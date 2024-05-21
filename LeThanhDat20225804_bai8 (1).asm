.data
	num_students: .word 0
	student_name: .space 160
	student_mark: .space 40
	prompt_num_students: .asciiz "Enter the number of students: "
	prompt_student_name: .asciiz "Enter student name: "
	prompt_student_mark: .asciiz "Enter student's mark (0-10): "
	newline: .asciiz "\n"
.text
	la $t4, student_name
	la $t5, student_mark

	la $a0, prompt_num_students
	li $v0, 4
	syscall

	li $v0, 5
	syscall

	move $t3, $v0
	li $t0, 0

loop:
	slt $t1, $t0, $t3
	beq $t1, $zero, sort_and_print

	la $a0, prompt_student_name
	li $v0, 4
	syscall

	li $v0, 8  #input string
	la $a0, 0($t4)
	li $a1, 16
	syscall

	addi $t4, $t4, 16 #next string

	la $a0, prompt_student_mark
	li $v0, 4
	syscall

	li $v0, 5  #input mark
	syscall
	sb $v0, 0($t5)
	addi $t5, $t5, 4

	addi $t0, $t0, 1
	j loop

sort_and_print:         # $t3 = num_students
    jal sort_students

print_loop:
	li $t0, 0                # i = 0
	la $t4, student_name
	la $t5, student_mark
loop_print:
    slt $t1, $t0, $t3
	beq $t1, $zero, end_print
	
    la $a0, 0($t4)      # Load address of student name
    li $v0, 4
    syscall
    
    lw $a0, 0($t5)
    li $v0, 1
    syscall
    
    la $a0, newline
    li $v0, 4
    syscall

    addi $t4, $t4, 16
    addi $t5, $t5, 4
    addi $t0, $t0, 1
    j loop_print
end_print:

    # Exit program
    li $v0, 10              # System call for exit
    syscall

#$t4=student_name, $t5=student_mark

sort_students:
	addi $s7, $t3, -1
	la $t4, student_name
	la $t5, student_mark
    li $t0, 0                   # $t0 = i = 0
outer_loop:
    slt $t1, $t0, $t3
	beq $t1, $zero, exit_sort
    li $t1, 0                   # $t1 = j = 0
inner_loop:
    slt $t9, $t1, $s7
	beq $t9, $zero, next_outer
	
    add $t2, $t2, $t5 
    lw $t7, 0($t2) # $t7 = mark[j]
    
    addi $t6, $t2, 4
    lw $t8, 0($t6) # $t5 = mark[j+1]
    
    ble $t7, $t8, no_swap       # if mark[j] <= mark[j+1], no need to swap
    
    # swap marks
    sw $t7, 0($t6) # mark[j+1] = mark[j]
    sw $t8, 0($t2)      # mark[j] = mar[j+1]
    
    sll $t2, $t1, 2  #$t2 = 4*j
    
    add $s6, $s6, $t4 
    
    # swap names
    la $s1, 0($s6)    # $s1 = &name[j]
    addi $s3, $s6, 16
    la $s2, 0($s3) # $s2 = &name[j+1]
    sll $s6, $t1, 4  # $s6 = 16*j
    
    
    li $t8, 16  #counter                                        
name_swap_loop:
    lb $s4, ($s1)       # load byte from name[j]
    lb $s5, ($s2)       # load byte from name[j+1]
    sb $s5, ($s1)       # store byte from name[j+1] into name[j]
    sb $s4, ($s2)       # store byte from name[j] into name[j+1]
    addi $s1, $s1, 1    
    addi $s2, $s2, 1    
    addi $t8, $t8, -1   # decrement counter
    bne $t8, $zero, name_swap_loop

no_swap:
    sll $t2, $t1, 2  #$t2 = 4*j
    sll $s6, $t1, 4  # $s6 = 16*j
    addi $t1, $t1, 1        # j += 1
    j inner_loop

next_outer:
    addi $t0, $t0, 1           # i += 1
    j outer_loop
    
exit_sort:
    jr $ra
