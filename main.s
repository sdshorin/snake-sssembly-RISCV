
# Main file which hands with timer interuptions and keyboard
# This code call game_step evety 0.2s and send to it last move command from keyboard

.include "utils.s"

.include "game_data.s" # all program static data (snake, food pos ...) and constants

    .data 
last_input:
    .word 0
    .word 0xfffffff
active_frame:
    .word 0
    # .space 32

.text
    .eqv IN_CTRL  0xffff0000
    .eqv IN       0xffff0004
   
	
    .eqv KEYBOARD_IRQ, 257          # Keyboard interrupt request number
    .eqv TIMER_IRQ, 0x10             # Timer interrupt request number

    j main
handler:
pushw(t0)
    pushw(t1)
    pushw(s0)
    pushw(s1)

    csrr t0, ucause
    andi t0, t0,  0xff
    # print_int(t0) #cant print from handler whit ecall - a bug occured

    li t1, 8
    beq t0, t1, keyboard_interupt

	li t1, 4
    beq t0, t1, timer_interrupt
    j handler_ret

timer_interrupt:
#    li t0, '|'
#    print_char(t0)

    la s0, active_frame
    lw t0, 0(s0)
    addi t0, t0, 1
    sw t0, 0(s0)
    timer(FRAME_TIME)
    j handler_ret

keyboard_interupt:
    li s0, IN_CTRL
    lw   t0, 0(s0)
    andi t0, t0, 0x1 # check CONTROL bit
    beqz t0, handler_ret 

    li s0, IN
    lw t0, 0(s0)

    li t1,'w'
    beq t1, t0, store_input		# if the pressed key is 'wasd', save it in memory
    li t1,'a'
    beq t1, t0, store_input
    li t1,'s'
    beq t1, t0, store_input
    li t1,'d'
    beq t1, t0, store_input
    j handler_ret
    
store_input:
# print_char(t0)
    la t1, last_input
    sw   t0, 0(t1)
    j handler_ret
    

handler_ret:
   popw(s1)
    popw(s0)
    popw(t1)
    popw(t0)
    uret



main:
    .eqv .current_frame s0
    la       t0, handler
    csrrw  zero, utvec, t0  # set utvec to the handlers address
    csrrsi zero, ustatus, 1 # set interrupt enable bit in ustatus
    
    li t1, KEYBOARD_IRQ
    li t0, TIMER_IRQ
    or t1, t1, t0
    csrrw  zero, uie, t1    # enable handling of the specific interrupt

    li s0, IN_CTRL
    li t0, 2
    sw t0, 0(s0)  # set interrupt flag in the IN device.

    li .current_frame, 0
    timer(FRAME_TIME) # init timer
loop:
    wfi
    la s1, active_frame
    lw s1, 0(s1)
    #print_int(s1)
    #print_int(.current_frame)
    ble s1, .current_frame, loop_end
main_step:
    addi .current_frame, .current_frame, 1
   # newline
   # print_int(.current_frame)
   # newline
    la t0, last_input # get move symbol
    lw t1, 0(t0)
    li t2, 0 
    sw t2, 0(t0) # reset last_input
    mv a0, t1
    jal ra, game_step
    # print_char(t1)
    # may be reset .current_frame to active_frame? signals from timer may occured during game_step execution
    
loop_end:
    j loop


.include "game_step.s"


