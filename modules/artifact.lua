function v_draw_active_trident()
    local player_pos = api_get_player_position();
    local camera_pos = api_get_camera_position();

    local player_id = api_get_player_instance();
    local dir = api_get_property(player_id, "dir");

    local px = player_pos["x"] - camera_pos["x"];
    local py = player_pos["y"] - camera_pos["y"];

    if (dir == "right") then
        api_draw_sprite(spr_trident, 1, (px + 4), py);
    else
        api_draw_sprite_ext(spr_trident, 1, (px - 4), py, -1, 1, 0, 1, 1);
    end
end

function v_activate_trident()
    -- Get the current mouse position
    local mouse = api_get_mouse_position();
    local tile = api_get_ground(mouse["x"], mouse["y"]);
    local biome = string.sub(tile, -1); -- Get the biome type at the end of the tile type

    if (string.match(tile, "grass")) then
        api_set_ground(("water" .. biome), mouse["x"], mouse["y"]);
    elseif (string.match(tile, "water")) then
        api_set_ground(("deep" .. biome), mouse["x"], mouse["y"]);
    elseif (string.match(tile, "deep")) then
        api_set_ground(("grass" .. biome), mouse["x"], mouse["y"]);
    end

    api_create_effect(mouse["x"], mouse["y"], "BEE_CONFETTI", 100, "FONT_WHITE");
end

