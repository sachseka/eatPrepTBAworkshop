"""Check local page links and the participant archive after packaging."""
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import unquote, urlsplit
import zipfile
import re

ROOT = Path(__file__).resolve().parents[1]
SITE = ROOT / '_site'


class Links(HTMLParser):
    def __init__(self):
        super().__init__()
        self.paths = []

    def handle_starttag(self, tag, attrs):
        for key, value in attrs:
            if key in ('href', 'src', 'poster') and value:
                self.paths.append(value)


missing = []
for page in SITE.glob('*.html'):
    links = Links()
    links.feed(page.read_text(encoding='utf-8'))
    for link in links.paths:
        url = urlsplit(link)
        if url.scheme or url.netloc or not url.path:
            continue
        target = (SITE / unquote(url.path).lstrip('/') if url.path.startswith('/')
                  else page.parent / unquote(url.path))
        if not target.exists():
            missing.append(f'{page.name}: {link}')
if missing:
    raise SystemExit('\n'.join(missing))

scripts = [
    '00_installation.R', '01_datenabruf.R', '02_daten_verstehen.R',
    '03_datenaufbereitung.R', '04_logs.R', '05_kodiermanuale.R',
    '06_kodiermanuale_studio.R',
]
required = {'WSeatPrepTBA.Rproj'}
required.update('Syntaxen/' + name for name in scripts)
required.update(path.relative_to(ROOT).as_posix() for path in (ROOT / 'Daten').iterdir()
                if path.is_file() and path.suffix in {'.csv', '.rds', '.json'}
                and not path.name.startswith('.') and not path.stem.endswith('_mod'))
for script in scripts:
    source = (ROOT / 'Syntaxen' / script).read_text(encoding='utf-8-sig')
    inputs = re.findall(r'["\'](Daten/[^/"\']+\.(?:csv|rds|json))["\']', source)
    assert set(inputs) <= required, f'Missing example files for {script}'
with zipfile.ZipFile(ROOT / 'downloads' / 'WSeatPrepTBA-material.zip') as archive:
    names = archive.namelist()
    assert len(names) == len(set(names)), 'Duplicate archive entries'
    assert set(names) == required, 'Unexpected or missing participant files'
    assert {Path(name).parts[0] for name in names} == {
        'Syntaxen', 'Daten', 'WSeatPrepTBA.Rproj'
    }, 'Expected exactly two folders and the project file at archive root'
    for name in required:
        data = archive.read(name)
        expected = (ROOT / name).read_bytes()
        # Git may convert text files to CRLF on a Windows checkout.
        if Path(name).suffix in {'.R', '.csv', '.json', '.Rproj'}:
            data = data.replace(b'\r\n', b'\n')
            expected = expected.replace(b'\r\n', b'\n')
        if data != expected:
            raise SystemExit(f'Archive content differs: {name}')
    assert archive.testzip() is None
assert not any((SITE / name).exists() for name in
               ('integration', 'review', '.library', 'workshop_mod.html', 'workshop_mod2.html',
                'exercises.html', 'solutions.html'))
payload = ROOT / 'integration/payload/docs/R_tutorials/eatPrepTBA2026_files'
assert not any((SITE / 'Syntaxen').rglob('*_mod.R'))
assert not any((payload / 'Syntaxen').rglob('*_mod.R'))
for published in (SITE, payload):
    assert not (published / 'Daten/EigeneDaten').exists()
    assert not any((published / name).exists() for name in
                   ('R', 'data', 'checkpoints', 'outputs', 'data_eigen'))
    assert (published / 'downloads/workshop.pdf').read_bytes() == (
        ROOT / 'downloads/workshop.pdf').read_bytes()
assert not any((payload / name).exists() for name in
               ('integration', 'review', '.library', 'workshop_mod.html', 'workshop_mod2.html',
                'exercises.html', 'solutions.html'))
print('All local HTML links and required archive contents verified.')
