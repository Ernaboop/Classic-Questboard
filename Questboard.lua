local addonName, ns = ...
local Tracking = ns.Tracking
local Windows = ns.Windows
local board, cards, db, minimapButton, questBrowser, debugModeButton
local Refresh
local ToggleBoard
local CreateMinimapButton
local RefreshQuestBrowser, SetDebugMode
local CreateBoard
local debugMode = false
local forcedLeftCategory
local QuestGenerationLevel

-- Amount ranges are deliberately curated per objective. Mob levels and zone
-- data use the WoW Forever zone tables; counts are balance choices.
local database = {
    categories = {
        {
            id = "kill", name = "Kill", source = "A local guard",
            objectives = {
                {id = "kobold_vermin", name = "Kobold Vermin", level = "1-2", minPlayerLevel = 1, maxPlayerLevel = 3, minAmount = 8, maxAmount = 12, location = "Northshire Valley"},
                {id = "young_wolf", name = "Young Wolf", level = "1", minPlayerLevel = 1, maxPlayerLevel = 3, minAmount = 8, maxAmount = 12, location = "Northshire and the western woods"},
                {id = "timber_wolf", name = "Timber Wolf", level = "2", minPlayerLevel = 1, maxPlayerLevel = 3, minAmount = 7, maxAmount = 10, location = "Northshire and the western woods"},
                {id = "defias_thug", name = "Defias Thug", level = "3-4", minPlayerLevel = 2, maxPlayerLevel = 4, minAmount = 6, maxAmount = 9, location = "the vineyards north of Goldshire"},
                {id = "kobold_laborer", name = "Kobold Laborer", level = "3-4", minPlayerLevel = 2, maxPlayerLevel = 4, minAmount = 6, maxAmount = 9, location = "the kobold camps north of Goldshire"},
                {id = "forest_spider", name = "Forest Spider", level = "5-6", minPlayerLevel = 4, maxPlayerLevel = 6, minAmount = 6, maxAmount = 9, location = "the woods around Goldshire"},
                {id = "kobold_tunneler", name = "Kobold Tunneler", level = "5-6", minPlayerLevel = 4, maxPlayerLevel = 7, minAmount = 8, maxAmount = 12, location = "Fargodeep Mine"},
                {id = "kobold_miner", name = "Kobold Miner", level = "6-7", minPlayerLevel = 5, maxPlayerLevel = 7, minAmount = 7, maxAmount = 10, location = "Fargodeep Mine"},
                {id = "stonetusk_boar", name = "Stonetusk Boar", level = "5-6", minPlayerLevel = 4, maxPlayerLevel = 7, minAmount = 6, maxAmount = 9, location = "Stonefield and Maclure farms"},
                {id = "defias_cutpurse", name = "Defias Cutpurse", level = "5-6", minPlayerLevel = 4, maxPlayerLevel = 7, minAmount = 6, maxAmount = 9, location = "the roads east of Goldshire"},
                {id = "murloc_streamrunner", name = "Murloc Streamrunner", level = "6-7", minPlayerLevel = 5, maxPlayerLevel = 7, minAmount = 7, maxAmount = 11, location = "Crystal Lake"},
                {id = "gray_forest_wolf", name = "Gray Forest Wolf", level = "7-8", minPlayerLevel = 6, maxPlayerLevel = 9, minAmount = 5, maxAmount = 8, location = "the eastern woods"},
                {id = "riverpaw_runt", name = "Riverpaw Runt", level = "8-9", minPlayerLevel = 7, maxPlayerLevel = 10, minAmount = 5, maxAmount = 8, location = "the Hogger camp"},
                {id = "young_forest_bear", name = "Young Forest Bear", level = "8-9", minPlayerLevel = 7, maxPlayerLevel = 10, minAmount = 5, maxAmount = 8, location = "the eastern woods"},
                {id = "murloc_lurker", name = "Murloc Lurker", level = "9-10", minPlayerLevel = 7, maxPlayerLevel = 10, minAmount = 5, maxAmount = 8, location = "the eastern shore of Crystal Lake"},
                {id = "murloc_forager", name = "Murloc Forager", level = "9-10", minPlayerLevel = 7, maxPlayerLevel = 10, minAmount = 5, maxAmount = 8, location = "Crystal Lake"},
                {id = "prowler", name = "Prowler", level = "9-10", minPlayerLevel = 7, maxPlayerLevel = 10, minAmount = 4, maxAmount = 7, location = "the eastern woods"},
                {id = "riverpaw_outrunner", name = "Riverpaw Outrunner", level = "9-10", minPlayerLevel = 7, maxPlayerLevel = 10, minAmount = 5, maxAmount = 8, location = "south of Eastvale"},
                {id = "defias_bandit", name = "Defias Bandit", level = "8-9", minPlayerLevel = 7, maxPlayerLevel = 10, minAmount = 5, maxAmount = 8, location = "Brackwell Pumpkin Patch"},
                {id = "defias_rogue_wizard", name = "Defias Rogue Wizard", level = "9-10", minPlayerLevel = 7, maxPlayerLevel = 10, minAmount = 4, maxAmount = 7, location = "Jasperlode Mine"},
            },
        },
        {
            id = "collect_sell", name = "Collect & Sell", source = "A local trader",
            objectives = {
                {id = "northshire_kobold_loot", name = "Kobold Camp Loot", target = "Kobold Vermin and Laborers", level = "1-4", minPlayerLevel = 1, maxPlayerLevel = 3, minAmount = 3, maxAmount = 5, location = "Northshire Valley"},
                {id = "young_wolf_meat", name = "Meat from the Western Woods", target = "Young Wolves and Timber Wolves", item = "Tough Wolf Meat", level = "1-2", minPlayerLevel = 1, maxPlayerLevel = 3, minAmount = 3, maxAmount = 5, location = "Northshire and the western woods"},
                {id = "defias_thug_loot", name = "Thieves' Pockets", target = "Defias Thugs", level = "3-4", minPlayerLevel = 2, maxPlayerLevel = 4, minAmount = 3, maxAmount = 5, location = "the vineyards north of Goldshire"},
                {id = "fargodeep_kobold_loot", name = "Fargodeep Mine Spoils", target = "Kobold Tunnelers and Miners", level = "5-7", minPlayerLevel = 4, maxPlayerLevel = 7, minAmount = 4, maxAmount = 6, location = "Fargodeep Mine"},
                {id = "stonetusk_boar_meat", name = "Boar Meat for the Market", target = "Stonetusk Boars", item = "Chunk of Boar Meat", level = "5-6", minPlayerLevel = 4, maxPlayerLevel = 7, minAmount = 4, maxAmount = 7, location = "Stonefield and Maclure farms"},
                {id = "crystal_lake_murloc_loot", name = "Crystal Lake Salvage", target = "Murlocs and Streamrunners", level = "6-7", minPlayerLevel = 5, maxPlayerLevel = 7, minAmount = 3, maxAmount = 5, location = "Crystal Lake"},
                {id = "eastern_wolf_loot", name = "Eastern Wolf Pelts", target = "Gray Forest Wolves and Young Forest Bears", level = "7-9", minPlayerLevel = 6, maxPlayerLevel = 10, minAmount = 3, maxAmount = 5, location = "the eastern woods"},
                {id = "riverpaw_runt_loot", name = "Hogger Camp Spoils", target = "Riverpaw Runts", level = "8-9", minPlayerLevel = 7, maxPlayerLevel = 10, minAmount = 3, maxAmount = 5, location = "the Hogger camp"},
                {id = "murloc_forager_loot", name = "Murloc Forager Supplies", target = "Murloc Foragers and Lurkers", level = "9-10", minPlayerLevel = 7, maxPlayerLevel = 10, minAmount = 3, maxAmount = 5, location = "Crystal Lake"},
                {id = "brackwell_defias_loot", name = "Brackwell Salvage", target = "Defias Bandits", level = "8-9", minPlayerLevel = 7, maxPlayerLevel = 10, minAmount = 3, maxAmount = 5, location = "Brackwell Pumpkin Patch"},
                {id = "riverpaw_outrunner_loot", name = "Eastern Road Spoils", target = "Riverpaw Outrunners", level = "9-10", minPlayerLevel = 7, maxPlayerLevel = 10, minAmount = 3, maxAmount = 5, location = "south of Eastvale"},
            },
        },
        {
            -- Hunt unlocks two levels below the target's minimum listed level.
            id = "hunt", name = "Hunt", source = "A local scout",
            branches = {
                {
                    id = "rare", name = "Rare target",
                    objectives = {
                        {id = "narg", name = "Narg the Taskmaster", level = "10", minPlayerLevel = 8, maxPlayerLevel = 10, minAmount = 1, maxAmount = 1, location = "outside Fargodeep Mine", rarity = "Rare"},
                        {id = "morgaine", name = "Morgaine the Sly", level = "10", minPlayerLevel = 8, maxPlayerLevel = 10, minAmount = 1, maxAmount = 1, location = "near the river to Westfall", rarity = "Rare"},
                        {id = "fedfennel", name = "Fedfennel", level = "12", minPlayerLevel = 10, maxPlayerLevel = 12, minAmount = 1, maxAmount = 1, location = "Stone Cairn Lake", rarity = "Rare"},
                        {id = "gruff_swiftbite", name = "Gruff Swiftbite", level = "12", minPlayerLevel = 10, maxPlayerLevel = 12, minAmount = 1, maxAmount = 1, location = "the Hogger camp", rarity = "Rare"},
                    },
                },
                {
                    id = "elite", name = "Elite targets",
                    objectives = {
                        {id = "mine_spider", name = "Mine Spider", level = "7-9", minPlayerLevel = 5, maxPlayerLevel = 9, minAmount = 3, maxAmount = 5, location = "Jasperlode Mine", rarity = "Elite"},
                        {id = "mother_fang", name = "Mother Fang", level = "7-10", minPlayerLevel = 5, maxPlayerLevel = 10, minAmount = 1, maxAmount = 1, location = "Jasperlode Mine", rarity = "Elite"},
                        {id = "hogger", name = "Hogger", level = "11", minPlayerLevel = 9, maxPlayerLevel = 12, minAmount = 1, maxAmount = 1, location = "the Hogger camp", rarity = "Elite"},
                    },
                },
            },
        },
    },
    gather = {
        {
            id = "herbalism", name = "Herbalism",
            skillLine = 182,
            objectives = {
                {id = "peacebloom", name = "Peacebloom", level = "Herbalism 1", minPlayerLevel = 1, maxPlayerLevel = 5, minAmount = 4, maxAmount = 8, location = "throughout Elwynn Forest"},
                {id = "silverleaf", name = "Silverleaf", level = "Herbalism 1", minPlayerLevel = 1, maxPlayerLevel = 7, minAmount = 4, maxAmount = 8, location = "near trees and shaded areas"},
                {id = "earthroot", name = "Earthroot", level = "Herbalism 15", minPlayerLevel = 3, maxPlayerLevel = 9, minAmount = 3, maxAmount = 5, location = "hillsides and rocky ground"},
                {id = "mageroyal", name = "Mageroyal", level = "Herbalism 50", minPlayerLevel = 6, maxPlayerLevel = 12, minAmount = 2, maxAmount = 4, location = "the more open eastern fields"},
            },
        },
        {
            id = "mining", name = "Mining",
            skillLine = 186,
            objectives = {
                {id = "copper_ore", name = "Copper Ore", level = "Mining 1", minPlayerLevel = 1, maxPlayerLevel = 12, minAmount = 5, maxAmount = 9, location = "Copper Veins throughout Elwynn Forest"},
                {id = "rough_stone", name = "Rough Stone", level = "Mining 1", minPlayerLevel = 1, maxPlayerLevel = 12, minAmount = 5, maxAmount = 9, location = "from Copper Veins throughout Elwynn Forest"},
                {id = "copper_vein_prospecting", name = "Copper Vein Prospecting", level = "Mining 1", minPlayerLevel = 1, maxPlayerLevel = 12, minAmount = 3, maxAmount = 5, location = "Copper Veins throughout Elwynn Forest", target = "Copper Veins"},
            },
        },
        {
            id = "skinning", name = "Skinning",
            skillLine = 393,
            objectives = {
                {id = "ruined_leather_scraps", name = "Ruined Leather Scraps", level = "Skinning 1", minPlayerLevel = 1, maxPlayerLevel = 5, minAmount = 4, maxAmount = 8, location = "skinnable low-level creatures in western Elwynn"},
                {id = "stonefield_light_leather", name = "Light Leather from Boars", level = "Skinning 1", minPlayerLevel = 4, maxPlayerLevel = 8, minAmount = 3, maxAmount = 5, location = "Stonetusk Boars at Stonefield and Maclure farms"},
                {id = "eastern_light_leather", name = "Light Leather from Forest Beasts", level = "Skinning 1", minPlayerLevel = 7, maxPlayerLevel = 10, minAmount = 3, maxAmount = 5, location = "wolves, bears, and prowlers in eastern Elwynn"},
            },
        },
        {
            id = "fishing", name = "Fishing",
            skillLine = 356,
            objectives = {
                {id = "brilliant_smallfish", name = "Raw Brilliant Smallfish", level = "Fishing 1", minPlayerLevel = 1, maxPlayerLevel = 5, minAmount = 5, maxAmount = 9, location = "lakes and rivers"},
                {id = "longjaw_mud_snapper", name = "Raw Longjaw Mud Snapper", level = "Fishing 50", minPlayerLevel = 4, maxPlayerLevel = 8, minAmount = 4, maxAmount = 8, location = "lakes and rivers"},
                {id = "bristle_whisker_catfish", name = "Raw Bristle Whisker Catfish", level = "Fishing 100", minPlayerLevel = 7, maxPlayerLevel = 12, minAmount = 2, maxAmount = 4, location = "Wildbend River"},
            },
        },
    },
}

-- Dun Morogh uses the same curated layers as Elwynn. See ZONE_DATA.md for
-- Forever source IDs and verification notes. Counts and eligibility bands are
-- addon balancing choices, not Blizzard quest requirements.
local dunMoroghData = {
    categories = {
        {
            id = "kill", name = "Kill", source = "A Dun Morogh mountaineer",
            objectives = {
                {id = "dm_ragged_young_wolf", name = "Ragged Young Wolf", level = "1", minPlayerLevel = 1, maxPlayerLevel = 3, minAmount = 8, maxAmount = 12, location = "Coldridge Valley"},
                {id = "dm_rockjaw_trogg", name = "Rockjaw Trogg", level = "1-2", minPlayerLevel = 1, maxPlayerLevel = 3, minAmount = 8, maxAmount = 12, location = "Coldridge Valley"},
                {id = "dm_burly_rockjaw_trogg", name = "Burly Rockjaw Trogg", level = "2", minPlayerLevel = 1, maxPlayerLevel = 3, minAmount = 7, maxAmount = 10, location = "Coldridge Valley"},
                {id = "dm_small_crag_boar", name = "Small Crag Boar", level = "3", minPlayerLevel = 2, maxPlayerLevel = 4, minAmount = 6, maxAmount = 9, location = "Coldridge Valley"},
                {id = "dm_frostmane_troll_whelp", name = "Frostmane Troll Whelp", level = "3-4", minPlayerLevel = 2, maxPlayerLevel = 4, minAmount = 6, maxAmount = 9, location = "the troll camps in Coldridge Valley"},
                {id = "dm_frostmane_novice", name = "Frostmane Novice", level = "3-4", minPlayerLevel = 2, maxPlayerLevel = 4, minAmount = 6, maxAmount = 9, location = "the troll cave in Coldridge Valley"},
                {id = "dm_rockjaw_raider", name = "Rockjaw Raider", level = "3-4", minPlayerLevel = 2, maxPlayerLevel = 5, minAmount = 6, maxAmount = 9, location = "Coldridge Pass"},
                {id = "dm_crag_boar", name = "Crag Boar", level = "5-6", minPlayerLevel = 4, maxPlayerLevel = 7, minAmount = 6, maxAmount = 9, location = "the slopes around Kharanos"},
                {id = "dm_large_crag_boar", name = "Large Crag Boar", level = "6-7", minPlayerLevel = 5, maxPlayerLevel = 8, minAmount = 6, maxAmount = 9, location = "the hills around Kharanos"},
                {id = "dm_young_black_bear", name = "Young Black Bear", level = "5-6", minPlayerLevel = 4, maxPlayerLevel = 7, minAmount = 6, maxAmount = 9, location = "the woods around Kharanos"},
                {id = "dm_young_wendigo", name = "Young Wendigo", level = "5-6", minPlayerLevel = 4, maxPlayerLevel = 7, minAmount = 6, maxAmount = 9, location = "the entrance to the Grizzled Den"},
                {id = "dm_wendigo", name = "Wendigo", level = "6-7", minPlayerLevel = 5, maxPlayerLevel = 8, minAmount = 5, maxAmount = 8, location = "the Grizzled Den"},
                {id = "dm_elder_crag_boar", name = "Elder Crag Boar", level = "7-8", minPlayerLevel = 6, maxPlayerLevel = 9, minAmount = 5, maxAmount = 8, location = "the eastern hills"},
                {id = "dm_ice_claw_bear", name = "Ice Claw Bear", level = "7-8", minPlayerLevel = 6, maxPlayerLevel = 10, minAmount = 5, maxAmount = 8, location = "the snowy wilderness"},
                {id = "dm_winter_wolf", name = "Winter Wolf", level = "7-8", minPlayerLevel = 6, maxPlayerLevel = 10, minAmount = 5, maxAmount = 8, location = "the shores of Iceflow Lake"},
                {id = "dm_rockjaw_skullthumper", name = "Rockjaw Skullthumper", level = "8-9", minPlayerLevel = 7, maxPlayerLevel = 10, minAmount = 5, maxAmount = 8, location = "Gol'Bolar Quarry"},
                {id = "dm_rockjaw_ambusher", name = "Rockjaw Ambusher", level = "9-10", minPlayerLevel = 8, maxPlayerLevel = 10, minAmount = 4, maxAmount = 7, location = "Gol'Bolar Quarry"},
                {id = "dm_rockjaw_bonesnapper", name = "Rockjaw Bonesnapper", level = "9-10", minPlayerLevel = 8, maxPlayerLevel = 10, minAmount = 4, maxAmount = 7, location = "Gol'Bolar Quarry Mine"},
                {id = "dm_frostmane_snowstrider", name = "Frostmane Snowstrider", level = "8-9", minPlayerLevel = 7, maxPlayerLevel = 10, minAmount = 5, maxAmount = 8, location = "Frostmane Hold"},
                {id = "dm_leper_gnome", name = "Leper Gnome", level = "8-10", minPlayerLevel = 7, maxPlayerLevel = 10, minAmount = 5, maxAmount = 8, location = "the surface ruins outside Gnomeregan"},
            },
        },
        {
            id = "collect_sell", name = "Collect & Sell", source = "A Kharanos trader",
            objectives = {
                {id = "dm_coldridge_trogg_spoils", name = "Coldridge Trogg Spoils", level = "1-2", minPlayerLevel = 1, maxPlayerLevel = 3, minAmount = 3, maxAmount = 5, location = "Coldridge Valley", target = "Rockjaw Trogg or Burly Rockjaw Trogg", targets = {"Rockjaw Trogg", "Burly Rockjaw Trogg"}},
                {id = "dm_troll_camp_spoils", name = "Troll Camp Salvage", level = "3-4", minPlayerLevel = 2, maxPlayerLevel = 4, minAmount = 3, maxAmount = 5, location = "the troll camps in Coldridge Valley", target = "Frostmane Troll Whelp", targets = {"Frostmane Troll Whelp"}},
                {id = "dm_novice_spoils", name = "Cold Cave Supplies", level = "3-4", minPlayerLevel = 2, maxPlayerLevel = 4, minAmount = 3, maxAmount = 5, location = "the troll cave in Coldridge Valley", target = "Frostmane Novice", targets = {"Frostmane Novice"}},
                {id = "dm_pass_spoils", name = "Coldridge Pass Salvage", level = "3-4", minPlayerLevel = 2, maxPlayerLevel = 5, minAmount = 3, maxAmount = 5, location = "Coldridge Pass", target = "Rockjaw Raider", targets = {"Rockjaw Raider"}},
                {id = "dm_boar_spoils", name = "Kharanos Boar Spoils", level = "5-7", minPlayerLevel = 4, maxPlayerLevel = 8, minAmount = 4, maxAmount = 6, location = "the hills around Kharanos", target = "Crag Boar or Large Crag Boar", targets = {"Crag Boar", "Large Crag Boar"}},
                {id = "dm_bear_spoils", name = "Black Bear Spoils", level = "5-6", minPlayerLevel = 4, maxPlayerLevel = 7, minAmount = 3, maxAmount = 5, location = "the woods around Kharanos", target = "Young Black Bear", targets = {"Young Black Bear"}},
                {id = "dm_wendigo_spoils", name = "Grizzled Den Spoils", level = "5-7", minPlayerLevel = 4, maxPlayerLevel = 8, minAmount = 4, maxAmount = 6, location = "the Grizzled Den", target = "Young Wendigo or Wendigo", targets = {"Young Wendigo", "Wendigo"}},
                {id = "dm_winter_wolf_spoils", name = "Iceflow Wolf Spoils", level = "7-9", minPlayerLevel = 6, maxPlayerLevel = 10, minAmount = 3, maxAmount = 5, location = "Iceflow Lake", target = "Winter Wolf or Starving Winter Wolf", targets = {"Winter Wolf", "Starving Winter Wolf"}},
                {id = "dm_quarry_spoils", name = "Quarry Salvage", level = "8-10", minPlayerLevel = 7, maxPlayerLevel = 10, minAmount = 3, maxAmount = 5, location = "Gol'Bolar Quarry", target = "Rockjaw Skullthumper or Rockjaw Ambusher or Rockjaw Bonesnapper", targets = {"Rockjaw Skullthumper", "Rockjaw Ambusher", "Rockjaw Bonesnapper"}},
                {id = "dm_frostmane_spoils", name = "Frostmane Hold Supplies", level = "8-10", minPlayerLevel = 7, maxPlayerLevel = 10, minAmount = 3, maxAmount = 5, location = "Frostmane Hold", target = "Frostmane Snowstrider or Frostmane Headhunter or Frostmane Hideskinner", targets = {"Frostmane Snowstrider", "Frostmane Headhunter", "Frostmane Hideskinner"}},
                {id = "dm_gnome_spoils", name = "Gnomeregan Surface Salvage", level = "8-10", minPlayerLevel = 7, maxPlayerLevel = 10, minAmount = 3, maxAmount = 5, location = "the surface ruins outside Gnomeregan", target = "Leper Gnome", targets = {"Leper Gnome"}},
            },
        },
        {
            id = "hunt", name = "Hunt", source = "A dwarven scout",
            branches = {
                {
                    id = "rare", name = "Rare target",
                    objectives = {
                        {id = "dm_edan", name = "Edan the Howler", level = "9", minPlayerLevel = 7, maxPlayerLevel = 10, minAmount = 1, maxAmount = 1, location = "the Grizzled Den", rarity = "Rare"},
                        {id = "dm_timber", name = "Timber", level = "10", minPlayerLevel = 8, maxPlayerLevel = 10, minAmount = 1, maxAmount = 1, location = "the islands of Iceflow Lake", rarity = "Rare"},
                        {id = "dm_arctikus", name = "Great Father Arctikus", level = "11", minPlayerLevel = 9, maxPlayerLevel = 12, minAmount = 1, maxAmount = 1, location = "Frostmane Hold", rarity = "Rare"},
                        {id = "dm_gibblewilt", name = "Gibblewilt", level = "11", minPlayerLevel = 9, maxPlayerLevel = 12, minAmount = 1, maxAmount = 1, location = "the surface ruins outside Gnomeregan", rarity = "Rare"},
                        {id = "dm_hammerspine", name = "Hammerspine", level = "12", minPlayerLevel = 10, maxPlayerLevel = 12, minAmount = 1, maxAmount = 1, location = "Gol'Bolar Quarry Mine", rarity = "Rare"},
                        {id = "dm_bjarn", name = "Bjarn", level = "12", minPlayerLevel = 10, maxPlayerLevel = 12, minAmount = 1, maxAmount = 1, location = "the Tundrid Hills", rarity = "Rare"},
                    },
                },
                {
                    id = "elite", name = "Elite target",
                    objectives = {
                        {id = "dm_vagash", name = "Vagash", level = "11", minPlayerLevel = 9, maxPlayerLevel = 12, minAmount = 1, maxAmount = 1, location = "the cave above Amberstill Ranch", rarity = "Elite"},
                    },
                },
            },
        },
    },
    gather = {
        {
            id = "herbalism", name = "Herbalism", skillLine = 182,
            objectives = {
                {id = "dm_peacebloom", name = "Peacebloom", level = "Herbalism 1", minPlayerLevel = 1, maxPlayerLevel = 5, minAmount = 4, maxAmount = 8, location = "the open slopes of Dun Morogh", itemID = 2447},
                {id = "dm_silverleaf", name = "Silverleaf", level = "Herbalism 1", minPlayerLevel = 1, maxPlayerLevel = 7, minAmount = 4, maxAmount = 8, location = "trees throughout Dun Morogh", itemID = 765},
                {id = "dm_earthroot", name = "Earthroot", level = "Herbalism 15", minPlayerLevel = 3, maxPlayerLevel = 10, minAmount = 3, maxAmount = 5, location = "rocky hillsides in Dun Morogh", itemID = 2449},
            },
        },
        {
            id = "mining", name = "Mining", skillLine = 186,
            objectives = {
                {id = "dm_copper_ore", name = "Copper Ore", level = "Mining 1", minPlayerLevel = 1, maxPlayerLevel = 12, minAmount = 5, maxAmount = 9, location = "Copper Veins throughout Dun Morogh", itemID = 2770},
                {id = "dm_rough_stone", name = "Rough Stone", level = "Mining 1", minPlayerLevel = 1, maxPlayerLevel = 12, minAmount = 5, maxAmount = 9, location = "Copper Veins throughout Dun Morogh", itemID = 2835},
                {id = "dm_copper_vein_prospecting", name = "Copper Vein Prospecting", level = "Mining 1", minPlayerLevel = 1, maxPlayerLevel = 12, minAmount = 3, maxAmount = 5, location = "Copper Veins throughout Dun Morogh", itemID = 2770, trackingKind = "nodes"},
            },
        },
        {
            id = "skinning", name = "Skinning", skillLine = 393,
            objectives = {
                {id = "dm_ruined_leather_scraps", name = "Ruined Leather Scraps", level = "Skinning 1", minPlayerLevel = 1, maxPlayerLevel = 5, minAmount = 4, maxAmount = 8, location = "skinnable low-level beasts in Dun Morogh", itemID = 2934},
                {id = "dm_boar_leather", name = "Light Leather from Crag Boars", level = "Skinning 1", minPlayerLevel = 4, maxPlayerLevel = 8, minAmount = 3, maxAmount = 5, location = "boars around Kharanos", itemID = 2318, targets = {"Crag Boar", "Large Crag Boar", "Elder Crag Boar"}},
                {id = "dm_winter_leather", name = "Light Leather from Winter Beasts", level = "Skinning 1", minPlayerLevel = 6, maxPlayerLevel = 10, minAmount = 3, maxAmount = 5, location = "wolves and bears in Dun Morogh", itemID = 2318, targets = {"Winter Wolf", "Starving Winter Wolf", "Ice Claw Bear"}},
            },
        },
        {
            id = "fishing", name = "Fishing", skillLine = 356,
            objectives = {
                {id = "dm_brilliant_smallfish", name = "Raw Brilliant Smallfish", level = "Fishing 1", minPlayerLevel = 1, maxPlayerLevel = 5, minAmount = 5, maxAmount = 9, location = "the open water of Iceflow Lake", itemID = 6291},
                {id = "dm_longjaw_mud_snapper", name = "Raw Longjaw Mud Snapper", level = "Fishing 50", minPlayerLevel = 4, maxPlayerLevel = 10, minAmount = 4, maxAmount = 8, location = "the open water of Iceflow Lake", itemID = 6289},
            },
        },
    },
}

local zones = {
    elwynn = {id = "elwynn", name = "Elwynn Forest", maxLevel = 12, data = database,
        questGivers = {
            {id = 240, name = "Marshal Dughan", location = "Goldshire", faction = "Alliance", roles = {kill = true, hunt = true}},
            {id = 197, name = "Marshal McBride", location = "Northshire Abbey", faction = "Alliance", roles = {kill = true, hunt = true}},
            {id = 823, name = "Deputy Willem", location = "Northshire Valley", faction = "Alliance", roles = {kill = true, hunt = true}},
            {id = 261, name = "Guard Thomas", location = "Eastvale road", faction = "Alliance", roles = {kill = true, hunt = true}},
            {id = 241, name = 'Remy "Two Times"', location = "Goldshire", faction = "Alliance", roles = {hunt = true}},
            {id = 295, name = "Innkeeper Farley", location = "Goldshire", faction = "Alliance", roles = {collect_sell = true, gather = true}},
            {id = 244, name = "Ma Stonefield", location = "Stonefield Farm", faction = "Alliance", roles = {gather = true}},
            {id = 251, name = "Maybell Maclure", location = "Maclure Vineyards", faction = "Alliance", roles = {gather = true}},
            {id = 514, name = "Smith Argus", location = "Goldshire", faction = "Alliance", roles = {gather = true}},
            {id = 66, name = "Tharynn Bouden", location = "Goldshire", faction = "Alliance", roles = {collect_sell = true}},
            {id = 1250, name = "Drake Lindgren", location = "Eastvale Logging Camp", faction = "Alliance", roles = {collect_sell = true}},
            {id = 152, name = "Brother Danil", location = "Northshire Abbey", faction = "Alliance", roles = {collect_sell = true}},
        }},
    dun_morogh = {id = "dun_morogh", name = "Dun Morogh", maxLevel = 12, data = dunMoroghData,
        questGivers = {
            {id = 658, name = "Sten Stoutarm", location = "Coldridge Valley", faction = "Alliance", roles = {kill = true, hunt = true}},
            {id = 713, name = "Balir Frosthammer", location = "Coldridge Valley", faction = "Alliance", roles = {kill = true, hunt = true}},
            {id = 786, name = "Grelin Whitebeard", location = "Coldridge Valley", faction = "Alliance", roles = {kill = true, hunt = true}},
            {id = 714, name = "Talin Keeneye", location = "Coldridge Valley", faction = "Alliance", roles = {kill = true, hunt = true}},
            {id = 1252, name = "Senir Whitebeard", location = "Kharanos", faction = "Alliance", roles = {kill = true, hunt = true}},
            {id = 1265, name = "Rudra Amberstill", location = "Amberstill Ranch", faction = "Alliance", roles = {kill = true, hunt = true}},
            {id = 1247, name = "Innkeeper Belm", location = "Kharanos", faction = "Alliance", roles = {collect_sell = true, gather = true}},
            {id = 1267, name = "Ragnar Thunderbrew", location = "Kharanos", faction = "Alliance", roles = {gather = true}},
            {id = 1378, name = "Pilot Bellowfiz", location = "Steelgrill's Depot", faction = "Alliance", roles = {gather = true}},
            {id = 1269, name = "Razzle Sprysprocket", location = "Steelgrill's Depot", faction = "Alliance", roles = {gather = true}},
            {id = 829, name = "Adlin Pridedrift", location = "Coldridge Valley", faction = "Alliance", roles = {collect_sell = true}},
            {id = 1691, name = "Kreg Bilmn", location = "Kharanos", faction = "Alliance", roles = {collect_sell = true}},
            {id = 1692, name = "Golorn Frostbeard", location = "south of Kharanos", faction = "Alliance", roles = {collect_sell = true}},
        }},
}
local zoneOrder = {"elwynn", "dun_morogh"}
for id, zone in pairs(zones) do
    for _, category in ipairs(zone.data.categories) do category.zoneId = id end
end

local function SelectedZone()
    return zones[db and db.selectedZone] or zones.elwynn
end

local function QuestZone(quest)
    if zones[quest.zoneId] then return zones[quest.zoneId] end
    for _, zone in pairs(zones) do
        if quest.zone == zone.name then return zone end
    end
    -- Legacy quests predate explicit zone IDs and were all Elwynn objectives.
    if not quest.zone then return zones.elwynn end
end


-- Explicit source groups avoid treating a plural display label as a mob name.
local collectSources = {
    northshire_kobold_loot = {"Kobold Vermin", "Kobold Laborer"},
    young_wolf_meat = {"Young Wolf", "Timber Wolf"},
    defias_thug_loot = {"Defias Thug"},
    fargodeep_kobold_loot = {"Kobold Tunneler", "Kobold Miner"},
    stonetusk_boar_meat = {"Stonetusk Boar"},
    crystal_lake_murloc_loot = {"Murloc", "Murloc Streamrunner"},
    eastern_wolf_loot = {"Gray Forest Wolf", "Young Forest Bear"},
    riverpaw_runt_loot = {"Riverpaw Runt"},
    murloc_forager_loot = {"Murloc Forager", "Murloc Lurker"},
    brackwell_defias_loot = {"Defias Bandit"},
    riverpaw_outrunner_loot = {"Riverpaw Outrunner"},
}
local trackedItems = {
    young_wolf_meat = 2672, stonetusk_boar_meat = 769,
    peacebloom = 2447, silverleaf = 765, earthroot = 2449, mageroyal = 785,
    copper_ore = 2770, rough_stone = 2835, copper_vein_prospecting = 2770,
    ruined_leather_scraps = 2934, stonefield_light_leather = 2318, eastern_light_leather = 2318,
    brilliant_smallfish = 6291, longjaw_mud_snapper = 6289, bristle_whisker_catfish = 6308,
}
local skinSources = {
    stonefield_light_leather = {"Stonetusk Boar"},
    eastern_light_leather = {"Gray Forest Wolf", "Young Forest Bear", "Prowler"},
}
local function TrackingSpec(categoryId, objective, profession, vendorID)
    if categoryId == "kill" or categoryId == "hunt" then
        return {kind = "kill", targets = {objective.name}}
    elseif categoryId == "collect_sell" then
        return {kind = "collect_sell", targets = objective.targets or collectSources[objective.id], itemID = objective.itemID or trackedItems[objective.id], vendorID = vendorID}
    elseif profession then
        return {kind = objective.trackingKind or (objective.id == "copper_vein_prospecting" and "nodes" or "gather"),
            profession = profession, itemID = objective.itemID or trackedItems[objective.id], targets = objective.targets or skinSources[objective.id]}
    end
end
local function ResolveTracking(quest)
    local zone = QuestZone(quest)
    if not zone then return end
    local database = zone.data
    for _, category in ipairs(database.categories) do
        if category.branches then
            for _, branch in ipairs(category.branches) do
                for _, objective in ipairs(branch.objectives) do
                    if objective.id == quest.objectiveId then return TrackingSpec(category.id, objective, nil, quest.questGiverID) end
                end
            end
        else
            for _, objective in ipairs(category.objectives) do
                if objective.id == quest.objectiveId then return TrackingSpec(category.id, objective, nil, quest.questGiverID) end
            end
        end
    end
    for _, profession in ipairs(database.gather) do
        for _, objective in ipairs(profession.objectives) do
            if objective.id == quest.objectiveId then return TrackingSpec("gather", objective, profession.id) end
        end
    end
end

local function RandomFrom(list)
    if not list or #list == 0 then return nil end
    return list[math.random(#list)]
end

-- These are original notice-board lines, not NPC dialogue from the game.
local flavorLines = {
    kill = {
        "The roads have grown dangerous; give the locals a reason to travel again.",
        "Another traveler came in shaken. See that the trouble does not follow them home.",
        "The watch is stretched thin, and someone must deal with the threat beyond the lamps.",
        "Farmers are keeping their doors barred. Clear the danger before the next supply run.",
    },
    collect_sell = {
        "A trader will pay for useful spoils, but someone has to brave the wilds first.",
        "The market shelves are bare. Bring back what you can and turn it into coin.",
        "Even the scraps left by troublemakers have value to a careful merchant.",
        "A local buyer has asked for fresh stock; gather it before another caravan does.",
    },
    hunt = {
        "Whispers of a dangerous creature have reached the inn. Find the truth behind them.",
        "The watch has a name, a trail, and too few hands to follow it.",
        "Something formidable is stalking the outskirts. End the tale before it claims another victim.",
        "A reward has been promised to anyone bold enough to face this menace.",
    },
    herbalism = {
        "The apothecary's jars are nearly empty; fresh herbs could spare a long journey.",
        "A healer needs plants gathered before the morning dew gives way to frost.",
        "The local remedies are running low. Search the wilds for the next batch.",
        "Some leaves are worth more than silver when a sick neighbor needs them.",
    },
    mining = {
        "The forge burns bright, but its ore bins are almost bare. Bring back a fresh haul.",
        "A smith has a stack of repairs and scarcely enough metal for a horseshoe.",
        "The next caravan needs sound fittings; the miners must keep the anvils ringing.",
        "Pickaxes are wanted in the hills. The smith will put every usable stone to work.",
    },
    skinning = {
        "The leatherworker has orders to fill and more empty racks than hides.",
        "Boots and packs wear thin on these roads; sturdy leather will keep travelers moving.",
        "A tanner is waiting on fresh hides before the next caravan departs.",
        "The town's straps and saddles need mending. Bring in hides fit for the work.",
    },
    fishing = {
        "The inn's supper pot is hungry, and the fish have yet to volunteer.",
        "A cook has promised a feast with nothing left in the fish basket.",
        "The morning catch was meager. Cast a line before the guests notice.",
        "Fresh fish would be welcome at the table after a long day on the road.",
    },
}

local function PlayerFaction()
    if type(UnitFactionGroup) ~= "function" then return nil end
    local faction = UnitFactionGroup("player")
    if faction == "Alliance" or faction == "Horde" then return faction end
end

local function QuestCategoryId(quest)
    if quest.professionId then return "gather" end
    if quest.categoryName == "Kill" then return "kill" end
    if quest.categoryName == "Collect & Sell" then return "collect_sell" end
    if quest.categoryName == "Hunt" then return "hunt" end
end

local function EligibleGivers(zone, categoryId)
    local result, faction = {}, PlayerFaction()
    if not faction then return result end
    for _, giver in ipairs(zone.questGivers or {}) do
        if giver.faction == faction and giver.roles[categoryId] then result[#result + 1] = giver end
    end
    return result
end

local function AssignNarrative(quest, zone, categoryId)
    local giver
    for _, candidate in ipairs(EligibleGivers(zone, categoryId)) do
        if candidate.id == quest.questGiverID then giver = candidate; break end
    end
    giver = giver or RandomFrom(EligibleGivers(zone, categoryId))
    if not giver then return false end
    local lines = flavorLines[quest.professionId or categoryId]
    if not lines then return false end
    if not quest.flavorText or quest.questGiverID ~= giver.id then quest.flavorText = RandomFrom(lines) end
    quest.questGiverID = giver.id
    quest.questGiverFaction = giver.faction
    quest.questGiverLocation = giver.location
    quest.source = giver.name
    quest.description = "From " .. giver.location .. ": " .. quest.flavorText
    return true
end

local function AmountOptions(objective)
    local options = {}
    if not objective then return options end
    for amount = objective.minAmount, objective.maxAmount do
        options[#options + 1] = amount
    end
    return options
end

local function RollAmount(objective)
    return math.random(objective.minAmount, objective.maxAmount)
end

local function LearnedGatherProfessions()
    local known = {}
    if type(GetProfessions) ~= "function" or type(GetProfessionInfo) ~= "function" then return known end
    local primaryOne, primaryTwo, third, fourth, fifth = GetProfessions()
    local function IncludeProfession(index)
        if index then
            local _, _, _, _, _, _, skillLine = GetProfessionInfo(index)
            for _, profession in ipairs(SelectedZone().data.gather) do
                if skillLine == profession.skillLine then known[profession.id] = true end
            end
        end
    end
    IncludeProfession(primaryOne)
    IncludeProfession(primaryTwo)
    IncludeProfession(third)
    IncludeProfession(fourth)
    IncludeProfession(fifth)
    return known
end

local function CategoryOptions(includeUnlearned, zone)
    zone = zone or SelectedZone()
    local database = zone.data
    local result = {}
    for _, category in ipairs(database.categories) do result[#result + 1] = category end
    local known = LearnedGatherProfessions()
    for _, profession in ipairs(database.gather) do
        if includeUnlearned or known[profession.id] then
            result[#result + 1] = {
                id = "gather:" .. profession.id,
                zoneId = zone.id,
                name = "Gather — " .. profession.name,
                baseName = "Gather",
                profession = profession,
                source = "A gathering commission",
                locked = not known[profession.id],
            }
        end
    end
    return result
end

local function CurrentPlayerLevel()
    return type(UnitLevel) == "function" and UnitLevel("player") or 1
end

local function NormalGenerationLevel()
    return math.min(CurrentPlayerLevel(), SelectedZone().maxLevel)
end

local function ProgressionBand(level)
    if level <= 3 then return "Early" end
    if level <= 6 then return "Mid" end
    if level <= 12 then return "Late" end
    return "Beyond zone range"
end

local function EligibleObjectives(objectives, playerLevel)
    local result = {}
    playerLevel = playerLevel or CurrentPlayerLevel()
    for _, objective in ipairs(objectives or {}) do
        if type(objective.minPlayerLevel) == "number" and type(objective.maxPlayerLevel) == "number"
            and playerLevel >= objective.minPlayerLevel and playerLevel <= objective.maxPlayerLevel then
            result[#result + 1] = objective
        end
    end
    return result
end

local function HighestObjectiveLevel(objectives)
    local highest
    for _, objective in ipairs(objectives or {}) do
        if type(objective.maxPlayerLevel) == "number"
            and (not highest or objective.maxPlayerLevel > highest) then
            highest = objective.maxPlayerLevel
        end
    end
    return highest
end

local function HighestCategoryLevel(category)
    if not category then return nil end
    if category.id == "hunt" then
        local highest
        for _, branch in ipairs(category.branches or {}) do
            local branchHighest = HighestObjectiveLevel(branch.objectives)
            if branchHighest and (not highest or branchHighest > highest) then highest = branchHighest end
        end
        return highest
    end
    return HighestObjectiveLevel(category.profession and category.profession.objectives or category.objectives)
end

-- The browser is an inspection tool, so keep showing a category's nearest
-- supported band when the selected level falls outside its available ranges.
local function BrowserObjectives(objectives, playerLevel)
    if questBrowser and questBrowser.allLevels:GetChecked() then return objectives or {}, nil end
    local eligible = EligibleObjectives(objectives, playerLevel)
    if #eligible > 0 then return eligible, playerLevel end

    local closestLevel, closestDistance
    for _, objective in ipairs(objectives or {}) do
        local minimum, maximum = objective.minPlayerLevel, objective.maxPlayerLevel
        if type(minimum) == "number" and type(maximum) == "number" then
            local candidateLevel
            if playerLevel < minimum then
                candidateLevel = minimum
            elseif playerLevel > maximum then
                candidateLevel = maximum
            else
                candidateLevel = playerLevel
            end
            local distance = math.abs(playerLevel - candidateLevel)
            if not closestDistance or distance < closestDistance
                or (distance == closestDistance and candidateLevel < closestLevel) then
                closestLevel, closestDistance = candidateLevel, distance
            end
        end
    end
    if not closestLevel then return {}, nil end
    return EligibleObjectives(objectives, closestLevel), closestLevel
end

local function ObjectiveOptions(category, branch, playerLevel, outleveled)
    if not category then return {} end
    local objectives = category.id == "hunt" and branch and branch.objectives
        or category.profession and category.profession.objectives or category.objectives
    -- A capped/debug level can exceed a category's ceiling even when it does
    -- not exceed the zone ceiling. Clamp each category independently.
    local highest = HighestCategoryLevel(category)
    local effectiveLevel = playerLevel
    if highest and (outleveled or playerLevel > highest) then effectiveLevel = highest end
    return EligibleObjectives(objectives, effectiveLevel)
end

local function ObjectiveText(category, objective, amount, zone, quest)
    local target = objective.target or objective.name
    local location = objective.location and (" at " .. objective.location) or (" in " .. zone.name)
    if category.id == "kill" then
        return "Travel to " .. objective.location .. " and defeat " .. amount .. " " .. target .. "."
    elseif category.id == "collect_sell" then
        local vendor = quest and quest.source or "the named vendor"
        local vendorLocation = quest and quest.questGiverLocation or zone.name
        return "Collect " .. amount .. " " .. (objective.item or "vendor-value item") .. (amount == 1 and "" or "s") .. " from " .. target .. " near " .. objective.location .. ", then sell them to " .. vendor .. " in " .. vendorLocation .. "."
    elseif category.id == "hunt" then
        return "Find and defeat " .. (amount > 1 and (amount .. " ") or "") .. target .. location .. "."
    elseif objective.trackingKind == "nodes" or objective.id == "copper_vein_prospecting" then
        return "Mine " .. amount .. " different Copper Veins in " .. zone.name .. " and loot their ore."
    elseif category.profession then
        return "Gather " .. amount .. " " .. target .. " " .. location .. "."
    end
end

local function BuildQuest(category, branch, objective, amount)
    if not category or not objective then return nil end
    local zone = zones[category.zoneId] or SelectedZone()
    amount = amount or RollAmount(objective)
    local kind = category.baseName or category.name
    local categoryId = category.profession and "gather" or category.id
    if #EligibleGivers(zone, categoryId) == 0 then return nil end
    local quest = {
        id = table.concat({category.id, branch and branch.id or "", objective.id, tostring(amount)}, ":"),
        selectionId = table.concat({category.id, branch and branch.id or "", objective.id}, ":"),
        title = objective.name,
        kind = kind .. (branch and (" — " .. branch.name) or (category.profession and (" — " .. category.profession.name) or "")),
        categoryName = kind,
        zone = zone.name,
        zoneId = zone.id,
        level = objective.level,
        prompt = category.id == "hunt" and "Gather what is known about the target before you set out; bring back one detail for the story." or
            "Ask the quest giver what makes this request important to them before you leave.",
        objectiveId = objective.id,
        branchId = branch and branch.id,
        professionId = category.profession and category.profession.id,
        amount = amount,
        minPlayerLevel = objective.minPlayerLevel,
        maxPlayerLevel = objective.maxPlayerLevel,
    }
    if not AssignNarrative(quest, zone, categoryId) then return nil end
    quest.objective = ObjectiveText(category, objective, amount, zone, quest)
    quest.tracking = TrackingSpec(category.id, objective, category.profession and category.profession.id, quest.questGiverID)
    return quest
end

local function UpdatedObjectiveText(quest)
    local zone = QuestZone(quest)
    if not zone then return quest.objective end
    for _, category in ipairs(CategoryOptions(true, zone)) do
        if category.branches then
            for _, branch in ipairs(category.branches) do
                for _, objective in ipairs(branch.objectives) do
                    if objective.id == quest.objectiveId then return ObjectiveText(category, objective, quest.amount, zone, quest) end
                end
            end
        else
            for _, objective in ipairs(category.profession and category.profession.objectives or category.objectives) do
                if objective.id == quest.objectiveId then return ObjectiveText(category, objective, quest.amount, zone, quest) end
            end
        end
    end
    return quest.objective
end

-- Relative odds among eligible categories; Gather gets one shared weight,
-- regardless of how many gathering professions the character knows.
local categoryWeights = {kill = 40, collect_sell = 30, gather = 25, hunt = 5}
local function WeightedCategory(categories)
    local groups, byId, total = {}, {}, 0
    for _, category in ipairs(categories) do
        local id = category.profession and "gather" or category.id
        local group = byId[id]
        if not group then
            group = {weight = categoryWeights[id], options = {}}
            byId[id], groups[#groups + 1] = group, group
            total = total + group.weight
        end
        group.options[#group.options + 1] = category
    end
    if total == 0 then return nil end
    local roll = math.random(total)
    for _, group in ipairs(groups) do
        roll = roll - group.weight
        if roll <= 0 then return RandomFrom(group.options) end
    end
end

local function GenerateQuest(playerLevel, outleveled, excluded, forcedCategory)
    playerLevel = playerLevel or NormalGenerationLevel()
    local function Options(category, branch)
        local result = {}
        local categoryId = category.profession and "gather" or category.id
        if forcedCategory and categoryId ~= forcedCategory then return result end
        for _, objective in ipairs(ObjectiveOptions(category, branch, playerLevel, outleveled)) do
            local key = table.concat({category.id, branch and branch.id or "", objective.id}, ":")
            if not excluded or not excluded[key] then result[#result + 1] = objective end
        end
        return result
    end
    local categories = {}
    for _, candidate in ipairs(CategoryOptions(false)) do
        local categoryId = candidate.profession and "gather" or candidate.id
        if #EligibleGivers(SelectedZone(), categoryId) > 0 then
            if candidate.id == "hunt" then
                local hasEligible = false
                for _, branchOption in ipairs(candidate.branches) do
                    if #Options(candidate, branchOption) > 0 then hasEligible = true; break end
                end
                if hasEligible then categories[#categories + 1] = candidate end
            elseif #Options(candidate, nil) > 0 then
                categories[#categories + 1] = candidate
            end
        end
    end
    local category = WeightedCategory(categories)
    if not category then return nil end
    local branch
    if category.id == "hunt" then
        local branches = {}
        for _, option in ipairs(category.branches) do
            if #Options(category, option) > 0 then branches[#branches + 1] = option end
        end
        branch = RandomFrom(branches)
    end
    local objective = RandomFrom(Options(category, branch))
    if not objective then return nil end
    return BuildQuest(category, branch, objective, RollAmount(objective))
end

local function PickDisplayedQuests()
    local chosen = {}
    local seen = {}
    local generationLevel, outleveled
    if QuestGenerationLevel then
        generationLevel, outleveled = QuestGenerationLevel()
    else
        generationLevel = NormalGenerationLevel()
        outleveled = CurrentPlayerLevel() > SelectedZone().maxLevel
    end
    if db.activeQuest and QuestZone(db.activeQuest) == SelectedZone() then
        chosen[1] = db.activeQuest
        seen[db.activeQuest.selectionId or db.activeQuest.id] = true
    elseif debugMode and forcedLeftCategory then
        local quest = GenerateQuest(generationLevel, outleveled, nil, forcedLeftCategory)
        if not quest then
            print("|cffffd27fClassic Questbook:|r No eligible objectives for the selected left-card category. Change category, generation level, or learned professions. Offers were kept.")
            return db.displayedQuests or {}
        end
        chosen[1], seen[quest.selectionId] = quest, true
    end
    local attempts = 0
    while #chosen < 3 and attempts < 100 do
        attempts = attempts + 1
        local quest = GenerateQuest(generationLevel, outleveled, seen)
        if quest and not seen[quest.selectionId] then
            chosen[#chosen + 1] = quest
            seen[quest.selectionId] = true
        end
    end
    return chosen
end

local function ValidQuest(quest)
    return type(quest) == "table"
        and type(quest.id) == "string"
        and type(quest.title) == "string"
        and type(quest.kind) == "string"
        and type(quest.objective) == "string"
        and type(quest.amount) == "number" and quest.amount >= 1 and quest.amount <= 1000 and quest.amount == math.floor(quest.amount)
end

local function ValidDisplayedQuests(displayed)
    if type(displayed) ~= "table" or #displayed > 3 then return false end
    local seen = {}
    for _, quest in ipairs(displayed) do
        if not ValidQuest(quest) or seen[quest.selectionId or quest.id] then return false end
        seen[quest.selectionId or quest.id] = true
    end
    return true
end

local function ValidZoneOffers(offers, zone)
    if not ValidDisplayedQuests(offers) then return false end
    for _, quest in ipairs(offers) do
        if QuestZone(quest) ~= zone then return false end
    end
    return true
end

local debugState = {testLevel = math.min(CurrentPlayerLevel(), SelectedZone().maxLevel)}
local ChangeDebugLevel

QuestGenerationLevel = function()
    if debugMode then return debugState.testLevel, false end
    return NormalGenerationLevel(), CurrentPlayerLevel() > SelectedZone().maxLevel
end

-- Kept on the private addon namespace for deterministic generator diagnostics.
ns.GenerateQuestForLevel = GenerateQuest

local function Text(parent, size, color)
    local text = parent:CreateFontString(nil, "OVERLAY", size or "GameFontHighlight")
    text:SetJustifyH("LEFT")
    text:SetJustifyV("TOP")
    if color then text:SetTextColor(unpack(color)) end
    return text
end

ChangeDebugLevel = function(delta)
    debugState.testLevel = math.min(SelectedZone().maxLevel, math.max(1, debugState.testLevel + delta))
    if board and board.debugLevelText then
        board.debugLevelText:SetText("Generation level: " .. debugState.testLevel .. " (" .. ProgressionBand(debugState.testLevel) .. ")")
        board.debugLevelDown:SetEnabled(debugState.testLevel > 1)
        board.debugLevelUp:SetEnabled(debugState.testLevel < SelectedZone().maxLevel)
    end
    if questBrowser and questBrowser:IsShown() then RefreshQuestBrowser() end
end

-- Each zone retains its own notices. Switching boards is browsing, not rerolling.
local function SelectZone(id)
    if not db or not zones[id] or id == db.selectedZone then return end
    db.zoneOffers[db.selectedZone] = db.displayedQuests
    db.selectedZone = id
    db.displayedQuests = db.zoneOffers[id]
    if not ValidZoneOffers(db.displayedQuests, SelectedZone()) then
        db.displayedQuests = PickDisplayedQuests()
    end
    db.zoneOffers[id] = db.displayedQuests
    ChangeDebugLevel(0)
    if questBrowser then
        questBrowser.preview:SetText("")
        RefreshQuestBrowser()
    end
    Refresh()
end

local browserTab = "kill"
local browserTabData = {
    {id = "kill", label = "Kill", icon = "Interface\\Icons\\Ability_Warrior_SavageBlow"},
    {id = "collect_sell", label = "Collect & Sell", icon = "Interface\\Icons\\INV_Misc_Bag_08"},
    {id = "hunt", label = "Hunt", icon = "Interface\\Icons\\Ability_Hunter_SniperShot"},
    {id = "gather", label = "Gather", icon = "Interface\\Icons\\Trade_Herbalism"},
}

local function BrowserCategory(categoryId)
    for _, category in ipairs(SelectedZone().data.categories) do
        if category.id == categoryId then return category end
    end
end

local function BrowserGatherCategory(profession)
    for _, category in ipairs(CategoryOptions(true)) do
        if category.profession and category.profession.id == profession.id then return category end
    end
end

local function CreateQuestBrowser()
    if questBrowser then return end
    questBrowser = CreateFrame("Frame", "WoWForeverQuestBrowser", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
    questBrowser:SetSize(680, 510)
    questBrowser:SetPoint("CENTER", UIParent, "CENTER", 100, 0)
    questBrowser:SetFrameStrata("FULLSCREEN_DIALOG")
    questBrowser:SetFrameLevel((board and board:GetFrameLevel() or 20) + 20)
    Windows.Register(questBrowser, board)
    questBrowser:SetClampedToScreen(true)
    questBrowser:SetMovable(true)
    questBrowser:EnableMouse(true)
    questBrowser:RegisterForDrag("LeftButton")
    questBrowser:SetScript("OnDragStart", questBrowser.StartMoving)
    questBrowser:SetScript("OnDragStop", questBrowser.StopMovingOrSizing)
    questBrowser:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 32, edgeSize = 16, insets = {left = 4, right = 4, top = 4, bottom = 4}})
    questBrowser:SetBackdropColor(0.12, 0.1, 0.08, 1)
    local title = Text(questBrowser, "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 22, -18)
    title:SetText("Quest Browser")
    local close = CreateFrame("Button", nil, questBrowser, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -4, -4)
    table.insert(UISpecialFrames, "WoWForeverQuestBrowser")

    questBrowser.levelLabel = Text(questBrowser, "GameFontNormal")
    questBrowser.levelLabel:SetPoint("TOPLEFT", 24, -54)
    questBrowser.levelLabel:SetSize(250, 24)
    questBrowser.levelDown = CreateFrame("Button", nil, questBrowser, "UIPanelButtonTemplate")
    questBrowser.levelDown:SetSize(30, 24)
    questBrowser.levelDown:SetPoint("LEFT", questBrowser.levelLabel, "RIGHT", 6, 0)
    questBrowser.levelDown:SetText("<")
    questBrowser.levelDown:SetScript("OnClick", function() ChangeDebugLevel(-1) end)
    questBrowser.levelUp = CreateFrame("Button", nil, questBrowser, "UIPanelButtonTemplate")
    questBrowser.levelUp:SetSize(30, 24)
    questBrowser.levelUp:SetPoint("LEFT", questBrowser.levelDown, "RIGHT", 4, 0)
    questBrowser.levelUp:SetText(">")
    questBrowser.levelUp:SetScript("OnClick", function() ChangeDebugLevel(1) end)
    questBrowser.allLevels = CreateFrame("CheckButton", nil, questBrowser, "UICheckButtonTemplate")
    questBrowser.allLevels:SetSize(26, 26)
    questBrowser.allLevels:SetPoint("TOPLEFT", 390, -51)
    questBrowser.allLevels:SetChecked(false)
    questBrowser.allLevels.label = Text(questBrowser.allLevels)
    questBrowser.allLevels.label:SetPoint("LEFT", questBrowser.allLevels, "RIGHT", 4, 0)
    questBrowser.allLevels.label:SetText("Show all levels")
    questBrowser.allLevels:SetScript("OnClick", function() RefreshQuestBrowser() end)
    questBrowser.tabs = {}
    for index, tabInfo in ipairs(browserTabData) do
        local tabId = tabInfo.id
        local tab = CreateFrame("Button", nil, questBrowser, "UIPanelButtonTemplate")
        questBrowser.tabs[index] = tab
        tab:SetSize(150, 38)
        tab:SetPoint("TOPLEFT", 22 + (index - 1) * 158, -88)
        tab.icon = tab:CreateTexture(nil, "ARTWORK")
        tab.icon:SetSize(22, 22)
        tab.icon:SetPoint("LEFT", 8, 0)
        tab.icon:SetTexture(tabInfo.icon)
        tab.label = tab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        tab.label:SetPoint("LEFT", tab.icon, "RIGHT", 6, 0)
        tab.label:SetText(tabInfo.label)
        tab.activeMark = tab:CreateTexture(nil, "OVERLAY")
        tab.activeMark:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
        tab.activeMark:SetBlendMode("ADD")
        tab.activeMark:SetSize(52, 52)
        tab.activeMark:SetPoint("CENTER", tab.icon, "CENTER", 0, 0)
        tab:SetScript("OnClick", function()
            browserTab = tabId
            RefreshQuestBrowser()
        end)
    end

    questBrowser.scroll = CreateFrame("ScrollFrame", nil, questBrowser, "UIPanelScrollFrameTemplate")
    questBrowser.scroll:SetPoint("TOPLEFT", 18, -136)
    questBrowser.scroll:SetPoint("BOTTOMRIGHT", -34, 110)
    questBrowser.content = CreateFrame("Frame", nil, questBrowser.scroll)
    questBrowser.content:SetWidth(610)
    questBrowser.content:SetHeight(1)
    questBrowser.scroll:SetScrollChild(questBrowser.content)
    questBrowser.sectionRows = {}
    questBrowser.objectiveRows = {}
    questBrowser.testButton = CreateFrame("Button", nil, questBrowser, "UIPanelButtonTemplate")
    questBrowser.testButton:SetSize(150, 26)
    questBrowser.testButton:SetPoint("BOTTOMLEFT", 22, 28)
    questBrowser.testButton:SetText("Generate test quest")
    questBrowser.testButton:SetScript("OnClick", function()
        local quest = GenerateQuest(debugState.testLevel)
        questBrowser.preview:SetText(quest and ("Test quest: " .. quest.title .. " — " .. quest.kind .. " — " .. quest.amount .. "\n" .. quest.objective) or "No eligible quest at this generation level.")
    end)
    questBrowser.preview = Text(questBrowser, "GameFontHighlightSmall", {0.6, 1, 0.6})
    questBrowser.preview:SetPoint("BOTTOMLEFT", questBrowser.testButton, "TOPLEFT", 0, 6)
    questBrowser.preview:SetSize(620, 44)
    questBrowser:Hide()
end

RefreshQuestBrowser = function()
    if not questBrowser then return end
    questBrowser.levelLabel:SetText(SelectedZone().name .. " — Level " .. debugState.testLevel .. " (" .. ProgressionBand(debugState.testLevel) .. ")")
    questBrowser.levelDown:SetEnabled(debugState.testLevel > 1)
    questBrowser.levelUp:SetEnabled(debugState.testLevel < SelectedZone().maxLevel)
    for index, tab in ipairs(questBrowser.tabs) do
        local active = browserTabData[index].id == browserTab
        tab.activeMark:SetShown(active)
        tab.label:SetTextColor(active and 1 or 0.82, active and 0.82 or 0.82, active and 0.2 or 0.82)
    end
    local sectionRows, objectiveRows = questBrowser.sectionRows, questBrowser.objectiveRows
    local sectionCount, objectiveCount, y = 0, 0, -8
    local function AddSection(label, icon)
        if questBrowser.allLevels:GetChecked() then label = label .. " — " .. SelectedZone().name .. ": all levels" end
        sectionCount = sectionCount + 1
        local row = sectionRows[sectionCount]
        if not row then
            row = Text(questBrowser.content, "GameFontNormal")
            sectionRows[sectionCount] = row
        end
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", questBrowser.content, "TOPLEFT", 8, y)
        row:SetSize(570, 22)
        row:SetText((icon and "|T" .. icon .. ":16:16:0:0|t  " or "") .. label)
        row:Show()
        y = y - 23
    end
    local function AddObjective(category, branch, objective)
        objectiveCount = objectiveCount + 1
        local row = objectiveRows[objectiveCount]
        if not row then
            row = CreateFrame("Button", nil, questBrowser.content, "UIPanelButtonTemplate")
            row.title = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            row.title:SetPoint("LEFT", 10, 0)
            row.amount = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            row.amount:SetPoint("RIGHT", -12, 0)
            objectiveRows[objectiveCount] = row
        end
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", questBrowser.content, "TOPLEFT", 8, y)
        row:SetSize(570, 26)
        row.title:SetText(objective.name)
        row.amount:SetText("Level " .. objective.minPlayerLevel .. "–" .. objective.maxPlayerLevel)
        row:SetScript("OnClick", function()
            local preview = BuildQuest(category, branch, objective, RollAmount(objective))
            questBrowser.preview:SetText(preview and (preview.title .. " — " .. preview.kind .. " — Amount range " .. objective.minAmount .. "–" .. objective.maxAmount .. "\n" .. preview.objective)
                or "No friendly quest giver is available for this category in this zone.")
        end)
        row:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:AddLine(objective.name)
            GameTooltip:AddLine("Creature/resource level or skill: " .. objective.level, 1, 1, 1)
            GameTooltip:AddLine("Eligible character levels: " .. objective.minPlayerLevel .. "-" .. objective.maxPlayerLevel, 1, 1, 1)
            GameTooltip:AddLine("Amount range: " .. objective.minAmount .. "-" .. objective.maxAmount, 1, 1, 1)
            GameTooltip:AddLine("Location: " .. objective.location, 0.8, 0.8, 0.8)
            GameTooltip:Show()
        end)
        row:SetScript("OnLeave", function() GameTooltip:Hide() end)
        row:Show()
        y = y - 28
    end
    if browserTab == "hunt" then
        local category = BrowserCategory("hunt")
        for _, branch in ipairs(category.branches) do
            local objectives, effectiveLevel = BrowserObjectives(branch.objectives, debugState.testLevel)
            local label = branch.name == "Rare target" and "Rare Targets" or "Elite Targets"
            if effectiveLevel then
                label = label .. " — Level " .. effectiveLevel
                if effectiveLevel ~= debugState.testLevel then label = label .. " (requested " .. debugState.testLevel .. ")" end
            end
            AddSection(label)
            for _, objective in ipairs(objectives) do
                AddObjective(category, branch, objective)
            end
        end
    elseif browserTab == "gather" then
        for _, profession in ipairs(SelectedZone().data.gather) do
            local category = BrowserGatherCategory(profession)
            local objectives, effectiveLevel = BrowserObjectives(profession.objectives, debugState.testLevel)
            local label = profession.name
            if effectiveLevel then
                label = label .. " — Level " .. effectiveLevel
                if effectiveLevel ~= debugState.testLevel then label = label .. " (requested " .. debugState.testLevel .. ")" end
            end
            AddSection(label, profession.icon)
            for _, objective in ipairs(objectives) do
                AddObjective(category, nil, objective)
            end
        end
    else
        local category = BrowserCategory(browserTab)
        local objectives, effectiveLevel = BrowserObjectives(category.objectives, debugState.testLevel)
        local label = category.name .. " Objectives"
        if effectiveLevel then
            label = label .. " — Level " .. effectiveLevel
            if effectiveLevel ~= debugState.testLevel then label = label .. " (requested " .. debugState.testLevel .. ")" end
        end
        AddSection(label)
        for _, objective in ipairs(objectives) do
            AddObjective(category, nil, objective)
        end
    end
    for index = sectionCount + 1, #sectionRows do sectionRows[index]:Hide() end
    for index = objectiveCount + 1, #objectiveRows do objectiveRows[index]:Hide() end
    if objectiveCount == 0 then AddSection("No objectives are eligible at this level.") end
    questBrowser.content:SetHeight(math.max(1, -y + 8))
    questBrowser.scroll:UpdateScrollChildRect()
    questBrowser.scroll:SetVerticalScroll(0)
end

local function CreateDebugModeButton(parent)
    if debugModeButton then return end
    debugModeButton = CreateFrame("Button", "WoWForeverDebugModeButton", parent, "UIPanelButtonTemplate")
    debugModeButton:SetSize(30, 30)
    debugModeButton:SetPoint("TOPLEFT", parent, "TOPLEFT", 16, -16)
    debugModeButton:EnableMouse(true)
    debugModeButton.icon = debugModeButton:CreateTexture(nil, "ARTWORK")
    debugModeButton.icon:SetTexture("Interface\\Common\\UI-Searchbox-Icon")
    debugModeButton.icon:SetDrawLayer("OVERLAY")
    debugModeButton.icon:SetPoint("CENTER", debugModeButton, "CENTER", 0, 0)
    debugModeButton.icon:SetSize(20, 20)
    debugModeButton.active = debugModeButton:CreateTexture(nil, "OVERLAY")
    debugModeButton.active:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
    debugModeButton.active:SetBlendMode("ADD")
    debugModeButton.active:SetPoint("CENTER")
    debugModeButton.active:SetSize(36, 36)
    debugModeButton.active:SetVertexColor(0.3, 0.65, 1, 0.55)
    debugModeButton.active:SetAlpha(0.45)
    debugModeButton.active:Hide()
    debugModeButton:SetScript("OnClick", function() SetDebugMode(not debugMode, false) end)
    debugModeButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine("Questboard Debug Mode")
        GameTooltip:AddLine(debugMode and "Click to turn off" or "Click to turn on", 1, 1, 1)
        GameTooltip:Show()
    end)
    debugModeButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

local optionsWindow, abandonDialog, helpWindow, statisticsWindow

local function SecondaryWindow(name, title, width, height, strata)
    local frame = CreateFrame("Frame", name, UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
    frame:SetSize(width, height)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata(strata or "FULLSCREEN_DIALOG")
    frame:SetFrameLevel(60)
    Windows.Register(frame, board)
    frame:SetClampedToScreen(true)
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 32, edgeSize = 16, insets = {left = 4, right = 4, top = 4, bottom = 4}})
    frame:SetBackdropColor(0.12, 0.1, 0.08, 1)
    frame.title = Text(frame, "GameFontNormalLarge")
    frame.title:SetPoint("TOPLEFT", 22, -20)
    frame.title:SetText(title)
    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -4, -4)
    table.insert(UISpecialFrames, name)
    return frame
end

local function Checkbox(parent, label, y)
    local check = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    check:SetSize(26, 26)
    check:SetPoint("TOPLEFT", 24, y)
    check.label = Text(check)
    check.label:SetPoint("LEFT", check, "RIGHT", 4, 0)
    check.label:SetText(label)
    return check
end

local function OpenOptions()
    if optionsWindow and optionsWindow:IsShown() then optionsWindow:Hide(); return end
    if not optionsWindow then
        optionsWindow = SecondaryWindow("WoWForeverOptions", "Classic Questbook Options", 430, 180)
        optionsWindow.confirmation = Checkbox(optionsWindow, "Show abandon quest confirmation", -62)
        optionsWindow.confirmation:SetScript("OnClick", function(self)
            db.settings.showAbandonConfirmation = not not self:GetChecked()
        end)
        local hint = Text(optionsWindow, "GameFontHighlightSmall")
        hint:SetPoint("TOPLEFT", 28, -108)
        hint:SetSize(370, 42)
        hint:SetText("Assign a toggle key in WoW's Key Bindings settings under Classic Questbook.")
    end
    optionsWindow.confirmation:SetChecked(db.settings.showAbandonConfirmation)
    Windows.Open(optionsWindow, Windows.Previous(board, optionsWindow))
end

local statisticSections = {
    {key = "accepted", label = "Quests accepted", field = "acceptedByCategory"},
    {key = "handedIn", label = "Quests handed in", field = "completedByCategory"},
    {key = "abandoned", label = "Quests abandoned", field = "abandonedByCategory"},
}
local function LayoutStatistics()
    local y = -58
    for _, definition in ipairs(statisticSections) do
        local section = statisticsWindow.sections[definition.key]
        section:ClearAllPoints()
        section:SetPoint("TOPLEFT", statisticsWindow, "TOPLEFT", 24, y)
        local height = section.expanded and 164 or 40
        section:SetHeight(height)
        section.categories:SetShown(section.expanded)
        section.expand:SetText(section.expanded and "−" or "+")
        y = y - height
    end
    statisticsWindow:SetHeight(-y + 78)
    statisticsWindow:SetScale(math.min(1, (UIParent:GetHeight() - 40) / statisticsWindow:GetHeight()))
end

local function RefreshStatistics()
    if not statisticsWindow then return end
    statisticsWindow.reset:SetShown(debugMode)
    local stats = Tracking.GetStatistics()
    for _, definition in ipairs(statisticSections) do
        local section = statisticsWindow.sections[definition.key]
        statisticsWindow.values[definition.key]:SetText(tostring(stats[definition.key]))
        local sum = 0
        for category, label in pairs(section.categoryValues) do
            local count = stats[definition.field][category]
            label:SetText(tostring(count))
            sum = sum + count
        end
        section.unclassified:SetText(tostring(math.max(0, stats[definition.key] - sum)))
    end
end

local function ToggleStatistics()
    if statisticsWindow and statisticsWindow:IsShown() then statisticsWindow:Hide(); return end
    if not statisticsWindow then
        statisticsWindow = SecondaryWindow("WoWForeverStatistics", "Classic Questbook Statistics", 440, 260)
        statisticsWindow.values, statisticsWindow.sections = {}, {}
        statisticsWindow.reset = CreateFrame("Button", nil, statisticsWindow, "UIPanelButtonTemplate")
        statisticsWindow.reset:SetSize(102, 24)
        statisticsWindow.reset:SetPoint("BOTTOMRIGHT", -28, 20)
        statisticsWindow.reset:SetText("Reset Stats")
        statisticsWindow.reset:SetScript("OnClick", function()
            if not debugMode then return end
            Tracking.DebugResetStatistics(true)
        end)
        for _, definition in ipairs(statisticSections) do
            local section = CreateFrame("Frame", nil, statisticsWindow)
            section:SetWidth(392)
            section.expanded = false
            statisticsWindow.sections[definition.key] = section
            section.expand = CreateFrame("Button", nil, section, "UIPanelButtonTemplate")
            section.expand:SetSize(22, 22)
            section.expand:SetPoint("TOPLEFT", 0, 0)
            local label = Text(section)
            label:SetPoint("TOPLEFT", 32, -4)
            label:SetText(definition.label)
            local value = Text(section, "GameFontNormalLarge")
            value:SetPoint("TOPRIGHT", -8, -4)
            statisticsWindow.values[definition.key] = value
            section.categories = CreateFrame("Frame", nil, section)
            section.categories:SetSize(352, 120)
            section.categories:SetPoint("TOPLEFT", 32, -30)
            section.categoryValues = {}
            for index, category in ipairs({"Kill", "Collect & Sell", "Hunt", "Gather", "Earlier / unclassified"}) do
                local categoryLabel = Text(section.categories, "GameFontHighlightSmall")
                categoryLabel:SetPoint("TOPLEFT", 8, -(index - 1) * 24)
                categoryLabel:SetText(category)
                local count = Text(section.categories, "GameFontNormal")
                count:SetPoint("TOPRIGHT", 0, -(index - 1) * 24)
                if index == 5 then section.unclassified = count else section.categoryValues[category] = count end
            end
            section.expand:SetScript("OnClick", function()
                section.expanded = not section.expanded
                LayoutStatistics()
            end)
        end
        local note = Text(statisticsWindow, "GameFontHighlightSmall", {0.65, 0.65, 0.65})
        note:SetPoint("BOTTOMLEFT", 28, 20)
        note:SetSize(260, 50)
        note:SetText("Per character; includes Debug Mode actions.\nEarlier totals without category records are unclassified.")
    end
    RefreshStatistics()
    LayoutStatistics()
    Windows.Open(statisticsWindow, Windows.Previous(board, statisticsWindow))
end

local function ToggleHelp()
    if helpWindow and helpWindow:IsShown() then helpWindow:Hide(); return end
    if not helpWindow then
        helpWindow = SecondaryWindow("WoWForeverHelp", "Classic Questbook Help", 440, 210)
        local message = Text(helpWindow)
        message:SetPoint("TOPLEFT", 28, -62)
        message:SetSize(382, 110)
        message:SetText("Help is on its way!\n\nUnfortunately, the author accepted a quest to collect 8 helpful tips and has only found 3.\n\nPlease check back after the next turn-in.")
    end
    Windows.Open(helpWindow, Windows.Previous(board, helpWindow))
end

local function AbandonActive(expected)
    if db.activeQuest ~= expected then return false end
    if not Tracking.Abandon() then return false end
    -- After a reload the offer and active quest can be separate saved tables.
    for _, offer in ipairs(db.displayedQuests) do
        if offer.id == expected.id then
            offer.state, offer.progress, offer.acceptedAt, offer.completedAt = nil, nil, nil, nil
        end
    end
    Refresh()
    return true
end

local function RequestAbandon()
    local active = db.activeQuest
    if not active then return end
    if not db.settings.showAbandonConfirmation then AbandonActive(active); return end
    if not abandonDialog then
        abandonDialog = SecondaryWindow("WoWForeverAbandonDialog", "Abandon Quest", 430, 220, "TOOLTIP")
        abandonDialog.message = Text(abandonDialog)
        abandonDialog.message:SetPoint("TOPLEFT", 26, -58)
        abandonDialog.message:SetSize(375, 54)
        abandonDialog.skip = Checkbox(abandonDialog, "Don't show this again", -120)
        abandonDialog.confirm = CreateFrame("Button", nil, abandonDialog, "UIPanelButtonTemplate")
        abandonDialog.confirm:SetSize(150, 26)
        abandonDialog.confirm:SetPoint("BOTTOMLEFT", 40, 24)
        abandonDialog.confirm:SetText("Abandon")
        abandonDialog.confirm:SetScript("OnClick", function()
            local expected, skip = abandonDialog.quest, abandonDialog.skip:GetChecked()
            if expected and AbandonActive(expected) and skip then
                db.settings.showAbandonConfirmation = false
                if optionsWindow then optionsWindow.confirmation:SetChecked(false) end
            end
            abandonDialog:Hide()
        end)
        abandonDialog.cancel = CreateFrame("Button", nil, abandonDialog, "UIPanelButtonTemplate")
        abandonDialog.cancel:SetSize(150, 26)
        abandonDialog.cancel:SetPoint("BOTTOMRIGHT", -40, 24)
        abandonDialog.cancel:SetText("Cancel")
        abandonDialog.cancel:SetScript("OnClick", function() abandonDialog:Hide() end)
        abandonDialog:SetScript("OnHide", function(self) self.quest = nil end)
    end
    abandonDialog.quest = active
    abandonDialog.skip:SetChecked(false)
    abandonDialog.message:SetText('Abandon "' .. active.title .. '"?\nYour progress on this quest will be lost.')
    Windows.Open(abandonDialog, board)
end

local function TurnInSlot(index)
    local excluded = {}
    for _, offer in ipairs(db.displayedQuests) do excluded[offer.selectionId or offer.id] = true end
    local generationLevel, outleveled = QuestGenerationLevel()
    local forcedCategory = debugMode and index == 1 and forcedLeftCategory or nil
    local replacement = GenerateQuest(generationLevel, outleveled, excluded, forcedCategory)
    if not replacement then
        local current = db.displayedQuests[index]
        excluded[current.selectionId or current.id] = nil
        replacement = GenerateQuest(generationLevel, outleveled, excluded, forcedCategory)
    end
    if not replacement and forcedCategory then
        -- A debug preference must not block handing in an already-ready quest.
        replacement = GenerateQuest(generationLevel, outleveled, excluded)
        if replacement then print("|cffffd27fClassic Questbook:|r No unique eligible replacement in the forced category; using a normal replacement.") end
    end
    if not replacement or not Tracking.TurnIn(debugMode) then return end
    db.displayedQuests[index] = replacement
    Refresh()
end

CreateBoard = function()
    board = CreateFrame("Frame", "WoWForeverQuestboard", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
    board:SetSize(840, 570)
    board:SetPoint("CENTER")
    board:SetFrameStrata("DIALOG")
    board:SetFrameLevel(20)
    Windows.Register(board)
    board:SetClampedToScreen(true)
    board:SetMovable(true)
    board:EnableMouse(true)
    board:RegisterForDrag("LeftButton")
    board:SetScript("OnDragStart", board.StartMoving)
    board:SetScript("OnDragStop", board.StopMovingOrSizing)
    board:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 32, edgeSize = 16, insets = {left = 4, right = 4, top = 4, bottom = 4}})
    board:SetBackdropColor(0.12, 0.1, 0.08, 1)
    local title = Text(board, "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 54, -12)
    title:SetText("Classic Questbook")
    local version = Text(board, "GameFontHighlightSmall")
    version:SetPoint("TOPLEFT", 54, -31)
    version:SetText("Alpha V0.9.0")
    board.zoneDropdown = CreateFrame("Frame", "WoWForeverZoneDropdown", board, "UIDropDownMenuTemplate")
    board.zoneDropdown:SetPoint("TOP", board, "TOP", 0, -8)
    UIDropDownMenu_SetWidth(board.zoneDropdown, 190)
    UIDropDownMenu_Initialize(board.zoneDropdown, function(self, menuLevel)
        for _, id in ipairs(zoneOrder) do
            local zoneId = id
            local info = UIDropDownMenu_CreateInfo()
            info.text = zones[zoneId].name
            info.checked = db.selectedZone == zoneId
            info.func = function()
                SelectZone(zoneId)
                CloseDropDownMenus()
            end
            UIDropDownMenu_AddButton(info, menuLevel)
        end
    end)
    board.zoneDropdown:HookScript("OnHide", function(self)
        if UIDROPDOWNMENU_OPEN_MENU == self then CloseDropDownMenus() end
    end)
    local subtitle = Text(board, "GameFontHighlightSmall")
    subtitle:SetPoint("TOPLEFT", 24, -50)
    subtitle:SetText("Generated " .. SelectedZone().name .. " adventures.")
    board.subtitle = subtitle
    local close = CreateFrame("Button", nil, board, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -4, -4)
    board.options = CreateFrame("Button", nil, board, "UIPanelButtonTemplate")
    board.options:SetSize(26, 26)
    board.options:SetPoint("TOPRIGHT", -38, -9)
    local settingsIcon = board.options:CreateTexture(nil, "OVERLAY")
    settingsIcon:SetTexture("Interface\\Icons\\INV_Misc_Gear_01")
    settingsIcon:SetSize(20, 20)
    settingsIcon:SetPoint("CENTER")
    board.options:SetScript("OnClick", OpenOptions)
    board.options:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine("Classic Questbook Options")
        GameTooltip:Show()
    end)
    board.options:SetScript("OnLeave", function() GameTooltip:Hide() end)
    board.help = CreateFrame("Button", nil, board, "UIPanelButtonTemplate")
    board.help:SetSize(26, 26)
    board.help:SetPoint("TOPRIGHT", -70, -9)
    board.help:SetText("?")
    board.help:SetScript("OnClick", ToggleHelp)
    board.help:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine("Classic Questbook Help")
        GameTooltip:Show()
    end)
    board.help:SetScript("OnLeave", function() GameTooltip:Hide() end)
    board.statistics = CreateFrame("Button", nil, board, "UIPanelButtonTemplate")
    board.statistics:SetSize(86, 26)
    board.statistics:SetPoint("TOPRIGHT", -104, -9)
    board.statistics:SetText("Statistics")
    board.statistics:SetScript("OnClick", ToggleStatistics)
    table.insert(UISpecialFrames, "WoWForeverQuestboard")
    CreateDebugModeButton(board)

    cards = {}
    for index = 1, 3 do
        local offerIndex = index
        local card = CreateFrame("Frame", nil, board, BackdropTemplateMixin and "BackdropTemplate" or nil)
        cards[index] = card
        card:SetSize(256, 396)
        card:SetPoint("TOPLEFT", 24 + (index - 1) * 268, -82)
        card:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12, insets = {left = 3, right = 3, top = 3, bottom = 3}})
        card:SetBackdropColor(0.16, 0.135, 0.09, 0.96)
        card.heading = Text(card, "GameFontNormalLarge")
        card.heading:SetPoint("TOPLEFT", 14, -16)
        card.heading:SetSize(228, 44)
        card.meta = Text(card, "GameFontHighlightSmall", {0.72, 0.65, 0.49})
        card.meta:SetPoint("TOPLEFT", 14, -62)
        card.meta:SetSize(228, 42)
        card.story = Text(card)
        card.story:SetPoint("TOPLEFT", 14, -108)
        card.story:SetSize(228, 88)
        card.objective = Text(card, "GameFontNormal")
        card.objective:SetPoint("TOPLEFT", 14, -202)
        card.objective:SetSize(228, 92)
        card.progress = Text(card, "GameFontNormalSmall")
        card.progress:SetPoint("TOPLEFT", 14, -302)
        card.progress:SetSize(228, 36)
        card.marker = Text(card, "GameFontNormalSmall", {0.5, 0.9, 0.5})
        card.marker:SetPoint("BOTTOM", 0, 43)
        card.button = CreateFrame("Button", nil, card, "UIPanelButtonTemplate")
        card.button:SetSize(218, 26)
        card.button:SetPoint("BOTTOM", 0, 12)
        card.button:SetScript("OnClick", function()
            local quest = db.displayedQuests[offerIndex]
            if not quest then return end
            if db.activeQuest then
                if db.activeQuest.id ~= quest.id then return end
                if db.activeQuest.state == "Ready to Turn In" then
                    TurnInSlot(offerIndex)
                else
                    RequestAbandon()
                end
                return
            end
            if quest.questGiverFaction ~= PlayerFaction() then return end
            if not Tracking.Accept(quest, debugMode) then return end
            Refresh()
            print("|cffffd27fClassic Questbook:|r Accepted \"" .. quest.title .. "\". Open /cq to view your objective.")
        end)
        -- A ready quest keeps Turn In as its primary action; abandonment is
        -- still possible on the same card, including outside rested areas.
        card.abandon = CreateFrame("Button", nil, card, "UIPanelButtonTemplate")
        card.abandon:SetSize(120, 20)
        card.abandon:SetPoint("BOTTOM", 0, 44)
        card.abandon:SetText("Abandon Quest")
        card.abandon:SetScript("OnClick", function()
            local quest = db.displayedQuests[offerIndex]
            if not quest or not db.activeQuest or quest.id ~= db.activeQuest.id then return end
            RequestAbandon()
        end)
        card.abandon:Hide()
    end

    board.status = Text(board, "GameFontNormal")
    board.status:SetPoint("TOPLEFT", 24, -489)
    board.status:SetSize(350, 22)
    board.note = Text(board, "GameFontHighlightSmall", {0.65, 0.65, 0.65})
    board.note:SetPoint("TOPLEFT", 24, -523)
    board.note:SetSize(790, 38)
    board.debugLevelControls = CreateFrame("Frame", nil, board)
    board.debugLevelControls:SetSize(300, 28)
    board.debugLevelControls:SetPoint("TOPRIGHT", -64, -46)
    board.debugLevelText = Text(board.debugLevelControls, "GameFontHighlight")
    board.debugLevelText:SetPoint("LEFT", 0, 0)
    board.debugLevelText:SetSize(214, 24)
    board.debugLevelDown = CreateFrame("Button", nil, board.debugLevelControls, "UIPanelButtonTemplate")
    board.debugLevelDown:SetSize(30, 24)
    board.debugLevelDown:SetPoint("LEFT", board.debugLevelText, "RIGHT", 2, 0)
    board.debugLevelDown:SetText("<")
    board.debugLevelDown:SetScript("OnClick", function() ChangeDebugLevel(-1) end)
    board.debugLevelUp = CreateFrame("Button", nil, board.debugLevelControls, "UIPanelButtonTemplate")
    board.debugLevelUp:SetSize(30, 24)
    board.debugLevelUp:SetPoint("LEFT", board.debugLevelDown, "RIGHT", 2, 0)
    board.debugLevelUp:SetText(">")
    board.debugLevelUp:SetScript("OnClick", function() ChangeDebugLevel(1) end)
    board.debugButton = CreateFrame("Button", nil, board, "UIPanelButtonTemplate")
    board.debugButton:SetSize(142, 26)
    board.debugButton:SetPoint("TOPRIGHT", -24, -487)
    board.debugButton:SetText("Quest Browser")
    board.debugButton:Hide()
    board.debugButton:SetScript("OnClick", function()
        if not debugMode then return end
        if questBrowser and questBrowser:IsShown() then questBrowser:Hide(); return end
        CreateQuestBrowser()
        RefreshQuestBrowser()
        Windows.Open(questBrowser, Windows.Previous(board, questBrowser))
    end)
    board.reroll = CreateFrame("Button", nil, board, "UIPanelButtonTemplate")
    board.reroll:SetSize(120, 26)
    board.reroll:SetPoint("RIGHT", board.debugButton, "LEFT", -8, 0)
    board.reroll:SetText("Reroll quests")
    board.reroll:SetScript("OnClick", function()
        if db.activeQuest then return end
        db.displayedQuests = PickDisplayedQuests()
        Refresh()
    end)

    board.debugLevelControls:Hide()
    board.debugProgress = CreateFrame("Button", nil, board, "UIPanelButtonTemplate")
    board.debugProgress:SetSize(115, 24)
    board.debugProgress:SetPoint("TOPLEFT", 280, -47)
    board.debugProgress:SetText("+1 Progress")
    board.debugProgress:SetScript("OnClick", function() Tracking.DebugAddProgress(debugMode) end)
    board.debugProgress:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine("Add quest progress (Debug Mode)")
        GameTooltip:AddLine("Adds one to the active objective. Collect & Sell advances collection first, then selling.", 1, 1, 1, true)
        GameTooltip:Show()
    end)
    board.debugProgress:SetScript("OnLeave", function() GameTooltip:Hide() end)
    board.debugProgress:Hide()
    local categoryChoices = {
        {label = "Any category"}, {id = "kill", label = "Kill"},
        {id = "collect_sell", label = "Collect & Sell"},
        {id = "hunt", label = "Hunt"}, {id = "gather", label = "Gather"},
    }
    board.debugCategory = CreateFrame("Frame", "WoWForeverCategoryDropdown", board, "UIDropDownMenuTemplate")
    board.debugCategory:SetPoint("TOPLEFT", 8, -43)
    UIDropDownMenu_SetWidth(board.debugCategory, 210)
    UIDropDownMenu_SetText(board.debugCategory, "Left card: Any category")
    UIDropDownMenu_Initialize(board.debugCategory, function(self, menuLevel)
        if not debugMode then return end
        for _, entry in ipairs(categoryChoices) do
            local choice = entry
            local info = UIDropDownMenu_CreateInfo()
            info.text = choice.label
            info.checked = forcedLeftCategory == choice.id
            info.func = function()
                if not debugMode then return end
                forcedLeftCategory = choice.id
                UIDropDownMenu_SetText(self, "Left card: " .. choice.label)
                CloseDropDownMenus()
            end
            UIDropDownMenu_AddButton(info, menuLevel)
        end
    end)
    board.debugCategory:HookScript("OnHide", function(self)
        if UIDROPDOWNMENU_OPEN_MENU == self then CloseDropDownMenus() end
    end)
    board.debugCategory:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine("Left card category")
        GameTooltip:AddLine("Choose Any, Kill, Collect & Sell, Hunt, or Gather from the dropdown.", 1, 1, 1)
        GameTooltip:AddLine("Applies on Reroll Quests or left-card turn-in. Eligibility rules still apply.", 0.7, 0.7, 0.7, true)
        GameTooltip:Show()
    end)
    board.debugCategory:SetScript("OnLeave", function() GameTooltip:Hide() end)
    board.debugCategory:Hide()
    board.debugAmountControls = CreateFrame("Frame", nil, board)
    board.debugAmountControls:SetSize(790, 30)
    board.debugAmountControls:SetPoint("TOPLEFT", 24, -570)
    local amountLabel = Text(board.debugAmountControls)
    amountLabel:SetPoint("LEFT")
    amountLabel:SetText("Required amount:")
    board.debugAmount = CreateFrame("EditBox", nil, board.debugAmountControls, "InputBoxTemplate")
    board.debugAmount:SetSize(65, 24)
    board.debugAmount:SetPoint("LEFT", amountLabel, "RIGHT", 14, 0)
    board.debugAmount:SetAutoFocus(false)
    board.debugAmount:SetNumeric(true)
    board.debugAmount:SetMaxLetters(4)
    board.debugAmount:SetScript("OnEscapePressed", function(self) self:ClearFocus(); self:SetText(db.activeQuest and tostring(db.activeQuest.amount) or "") end)
    board.debugAmountApply = CreateFrame("Button", nil, board.debugAmountControls, "UIPanelButtonTemplate")
    board.debugAmountApply:SetSize(70, 24)
    board.debugAmountApply:SetPoint("LEFT", board.debugAmount, "RIGHT", 8, 0)
    board.debugAmountApply:SetText("Apply")
    local function ApplyAmount()
        local active = db.activeQuest
        if not Tracking.DebugSetAmount(debugMode, board.debugAmount:GetText(), board.debugAmount.quest) then
            print("|cffffd27fClassic Questbook:|r Select an active tracked quest in Debug Mode and enter a whole amount from 1 to 1000.")
            return
        end
        active.objective = UpdatedObjectiveText(active)
        for _, offer in ipairs(db.displayedQuests) do
            if offer.id == active.id then offer.amount, offer.objective = active.amount, active.objective end
        end
        board.debugAmount:ClearFocus()
        board.debugAmount:SetText(tostring(active.amount))
        Refresh()
    end
    board.debugAmountApply:SetScript("OnClick", ApplyAmount)
    board.debugAmount:SetScript("OnEnterPressed", ApplyAmount)
    local amountHint = Text(board.debugAmountControls, "GameFontHighlightSmall")
    amountHint:SetPoint("LEFT", board.debugAmountApply, "RIGHT", 12, 0)
    amountHint:SetText("1–1000 • Active quest only • Progress is preserved")
    board.debugAmountControls:Hide()
    board:Hide()
end

SetDebugMode = function(enabled, openBrowser)
    debugMode = not not enabled
    if not board then CreateBoard() end
    if debugMode then
        if not ValidDisplayedQuests(db.displayedQuests) then db.displayedQuests = PickDisplayedQuests() end
        board:SetScale(math.min(1, UIParent:GetWidth() / 880, UIParent:GetHeight() / 610))
        Refresh()
        board:Show()
        if openBrowser then
            CreateQuestBrowser()
            RefreshQuestBrowser()
            Windows.Open(questBrowser, Windows.Previous(board, questBrowser))
        end
    elseif questBrowser then
        questBrowser:Hide()
    end
    if debugModeButton then debugModeButton.active:SetShown(debugMode) end
    if board then
        board.debugLevelText:SetText("Generation level: " .. debugState.testLevel .. " (" .. ProgressionBand(debugState.testLevel) .. ")")
        board.debugLevelDown:SetEnabled(debugState.testLevel > 1)
        board.debugLevelUp:SetEnabled(debugState.testLevel < SelectedZone().maxLevel)
        board.debugLevelControls:SetShown(debugMode)
        board.debugButton:SetShown(debugMode)
        Refresh()
    end
end

Refresh = function()
    if db and db.zoneOffers then db.zoneOffers[db.selectedZone] = db.displayedQuests end
    RefreshStatistics()
    if not board or not db then return end
    UIDropDownMenu_SetText(board.zoneDropdown, SelectedZone().name)
    board.subtitle:SetText("Generated " .. SelectedZone().name .. " adventures.")
    local resting = Tracking.IsResting()
    local locationAllowed = debugMode or resting
    for index, card in ipairs(cards) do
        local quest = db.displayedQuests[index]
        local accepted = quest and db.activeQuest and db.activeQuest.id == quest.id
        if accepted then quest = db.activeQuest end
        local ready = accepted and quest.state == "Ready to Turn In"
        local trackable = quest and Tracking.CanTrack(quest)
        -- Refresh saved Hunt wording too, without changing its generation data.
        local hunt = quest and quest.categoryName == "Hunt"
        local objectiveText = hunt and UpdatedObjectiveText(quest) or (quest and quest.objective)
        card.heading:SetText(quest and quest.title or "No suitable quest")
        card.meta:SetText(quest and (quest.kind .. "  |  " .. quest.zone .. "\n" .. (hunt and "" or ("Level or skill: " .. quest.level .. "  |  ")) .. quest.source) or SelectedZone().name)
        card.story:SetText(quest and quest.description or "No objectives match your current level and known professions.")
        card.objective:SetText(quest and ("Your objective\n|cffffffff" .. objectiveText .. "|r") or "")
        card.progress:SetText(accepted and Tracking.ProgressText(quest) or (quest and not trackable and "Automatic tracking is unavailable for this objective on this client." or ""))
        card.button:SetText(not quest and "Unavailable" or (ready and "Turn In Quest" or (accepted and "Abandon Quest" or (db.activeQuest and "Unavailable" or (not trackable and "Tracking unavailable" or "Accept Quest")))))
        card.button:SetEnabled(quest ~= nil and ((accepted and (not ready or locationAllowed)) or (not db.activeQuest and locationAllowed and trackable and quest.questGiverFaction == PlayerFaction())))
        card.abandon:SetShown(not not ready)
        card.marker:SetText("")
        card:SetBackdropBorderColor(accepted and 0.9 or 0.36, accepted and 0.3 or 0.3, accepted and 0.16 or 0.16, 1)
    end
    local active = db.activeQuest
    local canEditAmount = debugMode and active ~= nil and Tracking.CanTrack(active)
    board:SetHeight(debugMode and 610 or 570)
    board.debugAmountControls:SetShown(debugMode)
    board.debugAmount:SetEnabled(canEditAmount)
    board.debugAmountApply:SetEnabled(canEditAmount)
    if board.debugAmount.quest ~= active or not board.debugAmount:HasFocus() then
        board.debugAmount:SetText(active and tostring(active.amount) or "")
        board.debugAmount.quest = active
    end
    if not debugMode then board.debugAmount:ClearFocus() end
    board.subtitle:SetShown(not debugMode)
    board.debugCategory:SetShown(debugMode)
    board.debugProgress:SetShown(debugMode)
    board.debugProgress:SetEnabled(debugMode and active ~= nil and Tracking.CanTrack(active) and active.state == "Active")
    if abandonDialog and abandonDialog:IsShown() and abandonDialog.quest ~= active then abandonDialog:Hide() end
    local hasFriendlyGiver = #EligibleGivers(SelectedZone(), "kill") > 0
    board.status:SetText(active and (active.state .. ": " .. active.title) or (#db.displayedQuests == 0 and
        (hasFriendlyGiver and ("No " .. SelectedZone().name .. " objectives match your level and professions.") or
        "No friendly quest givers are available for your faction in this zone.") or "Choose one notice to begin your adventure."))
    board.reroll:SetEnabled(active == nil)
    local notice = debugMode and "Debug Mode: accept and turn-in location requirements are bypassed."
        or resting and "Rest area: you can accept quests and turn in finished objectives here."
        or "Visit an inn, city, or other rest area to accept or turn in quests. Progress still tracks outside rest areas."
    local last = db.completedQuests and db.completedQuests[#db.completedQuests]
    local activeElsewhere = active and QuestZone(active) ~= SelectedZone()
    board.note:SetText(notice .. (activeElsewhere and ("\nYour active quest is in " .. (active.zone or "Elwynn Forest") .. ". Select that zone above to view or turn it in.")
        or last and ("\nLast completed: " .. last.title) or ""))
end

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:SetScript("OnEvent", function(self, event, loaded)
    if loaded ~= addonName then return end
    WoWForeverDB = type(WoWForeverDB) == "table" and WoWForeverDB or {}
    db = WoWForeverDB
    db.settings = type(db.settings) == "table" and db.settings or {}
    if type(db.settings.showAbandonConfirmation) ~= "boolean" then db.settings.showAbandonConfirmation = true end
    if db.minimapPositionVersion ~= 2 then
        -- Older releases saved the button at the lower-right tracking control.
        db.minimapAngle = 45
        db.minimapPositionVersion = 2
    end
    if db.generatorDataVersion ~= "0.5.0" then
        db.displayedQuests = nil
        db.generatorDataVersion = "0.5.0"
    end
    if not ValidQuest(db.activeQuest) then db.activeQuest = nil end
    if db.activeQuest then db.activeQuestId = nil end
    db.zoneOffers = type(db.zoneOffers) == "table" and db.zoneOffers or {}
    for id, zone in pairs(zones) do
        if not ValidZoneOffers(db.zoneOffers[id], zone) then db.zoneOffers[id] = nil end
    end
    -- Migrate the existing board without changing any generated objective/amount.
    local oldOffers = db.displayedQuests
    local oldZone = type(oldOffers) == "table" and type(oldOffers[1]) == "table" and QuestZone(oldOffers[1])
    if oldZone and ValidZoneOffers(oldOffers, oldZone) then db.zoneOffers[oldZone.id] = oldOffers end
    if not zones[db.selectedZone] then db.selectedZone = oldZone and oldZone.id or "elwynn" end
    -- Enrich saved notices in place before tracking resolves the vendor ID.
    -- Older Collect & Sell notices may have a non-vendor giver; assign an
    -- actual merchant without changing their objective, amount, or progress.
    local function EnrichSaved(quest)
        if not quest then return end
        local zone = QuestZone(quest)
        local categoryId = QuestCategoryId(quest)
        if zone and categoryId and (not quest.questGiverID or categoryId == "collect_sell")
            and AssignNarrative(quest, zone, categoryId) and categoryId == "collect_sell" then
            quest.objective = UpdatedObjectiveText(quest)
            quest.tracking = ResolveTracking(quest)
        end
    end
    EnrichSaved(db.activeQuest)
    for _, offers in pairs(db.zoneOffers) do
        for _, quest in ipairs(offers) do EnrichSaved(quest) end
    end
    Tracking.Initialize(db, ResolveTracking, Refresh)
    if db.activeQuest then
        local activeZone = QuestZone(db.activeQuest) or zones.elwynn
        local activeOffers = db.zoneOffers[activeZone.id]
        local found
        for index, quest in ipairs(activeOffers or {}) do
            if quest.id == db.activeQuest.id then
                activeOffers[index] = db.activeQuest -- SavedVariables restores independent tables.
                found = true
                break
            end
        end
        if not found then
            local selected = db.selectedZone
            db.selectedZone = activeZone.id
            db.zoneOffers[activeZone.id] = PickDisplayedQuests()
            db.selectedZone = selected
        end
    end
    db.displayedQuests = db.zoneOffers[db.selectedZone]
    if not ValidZoneOffers(db.displayedQuests, SelectedZone()) then db.displayedQuests = PickDisplayedQuests() end
    db.zoneOffers[db.selectedZone] = db.displayedQuests
    CreateMinimapButton()
    self:UnregisterEvent("ADDON_LOADED")
end)

SLASH_WOWFOREVERQUESTBOARD1 = "/cq"
ToggleBoard = function(wantsDebug)
    if not db then return end
    if wantsDebug then
        SetDebugMode(true, true)
        return
    end
    if not board then CreateBoard() end
    if board:IsShown() then
        board:Hide()
        return
    end
    if not ValidDisplayedQuests(db.displayedQuests) then db.displayedQuests = PickDisplayedQuests() end
    board:SetScale(math.min(1, UIParent:GetWidth() / 880, UIParent:GetHeight() / 610))
    board.debugLevelControls:SetShown(debugMode)
    board.debugButton:SetShown(debugMode)
    Refresh()
    board:Show()
end

SlashCmdList.WOWFOREVERQUESTBOARD = function(message)
    ToggleBoard(type(message) == "string" and string.lower(message) == "debug")
end

BINDING_HEADER_CLASSICQUESTBOARD = "Classic Questbook"
BINDING_NAME_CLASSICQUESTBOARD_TOGGLE = "Toggle Classic Questbook"
function ClassicQuestboardToggle() ToggleBoard(false) end

SLASH_WOWFOREVERQUESTBOARDDEBUG1 = "/cqdebug"
SlashCmdList.WOWFOREVERQUESTBOARDDEBUG = function()
    ToggleBoard(true)
end

CreateMinimapButton = function()
    if minimapButton or not Minimap then return end
    local button = CreateFrame("Button", "WoWForeverMinimapButton", Minimap)
    minimapButton = button
    button:SetSize(32, 32)
    button:SetFrameStrata("MEDIUM")
    button:SetFrameLevel(Minimap:GetFrameLevel() + 5)
    button:EnableMouse(true)
    button:RegisterForClicks("LeftButtonUp")
    button:RegisterForDrag("LeftButton")

    button.background = button:CreateTexture(nil, "BACKGROUND")
    button.background:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    button.background:SetSize(24, 24)
    button.background:SetPoint("CENTER", button, "CENTER", 0, 0)

    button.icon = button:CreateTexture(nil, "ARTWORK")
    button.icon:SetTexture("Interface\\Icons\\INV_Misc_Map_01")
    button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    button.icon:SetSize(20, 20)
    button.icon:SetPoint("CENTER", button, "CENTER", 0, 0)
    button.iconMask = button:CreateMaskTexture()
    button.iconMask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask",
        "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    button.iconMask:SetAllPoints(button.icon)
    button.icon:AddMaskTexture(button.iconMask)

    -- The tracking texture includes transparent padding on its right/bottom.
    -- Its standard TOPLEFT anchor aligns the visible ring with the 32px button.
    button.border = button:CreateTexture(nil, "OVERLAY")
    button.border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    button.border:SetSize(53, 53)
    button.border:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
    button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight", "ADD")

    local function PositionButton()
        local angle = math.rad(tonumber(db.minimapAngle) or 45)
        button:ClearAllPoints()
        button:SetPoint("CENTER", Minimap, "CENTER",
            math.cos(angle) * (Minimap:GetWidth() / 2 + 8),
            math.sin(angle) * (Minimap:GetHeight() / 2 + 8))
    end
    local function UpdateDrag()
        local centerX, centerY = Minimap:GetCenter()
        if not centerX or not centerY then return end
        local x, y = GetCursorPosition()
        local scale = Minimap:GetEffectiveScale()
        x, y = x / scale - centerX, y / scale - centerY
        if x ~= 0 or y ~= 0 then
            db.minimapAngle = math.deg(math.atan2(y, x)) % 360
            PositionButton()
        end
    end
    local function StopDrag(self)
        self:SetScript("OnUpdate", nil)
        self.dragging = false
    end

    button:SetScript("OnMouseDown", function(self) self.suppressClick = false end)
    button:SetScript("OnClick", function(self)
        if self.suppressClick then
            self.suppressClick = false
            return
        end
        ToggleBoard(false)
    end)
    button:SetScript("OnEnter", function(self)
        if self.dragging then return end
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("Classic Questbook")
        GameTooltip:AddLine("Click to open the questboard", 1, 1, 1)
        GameTooltip:AddLine("Drag to reposition this button", 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)
    button:SetScript("OnDragStart", function(self)
        self.dragging, self.suppressClick = true, true
        GameTooltip:Hide()
        self:SetScript("OnUpdate", UpdateDrag)
        UpdateDrag()
    end)
    button:SetScript("OnDragStop", function(self)
        UpdateDrag()
        StopDrag(self)
    end)
    button:SetScript("OnHide", function(self)
        StopDrag(self)
        if GameTooltip:GetOwner() == self then GameTooltip:Hide() end
    end)
    button:SetScript("OnShow", PositionButton)
    PositionButton()
end
