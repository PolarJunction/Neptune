-- example of a function in another file that we can access
function log(group, msg)
    api_log(group, msg)
  end

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