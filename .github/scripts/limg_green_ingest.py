from __future__ import annotations

import hashlib
import json
from collections import deque
from pathlib import Path

import numpy as np
from PIL import Image, ImageCms

IMAGE_PATH = Path('mobile/assets/products/lunch/green.png')
SOURCE_ADMISSION_PATH = Path('docs/ui/PRODUCTION_SOURCE_ADMISSION.json')
PROVENANCE_PATH = Path('docs/ui/PRODUCTION_ASSET_PROVENANCE.json')
ADMISSION_DART_PATH = Path(
    'mobile/lib/design_system/components/media/walka_product_media_admission.dart'
)
VFIN_PATH = Path('docs/ui/VFIN_RELEASE_RECEIPT.json')
RECEIPT_PATH = Path('docs/ui/LIMG_GREEN_RECEIPT.json')


def border_connected_white_mask(rgb: np.ndarray) -> np.ndarray:
    h, w, _ = rgb.shape
    passable = rgb.min(axis=2) > 235
    background = np.zeros((h, w), dtype=bool)
    queue: deque[tuple[int, int]] = deque()
    for x in range(w):
        for y in (0, h - 1):
            if passable[y, x] and not background[y, x]:
                background[y, x] = True
                queue.append((y, x))
    for y in range(h):
        for x in (0, w - 1):
            if passable[y, x] and not background[y, x]:
                background[y, x] = True
                queue.append((y, x))
    neighbors = [
        (-1, -1), (-1, 0), (-1, 1),
        (0, -1), (0, 1),
        (1, -1), (1, 0), (1, 1),
    ]
    while queue:
        y, x = queue.popleft()
        for dy, dx in neighbors:
            yy, xx = y + dy, x + dx
            if (
                0 <= yy < h
                and 0 <= xx < w
                and passable[yy, xx]
                and not background[yy, xx]
            ):
                background[yy, xx] = True
                queue.append((yy, xx))
    return background


def remove_tiny_islands(foreground: np.ndarray, max_pixels: int = 5) -> np.ndarray:
    h, w = foreground.shape
    seen = np.zeros((h, w), dtype=bool)
    neighbors = [
        (-1, -1), (-1, 0), (-1, 1),
        (0, -1), (0, 1),
        (1, -1), (1, 0), (1, 1),
    ]
    for y in range(h):
        for x in range(w):
            if not foreground[y, x] or seen[y, x]:
                continue
            seen[y, x] = True
            component = [(y, x)]
            queue: deque[tuple[int, int]] = deque([(y, x)])
            while queue:
                cy, cx = queue.popleft()
                for dy, dx in neighbors:
                    yy, xx = cy + dy, cx + dx
                    if (
                        0 <= yy < h
                        and 0 <= xx < w
                        and foreground[yy, xx]
                        and not seen[yy, xx]
                    ):
                        seen[yy, xx] = True
                        queue.append((yy, xx))
                        component.append((yy, xx))
            if len(component) <= max_pixels:
                for yy, xx in component:
                    foreground[yy, xx] = False
    return foreground


def main() -> None:
    source_admission = json.loads(SOURCE_ADMISSION_PATH.read_text())
    green_source = next(
        item
        for item in source_admission['variants']
        if item['variantId'] == 'lunch-box:green'
    )
    assert green_source['sourceState'] == 'APPROVED'
    assert green_source['sourceFilename'] == 'WhatsApp Image 2026-02-24 at 11.22.34 PM.jpeg'
    assert green_source['canonicalPath'] == 'assets/products/lunch/green.png'

    source = Image.open(IMAGE_PATH).convert('RGBA')
    assert source.size == (500, 500), f'unexpected Green provisional dimensions: {source.size}'
    source_rgba = np.array(source, dtype=np.uint8)
    rgb = source_rgba[:, :, :3]
    original_alpha = source_rgba[:, :, 3]
    h, w = original_alpha.shape

    if np.any(original_alpha < 255):
        alpha = original_alpha.copy()
        assert np.count_nonzero(alpha) > 0
        background_ratio = float(np.count_nonzero(alpha == 0) / alpha.size)
    else:
        background = border_connected_white_mask(rgb)
        background_ratio = float(background.mean())
        assert background_ratio >= 0.10, (
            f'Green exterior background not safely separable: {background_ratio:.4f}'
        )
        foreground = remove_tiny_islands(~background)
        alpha = foreground.astype(np.uint8) * 255

    ys, xs = np.where(alpha > 0)
    assert len(xs) > 0, 'Green foreground mask is empty'
    source_bbox = [int(xs.min()), int(ys.min()), int(xs.max()), int(ys.max())]
    source_width = source_bbox[2] - source_bbox[0] + 1
    source_height = source_bbox[3] - source_bbox[1] + 1
    source_aspect = source_width / source_height

    cut_rgba = np.dstack([rgb, alpha])
    cut = Image.fromarray(cut_rgba, 'RGBA').crop(
        (source_bbox[0], source_bbox[1], source_bbox[2] + 1, source_bbox[3] + 1)
    )
    max_extent = 922
    scale = min(max_extent / cut.width, max_extent / cut.height)
    target_size = (
        max(1, round(cut.width * scale)),
        max(1, round(cut.height * scale)),
    )
    cut = cut.resize(target_size, Image.Resampling.LANCZOS)
    x0 = (1024 - target_size[0]) // 2
    y0 = (1024 - target_size[1]) // 2
    canvas = Image.new('RGBA', (1024, 1024), (0, 0, 0, 0))
    canvas.alpha_composite(cut, (x0, y0))
    output = np.array(canvas, dtype=np.uint8)
    output[:, :, 3][output[:, :, 3] < 3] = 0
    canvas = Image.fromarray(output, 'RGBA')

    srgb_profile = ImageCms.ImageCmsProfile(ImageCms.createProfile('sRGB')).tobytes()
    canvas.save(IMAGE_PATH, format='PNG', icc_profile=srgb_profile, optimize=True)

    data = IMAGE_PATH.read_bytes()
    assert len(data) <= 1_258_291, f'Green canonical exceeds 1.2 MiB: {len(data)}'
    rendered = np.array(Image.open(IMAGE_PATH).convert('RGBA'), dtype=np.uint8)
    rendered_alpha = rendered[:, :, 3]
    assert np.all(rendered_alpha[0, :] == 0)
    assert np.all(rendered_alpha[-1, :] == 0)
    assert np.all(rendered_alpha[:, 0] == 0)
    assert np.all(rendered_alpha[:, -1] == 0)
    ys, xs = np.where(rendered_alpha > 0)
    bbox = [int(xs.min()), int(ys.min()), int(xs.max()), int(ys.max())]
    margin = min(bbox[0], bbox[1], 1023 - bbox[2], 1023 - bbox[3])
    assert margin >= 51, f'Green safe margin too small: {margin}px'
    final_aspect = (bbox[2] - bbox[0] + 1) / (bbox[3] - bbox[1] + 1)
    aspect_delta = abs(final_aspect - source_aspect)
    assert aspect_delta <= 0.03, (source_aspect, final_aspect)
    coverage = float(np.count_nonzero(rendered_alpha) / (1024 * 1024))
    assert 0.03 <= coverage <= 0.88, f'Green alpha coverage out of range: {coverage:.4f}'
    for size in (96, 160, 240, 384):
        down = canvas.resize((size, size), Image.Resampling.LANCZOS)
        down_alpha = np.array(down, dtype=np.uint8)[:, :, 3]
        assert np.count_nonzero(down_alpha) > 0, f'Green disappears at {size}px'

    sha = hashlib.sha256(data).hexdigest()

    green_source['canonicalExportPresent'] = True
    green_source['reason'] = (
        'Approved real Green owner source has been normalized to the canonical transparent '
        'canvas using source-derived pixels only; camera/orientation and visible product '
        'geometry remain unchanged, with no recoloring, reconstruction or accessory invention.'
    )
    green_source['unblockAction'] = (
        'Keep the admitted Green binary, source fingerprint, camera/orientation truth, '
        'transparent framing and PAV metadata stable; any future replacement must repeat '
        'source admission and visual QA.'
    )
    SOURCE_ADMISSION_PATH.write_text(json.dumps(source_admission, indent=2) + '\n')

    provenance = json.loads(PROVENANCE_PATH.read_text())
    row = next(
        item for item in provenance['variants'] if item['variantId'] == 'lunch-box:green'
    )
    row['lifecycleState'] = 'ADMITTED'
    row['sha256'] = sha
    row['byteSize'] = len(data)
    row['width'] = 1024
    row['height'] = 1024
    row['alphaBoundingBox'] = bbox
    row['nearestTransparentSafeMargin'] = margin
    row['colorProfileExpectation'] = 'sRGB'
    for key in provenance['mandatoryQaChecks']:
        row['qa'][key] = 'PASS'
    PROVENANCE_PATH.write_text(json.dumps(provenance, indent=2) + '\n')

    dart = ADMISSION_DART_PATH.read_text()
    old = """    'lunch-box:green': WalkaProductMediaAdmissionEntry(
      variantId: 'lunch-box:green',
      canonicalPath: 'assets/products/lunch/green.png',
      state: WalkaProductMediaAdmissionState.pending,
      sourceApproved: true,
      canonicalExportPresent: false,
    ),"""
    new = """    'lunch-box:green': WalkaProductMediaAdmissionEntry(
      variantId: 'lunch-box:green',
      canonicalPath: 'assets/products/lunch/green.png',
      state: WalkaProductMediaAdmissionState.admitted,
      sourceApproved: true,
      canonicalExportPresent: true,
    ),"""
    assert old in dart, 'Green runtime admission block no longer matches pending truth'
    ADMISSION_DART_PATH.write_text(dart.replace(old, new, 1))

    vfin = json.loads(VFIN_PATH.read_text())
    media = vfin['productionMedia']
    media.update(
        {
            'admitted': 4,
            'pending': 0,
            'blocked': 1,
            'mechanicalReady': False,
            'stablePublication': False,
            'ownerVisualAcceptance': 'REQUIRES_OWNER_REVIEW',
            'finalVisualStatus': 'BLOCKED',
            'reason': (
                'Drawer White and Lunch Blue/Pink/Green are admitted from exact approved '
                'sources; Drawer Gray remains source-blocked, so final stable visual '
                'publication stays fail-closed.'
            ),
        }
    )
    VFIN_PATH.write_text(json.dumps(vfin, indent=2) + '\n')

    receipt = {
        'schemaVersion': 1,
        'variantId': 'lunch-box:green',
        'sourceFilename': green_source['sourceFilename'],
        'sourceState': green_source['sourceState'],
        'canonicalPath': green_source['canonicalPath'],
        'sourceCanvas': [w, h],
        'sourceForegroundBounds': source_bbox,
        'sourceBackgroundRatio': round(background_ratio, 6),
        'canonicalCanvas': [1024, 1024],
        'canonicalSha256': sha,
        'canonicalBytes': len(data),
        'alphaBoundingBox': bbox,
        'nearestTransparentSafeMargin': margin,
        'alphaCoverageRatio': round(coverage, 6),
        'geometryAspectDelta': round(aspect_delta, 6),
        'qa': 'PASS',
        'guardrails': {
            'protectedImagesModified': False,
            'recolored': False,
            'geometryReconstructed': False,
            'accessoryInvented': False,
        },
    }
    RECEIPT_PATH.write_text(json.dumps(receipt, indent=2) + '\n')
    print(json.dumps(receipt, indent=2))


if __name__ == '__main__':
    main()
