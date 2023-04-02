

.eqv .t_display_ptr t0
.eqv .t_max_ptr t1
.eqv .t_color t2
.eqv .t_temp_dis t3
.eqv .t_lines_to_draw t4



# This function fills the entire display with a BACKGROUND_COLOR color
# which is the background color of the game field.
# It's not in use now
FUNC_reset_display:
    li .t_display_ptr, DISPLAY_ADDRESS # FUNC_reset_display

    li .t_max_ptr, SCREEN_WIDTH
    li .t_temp_dis, SCREEN_HEIGHT
    mul .t_max_ptr, .t_max_ptr, .t_temp_dis # SCREEN_WIDTH * FIELD_HEIGHT
    li .t_temp_dis, 4 #128 # 4 * 
    mul .t_max_ptr, .t_max_ptr, .t_temp_dis # .t_max_ptr = screen size in bytes
    add .t_max_ptr, .t_max_ptr, .t_display_ptr
    li .t_color, BACKGROUND_COLOR

reset_screen_loop:
    bge .t_display_ptr, .t_max_ptr, FUNC_return_reset_display # reset_screen_loop
    sw .t_color, 0(.t_display_ptr)
    addi .t_display_ptr, .t_display_ptr, 4
    j reset_screen_loop


FUNC_return_reset_display:
    jalr zero, 0(ra) # FUNC_return_reset_display
    


# This function fills the entire display
# with the background color and adds decorations
# to the game field based on the coordinates.
FUNC.reset_display_with_titles:
    .eqv .current_line, s0
    .eqv .current_row, s1
    .eqv .max_lines, s2
    .eqv .max_rows, s3

    pushw(ra)
    pushw(.current_line)
    pushw(.current_row)
    pushw(.max_lines)
    pushw(.max_rows)

    li .current_line, 0
    li .max_lines, FIELD_HEIGHT
    li .max_rows, FIELD_WIDTH
reset_display_with_titles.loop.lines:
    beq .current_line, .max_lines, reset_display_with_titles.return
    li .current_row, 0
    
reset_display_with_titles.loop.lines.rows:
    beq .current_row, .max_rows, reset_display_with_titles.loop.lines.rows_ends
    # call func
    mv a0, .current_row
    mv a1, .current_line
    jal ra, FUNC.reset_cell

    addi .current_row, .current_row, 1
    j reset_display_with_titles.loop.lines.rows

reset_display_with_titles.loop.lines.rows_ends:
    addi .current_line, .current_line, 1
    j reset_display_with_titles.loop.lines

reset_display_with_titles.return:
    
    popw(.max_rows)
    popw(.max_lines)
    popw(.current_row)
    popw(.current_line)
    popw(ra)
    jalr zero, 0(ra) # reset_display_with_titles


 # This function is used to paint over a cell to hide its content.
 # It takes the x and y coordinates as arguments and resets
 # the cell by drawing over it with the background color or map decoration.
# a0 - x
# a1 - y
FUNC.reset_cell:
    pushw(ra)
    pushw(s0)
    pushw(s1)

    mv s0, a0
    mv s1, a1
    jal ra, FUNC.check_and_draw_map_decoration
    bne a0, zero, reset_cell.cell_reseted # cell was already reseted in FUNC.check_and_draw_map_decoration
    
    mv a0, s0
    mv a1, s1

    li a2, BACKGROUND_COLOR
    jal ra, FUNC_draw_cell

reset_cell.cell_reseted:
    popw(s1)
    popw(s0)
    popw(ra)
    jalr zero, 0(ra)


# This function draws a cell with the
# specified color at the given x and y coordinates.
# a0 - x
# a1 - y
# a2 - color
FUNC_draw_cell:

    li .t_display_ptr, DISPLAY_ADDRESS # FUNC_draw_cell

    li .t_temp_dis, SCREEN_WIDTH
    mul a1, a1, .t_temp_dis # a1 = y * SCREEN_WIDTH
    li .t_temp_dis, CELL_IN_BYTES
    mul a1, a1, .t_temp_dis # a1 = y * SCREEN_WIDTH * CELL_IN_BYTES
    mul a0, a0, .t_temp_dis # a0 = x * CELL_IN_BYTES

    add .t_display_ptr, .t_display_ptr, a0
    add .t_display_ptr, .t_display_ptr, a1 # .t_display_ptr - pointer to square start
    li .t_lines_to_draw, CELL


draw_cell_line_loop:
    beqz .t_lines_to_draw, FUNC_return_draw_cell # check if all lines are already drawn
    addi .t_lines_to_draw, .t_lines_to_draw, -1

    li .t_max_ptr, CELL_IN_BYTES
    add .t_max_ptr, .t_max_ptr, .t_display_ptr # t_max_ptr - pointer to last pixel


draw_cell_loop:
    bge .t_display_ptr, .t_max_ptr, draw_cell_line_finished # draw_cell_loop
    sw a2, 0(.t_display_ptr) # fill cell with color in a2
    addi .t_display_ptr, .t_display_ptr, 4
    j draw_cell_loop
draw_cell_line_finished:
    li .t_temp_dis, CELL_IN_BYTES # draw_cell_line_finished
    sub .t_display_ptr, .t_display_ptr, .t_temp_dis # move back by CELL_IN_BYTES bytes
    li .t_temp_dis, SCREEN_WIDTH
    li t5, 4
    mul .t_temp_dis, .t_temp_dis, t5 # .t_temp_dis - distance to next line in bytes
    add .t_display_ptr, .t_display_ptr, .t_temp_dis # move .t_display_ptr to next line
    j draw_cell_line_loop

FUNC_return_draw_cell:
    
    jalr zero, 0(ra) # FUNC_return_draw_cell



# This function checks if a map decoration
# should be drawn at the given x and y coordinates,
# and if so, it draws the decoration using the FUNC.draw_tile function.
# a0 - x
# a1 - y
# return: a0==0 - if cell did not reset
#         a0==1 - if cell was reseted
FUNC.check_and_draw_map_decoration:
    pushw(ra)
    pushw(s0)
    pushw(s1)
    pushw(s2)

    mv s1, a0
    mv s2, a1

    addi a0, a0, 234
    addi a1, a1, 678

    li t0, 813 # just a random prime number
    li t1, 1001 # just a random prime number
    mul t0, a0, t0
    mul t1, a1, t1

    add t2, t1, t0
    li a0, 0
    li t3, MAP_DECORATION_PROBABILITY_BASE
    rem t2, t2, t3

    # print_int(t2)
    # newline

    blt t2, zero, map_decoration.skip_tile # t2 less then zero (it is impossibly??)

    li t4, MAP_DECORATION_QUANTITY
    bge t2, t4, map_decoration.skip_tile # this is ordinary cell - t2 >= MAP_DECORATION_QUANTITY

    li t4, 4
    mul t2, t2, t4 # convert tile number ti byte offset in map_decorations_table
    la a2, map_decorations_table
    add a2, a2, t2 # a2 points to tile
    lw a2, 0(a2) # load pointer to tile
    

    mv a0, s1
    mv a1, s2
    jal ra, FUNC.draw_tile
    li a0, 1
    
map_decoration.skip_tile:
    popw(s2)
    popw(s1)
    popw(s0)
    popw(ra)
    jalr zero, 0(ra)

# This function draws a tile at the specified
# x and y coordinates using the given texture pointer.
# a0 - x
# a1 - y
# a2 - pointer to texture
FUNC.draw_tile:
    pushw(s3)
    pushw(s4)
    pushw(s5)
    li .t_display_ptr, DISPLAY_ADDRESS # FUNC.draw_tile

    li .t_temp_dis, SCREEN_WIDTH
    mul a1, a1, .t_temp_dis # a1 = y * SCREEN_WIDTH
    li .t_temp_dis, CELL_IN_BYTES
    mul a1, a1, .t_temp_dis # a1 = y * SCREEN_WIDTH * CELL_IN_BYTES
    mul a0, a0, .t_temp_dis # a0 = x * CELL_IN_BYTES

    add .t_display_ptr, .t_display_ptr, a0
    add .t_display_ptr, .t_display_ptr, a1 # .t_display_ptr - pointer to square start
    lw .t_lines_to_draw, 4(a2)
    addi s3, a2, 16 # s3 pointed to first pixel of image

draw_tile.line_loop:
    beqz .t_lines_to_draw, return.draw_cell # check if all lines are already drawn
    addi .t_lines_to_draw, .t_lines_to_draw, -1

    lw .t_max_ptr, 12(a2)
    add .t_max_ptr, .t_max_ptr, .t_display_ptr # t_max_ptr - pointer to last pixel


draw_tile.cell_loop:
    bge .t_display_ptr, .t_max_ptr, draw_tile.line_finished # draw_tile.cell_loop
    lw s4, 0(s3) # load pixel
    addi s3, s3, 4
    li s5, 0xff000000 # alpha mask
    and s5, s5, s4 # check pixel alpha
    beqz s5, draw_tile.skip_pixel # skip transparent pixel
    sw s4, 0(.t_display_ptr) # fill cell with loaded pixel
draw_tile.skip_pixel:
    addi .t_display_ptr, .t_display_ptr, 4
    j draw_tile.cell_loop
draw_tile.line_finished:
    lw .t_temp_dis, 12(a2) # draw_tile.line_finished
    sub .t_display_ptr, .t_display_ptr, .t_temp_dis # move back by CELL_IN_BYTES bytes
    li .t_temp_dis, SCREEN_WIDTH
    li t5, 4
    mul .t_temp_dis, .t_temp_dis, t5 # .t_temp_dis - distance to next line in bytes
    add .t_display_ptr, .t_display_ptr, .t_temp_dis # move .t_display_ptr to next line
    j draw_tile.line_loop

return.draw_cell:
    popw(s5)
    popw(s4)
    popw(s3)
    jalr zero, 0(ra) # return.draw_cell



# This function draws a snake tile (head, body, or tail)
# at the specified x and y coordinates, considering the previous
# and next element positions, and the tile type (head, body, or tail).
# a0 = x
# a1 = y
# a2 = previous element position
# a3 = next element position
# a4 - (BODY, HEAD, TAILL) - tile type
FUNC.draw_snake_tile:
    pushw(ra)

    li t0, HEAD
    beq t0, a4, draw_snake_tile.head
    li t0, BODY
    beq t0, a4, draw_snake_tile.body
    li t0, TAILL
    beq t0, a4, draw_snake_tile.tail
# to tind a head tail with next element on top, just load correesponded pointer: (la snake_head_table) + (TOP) * 4
draw_snake_tile.head:
    la t0, snake_head_table
    li t1, 4
    mul a3, a3, t1 # convert direction id to byte offset

    add a2, t0, a3 # a2 pointed to element in texture table
    lw a2, 0(a2) # load texture address
    jal ra, FUNC.draw_tile

    j draw_snake_tile.return

# to tind a head tail with next previous on top, just load correesponded pointer: (la snake_tail_table) + (TOP) * 4
draw_snake_tile.tail:
    la t0, snake_tail_table
    li t1, 4
    mul a2, a2, t1 # convert direction id to byte offset

    add a2, t0, a2 # a2 pointed to element in texture table
    lw a2, 0(a2) # load texture address
    jal ra, FUNC.draw_tile
    
    j draw_snake_tile.return

# to find body tile with previous element on top and next element on right: (la snake_body_table) + (TOP * 4 + RIGHT) * 4
draw_snake_tile.body:
    la t0, snake_body_table
    li t1, 4
    mul a2, a2, t1 # select row in 2-d array (because row size is 4 element)
    add a2, a3, a2 # a2 - element position in array
    mul a2, a2, t1 # multiply by 4 - becouse each element in array has 4 bite size

    add a2, t0, a2 # a2 pointed to element in texture table
    lw a2, 0(a2) # load texture address
    jal ra, FUNC.draw_tile
    
    j draw_snake_tile.return

draw_snake_tile.return:

    popw(ra)
    jalr zero, 0(ra)