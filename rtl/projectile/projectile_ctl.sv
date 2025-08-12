/*
 * Module Author: Antoni Zasadni
 * Module Co-Author: Kacper Wałęga
 * 
 * Description:
 * Projectile behaviour and action control on missles with enviorment.
 */


module projectile_ctl (
    input  logic clk,
    input  logic rst,

    input  logic        fire_active,
    input  logic [31:0] sin_val,
    input  logic [31:0] cos_val,
    input  logic [10:0] projectile_strength,

    input  logic [11:0] barrel_end_xpos,
    input  logic [11:0] barrel_end_ypos,

    input  logic [11:0] enemy_xpos,
    input  logic [11:0] enemy_ypos,

    output logic        collision,
    output logic        show_bullet,
    
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
        FIRING,
        RISING,
        FALLING,
        COLLISION,
        WAITING
    } projectile_state;

    projectile_state projectile_st, projectile_st_nxt;

    //projectile position in Q12.20
    logic [31:0] xpos_nxt, ypos_nxt;
    //velocity values in Q12.20
    logic [31:0] vx, vy;
    logic [63:0] temp_vx, temp_vy;
    // delay
    logic [15:0] delay_ctr;

    // FSM logic
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            vx        <= '0;
            vy        <= '0;
            temp_vx     <= '0;
            temp_vy     <= '0;
            xpos_nxt  <= PRJTL_X_INIT;
            ypos_nxt  <= PRJTL_Y_INIT;
            delay_ctr <= '0;

            collision       <= '0;
            show_bullet     <= '0;

            projectile_xpos <= PRJTL_X_INIT;
            projectile_ypos <= PRJTL_Y_INIT;

            projectile_st    <= IDLE;
        end else begin
            case (projectile_st)
                IDLE: begin
                    show_bullet <= '0;
                    vx          <= '0;
                    vy          <= '0;
                    temp_vx     <= '0;
                    temp_vy     <= '0;
                end

                FIRING: begin
                    if (fire_active) begin
                        show_bullet <= '0;
                    end else begin
                        show_bullet <= '1;
                    end
                    temp_vx <= (cos_val*GRAVITY)>>20;
                    temp_vy <= (sin_val*GRAVITY)>>20;
                    vx      <= temp_vx*projectile_strength;  // here put velocity based on strenght & angle
                    vy      <= temp_vy*projectile_strength;  // here put velocity based on strenght & angle
                    xpos_nxt[31:20] <= barrel_end_xpos;
                    ypos_nxt[31:20] <= barrel_end_ypos;
                end

                RISING: begin
                    if(delay_ctr < BULLET_DELAY) begin
                        delay_ctr <= delay_ctr + 1;
                    end else begin
                        delay_ctr <= '0;
                        xpos_nxt <= xpos_nxt + vx;
                        ypos_nxt <= ypos_nxt - vy;
                        if(vy >= GRAVITY) begin
                            vy <= vy - GRAVITY;
                        end else begin
                            vy <= '0;
                        end
                    end
                    // check for collision
                    if (
                        xpos_nxt[31:20] >= enemy_xpos &&
                        xpos_nxt[31:20] <= enemy_xpos + TANK_WIDTH &&
                        ypos_nxt[31:20] >= enemy_ypos &&
                        ypos_nxt[31:20] <= enemy_ypos + TANK_HEIGHT
                    ) begin
                        collision <= 1;
                    end else begin
                        collision <= 0;
                    end
                end
                FALLING: begin
                    if(delay_ctr < BULLET_DELAY) begin
                        delay_ctr <= delay_ctr + 1;
                    end else begin
                        delay_ctr <= '0;
                        xpos_nxt <= xpos_nxt + vx;
                        ypos_nxt <= ypos_nxt + vy;
                        if(ypos_nxt[31:20] + vy[31:20] <= VER_PIXELS) begin
                            vy <= vy + GRAVITY;
                        end else begin
                            vy <= '0;
                        end
                    end
                    // check for collision
                    if (
                        xpos_nxt[31:20] >= enemy_xpos &&
                        xpos_nxt[31:20] <= enemy_xpos + TANK_WIDTH &&
                        ypos_nxt[31:20] >= enemy_ypos &&
                        ypos_nxt[31:20] <= enemy_ypos + TANK_HEIGHT
                    ) begin
                        collision <= 1;
                    end else begin
                        collision <= 0;
                    end
                end

                COLLISION: begin
                end

                WAITING: begin
                    //wait for start of turn
                end
            endcase

            projectile_st <= projectile_st_nxt;
            projectile_xpos  <= xpos_nxt[31:20];
            projectile_ypos  <= ypos_nxt[31:20];
        end
    end

    always_comb begin
        projectile_st_nxt = projectile_st;

        case (projectile_st)
            IDLE: begin
                if (fire_active)
                    projectile_st_nxt = FIRING;
                else
                    projectile_st_nxt = IDLE;
            end

            FIRING: begin
                if(!fire_active)
                    projectile_st_nxt = RISING;
                else
                    projectile_st_nxt = FIRING;
            end

            RISING: begin
                if (collision)
                    projectile_st_nxt = COLLISION;
                else
                    if(vy <= GRAVITY)
                        projectile_st_nxt = FALLING;
                    else
                        projectile_st_nxt = RISING;
            end

            FALLING: begin
                if (collision)
                    projectile_st_nxt = COLLISION;
                else
                    if(ypos_nxt[31:20] + vy[31:20] > VER_PIXELS)
                        projectile_st_nxt = IDLE;//WAITING;
                    else
                        projectile_st_nxt = FALLING;
            end

            COLLISION: begin
                    // STOP THE BULLET (VELOCITY = 0)
                    // DETERMINE TYPE OF COLLISION (TERRAIN / TANK) AND DO STUFF ACCORDINGLY
            end

            WAITING: begin
                if(collision)   // reqired your_turn ; not connected yet
                    projectile_st_nxt = IDLE;
                else
                    projectile_st_nxt = WAITING;
            end
        endcase
    end

endmodule
