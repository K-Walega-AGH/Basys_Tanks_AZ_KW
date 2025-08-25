
 package tank_pkg;

    import terrain_pkg::*;

    // image parameters
    localparam TANK_WIDTH  = 64;
    localparam TANK_HEIGHT = 64;    // height of image rom, not the graphic
    localparam TANK_EMPTY_HEIGHT = 32;    // real height = 32
    // tank init positions
    localparam TANK_LEFT_X_INIT = 100;
    localparam TANK_LEFT_Y_INIT = TERRAIN_INIT - TANK_HEIGHT;
    localparam TANK_RIGHT_X_INIT = 900;
    localparam TANK_RIGHT_Y_INIT = TERRAIN_INIT - TANK_HEIGHT;
    // movement constants
    localparam MAX_FUEL = 100;
    localparam MOVE_STEP = 1;
    localparam MOVE_DELAY = 3_000_000;  // delay by 50ms, clk 60MHz
    // strength constants
    localparam MAX_STRENGTH = 1200;
    localparam STR_DELAY = 60_000;  // delay by 1ms, clk 60MHz
    // hit points
    localparam MAX_HP = 3;
    // delay const for barrel
    localparam ANGLE_DELAY = 3_000_000;  // delay by 50ms, clk 60MHz

    //initial tank vertical and horizontal position
    localparam TANK_XPOS_START = 50;
    localparam TANK_YPOS_START = 600 - (TANK_HEIGHT/4);


endpackage
