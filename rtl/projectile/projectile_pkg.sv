
package projectile_pkg; 

    // image parameters
    localparam PROJECTILE_WIDTH  = 8;
    localparam PROJECTILE_HEIGHT = 8;
    // radius of hit (pixels)
    localparam PROJECTILE_RADIUS = 24;
    // delay of bullet movement on screen
    localparam BULLET_DELAY = 60_000; // delay by 10ms, clk 60MHz
    // bullet's gravity (and everything else's too probably :P)
    localparam GRAVITY = 514; // IN FIXED POINT Q12.20
    // initial position (not rly relevant just here for rst)
    localparam PRJTL_X_INIT = 10;
    localparam PRJTL_Y_INIT = 10;


endpackage