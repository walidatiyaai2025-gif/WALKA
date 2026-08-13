#!/usr/bin/env python3
"""Deterministic Pink canonical re-extraction from the approved source panel.

This tool never recolors, reconstructs geometry, invents accessories, or reads
pixels outside the PINKSRC-approved product panel. It exists so the canonical
Pink PNG can be reproduced from source truth instead of a rejected white-matte
candidate.
"""
from __future__ import annotations

import argparse
import hashlib
import io
import json
import struct
import zlib
from pathlib import Path

import cv2
import numpy as np
from PIL import Image
from scipy import ndimage

SOURCE_SHA256 = "11a6020417067a8a1869eff1df90d0843f1e068a6cdc06d25e5c92abb1d2e3f5"
SOURCE_BYTES = 189515
SOURCE_SIZE = (695, 1536)
PANEL = (28, 760, 647, 575)
EXPECTED_SHA256 = "1667519c9a1931f16c8d26acefbed65e1f39ae7820ac58551de71a61a580d7fb"
EXPECTED_BYTES = 749558
EXPECTED_BBOX = [51, 125, 972, 898]
SAFE_MARGIN = 51
CANVAS = 1024
MAX_BYTES = 1258291


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def _write_srgb_png(rgba: np.ndarray, output: Path) -> None:
    raw = output.with_suffix(".raw.png")
    Image.fromarray(rgba, "RGBA").save(raw, compress_level=9)
    data = raw.read_bytes()
    if data[:8] != b"\x89PNG\r\n\x1a\n":
        raise SystemExit("generated output is not PNG")
    pos = 8
    chunks: list[tuple[bytes, bytes]] = []
    has_srgb = False
    while pos < len(data):
        length = struct.unpack(">I", data[pos:pos + 4])[0]
        kind = data[pos + 4:pos + 8]
        chunk = data[pos:pos + 12 + length]
        chunks.append((kind, chunk))
        has_srgb = has_srgb or kind == b"sRGB"
        pos += 12 + length
    encoded = bytearray(data[:8])
    for kind, chunk in chunks:
        encoded.extend(chunk)
        if kind == b"IHDR" and not has_srgb:
            payload = b"\x00"
            crc = zlib.crc32(b"sRGB" + payload) & 0xFFFFFFFF
            encoded.extend(
                struct.pack(">I", 1)
                + b"sRGB"
                + payload
                + struct.pack(">I", crc)
            )
            has_srgb = True
    output.write_bytes(bytes(encoded))
    raw.unlink()


def build(source: Path, output: Path) -> dict[str, object]:
    if source.stat().st_size != SOURCE_BYTES or sha256(source) != SOURCE_SHA256:
        raise SystemExit("Pink source fingerprint/size mismatch")
    source_rgb = np.array(Image.open(source).convert("RGB"))
    if (source_rgb.shape[1], source_rgb.shape[0]) != SOURCE_SIZE:
        raise SystemExit(f"Pink source dimensions changed: {source_rgb.shape!r}")
    x, y, width, height = PANEL
    panel_source = source_rgb[y:y + height, x:x + width].copy()
    if panel_source.shape != (575, 647, 3):
        raise SystemExit(f"approved product panel shape changed: {panel_source.shape!r}")
    # The accepted production experiment locked a JPEG95 product-panel working
    # derivative before segmentation. Recreate that derivative in memory so the
    # admitted canonical PNG remains byte-for-byte reproducible.
    panel_buffer = io.BytesIO()
    Image.fromarray(panel_source, "RGB").save(panel_buffer, format="JPEG", quality=95)
    panel_buffer.seek(0)
    panel = np.array(Image.open(panel_buffer).convert("RGB"))

    hsv = cv2.cvtColor(panel, cv2.COLOR_RGB2HSV)
    sat, val = hsv[:, :, 1], hsv[:, :, 2]
    gray = cv2.cvtColor(panel, cv2.COLOR_RGB2GRAY)
    edges = cv2.Canny(gray, 25, 70)
    edges = cv2.morphologyEx(
        edges, cv2.MORPH_CLOSE, np.ones((5, 5), np.uint8), iterations=2
    )
    edges = cv2.dilate(edges, np.ones((3, 3), np.uint8), iterations=1)
    contours, _ = cv2.findContours(
        edges, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE
    )
    mask = np.zeros(gray.shape, np.uint8)
    for contour in contours:
        if cv2.contourArea(contour) > 20:
            cv2.drawContours(mask, [contour], -1, 255, cv2.FILLED)

    background_candidate = ((val > 235) & (sat < 25)).astype(np.uint8)
    count, labels, stats, _ = cv2.connectedComponentsWithStats(
        background_candidate, 8
    )
    border_background = np.zeros_like(background_candidate)
    for index in range(1, count):
        bx, by, bw, bh, _area = stats[index]
        if (
            bx == 0
            or by == 0
            or bx + bw == background_candidate.shape[1]
            or by + bh == background_candidate.shape[0]
        ):
            border_background[labels == index] = 1
    mask[border_background.astype(bool)] = 0

    mask = cv2.morphologyEx(
        mask, cv2.MORPH_CLOSE, np.ones((3, 3), np.uint8), iterations=1
    )
    inverted = cv2.bitwise_not(mask)
    flooded = inverted.copy()
    flood_mask = np.zeros((flooded.shape[0] + 2, flooded.shape[1] + 2), np.uint8)
    cv2.floodFill(flooded, flood_mask, (0, 0), 0)
    mask = cv2.bitwise_or(mask, flooded)

    eroded = cv2.erode(
        (mask > 0).astype(np.uint8),
        np.ones((3, 3), np.uint8),
        iterations=1,
    )
    distance = cv2.distanceTransform(eroded, cv2.DIST_L2, 3)
    alpha = np.clip(distance / 1.6 * 255, 0, 255).astype(np.uint8)

    core = alpha >= 250
    _, nearest_indices = ndimage.distance_transform_edt(
        ~core, return_indices=True
    )
    nearest_rgb = panel[nearest_indices[0], nearest_indices[1]]
    cleaned = panel.astype(np.float32)
    chroma = panel.max(2) - panel.min(2)
    partial_edge = (alpha > 0) & (alpha < 250)
    light_edge = (panel.mean(2) > 220) & (chroma < 25)
    weight = np.where(light_edge, 0.85, 0.30).astype(np.float32)[..., None]
    cleaned[partial_edge] = (
        cleaned[partial_edge] * (1 - weight[partial_edge])
        + nearest_rgb[partial_edge] * weight[partial_edge]
    )
    cleaned = np.clip(cleaned, 0, 255).astype(np.uint8)

    # The approved panel contains a small bright source-background fleck above
    # the bag in the first 25 rows. Remove only bright/low-chroma pixels there;
    # Pink fabric/strap pixels remain untouched.
    cleaned_hsv = cv2.cvtColor(cleaned, cv2.COLOR_RGB2HSV)
    cleaned_sat, cleaned_val = cleaned_hsv[:, :, 1], cleaned_hsv[:, :, 2]
    top_artifact = np.zeros_like(alpha, dtype=bool)
    top_artifact[:25, :] = (
        (cleaned_sat[:25, :] < 35) & (cleaned_val[:25, :] > 200)
    )
    alpha[top_artifact] = 0

    rgba = np.dstack([cleaned, alpha])
    ys, xs = np.where(alpha > 2)
    if len(xs) == 0:
        raise SystemExit("Pink foreground mask is empty")
    source_bbox = [int(xs.min()), int(ys.min()), int(xs.max()), int(ys.max())]
    crop = rgba[source_bbox[1]:source_bbox[3] + 1, source_bbox[0]:source_bbox[2] + 1]

    inner = CANVAS - 2 * SAFE_MARGIN
    crop_h, crop_w = crop.shape[:2]
    scale = min(inner / crop_w, inner / crop_h)
    out_w, out_h = round(crop_w * scale), round(crop_h * scale)

    crop_alpha = crop[:, :, 3].astype(np.float32) / 255.0
    premultiplied = crop[:, :, :3].astype(np.float32) * crop_alpha[..., None]
    premultiplied_resized = cv2.resize(
        premultiplied, (out_w, out_h), interpolation=cv2.INTER_LANCZOS4
    )
    alpha_resized = np.clip(
        cv2.resize(crop_alpha, (out_w, out_h), interpolation=cv2.INTER_LANCZOS4),
        0,
        1,
    )
    rgb_resized = np.zeros((out_h, out_w, 3), np.float32)
    nonzero = alpha_resized > 1e-5
    rgb_resized[nonzero] = (
        premultiplied_resized[nonzero] / alpha_resized[nonzero, None]
    )

    canvas = np.zeros((CANVAS, CANVAS, 4), np.uint8)
    offset_x = (CANVAS - out_w) // 2
    offset_y = (CANVAS - out_h) // 2
    canvas[offset_y:offset_y + out_h, offset_x:offset_x + out_w, :3] = (
        np.clip(rgb_resized, 0, 255).astype(np.uint8)
    )
    canvas[offset_y:offset_y + out_h, offset_x:offset_x + out_w, 3] = (
        np.clip(alpha_resized * 255, 0, 255).astype(np.uint8)
    )

    output.parent.mkdir(parents=True, exist_ok=True)
    _write_srgb_png(canvas, output)

    output_rgba = np.array(Image.open(output).convert("RGBA"))
    ys, xs = np.where(output_rgba[:, :, 3] > 2)
    bbox = [int(xs.min()), int(ys.min()), int(xs.max()), int(ys.max())]
    margins = [bbox[0], bbox[1], 1023 - bbox[2], 1023 - bbox[3]]
    receipt = {
        "sourceSha256": sha256(source),
        "sourceBytes": source.stat().st_size,
        "sourceDimensions": list(SOURCE_SIZE),
        "approvedPanel": list(PANEL),
        "canonicalSha256": sha256(output),
        "canonicalBytes": output.stat().st_size,
        "canonicalDimensions": [CANVAS, CANVAS],
        "alphaBoundingBox": bbox,
        "transparentMargins": margins,
        "minimumTransparentSafeMargin": min(margins),
        "sRGB": b"sRGB" in output.read_bytes(),
        "marketplacePixelsOutsidePanelExcluded": True,
        "recolor": False,
        "geometryReconstruction": False,
        "accessoryInvention": False,
        "generativeFill": False,
    }
    if receipt["canonicalSha256"] != EXPECTED_SHA256:
        raise SystemExit(
            f"Pink canonical SHA mismatch: {receipt['canonicalSha256']}"
        )
    if receipt["canonicalBytes"] != EXPECTED_BYTES:
        raise SystemExit(
            f"Pink canonical byte-size mismatch: {receipt['canonicalBytes']}"
        )
    if bbox != EXPECTED_BBOX:
        raise SystemExit(f"Pink canonical alpha bbox mismatch: {bbox}")
    if min(margins) < SAFE_MARGIN:
        raise SystemExit(f"Pink canonical safe margin too small: {margins}")
    if output.stat().st_size > MAX_BYTES:
        raise SystemExit("Pink canonical exceeds file budget")
    if not receipt["sRGB"]:
        raise SystemExit("Pink canonical is missing sRGB")
    return receipt


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--receipt", type=Path)
    args = parser.parse_args()
    receipt = build(args.source, args.output)
    if args.receipt:
        args.receipt.parent.mkdir(parents=True, exist_ok=True)
        args.receipt.write_text(json.dumps(receipt, indent=2) + "\n")
    print(json.dumps(receipt, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
