
module tank_ctl (
    input  logic clk,
    input  logic rst,

    // moving[0] = 1 <== Moving input is pressed(left OR right);
    // moving[1] = 0 <== move LEFT
    // moving[1] = 1 <== move RIGHT
    input  logic [1:0] moving,      
    input  logic       fire_active,     // Fire bullet input was pressed, start increasing the power
    input  logic       your_turn,       // signal for your turn to fight

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
    logic [11:0] xpos, xpos_nxt;
    logic [11:0] ypos, ypos_nxt;
    // tank fuel
    logic [10:0] fuel, fuel_nxt;
    // delay for movement
    logic [19:0] delay_ctr;
    //
    logic [10:0] projectile_strength_nxt;

    assign tank_xpos = xpos;
    assign tank_ypos = ypos;
    // state in action
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            xpos    <= TANK_X_INIT;
            ypos    <= TANK_Y_INIT;
            xpos_nxt    <= TANK_X_INIT;
            ypos_nxt    <= TANK_Y_INIT;
            fuel        <= MAX_FUEL;
            fuel_nxt    <= MAX_FUEL;
            delay_ctr   <= '0;
            projectile_strength     <= '0;
            projectile_strength_nxt <= '0;

            tank_st     <= IDLE;
        end else begin
            case(tank_st)
                IDLE: begin
                    // player thinking...
                    if(fire_active) begin
                        delay_ctr <= '0;
                    end
                end

                MOVING: begin
                    if(moving[0])begin
                        // check fuel
                        if(fuel > 0) begin
                            if(delay_ctr < MOVE_DELAY) begin
                                delay_ctr <= delay_ctr + 1;
                            end else begin
                                if (moving[1]) begin    // RIGHT
                                    if(xpos < (HOR_PIXELS -TANK_WIDTH-1)) begin
                                        xpos_nxt <= xpos + MOVE_STEP;
                                    end else begin
                                        xpos_nxt <= xpos;
                                    end
                                    ypos_nxt <= ypos;
                                end else begin          // LEFT
                                    if(xpos > 0) begin
                                        xpos_nxt <= xpos - MOVE_STEP;
                                    end else begin
                                        xpos_nxt <= xpos;
                                    end
                                    ypos_nxt <= ypos;
                                end
                                delay_ctr <= '0;
                                fuel_nxt <= fuel - MOVE_STEP;
                            end
                        end else begin
                            // cant move, bcs no fuel
                            // maybe flicker/blink indicator 2 times on red->white->red
                            xpos_nxt <= xpos;
                            ypos_nxt <= ypos;
                        end
                    end else begin
                        xpos_nxt <= xpos;
                        ypos_nxt <= ypos;
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
                            if(projectile_strength >= 0 && projectile_strength <= 1500)
                                projectile_strength_nxt <= projectile_strength + 1;
                            else
                                projectile_strength_nxt <= projectile_strength;
                            delay_ctr <= '0;
                        end
                    end
                end

                WAITING: begin
                    //do nothing, wait for 2nd player
                    if(your_turn) begin
                        fuel <= MAX_FUEL;
                        // uncomment after tb
                        //projectile_strength_nxt <= '0;
                    end

                end
            endcase
            
            fuel <= fuel_nxt;
            xpos <= xpos_nxt;
            ypos <= ypos_nxt; // na razie jest plaski teren wiec nie ma znaczneia
            projectile_strength <= projectile_strength_nxt;
            tank_st <= tank_st_nxt;
        end
    end

    // SM logic
    always_comb begin
        case (tank_st)
            IDLE: begin
                if (fire_active)
                    tank_st_nxt = FIRING;
                else if (moving[0] && fuel > 0)
                    tank_st_nxt = MOVING;
            end

            MOVING: begin
                if (fire_active) begin   // if 0 then stop moving
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
                if (your_turn) begin
                    tank_st_nxt = IDLE;
                end else begin
                    tank_st_nxt = WAITING;
                end
            end
        endcase
    end

endmodule
