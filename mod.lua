
function register()
    -- register our mod name and the hooks we want
    return {
      name = "Neptune",
      hooks = {"clock", "key", "draw", "tick", "click"}
    }
  end

  -- SPRITES
  spr_fishing_spot = nil
  spr_fishing_rod = nil
  spr_fishing_lure = nil

  -- GLOBALS
  TICK_NUM = 0 -- custom tick count

  frm_fishing_spot = 0 -- Animate fishing spot - frame counter

  ROD_CAST = 0 -- 0 not cast, 1 in progress, 2 cast

  click_pos_x = 0 -- pos to track where a player clicked to cast
  click_pos_y = 0

  lure_pos_x = 0; -- pos to track lure while casting is in progress
  lure_pos_y = 0;

  INIT = false

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
      durability =0,
      singular = false
    }, "sprites/fish.png")

    api_define_item({
      id = "fishing_rod",
      name = "Fishing Rod",
      category = "Tool",
      tooltip = "A great tool for catching fish!",
      shop_key = false,
      shop_buy = 1000,
      shop_sell = 2000,
      durability = 0,
      singular = true
    }, "sprites/fishing-rod.png")

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
    api_define_color("FISHING_LINE_COLOR", {r=195, g=210, b=218} );

    -- Add our sprites
    spr_fishing_spot = api_define_sprite("spot", "sprites/fishing-spot.png", 6)
    spr_fishing_rod = api_define_sprite("rod", "sprites/fishing-rod-active.png", 2)
    spr_fishing_lure = api_define_sprite("lure", "sprites/fishing-lure.png", 4)

    INIT = true

    return "Success"
  end

  function clock()
    -- do something
  end

  function tick()
    -- Update the tick num, used for time periodic timing
    TICK_NUM = TICK_NUM + 1;

    frm_fishing_spot = i_counter(frm_fishing_spot, 0, 5, 5);

  end

  -- Increment a frame counter, every x ticks.
  function i_counter(count, min, max, delay)

    if (math.fmod(TICK_NUM, delay) == 0) then
        count = count + 1;

        if (count > max) then
            count = min;
        end
    end
    
    return count;

  end

  function draw()
    -- Don't draw anything until we have initialised the sprites
    if (INIT == false) then
        return
    end

    v_draw_animated_fishing_spots();

    -- If we have fishing rod equiped, draw it
    if (b_is_equipped("Neptune_fishing_rod")) then
      draw_active_fishing_rod();
    elseif (ROD_CAST == 2) then
      -- Clear any cast we had, fishing rod is no longer equipped
      ROD_CAST = 0
    end
  end

  function key(key_code)
    if (key_code == 32) then
    --   api_give_item("Neptune_fish", 1)
    --   api_give_item("Neptune_fishing_rod", 1)
      
      -- create a fishing spot
      player_pos = api_get_player_position()

      px = player_pos["x"] + 40
      py = player_pos["y"] + 40

      api_create_object("Neptune_fishing_spot", px, py);

    end
  end

  function click()
    api_log("Click", "Received")
    -- Check if we have a fishing rod equipped
    if (api_get_equipped() == "Neptune_fishing_rod") then
        if (ROD_CAST == 0) then
            -- cast away
            mouse = api_get_mouse_position();

            click_pos_x = mouse["x"];
            click_pos_y = mouse["y"];

            -- set the lure pos to the player
            player_pos = api_get_player_position();
            lure_pos_x = player_pos["x"] + 16;
            lure_pos_y = player_pos["y"] + 2;

            ROD_CAST = 1;
        else
            ROD_CAST = 0;
        end
    end
  end

  -- Check if a given item is currently equipped by the player
  function b_is_equipped(item)
    -- Get the currently equipped item
    equipped_item = api_get_equipped();

    if (equipped_item == item) then
        return true
    else
        return false
    end
  end

  -- Draw the animated fishing spot sprites on top of any fishing_spot objects
  -- in the world, fishing_spot objects remain invisible
  function v_draw_animated_fishing_spots()
    -- get a list of nearby objects in camera view
    objs = api_get_objects();
    camera_pos = api_get_cam();

    for i=1, #objs do
      if (objs[i]["oid"] == "Neptune_fishing_spot") then
        px = (objs[i]["x"] - camera_pos["x"]);
        py = (objs[i]["y"] - camera_pos["y"]) + 20;
        api_draw_sprite(spr_fishing_spot, frm_fishing_spot, px, py);
      end
    end
  end -- v_draw_animated_fishing_spots()

  function draw_active_fishing_rod()
    player_pos = api_get_player_position();
    camera_pos = api_get_camera_position();

    -- Player position on screen
    px = player_pos["x"] - camera_pos["x"];
    py = player_pos["y"] - camera_pos["y"];

    -- Draw active fishing rod sprite
    rod_x = px + 4;
    rod_y = py;

    if (ROD_CAST == 0) then
      -- Standard fishing rod
      api_draw_sprite(spr_fishing_rod, 0, rod_x, rod_y);
    else
      -- Casting/casted fishing rod
      api_draw_sprite(spr_fishing_rod, 1, rod_x, rod_y);

       -- Draw fishing line - if casted
      rod_top_x = rod_x + 12;
      rod_top_y = rod_y;

      -- Update lure pos if we are casting
      if (ROD_CAST == 1) then
          update_fishing_lure_pos();
      end

      check_fishing_line_length(rod_top_x, rod_top_y, lure_pos_x, lure_pos_y, 300);

      fish_x = lure_pos_x - camera_pos["x"];
      fish_y = lure_pos_y - camera_pos["y"];

      api_draw_line(rod_top_x, rod_top_y, fish_x, fish_y, "FISHING_LINE_COLOR")

      -- Draw lure - need to animate this
      lure_x = fish_x - 8;
      lure_y = fish_y - 8;

      api_draw_sprite(spr_fishing_lure, 0, lure_x, lure_y)
    end
  end

  -- If the fishing line goes beyond a certain limit cancel the cast
  function check_fishing_line_length(rod_x, rod_y, lure_x, lure_y, max_dist)

    -- Calculate the distance
    i_delta_x = rod_x - lure_x;
    i_delta_y = rod_y - lure_y;

    dXsq = i_delta_x * i_delta_x;
    dYsq = i_delta_y * i_delta_y;

    dTsq = dXsq + dYsq;

    i_dist = math.ceil(math.sqrt(dTsq));

    if (ROD_CAST == 1) then
      if (i_dist >= max_dist) then
       -- if we are in the middle of casting and reached the limit, halt the lure where it is
       ROD_CAST = 2

       click_pos_x = lure_x;
       click_pos_y = lure_y;
      end

    elseif (ROD_CAST == 2) then
        if (i_dist >= (max_dist + 2)) then
            ROD_CAST = 0
        end
    end

    

    -- if we are currently casting and move too far away, cancel casting
  end

  -- Animate the fishing lure when we are casting our line out
  function update_fishing_lure_pos()
    -- If we are in the middle of casting, work out the next position
    -- USE STEP when available
    if (ROD_CAST == 1) then
        -- casting
        deltaX = lure_pos_x - click_pos_x;
        deltaY = lure_pos_y - click_pos_y;

        if (math.abs(deltaX) <= 10) and (math.abs(deltaY) <= 10) then
            ROD_CAST = 2;
            lure_pos_x = click_pos_x;
            lure_pos_y = click_pos_y;
        else
            angle = math.atan(deltaY, deltaX);
            speed_x = 3 -- rod cast speed
            speed_y = 2

            lure_pos_x = math.ceil(lure_pos_x - (speed_x * math.cos(angle)))
            lure_pos_y = math.ceil(lure_pos_y - (speed_y * math.sin(angle)))
        end
    end
end
