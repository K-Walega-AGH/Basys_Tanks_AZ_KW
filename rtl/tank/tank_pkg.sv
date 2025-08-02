
 package tank_pkg;

    // image parameters
    localparam TANK_WIDTH  = 128;
    localparam TANK_HEIGHT = 128;
    localparam TANK_REAL_HEIGHT = 50;
    // tank init position
    localparam TANK_X_INIT = 100;
    localparam TANK_Y_INIT = 572;
    // movement constants
    localparam MAX_FUEL = 100;
    localparam MOVE_STEP = 1;

    //initial tank vertical and horizontal position
    localparam TANK_XPOS_START = 50;
    localparam TANK_YPOS_START = 600 - (TANK_HEIGHT/4);


endpackage
