"""Validate the single TOC release version and its player-facing history."""

from argparse import ArgumentParser
from pathlib import Path
import re


ROOT = Path(__file__).resolve().parents[1]
toc = (ROOT / "Classic Questboard.toc").read_text(encoding="utf-8")
matches = re.findall(r"^## Version: (\S+)$", toc, flags=re.MULTILINE)
assert len(matches) == 1, "TOC must contain exactly one Version field"
version = matches[0]
assert re.fullmatch(r"(?:0|[1-9]\d*)\.(?:0|[1-9]\d*)\.(?:0|[1-9]\d*)(?:-[0-9A-Za-z.-]+)?", version), "Invalid SemVer in TOC"
base_version = version.split("-", 1)[0]

changelog = (ROOT / "CHANGELOG.md").read_text(encoding="utf-8")
releases = re.findall(r"^## \[(\d+\.\d+\.\d+)\]", changelog, flags=re.MULTILINE)
history = (ROOT / "Data" / "UpdateHistory.lua").read_text(encoding="utf-8")
in_game_releases = re.findall(r'^    \{version = "(\d+\.\d+\.\d+)", text = ', history, flags=re.MULTILINE)
assert releases and releases[0] == base_version, "Newest changelog entry must match TOC"
assert in_game_releases == releases, "In-game history must match every changelog release"

parser = ArgumentParser()
parser.add_argument("--tag", help="Git tag being published, e.g. v0.13.2-alpha")
args = parser.parse_args()
if args.tag:
    assert args.tag == "v" + version, f"Release tag {args.tag!r} does not match TOC v{version}"

print(f"Release version OK: {version} (tag v{version})")
