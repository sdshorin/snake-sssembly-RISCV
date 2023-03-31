
.eqv CURRENT_TIME 0xFFFF0018 # current time
.eqv NEW_TIME 0xFFFF0020 # time for new interrupt
.macro timer(%timeout)
    lw     t0, CURRENT_TIME
	li     t1, %timeout
    add    t0, t0, t1
    sw     t0, NEW_TIME, t1
.end_macro

.macro pushw(%x)
	addi sp, sp, -4
	sw %x, (sp)
.end_macro
	
.macro popw(%x)
	lw %x, (sp)
	addi sp, sp, 4
.end_macro

.macro read_int (%x)
	li a7, 5
	ecall
	mv %x, a0
.end_macro

.macro print_int (%x)
	mv a0, %x
	li a7, 1
	ecall
.end_macro

.macro print_char(%c)
	mv a0, %c
	li a7, 11
	ecall
.end_macro

.macro exit
    li      a7, 10
    ecall
.end_macro

.macro print_hex(%x)
    mv      a0, %x
    li      a7, 34
    ecall
.end_macro

.macro newline
    li      a0, '\n'
    li      a7, 11
    ecall
.end_macro

.macro put_string(%c)
	la a0, %c
	li a7, 4
	ecall
.end_macro

.macro put_char(%c)
	li a0, %c
	li a7, 11
	ecall
.end_macro
