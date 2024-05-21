.data
    input_str: .space 256            # Reserve space for input string
    input: .asciiz "Enter a string: "
    output_msg: .asciiz "Reversed string: "

.text
.globl main
main:
	la $fp, 0($sp)
    # Print prompt for user input
    li $v0, 4
    la $a0, input
    syscall

    # Read string from user
    li $v0, 8
    la $a0, input_str
    li $a1, 256
    syscall

    # Initialize $t0 for string traversal
    la $t0, input_str
	
	li $t6, 0
	li $t7, 0
extract_loop:
    lb $t1, 0($t0)          # Load a byte from the string
    addi $t6, $t6, 1
    beq $t1, $zero, reverse # If it's zero (end of string), go to reverse


    # Check if the character is a digit
    li $t2, '0'
    sub $t3, $t1, $t2
    blt	$t3, 10, not_digit_check1

    # Push digit onto stack
    addi $sp, $sp, -1
    sb $t1, 0($sp)

not_digit:
    addi $t0, $t0, 1        # Move to the next character
    j extract_loop

reverse:
    # Print output message
    li $v0, 4
    la $a0, output_msg
    syscall

print_loop:
    lb $t1, 0($sp)          # Load a byte from the stack
    addi $t7, $t7, 1
    beq $t7, $t6, end
    # Print the character
    li $v0, 11
    move $a0, $t1
   
    syscall

    addi $sp, $sp, 1        # Move stack pointer back
    j print_loop

j end

not_digit_check1:
bgt $t3, 0, not_digit
else_digit:
addi $sp, $sp, -1
sb $t1, 0($sp)
addi $t0, $t0, 1        # Move to the next character
j extract_loop

end:
    # Exit program
    li $v0, 10
    syscall
    
