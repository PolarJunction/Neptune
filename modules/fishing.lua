--[[
  Name: v_cast_rod()
  Desc: Handle an attempt to cast the rod
  Params: N/A
  Returns: N/A
--]] function v_cast_rod()
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

        if (t_delta < fishing_rods[equipped_rod].catch_time) then
            -- Successful catch
            v_spawn_random_catch_reward();
        end

        v_reel_in_lure();
    else
        -- already casted, reel in
        v_reel_in_lure();
    end
end -- v_cast_rod()

--[[
    Name: v_check_rod_equipped()
    Desc: Check if we have a rod equipped and set the correct ROD_STATE
    Params: N/A
    Returns: N/A
--]]
function v_check_rod_equipped()
    -- Check what the currently equipped item, and check if it's changed
    -- If its not a rod, set not equipped state
    local currently_equipped = api_get_equipped();

    if ((b_is_equipped("Neptune_rod") == false) and (ROD_STATE ~= NOT_EQUIPPED)) then
        -- If we don't have a rod, make sure NOT_EQUIPPED is set
        ROD_STATE = NOT_EQUIPPED;
        equipped_rod = "";

    elseif (b_is_equipped("Neptune_rod") == true) then
        -- If we have a rod equipped, check if it has changed
        local rodId = string.sub(currently_equipped, -4)

        if (rodId ~= equipped_rod) or (ROD_STATE == NOT_EQUIPPED) then
            -- We've changed rods, reel in
            ROD_STATE = READY;

            -- Set currently equipped rod
            equipped_rod = rodId;

        end
    end
end

--[[
    Name: v_draw_animated_fishing_spots()
    Desc: Draw animated fishing spot sprites on top of any fishing_spot objects in the world
          fishing_spot objects themselves remain invisible
    Params: N/A
    Returns: N/A
--]]
function v_draw_animated_fishing_spots()
    -- get a list of nearby objects in camera view
    local objs = api_get_objects(nil, "Neptune_fishing_spot");
    local camera_pos = api_get_cam();
    active_fishing_spots = 0;

    for i = 1, #objs do
        px = (objs[i]["x"] - camera_pos["x"]);
        py = (objs[i]["y"] - camera_pos["y"]);
        api_draw_sprite(spr_fishing_spot, frm_fishing_spot, px, py);

        -- Record how many fishing spots we have active at the moment
        active_fishing_spots = active_fishing_spots + 1;
    end
end -- v_draw_animated_fishing_spots()

--[[
    Name: v_consume_bait()
    Desc: Handle the actions for throwing bait into water
    Params: N/A
    Returns: N/A
--]]
function v_consume_bait()
    -- Get the position under the mouse
    local mouse = api_get_mouse_position();

    -- Check what slots contain the bait thrown
    local bait_item = api_get_equipped();
    local tile = api_get_ground(mouse["x"], mouse["y"]);

    -- Check the bait was thrown into shallow/deep water
    if (string.match(tile, "water") or string.match(tile, "deep")) then
        -- Double check it is actually bait we have
        if (b_is_equipped("Neptune_bait")) then
            -- Get player slots
            local slot = api_slot_match(api_get_player_instance(), {bait_item},
                                        true)

            if (slot ~= nil) then
                -- reduce whatever is in the first slot by 2, if anything
                api_slot_decr(slot["id"], 1)

                -- Give a chance of spawning a fishing spot
                local i_roll = api_random(100);
                local tgt_roll = 80;
                local timer = 60;

                if (bait_item == "Neptune_bait1") then
                    tgt_roll = 70;
                    timer = 80;
                elseif (bait_item == "Neptune_bait2") then
                    tgt_roll = 60;
                    timer = 100;
                elseif (bait_item == "Neptune_bait3") then
                    tgt_roll = 50;
                    timer = 120;
                elseif (bait_item == "Neptune_bait4") then
                    tgt_roll = 0;
                    timer = 180;
                end

                if (i_roll > tgt_roll) then
                    v_spawn_fishing_spot(mouse["x"] - 1, mouse["y"] - 1, timer);
                end

                -- Create a splash effect
                api_create_effect(mouse["x"], mouse["y"], "EXTRACT_DUST", 30,
                                  "FISHING_LINE_COLOR");
            end
        end
    end
end -- v_consume_bait()


--[[
    Name: v_spawn_fishing_spot()
    Desc: Spawn a fishing spot at a given pos, with a given lifetime
    Params: X & Y Position, life time in seconds
    Returns: N/A
--]]
function v_spawn_fishing_spot(x, y, timer)
    -- Spawn a fishing spot at the location
    local spot_id = api_create_obj("Neptune_fishing_spot", x, y);
    -- Despawn it after a short time, depending on the quality of bait used
    api_create_timer("api_destroy_inst", timer, spot_id)
    -- Add it to the list of known id's so it doesn't get cleaned up
    fishing_spot_ids[spot_id] = true;
end -- v_spawn_fishing_spot()


--[[
    Name: v_cleanup_fishing_spots()
    Desc: Check if there are any fishing spots that weren't spawned in this play
    Params: N/A
    Returns: N/A
--]]
function v_cleanup_fishing_spots()
    -- Get all active fishing spots and check they have been spawned since the game started
    local objs = api_get_objects(nil, "Neptune_fishing_spot");

    for i=1, #objs do
        if (fishing_spot_ids[(objs[i]["id"])] == nil) then
            -- otherwise, remove them
            api_destroy_inst(objs[i]["id"]);
        end
    end
end -- v_cleanup_fishing_spots()


--[[
    Name: v_check_for_fishing_spot()
    Desc: Check if we should spawn a fishing spot, find a random location
    Params: N/A
    Returns: N/A
--]]
function v_check_for_fishing_spot()
-- Check periodically if we should spawn a fishing spot
    if (active_fishing_spots < 2) then

        local i_roll = api_random(100);

        if (i_roll > 80) then
            local radius = 20 * 16; -- 16 points per tile

            local player_pos = api_get_player_tile_position();
            local min_x = player_pos["x"] - radius;
            local min_y = player_pos["y"] - radius;

            -- Wrap minimum values
            if (min_x < 0) then min_x = 0; end

            if (min_y < 0) then min_y = 0; end

            local deep_tiles = {};

            for x = min_x, (player_pos["x"] + (radius)), 16 do
                for y = min_y, (player_pos["y"] + (radius)), 16 do
                    local tile = api_get_ground(x, y);

                    if (string.match(tile, "deep")) then
                        -- Add deep tile to list
                        table.insert(deep_tiles, {xPos = x, yPos = y});
                    end
                end
            end

            if (#deep_tiles > 0) then
                local idx = api_random(#deep_tiles);
                -- Spawn a fishing spot at the location
                v_spawn_fishing_spot(deep_tiles[idx].xPos, deep_tiles[idx].yPos, (60 + api_random(120)));
                return;
            end
        end
    end
end -- v_check_for_fishing_spot()


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
    local spr_fishing_rod = api_get_sprite("sp_" .. equipped_rod); -- sprite id matches spr + the rodId i.e sp_rod0

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
            v_check_fishing_line_length(rod_top_x + camera_pos["x"],
                                        rod_top_y + camera_pos["y"], lure_pos_x,
                                        lure_pos_y,
                                        fishing_rods[equipped_rod].line_length);
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
end -- v_draw_active_fishing_rod()

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
end -- v_check_for_fish()

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

    api_play_sound("plop");
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
        api_give_item("Neptune_artifact0")
    elseif (i_num < (fishing_rods[equipped_rod].fish_chance * 100)) then
        api_create_log(tostring(i_num), "spawn_fish");
        -- Spawn fish
        v_spawn_fish();
    else
        api_create_log(tostring(i_num), "spawn_junk");
        -- Spawn random junk item
        v_spawn_junk();
    end
end

--[[
    Name: v_spawn_fish()
    Desc: Spawn a random fish by rarity
    Params: N/A
    Returns: N/A
--]]
function v_spawn_fish()

    -- Roll from 0-100
    -- Get a list of available fish for the given rod
    -- Check the roll against the chance min/max for each fish

    local available_fish = fishing_rods[equipped_rod].available_fish[lure_biome];
    local i_num = api_random(100);
    local chance_total = 0;

    for id, chance in pairs(available_fish) do
        if (i_num >= chance_total) and (i_num < (chance_total + chance)) then
            api_give_item("Neptune_" .. id);
            api_create_log("Fish spawn: ", "Neptune_" .. id);

            break
        end

        chance_total = chance_total + chance;
    end
end

--[[
    Name: v_spawn_junk()
    Desc: Spawn a random junk item
    Params: N/A
    Returns: N/A
--]]
function v_spawn_junk()
    local i_num = math.floor(api_random((num_junk_items) - 1));

    api_give_item(("Neptune_junk" .. tostring(i_num)));
    api_create_log("junk spawn:", ("Neptune_junk" .. tostring(i_num)));
end

--[[
    Name: i_find_nearby_fishing_spots()
    Desc: Count how many fishing spots are within range of the lure
    Params: Radius to count fishing spots
    Returns: Count of how many fishing spots are within x range
--]]
function i_find_nearby_fishing_spots(radius)
    local objs = api_get_objects(nil, "Neptune_fishing_spot"); -- Get onscreen objects
    local near_fishing_spots = 0;

    -- Count how many fishing spots are within x radius
    for i = 1, (#objs) do
        -- check if position is close
        local i_dist = i_get_distance(lure_pos_x, lure_pos_y,
                                       (objs[i]["x"] + 8), (objs[i]["y"] + 8));

        if (i_dist < radius) then
            near_fishing_spots = near_fishing_spots + 1;
        end
    end

    return near_fishing_spots;
end -- i_find_nearby_fishing_spots()

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
end -- v_check_fishing_line_length()

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
end -- v_reel_in_lure()

--[[
    Name: v_handle_lure_landing()
    Desc: Check what type of tile the lure landed on, animate effect and reel in if not on water
    Params: N/A
    Returns: N/A
--]]
function v_handle_lure_landing()
    -- Get the tile type under the lure
    local lure_tile = api_get_ground(lure_pos_x, lure_pos_y);
    local biome = string.sub(lure_tile, -1);

    -- Record the biome of the tile that the lure landed on
    if (biome == "1") then
        lure_biome = "forest";
    elseif (biome == "2") then
        lure_biome = "swamp";
    elseif (biome == "3") then
        lure_biome = "tundra";
    else
        lure_biome = "hallow";
    end

    -- Check what tile type the lure landed on, and activate the correct effect
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
end -- v_handle_lure_landing()

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
end -- v_update_fishing_lure_pos()
