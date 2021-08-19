
--[[
  Name: register()
  Desc: Register our mod name and hook into game events
  Params: N/A
  Return: N/A
--]]
function register()
    -- register our mod name and the hooks we want
    return {
        name = "Neptune",
        hooks = {"clock", "key", "draw", "tick", "click", "ready"},
        modules = {"utility", "globals", "fishing"}
    }
end --register()


--[[
    Name: init()
    Desc: Game hook, called before starting, initialise items/sprites/objects etc
    Params: N/A
    Return: String - to indicate "Success"
--]]
function init()
    -- init the mod
    api_set_devmode(true);

    -- Define all of the catch-able fish
    v_define_fish("fish0",  "Guppy",       "A small and tasty fish.", 10);
    v_define_fish("fish1",  "Sardine",     "A small and tasty fish.", 10);
    v_define_fish("fish2",  "Octopus",     "Clever and tricky to catch.", 10);
    v_define_fish("fish3",  "Sea Snake",   "Wait, this isn't a fish?", 10);
    v_define_fish("fish4",  "Mackerel",    "A small and tasty fish.", 10);
    v_define_fish("fish5",  "Crab",        "A fiesty crustacean with snapping claws.", 10);
    v_define_fish("fish6",  "Prawn",       "A small and tasty shellfish.", 10);
    v_define_fish("fish7",  "Lobster",     "A classic and well sought after fish.", 10);
    v_define_fish("fish8",  "Pufferfish",  "A big and exciting fish.", 10);
    v_define_fish("fish9",  "Glowfish",    "A strange and elusive fish.", 10);
    v_define_fish("fish10", "Lionfish",    "Poisonous, but nutritious when prepared carefully", 10);
    v_define_fish("fish11", "Fossil",      "An ancient and rare fossil.", 10);

    -- -- Define all of the fishing rods
    v_define_rod("rod0", "Wooden Rod", "Grandad's old wooden fishing rod", 10);
    v_define_rod("rod1", "Lightweight Rod", "Modern aluminium fishing rod.", 10);
    v_define_rod("rod2", "Diamond Rod", "Premium, diamond standard fishing rod.", 10);
    v_define_rod("rod3", "Uranium Rod", "Uranium enriched fishing rod.", 10);
    v_define_rod("rod4", "Rainbow Rod", "Nanobii's legendary fishing rod.", 10);

    -- -- Define all of the junk items
    v_define_junk("junk0", "Seaweed", "Slimy green vegetation.", 10);
    v_define_junk("junk1", "Broken Rod", "Useless broken fishing rod.", 10);
    v_define_junk("junk2", "Rusty Sword", "A distant memory of the honey wars.", 10);
    v_define_junk("junk3", "Slimy Rock", "Shiny clear stone covered in seaweed, worthless.", 10);
    v_define_junk("junk4", "Old Rubber", "A pile of old rubber.", 10);
    v_define_junk("junk5", "Golden Key", "Ancient key that vibrates slightly when held, probably doesn't unlock anything useful.", 10);
    v_define_junk("junk6", "Old Boots", "Grandad's old boots.", 10);
    v_define_junk("junk7", "Ruined Book", "A ruined copy of Tales to Astonish #70.", 10);
    v_define_junk("junk8", "Anchor", "Old ship anchor, not as heavy as it should be.", 10);

    -- -- Define all of the fishing bait
    v_define_bait("bait0", "Bread Crumbs", "Small chunks of crusty bread", 10);
    v_define_bait("bait1", "Small Worms", "Small wriggly worms, ideal for attracting small fish", 10);
    v_define_bait("bait2", "Large Worms", "Large wriggly worms, ideal for attracting large fish", 10);
    v_define_bait("bait3", "Exotic Worms", "Exotic wriggly worms, ideal for attracting exotic fish", 10);

    -- Add our custom objects
    api_define_object({
        id = "fishing_spot",
        name = "Fishing Spot",
        category = "Fishing",
        tooltip = "Try casting a fishing rod in here!",
        shop_key = false,
        shop_buy = 0,
        shop_sell = 0,
        tools = {"Neptune_rod0"},
        invisible = true
    }, "sprites/fishing-spot-dummy.png")

    -- Add the fisherman NPC
    npc_def = {
        id = 42,
        name = "Poseidon",
        pronouns = "He/Him",
        tooltip = "Elderly fisherman",
        shop = true,
        walking = false,
        stock = {"log","Neptune_rod0", "Neptune_rod1", "Neptune_rod2", "Neptune_rod3", "Neptune_rod4"}, -- max 10
        specials = {"Neptune_bait0", "Neptune_bait1", "Neptune_bait2"}, -- must be 3
        dialogue = {
        "If I'm not fishing, I'm thinking about it..",
        "A fisherman lives here, with the catch of his life..",
        "I'd rather have a bad day fishing, than a good day at work..",
        "Sometimes, when the water is quiet, you can almost hear the fish laughing at you..",
        "Work is for people who can't fish",
        "There is no losing in fishing. You either catch or you learn.."
        },
        greeting = "The sea calls you again? I've got wares that can help.."
    }
    
    -- define npc
    api_define_npc(npc_def,
        "sprites/npc_standing.png",
        "sprites/npc_standing_h.png",
        "sprites/npc_walking.png",
        "sprites/npc_walking_h.png",
        "sprites/npc_head.png",
        "sprites/npc_bust.png",
        "sprites/npc_item.png",
        "sprites/npc_dialogue_menu.png",
        "sprites/npc_shop_menu.png"
    )


    -- Add custom colors
    api_define_color("FISHING_LINE_COLOR", {r = 195, g = 210, b = 218});

    -- Add our sprites
    spr_fishing_spot = api_define_sprite("spot", "sprites/fishing-spot.png", 6);
    spr_fishing_rod = api_define_sprite("rod", "sprites/fishing-rod-active.png", 2);
    spr_fishing_lure = api_define_sprite("lure", "sprites/fishing-lure.png", 4);

    return "Success"
end --init()


--[[
    Name: ready()
    Desc: Game hook, called after world-gen
    Params: N/A
    Returns: N/A
--]]
function ready()
    -- If we haven't already spawned our npc, spawn him now
    fisherman_npc = api_get_menu_objects(nil, "npc42")
    if (#fisherman_npc == 0) then
        api_create_obj("npc42", 3467, 827);
    end
end


--[[
    Name: clock()
    Desc: Game hook, called once per second
    Params: N/A
    Returns: N/A
--]]
function clock()

    -- If the lure has been casted
    if (ROD_STATE == CASTED) then
        local lure_nearby_fishing_spots = i_find_nearby_fishing_spots(16); -- might want to reduce how often this is called
        
        if (lure_nearby_fishing_spots > 0) then
           v_check_for_fish();
        end
    elseif (ROD_STATE == CATCHING) then
        local t_delta = TICK_NUM - catch_ticks;
        
        if (t_delta > 14) then
            -- Missed opportunity to catch
            v_reel_in_lure();
        end
    end

end --clock()


--[[
    Name: tick()
    Desc: Game hook, called every 0.1s
    Params: N/A
    Returns: N/A
--]]
function tick()
    -- Update the tick num, used for time periodic timing
    TICK_NUM = TICK_NUM + 1;

    frm_fishing_spot = i_counter(frm_fishing_spot, 0, 5, 5);
    lure_bob = i_counter(lure_bob, 0, 2, 10);
end --tick()


--[[
  Name: draw()
  Desc: Game hook, called every time the GUI is updated (~60fps)
  Params: N/A
  Returns: N/A
--]]
function draw()

    v_draw_animated_fishing_spots();

    -- If we have fishing rod equiped, draw it
    if (b_is_equipped("Neptune_rod")) then
        v_draw_active_fishing_rod();

    elseif (ROD_STATE == CASTED) then
        -- Clear any cast we had, fishing rod is no longer equipped
        ROD_STATE = READY
    end
end --draw()


--[[
    Name: key()
    Desc: Game hook, called when a key is pressed
    Params: Key code of the key that was pressed
    Returns: N/A
--]]
function key(key_code)
    if (key_code == 32) then
        -- create a fishing spot
        local player_pos = api_get_player_position()

        local px = player_pos["x"] + 40
        local py = player_pos["y"] + 40

        api_create_obj("Neptune_fishing_spot", px, py);

        player = api_get_player_position()
        api_create_log("Loc:", ("x:" .. tostring(player["x"]) .. " y:" .. tostring(player["y"]) ));

    end
end --key()


--[[
  Name: click()
  Desc: Game hook, called when the mouse/action button is pressed
  Params: N/A
  Returns: N/A
--]]
function click(button, click_type)

    if (button == "LEFT" and click_type == "PRESSED") then
     -- Check if we have a fishing rod equipped
        if (b_is_equipped("Neptune_rod")) then
            v_cast_rod();
            api_create_log("click", "registered")
        end   
    end
end --click()
