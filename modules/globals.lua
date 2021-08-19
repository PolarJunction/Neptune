--[[
    Global Values
--]]

-- SPRITES
spr_fishing_spot = nil;
spr_fishing_rod = nil;
spr_fishing_lure = nil;
spr_trident = nil;

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