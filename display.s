

.eqv .t_display_ptr t0
.eqv .t_max_ptr t1
.eqv .t_color t2
.eqv .t_temp_dis t3
.eqv .t_lines_to_draw t4

# fiil all display with green
FUNC_reset_display:
    li .t_display_ptr, DISPLAY_ADDRESS # FUNC_reset_display

    li .t_max_ptr, SCREEN_WIDTH
    li .t_temp_dis, SCREEN_HEIGHT
    mul .t_max_ptr, .t_max_ptr, .t_temp_dis # SCREEN_WIDTH * FIELD_HEIGHT
    li .t_temp_dis, 4 #128 # 4 * 
    mul .t_max_ptr, .t_max_ptr, .t_temp_dis # .t_max_ptr = screen size in bytes
    add .t_max_ptr, .t_max_ptr, .t_display_ptr
    li .t_color, 0x00af00

reset_screen_loop:
    bge .t_display_ptr, .t_max_ptr, FUNC_return_reset_display # reset_screen_loop
    sw .t_color, 0(.t_display_ptr)
    addi .t_display_ptr, .t_display_ptr, 4
    j reset_screen_loop
    

FUNC_return_reset_display:
    jalr zero, 0(ra) # FUNC_return_reset_display


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



# a0 - x
# a1 - y
# a2 - pointer to texture
FUNC.draw_tile:
    pushw(s3)
    pushw(s4)
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
    sw s4, 0(.t_display_ptr) # fill cell with loaded pixel
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
    popw(s4)
    popw(s3)
    jalr zero, 0(ra) # return.draw_cell

