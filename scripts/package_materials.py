"""After `quarto render`: refresh the ZIP and the IQB-Methods payload.

Generate downloads/workshop.pdf via the Reveal.js print view before packaging.
Only participant materials are copied; review files remain in the source tree.
"""
from pathlib import Path
import shutil
import zipfile

ROOT = Path(__file__).resolve().parents[1]
SITE = ROOT / '_site'
DOWNLOADS = ROOT / 'downloads'
SCRIPTS = (
    '00_installation.R', '01_datenabruf.R', '02_daten_verstehen.R',
    '03_datenaufbereitung.R', '04_logs.R', '05_kodiermanuale.R',
    '06_kodiermanuale_studio.R',
)
EXAMPLE_FILES = sorted(path for path in (ROOT / 'Daten').iterdir()
                       if path.is_file() and path.suffix in {'.csv', '.rds', '.json'}
                       and not path.name.startswith('.') and not path.stem.endswith('_mod'))
EXCLUDED = {'integration', 'review', '_site', '.library', '.git', '__pycache__'}
OBSOLETE_OUTPUTS = {'Daten/Ergebnisse/kodiermanual.docx', 'Daten/kodiermanual.md'}


def remove_generated(path):
    """Remove only a checked directory below one of the two output roots."""
    resolved = path.resolve()
    if not resolved.is_relative_to(ROOT) or resolved == ROOT:
        raise ValueError(f'Path outside the workspace: {resolved}')
    allowed = (SITE.resolve(), (ROOT / 'integration' / 'payload').resolve())
    if not any(resolved.is_relative_to(base) and resolved != base
               for base in allowed):
        raise ValueError(f'Not a generated subtree: {resolved}')
    if path.is_symlink():
        raise ValueError(f'Refusing to remove a symlink: {path}')
    if path.exists():
        shutil.rmtree(path)


def ignore_internal(directory, names):
    return [name for name in names if name in EXCLUDED or name.startswith('workshop_mod')
            or name.endswith('_mod.R')
            or name in {'workshop_mod.qmd', 'workshop_mod.html',
                        'exercises.html', 'solutions.html'}]


if not (SITE / 'index.html').exists():
    raise SystemExit('Run quarto render first.')
DOWNLOADS.mkdir(exist_ok=True)

# The participant ZIP has only the project file, scripts and example data.
with zipfile.ZipFile(DOWNLOADS / 'WSeatPrepTBA-material.zip', 'w',
                     zipfile.ZIP_DEFLATED) as archive:
    archive.write(ROOT / 'WSeatPrepTBA.Rproj', 'WSeatPrepTBA.Rproj')
    for name in SCRIPTS:
        archive.write(ROOT / 'Syntaxen' / name, 'Syntaxen/' + name)
    for file in EXAMPLE_FILES:
        archive.write(file, file.relative_to(ROOT).as_posix())

# Refresh script downloads so renamed scripts cannot survive an older render.
remove_generated(SITE / 'Syntaxen')
(SITE / 'Syntaxen').mkdir()
for name in SCRIPTS:
    shutil.copy2(ROOT / 'Syntaxen' / name, SITE / 'Syntaxen' / name)

# Rebuild public data from a whitelist, excluding any own study data.
remove_generated(SITE / 'Daten')
(SITE / 'Daten').mkdir()
for file in EXAMPLE_FILES:
    shutil.copy2(file, SITE / 'Daten' / file.name)
for file in sorted((ROOT / 'Daten/Zwischenstaende').glob('*.rds')):
    (SITE / 'Daten/Zwischenstaende').mkdir(exist_ok=True)
    shutil.copy2(file, SITE / 'Daten/Zwischenstaende' / file.name)
codebook = ROOT / 'Daten/Ergebnisse/codebook.xlsx'
if codebook.exists():
    (SITE / 'Daten/Ergebnisse').mkdir(exist_ok=True)
    shutil.copy2(codebook, SITE / 'Daten/Ergebnisse/codebook.xlsx')
(SITE / 'downloads').mkdir(exist_ok=True)
for file in DOWNLOADS.iterdir():
    if file.is_file():
        shutil.copy2(file, SITE / 'downloads' / file.name)

# Remove superseded generated documents from the published site.
for name in OBSOLETE_OUTPUTS:
    (SITE / name).unlink(missing_ok=True)

# Clean generated remnants of earlier builds; no source files are touched.
for name in ('R', 'data', 'checkpoints', 'outputs', 'data_eigen',
             'integration', 'review', '.library', 'exercises_files',
             'solutions_files', 'workshop_mod_files', 'workshop_mod2_files'):
    remove_generated(SITE / name)
for name in ('exercises.html', 'solutions.html', 'workshop_mod.html', 'workshop_mod2.html'):
    (SITE / name).unlink(missing_ok=True)

# Replace the exact generated subtree, preserving integration source files.
payload = ROOT / 'integration' / 'payload' / 'docs' / 'R_tutorials'
payload.mkdir(parents=True, exist_ok=True)
destination = payload / 'eatPrepTBA2026_files'
remove_generated(destination)
shutil.copy2(ROOT / 'integration' / 'eatPrepTBA2026.qmd', payload)
shutil.copytree(SITE, destination, ignore=ignore_internal)
print('Participant ZIP and IQB-Methods payload refreshed.')
