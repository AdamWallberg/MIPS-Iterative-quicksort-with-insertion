	.data
datalen:
	.word	0x0010	# 16
data:
	.word	0xffff7e81
	.word	0x00000001
	.word	0x00000002
	.word	0xffff0001
	.word	0x00000000
	.word	0x00000001
	.word	0xffffffff
	.word	0x00000000
	.word	0xe3456687
	.word	0xa001aa88
	.word	0xf0e159ea
	.word	0x9152137b
	.word	0xaab385a1
	.word	0x31093c54
	.word	0x42102f37
	.word	0x00ee655b

newline:
	.asciiz "\n"

	.text
main:
	la $s0, data 	# Data pointer
	li $s1, 0		# Low
	lw $s2, datalen	# High
	move $t4, $s2 	# t4 = high
	addi $s2, $s2, -1
	
	jal quick_sort_iterative
	nop
	
	jal insertion_sort
	nop
	
	jal print_data
	nop

	li $v0, 10
	syscall
	
print_data:
	# Print all data
	move $t0, $s0
	addi $t0, $t0, 4
	addi $t4, $t4, -1
	sll $t1, $t4, 2
	add $t1, $t1, $s0
	L5:
		li $v0, 1
		lw $a0, -4($t0)
		syscall
		
		li $v0, 4
		la $a0, newline
		syscall
		
		addi $t0, $t0, 4
		blt  $t0, $t1, L5
	
	jr $ra
	nop
	
insertion_sort:
	# t0 = i
	# t1 = j
	# t3 = key
	# t4 = high
	
	li $t0, 1
	addi $t2, $s0, 4
	
	L3:
	bge $t0, $t4, L3E
	nop
		lw $t3, 0($t2)		# key = arr[i];
		
		addi $t1, $t0, -1	# j = i-1;
		
		sll $t5, $t1, 2
		add $t5, $t5, $s0
		lw $t5, 0($t5)		# arr[j]
		
		L4:
		bltz $t1, L4E
		nop
		ble $t5, $t3, L4E
		nop
			addi $t6, $t1, 1
			sll $t6, $t6, 2
			add $t6, $t6, $s0	# &arr[j + 1]
			
			sw $t5, 0($t6)		# arr[j+1] = arr[j];
			addi $t1, $t1, -1	# j--
			
			sll $t5, $t1, 2
			add $t5, $t5, $s0	# &arr[j]
			lw $t5, 0($t5)		# arr[j]
			
			j L4
			nop
		L4E:
		
		addi $t6, $t1, 1
		sll $t6, $t6, 2
		add $t6, $t6, $s0	# &arr[j + 1]
		sw $t3, 0($t6)	# arr[j+1] = key;
		
		addi $t0, $t0, 1
		addi $t2, $t2, 4
		
		j L3
		nop
	L3E:
	
	jr $ra
	nop	

quick_sort_iterative:
	addi $sp, $sp, -4
	sw $ra, ($sp)
	
	# Allocate stack on heap
	sll $a0, $s2, 2
	addi $a0, $a0, -4
	li $v0, 9
	syscall
	move $t0, $v0	# Heap address
	
	# t0 = base address
	# t1 = pointer iterator
	
	# Set stack[0] to low, and [1] to high
	move $t1, $t0
	sw $s1, 0($t1)	# low
	sw $s2, 4($t1)	# high
	addi $t1, $t1, 8
	
	L1:
		blt $t1, $t0, L1E
		nop
		
		addi $t1, $t1, -8
		lw $s2, 4($t1)		# high = stack[top--]
		lw $s1, 0($t1)		# low = stack[top--]
		
		
		jal partition
		nop
		
		addi $v0, $v0, -1
		
		ble $v0, $s1, skip1
		nop
		sub $s7, $v0, $s1
		blt $s7, 12, skip1
		nop
			addi $t1, $t1, 8
			sw $s1, -8($t1)
			sw $v0, -4($t1)
		skip1:
		
		addi $v0, $v0, 2
		
		bge $v0, $s2, skip2
		nop
		sub $s7, $s2, $v0
		blt $s7, 12, skip2
		nop
			addi $t1, $t1, 8
			sw $v0, -8($t1)
			sw $s2, -4($t1)
		skip2:
		
		j L1
		nop
	L1E:
	
	lw $ra, ($sp)
	addi $sp, $sp, 4
	
	jr $ra
	nop
	
partition:
	# s1 = low
	# s2 = high
	# s3 = pivot
	# s4 = i
	# s5 = j
	
	sll $s3, $s1, 2		# &arr[low]
	add $s3, $s3, $s0
	sll $s4, $s2, 2		# &arr[high]
	add $s4, $s4, $s0
	
	lw $s5, 0($s3)		# arr[low]
	lw $s6, 4($s3)		# arr[low + 1]
	
	# TODO: compare with bgt
	bge $s6, $s5, skip4	# If A > B
	nop
		sw $s5, 4($s3)	# Switch A and B
		sw $s6, 0($s3)
	skip4:
	
	lw $s5, 4($s3)		# arr[low + 1]
	lw $s6, 0($s4)		# arr[high]
	
	bge $s6, $s5, skip5	# If B > C
	nop
		sw $s5, 0($s4)	# Switch B and C
		sw $s6, 4($s3)
	skip5:
	
	lw $s5, 0($s3)
	lw $s6, 0($s4)
	
	bge $s5, $s6, skip6 # If C > A
	nop
		sw $s5, 0($s4)
		sw $s6, 0($s3)
	skip6:

	lw $s3, ($s4)		# arr[high]
	
	addi $s4, $s1, -1	# i = low - 1
	sll $s4, $s4, 2
	sll $s5, $s1, 2		# j = low
	
	
	L2: # for(j = low; j < high; j++)
		srl $t8, $s5, 2
		bge $t8, $s2, L2E
		nop
		
		add $s7, $s5, $s0		# &arr[j]
		lw $s6, ($s7)			# arr[j]
		
		bgt $s6, $s3, skip3	# if(arr[j <= pivot])
		nop
			addi $s4, $s4, 4	# i++
			add $t8, $s4, $s0	# &arr[i]
			
			lw $t6, ($t8)		# Swap
			sw $t6, ($s7)
			sw $s6, ($t8)
		skip3:
		
		addi $s5, $s5, 4	# j++
		
		j L2
		nop
	L2E:
	
	addi $s4, $s4, 4	# i++
	add $t9, $s4, $s0	# &arr[i + 1]
	
	sll $t8, $s2, 2
	add $t8, $t8, $s0	# &arr[high]
	
	lw $t6, ($t8)		# Swap
	lw $t7, ($t9)
	sw $t6, ($t9)
	sw $t7, ($t8)
	
	srl $v0, $s4, 2
	
	jr $ra
	nop
	
	
	
	
	
	
	
	
