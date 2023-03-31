
# Circle array with snake data - allow push and pop operations in O(1)
# EXAMPLE:
# .data
# circle_array:
#     .word 0 # current array length - .arr_length
#     .word 0 # first elem in allocated data (in elem_size) - .arr_offset
#     .word 2 # element size in byte - .arr_elem_size
#     .word 10 # pre-allocated elements - .arr_allocated
#     .space 20 # - .arr_start_ptr
#.text
# Test

.text

.eqv .arr_length s0
.eqv .arr_offset s1
.eqv .arr_elem_size s2
.eqv .arr_allocated s3
.eqv .arr_start_ptr s4

.eqv .t_target, t0
.eqv .t_temp_c_arr, t1

# a0 - ptr to array struct
# a1 - element number
# return: a0, a1, a2, ... - loaded element
# TODO: add error handling in case  a1 <= arr_size
FUNC_circle_array_get_elem:
    pushw(ra) # start circle_array_get_elem
    pushw(.arr_length)
    pushw(.arr_offset)
    pushw(.arr_elem_size)
    pushw(.arr_allocated)
    pushw(.arr_start_ptr)

    lw .arr_length, 0(a0)
    lw .arr_offset, 4(a0)
    lw .arr_elem_size, 8(a0)
    lw .arr_allocated, 12(a0)
    mv .arr_start_ptr, a0
    addi .arr_start_ptr, .arr_start_ptr, 16

    add .t_target, a1, .arr_offset

    rem .t_target, .t_target, .arr_allocated # t_target = t_target % arr_allocated
    mul .t_target, .t_target, .arr_elem_size # t_target = t_target * arr_elem_size
    
    li .t_temp_c_arr, 4
    mul .t_target, .t_target, .t_temp_c_arr # t_target = t_target * 4

    add .t_target, .t_target, .arr_start_ptr

    lw a0, 0(.t_target) # load first element
    addi .arr_elem_size, .arr_elem_size,  -1
    beqz .arr_elem_size, FUNC_return_circle_array_get_elem

    lw a1, 4(.t_target) # load second element
    addi .arr_elem_size, .arr_elem_size,  -1
    beqz .arr_elem_size, FUNC_return_circle_array_get_elem

    lw a2, 8(.t_target) # load third element
    addi .arr_elem_size, .arr_elem_size,  -1
    beqz .arr_elem_size, FUNC_return_circle_array_get_elem

    lw a3, 12(.t_target) # load fourth element
    addi .arr_elem_size, .arr_elem_size,  -1
    beqz .arr_elem_size, FUNC_return_circle_array_get_elem

FUNC_return_circle_array_get_elem:
    popw(.arr_start_ptr) # return return_circle_array_get_elem
    popw(.arr_allocated)
    popw(.arr_elem_size)
    popw(.arr_offset)
    popw(.arr_length)
    popw(ra)
    jalr zero, 0(ra)



# a0 - ptr to array struct
# a1, a2, a3, ... - new element fields
# return: a0, a1, a2, ... - loaded element
# TODO: add error handling in case  a1 <= arr_size
FUNC_circle_array_push_front:
    pushw(ra) # start circle_array_get_elem
    pushw(.arr_length)
    pushw(.arr_offset)
    pushw(.arr_elem_size)
    pushw(.arr_allocated)
    pushw(.arr_start_ptr)

    lw .arr_length, 0(a0)
    lw .arr_offset, 4(a0)
    lw .arr_elem_size, 8(a0)
    lw .arr_allocated, 12(a0)
    mv .arr_start_ptr, a0
    addi .arr_start_ptr, .arr_start_ptr, 16

    mv .t_target, .arr_offset
    addi .t_target, .t_target, -1 # point to element before head
    
    add .t_target, .t_target, .arr_allocated # rem cant handle negative numbers
    rem .t_target, .t_target, .arr_allocated # t_target = t_target % arr_allocated
    mul .t_target, .t_target, .arr_elem_size # t_target = t_target * arr_elem_size
    
    li .t_temp_c_arr, 4
    mul .t_target, .t_target, .t_temp_c_arr # t_target = t_target * 4
    add .t_target, .t_target, .arr_start_ptr

    addi .arr_offset, .arr_offset, -1
    add .arr_offset, .arr_offset, .arr_allocated # to handle negative numbers
    rem .arr_offset, .arr_offset, .arr_allocated # update the offset
    sw .arr_offset, 4(a0)
    
    addi .arr_length, .arr_length, 1 # increase array size
    sw .arr_length, 0(a0)

    sw a1, 0(.t_target) # store first element
    addi .arr_elem_size, .arr_elem_size,  -1
    beqz .arr_elem_size, FUNC_return_circle_array_push_front

    sw a2, 4(.t_target) # store second element
    addi .arr_elem_size, .arr_elem_size,  -1
    beqz .arr_elem_size, FUNC_return_circle_array_push_front

    sw a3, 8(.t_target) # store third element
    addi .arr_elem_size, .arr_elem_size,  -1
    beqz .arr_elem_size, FUNC_return_circle_array_push_front

    sw a4, 12(.t_target) # store fourth element
    addi .arr_elem_size, .arr_elem_size,  -1
    beqz .arr_elem_size, FUNC_return_circle_array_push_front

FUNC_return_circle_array_push_front:
    popw(.arr_start_ptr) # return FUNC_return_circle_array_push_front
    popw(.arr_allocated)
    popw(.arr_elem_size)
    popw(.arr_offset)
    popw(.arr_length)
    popw(ra)
    jalr zero, 0(ra)


# a0 - ptr to array struct
# remove last element
FUNC_circle_array_pop_back:
    pushw(ra) # start FUNC_circle_array_pop_back
    pushw(.arr_length)
    pushw(.arr_offset)
    pushw(.arr_elem_size)
    pushw(.arr_allocated)
    pushw(.arr_start_ptr)

    lw .arr_length, 0(a0)
    lw .arr_offset, 4(a0)
    lw .arr_elem_size, 8(a0)
    lw .arr_allocated, 12(a0)

    addi .arr_length, .arr_length, -1 # decrease array size
    sw .arr_length, 0(a0)

    mv .arr_start_ptr, a0
    addi .arr_start_ptr, .arr_start_ptr, 16

    add .t_target, .arr_length , .arr_offset # pointer to last element (it sould be deleted)

    rem .t_target, .t_target, .arr_allocated # t_target = t_target % arr_allocated
    mul .t_target, .t_target, .arr_elem_size # t_target = t_target * arr_elem_size
    
    li .t_temp_c_arr, 4
    mul .t_target, .t_target, .t_temp_c_arr # t_target = t_target * 4

    add .t_target, .t_target, .arr_start_ptr

    li .t_temp_c_arr, 0

    sw .t_temp_c_arr, 0(.t_target) # zero first element
    addi .arr_elem_size, .arr_elem_size,  -1
    beqz .arr_elem_size, FUNC_return_circle_array_pop_back

    sw .t_temp_c_arr, 4(.t_target) # zero second element
    addi .arr_elem_size, .arr_elem_size,  -1
    beqz .arr_elem_size, FUNC_return_circle_array_pop_back

    sw .t_temp_c_arr, 8(.t_target) # zero third element
    addi .arr_elem_size, .arr_elem_size,  -1
    beqz .arr_elem_size, FUNC_return_circle_array_pop_back

    sw .t_temp_c_arr, 12(.t_target) # zero fourth element
    addi .arr_elem_size, .arr_elem_size,  -1
    beqz .arr_elem_size, FUNC_return_circle_array_pop_back
FUNC_return_circle_array_pop_back:
    popw(.arr_start_ptr) # return return_circle_array_get_elem
    popw(.arr_allocated)
    popw(.arr_elem_size)
    popw(.arr_offset)
    popw(.arr_length)
    popw(ra)
    jalr zero, 0(ra)
