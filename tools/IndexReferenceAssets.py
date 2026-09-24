"""Index local visual evidence without changing any source image.

PNG size, file hash and source classification establish which exact artifact a
review used. They do not establish game version, native playability or approval.
"""
from pathlib import Path
import hashlib
import json
import struct

ROOT = Path(__file__).resolve().parents[1]
BOARD = ROOT / 'docs' / 'ui-review'
raw = (BOARD / 'reference-set.js').read_text(encoding='utf-8')
dataset = json.loads(raw.split('const REFERENCE_SET = ', 1)[1].strip().removesuffix(';'))
records = []
missing = []
for view in dataset['rows']:
    items = [
        ('reference', view.get('sourceImage'), BOARD),
        ('implementation', view.get('current'), ROOT / 'artifacts'),
        ('concept', view.get('target'), ROOT / 'artifacts' / 'field-instruments-review'),
    ]
    for kind, name, base in items:
        if not name:
            continue
        path = (base / name).resolve()
        if not path.is_relative_to(ROOT):
            raise ValueError(f'Unexpected non-workspace artifact: {path}')
        if not path.is_file():
            missing.append(str(path.relative_to(ROOT)))
            continue
        blob = path.read_bytes()
        dimensions = list(struct.unpack('>II', blob[16:24])) if blob.startswith(b'\x89PNG\r\n\x1a\n') else None
        records.append({
            'view': view['id'], 'kind': kind,
            'path': path.relative_to(ROOT).as_posix(),
            'bytes': len(blob), 'sha256': hashlib.sha256(blob).hexdigest(),
            'resolution': dimensions,
            'approval': 'not implied by inclusion',
            'capture_build_commit': None,
            'source_url': (dataset['video'] + '&t=' + str(view['sourceTime']) + 's') if kind == 'reference' and view.get('sourceTime') and '/video/' in path.as_posix() else None,
            'context': view.get('sourceLabel') if kind == 'reference' else None,
        })
result = {
    'schema': 1,
    'purpose': 'Reference/review corpus, not training data or production assets',
    'notice': 'Null capture commit means it was not established. Hashes identify pixels, not acceptance.',
    'records': records,
    'missing_files': missing,
}
(BOARD / 'reference-assets.json').write_text(json.dumps(result, indent=2) + '\n', encoding='utf-8')
print(json.dumps({'view_families': len(dataset['rows']), 'indexed_images': len(records), 'missing_files': missing, 'mock_views': sum(bool(v.get('target')) for v in dataset['rows'])}))
if missing:
    raise SystemExit(1)
