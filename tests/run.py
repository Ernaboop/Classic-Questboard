"""Run with Python + lupa (Lua 5.1). No WoW installation is required."""
from pathlib import Path
from lupa.lua51 import LuaRuntime
root = Path(__file__).resolve().parents[1]
lua = LuaRuntime(unpack_returned_tuples=True)
for name in ("Tracking.lua", "Questboard.lua"):
    lua.execute("assert(loadstring(...))", (root / name).read_text(encoding="utf-8"))
lua.globals().tracking_source = (root / "Tracking.lua").read_text(encoding="utf-8")
lua.globals().board_source = (root / "Questboard.lua").read_text(encoding="utf-8")
lua.execute((root / "tests" / "tracking_spec.lua").read_text(encoding="utf-8"))
