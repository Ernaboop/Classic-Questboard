local _, ns = ...
local Database = ns.Database

-- Darkshore: Auberdine's notice writers and actual Alliance merchants.
-- Innkeeper Shaussiy has no merchant inventory, so has no vendor tag.
for _, giver in ipairs({
    {id = "ds_cerellean", name = "Cerellean Whiteclaw", npcID = 3644, location = "Auberdine docks", tags = {"questgiver", "resident"}},
    {id = "ds_thundris", name = "Thundris Windweaver", npcID = 3649, location = "Auberdine", tags = {"questgiver", "collector", "resident"}},
    {id = "ds_barithras", name = "Barithras Moonshade", npcID = 3583, location = "Auberdine", tags = {"questgiver", "resident"}},
    {id = "ds_glynda", name = "Sentinel Glynda Nal'Shea", npcID = 2930, location = "Auberdine", tags = {"questgiver", "guard"}},
    {id = "ds_shaussiy", name = "Innkeeper Shaussiy", npcID = 6737, location = "Auberdine inn", tags = {"collector", "innkeeper"}},
    {id = "ds_dalmond", name = "Dalmond", npcID = 4182, location = "Auberdine", tags = {"vendor", "collector"}},
    {id = "ds_gorbold", name = "Gorbold Steelhand", npcID = 6301, location = "Auberdine", tags = {"vendor", "collector"}},
    {id = "ds_laird", name = "Laird", npcID = 4200, location = "Auberdine inn", tags = {"vendor", "collector", "fisherman"}},
    {id = "ds_elisa", name = "Elisa Steelhand", npcID = 6300, location = "Auberdine forge", tags = {"vendor", "blacksmith", "collector"}},
}) do
    giver.zone, giver.faction = "darkshore", "Alliance"
    Database:RegisterQuestGiver(giver)
end

-- Westfall NPCs; the vendor tag identifies actual merchant windows.
for _, giver in ipairs({
    {id = "wf_gryan", name = "Gryan Stoutmantle", npcID = 234, location = "Sentinel Hill tower", faction = "Alliance", tags = {"questgiver", "guard"}},
    {id = "wf_grayson", name = "Captain Grayson", npcID = 392, location = "Westfall Lighthouse", faction = "Neutral", tags = {"questgiver", "scout"}},
    {id = "wf_saldean", name = "Farmer Saldean", npcID = 233, location = "Saldean's Farm", faction = "Alliance", tags = {"questgiver", "collector", "vendor", "farmer"}},
    {id = "wf_heather", name = "Innkeeper Heather", npcID = 8931, location = "Sentinel Hill inn", faction = "Alliance", tags = {"collector", "vendor", "innkeeper"}},
    {id = "wf_lewis", name = "Quartermaster Lewis", npcID = 491, location = "Sentinel Hill tower", faction = "Alliance", tags = {"vendor", "quartermaster"}},
    {id = "wf_macgregor", name = "William MacGregor", npcID = 1668, location = "Sentinel Hill", faction = "Alliance", tags = {"vendor"}},
    {id = "wf_profiteer", name = "Defias Profiteer", npcID = 1669, location = "upper floor of the Moonbrook inn", faction = "Neutral", tags = {"vendor"}},
}) do
    giver.zone = "westfall"
    Database:RegisterQuestGiver(giver)
end

-- Stable IDs refer to real NPCs. Objective tag requirements select providers.

Database:RegisterQuestGiver({
    id = "npc_240",
    name = "Marshal Dughan",
    npcID = 240,
    zone = "elwynn",
    location = "Goldshire",
    faction = "Alliance",
    tags = {"questgiver", "guard"},
})

Database:RegisterQuestGiver({
    id = "npc_197",
    name = "Marshal McBride",
    npcID = 197,
    zone = "elwynn",
    location = "Northshire Abbey",
    faction = "Alliance",
    tags = {"questgiver", "guard"},
})

Database:RegisterQuestGiver({
    id = "npc_823",
    name = "Deputy Willem",
    npcID = 823,
    zone = "elwynn",
    location = "Northshire Valley",
    faction = "Alliance",
    tags = {"questgiver", "guard"},
})

Database:RegisterQuestGiver({
    id = "npc_261",
    name = "Guard Thomas",
    npcID = 261,
    zone = "elwynn",
    location = "Eastvale road",
    faction = "Alliance",
    tags = {"questgiver", "guard"},
})

Database:RegisterQuestGiver({
    id = "npc_241",
    name = "Remy \"Two Times\"",
    npcID = 241,
    zone = "elwynn",
    location = "Goldshire",
    faction = "Alliance",
    tags = {"questgiver", "scout"},
})

Database:RegisterQuestGiver({
    id = "npc_295",
    name = "Innkeeper Farley",
    npcID = 295,
    zone = "elwynn",
    location = "Goldshire",
    faction = "Alliance",
    tags = {"vendor", "collector", "innkeeper"},
})

Database:RegisterQuestGiver({
    id = "npc_244",
    name = "Ma Stonefield",
    npcID = 244,
    zone = "elwynn",
    location = "Stonefield Farm",
    faction = "Alliance",
    tags = {"collector", "farmer"},
})

Database:RegisterQuestGiver({
    id = "npc_251",
    name = "Maybell Maclure",
    npcID = 251,
    zone = "elwynn",
    location = "Maclure Vineyards",
    faction = "Alliance",
    tags = {"collector", "farmer"},
})

Database:RegisterQuestGiver({
    id = "npc_514",
    name = "Smith Argus",
    npcID = 514,
    zone = "elwynn",
    location = "Goldshire",
    faction = "Alliance",
    tags = {"collector", "blacksmith", "trainer"},
})

Database:RegisterQuestGiver({
    id = "npc_66",
    name = "Tharynn Bouden",
    npcID = 66,
    zone = "elwynn",
    location = "Goldshire",
    faction = "Alliance",
    tags = {"vendor"},
})

Database:RegisterQuestGiver({
    id = "npc_1250",
    name = "Drake Lindgren",
    npcID = 1250,
    zone = "elwynn",
    location = "Eastvale Logging Camp",
    faction = "Alliance",
    tags = {"vendor"},
})

Database:RegisterQuestGiver({
    id = "npc_152",
    name = "Brother Danil",
    npcID = 152,
    zone = "elwynn",
    location = "Northshire Abbey",
    faction = "Alliance",
    tags = {"vendor"},
})

Database:RegisterQuestGiver({
    id = "npc_658",
    name = "Sten Stoutarm",
    npcID = 658,
    zone = "dun_morogh",
    location = "Coldridge Valley",
    faction = "Alliance",
    tags = {"questgiver", "guard"},
})

Database:RegisterQuestGiver({
    id = "npc_713",
    name = "Balir Frosthammer",
    npcID = 713,
    zone = "dun_morogh",
    location = "Coldridge Valley",
    faction = "Alliance",
    tags = {"questgiver", "guard"},
})

Database:RegisterQuestGiver({
    id = "npc_786",
    name = "Grelin Whitebeard",
    npcID = 786,
    zone = "dun_morogh",
    location = "Coldridge Valley",
    faction = "Alliance",
    tags = {"questgiver", "resident"},
})

Database:RegisterQuestGiver({
    id = "npc_714",
    name = "Talin Keeneye",
    npcID = 714,
    zone = "dun_morogh",
    location = "Coldridge Valley",
    faction = "Alliance",
    tags = {"questgiver", "scout"},
})

Database:RegisterQuestGiver({
    id = "npc_1252",
    name = "Senir Whitebeard",
    npcID = 1252,
    zone = "dun_morogh",
    location = "Kharanos",
    faction = "Alliance",
    tags = {"questgiver", "scout"},
})

Database:RegisterQuestGiver({
    id = "npc_1265",
    name = "Rudra Amberstill",
    npcID = 1265,
    zone = "dun_morogh",
    location = "Amberstill Ranch",
    faction = "Alliance",
    tags = {"questgiver", "guard"},
})

Database:RegisterQuestGiver({
    id = "npc_1247",
    name = "Innkeeper Belm",
    npcID = 1247,
    zone = "dun_morogh",
    location = "Kharanos",
    faction = "Alliance",
    tags = {"vendor", "collector", "innkeeper"},
})

Database:RegisterQuestGiver({
    id = "npc_1267",
    name = "Ragnar Thunderbrew",
    npcID = 1267,
    zone = "dun_morogh",
    location = "Kharanos",
    faction = "Alliance",
    tags = {"collector", "resident"},
})

Database:RegisterQuestGiver({
    id = "npc_1378",
    name = "Pilot Bellowfiz",
    npcID = 1378,
    zone = "dun_morogh",
    location = "Steelgrill's Depot",
    faction = "Alliance",
    tags = {"collector", "engineer"},
})

Database:RegisterQuestGiver({
    id = "npc_1269",
    name = "Razzle Sprysprocket",
    npcID = 1269,
    zone = "dun_morogh",
    location = "Steelgrill's Depot",
    faction = "Alliance",
    tags = {"collector", "engineer"},
})

Database:RegisterQuestGiver({
    id = "npc_829",
    name = "Adlin Pridedrift",
    npcID = 829,
    zone = "dun_morogh",
    location = "Coldridge Valley",
    faction = "Alliance",
    tags = {"vendor"},
})

Database:RegisterQuestGiver({
    id = "npc_1691",
    name = "Kreg Bilmn",
    npcID = 1691,
    zone = "dun_morogh",
    location = "Kharanos",
    faction = "Alliance",
    tags = {"vendor"},
})

Database:RegisterQuestGiver({
    id = "npc_1692",
    name = "Golorn Frostbeard",
    npcID = 1692,
    zone = "dun_morogh",
    location = "south of Kharanos",
    faction = "Alliance",
    tags = {"vendor"},
})

Database:RegisterQuestGiver({
    id = "npc_1690",
    name = "Thrawn Boltar",
    npcID = 1690,
    zone = "dun_morogh",
    location = "Kharanos",
    faction = "Alliance",
    tags = {"vendor", "blacksmith", "collector"},
})
