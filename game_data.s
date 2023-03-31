.data


# field size:
# screen size 512 на 256
# Cell size: 32x32
# field size in blocks: 16x8


.eqv SCREEN_WIDTH 512
.eqv SCREEN_HEIGHT 256

.eqv CELL 32 # cell of game field
.eqv CELL_IN_BYTES 128 # CELL * 4
.eqv FIELD_WIDTH 16 # 512 / 32
.eqv FIELD_HEIGHT 8 # 256 / 32

# .eqv FRAME_TIME 2000 # 2s for evefy frime, 0.5  FPS
.eqv FRAME_TIME 200 # 0.2s for evefy frime, 10 FPS

.eqv SEGMENT_DATA_SIZE 4 # size of stuct with snake body element.
                        # (x, y, metadata_1, metadata_2)

.eqv SNAKE_ARR_ALLOCATED_ELEMENTS 132 # (FIELD_WIDTH * FIELD_HEIGHT + 4)  # 4 - reserve
.eqv SNAKE_ARR_SIZE_IN_BYTES 2112 # (SEGMENT_DATA_SIZE * SNAKE_ARR_ALLOCATED_ELEMENTS) * 4 = 132 * 16

.eqv LEFT 0
.eqv TOP 1
.eqv RIGHT 2
.eqv BOTTOM 3

.eqv HEAD 0
.eqv BODY 1
.eqv TAILL 3 # doesn't compile with TAIL. Therefore double L using here

.eqv DISPLAY_ADDRESS 0x10040000

.eqv FOOD_PROPS_QUANTITY 3

BOOM_STR:
    .asciz "BOOM! GAME END!"

food_position:
    .word 5 # x
    .word 5 # y
food_assert:
    .word 0 # 0 - apple, 1 - mouse, 2 - mushroom

# Snake tiles table. Allow to select title with target shipe and rotation
# to tind a head tail with next element on top, just load correesponded pointer: (la snake_head_table) + (TOP) * 4
# to find body tile with previous element on top and next element on right: (la snake_body_table) + (TOP * 4 + RIGHT) * 4
snake_tile_table:
snake_head_table:
.word asset_head_to_left, asset_head_to_top, asset_head_to_right, asset_head_to_bottom
snake_tail_table:
.word asset_tail_from_left, asset_tail_from_top, asset_tail_from_right, asset_tail_from_bottom
snake_body_table:
.word 0, asset_body_left_to_top, asset_body_left_to_right, asset_body_left_to_bottom
.word asset_body_top_to_left, 0, asset_body_top_to_right, asset_body_top_to_bottom
.word asset_body_right_to_left, asset_body_right_to_top, 0, asset_body_right_to_bottom
.word asset_body_bottom_to_left, asset_body_bottom_to_top, asset_body_bottom_to_right, 0

# Circle array with snake data - allow push and pop operations in O(1)
# store each element in machine world (4 bytes)
snake_data:
    .word RIGHT # direction
snake_circle_array:
    .word 2 # array length
    .word 0 # head positoin in array
    .word SEGMENT_DATA_SIZE # element size
    .word SNAKE_ARR_ALLOCATED_ELEMENTS # allocated elements
snake_body:
    .word 7 4 # head
    .word 8 4 #(FIELD_WIDTH / 2) # x (FIELD_HEIGHT / 2) # y
    
    .space SNAKE_ARR_SIZE_IN_BYTES # (SNAKE_ARR_SIZE - SEGMENT_DATA_SIZE)
    # .space SNAKE_ARR_SIZE

