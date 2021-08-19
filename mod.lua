--[[
    Global Values
--]]

-- SPRITES
spr_fishing_spot = nil;
spr_fishing_rod = nil;
spr_fishing_lure = nil;

-- GLOBALS
TICK_NUM = 0; -- custom tick count

frm_fishing_spot = 0; -- Animate fishing spot - frame counter

ROD_STATE = 0; -- Store casting state, READY, CASTING, CASTED, REELING
READY = 0;
CASTING = 1;
CASTED = 2;
REELING = 3;
CATCHING = 4;

click_pos_x = 0; -- pos to track where a player clicked to cast
click_pos_y = 0;

lure_pos_x = 0; -- pos to track lure while casting is in progress
lure_pos_y = 0;
lure_bob = 0;
lure_nearby_fishing_spots = 0;

catch_ticks = 0; -- Store when the catch event was started to check if the player clicked in time

--[[]
    End of Global Values
--]]


--[[
  Name: register()
  Desc: Register our mod name and hook into game events
  Params: N/A
  Return: N/A
--]]
function register()
    -- register our mod name and the hooks we want
    return {name = "Neptune", hooks = {"clock", "key", "draw", "tick", "click", "ready"}}
end --register()


--[[
    Name: init()
    Desc: Game hook, called before starting, initialise items/sprites/objects etc
    Params: N/A
    Return: String - to indicate "Success"
--]]
function init()
    -- init the mod
    api_create_log("init", "Hello World!")
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

function ready()
    -- If we haven't already spawned our npc, spawn him now
    fisherman_npc = api_get_menu_objects(nil, "npc42")
    if (#fisherman_npc == 0) then
        api_create_obj("npc42", 3467, 827);
    end

    -- TODO -remove
    api_give_money(420)
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


--[[
    Name: i_counter()
    Desc: Increment a frame counter, every x ticks, wrap on max ticks
    Params: Counter to be incremented, min, max counts, delay in ticks
    Returns: Counter result
--]]
-- Increment a frame counter, every x ticks.
function i_counter(count, min, max, delay)

    if (math.fmod(TICK_NUM, delay) == 0) then
        count = count + 1;

        if (count > max) then count = min; end
    end

    return count;
end --i_counter()


--[[
    Name: v_define_fish()
    Desc: Helper function to define fish
    Params: fish_id, name, tooltip and how much the shop will buy it for
    Returns: N/A
--]]
function v_define_fish(id, name, tooltip, sell)
    api_define_item({
        id = id,
        name = name,
        category = "Fish",
        tooltip = tooltip,
        shop_key = false,
        shop_buy = 0,
        shop_sell = sell,
        singular = false },

        ("sprites/" .. id .. ".png") );
end


--[[
    Name: v_define_junk()
    Desc: Helper function to define junk items
    Params: Junk id, name, tooltip and how much the shop will buy it for
    Returns: N/A
--]]
function v_define_junk(id, name, tooltip, sell)
    api_define_item({
        id = id,
        name = name,
        category = "Junk",
        tooltip = tooltip,
        shop_key = false,
        shop_buy = 0,
        shop_sell = sell,
        singular = false  },

        ("sprites/" .. id .. ".png") );
end


--[[
    Name: v_define_rod()
    Desc: Helper function to define fishing rods
    Params: Rod id, name, tooltip and how much it costs from the shop
    Returns: N/A
--]]
function v_define_rod(id, name, tooltip, buy)
    api_define_item({
        id = id,
        name = name,
        category = "Fishing Rods",
        tooltip = tooltip,
        shop_key = false,
        shop_buy = buy,
        shop_sell = (buy / 2),
        singular = true },

        ("sprites/" .. id .. ".png") );
end


--[[
    Name: v_define_bait()
    Desc: Helper function to define bait
    Params: Bait id, name, tooltip and how much it costs from the shop
    Returns: N/A
--]]
function v_define_bait(id, name, tooltip, buy)
    api_define_item({
        id = id,
        name = name,
        category = "Fishing Bait",
        tooltip = tooltip,
        shop_key = false,
        shop_buy = buy,
        shop_sell = (buy / 2),
        singular = false },

        ("sprites/" .. id .. ".png") );
end


--[[
  Name: v_cast_rod()
  Desc: Handle an attempt to cast the rod
  Params: N/A
  Returns: N/A
--]]
function v_cast_rod()
    if (ROD_STATE == READY) then
        -- cast away
        local mouse = api_get_mouse_position();

        click_pos_x = mouse["x"];
        click_pos_y = mouse["y"];

        -- set the lure pos to the player
        local player_pos = api_get_player_position();

        lure_pos_x = player_pos["x"] + 16;
        lure_pos_y = player_pos["y"] + 2;

        ROD_STATE = CASTING;

    elseif (ROD_STATE == CATCHING) then
        -- Check if the player was quick enough
        local t_delta = TICK_NUM - catch_ticks;

        if (t_delta < 15) then
            -- Successful catch
            v_spawn_random_catch_reward();
        end
        
        v_reel_in_lure();
    else
        -- already casted, reel in
        v_reel_in_lure();
    end
end --v_cast_rod()


--[[
    Name: b_is_equipped()
    Desc: Check if a given item is currently equipped by the player
    Params: Item string/part string to check
    Returns: true/false equipped or not
--]]
function b_is_equipped(item)
    -- Get the currently equipped item
    local equipped_item = api_get_equipped();

    if (string.match(equipped_item, item)) then
        return true
    else
        return false
    end
end --b_is_equipped()


--[[
    Name: v_draw_animated_fishing_spots()
    Desc: Draw animated fishing spot sprites on top of any fishing_spot objects in the world
          fishing_spot objects themselves remain invisible
    Params: N/A
    Returns: N/A
--]]
function v_draw_animated_fishing_spots()
    -- get a list of nearby objects in camera view
    local objs = api_get_objects();
    local camera_pos = api_get_cam();

    for i = 1, #objs do
        if (objs[i]["oid"] == "Neptune_fishing_spot") then
            px = (objs[i]["x"] - camera_pos["x"]);
            py = (objs[i]["y"] - camera_pos["y"]);
            api_draw_sprite(spr_fishing_spot, frm_fishing_spot, px, py);
        end
    end
end --v_draw_animated_fishing_spots()


--[[
  Name: v_draw_active_fishing_rod()
  Desc: Draw the fishing rod sprite casted/uncasted when it is equipped by the player
  Params: N/A
  Returns: N/A
--]]
function v_draw_active_fishing_rod()
    local player_pos = api_get_player_position();
    local camera_pos = api_get_camera_position();
    local player = api_get_player_instance(); -- used to determine the players direction

    -- Player position on screen
    local px = player_pos["x"] - camera_pos["x"];
    local py = player_pos["y"] - camera_pos["y"];

    -- Draw active fishing rod sprite
    local rod_x = px + 4;
    local rod_y = py;

    if (ROD_STATE == READY) then
        -- Standard fishing rod
        api_draw_sprite(spr_fishing_rod, 0, rod_x, rod_y);
    else
        -- Casting/casted fishing rod
        api_draw_sprite(spr_fishing_rod, 1, rod_x, rod_y);

        -- Draw fishing line - if casted
        local rod_top_x = rod_x + 12;
        local rod_top_y = rod_y;

        -- Update lure pos if we are casting
        if (ROD_STATE == CASTING or ROD_STATE == REELING) then
            v_update_fishing_lure_pos();
        end

        -- If the line is out, check it doesn't get longer than the rod limit
        if (ROD_STATE ~= READY) then
            v_check_fishing_line_length(player_pos["x"] + 16, player_pos["y"],
                                        lure_pos_x, lure_pos_y, 100);
        end

        -- Animate the lure position slightly in Y direction to create a bob effect
        local fish_x = lure_pos_x - camera_pos["x"];
        local fish_y = (lure_pos_y - lure_bob) - camera_pos["y"];
        
        api_draw_line(rod_top_x, rod_top_y, fish_x, fish_y, "FISHING_LINE_COLOR")

        -- Draw lure - need to animate this
        local lure_x = fish_x - 8;
        local lure_y = fish_y - 8;

        -- If a catch event has been started, draw different frames
        if (ROD_STATE == CATCHING) then
            local t_delta = TICK_NUM - catch_ticks;

            if (t_delta <= 2) then
                api_draw_sprite(spr_fishing_lure, 1, lure_x, lure_y)
            elseif (t_delta <= 4) then
                api_draw_sprite(spr_fishing_lure, 2, lure_x, lure_y)
            elseif (t_delta <= 6) then
                api_draw_sprite(spr_fishing_lure, 3, lure_x, lure_y)
            else
                -- Don't draw
            end
        else
            api_draw_sprite(spr_fishing_lure, 0, lure_x, lure_y)
        end

    end
end --v_draw_active_fishing_rod()


--[[
    Name: v_check_for_fish()
    Desc: Check if we caught a fish
    Params: N/A
    Returns: N/A 
--]]
function v_check_for_fish()
    -- Check if we are casted
    -- Check if the lure is within x range of a fishing spot
    local i_num = api_random(100);

    -- 5% chance of successfully fishing
    if (i_num < 8) then
        -- successful
        v_start_catch_event();
    end
end --v_check_for_fish()


--[[
    Name: v_start_catch_event()
    Desc: Setup for the catch event
    Params: N/A
    Returns: N/A
--]]
function v_start_catch_event()

    ROD_STATE = CATCHING;
    catch_ticks = TICK_NUM; -- Start time for the catch
    
    api_create_effect(lure_pos_x, lure_pos_y, "EXTRACT_DUST", 80,
                          "FISHING_LINE_COLOR");

end


--[[
    Name: v_spawn_random_catch()
    Desc: Spawn a reward for a successful catch
    Params: N/A
    Returns: N/A
--]]
function v_spawn_random_catch_reward()

    local i_num = api_random(10000);
    
    if (i_num < 5) then -- 0.05%
        -- api_give_item("Neptune_artifact0")
    elseif (i_num < 2500) then
        -- spawn fish
        v_spawn_fish();

        api_create_log("Spawn", "fish");
    else
        v_spawn_junk();

        api_create_log("Spawn", "junk");
        -- spawn junk
    end
end


--[[
    Name: v_spawn_fish()
    Desc: Spawn a random fish by rarity
    Params: N/A
    Returns: N/A
--]]
function v_spawn_fish()
    local i_num = api_random(2500);
    api_create_log("Spawn", "fish");

    if (i_num < 20) then
        api_give_item("Neptune_fish11"); -- Fossil
    elseif (i_num < 50) then
        api_give_item("Neptune_fish10"); -- Lionfish
    elseif (i_num < 100) then
        api_give_item("Neptune_fish9"); -- Glowfish
    elseif (i_num < 200) then
        api_give_item("Neptune_fish8"); -- Pufferfish
    elseif (i_num < 400) then
        api_give_item("Neptune_fish7"); -- Lobster
    elseif (i_num < 600) then
        api_give_item("Neptune_fish6"); -- Prawn
    elseif (i_num < 900) then
        api_give_item("Neptune_fish5"); -- Crab
    elseif (i_num < 1200) then
        api_give_item("Neptune_fish4"); -- Mackerel
    elseif (i_num < 1600) then
        api_give_item("Neptune_fish3"); -- Sea Snake
    elseif (i_num < 1750) then
        api_give_item("Neptune_fish2"); -- Octopus
    elseif (i_num < 2000) then
        api_give_item("Neptune_fish1"); -- Sardine
    else
        api_give_item("Neptune_fish0"); -- Guppy
    end

end

--[[
    Name: v_spawn_junk()
    Desc: Spawn a random junk item
    Params: N/A
    Returns: N/A
--]]
function v_spawn_junk()

    local i_num = math.floor(api_random(8));
    -- local s_item = ("Neptune_junk" .. tostring(i_num));

    -- api_create_log("Spawn", s_item);


    api_give_item(("Neptune_junk" .. tostring(i_num)));

end


--[[
    Name: i_find_nearby_fishing_spots()
    Desc: Count how many fishing spots are within range of the lure
    Params: Radius to count fishing spots
    Returns: Count of how many fishing spots are within x range
--]]
function i_find_nearby_fishing_spots(radius)
    local objs = api_get_objects(); -- Get onscreen objects
    local near_fishing_spots = 0;

    -- Count how many fishing spots are within x radius
    for i=1,(#objs) do
        if objs[i]["oid"] == "Neptune_fishing_spot" then
            -- check if position is close
            local i_dist = i_get_distance(lure_pos_x, lure_pos_y, (objs[i]["x"] + 8), (objs[i]["y"] + 8));

            if (i_dist < radius) then
                near_fishing_spots = near_fishing_spots + 1;
            end
        end
    end
    
    return near_fishing_spots;
end --i_find_nearby_fishing_spots()


--[[
    Name: i_get_distance()
    Desc: Get the linear distance between two coordinates
    Params: First and second position, x+y coords
    Returns: The calculated distance, rounded up to nearest int
--]]
function i_get_distance(posA_x, posA_y, posB_x, posB_y)
    -- D2 = X2 + Y2
    local i_delta_x = posA_x - posB_x;
    local i_delta_y = posA_y - posB_y;

    local dXsq = i_delta_x * i_delta_x;
    local dYsq = i_delta_y * i_delta_y;

    return(math.ceil(math.sqrt((dXsq + dYsq))) );
end --i_get_distance()


--[[
    Name: v_check_fishing_line_length()
    Desc: Check if the fishing line goes beyond the fishing rod limit, if so reel in
    Params: N/A
    Returns: N/A
--]]
function v_check_fishing_line_length(rod_x, rod_y, lure_x, lure_y, max_dist)
    -- Calculate the distance D2 = X2 + Y2
    local i_dist = i_get_distance(rod_x, rod_y, lure_x, lure_y);

    if (ROD_STATE == CASTING) then
        if (i_dist >= max_dist) then
            -- if we are in the middle of casting and reached the limit, halt the lure where it is
            ROD_STATE = CASTED;

            click_pos_x = lure_x;
            click_pos_y = lure_y;

            v_handle_lure_landing();
        end

    elseif (ROD_STATE == CASTED) then
        if (i_dist >= (max_dist + 10)) then v_reel_in_lure(); end
    end
end --v_check_fishing_line_length()


--[[
    Name: v_reel_in_lure()
    Desc: Start reeling in the lure
    Params: N/A
    Returns: N/A
--]]
function v_reel_in_lure()
    local player_pos = api_get_player_position();

    ROD_STATE = REELING;

    -- Reel in, set the position back to the rod
    click_pos_x = (player_pos["x"] + 16);
    click_pos_y = (player_pos["y"]);
end --v_reel_in_lure()


--[[
    Name: v_handle_lure_landing()
    Desc: Check what type of tile the lure landed on, animate effect and reel in if not on water
    Params: N/A
    Returns: N/A
--]]
function v_handle_lure_landing()
    -- Get the tile type under the lure
    local lure_tile = api_get_ground(lure_pos_x, lure_pos_y);

    if (string.match(lure_tile, "water")) then
        -- shallow water splash
        api_create_effect(lure_pos_x, lure_pos_y, "EXTRACT_DUST", 40,
                          "FISHING_LINE_COLOR");

    elseif (string.match(lure_tile, "deep")) then
        -- deep water splash
        api_create_effect(lure_pos_x, lure_pos_y, "EXTRACT_DUST", 40,
                          "FISHING_LINE_COLOR");

    else
        -- ground dust splash
        api_create_effect(lure_pos_x, lure_pos_y, "SMOKE_PUFF", 10, "FONT_BROWN");

        -- landed on ground, reel back in
        v_reel_in_lure();
    end
end --v_handle_lure_landing()


--[[
    Name: v_update_fishing_lure_pos()
    Desc: Animate the fishing lure when we are casting our line out or reeling in
    Params: N/A
    Returns: N/A
--]]
function v_update_fishing_lure_pos()
    -- If we are in the middle of casting or reeling, work out the next position
    -- USE STEP when available
    local deltaX = lure_pos_x - click_pos_x;
    local deltaY = lure_pos_y - click_pos_y;

    if (math.abs(deltaX) <= 10) and (math.abs(deltaY) <= 10) then
        if (ROD_STATE == CASTING) then
            -- landed
            ROD_STATE = CASTED;

            -- set the lure position to exactly where the player clicked
            lure_pos_x = click_pos_x;
            lure_pos_y = click_pos_y;

            v_handle_lure_landing();

        elseif (ROD_STATE == REELING) then
            ROD_STATE = READY;
        end
    else
        local angle = math.atan(deltaY, deltaX);
        local speed_x = 3; -- rod cast speed
        local speed_y = 2;

        lure_pos_x = math.ceil(lure_pos_x - (speed_x * math.cos(angle)));
        lure_pos_y = math.ceil(lure_pos_y - (speed_y * math.sin(angle)));
    end
end --v_update_fishing_lure_pos()
