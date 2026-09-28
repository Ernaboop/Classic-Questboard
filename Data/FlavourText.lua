local _, ns = ...
local Database = ns.Database

for _, line in ipairs({
    {id = "ds_story_kill_1", category = "kill", text = "The road lamps are lit, but the shadows keep moving. Clear a path before the next caravan leaves Auberdine."},
    {id = "ds_story_kill_2", category = "kill", text = "The coast sends back fewer travelers each evening. Give the watch one stretch of shore it can trust."},
    {id = "ds_story_supply_1", category = "supply", text = "Every hull that reaches Auberdine carries less than we ordered. Salvage what the wilds surrender and bring it to my counter."},
    {id = "ds_story_supply_2", category = "supply", text = "The sea takes its share of our stock. Find something worth trading and I will make sure it feeds the town."},
    {id = "ds_story_hunt_1", category = "hunt", text = "The sentinels have a name for the shape stalking the treeline. They would rather speak it in the past tense."},
    {id = "ds_story_hunt_2", category = "hunt", text = "Ordinary patrols have turned back. Follow the tracks they left untouched and finish the work."},
    {id = "ds_story_herbalism", category = "gather", profession = "herbalism", text = "The healers have exhausted their satchels. Search the damp woods for what the soil still offers."},
    {id = "ds_story_mining", category = "gather", profession = "mining", text = "Salt air has eaten through our fittings. Bring back ore before the next boat finds a loose mooring."},
    {id = "ds_story_skinning", category = "gather", profession = "skinning", text = "The sentinels' cloaks are wearing thin. Good hides will keep the night watch warm."},
    {id = "ds_story_fishing", category = "gather", profession = "fishing", text = "The boats have returned with empty nets. A patient line may yet put supper on the table."},
}) do
    line.zone = "darkshore"
    Database:RegisterFlavour(line)
end

-- Westfall stories are original addon prose keyed to the same categories.
for _, line in ipairs({
    {id = "wf_story_kill_1", category = "kill", text = "The militia is stretched thin. One quiet road tonight would mean a great deal to the families still here."},
    {id = "wf_story_kill_2", category = "kill", text = "Another farm has gone silent. See what is prowling between the fields before the sun sets."},
    {id = "wf_story_supply_1", category = "supply", text = "Our shelves are nearly empty; bring what the troublemakers leave behind and I'll turn it into coin for the locals."},
    {id = "wf_story_supply_2", category = "supply", text = "A trader can make use of salvage others would leave in the dust. Bring it to my counter."},
    {id = "wf_story_hunt_1", category = "hunt", text = "There is a name whispered at every campfire. Find the creature behind it before someone else becomes the story."},
    {id = "wf_story_hunt_2", category = "hunt", text = "The ordinary patrols cannot spare hands for this one. Track the menace and come back with proof."},
    {id = "wf_story_herbalism", category = "gather", profession = "herbalism", text = "The last clean field is worth guarding, and every healing herb you find will help."},
    {id = "wf_story_mining", category = "gather", profession = "mining", text = "If the smith's hammer is going to ring tomorrow, we need metal from the hills today."},
    {id = "wf_story_skinning", category = "gather", profession = "skinning", text = "Good leather keeps a militiaman's boots together longer than another speech will."},
    {id = "wf_story_fishing", category = "gather", profession = "fishing", text = "The dry fields will not feed everyone. See what the water has to spare."},
}) do
    line.zone = "westfall"
    Database:RegisterFlavour(line)
end

-- Original addon flavour, not dialogue quoted from Blizzard NPCs.
-- Add a new permanent ID for each new line.

Database:RegisterFlavour({
    id = "flavour_kill_1",
    category = "kill",
    text = "The roads have grown dangerous; give the locals a reason to travel again.",
})

Database:RegisterFlavour({
    id = "flavour_kill_2",
    category = "kill",
    text = "Another traveler came in shaken. See that the trouble does not follow them home.",
})

Database:RegisterFlavour({
    id = "flavour_kill_3",
    category = "kill",
    text = "The watch is stretched thin, and someone must deal with the threat beyond the lamps.",
})

Database:RegisterFlavour({
    id = "flavour_kill_4",
    category = "kill",
    text = "Farmers are keeping their doors barred. Clear the danger before the next supply run.",
})

Database:RegisterFlavour({
    id = "flavour_supply_1",
    category = "supply",
    text = "A trader will pay for useful spoils, but someone has to brave the wilds first.",
})

Database:RegisterFlavour({
    id = "flavour_supply_2",
    category = "supply",
    text = "The market shelves are bare. Bring back what you can and turn it into coin.",
})

Database:RegisterFlavour({
    id = "flavour_supply_3",
    category = "supply",
    text = "Even the scraps left by troublemakers have value to a careful merchant.",
})

Database:RegisterFlavour({
    id = "flavour_supply_4",
    category = "supply",
    text = "A local buyer has asked for fresh stock; gather it before another caravan does.",
})

Database:RegisterFlavour({
    id = "flavour_hunt_1",
    category = "hunt",
    text = "Whispers of a dangerous creature have reached the inn. Find the truth behind them.",
})

Database:RegisterFlavour({
    id = "flavour_hunt_2",
    category = "hunt",
    text = "The watch has a name, a trail, and too few hands to follow it.",
})

Database:RegisterFlavour({
    id = "flavour_hunt_3",
    category = "hunt",
    text = "Something formidable is stalking the outskirts. End the tale before it claims another victim.",
})

Database:RegisterFlavour({
    id = "flavour_hunt_4",
    category = "hunt",
    text = "A reward has been promised to anyone bold enough to face this menace.",
})

Database:RegisterFlavour({
    id = "flavour_herbalism_1",
    category = "gather",
    profession = "herbalism",
    text = "The apothecary's jars are nearly empty; fresh herbs could spare a long journey.",
})

Database:RegisterFlavour({
    id = "flavour_herbalism_2",
    category = "gather",
    profession = "herbalism",
    text = "A healer needs plants gathered before the morning dew gives way to frost.",
})

Database:RegisterFlavour({
    id = "flavour_herbalism_3",
    category = "gather",
    profession = "herbalism",
    text = "The local remedies are running low. Search the wilds for the next batch.",
})

Database:RegisterFlavour({
    id = "flavour_herbalism_4",
    category = "gather",
    profession = "herbalism",
    text = "Some leaves are worth more than silver when a sick neighbor needs them.",
})

Database:RegisterFlavour({
    id = "flavour_mining_1",
    category = "gather",
    profession = "mining",
    text = "The forge burns bright, but its ore bins are almost bare. Bring back a fresh haul.",
})

Database:RegisterFlavour({
    id = "flavour_mining_2",
    category = "gather",
    profession = "mining",
    text = "A smith has a stack of repairs and scarcely enough metal for a horseshoe.",
})

Database:RegisterFlavour({
    id = "flavour_mining_3",
    category = "gather",
    profession = "mining",
    text = "The next caravan needs sound fittings; the miners must keep the anvils ringing.",
})

Database:RegisterFlavour({
    id = "flavour_mining_4",
    category = "gather",
    profession = "mining",
    text = "Pickaxes are wanted in the hills. The smith will put every usable stone to work.",
})

Database:RegisterFlavour({
    id = "flavour_skinning_1",
    category = "gather",
    profession = "skinning",
    text = "The leatherworker has orders to fill and more empty racks than hides.",
})

Database:RegisterFlavour({
    id = "flavour_skinning_2",
    category = "gather",
    profession = "skinning",
    text = "Boots and packs wear thin on these roads; sturdy leather will keep travelers moving.",
})

Database:RegisterFlavour({
    id = "flavour_skinning_3",
    category = "gather",
    profession = "skinning",
    text = "A tanner is waiting on fresh hides before the next caravan departs.",
})

Database:RegisterFlavour({
    id = "flavour_skinning_4",
    category = "gather",
    profession = "skinning",
    text = "The town's straps and saddles need mending. Bring in hides fit for the work.",
})

Database:RegisterFlavour({
    id = "flavour_fishing_1",
    category = "gather",
    profession = "fishing",
    text = "The inn's supper pot is hungry, and the fish have yet to volunteer.",
})

Database:RegisterFlavour({
    id = "flavour_fishing_2",
    category = "gather",
    profession = "fishing",
    text = "A cook has promised a feast with nothing left in the fish basket.",
})

Database:RegisterFlavour({
    id = "flavour_fishing_3",
    category = "gather",
    profession = "fishing",
    text = "The morning catch was meager. Cast a line before the guests notice.",
})

Database:RegisterFlavour({
    id = "flavour_fishing_4",
    category = "gather",
    profession = "fishing",
    text = "Fresh fish would be welcome at the table after a long day on the road.",
})
