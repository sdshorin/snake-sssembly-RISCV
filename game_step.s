
.data
POS:
.asciz "pos "


.text
# this function called every frame from main loop.
# a0 - input from user. May be wasd or 0
game_step:
    pushw(ra)
    pushw(s0)
    pushw(s1)

    mv s1, a0 # save last input

    jal ra, FUNC.prepare_display # draw all screen or just reset cell with snake and food

    mv a0, s1 # first argument - last input
    jal ra, FUNC_update_snake_direction # update direction with input from keyboard
    jal ra, FUNC_move_snake # move snake according to direction
    jal ra, FUNC_detect_collisions

    # print current position
    mv s0, a0
    mv s1, a1
    # put_string(POS)
    # print_int(s0)
    # put_char(' ')
    # print_int(s1)
    # newline

    jal ra, FUNC_check_food # Check is snake can eat food
    
    #jal ra, FUNC.reset_display
    jal ra, FUNC_draw_food
    # jal ra, FUNC_draw_snake
    jal ra, FUNC.draw_snake_pretty


    popw(s1)
    popw(s0)
    popw(ra)
    jalr zero, 0(ra)


# draw bakground in first frame, paint over snake and props in next
FUNC.prepare_display:
    pushw(ra)
    pushw(s0)

    la t0, is_first_frame_drawn
    lw t0, 0(t0)
    
    beqz t0, prepare_display.draw_background
    j prepare_display.paint_over

prepare_display.draw_background:
    la t0, is_first_frame_drawn
    li t1, 1
    sw t1, 0(t0)
    
    # jal ra, FUNC.reset_display
    
    jal ra, FUNC.reset_display_with_titles
    j prepare_display.return

prepare_display.paint_over:
    jal ra, FUNC.paint_over_titles
    j prepare_display.return

prepare_display.return:
    popw(s0)
    popw(ra)
    jalr zero, 0(ra)



.include "circle_array.s"
.include "snake.s"
.include "display.s"
