--[[
    Global Values
--]] -- SPRITES
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
lure_biome = "";

-- Number of each item type defined
num_junk_items = 0;
num_fish_items = 0;
num_bait_items = 0;
num_rod_items = 0;

catch_ticks = 0; -- Store when the catch event was started to check if the player clicked in time

active_fishing_spots = 0; -- How many fishing spots are active on the screen, used to check if we need to spawn one
fishing_spot_ids = {};

-- Add globals for the fish types just to make it easier to define rod tables
GUPPY = "fish0";
SARDINE = "fish1";
OCTOPUS = "fish2";
SEA_SNAKE = "fish3";
MACKEREL = "fish4";
CRAB = "fish5";
PRAWN = "fish6";
LOBSTER = "fish7";
PUFFER_FISH = "fish8";
GLOW_FISH = "fish9";
LION_FISH = "fish10";
FOSSIL = "fish11";
FLOUNDER = "fish12";
TOWER_SHELL = "fish13";
DAB = "fish14";
SQUID = "fish15";
SUN_FISH = "fish16";
JELLY_FISH = "fish17";
STAR_FISH = "fish18";
PARROT_FISH = "fish19";
ANGEL_FISH = "fish20";

-- Define our fishing rods
fishing_rods = {

    ["rod0"] = {
        name = "Wooden Rod",
        tooltip = "Grandad's old wooden fishing rod",
        cost = 100,
        line_length = 60,
        catch_time = 10,
        catch_chance = 4,
        fish_chance = 30,
        available_fish = {

            ["forest"] = {[GUPPY] = 40, [SARDINE] = 40, [PRAWN] = 20},

            ["swamp"]  = {[GUPPY] = 40, [SARDINE] = 40, [SEA_SNAKE] = 20},

            ["tundra"] = {[GUPPY] = 40, [SARDINE] = 40, [CRAB] = 20},

            ["hallow"] = {[GUPPY] = 40, [SARDINE] = 40, [TOWER_SHELL] = 20}
        }
    },

    ["rod1"] = {
        name = "Lightweight Rod",
        tooltip = "Modern aluminium fishing rod",
        cost = 1000,
        line_length = 80,
        catch_time = 12,
        catch_chance = 6,
        fish_chance = 40,
        available_fish = {

            ["forest"] = {[GUPPY] = 30, [SARDINE] = 30, [PRAWN] = 30, [MACKEREL] = 10},

            ["swamp"]  = {[GUPPY] = 30, [SARDINE] = 40, [SEA_SNAKE] = 30, [LION_FISH] = 10},

            ["tundra"] = {[GUPPY] = 30, [SARDINE] = 30, [CRAB] = 30, [LOBSTER] = 10},

            ["hallow"] = {[GUPPY] = 30, [SARDINE] = 30, [TOWER_SHELL] = 30, [SQUID] = 10}
        }
    },

    ["rod2"] = {
        name = "Diamond Rod",
        tooltip = "Premium, diamond standard fishing rod",
        cost = 3000,
        line_length = 110,
        catch_time = 15,
        catch_chance = 8,
        fish_chance = 50,
        available_fish = {

            ["forest"] = {[GUPPY] = 25, [SARDINE] = 25, [PRAWN] = 25, [MACKEREL] = 15, [SUN_FISH] = 10},

            ["swamp"] = {[GUPPY] = 25, [SARDINE] = 25, [SEA_SNAKE] = 25, [LION_FISH] = 15, [DAB] = 10},

            ["tundra"] = {[GUPPY] = 25, [SARDINE] = 25, [CRAB] = 25, [LOBSTER] = 15, [JELLY_FISH] = 10},

            ["hallow"] = {[GUPPY] = 25, [SARDINE] = 25, [TOWER_SHELL] = 25, [SQUID] = 15, [OCTOPUS] = 10}
        }
    },

    ["rod3"] = {
        name = "Uranium Rod",
        tooltip = "Uranium enriched fishing rod",
        cost = 6000,
        line_length = 150,
        catch_time = 18,
        catch_chance = 10,
        fish_chance = 60,
        available_fish = {

            ["forest"] = {[GUPPY] = 15, [SARDINE] = 15, [PRAWN] = 20, [MACKEREL] = 20, [SUN_FISH] = 20, [PARROT_FISH] = 10},

            ["swamp"]  = {[GUPPY] = 15, [SARDINE] = 15, [SEA_SNAKE] = 20, [LION_FISH] = 20, [DAB] = 20, [PUFFER_FISH] = 10},

            ["tundra"] = {[GUPPY] = 15, [SARDINE] = 15, [CRAB] = 20, [LOBSTER] = 20, [JELLY_FISH] = 20, [FLOUNDER] = 10},

            ["hallow"] = {[GUPPY] = 15, [SARDINE] = 15, [TOWER_SHELL] = 20, [SQUID] = 20, [OCTOPUS] = 20, [GLOW_FISH] = 10}
        }
    },

    ["rod4"] = {
        name = "Rainbow Rod",
        tooltip = "Nanobii's legendary fishing rod",
        cost = 9999,
        line_length = 220,
        catch_time = 20,
        catch_chance = 15,
        fish_chance = 70,
        available_fish = {

            ["forest"] = {[GUPPY] = 10, [SARDINE] = 10, [PRAWN] = 10, [MACKEREL] = 15, [SUN_FISH] = 20, [PARROT_FISH] = 20, [ANGEL_FISH] = 10, [FOSSIL] = 5},

            ["swamp"]  = {[GUPPY] = 10, [SARDINE] = 10, [SEA_SNAKE] = 10, [LION_FISH] = 15, [DAB] = 25, [PUFFER_FISH] = 25, [FOSSIL] = 5},

            ["tundra"] = {[GUPPY] = 10, [SARDINE] = 10, [CRAB] = 10, [LOBSTER] = 15, [JELLY_FISH] = 25, [FLOUNDER] = 25, [STAR_FISH] = 10, [FOSSIL] = 5},

            ["hallow"] = {[GUPPY] = 10, [SARDINE] = 10, [TOWER_SHELL] = 10, [SQUID] = 15, [OCTOPUS] = 25, [GLOW_FISH] = 25, [FOSSIL] = 5}
        }
    }
};

-- Define our junk items
junk_items = {

    ["junk0"] = {
        name = "Seaweed",
        tooltip = "Slimy green vegetation",
        sell_price = 1
    },

    ["junk1"] = {
        name = "Broken Rod",
        tooltip = "Useless broken fishing rod",
        sell_price = 1
    },

    ["junk2"] = {
        name = "Rusty Sword",
        tooltip = "A distant memory of the honey wars of old",
        sell_price = 1
    },

    ["junk3"] = {
        name = "Slimy Rock",
        tooltip = "Shiny clear stone covered in seaweed, worthless",
        sell_price = 1
    },

    ["junk4"] = {
        name = "Old Rubber",
        tooltip = "A pile of old rubber",
        sell_price = 1
    },

    ["junk5"] = {
        name = "Golden Key",
        tooltip = "Ancient key that vibrates slightly when held, probably doesn't unlock anything useful",
        sell_price = 1
    },

    ["junk6"] = {
        name = "Old Boots",
        tooltip = "Grandad's old boots",
        sell_price = 1
    },

    ["junk7"] = {
        name = "Ruined Book",
        tooltip = "A ruined copy of Tales to Astonish #70",
        sell_price = 1
    },

    ["junk8"] = {
        name = "Anchor",
        tooltip = "Old shop anchor, not as heavy as it should be",
        sell_price = 1
    },

    ["junk9"] = {
        name = "Fish Skeleton",
        tooltip = "The remains of a dead fish",
        sell_price = 1
    }
};

-- Define our bait items
bait_items = {

    ["bait0"] = {
        name = "Bread Crumbs",
        tooltip = "Small chunks of crusty bread, slight chance of attracting fish",
        cost = 1
    },

    ["bait1"] = {
        name = "Small Worms",
        tooltip = "Small wriggly worms, small chance of attracting fish",
        cost = 1
    },

    ["bait2"] = {
        name = "Large Worms",
        tooltip = "Large wriggly worms, good chance of attracting fish",
        cost = 3
    },

    ["bait3"] = {
        name = "Exotic Worms",
        tooltip = "Exotic wriggly worms, almost guaranteed to attract fish",
        cost = 5
    }
};

-- Define our fish
fish_items = {

    --[[
        NO BIOME FISH
    --]]

    [GUPPY] = {
        name = "Guppy",
        tooltip = "A small and tasty fish",
        sell_price = 2
    },

    [SARDINE] = {
        name = "Sardine",
        tooltip = "A small and tasty fish",
        sell_price = 2
    },

    [FOSSIL] = {
        name = "Fossil",
        tooltip = "An ancient and rare fossil",
        sell_price = 50
    },



    --[[
        FOREST FISH
    --]]

    [PRAWN] = {
        name = "Prawn",
        tooltip = "A small and tasty shellfish",
        sell_price = 5
    },

    [MACKEREL] = {
        name = "Mackerel",
        tooltip = "A large and tasty fish, popular for its oil",
        sell_price = 10
    },

    [SUN_FISH] = {
        name = "Sun Fish",
        tooltip = "A massive and bright fish with rainbow underbelly scales",
        sell_price = 15
    },

    [PARROT_FISH] = {
        name = "Parrot Fish",
        tooltip = "A bright and attractive fish with intricate patterns on its body",
        sell_price = 20
    },

    [ANGEL_FISH] = {
        name = "Angel Fish",
        tooltip = "A very popular freshwater aquariam fish due to its majestic appearance and ease of care",
        sell_price = 25
    },


    --[[
        SWAMP FISH
    --]]

    [SEA_SNAKE] = {
        name = "Sea Snake",
        tooltip = "Wait, this isn't a fish?",
        sell_price = 5
    },

    [LION_FISH] = {
        name = "Lionfish",
        tooltip = "Venomous marine fish, but nutritious when prepared carefully",
        sell_price = 10
    },

    [DAB] = {
        name = "Dab",
        tooltip = "A tasty flatfish that lives on sandy bottoms",
        sell_price = 15
    },

    [PUFFER_FISH] = {
        name = "Pufferfish",
        tooltip = "A big and exciting fish",
        sell_price = 20
    },

    


    --[[
        TUNDRA FISH
    --]]
    [CRAB] = {
        name = "Crab",
        tooltip = "A fiesty crustacean with snapping claws",
        sell_price = 5
    },

    [LOBSTER] = {
        name = "Lobster",
        tooltip = "A classic and well sought after fish",
        sell_price = 10
    },

    [JELLY_FISH] = {
        name = "Jellyfish",
        tooltip = "A gelatinous and bioluminescent creature with trailing tentacles",
        sell_price = 15
    },

    [FLOUNDER] = {
        name = "Flounder",
        tooltip = "An modestly sized fish with an unusual flat shape",
        sell_price = 20
    },

    [STAR_FISH] = {
        name = "Starfish",
        tooltip = "Beautiful marine creature found in a variaty of shapes, colours and sizes",
        sell_price = 25
    },


    --[[
        HALLOW FISH
    --]]

    [TOWER_SHELL] = {
        name = "Tower Shell",
        tooltip = "The shell of a medium-sized sea snail",
        sell_price = 5
    },

    [SQUID] = {
        name = "Squid",
        tooltip = "A strange creature with an elongated body, large eyes and ten appendages",
        sell_price = 10
    },

    [OCTOPUS] = {
        name = "Octopus",
        tooltip = "Clever and tricky to catch",
        sell_price = 15
    },

    [GLOW_FISH] = {
        name = "Glowfish",
        tooltip = "A strange and elusive fish",
        sell_price = 20
    },

};

--[[]
    End of Global Values
--]]
