
 package tank_pkg;

    // image parameters
    localparam TANK_WIDTH  = 64;
    localparam TANK_HEIGHT = 64;    // real height = 32
    // tank init position
    localparam TANK_X_INIT = 100;
    localparam TANK_Y_INIT = 700 - TANK_HEIGHT;
    // movement constants
    localparam MAX_FUEL = 1000;
    localparam MOVE_STEP = 1;
    localparam MOVE_DELAY = 600_000;  // delay by 10ms, clk 60MHz
    // const for barrel
    localparam ANGLE_DELAY = 600_000;  // delay by 10ms, clk 60MHz

    //initial tank vertical and horizontal position
    localparam TANK_XPOS_START = 50;
    localparam TANK_YPOS_START = 600 - (TANK_HEIGHT/4);


endpackage
