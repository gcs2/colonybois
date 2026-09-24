"""Evidence coverage report; never a gameplay completion percentage."""
from pathlib import Path
import json

root = Path(__file__).resolve().parents[1]
data = json.loads((root / 'docs/parity/experience_coverage.json').read_text(encoding='utf-8'))
flows = data['flows']
keys = ('visual_sampled', 'readable_evidence', 'interaction_verified', 'presentation_reviewed', 'audio_reviewed')
assert len({f['id'] for f in flows}) == len(flows), 'Duplicate flow IDs'
assert len({f['key'] for f in flows}) == len(flows), 'Duplicate workflow ownership'
categories = {c['id'] for c in data['categories']}
for f in flows:
    assert f['category'] in categories
    assert not f['visual_sampled'] or f['evidence_times'] or f.get('other_visual_evidence'), f['id'] + ': missing inspected source'
    if f['readable_evidence']:
        assert f.get('readability_evidence'), f['id'] + ': missing assessed frame'
    if f['interaction_verified']:
        required = ('readable_evidence', 'before_action_result', 'costs_restrictions_verified', 'failure_or_boundary_verified', 'independent_corroboration', 'adaptation_recorded')
        assert all(f.get(k) for k in required), f['id'] + ': incomplete interaction proof'
        assert f.get('interaction_evidence'), f['id'] + ': missing interaction record'
    if f['presentation_reviewed']:
        assert f.get('motion_evidence') and (f['audio_reviewed'] or f.get('documented_silence')), f['id'] + ': missing motion/listening evidence'
    if f['audio_reviewed']:
        assert f.get('listening_evidence'), f['id'] + ': missing listener/source/notes'

def summarize(rows):
    return {'denominator': len(rows), **{k: {'count': sum(bool(f[k]) for f in rows), 'percent': round(100 * sum(bool(f[k]) for f in rows) / len(rows), 1) if rows else None} for k in keys}}

report = {'schema': 1, 'scope': data['scope'], 'closure': data['closure'], 'overall': summarize(flows), 'categories': [{**c, **summarize([f for f in flows if f['category'] == c['id']])} for c in data['categories']]}
(root / 'docs/ui-review/reference-metrics.js').write_text('const REFERENCE_METRICS = ' + json.dumps(report, indent=2) + ';\n', encoding='utf-8')
lines = ['# Reference experience coverage report', '', 'Generated from `experience_coverage.json`. These are evidence metrics, not game completion or a claim of full understanding.', '', '| Category | Workflows | Visually sampled | Readable | Interaction verified | Presentation reviewed | Audio reviewed |', '|---|---:|---:|---:|---:|---:|---:|']
for c in report['categories']:
    lines.append('| ' + c['title'] + ' | ' + str(c['denominator']) + ' | ' + ' | '.join(str(c[k]['count']) for k in keys) + ' |')
lines += ['', 'Overall: **' + str(report['overall']['visual_sampled']['count']) + '/' + str(len(flows)) + ' (' + str(report['overall']['visual_sampled']['percent']) + '%) visually sampled**. Readable, interaction and presentation coverage remain independently gated.', '', 'Full rules: [REFERENCE_COVERAGE_METRICS.md](../research/REFERENCE_COVERAGE_METRICS.md). Catalog variant/price/unlock audit and unknown denominator closure remain separate.']
(root / 'docs/parity/EXPERIENCE_REPORT.md').write_text('\n'.join(lines) + '\n', encoding='utf-8')
print(json.dumps(report['overall']))
