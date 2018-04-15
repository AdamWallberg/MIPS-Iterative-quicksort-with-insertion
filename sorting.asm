	.data
	
# Insert data here

newline:
	.asciiz "\n"

	.text
main:
# Written by Adam Vallberg and Viking Renhammar Metus
#
# This sorting algorithm is using iterative quicksort combined
# with insertion sort. When the subpartitions reach a size smaller
# than 17 elements, the quicksort stops sorting that partition, and 
# leaves it for the insertion sort to take care of.
# Disclaimer: Readability is not prioritized. So subroutines have
# been inlined, and conventions relating to registers have not
# been followed.

	la		$s0, data 	# Data pointer
	li 		$s1, 0		# Low
	lw 		$s2, datalen	# High
	move 	$t4, $s2 	# t4 = high
	sll 	$t4, $t4, 2
	addi 	$s2, $s2, -1
	
	### Start quick sort ###
	
	# Allocate virtual stack on heap
	sll 	$a0, $s2, 2
	addi 	$a0, $a0, -4
	li 		$v0, 9
	syscall
	move 	$t0, $v0	# Heap address
	
	# t0 = base address
	# t1 = pointer iterator
	
	# Set stack[0] to low, and [1] to high
	move 	$t1, $t0
	sw 		$s1, 0($t1)	# low
	sw 		$s2, 4($t1)	# high
	addi 	$t1, $t1, 8
	
	L1:
		blt 	$t1, $t0, L1E
		nop
		
		addi 	$t1, $t1, -8
		lw 		$s2, 4($t1)		# high = stack[top--]
		lw 		$s1, 0($t1)		# low = stack[top--]
		
		
		### Start partitioning
		
		# s1 = low
		# s2 = high
		# s3 = pivot
		# s4 = i
		# s5 = j
		
		sll 	$s3, $s1, 2		# &arr[low]
		add 	$s3, $s3, $s0
		sll 	$s4, $s2, 2		# &arr[high]
		add 	$s4, $s4, $s0
		
		lw 		$s5, 0($s3)		# arr[low]
		lw 		$s6, 4($s3)		# arr[low + 1]
		
		bge 	$s6, $s5, skip4	# If A > B
		nop
			sw 		$s5, 4($s3)	# Switch A and B
			sw 		$s6, 0($s3)
		skip4:
		
		lw 		$s5, 4($s3)		# arr[low + 1]
		lw 		$s6, 0($s4)		# arr[high]
		
		bge 	$s6, $s5, skip5	# If B > C
		nop
			sw 		$s5, 0($s4)	# Switch B and C
			sw 		$s6, 4($s3)
		skip5:
		
		lw 		$s5, 0($s3)
		lw 		$s6, 0($s4)
		
		bge 	$s5, $s6, skip6 # If C > A
		nop
			sw 		$s5, 0($s4)
			sw 		$s6, 0($s3)
		skip6:

		lw 		$s3, ($s4)		# arr[high]
		
		addi 	$s4, $s1, -1	# i = low - 1
		sll 	$s4, $s4, 2
		add 	$s4, $s4, $s0	# i = &arr[i]
		
		sll 	$s5, $s1, 2		# j = low
		add 	$s5, $s5, $s0	# j = &arr[j]
		
		sll 	$t5, $s2, 2		
		add 	$t5, $t5, $s0	# t5 = &arr[high]
		
		
		L2: # for(j = low; j < high; j++)
			bge 	$s5, $t5, L2E
			#nop
			
			lw 		$s6, ($s5)			# arr[j]
			
			bgt 	$s6, $s3, skip3	# if(arr[j <= pivot])
			nop
				addi 	$s4, $s4, 4	# i++
				
				lw 		$t6, ($s4)		# Swap
				sw 		$t6, ($s5)
				sw 		$s6, ($s4)
			skip3:
			
			addi 	$s5, $s5, 4	# j++
			
			j L2
			nop
		L2E:
		
		addi 	$s4, $s4, 4	# i++
		
		lw 		$t6, ($t5)		# Swap
		lw 		$t7, ($s4)
		sw 		$t6, ($s4)
		sw 		$t7, ($t5)
		
		sub 	$s4, $s4, $s0
		srl 	$v0, $s4, 2
		
		### End partitioning
		
		addi 	$v0, $v0, -1
		
		ble 	$v0, $s1, skip1
		nop
		sub 	$s7, $v0, $s1
		blt 	$s7, 17, skip1
		nop
			addi 	$t1, $t1, 8
			sw 		$s1, -8($t1)
			sw 		$v0, -4($t1)
		skip1:
		
		addi 	$v0, $v0, 2
		
		bge 	$v0, $s2, skip2
		nop
		sub 	$s7, $s2, $v0
		blt 	$s7, 17, skip2
		nop
			addi 	$t1, $t1, 8
			sw 		$v0, -8($t1)
			sw 		$s2, -4($t1)
		skip2:
		
		j L1
		nop
	L1E:
	
	lw 		$ra, ($sp)
	addi 	$sp, $sp, 4
	
	### End quick sort
	
	### Start insertion sort
	
	# $t0 = key iterator (i), from leftwise element+1 to high (4, 8, 12...)
	# $t1 = adress of key (s0 + t0)
	# $t2 = value of key (t1)
	
	# $t3 = value of low
	# $t9 = adress of low
	
	addi 	$sp, $sp, -4
	sw 		$ra, ($sp)
	
	xor 	$t0, $t0, $t0
	addi 	$t0, $t0, 4
	
	L3_alt:
	add 	$t1, $s0, $t0
	addi 	$t9, $t1, -4 #j = i-1
	lw 		$t2, ($t1)
	lw 		$t3, ($t9)
	
	bge 	$t2, $t3, L4E_alt
	nop
	
		L4_alt:
		
		
		beq 	$t9, $s0, insert
		sw 		$t3, 4($t9)
		
		addi 	$t9, $t9, -4
		lw 		$t3, ($t9)
		
		bgt 	$t3, $t2, L4_alt
		nop
		
		j L4E_alt
		sw 		$t2, 4($t9)
		
		insert:
		sw 		$t2, ($t9)
		L4E_alt:
	
		
	addi 	$t0, $t0, 4
	bne 	$t0, $t4, L3_alt
	nop
	L3E_alt:
	
	lw 		$ra, ($sp)
	addi 	$sp, $sp, 4
	
	### END
	
	### Print all data
	
	move 	$t0, $s0
	addi	$t0, $t0, 4
	addi	$t4, $t4, -4
	move 	$t1, $t4
	add 	$t1, $t1, $s0
	L5:
		li 		$v0, 1
		lw 		$a0, -4($t0)
		syscall
		
		li 		$v0, 4
		la 		$a0, newline
		syscall
		
		addi	$t0, $t0, 4
		blt  	$t0, $t1, L5

	### End printing

	li 		$v0, 10
	syscall
