
.data
POS:
.asciz "pos "


.text
# this function called every frame from main loop.
# a0 - input from user. May be wasd or 0
game_step:
    pushw(ra)
    pushw(s0)

    # transfer a0 from game_step arguments to FUNC_update_snake_direction
    jal ra, FUNC_update_snake_direction # update direction with input from keyboard
    jal ra, FUNC_move_snake # move snake according to direction
    jal ra, FUNC_detect_collisions

    # print current position
    mv s0, a0
    mv s1, a1
    put_string(POS)
    print_int(s0)
    put_char(' ')
    print_int(s1)
    newline

    jal ra, FUNC_check_food # Check is snake can eat food
    
    jal ra, FUNC_reset_display
    jal ra, FUNC_draw_food
    # jal ra, FUNC_draw_snake
    jal ra, FUNC.draw_snake_pretty


    popw(s0)
    popw(ra)
    jalr zero, 0(ra)



.include "circle_array.s"
.include "snake.s"
.include "display.s"
