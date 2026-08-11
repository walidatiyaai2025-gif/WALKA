#!/usr/bin/env python3
from __future__ import annotations

import argparse
import struct
import zlib
from pathlib import Path

import cv2
import numpy as np
from PIL import Image


def add_srgb_chunk(in_path: Path, out_path: Path) -> None:
    data = in_path.read_bytes()
    if data[:8] != b'\x89PNG\r\n\x1a\n':
        raise ValueError('generated file is not PNG')
    pos = 8
    chunks: list[tuple[bytes, bytes]] = []
    has_srgb = False
    while pos < len(data):
        length = struct.unpack('>I', data[pos:pos + 4])[0]
        kind = data[pos + 4:pos + 8]
        chunk = data[pos:pos + 12 + length]
        if kind == b'sRGB':
            has_srgb = True
        chunks.append((kind, chunk))
        pos += 12 + length

    encoded = bytearray(data[:8])
    inserted = False
    for kind, chunk in chunks:
        encoded.extend(chunk)
        if kind == b'IHDR' and not has_srgb and not inserted:
            payload = b'\x00'
            ctype = b'sRGB'
            crc = zlib.crc32(ctype + payload) & 0xFFFFFFFF
            encoded.extend(struct.pack('>I', 1))
            encoded.extend(ctype)
            encoded.extend(payload)
            encoded.extend(struct.pack('>I', crc))
            inserted = True
    out_path.write_bytes(bytes(encoded))


def build(source: Path, destination: Path) -> None:
    rgb = np.array(Image.open(source).convert('RGB'))
    if rgb.shape != (1024, 1024, 3):
        raise ValueError(f'expected 1024x1024 approved Blue source, got {rgb.shape!r}')

    gray = cv2.cvtColor(rgb, cv2.COLOR_RGB2GRAY)
    edges = cv2.Canny(gray, 40, 100)
    edges = cv2.morphologyEx(
        edges,
        cv2.MORPH_CLOSE,
        np.ones((5, 5), np.uint8),
        iterations=2,
    )
    edges = cv2.dilate(edges, np.ones((3, 3), np.uint8), iterations=1)

    contours, _ = cv2.findContours(
        edges,
        cv2.RETR_EXTERNAL,
        cv2.CHAIN_APPROX_SIMPLE,
    )
    mask = np.zeros(gray.shape, np.uint8)
    for contour in contours:
        if cv2.contourArea(contour) > 100:
            cv2.drawContours(mask, [contour], -1, 255, cv2.FILLED)

    # One-pixel inward matte refinement removes the source white fringe while
    # preserving real geometry and stainless/cutlery highlights.
    mask = cv2.erode(mask, np.ones((3, 3), np.uint8), iterations=1)
    mask = cv2.GaussianBlur(mask, (0, 0), 0.6)

    ys, xs = np.where(mask > 2)
    if len(xs) == 0:
        raise ValueError('object mask is empty')
    x0, y0, x1, y1 = xs.min(), ys.min(), xs.max(), ys.max()
    crop_rgb = rgb[y0:y1 + 1, x0:x1 + 1]
    crop_a = mask[y0:y1 + 1, x0:x1 + 1]

    pad = 51
    inner = 1024 - 2 * pad
    scale = min(inner / crop_rgb.shape[1], inner / crop_rgb.shape[0])
    nw = round(crop_rgb.shape[1] * scale)
    nh = round(crop_rgb.shape[0] * scale)

    alpha = crop_a.astype(np.float32) / 255.0
    premultiplied = crop_rgb.astype(np.float32) * alpha[..., None]
    premultiplied_r = cv2.resize(
        premultiplied,
        (nw, nh),
        interpolation=cv2.INTER_LANCZOS4,
    )
    alpha_r = cv2.resize(alpha, (nw, nh), interpolation=cv2.INTER_LANCZOS4)
    alpha_r = np.clip(alpha_r, 0, 1)

    rgb_r = np.zeros((nh, nw, 3), np.float32)
    nonzero = alpha_r > 1e-5
    rgb_r[nonzero] = premultiplied_r[nonzero] / alpha_r[nonzero, None]
    rgb_r = np.clip(rgb_r, 0, 255).astype(np.uint8)
    alpha_u8 = np.clip(alpha_r * 255, 0, 255).astype(np.uint8)

    canvas = np.zeros((1024, 1024, 4), np.uint8)
    ox = (1024 - nw) // 2
    oy = (1024 - nh) // 2
    canvas[oy:oy + nh, ox:ox + nw, :3] = rgb_r
    canvas[oy:oy + nh, ox:ox + nw, 3] = alpha_u8

    destination.parent.mkdir(parents=True, exist_ok=True)
    raw = destination.with_suffix('.raw.png')
    Image.fromarray(canvas, 'RGBA').save(raw, compress_level=9)
    add_srgb_chunk(raw, destination)
    raw.unlink()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument('--source', required=True, type=Path)
    parser.add_argument('--output', required=True, type=Path)
    args = parser.parse_args()
    build(args.source, args.output)


if __name__ == '__main__':
    main()
