--[[
    Global Values
--]]

-- SPRITES
spr_fishing_spot = nil;
spr_fishing_lure = nil;
spr_trident = nil;

-- GLOBALS
TICK_NUM = 0; -- custom tick count

frm_fishing_spot = 0; -- Animate fishing spot - frame counter

ROD_STATE = 0; -- Store casting state, READY, CASTING, CASTED, REELING
NOT_EQUIPPED = 0;
READY = 1;
CASTING = 2;
CASTED = 3;
REELING = 4;
CATCHING = 5;

equipped_rod = "";

click_pos_x = 0; -- pos to track where a player clicked to cast
click_pos_y = 0;

lure_pos_x = 0; -- pos to track lure while casting is in progress
lure_pos_y = 0;
lure_bob = 0;
lure_nearby_fishing_spots = 0;

-- Number of each item type defined
num_junk_items = 0; 
num_fish_items = 0;
num_bait_items = 0;
num_rod_items = 0;

catch_ticks = 0; -- Store when the catch event was started to check if the player clicked in time

-- Define our fishing rods
fishing_rods = {

    ["rod0"] = {    name = "Wooden Rod", tooltip = "Grandad's old wooden fishing rod", cost = 100,
                    line_length = 60, catch_time = 10, catch_chance = 4, fish_chance = 30,
                    available_fish = {
                        { id = "fish0", chance_s = 0, chance_e = 40}, -- Guppy *
                        { id = "fish1", chance_s = 41, chance_e = 70}, -- Sardine *
                        { id = "fish5", chance_s = 71, chance_e = 80}, -- Crab **
                        { id = "fish6", chance_s = 81, chance_e = 100} -- Prawn *
                    }};

    ["rod1"] = {    name = "Lightweight Rod", tooltip = "Modern aluminium fishing rod", cost = 1000,
                    line_length = 75, catch_time = 12, catch_chance = 6, fish_chance = 40,
                    available_fish = {
                        { id = "fish0", chance_s = 0, chance_e = 20 }, -- Guppy
                        { id = "fish1", chance_s = 21, chance_e = 40 }, -- Sardine
                        { id = "fish4", chance_s = 41, chance_e = 60}, -- Mackerel *
                        { id = "fish5", chance_s = 61, chance_e = 80}, -- Crab
                        { id = "fish6", chance_s = 81, chance_e = 95}, -- Prawn
                        { id = "fish7", chance_s = 96, chance_e = 100} -- Lobster **
                    }};

    ["rod2"] = {    name = "Diamond Rod", tooltip = "Premium, diamond standard fishing rod", cost = 10000,
                    line_length = 100, catch_time = 15, catch_chance = 8, fish_chance = 50,
                    available_fish = {
                        { id = "fish0", chance_s = 0, chance_e = 15 }, -- Guppy
                        { id = "fish1", chance_s = 16, chance_e = 30 }, -- Sardine
                        { id = "fish2", chance_s = 31, chance_e = 40 }, -- Octopus *
                        { id = "fish3", chance_s = 41, chance_e = 50 }, -- Sea Snake *
                        { id = "fish4", chance_s = 51, chance_e = 60}, -- Mackerel
                        { id = "fish5", chance_s = 61, chance_e = 70}, -- Crab
                        { id = "fish6", chance_s = 71, chance_e = 80}, -- Prawn
                        { id = "fish7", chance_s = 81, chance_e = 95}, -- Lobster
                        { id = "fish8", chance_s = 96, chance_e = 100} -- Pufferfish **
                    }};

    ["rod3"] = {    name = "Uranium Rod", tooltip = "Uranium enriched fishing rod", cost = 20000,
                    line_length = 125, catch_time = 18, catch_chance = 10, fish_chance = 60,
                    available_fish = {
                        { id = "fish0", chance_s = 0, chance_e = 10 }, -- Guppy
                        { id = "fish1", chance_s = 11, chance_e = 20 }, -- Sardine
                        { id = "fish2", chance_s = 21, chance_e = 30 }, -- Octopus
                        { id = "fish3", chance_s = 31, chance_e = 40 }, -- Sea Snake
                        { id = "fish4", chance_s = 41, chance_e = 50}, -- Mackerel
                        { id = "fish5", chance_s = 51, chance_e = 60}, -- Crab
                        { id = "fish6", chance_s = 61, chance_e = 70}, -- Prawn
                        { id = "fish7", chance_s = 71, chance_e = 80}, -- Lobster
                        { id = "fish8", chance_s = 81, chance_e = 90}, -- Pufferfish
                        { id = "fish9", chance_s = 91, chance_e = 95}, -- Glowfish **
                        { id = "fish10", chance_s = 96, chance_e = 100} -- Lionfish **
                    }};

    ["rod4"] = {    name = "Rainbow Rod", tooltip = "Nanobii's legendary fishing rod", cost = 50000,
                    line_length = 150, catch_time = 20, catch_chance = 15, fish_chance = 70,
                    available_fish = {
                        { id = "fish0", chance_s = 0, chance_e = 5 }, -- Guppy
                        { id = "fish1", chance_s = 6, chance_e = 10 }, -- Sardine
                        { id = "fish2", chance_s = 11, chance_e = 20}, -- Octopus
                        { id = "fish3", chance_s = 21, chance_e = 30 }, -- Sea Snake
                        { id = "fish4", chance_s = 31, chance_e = 35}, -- Mackerel
                        { id = "fish5", chance_s = 36, chance_e = 45}, -- Crab
                        { id = "fish6", chance_s = 46, chance_e = 55}, -- Prawn
                        { id = "fish7", chance_s = 56, chance_e = 65}, -- Lobster
                        { id = "fish8", chance_s = 66, chance_e = 75}, -- Pufferfish
                        { id = "fish9", chance_s = 76, chance_e = 85}, -- Glowfish
                        { id = "fish10", chance_s = 86, chance_e = 95}, -- Lionfish
                        { id = "fish11", chance_s = 96, chance_e = 100} -- Fossil **
                    }};
};

-- Define our junk items
junk_items = {

    ["junk0"] = { name = "Seaweed",
                  tooltip = "Slimy green vegetation", sell_price = 10 };

    ["junk1"] = { name = "Broken Rod",
                  tooltip = "Useless broken fishing rod", sell_price = 10 };

    ["junk2"] = { name = "Rusty Sword",
                  tooltip = "A distant memory of the honey wars of old", sell_price = 10 };
                  
    ["junk3"] = { name = "Slimy Rock",
                  tooltip = "Shiny clear stone covered in seaweed, worthless", sell_price = 10 };

    ["junk4"] = { name = "Old Rubber",
                  tooltip = "A pile of old rubber", sell_price = 10 };

    ["junk5"] = { name = "Golden Key",
                  tooltip = "Ancient key that vibrates slightly when held, probably doesn't unlock anything useful", sell_price = 10 };

    ["junk6"] = { name = "Old Boots",
                  tooltip = "Grandad's old boots", sell_price = 10 };

    ["junk7"] = { name = "Ruined Book",
                  tooltip = "A ruined copy of Tales to Astonish #70", sell_price = 10 };

    ["junk8"] = { name = "Anchor",
                  tooltip = "Old shop anchor, not as heavy as it should be", sell_price = 10 };
};

-- Define our bait items
bait_items = {

    ["bait0"] = { name = "Bread Crumbs",
                  tooltip = "Small chunks of crusty bread, increases chances of catching fish slightly", cost = 1 };

    ["bait1"] = { name = "Small Worms",
                  tooltip = "Small wriggly worms, increases chances of attracting fish", cost = 2 };

    ["bait2"] = { name = "Large Worms",
                  tooltip = "Large wriggly worms, increases chances of attracting fish greatly", cost = 3 };

    ["bait3"] = { name = "Exotic Worms",
                  tooltip = "Exotic wriggly worms, guarantees attracting a fish everytime", cost = 5 };
};


-- Define our fish
fish_items = {

    ["fish0"] = { name = "Guppy",
                  tooltip = "A small and tasty fish", sell_price = 10 };

    ["fish1"] = { name = "Sardine",
                  tooltip = "A small and tasty fish", sell_price = 20 };

    ["fish2"] = { name = "Octopus",
                  tooltip = "Clever and tricky to catch", sell_price = 30 };

    ["fish3"] = { name = "Sea Snake",
                  tooltip = "Wait, this isn't a fish?", sell_price = 40 };

    ["fish4"] = { name = "Mackerel",
                  tooltip = "A large and tasty fish", sell_price = 50 };

    ["fish5"] = { name = "Crab",
                  tooltip = "A fiesty crustacean with snapping claws", sell_price = 60 };

    ["fish6"] = { name = "Prawn",
                  tooltip = "A small and tasty shellfish", sell_price = 70 };

    ["fish7"] = { name = "Lobster",
                  tooltip = "A classic and well sought after fish", sell_price = 80 };

    ["fish8"] = { name = "Pufferfish",
                  tooltip = "A big and exciting fish", sell_price = 90 };

    ["fish9"] = { name = "Glowfish",
                  tooltip = "A strange and elusive fish", sell_price = 100 };

    ["fish10"] = { name = "Lionfish",
                  tooltip = "Poisonous, but nutritious when prepared carefully", sell_price = 120 };

    ["fish11"] = { name = "Fossil",
                  tooltip = "An ancient and rare fossil", sell_price = 150 };
};

--[[]
    End of Global Values
--]]