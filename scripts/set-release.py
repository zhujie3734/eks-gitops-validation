"""Write a small deterministic Helm release file without third-party dependencies."""
import pathlib, re, sys
environment, registry, tag = sys.argv[1:]
if environment not in {'kind', 'eks'} or not re.fullmatch(r'[a-zA-Z0-9_][a-zA-Z0-9_.-]{0,127}', tag):
    raise SystemExit('Invalid environment or image tag')
if not re.fullmatch(r'[a-z0-9][a-z0-9./:_-]*', registry):
    raise SystemExit('Invalid registry prefix')
root = pathlib.Path(__file__).resolve().parents[1]
path = root / 'environments' / environment / 'release.yaml'
path.write_text(''.join(f'{app}:\n  image: {registry}/{app}\n  tag: "{tag}"\n' for app in ['frontend', 'backend']))
