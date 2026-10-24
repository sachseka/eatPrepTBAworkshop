"""Keep displayed workshop code identical to the downloadable R scripts.

Run before Quarto (configured in _quarto.yml), or use --check in validation.
The HTML comments in the QMD files identify a script and its named block.
"""
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
SNIPPET = re.compile(
    r'<!-- r-source: (R/[^#\s]+\.R)#([\w-]+) -->.*?<!-- /r-source -->',
    re.DOTALL,
)


def replace(match):
    relative, label = match.group(1, 2)
    script = (ROOT / relative).read_text(encoding='utf-8-sig')
    pattern = rf'^# ---- {re.escape(label)} ----\n(.*?)^# ---- /{re.escape(label)} ----'
    block = re.search(pattern, script, re.MULTILINE | re.DOTALL)
    if not block:
        raise ValueError(f'Missing block {label} in {relative}')
    code = block.group(1).strip()
    return (f'<!-- r-source: {relative}#{label} -->\n'
            '```{r}\n#| eval: false\n' + code + '\n```\n<!-- /r-source -->')


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
