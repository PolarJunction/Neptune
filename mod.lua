
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
        modules = {"utility", "globals", "fishing", "artifact"}
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

    -- Define all of the fishing rods
    for id, rod in pairs(fishing_rods) do
        v_define_rod(id, rod.name, rod.tooltip, rod.cost);
        num_rod_items = num_rod_items + 1;
    end

    -- Define all of the junk items
    for id, junk in pairs(junk_items) do
        v_define_junk(id, junk.name, junk.tooltip, junk.sell_price);
        num_junk_items = num_junk_items + 1;
    end

    -- Define all of the catch-able fish
    for id, fish in pairs(fish_items) do
        v_define_fish(id, fish.name, fish.tooltip, fish.sell_price);
        num_fish_items = num_fish_items + 1;
    end

    -- Define all of the fishing bait
    for id, bait in pairs(bait_items) do
        v_define_bait(id, bait.name, bait.tooltip, bait.cost);
        num_bait_items = num_bait_items + 1;
    end

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

    -- Add our artifacts
    api_define_item({
        id = "artifact0",
        name = "Poseidon's Trident",
        category = "Tool",
        tooltip = "A rare and powerful trident, capable of controlling the tides.",
        shop_key = false,
        shop_buy = 0,
        shop_sell = 10000,
        singular = true },

        ("sprites/artifact0.png") );


    -- Add the fisherman NPC
    npc_def = {
        id = 42,
        name = "Poseidon",
        pronouns = "He/Him",
        tooltip = "Elderly fisherman",
        shop = true,
        walking = false,
        stock = {"log","Neptune_rod0", "Neptune_rod1", "Neptune_rod2", "Neptune_rod3", "Neptune_rod4"}, -- max 10
        specials = {"Neptune_bait1", "Neptune_bait2", "Neptune_bait3"}, -- must be 3
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

    api_define_sprite("rod0", "sprites/rod0_active.png", 2);
    api_define_sprite("rod1", "sprites/rod1_active.png", 2);
    api_define_sprite("rod2", "sprites/rod2_active.png", 2);
    api_define_sprite("rod3", "sprites/rod3_active.png", 2);
    api_define_sprite("rod4", "sprites/rod4_active.png", 2);

    spr_fishing_lure = api_define_sprite("lure", "sprites/fishing-lure.png", 4);
    spr_trident = api_define_sprite("trident", "sprites/artifact0_active.png", 2);


    api_define_command("/teleport", "teleport_command")

    return "Success"
end --init()

-- command run when player types "/teleport"
function teleport_command(args) 
    -- args are a list of args after /teleport seperated by spaces
    -- for example we could type "/teleport 100 50" in this case
    api_set_player_position(args[1], args[2])
  end


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

    v_cleanup_fishing_spots();
end


--[[
    Name: clock()
    Desc: Game hook, called once per second
    Params: N/A
    Returns: N/A
--]]
function clock()

    -- Cleanup any unexpected fishing spots
    v_cleanup_fishing_spots();

    -- Check if we should spawn a fishing spot
    v_check_for_fishing_spot();

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

    v_check_rod_equipped();

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
    if (ROD_STATE >= READY) then
        v_draw_active_fishing_rod();
    elseif (b_is_equipped("Neptune_artifact0")) then
        v_draw_active_trident();
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
    elseif (key_code == 70) then
        v_spawn_random_catch_reward();
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

        elseif (b_is_equipped("Neptune_bait")) then
            v_consume_bait();

        elseif (b_is_equipped("Neptune_artifact0"))  then
            v_activate_trident();

        end
    end
end --click()
