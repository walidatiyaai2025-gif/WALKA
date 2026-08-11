#!/usr/bin/env python3
"""Materialize the approved Drawer White canonical PNG from the exact source.

Fail closed: input bytes must match the owner-connected approved source and the
output must match deterministic geometry, alpha, PNG structure, bytes and SHA.
No recolor, hidden-geometry reconstruction, or protected Images/ input is used.
"""
from __future__ import annotations

import argparse
import hashlib
import io
from pathlib import Path
import struct
import zlib

import cv2
import numpy as np
from PIL import Image

SOURCE_SHA256 = "89d7b586c45bd6121537db479139449eb3b8f637c9396d83790d4fd0e03263c2"
OUTPUT_SHA256 = "b2c6967b6ccb3283a90e26337f90fe15f2f707dbcf20531d760fb656c06d234f"
OUTPUT_BYTES = 189339
CANVAS = 1024
VISIBLE_WIDTH = 922
BACKGROUND_DISTANCE_THRESHOLD = 18.0
EXPECTED_BBOX = (51, 184, 973, 840)  # PIL exclusive right/bottom.


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def sha256(path: Path) -> str:
    return sha256_bytes(path.read_bytes())


def _insert_srgb_chunk(png_bytes: bytes) -> bytes:
    signature = b"\x89PNG\r\n\x1a\n"
    if not png_bytes.startswith(signature):
        raise SystemExit("generated payload is not PNG")
    ihdr_length = struct.unpack(">I", png_bytes[8:12])[0]
    if png_bytes[12:16] != b"IHDR" or ihdr_length != 13:
        raise SystemExit("generated PNG has invalid IHDR")
    ihdr_end = 8 + 12 + ihdr_length
    chunk_type = b"sRGB"
    chunk_data = b"\x00"  # perceptual rendering intent.
    crc = zlib.crc32(chunk_type + chunk_data) & 0xFFFFFFFF
    srgb_chunk = (
        struct.pack(">I", len(chunk_data))
        + chunk_type
        + chunk_data
        + struct.pack(">I", crc)
    )
    return png_bytes[:ihdr_end] + srgb_chunk + png_bytes[ihdr_end:]


def materialize(source_path: Path, output_path: Path) -> None:
    source_hash = sha256(source_path)
    if source_hash != SOURCE_SHA256:
        raise SystemExit(
            f"approved source fingerprint mismatch: {source_hash} != {SOURCE_SHA256}"
        )

    source = Image.open(source_path).convert("RGB")
    if source.size != (1416, 943):
        raise SystemExit(f"approved source dimensions changed: {source.size}")

    rgb = np.array(source)
    distance = np.sqrt(((255 - rgb.astype(np.float32)) ** 2).sum(axis=2))
    threshold_mask = (distance > BACKGROUND_DISTANCE_THRESHOLD).astype(np.uint8) * 255
    contours, _ = cv2.findContours(
        threshold_mask,
        cv2.RETR_EXTERNAL,
        cv2.CHAIN_APPROX_SIMPLE,
    )
    if not contours:
        raise SystemExit("no product contour found in approved source")

    contour = max(contours, key=cv2.contourArea)
    x, y, width, height = cv2.boundingRect(contour)
    if (x, y, width, height) != (92, 2, 1321, 941):
        raise SystemExit(
            f"approved source contour changed: {(x, y, width, height)}"
        )

    silhouette = np.zeros(threshold_mask.shape, np.uint8)
    cv2.drawContours(silhouette, [contour], -1, 255, cv2.FILLED)

    crop_rgb = rgb[y : y + height, x : x + width]
    crop_mask = silhouette[y : y + height, x : x + width]
    target_height = int(height * VISIBLE_WIDTH / width)
    if target_height != 656:
        raise SystemExit(f"unexpected normalized product height: {target_height}")

    resized_rgb = Image.fromarray(crop_rgb).resize(
        (VISIBLE_WIDTH, target_height), Image.Resampling.LANCZOS
    )
    resized_mask = Image.fromarray(crop_mask).resize(
        (VISIBLE_WIDTH, target_height), Image.Resampling.LANCZOS
    )

    canvas = Image.new("RGBA", (CANVAS, CANVAS), (0, 0, 0, 0))
    product = resized_rgb.convert("RGBA")
    product.putalpha(resized_mask)
    x_offset = (CANVAS - VISIBLE_WIDTH) // 2
    y_offset = (CANVAS - target_height) // 2
    canvas.alpha_composite(product, (x_offset, y_offset))

    if canvas.getchannel("A").getbbox() != EXPECTED_BBOX:
        raise SystemExit(
            f"alpha bounding box changed: {canvas.getchannel('A').getbbox()}"
        )

    # Re-wrap pixel bytes into a fresh image so no dynamic ICC metadata survives.
    # PAV explicitly accepts a standards-compliant sRGB PNG chunk, which is then
    # inserted with deterministic bytes and CRC.
    clean = Image.fromarray(np.array(canvas), "RGBA")
    buffer = io.BytesIO()
    clean.save(buffer, "PNG", optimize=True)
    output_bytes = _insert_srgb_chunk(buffer.getvalue())

    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_bytes(output_bytes)

    generated_hash = sha256_bytes(output_bytes)
    generated_bytes = len(output_bytes)
    if generated_hash != OUTPUT_SHA256 or generated_bytes != OUTPUT_BYTES:
        raise SystemExit(
            "deterministic output mismatch: "
            f"sha={generated_hash} bytes={generated_bytes}; "
            f"expected sha={OUTPUT_SHA256} bytes={OUTPUT_BYTES}"
        )

    print(f"source_sha256={source_hash}")
    print(f"output_sha256={generated_hash}")
    print(f"output_bytes={generated_bytes}")
    print(f"alpha_bbox={EXPECTED_BBOX}")
    print("safe_margins=51,51,184,184")
    print("color_profile=sRGB chunk")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()
    materialize(args.source, args.output)


if __name__ == "__main__":
    main()
