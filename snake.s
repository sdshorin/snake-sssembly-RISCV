
.text

.eqv .current_direction s0
.eqv .snake_ptr s1
.eqv .circle_array s2

.eqv .t_temp_sn, t0

# check is direction changing is valid and store new value in snake_data
# a0 - new direction.Can be WASD or zero
FUNC_update_snake_direction:
    pushw(ra)
    pushw(.current_direction)
    pushw(.snake_ptr)
    beqz a0, FUNC_return_upt_s_dir # empty input - save old direction

    jal ra, FUNC_decode_input # convert WASD in a0 to TOP LEFT RIGHT BOTTOM 

    la .snake_ptr, snake_data
    lw .current_direction, 0(.snake_ptr) # load the direction of snake in the previous frame

# start check from TOP
    li t0, TOP
    bne t0, .current_direction, skip_top # check is current_direction is TOP
    li t0, BOTTOM
    beq t0, a0, FUNC_return_upt_s_dir # Can't change from top to bottom
    sw a0, 0(.snake_ptr) # Change direction

skip_top: # check LEFT
    li t0, LEFT
    bne t0, .current_direction, skip_left # check is current_direction is LEFT
    li t0, RIGHT
    beq t0, a0, FUNC_return_upt_s_dir # Can't change from LEFT to RIGHT
    sw a0, 0(.snake_ptr) # Change direction
skip_left: # check BOTTOM
    li t0, BOTTOM
    bne t0, .current_direction, skip_bottom # check is current_direction is BOTTOM
    li t0, TOP
    beq t0, a0, FUNC_return_upt_s_dir # Can't change from BOTTOM to TOP
    sw a0, 0(.snake_ptr) # Change direction
skip_bottom: # check RIGHT
    li t0, RIGHT
    bne t0, .current_direction, FUNC_return_upt_s_dir # check is current_direction is RIGHT
    li t0, LEFT
    beq t0, a0, FUNC_return_upt_s_dir # Can't change from RIGHT to LEFT
    sw a0, 0(.snake_ptr) # Change direction
# end check
FUNC_return_upt_s_dir:
    popw(.snake_ptr)
    popw(.current_direction)
    popw(ra)
    jalr zero, 0(ra) # return update_snake_direction


# Convert WASD in a0 to TOP LEFT RIGHT BOTTOM 
FUNC_decode_input:
decode_w:
    li t0, 'w'
    bne t0, a0, decode_a
    li a0, TOP
    j FUNC_return_decode_input
decode_a:
    li t0, 'a'
    bne t0, a0, decode_s
    li a0, LEFT
    j FUNC_return_decode_input
decode_s:
    li t0, 's'
    bne t0, a0, decode_d
    li a0, BOTTOM
    j FUNC_return_decode_input
decode_d:
    li t0, 'd'
    bne t0, a0, FUNC_return_decode_input
    li a0, RIGHT
    j FUNC_return_decode_input
FUNC_return_decode_input: # return decode_input
    jalr zero, 0(ra)


# move snake in the chosen direction
# return new head position in (a0, a1): (x, y)
FUNC_move_snake:
    pushw(ra)
    pushw(.snake_ptr)
    pushw(.current_direction)
    pushw(.circle_array)

    # load snake data
    la .snake_ptr, snake_data
    lw .current_direction, 0(.snake_ptr) # load the direction of snake in the previous frame
    mv .circle_array, .snake_ptr
    addi .circle_array, .circle_array, 4 # pointer to snake circle array

    # get first snake segment
    mv a0, .circle_array
    li a1, 0
    jal ra, FUNC_circle_array_get_elem
    # a0 - x of head
    # a1 - y of head

    # add direction to coordinates
    li .t_temp_sn, TOP
    bne .current_direction, .t_temp_sn, move_check_left 
    addi a1, a1, -1 # move TOP: y -= 1
    j move_remainder_by_field

move_check_left:
    li .t_temp_sn, LEFT
    bne .current_direction, .t_temp_sn, move_check_bottom
    addi a0, a0, -1 # move LEFT: x -= 1
    j move_remainder_by_field
move_check_bottom:
    li .t_temp_sn, BOTTOM
    bne .current_direction, .t_temp_sn, move_check_right
    addi a1, a1, 1 # move BOTTOM: y += 1
    j move_remainder_by_field
move_check_right:
    li .t_temp_sn, RIGHT
    bne .current_direction, .t_temp_sn, move_remainder_by_field
    addi a0, a0, 1 # move RIGHT: x += 1
    j move_remainder_by_field
    
move_remainder_by_field:
    #reminded by field size
    li .t_temp_sn, FIELD_WIDTH
    addi a0, a0, FIELD_WIDTH # to handle negative numbers
    rem a0, a0, .t_temp_sn # x = x % FIELD_WIDTH
    li .t_temp_sn, FIELD_HEIGHT
    addi a1, a1, FIELD_HEIGHT # to handle negative numbers
    rem a1, a1, .t_temp_sn # y = y % FIELD_WIDTH

    mv a2, a1 # a2 = y
    mv a1, a0 # a1 = x
    mv s0, a1 # s0 = x  - save  coordinate for retun from this function
    mv s1, a2 # s0 = y
    la a0, snake_circle_array # a0 = array_ptr
    jal ra, FUNC_circle_array_push_front # push_front new elem

    la a0, snake_circle_array # a0 = array_ptr
    jal ra, FUNC_circle_array_pop_back # remove last elem from array

    mv a0, s0 # return x in a0
    mv a1, s1 # return x in a1

    popw(.circle_array)
    popw(.current_direction)
    popw(.snake_ptr)
    popw(ra)
    jalr zero, 0(ra)


# draw all segments of snake
FUNC_draw_snake:
    pushw(ra)
    pushw(.circle_array)
    pushw(s3)
    # get first snake segment
    la .circle_array, snake_data
    addi .circle_array, .circle_array, 4 # pointer to snake circle array

    lw s3, 0(.circle_array) # save snake lengthto s3

draw_snake_loop:
    beqz s3, FUNC_return_draw_snake

    mv a0, .circle_array
    addi a1, s3, -1 # get next index
    jal ra, FUNC_circle_array_get_elem
    # # a0 - x of head
    # # a1 - y of head
    li a2, 0xff0000
    # # a0 - x
    # # a1 - y
    # # a2 - color
    jal ra, FUNC_draw_cell
    addi s3, s3, -1
    j draw_snake_loop

FUNC_return_draw_snake:
    popw(s3)
    popw(.circle_array)
    popw(ra)
    jalr zero, 0(ra)


FUNC_increase_snake:
    nop # FUNC_increase_snake
    pushw(ra)
    pushw(.circle_array)
    pushw(s3)

    # load snake head
    la .circle_array, snake_circle_array # get snake struct

    mv a0, .circle_array
    li a1, 0
    jal ra, FUNC_circle_array_get_elem
    # # a0 - x
    # # a1 - y

    mv a2, a1 # a2 = y
    mv a1, a0 # a1 = x
    la a0, snake_circle_array # a0 = array_ptr
    jal ra, FUNC_circle_array_push_front # push_front new elem

    popw(s3)
    popw(.circle_array)
    popw(ra)
    jalr zero, 0(ra)


FUNC_detect_collisions:
    nop # FUNC_increase_snake
    pushw(ra)
    pushw(.circle_array)
    pushw(s3)
    pushw(s4)
    pushw(s5)
    pushw(s6)
    pushw(s7)
    pushw(s8)

    la .circle_array, snake_circle_array # init pointer to snake struct
    mv a0, .circle_array
    li a1, 0
    jal ra, FUNC_circle_array_get_elem # get first snake segment

    mv s4, a0 # s4 stores the x coordinate of the head
    mv s5, a1 # s5 stores the x coordinate of the head

    lw s3, 0(.circle_array) # save snake lengthto s3
    li s8, 2 # check snake from third element
    bge s8, s3, RETURN_detect_collisions # snake too short

    li s8, 2 # check snake from third element
    print_int(s3)
detect_collisions_loop:
    bge s8, s3, RETURN_detect_collisions

    mv a0, .circle_array
    mv a1, s8 # get next index
    jal ra, FUNC_circle_array_get_elem
    # # a0 - x of head
    # # a1 - y of head
    mv s6, a0
    mv s7, a1
    addi s8, s8, 1

    newline
    print_int(s6)
    put_char(' ')
    print_int(s7)
    put_char('-')
    print_int(s4)
    put_char(' ')
    print_int(s5)
    newline
    bne s6, s4, detect_collisions_loop
    bne s7, s5, detect_collisions_loop
    put_string(BOOM_STR)
    nop # GAME END
    exit
    
RETURN_detect_collisions:
    popw(s8)
    popw(s7)
    popw(s6)
    popw(s5)
    popw(s4)
    popw(s3)
    popw(.circle_array)
    popw(ra)
    jalr zero, 0(ra)


FUNC_check_food:
    nop # FUNC_check_food
    pushw(ra)
    pushw(.circle_array)
    pushw(s3)
    
    la .circle_array, snake_circle_array # get snake struct

    mv a0, .circle_array
    li a1, 0
    jal ra, FUNC_circle_array_get_elem

    la t0, food_position # load food position
    # # a0 - x
    lw t1, 0(t0) # food x
    lw t2, 4(t0) # food y

    bne a0, t1,FUNC_return_check_food
    bne a1, t2,FUNC_return_check_food

    put_char('*')
    jal ra, FUNC_increase_snake
    jal ra, FUNC_spawn_new_food

FUNC_return_check_food:
    popw(s3)
    popw(.circle_array)
    popw(ra)
    jalr zero, 0(ra)


# draw snake food
FUNC_draw_food:
    pushw(ra)
    pushw(.circle_array)
    pushw(s3)

    la t0, food_position # load food position
    # # a0 - x
    lw a0, 0(t0)
    # # a1 - y
    lw a1, 4(t0)

    la t0, food_assert
    lw t1, 0(t0) # load current prop type
    li t0, 0 # 0 - apple
    beq t1, t0, draw_food.apple
    li t0, 1 # 1 - mouse
    beq t1, t0, draw_food.mouse
    li t0, 2 # 1 - mushroom
    beq t1, t0, draw_food.mushroom

    # a2 - pointer to texture
draw_food.mushroom:
    la a2, asset_mushroom
    j draw_food.call_draw_tile
draw_food.mouse:
    la a2, asset_mouse
    j draw_food.call_draw_tile
draw_food.apple:
    la a2, asset_apple
    j draw_food.call_draw_tile

draw_food.call_draw_tile:
    jal ra, FUNC.draw_tile

    popw(s3)
    popw(.circle_array)
    popw(ra)
    jalr zero, 0(ra)

FUNC_spawn_new_food:
    nop # FUNC_spawn_new_food
    pushw(ra)
    pushw(.circle_array)
    pushw(s3)
    
    mv   a0, zero
    li   a1, FIELD_WIDTH 
    li   a7, 42
    ecall  # random [0, FIELD_WIDTH)
    mv t1, a0

    mv   a0, zero
    li   a1, FIELD_HEIGHT 
    li   a7, 42
    ecall  # random [0, FIELD_HEIGHT)
    mv t2, a0

    la t0, food_position # load food position
    sw t1, 0(t0) # food x
    sw t2, 4(t0) # food y

    mv   a0, zero
    li   a1, FOOD_PROPS_QUANTITY 
    li   a7, 42
    ecall  # random [0, FOOD_PROPS_QUANTITY)
    mv t1, a0

    la t0, food_assert
    sw t1, 0(t0) # save the new prop type

    put_char('F')
    popw(s3)
    popw(.circle_array)
    popw(ra)
    jalr zero, 0(ra)



