"""Keep displayed workshop code identical to the downloadable R scripts.

Run before Quarto (configured in _quarto.yml), or use --check in validation.
QMD comments identify each script and block; snippets.json locates the code
with unique text anchors. The participant scripts need no technical markers.
"""
from pathlib import Path
import json
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
SNIPPET = re.compile(
    r'<!-- r-source: (Syntaxen/[^#\s]+\.R)#([\w-]+) -->.*?<!-- /r-source -->',
    re.DOTALL,
)
MANIFEST = json.loads((ROOT / 'scripts/snippets.json').read_text(encoding='utf-8'))


def locate(lines, anchor, description):
    matches = [i for i in range(len(lines) - len(anchor) + 1)
               if lines[i:i + len(anchor)] == anchor]
    if not anchor or len(matches) != 1:
        raise ValueError(f'{description}: expected one anchor match, found {len(matches)}; '
                         'update scripts/snippets.json to match the R script')
    return matches[0]


def read_block(relative, label):
    try:
        anchors = MANIFEST[relative][label]
    except KeyError:
        raise ValueError(f'Missing snippet definition: {relative}#{label}') from None
    lines = (ROOT / relative).read_text(encoding='utf-8-sig').splitlines()
    start = locate(lines, anchors['start'], f'{relative}#{label} start')
    end = locate(lines, anchors['end'], f'{relative}#{label} end') + len(anchors['end'])
    if end <= start:
        raise ValueError(f'Invalid snippet range: {relative}#{label}')
    return '\n'.join(lines[start:end]).strip()


def replace(match):
    relative, label = match.group(1, 2)
    code = read_block(relative, label)
    return (f'<!-- r-source: {relative}#{label} -->\n'
            '```{r}\n#| eval: false\n' + code + '\n```\n<!-- /r-source -->')


def main():
    # Validate unused preview blocks too, so stale anchors fail before rendering.
    for relative, blocks in MANIFEST.items():
        for label in blocks:
            read_block(relative, label)
    changed = []
    count = 0
    for name in ('workshop.qmd', 'handout.qmd', 'setup.qmd'):
        path = ROOT / name
        source = path.read_text(encoding='utf-8-sig')
        result, number = SNIPPET.subn(replace, source)
        count += number
        if result != source:
            changed.append(path.name)
            if '--check' not in sys.argv:
                path.write_text(result, encoding='utf-8', newline='\n')
    if '--check' in sys.argv and changed:
        raise SystemExit('Outdated snippets: ' + ', '.join(changed))
    print(f'{count} R snippets synchronized; {len(changed)} documents changed.')


if __name__ == '__main__':
    main()
