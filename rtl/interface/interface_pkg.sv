
 package interface_pkg;

    // positions of images
    localparam TEXT_OFFSET_X = 24;
    localparam TEXT_OFFSET_Y = 4 + 1;

    localparam HP_CURRENT_X = 100;
    localparam HP_CURRENT_Y = 700;
    localparam HP_ENEMY_X = 900;
    localparam HP_ENEMY_Y = 32;

    localparam STRENGTH_X = 300;
    localparam STRENGTH_Y = 700;

    localparam FUEL_X = 600;
    localparam FUEL_Y = 700;

    localparam TEXT_CENTER_OFFSET = 8;
    localparam ANGLE_X = 800;
    localparam ANGLE_Y = 700 + TEXT_CENTER_OFFSET;

    // border sizes
    localparam GRAY_BOX_INIT = 650;
    
    localparam HP_ICON_HEIGHT = 32;
    localparam HP_ICON_WIDTH  = 32;

    localparam BORDER_STR_HEIGHT = 32;
    localparam BORDER_STR_WIDTH  = 128;
    localparam BORDER_STR_OFFSET = 4;

    localparam BORDER_FUEL_HEIGHT = 32;
    localparam BORDER_FUEL_WIDTH  = 128;
    localparam BORDER_FUEL_OFFSET = 4;


endpackage
