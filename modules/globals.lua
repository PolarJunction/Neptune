--[[
    Global Values
--]]

-- SPRITES
spr_fishing_spot = nil;
spr_fishing_rod = nil;
spr_fishing_lure = nil;
spr_trident = nil;

-- GLOBALS
TICK_NUM = 0; -- custom tick count

frm_fishing_spot = 0; -- Animate fishing spot - frame counter

ROD_STATE = 0; -- Store casting state, READY, CASTING, CASTED, REELING
READY = 0;
CASTING = 1;
CASTED = 2;
REELING = 3;
CATCHING = 4;

equipped_rod = "";

click_pos_x = 0; -- pos to track where a player clicked to cast
click_pos_y = 0;

lure_pos_x = 0; -- pos to track lure while casting is in progress
lure_pos_y = 0;
lure_bob = 0;
lure_nearby_fishing_spots = 0;

catch_ticks = 0; -- Store when the catch event was started to check if the player clicked in time

-- Define our fishing rods
fishing_rods = {
    ["rod0"] = {    name = "Wooden Rod", tooltip = "Grandad's old wooden fishing rod", cost = 100,
                    line_length = 70, catch_time = 10, catch_chance = 4, fish_chance = 70,
                    fish = {
                        { id = "fish0", chance_s = 0, chance_e = 10},
                        { id = "fish1", chance_s = 10, chance_e = 100}
                    }};

    ["rod1"] = {    name = "Lightweight Rod", tooltip = "Modern aluminium fishing rod", cost = 1000,
                    line_length = 80, catch_time = 12, catch_chance = 6, fish_chance = 75,
                    fish = {
                        { id = "fish0", chance_s = 0, chance_e = 10 },
                        { id = "fish1", chance_s = 10, chance_e = 100 }
                    }};

    ["rod2"] = {    name = "Diamond Rod", tooltip = "Premium, diamond standard fishing rod", cost = 10000,
                    line_length = 90, catch_time = 15, catch_chance = 8, fish_chance = 80,
                    fish = {
                        { id = "fish0", chance_s = 0, chance_e = 10 },
                        { id = "fish1", chance_s = 10, chance_e = 100 }
                    }};

    ["rod3"] = {    name = "Uranium Rod", tooltip = "Uranium enriched fishing rod", cost = 20000,
                    line_length = 100, catch_time = 18, catch_chance = 10, fish_chance = 85,
                    fish = {
                        { id = "fish0", chance_s = 0, chance_e = 10 },
                        { id = "fish1", chance_s = 10, chance_e = 100 }
                    }};

    ["rod4"] = {    name = "Rainbow Rod", tooltip = "Nanobii's legendary fishing rod", cost = 50000,
                    line_length = 120, catch_time = 20, catch_chance = 15, fish_chance = 90,
                    fish = {
                        { id = "fish0", chance_s = 0, chance_e = 10 },
                        { id = "fish1", chance_s = 10, chance_e = 100 }
                    }};
};

-- Define our junk items
junk_items = {};

junk_items[1] = { id = "junk0",
                  name = "Seaweed", tooltip = "Slimy green vegetation", sell_price = 10 };
junk_items[2] = { id = "junk1",
                  name = "Broken Rod", tooltip = "Useless broken fishing rod", sell_price = 10 };
junk_items[3] = { id = "junk2",
                  name = "Rusty Sword", tooltip = "A distant memory of the honey wars of old", sell_price = 10 };
junk_items[4] = { id = "junk3",
                  name = "Slimy Rock", tooltip = "Shiny clear stone covered in seaweed, worthless", sell_price = 10 };
junk_items[5] = { id = "junk4",
                  name = "Old Rubber", tooltip = "A pile of old rubber", sell_price = 10 };
junk_items[6] = { id = "junk5",
                  name = "Golden Key", tooltip = "Ancient key that vibrates slightly when held, probably doesn't unlock anything useful", sell_price = 10 };
junk_items[7] = { id = "junk6",
                  name = "Old Boots", tooltip = "Grandad's old boots", sell_price = 10 };
junk_items[8] = { id = "junk7",
                  name = "Ruined Book", tooltip = "A ruined copy of Tales to Astonish #70", sell_price = 10 };
junk_items[9] = { id = "junk8",
                  name = "Anchor", tooltip = "Old shop anchor, not as heavy as it should be", sell_price = 10 };


-- Define our bait items
bait_items = {};

bait_items[1] = { id = "bait0",
                  name = "Bread Crumbs", tooltip = "Small chunks of crusty bread, increases chances of catching fish slightly", cost = 10 };
bait_items[2] = { id = "bait1",
                  name = "Small Worms", tooltip = "Small wriggly worms, increases chances of attracting fish", cost = 20 };
bait_items[3] = { id = "bait2",
                  name = "Large Worms", tooltip = "Large wriggly worms, increases chances of attracting fish greatly", cost = 30 };
bait_items[4] = { id = "bait3",
                  name = "Exotic Worms", tooltip = "Exotic wriggly worms, guarantees attracting a fish everytime", cost = 40 };


-- Define our fish
fish = {};

fish[1] = { id = "fish0",
            name = "Guppy", tooltip = "A small and tasty fish", sell_price = 10 };
fish[2] = { id = "fish1",
            name = "Sardine", tooltip = "A small and tasty fish", sell_price = 20 };
fish[3] = { id = "fish2",
            name = "Octopus", tooltip = "Clever and tricky to catch", sell_price = 30 };
fish[4] = { id = "fish3",
            name = "Sea Snake", tooltip = "Wait, this isn't a fish?", sell_price = 40 };
fish[5] = { id = "fish4",
            name = "Mackerel", tooltip = "A large and tasty fish", sell_price = 50 };
fish[6] = { id = "fish5",
            name = "Crab", tooltip = "A fiesty crustacean with snapping claws", sell_price = 60 };
fish[7] = { id = "fish6",
            name = "Prawn", tooltip = "A small and tasty shellfish", sell_price = 70 };
fish[8] = { id = "fish7",
            name = "Lobster", tooltip = "A classic and well sought after fish", sell_price = 80 };
fish[9] = { id = "fish8",
            name = "Pufferfish", tooltip = "A big and exciting fish", sell_price = 90 };
fish[10] = { id = "fish9",
            name = "Glowfish", tooltip = "A strange and elusive fish", sell_price = 100 };
fish[11] = { id = "fish10",
            name = "Lionfish", tooltip = "Poisonous, but nutritious when prepared carefully", sell_price = 120 };
fish[12] = { id = "fish11",
            name = "Fossil", tooltip = "An ancient and rare fossil", sell_price = 150 };


--[[]
    End of Global Values
--]]