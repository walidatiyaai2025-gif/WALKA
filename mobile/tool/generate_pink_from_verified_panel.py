#!/usr/bin/env python3
"""Generate the Pink review candidate from the exact approved product panel.

This tool is deliberately fail closed. It never decides production admission or
owner visual acceptance. It only transforms an already verified 647x575 RGB
panel into a deterministic 1024x1024 RGBA review candidate and refuses to
succeed unless every locked fingerprint/geometry budget matches.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path

import cv2
import numpy as np
from PIL import Image, ImageCms
from scipy import ndimage

PANEL_SHA256 = "da57ff18b5e6fb06cc3a685c16ef05fa8d9592d6c6b3986e3450380e28db7e0b"
PANEL_BYTES = 301945
PANEL_SIZE = (647, 575)
EXPECTED_CANDIDATE_SHA256 = "755ead90e98b51f2fd732c267c01671ffa776d59624565b7521bd4c4ac3f1776"
EXPECTED_CANDIDATE_BYTES = 683551
EXPECTED_ALPHA_BBOX = [51, 128, 973, 895]
MIN_SAFE_MARGIN = 51
MAX_BYTES = 1_258_291

OBJECTS = {
    "bag": (300, 0, 345, 205),
    "lunchbox": (0, 85, 345, 170),
    "tray_base": (0, 190, 500, 360),
    "utensils": (390, 150, 257, 180),
    "cup_lid": (445, 285, 190, 190),
}

PROOF_COLORS = {
    "white": (255, 255, 255),
    "ivory": (245, 241, 232),
    "navy": (8, 22, 45),
}
DOWNSCALES = (96, 160, 240, 384)


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def load_verified_panel(path: Path) -> np.ndarray:
    raw = path.read_bytes()
    if sha256_bytes(raw) != PANEL_SHA256:
        raise RuntimeError("approved panel SHA-256 mismatch")
    if len(raw) != PANEL_BYTES:
        raise RuntimeError("approved panel byte-size mismatch")
    image = Image.open(path).convert("RGB")
    if image.size != PANEL_SIZE:
        raise RuntimeError(f"approved panel dimensions drifted: {image.size}")
    return np.array(image)


def build_foreground(panel: np.ndarray) -> tuple[np.ndarray, dict[str, object]]:
    h, w = panel.shape[:2]
    white_lab = cv2.cvtColor(
        np.uint8([[[255, 255, 255]]]), cv2.COLOR_RGB2LAB
    ).astype(np.float32)[0, 0]
    union = np.zeros((h, w), np.uint8)
    component_stats: dict[str, object] = {}

    for name, (x, y, ww, hh) in OBJECTS.items():
        x0, y0 = max(0, x), max(0, y)
        x1, y1 = min(w, x + ww), min(h, y + hh)
        crop = panel[y0:y1, x0:x1]
        ch, cw = crop.shape[:2]
        if cw < 5 or ch < 5:
            raise RuntimeError(f"invalid object crop: {name}")

        gmask = np.zeros((ch, cw), np.uint8)
        bgd = np.zeros((1, 65), np.float64)
        fgd = np.zeros((1, 65), np.float64)
        cv2.grabCut(
            cv2.cvtColor(crop, cv2.COLOR_RGB2BGR),
            gmask,
            (2, 2, cw - 4, ch - 4),
            bgd,
            fgd,
            8,
            cv2.GC_INIT_WITH_RECT,
        )
        fg = ((gmask == cv2.GC_FGD) | (gmask == cv2.GC_PR_FGD)).astype(np.uint8)

        # Remove only near-white regions connected to the local crop frame.
        # Enclosed stainless/white product highlights remain foreground.
        lab = cv2.cvtColor(crop, cv2.COLOR_RGB2LAB).astype(np.float32)
        distance = np.linalg.norm(lab - white_lab, axis=2)
        near_white = (distance < 18).astype(np.uint8)
        _, labels = cv2.connectedComponents(near_white, 8)
        border_labels = np.unique(
            np.concatenate([labels[0], labels[-1], labels[:, 0], labels[:, -1]])
        )
        border_labels = border_labels[border_labels != 0]
        fg[np.isin(labels, border_labels)] = 0

        # Remove tiny isolated specks only. No morphology is used because it can
        # mutate thin fork/spoon geometry.
        count, labels, stats, _ = cv2.connectedComponentsWithStats(fg, 8)
        keep = [
            index
            for index in range(1, count)
            if stats[index, cv2.CC_STAT_AREA] >= 40
        ]
        fg = np.isin(labels, keep).astype(np.uint8)
        union[y0:y1, x0:x1] |= fg
        component_stats[name] = {
            "foregroundPixels": int(fg.sum()),
            "componentsKept": len(keep),
        }

    count, _, stats, _ = cv2.connectedComponentsWithStats(union, 8)
    areas = sorted(
        [int(stats[index, cv2.CC_STAT_AREA]) for index in range(1, count)],
        reverse=True,
    )
    if len(areas) < 4 or areas[0] <= 50_000:
        raise RuntimeError("foreground component topology failed closed")

    return union, {
        "foregroundPixels": int(union.sum()),
        "connectedComponentAreas": areas,
        "objects": component_stats,
    }


def generate(panel: np.ndarray) -> tuple[np.ndarray, dict[str, object]]:
    union, mask_metrics = build_foreground(panel)
    foreground = union.astype(bool)
    if not foreground.any():
        raise RuntimeError("empty foreground")

    # Source-derived nearest-foreground RGB padding prevents white matte during
    # Lanczos interpolation. Alpha remains the sole segmentation authority.
    _, indices = ndimage.distance_transform_edt(~foreground, return_indices=True)
    filled = panel.copy()
    background = ~foreground
    filled[background] = panel[indices[0, background], indices[1, background]]
    alpha = (union * 255).astype(np.uint8)

    ys, xs = np.where(foreground)
    x0, y0 = int(xs.min()), int(ys.min())
    x1, y1 = int(xs.max() + 1), int(ys.max() + 1)
    rgb_crop = filled[y0:y1, x0:x1]
    alpha_crop = alpha[y0:y1, x0:x1]

    max_dim = 1024 - 102
    scale = min(max_dim / rgb_crop.shape[1], max_dim / rgb_crop.shape[0])
    new_w = max(1, round(rgb_crop.shape[1] * scale))
    new_h = max(1, round(rgb_crop.shape[0] * scale))

    alpha_float = alpha_crop.astype(np.float32) / 255.0
    premultiplied = rgb_crop.astype(np.float32) * alpha_float[:, :, None]
    resized_premul = cv2.resize(
        premultiplied, (new_w, new_h), interpolation=cv2.INTER_LANCZOS4
    )
    resized_alpha = cv2.resize(
        alpha_float, (new_w, new_h), interpolation=cv2.INTER_LANCZOS4
    )
    resized_alpha = np.clip(resized_alpha, 0, 1)
    resized_premul = np.clip(resized_premul, 0, 255)

    resized_rgb = np.zeros_like(resized_premul)
    nonzero = resized_alpha > 1e-6
    resized_rgb[nonzero] = (
        resized_premul[nonzero] / resized_alpha[nonzero, None]
    )
    resized_rgb = np.clip(resized_rgb, 0, 255).astype(np.uint8)
    resized_alpha_u8 = np.clip(np.rint(resized_alpha * 255), 0, 255).astype(np.uint8)
    resized_alpha_u8[resized_alpha_u8 < 3] = 0

    canvas = np.zeros((1024, 1024, 4), np.uint8)
    px = (1024 - new_w) // 2
    py = (1024 - new_h) // 2
    canvas[py : py + new_h, px : px + new_w, :3] = resized_rgb
    canvas[py : py + new_h, px : px + new_w, 3] = resized_alpha_u8

    return canvas, {
        "panelMask": {
            "bbox": [x0, y0, x1, y1],
            **mask_metrics,
        },
        "resizedForeground": [new_w, new_h],
        "canvasOffset": [px, py],
    }


def save_png(canvas: np.ndarray, output: Path) -> bytes:
    output.parent.mkdir(parents=True, exist_ok=True)
    image = Image.fromarray(canvas, "RGBA")
    profile = ImageCms.ImageCmsProfile(ImageCms.createProfile("sRGB")).tobytes()
    image.save(output, compress_level=9, optimize=True, icc_profile=profile)
    return output.read_bytes()


def alpha_metrics(canvas: np.ndarray) -> tuple[list[int], list[int]]:
    alpha = canvas[:, :, 3]
    ys, xs = np.where(alpha >= 8)
    if not len(xs):
        raise RuntimeError("candidate has no visible alpha")
    bbox = [int(xs.min()), int(ys.min()), int(xs.max() + 1), int(ys.max() + 1)]
    margins = [bbox[0], bbox[1], 1024 - bbox[2], 1024 - bbox[3]]
    return bbox, margins


def write_proofs(canvas: np.ndarray, proof_dir: Path) -> None:
    proof_dir.mkdir(parents=True, exist_ok=True)
    candidate = Image.fromarray(canvas, "RGBA")
    for name, color in PROOF_COLORS.items():
        background = Image.new("RGBA", (1024, 1024), color + (255,))
        background.alpha_composite(candidate)
        rgb = background.convert("RGB")
        rgb.save(proof_dir / f"proof_{name}_1024.png", optimize=True)
        for size in DOWNSCALES:
            rgb.resize((size, size), Image.Resampling.LANCZOS).save(
                proof_dir / f"proof_{name}_{size}.png", optimize=True
            )


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--panel", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--receipt", required=True, type=Path)
    parser.add_argument("--proof-dir", required=True, type=Path)
    args = parser.parse_args()

    panel = load_verified_panel(args.panel)
    canvas, generation = generate(panel)
    output_bytes = save_png(canvas, args.output)
    output_sha = sha256_bytes(output_bytes)
    bbox, margins = alpha_metrics(canvas)

    if output_sha != EXPECTED_CANDIDATE_SHA256:
        raise RuntimeError(
            f"candidate SHA drift: {output_sha} != {EXPECTED_CANDIDATE_SHA256}"
        )
    if len(output_bytes) != EXPECTED_CANDIDATE_BYTES:
        raise RuntimeError("candidate byte-size drift")
    if bbox != EXPECTED_ALPHA_BBOX:
        raise RuntimeError(f"candidate alpha bbox drift: {bbox}")
    if min(margins) < MIN_SAFE_MARGIN:
        raise RuntimeError(f"safe margin below {MIN_SAFE_MARGIN}px: {margins}")
    if len(output_bytes) > MAX_BYTES:
        raise RuntimeError("candidate exceeds 1.2 MiB hard budget")

    write_proofs(canvas, args.proof_dir)
    partial = (canvas[:, :, 3] > 0) & (canvas[:, :, 3] < 255)
    receipt = {
        "schemaVersion": 1,
        "variantId": "lunch-box:pink",
        "state": "REVIEW_CANDIDATE_OWNER_ACCEPTANCE_REQUIRED",
        "source": {
            "filename": "1000389975.jpg",
            "sha256": "11a6020417067a8a1869eff1df90d0843f1e068a6cdc06d25e5c92abb1d2e3f5",
            "bytes": 189515,
            "dimensions": [695, 1536],
            "approvedPanel": {"x": 28, "y": 760, "width": 647, "height": 575},
            "verifiedPanelSha256": PANEL_SHA256,
            "verifiedPanelBytes": PANEL_BYTES,
        },
        "candidate": {
            "path": "assets/products/lunch/pink.png",
            "sha256": output_sha,
            "bytes": len(output_bytes),
            "dimensions": [1024, 1024],
            "pixelFormat": "8-bit RGBA",
            "colorProfile": "sRGB",
            "alphaBoundingBox": bbox,
            "safeMargins": margins,
            "partialAlphaPixels": int(partial.sum()),
        },
        "algorithm": (
            "object-local GrabCut + border-connected Lab-white subtraction (<18) + "
            "source-derived nearest-foreground RGB padding + premultiplied Lanczos"
        ),
        "generation": generation,
        "requiredVisualQa": [
            "surfaceWhite",
            "surfaceIvory",
            "surfaceNavy",
            "downscale96",
            "downscale160",
            "downscale240",
            "downscale384",
            "geometryPreserved",
            "bakedUiExcluded",
        ],
        "guardrails": {
            "recolor": False,
            "geometryReconstruction": False,
            "generativeFill": False,
            "marketplacePixelsOutsideApprovedPanelIncluded": False,
            "automationCanAcceptVisualFidelity": False,
            "runtimeAdmissionChanged": False,
            "ownerVisualAcceptance": "REQUIRED",
        },
    }
    args.receipt.parent.mkdir(parents=True, exist_ok=True)
    args.receipt.write_text(json.dumps(receipt, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(receipt, indent=2))


if __name__ == "__main__":
    main()
