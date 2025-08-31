
module tank_ctl 
#(
    // Either 1 or 2
    //determines tank side of screen, roms and bullet vx direction
    PLAYER_ID = 1    
)(
    input  logic clk,
    input  logic rst,

    input  logic [10:0] hcount,
    input  logic [11:0] terrain_y,

    // moving[0] = 1 <== Moving input is pressed(left OR right);
    // moving[1] = 0 <== move LEFT
    // moving[1] = 1 <== move RIGHT
    input  logic [1:0] moving,      
    input  logic       fire_active,     // Fire bullet input was pressed, start increasing the power
    input  logic       your_turn,       // signal for your turn to fight
    input  logic       damaged,

    output logic  [1:0] hp,
    output logic  [6:0] fuel,
    output logic [10:0] projectile_strength,
    output logic [11:0] tank_xpos,
    output logic [11:0] tank_ypos
);

    timeunit 1ns;
    timeprecision 1ps;

    import vga_pkg::*;
    import tank_pkg::*;

    // Tank FSM states
    typedef enum logic [2:0] {
        IDLE,
        MOVING,
        FIRING,
        WAITING
    } tank_state;

    tank_state tank_st, tank_st_nxt;

    // tank local position
    logic [11:0] ypos_left, ypos_right, terrain_max;
    logic [11:0] xpos, xpos_nxt;
    logic [11:0] ypos, ypos_nxt;
    // tank fuel
    logic  [6:0] local_fuel, local_fuel_nxt;
    logic  [1:0] local_hp;
    // delay for movement
    logic [21:0] delay_ctr;
    // projectile strength value
    logic [10:0] projectile_strength_nxt;
    // variables for rising edge of your_turn for state change WAITING -> IDLE
    logic        your_turn_d, your_turn_posedge;

    // assignments
    assign hp = local_hp;
    assign fuel = local_fuel;
    assign tank_xpos = xpos;
    assign tank_ypos = ypos;
    assign your_turn_posedge = (!your_turn_d && your_turn);
    
    // states in action
    always_ff @(posedge clk) begin
        if (rst) begin
            if(PLAYER_ID == 1) begin
                xpos    <= TANK_LEFT_X_INIT;
                ypos    <= TANK_LEFT_Y_INIT;
                xpos_nxt    <= TANK_LEFT_X_INIT;
                ypos_nxt    <= TANK_LEFT_Y_INIT;
            end else begin
                xpos    <= TANK_RIGHT_X_INIT;
                ypos    <= TANK_RIGHT_Y_INIT;
                xpos_nxt    <= TANK_RIGHT_X_INIT;
                ypos_nxt    <= TANK_RIGHT_Y_INIT;
            end
            local_fuel        <= MAX_FUEL;
            local_fuel_nxt    <= MAX_FUEL;
            local_hp          <= MAX_HP;
            delay_ctr         <= '0;
            projectile_strength     <= '0;
            projectile_strength_nxt <= '0;
            your_turn_d <= '0;

            tank_st     <= IDLE;
        end else begin
            case(tank_st)
                IDLE: begin
                    // player thinking...
                    if(fire_active) begin
                        delay_ctr <= '0;
                    end
                    xpos_nxt <= xpos;
                end

                MOVING: begin
                    if(moving[0])begin
                        // check local_fuel
                        if(local_fuel > 0) begin
                            if(delay_ctr < MOVE_DELAY) begin
                                delay_ctr <= delay_ctr + 1;
                            end else begin
                                if (moving[1]) begin    // RIGHT
                                    if(xpos < (HOR_PIXELS -TANK_WIDTH-1)) begin
                                        xpos_nxt <= xpos + MOVE_STEP;
                                    end else begin
                                        xpos_nxt <= xpos;
                                    end

                                end else begin          // LEFT
                                    if(xpos > 0) begin
                                        xpos_nxt <= xpos - MOVE_STEP;
                                    end else begin
                                        xpos_nxt <= xpos;
                                    end
                                end
                                delay_ctr <= '0;
                                local_fuel_nxt <= local_fuel - MOVE_STEP;
                            end
                        end else begin
                            // cant move, bcs no local_fuel
                            // maybe flicker/blink indicator 2 times on red->white->red
                            xpos_nxt <= xpos;
                        end
                    end else begin
                        xpos_nxt <= xpos;
                    end
                    if(fire_active) begin
                        delay_ctr <= '0;
                    end
                end

                FIRING: begin
                    if(fire_active) begin
                        if(delay_ctr < STR_DELAY) begin
                            delay_ctr <= delay_ctr + 1;
                        end else begin
                            if(projectile_strength >= 0 && projectile_strength <= MAX_STRENGTH)
                                projectile_strength_nxt <= projectile_strength + 1;
                            else
                                projectile_strength_nxt <= projectile_strength;
                            delay_ctr <= '0;
                        end
                    end
                    xpos_nxt <= xpos;
                end

                WAITING: begin
                    //wait for hit or 2nd player to end turn
                    if(damaged == 1) begin
                        if(local_hp > 0) begin
                            local_hp <= local_hp - 1;
                        end else begin
                            local_hp <= local_hp;
                        end
                    end else begin
                        local_hp <= local_hp;
                    end
                    if(your_turn_posedge) begin
                        local_fuel_nxt <= MAX_FUEL;
                        projectile_strength_nxt <= '0;
                    end
                    xpos_nxt <= xpos;
                end
            endcase

            // calculate ypos_nxt based on terrain max value under tank

            if(ypos_right <= ypos_left) begin
                if(hcount == (xpos_nxt+TANK_WIDTH-6)) begin
                    ypos_nxt <= terrain_max;
                end
            end else begin
                if(hcount == xpos_nxt+6) begin
                    ypos_nxt <= terrain_max;
                end
            end

            // update values & state
            local_fuel <= local_fuel_nxt;
            xpos <= xpos_nxt;
            ypos <= ypos_nxt;
            projectile_strength <= projectile_strength_nxt;
            your_turn_d <= your_turn;
            tank_st <= tank_st_nxt;
        end
    end

    // SM logic
    always_comb begin : SM_logic
        case (tank_st)
            IDLE: begin
                if (!your_turn) begin
                    tank_st_nxt = WAITING;
                end else if (fire_active) begin
                    tank_st_nxt = FIRING;
                end else if (moving[0] && local_fuel > 0) begin
                    tank_st_nxt = MOVING;
                end else begin
                    tank_st_nxt = IDLE;
                end
            end

            MOVING: begin
                if (fire_active) begin   // if 1 then stop moving
                    tank_st_nxt = FIRING;
                end else begin
                    tank_st_nxt = MOVING;
                end
            end

            FIRING: begin
                if(!fire_active) begin
                    tank_st_nxt = WAITING;
                end else begin
                    tank_st_nxt = FIRING;
                end
            end

            WAITING: begin
                if (your_turn_posedge) begin
                    tank_st_nxt = IDLE;
                end else begin
                    tank_st_nxt = WAITING;
                end
            end
        endcase
    end : SM_logic
    
always_comb begin
    if(hcount == xpos_nxt-2) begin
        ypos_left  = terrain_y - TANK_HEIGHT;
        terrain_max  = terrain_y - TANK_HEIGHT;
    end else if(hcount > xpos_nxt && hcount < (xpos_nxt+TANK_WIDTH)) begin
        if(terrain_y > terrain_max) begin
            terrain_max  = terrain_y - TANK_HEIGHT;
        end   
    end else if(hcount == (xpos_nxt+TANK_WIDTH+2)) begin
        ypos_right = terrain_y - TANK_HEIGHT;
    end
end

endmodule
