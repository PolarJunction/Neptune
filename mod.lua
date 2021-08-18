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

ROD_CAST = 0; -- Store casting state, READY, CASTING, CASTED, REELING
READY = 0;
CASTING = 1;
CASTED = 2;
REELING = 3;

click_pos_x = 0; -- pos to track where a player clicked to cast
click_pos_y = 0;

lure_pos_x = 0; -- pos to track lure while casting is in progress
lure_pos_y = 0;
lure_bob = 0;
lure_nearby_fishing_spots = 0;

INIT = false; -- workaround for draw() being called before init()

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
    return {name = "Neptune", hooks = {"clock", "key", "draw", "tick", "click"}}
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

    -- Add our custom items
    api_define_item({
        id = "fish",
        name = "Fish",
        category = "Decoration",
        tooltip = "This is a cool fish!",
        shop_key = false,
        shop_buy = 10,
        shop_sell = 0,
        durability = 0,
        singular = false
    }, "sprites/fish.png")

    api_define_item({
        id = "rod0",
        name = "Wooden Rod",
        category = "Tool",
        tooltip = "Grandad's old fishing rod for catching fish!",
        shop_key = false,
        shop_buy = 1000,
        shop_sell = 200,
        durability = 0,
        singular = true
    }, "sprites/rod0.png")

    api_define_item({
        id = "rod1",
        name = "Lightweight Rod",
        category = "Tool",
        tooltip = "Lightweight aluminium fishing rod for catching fish!",
        shop_key = false,
        shop_buy = 1000,
        shop_sell = 200,
        durability = 0,
        singular = true
    }, "sprites/rod1.png")

    api_define_item({
        id = "rod2",
        name = "Diamond Rod",
        category = "Tool",
        tooltip = "Premium diamond encrusted fishing rod for catching fish!",
        shop_key = false,
        shop_buy = 1000,
        shop_sell = 200,
        durability = 0,
        singular = true
    }, "sprites/rod2.png")

    api_define_item({
        id = "rod3",
        name = "Uranium Rod",
        category = "Tool",
        tooltip = "Uranium enriched fishing rod for catching fish!",
        shop_key = false,
        shop_buy = 1000,
        shop_sell = 200,
        durability = 0,
        singular = true
    }, "sprites/rod3.png")

    api_define_item({
        id = "rod4",
        name = "Rainbow Rod",
        category = "Tool",
        tooltip = "Legendary fishing rod for catching fish!",
        shop_key = false,
        shop_buy = 1000,
        shop_sell = 200,
        durability = 0,
        singular = true
    }, "sprites/rod4.png")

    -- Add our custom objects
    api_define_object({
        id = "fishing_spot",
        name = "Fishing Spot",
        category = "Fishing",
        tooltip = "Try casting a fishing rod in here!",
        shop_key = false,
        shop_buy = 0,
        shop_sell = 0,
        tools = {"Neptune_fishing_rod"},
        has_shadow = false
    }, "sprites/fishing-spot-dummy.png")

    -- Add custom colors
    api_define_color("FISHING_LINE_COLOR", {r = 195, g = 210, b = 218});

    -- Add our sprites
    spr_fishing_spot = api_define_sprite("spot", "sprites/fishing-spot.png", 6);
    spr_fishing_rod = api_define_sprite("rod", "sprites/fishing-rod-active.png", 2);
    spr_fishing_lure = api_define_sprite("lure", "sprites/fishing-lure.png", 4);

    return "Success"
end --init()


--[[
    Name: clock()
    Desc: Game hook, called once per second
    Params: N/A
    Returns: N/A
--]]
function clock()

    -- If the lure has been casted
    if (ROD_CAST == CASTED) then
        lure_nearby_fishing_spots = i_find_nearby_fishing_spots(16); -- might want to reduce how often this is called
        
        if (lure_nearby_fishing_spots > 0) then
           v_check_for_fish();
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
    if (b_is_equipped("Neptune_fishing_rod")) then
        v_draw_active_fishing_rod();

    elseif (ROD_CAST == CASTED) then
        -- Clear any cast we had, fishing rod is no longer equipped
        ROD_CAST = READY
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
        --   api_give_item("Neptune_fish", 1)
        --   api_give_item("Neptune_fishing_rod", 1)

        -- create a fishing spot
        player_pos = api_get_player_position()

        px = player_pos["x"] + 40
        py = player_pos["y"] + 40

        api_create_obj("Neptune_fishing_spot", px, py);

    end

    if (key_code == 70) then
        -- Check if we have a fishing rod equipped
        if (api_get_equipped() == "Neptune_fishing_rod") then
            v_cast_rod();
        end
    end
end --key()


--[[
  Name: click()
  Desc: Game hook, called when the mouse/action button is pressed
  Params: N/A
  Returns: N/A
--]]
function click()
    -- do something
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
  Name: v_cast_rod()
  Desc: Handle an attempt to cast the rod
  Params: N/A
  Returns: N/A
--]]
function v_cast_rod()
    if (ROD_CAST == READY) then
        -- cast away
        mouse = api_get_mouse_position();

        click_pos_x = mouse["x"];
        click_pos_y = mouse["y"];

        -- set the lure pos to the player
        player_pos = api_get_player_position();
        lure_pos_x = player_pos["x"] + 16;
        lure_pos_y = player_pos["y"] + 2;

        ROD_CAST = CASTING;
    else
        -- already casted, reel in
        v_reel_in_lure();
    end
end --v_cast_rod()


--[[
    Name: b_is_equipped()
    Desc: Check if a given item is currently equipped by the player
    Params: Item string to check
    Returns: true/false equipped or not
--]]
function b_is_equipped(item)
    -- Get the currently equipped item
    equipped_item = api_get_equipped();

    if (equipped_item == item) then
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
    objs = api_get_objects();
    camera_pos = api_get_cam();

    for i = 1, #objs do
        if (objs[i]["oid"] == "Neptune_fishing_spot") then
            px = (objs[i]["x"] - camera_pos["x"]);
            py = (objs[i]["y"] - camera_pos["y"]) + 20;
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
    player_pos = api_get_player_position();
    camera_pos = api_get_camera_position();

    -- Player position on screen
    px = player_pos["x"] - camera_pos["x"];
    py = player_pos["y"] - camera_pos["y"];

    -- Draw active fishing rod sprite
    rod_x = px + 4;
    rod_y = py;

    if (ROD_CAST == READY) then
        -- Standard fishing rod
        api_draw_sprite(spr_fishing_rod, 0, rod_x, rod_y);
    else
        -- Casting/casted fishing rod
        api_draw_sprite(spr_fishing_rod, 1, rod_x, rod_y);

        -- Draw fishing line - if casted
        rod_top_x = rod_x + 12;
        rod_top_y = rod_y;

        -- Update lure pos if we are casting
        if (ROD_CAST == CASTING or ROD_CAST == REELING) then
            v_update_fishing_lure_pos();
        end

        -- If the line is out, check it doesn't get longer than the rod limit
        if (ROD_CAST ~= READY) then
            v_check_fishing_line_length(player_pos["x"] + 16, player_pos["y"],
                                        lure_pos_x, lure_pos_y, 100);
        end

        -- Animate the lure position slightly in Y direction to create a bob effect
        fish_x = lure_pos_x - camera_pos["x"];
        fish_y = (lure_pos_y - lure_bob) - camera_pos["y"];
        
        api_draw_line(rod_top_x, rod_top_y, fish_x, fish_y, "FISHING_LINE_COLOR")

        -- Draw lure - need to animate this
        lure_x = fish_x - 8;
        lure_y = fish_y - 8;

        api_draw_sprite(spr_fishing_lure, 0, lure_x, lure_y)
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
    i_num = api_random(100);

    -- 5% chance of successfully fishing
    if (i_num < 5) then
        -- successful
        v_spawn_random_fish();
    
        v_reel_in_lure();
    end
end --v_check_for_fish()


function v_spawn_random_fish()
    api_give_item("Neptune_fish", 1);
end

-- If we are in range, create an "caught fish" event
-- If the player reels in within x ms of the event, spawn a random fish/item

--[[
    Name: i_find_nearby_fishing_spots()
    Desc: Count how many fishing spots are within range of the lure
    Params: Radius to count fishing spots
    Returns: Count of how many fishing spots are within x range
--]]
function i_find_nearby_fishing_spots(radius)
    objs = api_get_objects(); -- Get onscreen objects
    near_fishing_spots = 0;

    -- Count how many fishing spots are within x radius
    for i=1,(#objs) do
        if objs[i]["oid"] == "Neptune_fishing_spot" then
            -- check if position is close
            i_dist = i_get_distance(lure_pos_x, lure_pos_y, (objs[i]["x"] + 8), (objs[i]["y"] + 8));

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
    -- Get the linear distance between two coordinates
    i_delta_x = posA_x - posB_x;
    i_delta_y = posA_y - posB_y;

    dXsq = i_delta_x * i_delta_x;
    dYsq = i_delta_y * i_delta_y;

    dTsq = dXsq + dYsq;

    i_dist = math.ceil(math.sqrt(dTsq));
    
    return i_dist;
end --i_get_distance()


--[[
    Name: v_check_fishing_line_length()
    Desc: Check if the fishing line goes beyond the fishing rod limit, if so reel in
    Params: N/A
    Returns: N/A
--]]
function v_check_fishing_line_length(rod_x, rod_y, lure_x, lure_y, max_dist)
    -- Calculate the distance D2 = X2 + Y2
    i_dist = i_get_distance(rod_x, rod_y, lure_x, lure_y);

    if (ROD_CAST == CASTING) then
        if (i_dist >= max_dist) then
            -- if we are in the middle of casting and reached the limit, halt the lure where it is
            ROD_CAST = CASTED;

            click_pos_x = lure_x;
            click_pos_y = lure_y;

            v_handle_lure_landing();
        end

    elseif (ROD_CAST == CASTED) then
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
    ROD_CAST = REELING;

    player_pos = api_get_player_position();

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
    lure_tile = api_get_ground(lure_pos_x, lure_pos_y);

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
    deltaX = lure_pos_x - click_pos_x;
    deltaY = lure_pos_y - click_pos_y;

    if (math.abs(deltaX) <= 10) and (math.abs(deltaY) <= 10) then
        if (ROD_CAST == CASTING) then
            -- landed
            ROD_CAST = CASTED;

            -- set the lure position to exactly where the player clicked
            lure_pos_x = click_pos_x;
            lure_pos_y = click_pos_y;

            v_handle_lure_landing();
        elseif (ROD_CAST == REELING) then
            ROD_CAST = READY;
        end
    else
        angle = math.atan(deltaY, deltaX);
        speed_x = 3 -- rod cast speed
        speed_y = 2

        lure_pos_x = math.ceil(lure_pos_x - (speed_x * math.cos(angle)))
        lure_pos_y = math.ceil(lure_pos_y - (speed_y * math.sin(angle)))
    end
end --v_update_fishing_lure_pos()
