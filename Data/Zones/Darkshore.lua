local _, ns = ...

-- Forever Darkshore outdoor content. The player bands are addon balance choices,
-- deliberately wider than the creature-level labels. Keep entries in zone order.
local objectives = {}
local function Add(id, name, category, level, first, last, low, high, location, extra)
    local entry = {id = "ds_" .. id, name = name, category = category, level = level,
        minPlayerLevel = first, maxPlayerLevel = last, minAmount = low,
        maxAmount = high, location = location,
        requiredNPCTags = {category == "supply" and "vendor" or category == "gather" and "collector" or "questgiver"}}
    for key, value in pairs(extra) do entry[key] = value end
    objectives[#objectives + 1] = entry
end

local function Kill(id, name, level, first, last, low, high, location)
    Add(id, name, "kill", level, first, last, low, high, location, {targets = {name}})
end
local function Supply(id, name, target, level, first, last, low, high, location)
    Add(id, name, "supply", level, first, last, low, high, location,
        {targets = {target}, lootMode = "any_vendor_item", item = target .. " saleable loot"})
end
local function Hunt(id, name, npcID, level, first, last, location)
    Add(id, name, "hunt", level, first, last, 1, 1, location,
        {classification = "rare", npcID = npcID, targets = {name}})
end
local function Gather(id, name, profession, skill, first, last, low, high, location, itemID, targets)
    local extra = {profession = profession, itemID = itemID, trackingKind = "gather"}
    if targets then extra.targets = targets end
    Add(id, name, "gather", skill, first, last, low, high, location, extra)
end

-- Kill (20): coast and Auberdine outskirts through the northern ruins.
Kill("pygmy_tide_crawler", "Pygmy Tide Crawler", "9-10", 10, 14, 7, 11, "the Long Wash")
Kill("young_reef_crawler", "Young Reef Crawler", "10-11", 10, 15, 7, 10, "the Long Wash")
Kill("greymist_raider", "Greymist Raider", "11-12", 10, 15, 6, 9, "the southern coast")
Kill("moonstalker_runt", "Moonstalker Runt", "10-12", 10, 15, 6, 9, "Auberdine's northern road")
Kill("foreststrider_fledgling", "Foreststrider Fledgling", "11-13", 10, 16, 6, 9, "woods north of Auberdine")
Kill("blackwood_pathfinder", "Blackwood Pathfinder", "12-13", 11, 17, 5, 8, "Blackwood camps")
Kill("greymist_coastrunner", "Greymist Coastrunner", "12-13", 11, 17, 5, 8, "the Long Wash")
Kill("moonkin", "Moonkin", "12-13", 11, 17, 5, 8, "caves east of Auberdine")
Kill("dethryll_satyr", "Deth'ryll Satyr", "12-13", 11, 17, 5, 8, "Bashal'Aran")
Kill("cursed_highborne", "Cursed Highborne", "10-11", 10, 15, 6, 9, "Ameth'Aran")
Kill("greymist_seer", "Greymist Seer", "13-14", 12, 18, 5, 8, "the coast north of Auberdine")
Kill("rabid_thistle_bear", "Rabid Thistle Bear", "13-14", 12, 18, 5, 8, "the Cliffspring road")
Kill("moonstalker", "Moonstalker", "14-15", 13, 19, 5, 8, "the northern woods")
Kill("foreststrider", "Foreststrider", "14-16", 13, 19, 5, 8, "the northern woods")
Kill("greymist_netter", "Greymist Netter", "14-15", 13, 19, 4, 7, "Mist's Edge")
Kill("blackwood_warrior", "Blackwood Warrior", "16-17", 15, 21, 4, 7, "the northern Blackwood camps")
Kill("dark_strand_fanatic", "Dark Strand Fanatic", "16-17", 15, 21, 4, 7, "the Tower of Althalaxx")
Kill("greymist_oracle", "Greymist Oracle", "18-19", 17, 22, 3, 6, "Mist's Edge")
Kill("greymist_tidehunter", "Greymist Tidehunter", "19-20", 18, 22, 3, 5, "Mist's Edge")
Kill("blackwood_ursa", "Blackwood Ursa", "18-19", 17, 22, 3, 5, "the northern Blackwood camps")

-- Supply (11): collect ordinary vendor-value drops, then sell to the assigned merchant.
Supply("pygmy_crawler_spoils", "Pygmy Crawler Spoils", "Pygmy Tide Crawler", "9-10", 10, 15, 4, 7, "the Long Wash")
Supply("greymist_raider_spoils", "Greymist Raider Spoils", "Greymist Raider", "11-12", 10, 16, 4, 6, "the southern coast")
Supply("pathfinder_spoils", "Blackwood Pathfinder Spoils", "Blackwood Pathfinder", "12-13", 11, 17, 3, 6, "Blackwood camps")
Supply("satyr_spoils", "Deth'ryll Satyr Spoils", "Deth'ryll Satyr", "12-13", 11, 17, 3, 6, "Bashal'Aran")
Supply("bear_spoils", "Rabid Thistle Bear Spoils", "Rabid Thistle Bear", "13-14", 12, 18, 3, 6, "the Cliffspring road")
Supply("netter_spoils", "Greymist Netter Spoils", "Greymist Netter", "14-15", 13, 19, 3, 5, "Mist's Edge")
Supply("highborne_spoils", "Cursed Highborne Spoils", "Cursed Highborne", "10-11", 10, 16, 4, 6, "Ameth'Aran")
Supply("warrior_spoils", "Blackwood Warrior Spoils", "Blackwood Warrior", "16-17", 15, 21, 2, 5, "the northern Blackwood camps")
Supply("fanatic_spoils", "Dark Strand Fanatic Spoils", "Dark Strand Fanatic", "16-17", 15, 21, 2, 5, "the Tower of Althalaxx")
Supply("oracle_spoils", "Greymist Oracle Spoils", "Greymist Oracle", "18-19", 17, 22, 2, 4, "Mist's Edge")
Supply("ursa_spoils", "Blackwood Ursa Spoils", "Blackwood Ursa", "18-19", 17, 22, 2, 4, "the northern Blackwood camps")

-- Hunt (7): every named rare needs one kill and unlocks two levels early.
Hunt("shadowclaw", "Shadowclaw", 2175, "13", 11, 18, "the northern woods")
Hunt("licillin", "Licillin", 2191, "14", 12, 19, "Bashal'Aran")
Hunt("carnivous", "Carnivous the Breaker", 2186, "16", 14, 21, "the southern coast")
Hunt("flagglemurk", "Flagglemurk the Cruel", 7015, "16", 14, 21, "the Darkshore coast")
Hunt("lady_moongazer", "Lady Moongazer", 2184, "17", 15, 22, "Ameth'Aran")
Hunt("strider_clutchmother", "Strider Clutchmother", 2172, "20", 18, 22, "the northern woods")
Hunt("lady_vespira", "Lady Vespira", 7016, "22", 20, 22, "Darkshore's northern coast")

-- Gather (12): separate profession pools, gated by known professions as before.
Gather("mageroyal", "Mageroyal", "herbalism", "Herbalism 50", 10, 17, 4, 7, "roadsides and clearings", 785)
Gather("briarthorn", "Briarthorn", "herbalism", "Herbalism 70", 11, 19, 3, 6, "trees and hedgerows", 2450)
Gather("bruiseweed", "Bruiseweed", "herbalism", "Herbalism 100", 14, 22, 3, 5, "ruins and shaded ground", 2453)
Gather("stranglekelp", "Stranglekelp", "herbalism", "Herbalism 85", 14, 22, 2, 4, "the shallow coast", 3820)
Gather("copper_ore", "Copper Ore", "mining", "Mining 1", 10, 18, 5, 8, "rocky hills", 2770)
Gather("tin_ore", "Tin Ore", "mining", "Mining 65", 13, 22, 4, 7, "northern rocky hills", 2771)
Gather("coarse_stone", "Coarse Stone", "mining", "Mining 65", 13, 22, 4, 7, "Tin Veins in rocky hills", 2836)
Gather("bear_leather", "Light Leather from Rabid Thistle Bears", "skinning", "Skinning 1", 12, 18, 4, 7, "the Cliffspring road", 2318, {"Rabid Thistle Bear"})
Gather("moonstalker_leather", "Light Leather from Moonstalkers", "skinning", "Skinning 1", 13, 19, 4, 7, "the northern woods", 2318, {"Moonstalker"})
Gather("strider_leather", "Light Leather from Giant Foreststriders", "skinning", "Skinning 1", 17, 22, 3, 5, "Mathystra's northern woods", 2318, {"Giant Foreststrider"})
Gather("rainbow_albacore", "Raw Rainbow Fin Albacore", "fishing", "Fishing 50", 10, 19, 4, 7, "Darkshore waters", 6361)
Gather("oily_blackmouth", "Oily Blackmouth", "fishing", "Fishing 50", 14, 22, 2, 4, "Darkshore coastal waters", 6358)

-- Mining work orders use the same staged tracker as the other zones.
Add("copper_bar_workorder", "Copper Bar Work Order", "gather", "Mining 1", 10, 18, 4, 7, "rocky hills",
    {profession = "mining", target = "Copper Bar", trackingKind = "mining_workorder", oreItemID = 2770, oreName = "Copper Ore", itemID = 2840, smeltSpellID = 2657})
Add("tin_bar_workorder", "Tin Bar Work Order", "gather", "Mining 65", 13, 22, 3, 6, "northern rocky hills",
    {profession = "mining", target = "Tin Bar", minProfessionSkill = 65, trackingKind = "mining_workorder", oreItemID = 2771, oreName = "Tin Ore", itemID = 3576, smeltSpellID = 3304})
Add("copper_bar_blacksmith", "Copper Bars for Auberdine", "gather", "Mining 1", 12, 22, 3, 5, "rocky hills",
    {profession = "mining", target = "Copper Bar", trackingKind = "mining_workorder", oreItemID = 2770, oreName = "Copper Ore", itemID = 2840, smeltSpellID = 2657,
        requiredNPCTags = {"blacksmith", "vendor"}, handoff = "sale"})

ns.Database:RegisterZone({
    id = "darkshore", name = "Darkshore", minLevel = 10, maxLevel = 22, order = 4,
    mapIDs = {62, 1439}, objectives = objectives,
})
