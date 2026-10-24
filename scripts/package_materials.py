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
MATERIAL_DIRS = ('R', 'data', 'checkpoints', 'assets', 'outputs', 'scripts')
SOURCE_FILES = (
    'index.qmd', 'workshop.qmd', 'setup.qmd', 'handout.qmd', 'reference.qmd',
    '_quarto.yml', 'theme.scss', 'theme.css', 'website.scss', 'website.css',
    'WSeatPrepTBA.Rproj', '.Rprofile', 'README.md', 'WORKSHOP-PLAN.md',
    'teaching-notes.md', 'VALIDATION.md', 'renv.lock',
)
EXCLUDED = {'integration', 'review', '_site', '.library', '.git', '__pycache__'}
OBSOLETE_OUTPUTS = {'outputs/kodiermanual.docx', 'data/kodiermanual.md'}


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

# Iterate only selected source directories, never the whole workspace.
with zipfile.ZipFile(DOWNLOADS / 'WSeatPrepTBA-material.zip', 'w',
                     zipfile.ZIP_DEFLATED) as archive:
    for name in SOURCE_FILES:
        archive.write(ROOT / name, Path('WSeatPrepTBA') / name)
    for name in MATERIAL_DIRS:
        for file in sorted((ROOT / name).rglob('*')):
            relative = file.relative_to(ROOT)
            if (file.is_file() and not EXCLUDED.intersection(relative.parts)
                    and not file.name.endswith('_mod.R')
                    and relative.as_posix() not in OBSOLETE_OUTPUTS):
                archive.write(file, Path('WSeatPrepTBA') / relative)
    for pdf in sorted(DOWNLOADS.glob('*.pdf')):
        archive.write(pdf, Path('WSeatPrepTBA') / 'downloads' / pdf.name)

# Refresh script downloads so renamed scripts cannot survive an older render.
remove_generated(SITE / 'R')
shutil.copytree(ROOT / 'R', SITE / 'R', ignore=ignore_internal)
(SITE / 'downloads').mkdir(exist_ok=True)
for file in DOWNLOADS.iterdir():
    if file.is_file():
        shutil.copy2(file, SITE / 'downloads' / file.name)

# Remove superseded generated documents from the published site.
for name in OBSOLETE_OUTPUTS:
    (SITE / name).unlink(missing_ok=True)

# Clean generated remnants of earlier builds; no source files are touched.
for name in ('integration', 'review', '.library', 'exercises_files',
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
