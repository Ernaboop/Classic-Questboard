local _, ns = ...
local Database = ns.Database

-- Westfall NPCs; merchant flags identify actual friendly vendor windows.
for _, giver in ipairs({
    {id = "wf_gryan", name = "Gryan Stoutmantle", npcID = 234, location = "Sentinel Hill tower", faction = "Alliance", categories = {"kill", "hunt"}},
    {id = "wf_grayson", name = "Captain Grayson", npcID = 392, location = "Westfall Lighthouse", faction = "Neutral", categories = {"kill", "hunt"}},
    {id = "wf_saldean", name = "Farmer Saldean", npcID = 233, location = "Saldean's Farm", faction = "Alliance", categories = {"kill", "gather", "supply"}, vendor = true},
    {id = "wf_heather", name = "Innkeeper Heather", npcID = 8931, location = "Sentinel Hill inn", faction = "Alliance", categories = {"gather", "supply"}, vendor = true},
    {id = "wf_lewis", name = "Quartermaster Lewis", npcID = 491, location = "Sentinel Hill tower", faction = "Alliance", categories = {"supply"}, vendor = true},
    {id = "wf_macgregor", name = "William MacGregor", npcID = 1668, location = "Sentinel Hill", faction = "Alliance", categories = {"supply"}, vendor = true},
    {id = "wf_profiteer", name = "Defias Profiteer", npcID = 1669, location = "upper floor of the Moonbrook inn", faction = "Neutral", categories = {"supply"}, vendor = true},
}) do
    giver.zone = "westfall"
    giver.vendor = giver.vendor or false
    Database:RegisterQuestGiver(giver)
end

-- Stable IDs refer to real NPCs; categories control which notices they post.

Database:RegisterQuestGiver({
    id = "npc_240",
    name = "Marshal Dughan",
    npcID = 240,
    zone = "elwynn",
    location = "Goldshire",
    faction = "Alliance",
    categories = {"kill", "hunt"},
    vendor = false,
})

Database:RegisterQuestGiver({
    id = "npc_197",
    name = "Marshal McBride",
    npcID = 197,
    zone = "elwynn",
    location = "Northshire Abbey",
    faction = "Alliance",
    categories = {"kill", "hunt"},
    vendor = false,
})

Database:RegisterQuestGiver({
    id = "npc_823",
    name = "Deputy Willem",
    npcID = 823,
    zone = "elwynn",
    location = "Northshire Valley",
    faction = "Alliance",
    categories = {"kill", "hunt"},
    vendor = false,
})

Database:RegisterQuestGiver({
    id = "npc_261",
    name = "Guard Thomas",
    npcID = 261,
    zone = "elwynn",
    location = "Eastvale road",
    faction = "Alliance",
    categories = {"kill", "hunt"},
    vendor = false,
})

Database:RegisterQuestGiver({
    id = "npc_241",
    name = "Remy \"Two Times\"",
    npcID = 241,
    zone = "elwynn",
    location = "Goldshire",
    faction = "Alliance",
    categories = {"hunt"},
    vendor = false,
})

Database:RegisterQuestGiver({
    id = "npc_295",
    name = "Innkeeper Farley",
    npcID = 295,
    zone = "elwynn",
    location = "Goldshire",
    faction = "Alliance",
    categories = {"supply", "gather"},
    vendor = true,
})

Database:RegisterQuestGiver({
    id = "npc_244",
    name = "Ma Stonefield",
    npcID = 244,
    zone = "elwynn",
    location = "Stonefield Farm",
    faction = "Alliance",
    categories = {"gather"},
    vendor = false,
})

Database:RegisterQuestGiver({
    id = "npc_251",
    name = "Maybell Maclure",
    npcID = 251,
    zone = "elwynn",
    location = "Maclure Vineyards",
    faction = "Alliance",
    categories = {"gather"},
    vendor = false,
})

Database:RegisterQuestGiver({
    id = "npc_514",
    name = "Smith Argus",
    npcID = 514,
    zone = "elwynn",
    location = "Goldshire",
    faction = "Alliance",
    categories = {"gather"},
    vendor = false,
})

Database:RegisterQuestGiver({
    id = "npc_66",
    name = "Tharynn Bouden",
    npcID = 66,
    zone = "elwynn",
    location = "Goldshire",
    faction = "Alliance",
    categories = {"supply"},
    vendor = true,
})

Database:RegisterQuestGiver({
    id = "npc_1250",
    name = "Drake Lindgren",
    npcID = 1250,
    zone = "elwynn",
    location = "Eastvale Logging Camp",
    faction = "Alliance",
    categories = {"supply"},
    vendor = true,
})

Database:RegisterQuestGiver({
    id = "npc_152",
    name = "Brother Danil",
    npcID = 152,
    zone = "elwynn",
    location = "Northshire Abbey",
    faction = "Alliance",
    categories = {"supply"},
    vendor = true,
})

Database:RegisterQuestGiver({
    id = "npc_658",
    name = "Sten Stoutarm",
    npcID = 658,
    zone = "dun_morogh",
    location = "Coldridge Valley",
    faction = "Alliance",
    categories = {"kill", "hunt"},
    vendor = false,
})

Database:RegisterQuestGiver({
    id = "npc_713",
    name = "Balir Frosthammer",
    npcID = 713,
    zone = "dun_morogh",
    location = "Coldridge Valley",
    faction = "Alliance",
    categories = {"kill", "hunt"},
    vendor = false,
})

Database:RegisterQuestGiver({
    id = "npc_786",
    name = "Grelin Whitebeard",
    npcID = 786,
    zone = "dun_morogh",
    location = "Coldridge Valley",
    faction = "Alliance",
    categories = {"kill", "hunt"},
    vendor = false,
})

Database:RegisterQuestGiver({
    id = "npc_714",
    name = "Talin Keeneye",
    npcID = 714,
    zone = "dun_morogh",
    location = "Coldridge Valley",
    faction = "Alliance",
    categories = {"kill", "hunt"},
    vendor = false,
})

Database:RegisterQuestGiver({
    id = "npc_1252",
    name = "Senir Whitebeard",
    npcID = 1252,
    zone = "dun_morogh",
    location = "Kharanos",
    faction = "Alliance",
    categories = {"kill", "hunt"},
    vendor = false,
})

Database:RegisterQuestGiver({
    id = "npc_1265",
    name = "Rudra Amberstill",
    npcID = 1265,
    zone = "dun_morogh",
    location = "Amberstill Ranch",
    faction = "Alliance",
    categories = {"kill", "hunt"},
    vendor = false,
})

Database:RegisterQuestGiver({
    id = "npc_1247",
    name = "Innkeeper Belm",
    npcID = 1247,
    zone = "dun_morogh",
    location = "Kharanos",
    faction = "Alliance",
    categories = {"supply", "gather"},
    vendor = true,
})

Database:RegisterQuestGiver({
    id = "npc_1267",
    name = "Ragnar Thunderbrew",
    npcID = 1267,
    zone = "dun_morogh",
    location = "Kharanos",
    faction = "Alliance",
    categories = {"gather"},
    vendor = false,
})

Database:RegisterQuestGiver({
    id = "npc_1378",
    name = "Pilot Bellowfiz",
    npcID = 1378,
    zone = "dun_morogh",
    location = "Steelgrill's Depot",
    faction = "Alliance",
    categories = {"gather"},
    vendor = false,
})

Database:RegisterQuestGiver({
    id = "npc_1269",
    name = "Razzle Sprysprocket",
    npcID = 1269,
    zone = "dun_morogh",
    location = "Steelgrill's Depot",
    faction = "Alliance",
    categories = {"gather"},
    vendor = false,
})

Database:RegisterQuestGiver({
    id = "npc_829",
    name = "Adlin Pridedrift",
    npcID = 829,
    zone = "dun_morogh",
    location = "Coldridge Valley",
    faction = "Alliance",
    categories = {"supply"},
    vendor = true,
})

Database:RegisterQuestGiver({
    id = "npc_1691",
    name = "Kreg Bilmn",
    npcID = 1691,
    zone = "dun_morogh",
    location = "Kharanos",
    faction = "Alliance",
    categories = {"supply"},
    vendor = true,
})

Database:RegisterQuestGiver({
    id = "npc_1692",
    name = "Golorn Frostbeard",
    npcID = 1692,
    zone = "dun_morogh",
    location = "south of Kharanos",
    faction = "Alliance",
    categories = {"supply"},
    vendor = true,
})
