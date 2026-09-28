"""Run with Python + lupa (Lua 5.1). No WoW installation is required."""
from pathlib import Path
import json
import re
from lupa.lua51 import LuaRuntime
root = Path(__file__).resolve().parents[1]
lua = LuaRuntime(unpack_returned_tuples=True)
data_files = ["Data/Database.lua", "Data/Zones/ElwynnForest.lua", "Data/Zones/DunMorogh.lua", "Data/Zones/Westfall.lua", "Data/Zones/Darkshore.lua",
              "Data/QuestGivers.lua", "Data/FlavourText.lua"]
toc = (root / "Classic Questboard.toc").read_text(encoding="utf-8")
load_order = [line.strip().replace(chr(92), "/") for line in toc.splitlines() if line.strip() and not line.startswith("#")]
assert load_order == data_files + ["Tracking.lua", "Windows.lua", "DatabaseEditor.lua", "Questboard.lua", "Tooltips.lua"], "TOC load order differs from tests"
version = next(line.split(":", 1)[1].strip() for line in toc.splitlines() if line.startswith("## Version:"))
assert "Alpha V" + version in (root / "Questboard.lua").read_text(encoding="utf-8")
assert "current release is " + version in (root / "AGENTS.md").read_text(encoding="utf-8")
assert "## [" + version + "]" in (root / "CHANGELOG.md").read_text(encoding="utf-8")
changelog = (root / "CHANGELOG.md").read_text(encoding="utf-8")
recent_versions = re.findall(r"^## \[(\d+\.\d+\.\d+)\]", changelog, flags=re.MULTILINE)[:3]
in_game_versions = re.findall(r'\{version = "(\d+\.\d+\.\d+)", text = ', (root / "Questboard.lua").read_text(encoding="utf-8"))
assert len(in_game_versions) == 3 and in_game_versions == recent_versions, "In-game changelog must list the newest three releases"
for name in load_order:
    lua.execute("assert(loadstring(...))", (root / name).read_text(encoding="utf-8"))
lua.globals().tracking_source = (root / "Tracking.lua").read_text(encoding="utf-8")
lua.globals().data_sources = lua.table_from([(root / name).read_text(encoding="utf-8") for name in data_files])
lua.globals().editor_source = (root / "DatabaseEditor.lua").read_text(encoding="utf-8")
lua.globals().board_source = '''local testName, testNS = ...
if not testNS.Database then
    for _, source in ipairs(data_sources) do assert(loadstring(source))(testName, testNS) end
end
assert(loadstring(editor_source))(testName, testNS)
''' + (root / "Questboard.lua").read_text(encoding="utf-8")
lua.globals().windows_source = (root / "Windows.lua").read_text(encoding="utf-8")
lua.globals().tooltip_source = (root / "Tooltips.lua").read_text(encoding="utf-8")
from xml.etree import ElementTree
bindings = ElementTree.parse(root / "Bindings.xml").getroot()
assert bindings.find("Binding").attrib["name"] == "CLASSICQUESTBOARD_TOGGLE"
lua.globals().binding_source = bindings.find("Binding").text
lua.execute((root / "tests" / "tracking_spec.lua").read_text(encoding="utf-8"))
lua.execute((root / "tests" / "database_spec.lua").read_text(encoding="utf-8"))

# Freeze the 0.9.0 content contract apart from intentionally widened player
# eligibility bands: IDs, targets, quantities, item IDs, and locations stay put.
base_objectives = lua.execute('''local ns = {}
for _, source in ipairs(data_sources) do assert(loadstring(source))("test", ns) end
return ns.Database:GetBase().objectives''')
def plain(value):
    if not hasattr(value, "items"):
        return value
    items = dict(value.items())
    if items and all(isinstance(key, int) for key in items):
        return [plain(items[key]) for key in sorted(items)]
    return {key: plain(item) for key, item in items.items()}
legacy_objectives = json.loads((root / "tests/data_090_manifest.json").read_text(encoding="utf-8"))
for objective in legacy_objectives.values():
    if objective["category"] == "collect_sell": objective["category"] = "supply"
base_entries = plain(base_objectives)
for key, expected in legacy_objectives.items():
    actual = base_entries[key].copy()
    old = expected.copy()
    assert (actual["minPlayerLevel"] <= old["minPlayerLevel"] and
            actual["maxPlayerLevel"] >= old["maxPlayerLevel"]), f"legacy eligibility narrowed: {key}"
    for field in ("minPlayerLevel", "maxPlayerLevel"):
        actual.pop(field, None)
        old.pop(field, None)
    assert actual == old, f"0.9.0 content changed beyond eligibility bands: {key}"
assert len(base_entries) == 200, "Darkshore should add 50 objectives"
print("PASS: all 100 original objectives preserve their 0.9.0 identity and mechanics")
