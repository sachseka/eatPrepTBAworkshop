"""Check local page links and the participant archive after packaging."""
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import unquote, urlsplit
import zipfile

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

required = [
    'R/00_installation.R', 'R/01_datenabruf.R', 'R/03_datenaufbereitung.R', 'R/04_logs.R',
    'R/02_daten_verstehen.R', 'data/demo-pc-responses.csv',
    'R/05_kodiermanuale.R', 'R/06_kodiermanuale_studio.R', 'data/Logs.csv',
    'data/units.rds', 'downloads/workshop.pdf', 'outputs/codebook.xlsx',
    'assets/eatPrepTBA-logo.png', 'renv.lock',
]
with zipfile.ZipFile(ROOT / 'downloads' / 'WSeatPrepTBA-material.zip') as archive:
    for name in required:
        data = archive.read('WSeatPrepTBA/' + name)
        if data != (ROOT / name).read_bytes():
            raise SystemExit(f'Archive content differs: {name}')
    forbidden = ('.library', 'review', 'integration', '_site', 'workshop_mod.qmd',
                 'workshop_mod2.qmd', 'workshop_mod3.qmd', 'kodiermanual.docx', 'exercises.qmd', 'solutions.qmd', '03_exercises.R')
    assert not any(set(Path(name).parts).intersection(forbidden)
                   for name in archive.namelist())
    assert archive.testzip() is None
assert not any((SITE / name).exists() for name in
               ('integration', 'review', '.library', 'workshop_mod.html', 'workshop_mod2.html',
                'exercises.html', 'solutions.html'))
payload = ROOT / 'integration/payload/docs/R_tutorials/eatPrepTBA2026_files'
assert not any((payload / name).exists() for name in
               ('integration', 'review', '.library', 'workshop_mod.html', 'workshop_mod2.html',
                'exercises.html', 'solutions.html'))
print('All local HTML links and required archive contents verified.')
