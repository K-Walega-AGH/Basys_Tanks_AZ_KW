module tank_ctl (
    input  logic clk,
    input  logic rst,

    input  logic [1:0] moving,      
    // moving[0] = 1 <== Moving input is pressed(left OR right);
    // moving[1] = 0 <== move LEFT
    // moving[1] = 1 <== move RIGHT
    input  logic       fire_active,     // Fire bullet input was pressed, start increasing the power
    input  logic       your_turn,       // signal for your turn to fight

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
        PREP_BULLET,
        SHOOT,
        WAITING
    } tank_state;

    tank_state tank_st, tank_st_nxt;

    // tank local position
    logic [11:0] xpos, xpos_nxt;
    logic [11:0] ypos, ypos_nxt;
    // tank fuel
    logic [6:0] fuel, fuel_nxt;

    assign tank_xpos = xpos;
    assign tank_ypos = ypos;
    // xxxx
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            xpos    <= TANK_X_INIT;
            ypos    <= TANK_Y_INIT;
            xpos_nxt    <= TANK_X_INIT;
            ypos_nxt    <= TANK_Y_INIT;
            fuel        <= MAX_FUEL;
            fuel_nxt    <= MAX_FUEL;
            tank_st     <= WAITING; // ONLY FOR TESTBENCH, then IDLE
        end else begin
            tank_st <= tank_st_nxt;
            case(tank_st)
                IDLE: begin
                    // player thinking...
                end

                MOVING: begin
                    // check fuel
                    if(fuel > 0) begin
                        fuel_nxt <= fuel - MOVE_STEP;
                        //check map border
                        if((xpos > 0) && (xpos <= (HOR_PIXELS - TANK_WIDTH))) begin  
                            if (moving[1]) begin    // RIGHT
                                xpos_nxt <= xpos + MOVE_STEP;
                                ypos_nxt <= ypos;
                            end else begin          // LEFT
                                xpos_nxt <= xpos - MOVE_STEP;
                                ypos_nxt <= ypos;
                            end
                        end else begin
                            xpos_nxt <= xpos;
                            ypos_nxt <= ypos;
                        end
                    end else begin
                        // cant move, bcs no fuel
                        xpos_nxt <= xpos;
                        ypos_nxt <= ypos;
                        // maybe flicker/blink indicator 2 times on red->white->red
                    end
                end

                PREP_BULLET: begin
                    // here send signal to other module that will begin counting
                    // when fire_active = 0 stop the counter
                    // value of that counter sent to bullet module(bullet translates it to velocity)
                end

                SHOOT: begin
                end

                WAITING: begin
                    //do nothing, wait for 2nd player
                    if(your_turn) begin
                        fuel <= MAX_FUEL;
                    end
                end
            endcase

            fuel <= fuel_nxt;
            xpos <= xpos_nxt;
            ypos <= ypos_nxt; // na razie jest plaski teren wiec nie ma znaczneia
        end
    end

    // SM logic
    always_comb begin
        tank_st_nxt = tank_st;

        case (tank_st)
            IDLE: begin
                if (fire_active)
                    tank_st_nxt = PREP_BULLET;
                else if (moving[0] && fuel > 0)
                    tank_st_nxt = MOVING;
            end

            MOVING: begin
                if (!moving[0]) begin   // if 0 then stop moving
                    tank_st_nxt = IDLE;
                end else begin
                    tank_st_nxt = MOVING;
                end
            end

            PREP_BULLET: begin
                if(!fire_active) begin
                    tank_st_nxt = SHOOT;
                end else begin
                    tank_st_nxt = PREP_BULLET;
                end
            end

            SHOOT: begin
                if(fuel > 0) begin
                    tank_st_nxt = IDLE;
                end else begin
                    tank_st_nxt = WAITING;
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
