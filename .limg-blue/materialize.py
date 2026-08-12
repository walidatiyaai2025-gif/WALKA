from __future__ import annotations
from pathlib import Path
from PIL import Image, ImageDraw
import hashlib, json, struct, zlib
import numpy as np
from zopfli.zlib import compress as zopfli_compress

ROOT = Path('.')
SOURCE = ROOT / 'main new(3).jpg'
ALPHA = ROOT / 'finalmask_alpha.png'
OUT = Path('mobile/assets/products/lunch/blue.png')
EXPECTED_SOURCE_SHA = '1ad36a3c917ea7e0e4dbadfd68070e4ebc1392cf78217fd860640e1a3d68077e'
EXPECTED_CANONICAL_SHA = '6ae7a29c62a691b5b55239d10a984df2aa16c04bcc0e42670a4d68b322c3a194'
EXPECTED_CANONICAL_BYTES = 594322


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def png_chunk(kind: bytes, data: bytes) -> bytes:
    return struct.pack('>I', len(data)) + kind + data + struct.pack('>I', zlib.crc32(kind + data) & 0xffffffff)


def paeth_predictor(a: np.ndarray, b: np.ndarray, c: np.ndarray) -> np.ndarray:
    aa = a.astype(np.int16)
    bb = b.astype(np.int16)
    cc = c.astype(np.int16)
    p = aa + bb - cc
    pa = np.abs(p - aa)
    pb = np.abs(p - bb)
    pc = np.abs(p - cc)
    return np.where((pa <= pb) & (pa <= pc), aa, np.where(pb <= pc, bb, cc)).astype(np.uint8)


def filter_score(value: np.ndarray) -> int:
    signed = value.astype(np.int16)
    signed = np.where(signed < 128, signed, 256 - signed)
    return int(signed.sum())


def encode_rgba_png_zopfli(image: Image.Image, output: Path) -> None:
    arr = np.asarray(image.convert('RGBA'), dtype=np.uint8)
    height, width, _ = arr.shape
    bytes_per_pixel = 4
    previous = np.zeros((width, bytes_per_pixel), dtype=np.uint8)
    rows: list[bytes] = []
    for y in range(height):
        row = arr[y].reshape(width, bytes_per_pixel)
        left = np.vstack([np.zeros((1, bytes_per_pixel), dtype=np.uint8), row[:-1]])
        upper_left = np.vstack([np.zeros((1, bytes_per_pixel), dtype=np.uint8), previous[:-1]])
        candidates: list[tuple[int, np.ndarray]] = [
            (0, row.reshape(-1)),
            (1, ((row.astype(np.int16) - left.astype(np.int16)) & 255).astype(np.uint8).reshape(-1)),
            (2, ((row.astype(np.int16) - previous.astype(np.int16)) & 255).astype(np.uint8).reshape(-1)),
        ]
        average = ((left.astype(np.uint16) + previous.astype(np.uint16)) // 2).astype(np.uint8)
        candidates.append((3, ((row.astype(np.int16) - average.astype(np.int16)) & 255).astype(np.uint8).reshape(-1)))
        predictor = paeth_predictor(left, previous, upper_left)
        candidates.append((4, ((row.astype(np.int16) - predictor.astype(np.int16)) & 255).astype(np.uint8).reshape(-1)))
        kind, payload = min(candidates, key=lambda item: filter_score(item[1]))
        rows.append(bytes([kind]) + payload.tobytes())
        previous = row.copy()
    compressed = zopfli_compress(b''.join(rows), numiterations=3)
    ihdr = struct.pack('>IIBBBBB', width, height, 8, 6, 0, 0, 0)
    png = (
        b'\x89PNG\r\n\x1a\n'
        + png_chunk(b'IHDR', ihdr)
        + png_chunk(b'sRGB', b'\x00')
        + png_chunk(b'IDAT', compressed)
        + png_chunk(b'IEND', b'')
    )
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_bytes(png)


def main() -> None:
    assert sha256(SOURCE) == EXPECTED_SOURCE_SHA, 'approved source fingerprint mismatch'
    source = Image.open(SOURCE).convert('RGB')
    alpha = Image.open(ALPHA).convert('L')
    ImageDraw.Draw(alpha).polygon(
        [(669, 664), (718, 672), (716, 686), (707, 696), (693, 702), (679, 701), (669, 692)],
        fill=255,
    )

    colors = np.asarray(source).astype(np.float32)
    opacity = np.asarray(alpha).astype(np.float32) / 255.0
    rgb = np.zeros_like(colors, dtype=np.uint8)
    opaque = opacity >= 0.999
    semi = (opacity > 0) & (~opaque)
    rgb[opaque] = np.clip(colors[opaque], 0, 255).astype(np.uint8)
    if semi.any():
        av = opacity[semi, None]
        foreground = (colors[semi] - 255.0 * (1.0 - av)) / np.maximum(av, 1e-6)
        rgb[semi] = np.clip(np.rint(foreground), 0, 255).astype(np.uint8)

    rgba = np.dstack([rgb, np.asarray(alpha, dtype=np.uint8)])
    ys, xs = np.where(rgba[:, :, 3] > 0)
    box = (int(xs.min()), int(ys.min()), int(xs.max()) + 1, int(ys.max()) + 1)
    cutout = Image.fromarray(rgba, 'RGBA').crop(box)
    new_width = 922
    new_height = round(cutout.height * new_width / cutout.width)
    cutout = cutout.resize((new_width, new_height), Image.Resampling.LANCZOS)
    canvas = Image.new('RGBA', (1024, 1024), (0, 0, 0, 0))
    canvas.alpha_composite(cutout, ((1024 - new_width) // 2, (1024 - new_height) // 2))
    encode_rgba_png_zopfli(canvas, OUT)

    result = np.asarray(Image.open(OUT).convert('RGBA'))
    output_alpha = result[:, :, 3]
    ys, xs = np.where(output_alpha > 0)
    bbox = [int(xs.min()), int(ys.min()), int(xs.max()), int(ys.max())]
    margins = [bbox[0], 1023 - bbox[2], bbox[1], 1023 - bbox[3]]
    assert min(margins) >= 51
    assert output_alpha[0, :].max() == output_alpha[-1, :].max() == 0
    assert output_alpha[:, 0].max() == output_alpha[:, -1].max() == 0
    assert OUT.stat().st_size == EXPECTED_CANONICAL_BYTES
    assert sha256(OUT) == EXPECTED_CANONICAL_SHA
    assert b'sRGB' in OUT.read_bytes()
    print(json.dumps({
        'sha256': sha256(OUT),
        'byteSize': OUT.stat().st_size,
        'alphaBoundingBox': bbox,
        'marginsLeftRightTopBottom': margins,
        'nearestTransparentSafeMargin': min(margins),
    }, indent=2))


if __name__ == '__main__':
    main()
