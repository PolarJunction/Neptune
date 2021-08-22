
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
        local player_id = api_get_player_instance();
        local dir = api_get_property(player_id, "dir");

        if (dir == "right") then
            lure_pos_x = player_pos["x"] + 16;
        else
            lure_pos_x = player_pos["x"] - 16;
        end

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
    local player_id = api_get_player_instance(); -- used to determine the players direction
    local dir = api_get_property(player_id, "dir");

    -- Player position on screen
    local px = player_pos["x"] - camera_pos["x"];
    local py = player_pos["y"] - camera_pos["y"];

    if (ROD_STATE == READY) then
        if (dir == "right") then
            -- Standard fishing rod
            api_draw_sprite(spr_fishing_rod, 0, (px + 4), py);
        else
            -- Flipped fishing rod
            api_draw_sprite_ext(spr_fishing_rod, 0, (px - 4), py, -1, 1, 0, 1, 1);
        end
    else
        
        -- Draw fishing line - if casted
        local rod_top_x = px;
        local rod_top_y = py;

        --- Draw & Adjust line attach point if we are flipped
        if (dir == "right") then
            -- Casting/casted fishing rod
            api_draw_sprite(spr_fishing_rod, 1, (px + 4), py);

            rod_top_x = rod_top_x + 16;

        else
            -- Casting/casted fishing rod
            api_draw_sprite_ext(spr_fishing_rod, 1, (px - 4), py, -1, 1, 0, 1, 1);

            rod_top_x = rod_top_x - 20;
        end

        -- Update lure pos if we are casting
        if (ROD_STATE == CASTING or ROD_STATE == REELING) then
            v_update_fishing_lure_pos();
        end

        -- If the line is out, check it doesn't get longer than the rod limit
        if (ROD_STATE ~= READY) then
            v_check_fishing_line_length(rod_top_x + camera_pos["x"], rod_top_y + camera_pos["y"],
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
    if (i_num <= fishing_rods[equipped_rod].catch_chance) then
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
    local player_id = api_get_player_instance();
    local dir = api_get_property(player_id, "dir");

    ROD_STATE = REELING;

    -- Reel in, set the position back to the rod
    if (dir == "right") then
        click_pos_x = (player_pos["x"] + 16);
    else
        click_pos_x = (player_pos["x"] - 20);
    end
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