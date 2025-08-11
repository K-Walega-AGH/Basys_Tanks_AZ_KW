/*
 * Module Author Antoni Zasadni
 * Module Co-Author Kacper Wałęga
 * 
 * Still have no idea how to do collision on terrain here and how to calculate dmg. TBD
 * 
 */


module projectile_ctl (
    input  logic clk,
    input  logic rst,

    input  logic fire_active,
    input  logic [3:0] degree,
    input  logic [7:0] projectile_strength,

    input  logic [11:0] barrel_end_xpos,
    input  logic [11:0] barrel_end_ypos,

    input  logic [11:0] enemy_xpos,
    input  logic [11:0] enemy_ypos,

    output logic collision,
    output logic show_bullet,
    
    output logic [11:0] projectile_xpos,
    output logic [11:0] projectile_ypos
);

    timeunit 1ns;
    timeprecision 1ps;

    import vga_pkg::*;
    import projectile_pkg::*;
    import tank_pkg::*;

    // FSM states
    typedef enum logic [2:0] {
        IDLE,
        FIRED,
        RISING,
        FALLING,
        COLLISION
    } projectile_state;

    projectile_state projectile_st, projectile_st_nxt;

    logic signed [11:0] xpos, ypos;
    logic signed [11:0] vx, vy;

    logic [3:0] missle_degree;
    logic signed [7:0] gravity = -1;

    logic [15:0] delay_ctr;

    always_comb begin
        case (degree)
            4'b0001: missle_degree = 4'd1;
            4'b0010: missle_degree = 4'd2;
            4'b0100: missle_degree = 4'd5;
            4'b1000: missle_degree = 4'd10;
            default: missle_degree = 4'd0;
        endcase
    end

    // FSM logic
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            projectile_st    <= IDLE;
            projectile_xpos  <= PRJTL_X;
            projectile_ypos  <= PRJTL_Y;
            xpos             <= PRJTL_X;
            ypos             <= PRJTL_Y;
            vx               <= 0;
            vy               <= 0;
            collision        <= 0;
            show_bullet      <= '0;
        end else begin
            case (projectile_st)

                IDLE: begin
                    if (fire_active) begin
                        vx <= missle_degree <<< 1; // *2
                        vy <= projectile_strength;
                        show_bullet <= '1;
                    end else begin
                        show_bullet <= '0;
                    end
                    projectile_xpos <= barrel_end_xpos;
                    projectile_ypos <= barrel_end_ypos;
                end



                RISING, FALLING: begin
                    if(delay_ctr < 60_000) begin
                        delay_ctr <= delay_ctr + 1;
                    end else begin
                        projectile_xpos <= projectile_xpos + vx;
                        projectile_ypos <= projectile_ypos - vy;
                        vy <= vy + gravity;
                        delay_ctr <= '0;
                    end
                     // START MOVING BULLET WITH PARABOLA
                    // CONSTANTLY CHECK FOR COLLISION; 
                    // IF COLLISION GO SO 'COLLISION' STATE
                    // CONSTANTLY DECREASE Y_VELOCITY AND IF SMALL ENOUGH GO TO FALLING
                    // LET BULLET START FALLIN
                    // CONSTANTLY CHECK FOR COLLISION; 
                    // IF COLLISION GO SO 'COLLISION' STATE
                    
                    if (
                        projectile_xpos >= enemy_xpos &&
                        projectile_xpos <= enemy_xpos + TANK_WIDTH &&
                        projectile_ypos >= enemy_ypos &&
                        projectile_ypos <= enemy_ypos + TANK_HEIGHT
                    ) begin
                        collision <= 1;
                    end else begin
                        collision <= 0;
                    end
                end

                COLLISION: begin
                    vx <= 0;
                    vy <= 0;
                end
            endcase

            projectile_st <= projectile_st_nxt;
        end
    end

    always_comb begin
        projectile_st_nxt = projectile_st;

        case (projectile_st)
            IDLE: begin
                if (fire_active)
                    projectile_st_nxt = RISING;
            end

            RISING: begin
                if (collision)
                    projectile_st_nxt = COLLISION;
                else if (vy <= 0)
                    projectile_st_nxt = FALLING;
                else
                    projectile_st_nxt = RISING;
            end

            FALLING: begin
                if (collision)
                    projectile_st_nxt = COLLISION;
                else
                    projectile_st_nxt = FALLING;
            end

            COLLISION: begin
                    // STOP THE BULLET (VELOCITY = 0)
                    // DETERMINE TYPE OF COLLISION (TERRAIN / TANK) AND DO STUFF ACCORDINGLY
            end
        endcase
    end

endmodule
