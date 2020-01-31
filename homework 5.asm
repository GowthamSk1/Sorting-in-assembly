# GOWTHAM CS 3340 Dr.Mazidi Homework 5.asm
.data
filename: .asciiz "input.txt"   	# filename
spaceForNumbers: .space 80		# space to store the numbers which are read
space: .asciiz " " 			# space to display the integers
endLine: .asciiz "\n"
before: .asciiz "The array before: "   # prompt
after:  .asciiz "The array after:  "	 # prompt after
meanPrompt:   .asciiz "The mean is: "	 # mean prompt
mean: .float 0
medianPrompt: .asciiz "The median is: "	 # median 
standardDeviationPrompt: .asciiz "The standard deviation is: "   # standard deviation

.text
main: 	
	la $t0, filename		# load addresses
	la $t1, spaceForNumbers	# load addresses
	move $a0, $t0
	move $a1, $t1	
	jal readFromFile   		# functionto read text from file
	
	# Allocate space for 20 words/for the array
	li $v0, 9
	li $a0, 80
	syscall
	move $s1, $v0  			# store the address of the array in a s register this $s1 will be used throughout main program
	
	# Store values into $a0, $a1 registers and call the convertToInt subroutine
	move $a0, $v0
	la $a1, spaceForNumbers	# $a2 is the address where the buffer starts 	
	jal convertToInt
	
	# display the array of integers BEFORE sorted
	#for(int e: $a0) print(e);
	li $v0, 4
	la $a0, before 			# print the before prompt
	syscall 
	
	move $a1, $s1 
	jal displayArray   		# print to console before the array is sorted
	
	li $v0, 4		
	la $a0, endLine			# print \n character 
	syscall
	
	# Sort the array by calling the selectionSort subroutine
	move $a0, $s1  			 # $a0 = address of array from $s1 register
	li $a1, 20			 # $a1 = the size of the array
	jal selectionSort  		 # call selection sort subroutine
	
	li $v0, 4
	la $a0, after 			# print the before prompt
	syscall 
				
	move $a1, $s1
	jal displayArray		# print to console after the array is sorted
	
	li $v0, 4
	la $a0, endLine			# print \n character 
	syscall
	
	li $v0, 4
	la $a0, meanPrompt		# print the message "the mean is: "
	syscall
	
	# floating point arithmetic 
	# mean, median, SD
	move $a0, $s1			# $a0 = address of the array
	#la $a2, mean
	jal calculateMean		# call the calculateMean subroutine

	li $v0, 4
	la $a0, endLine			# endline
	syscall
		
	li $v0, 4
	la $a0, medianPrompt		# print the median message "the median is: "
	syscall
	
	move $a0, $s1			# $a0 = address of the array
	jal calculateMedian		# calculate median of the list
		
	li $v0, 4
	la $a0, endLine			# endline
	syscall
		
	li $v0, 4			# print the message "thestandard deviation is: "
	la $a0, standardDeviationPrompt 	
	syscall
	
	move $a0, $s1			# $a0 = address of the array
	jal calculateStandardDeviation	 # calculate the standard deviation
	
	li $v0, 10			# EXIT PROGRAM
	syscall
	
readFromFile:	
	move $t0, $a0			# move address of filename
	move $t1, $a1			# move address of spaceForNumbers
	
	li $v0, 13			# open the file
	la $a0, ($t0)			# put contents (address) of filename
	li $a1, 0
	li $a2, 0
	syscall
	move $s0, $v0			# save the file descriptor
	
	# read from the file that was just opened
	li $v0, 14
	move $a0, $s0   		# $s0 register has the file descriptor
	la $a1, 0($t1)			# to store the string of integers
	li $a2, 80   			
	syscall

	# after reading in the input close the file
	li $v0, 16
	move $a0, $s0 			# file descriptor (close)
	syscall
	
	jr $ra
		
convertToInt: 
	move $t6, $zero   		# s1 is the accumulator  load 0 into the accumulator ($s1 = 0)
	move $t7, $zero   		# index i = 0	
	addi $t3, $zero, 10		# $t3 = 10
	addi $t2, $zero, 48		# check if it is less than 48
	addi $t8, $zero, 57		# check if it is more than 57
loop: 	
	lb $t0, 0($a1)      		# load byte by byte from the address buffer beginning
	beq $t0, $zero, done  		# When you load in a byte that is equal to 0 this is end of data
	beq $t0, $t3, load  		# When you load in a byte that is equal to 10, this is newline, so you are done with the integer you were converting;
 	blt $t0, $t2, ignore		# As you load a byte from the buffer, ignore the byte if it is <48 (ASCII for 0)
 	bgt $t0, $t8, ignore		# ignore > 57 (ASCII for 9). 
	addi $t1, $t0, -48 		# Subtract 48 to convert it from ASCII to int. 
	# now register t1 has the integer of the first byte
	mul $t6, $t6, 10   		# multiply the register you are using as an accumulator by 10 accumnulator register is $t6
	add $t6, $t6, $t1  		# add this new digit
	addi $a1, $a1, 1    		# next byte
	j loop	
	
ignore: addi $a1, $a1, 1		# if the byte is not a digit ignore and move on to the next byte
	j loop				# jump to loop for next byte
load:	#beq $t7, $zero, loop	 	# check if beginning of number list then skip
	sll $t4, $t7, 2 		# $t7 = i*4
	add $t5, $a0, $t4   		# $t5 = address of array[i]
	sw $t6, 0($t5)      		# array [i] = $t2 which is the digit
	addi $t7, $t7, 1    		# i = i + 1
	addi $a1, $a1, 1  		# after loading in the integer into array go back to loop and load the next digit/byte
	move $t6, $zero    		# after loading in the interger set accumulator to 0 and jump
	j loop    			# jump to loop
done:
	jr $ra

displayArray: # pointer method to display the array
	move $t0, $a1  			# move the address of array into a temp register (unneccessary)
	li $t1, 20			# load the length of the array (20 words)
	sll $t3, $t1 ,2  		# $t3 = 20 * 4    80 = $t2
	add $t4, $t0, $t3		# $t4 = &array[size]
loop2:
	lw $t7, 0($t0)			# load the integer into a temporary $t7 register
	# display each integer
	li $v0, 1
	add $a0, $t7, $zero		# print (arrayat(0,4,8,16....80))
	syscall
	# print " " between integers
	li $v0, 4			# to print the spacing between the integers
	la $a0, space
	syscall
	# next element in the array using pointers
	addi $t0, $t0, 4		# p = p + 4
	slt $t5, $t0, $t4   		# t5 = (p < &array[size])
	bne $t5, $zero, loop2    	# bne if not end of the list go to loop2 else end of the array quit
	jr $ra
								
#selection sort
selectionSort:
	addi $sp, $sp, -4 		# save value of $s1 on stack
	sw $s1, 0($sp)    		# save s1
	# setting up the array
	move $s0, $a0  			# move array address $s0 = array base address
	move $s1, $a1			# move $s1 = size
	addi $s1, $s1, -1  		# $s1 = size-1
	move $t0, $zero   		# i = 0
	
SSloop1:	
	beq $t0, $s1, loopDone  	 # if(i < size-1) go to label
	move $t1, $t0      		 # minimumindex  = i
	addi $t2, $t0, 1  		 # j = i+1
	j SSloop2			 # go back to loop2 after each iteration
SSloop2: 
	bgt $t2, $s1, swap
	sll $t3, $t2, 2        	# $t3 = j*4
	add $t4, $s0, $t3      	# $t4 = &array[j]
	lw $s7, 0($t4)			# $s7 = array[j]
	
	sll $t8, $t1, 2			# $t8 = minimumindex *4
	add $t8, $s0, $t8 		# $t8 = &array[minimumindex]
	lw $s6, 0($t8)			# $s6 = array[minimumindex]
	# this is for array[j] < array[minimumindex]
	bge $s7, $s6, incrementj 	# go to next element
	move $t1, $t2		  	# minimumindex = j
	j incrementj
	
incrementj:	addi $t2, $t2, 1	# j = j+1
		j SSloop2
		
incrementi:	addi $t0, $t0, 1	# i = i+1
		j SSloop1	
swap:
	move $t7, $zero       		 # temp = 0
	sll $t5, $t0, 2     		 # i = i * 4
	add $t8, $s0, $t5		 # $t8 = &array[i]
	lw $t9, 0($t8)			 # $t9 = array[i] t9 has element in i
		
	move $t7, $t9			 # $t7 = array[i]
			
	sll $s3, $t1, 2			 # minimumindexj = minimumindexj *4
	add $s5, $s0, $s3 		 # $s5 = &array[minimumindexJ] 
	lw $s4, 0($s5)   		 #  $s4 = array[minimumindexJ]
	
	sw $s4, 0($t8)      		 #  &array[i] = array[minimumindexj]
	sw $t7, 0($s5)			 # &array[minimumindexJ] = temp
	j incrementi
loopDone: 
	lw $s1, 0($sp)			 # restore stack pointer
	addi $sp, $sp, 4		 # pop the stack pointer 
	jr  $ra				 # return 
# calculate mean subroutine	
calculateMean: 
	move $t0, $a0  			# move the address of array into a temp register (unneccessary)
	li $t1, 20			# load the length of the array (20 words)
	sll $t3, $t1 ,2  		# $t3 = 20 * 4    80 = $t2
	add $t4, $t0, $t3		# $t4 = &array[size]
	move $t9, $zero			# counter = 0
meanLoop:  # using pointer method
	lw $t7, 0($t0)			# load the integer into a temporary $t7 register
	# add to the counter/accumulator
	add $t9, $t7, $t9		#  $t9 = $t9 + $t7
	# check if end of the array	
	addi $t0, $t0, 4	
	slt $t5, $t0, $t4   		# t5 = (p < &array[size])
	bne $t5, $zero, meanLoop   	# bne 
	
	mtc1 $t9, $f0   		# $f1 = sum of values
	mtc1 $t1, $f2 	 		# $f3 = number of values
	
	div.s $f4, $f0, $f2    	# average = Esum/numberof values
					# $f4 = mean	
	s.s $f4, mean				
	#cvt.w.s $f5, $f4
	#swc1 $f5, 0($a2)
	
	li $v0, 2
	movf.s $f12, $f4
	syscall  			 # print the floating point value to screen
	jr $ra
	
calculateMedian:
	move $t0, $a0  			# move the address of array into a temp register (unneccessary)
	
	li $t1, 20			# load the length of the array (20 words)
	li $t5, 19			# load the length-1 of the array = length -1
	
	addi $t4, $zero, 2		# $t4 = 2
	div $t1, $t4			# divide length/2 and check if it is even or odd
	mfhi $t2			# $t2 has remainder 
	beq $t2, $zero, even
	j odd
	
odd:  	div $t1, $t4			# if odd divide the middle element	
	mflo $t6			# move quotient
	mtc1 $t1, $f0   		# $f1 = length of the number
	mtc1 $t4, $f2 	 		# $f4 = 2
	div.s $f4, $f0, $f2    	# if odd then divide and get value in middle		# $f4 = mean	
	addi $t6, $t6, -1
	sll $t6, $t6, 2
	add $t7, $t0, $t6
	lw $t7, 0($t7)			# load the integer into a temporary $t7 register
	
even: 	
	addi $s7, $zero, 9		# $s7 = 9
	addi $s6, $zero, 10		# $s6 = 10
	sll $s5, $s7, 2 		# $s6 = 9*4 = 
	add $s4, $t0, $s5		# s4 = array[9] 
	lw $s3, 0($s4)
	
	sll $s5, $s6, 2 		# 10*4
	add $s4, $t0, $s5		# s4 = array[10] 
	lw $s2, 0($s4)			# load the value into the register
	add $s2,$s2, $s3               # even so add up the middle values
	mtc1 $s2, $f4   		# $f4 = array[9]
	mtc1 $t4, $f6 	 		# $f3 = array[10]
	
	div.s $f8, $f4, $f6    	# average of the middle values		
	
	li $v0, 2
	movf.s $f12, $f8
	syscall 	
	mfc1 $v1, $f8	
	move $v0, $zero       		#Set $v1 to be a flag to indicate whether the result was int or float so
					# that you can use the appropriate syscall in main to print the median.
	jr $ra
 
calculateStandardDeviation: 
 	move $t0, $a0  			# move the address of array into a temp register (unneccessary)
 	
 	li $s7, 19			#   $s7 = n-1  = 19
 	mtc1 $s7, $f17			# move to cop1  $f17 = 19 = $s7
 	cvt.s.w $f17, $f17		# convert 19 to floating point
	li $t1, 20			# $t1 = 20     load the length of the array (20 words)
	sll $t3, $t1 ,2  		# $t3 = 20 * 4 
	add $t4, $t0, $t3		# $t4 = &array[size]
					
	l.s $f21, mean			#  $t21 = mean
	addi $s6, $zero, 0		# $s6 = 0
	mtc1 $s6, $f9			# $f9 = 0 = $s6
 	cvt.s.w $f9, $f9		# convert 19 to floating point
	add.s   $f10, $f9, $f9		# counter = 0  f10
standardDeviationLoop:
	lw $t7, 0($t0)			# load the integer into a temporary $t7 register
	mtc1 $t7, $f0		
	cvt.s.w $f0, $f0		# convert to floating point number  (CRUCIAL) **
	sub.s $f4, $f0, $f21		#  f4 = value - average
	mul.s $f5, $f4, $f4		# (ri-ravg)^2
	add.s  $f10, $f10, $f5		# accumulator in f10	
	addi $t0, $t0, 4	
	slt $t5, $t0, $t4   		# t5 = (p < &array[size])
	bne $t5, $zero, standardDeviationLoop   	# bne 
	div.s $f14, $f10, $f17		# ri-ravg)^2/ (n-1)
	sqrt.s $f13, $f14
	li $v0, 2
	movf.s $f12, $f13
	syscall  			 # print the floating point value to screen
	jr $ra	
