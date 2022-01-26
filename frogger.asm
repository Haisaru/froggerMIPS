#####################################################################
#
# CSC258H5S Fall 2021 Assembly Final Project
# University of Toronto, St. George
#
# Student: Jason Li, 1005787089
#
# Bitmap Display Configuration:
# - Unit width in pixels: 32
# - Unit height in pixels: 32
# - Display width in pixels: 512
# - Display height in pixels: 512
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestone is reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 5 (choose the one the applies)
#
# Which approved additional features have been implemented?
# (See the assignment handout for the list of additional features)
# 1. Add a third (and more) row in each of the water and road sections.
# 2. objects in different rows move at different speeds.
# 3. Objects increase in speed with completion of more goals
# 4. Show lives in the top left and right hand corners
# 5. Two-player mode (two sets of inputs controlling two frogs at the same time) (ijkl keys)
# 6. Added sound for movement, goal, and collision
#
# 4 easy features and 2 hard features
#
#####################################################################

.data
	displayAddress: .word 0x10008000
	gsize: .word 16  #calculated as (Display width in pixels)/(Unit Width in Pixels)
	red: .word 0xFF0000
	green: .word 0x00FF00
	goalGreen: .word 0x33A110 
	magenta: .word 0xFF00FF
	darkGreen: .word 0x14612A
	blue: .word 0x0000FF
	purple: .word 0xB500FF
	brown: .word 0x8F6116 
	darkBrown: .word 0x863515
	black: .word 0
	
	lives: .word 3
	lives2: .word 3
	
	x: .word 6
	y: .word 15
	
	x2: .word 9
	y2: .word 15
	
	shiftValue: .word 1
	
	carData1: .word 7, 0xA78A77, 8, 0
	carPos1: .word 145,146,150,151,155,156,157
	
	carData2: .word 2, 0x6DD4D6 , 6, 0
	carPos2: .word  166, 174
	
	carData3: .word 4, 0xD66DCD , 8, 0
	carPos3: .word 176,179,182,187,
	
	carData4: .word 3, 0x4E6185 , 8, 0
	carPos4: .word 193,197,206
	
	carData5: .word 8, 0xF7F615, 8, 0
	carPos5: .word 208, 209, 212, 213, 216, 217, 220, 221
	

	
	#riverDatax: .word sizeof(riverPosx), colour, speed, counter
	
	riverData1: .word 8, 0x0000FF, 9, 0
	riverPos1: .word 48, 49, 52, 53, 56, 57, 60, 61
	
	riverData2: .word 3, 0x0000FF, 9, 0
	riverPos2: .word 65, 70, 75
	
	riverData3: .word 7, 0x0000FF, 9, 0
	riverPos3: .word 80,81,82,83, 84, 90,91
	
	riverData4: .word 6, 0x0000FF, 8, 0
	riverPos4: .word 97,98, 103,104, 106,107
		
	riverData5: .word 8, 0x0000FF, 9, 0
	riverPos5: .word 113, 114, 115, 116, 119, 122, 125, 126
	
	
	goalColours: .word 0x0000FF, 0x0000FF, 0x0000FF, 0x0000FF, 0x0000FF
	
	deathpitch: .word 69 
	deathduration: .word 100
	deathinstrument: .word 58
	deathvolume: .word 100
	
	movepitch: .word 69 
	moveduration: .word 100
	moveinstrument: .word 32
	movevolume: .word 100
	
	goalpitch: .word 69 
	goalduration: .word 100
	goalinstrument: .word 0
	goalvolume: .word 100
	
	
	
.text

main:		
		
		jal IOcheck					#check keyboardInput
		
		jal checkGoal				#check if on goal
		jal checkGoalp
		
		jal checkTop				#check if missed goal
		jal checkTop2
		
		lw $t0, lives
		lw $t1, lives2
		bne $t0, $zero, yesLives		#branch if lives are not zero
		bne $t1, $zero, yesLives
		j gameOver
		
		
yesLives:	
		
		li $a0, 0
		li $a1, 16
		li $a2, 1
		lw $a3, black
		jal DrawLRectangle			#draw top ui banner
	
		li $a0, 16
		li $a1, 16
		li $a2, 2
		lw $a3, goalGreen
		jal DrawLRectangle			#draw end row
	
		li $a0, 48
		li $a1, 16
		li $a2, 1
		lw $a3, brown
		jal DrawLRectangle			#draw logs
		
		li $a0, 64
		lw $a3, darkGreen
		jal DrawLRectangle			#draw turtle
		
		li $a0, 80
		lw $a3, brown
		jal DrawLRectangle			#draw logs
		
		li $a0, 96
		lw $a3, darkBrown
		jal DrawLRectangle			#draw logs
		
		li $a0, 112
		lw $a3, darkGreen
		jal DrawLRectangle			#draw turtle
	
	
		li $a0, 128
		li $a1, 16
		li $a2, 1
		lw $a3, purple
		jal DrawLRectangle			#draw rest strip
		
		li $a0, 144
		li $a1, 16
		li $a2, 5
		lw $a3, black
		jal DrawLRectangle			#draw asphalt
		
		li $a0, 224
		li $a1, 16
		li $a2, 1
		lw $a3, purple
		jal DrawLRectangle			#draw spawn strip
	
		li $a0, 240
		li $a1, 16
		li $a2, 1
		lw $a3, black
		jal DrawLRectangle			#draw bottom ui banner
		
		lw $t0, lives				#draw lives		
		
		beq $t0, 3, threelives
		beq $t0, 2, twolives
		beq $t0, 1, onelife
		beq $t0, 0, nolife
threelives:	
		li $a0, 4
		li $a1, 1
		li $a2, 1
		lw $a3, green
		jal DrawLRectangle	
twolives:
		li $a0, 2
		li $a1, 1
		li $a2, 1
		lw $a3, green
		jal DrawLRectangle	
onelife:
		li $a0, 0
		li $a1, 1
		li $a2, 1
		lw $a3, green
		jal DrawLRectangle	
nolife:
		lw $t0, lives2
		
		beq $t0, 3, threelives2
		beq $t0, 2, twolives2
		beq $t0, 1, onelife2
		beq $t0, 0, nolife2
threelives2: 		
		li $a0, 11
		li $a1, 1
		li $a2, 1
		lw $a3, magenta
		jal DrawLRectangle		
twolives2:
		li $a0, 13
		li $a1, 1
		li $a2, 1
		lw $a3, magenta
		jal DrawLRectangle	
onelife2:
		li $a0, 15
		li $a1, 1
		li $a2, 1
		lw $a3, magenta
		jal DrawLRectangle	
nolife2:
		li $a0, 34					#draw goals
		li $a1, 1
		li $a2, 1
		lw $a3, goalColours
		jal DrawLRectangle
		
		li $a0, 37
		lw $a3, goalColours + 4
		jal DrawLRectangle
		
		li $a0, 40
		lw $a3, goalColours + 8
		jal DrawLRectangle
		
		li $a0, 43
		lw $a3, goalColours + 12
		jal DrawLRectangle
		
		li $a0, 46
		lw $a3, goalColours + 16
		jal DrawLRectangle
		
		lw $t0, lives
		beq $t0, $zero, frogdead1		#branch if lives are zero

	
		jal xyToOffset		#now converted from (x, y) to offset stored in $v0
		add $a0, $v0, $zero
		li $a1, 1
		li $a2, 1
		lw $a3, green
		jal DrawLRectangle			#draw frog
		
frogdead1:		
		lw $t0, lives2
		beq $t0, $zero, frogdead2

		jal xyToOffset2		#now converted from (x, y) to offset stored in $v0
		add $a0, $v0, $zero
		li $a1, 1
		li $a2, 1
		lw $a3, magenta
		jal DrawLRectangle			#draw frog2
		
frogdead2:
					###DRAW RIVER###

		la $s0, riverData1			#address of river data array size
		la $s1, riverPos1			#address of river position array
		jal DrawRowR
		
		
		la $s0, riverData2			#address of river data array size
		la $s1, riverPos2		#address of river position array
		jal DrawRowL

	
		la $s0, riverData3			#address of river data array size
		la $s1, riverPos3		#address of river position array
		jal DrawRowR
		
		
		la $s0, riverData4		#address of river data array size
		la $s1, riverPos4	#address of river position array
		jal DrawRowR
		
		la $s0, riverData5		#address of river data array size
		la $s1, riverPos5			#address of river position array
		jal DrawRowL
		
#DRAW CAR
		la $s0, carData1		#address of car position array size
		la $s1, carPos1				#address of car array
		jal DrawRowL
		
		la $s0, carData2		#address of car position array size
		la $s1, carPos2			#address of car array
		jal DrawRowR
		
		la $s0, carData3		#address of car position array size
		la $s1, carPos3			#address of car array
		jal DrawRowL
		
		la $s0, carData4		#address of car position array size
		la $s1, carPos4				#address of car array
		jal DrawRowR
		
		la $s0, carData5		#address of car position array size
		la $s1, carPos5			#address of car array
		jal DrawRowL
		
		li $v0, 32
 		li $a0, 60
 		syscall					#sleep for a bit
	
		j main					#loop main block
		
		
#############
##FUNCTIONS##
#############
	
#Draw a rectangle from the top left corner
#$a0 is top left coord, $a1, width, $a2 is height, $a3 is colour
DrawLRectangle: addi $sp, $sp, -4
		sw $ra, 0($sp)			#push function on stack
		
		lw $t0, gsize
		
		add $t1, $a0, $a1		#to check to crop rectangle in case of overflow
		div $t1, $t0
		mfhi $t1			#$t1 is ammount of overflow
		mflo $t2			#$t2 is quotient of right edge
		div $a0, $t0			#calculating quotient to compare to
		mflo $t3
		beq $t2, $t3, DrawLRecK		#checking if values are on same row
		
		sub $a1, $a1, $t1		#$a1 is new cropped width
		
DrawLRecK:	addi $t9, $zero, 0
		addi $t8, $zero, 0		#initalize index registers as 0
		
DrawLRecL1:	bge $t9, $a2, DrawLRecExit
		addi $t8, $zero, 0		#set inner index back to 0
DrawLRecL2:	bge $t8, $a1, DrawLRecL3
		
		lw $t0, gsize
		lw $t1, displayAddress
		mult $t0, $t9
		mflo $t2			#multiply gsize*outerloop_index
		add $t2, $t2, $t8		#now $t2 is gsize*i + j
		add $t2, $t2, $a0
		
		add $t2, $t2, $t2
		add $t2, $t2, $t2		# we "multiply" by 4 by adding
		
		add $t2, $t2, $t1 		#add offset to display address
		
		sw $a3, 0($t2)			#we paint at $t2
					
		addi $t8, $t8, 1
		j DrawLRecL2
DrawLRecL3:	addi $t9, $t9, 1
		j DrawLRecL1
		
DrawLRecExit:	
		lw $ra, 0($sp)
		addi $sp, $sp, 4		#pop function off stack										
		jr $ra				#return 	 
		
		
		
#draw row of things moving left according to array at address $s1 of size at address $s0
# and of colour at address 4($s0). Counter is at 12($s0) with speed at 8($s0)
DrawRowL:addi $sp, $sp, -4
		sw $ra, 0($sp)				#push function on stack
		
		lw $t2, 8($s0)				#what value to count to
		lw $t3, 12($s0)				#counter
		addi $t3, $t3, 1
		sw $t3, 12($s0)	
		sw $zero, shiftValue
		
		ble $t3, $t2, DrawRowLnoShift
		addi $t2, $zero, 1
		sw $t2, shiftValue			#shiftValue becomes 1
		sw $zero, 12($s0)			#reset counter
		
		
DrawRowLnoShift:

		addi $s7, $zero, 0			#init index variable
		lw $s2, gsize				#init constant gsize
		lw $s3, 0($s0)
		
		

DrawRowL1:	bge $s7, $s3, DrawRowLCheckRiver
		add $s5, $s7, $s7
		add $s5, $s5, $s5			#$s5 now has offset from index*4
	
		add $s5, $s5, $s1			#adding start of array address
		lw $s4, 0($s5)				#$s5 contains block position
		
		add $t0, $s4, $zero			#save old value of $s4
		
		lw $t2, shiftValue
		sub $s4, $s4, $t2			#decrease block position by shiftValue
		
		div $t0, $s2
		mflo $t0
		
		div $s4, $s2
		mflo $t1
		
		beq $t0, $t1, DrawRowL2		#on same row iff same quotient
		add $s4, $s4, $s2			#if not on screen, then shift 
		
DrawRowL2:	
		sw $s4, 0($s5)				#update block position in array
		
		add $a0, $zero, $s4			#copy value of $s4 into $a0
		li $a1, 1
		li $a2, 1
		lw $a3, 4($s0)
		jal DrawLRectangle			#draw block
		
		###CHECKING IF FROG IS HIT BY OBJECT####
		jal xyToOffset
		add $t0, $zero, $v0
		
		bne $t0, $a0, FrogSafeL1
		jal frogDead
		
FrogSafeL1:		
		###CHECKING IF FROG2 IS HIT BY OBJECT####
		jal xyToOffset2
		add $t0, $zero, $v0
		
		bne $t0, $a0, FrogSafeL2
		jal frogDead2
		

FrogSafeL2:
		addi $s7, $s7, 1			#update loop index
		j DrawRowL1
		
		 ###CHECKING IF FROG IS ON LOG###
DrawRowLCheckRiver: lw $t0, y
					lw $t1, gsize
					lw $t2, 0($s1)
					div $t2, $t1
					mflo $t1
					
					beq $t0, 9, DrawRowLCheckRiverp		#check if on road first
					beq $t0, 10, DrawRowLCheckRiverp
					beq $t0, 11, DrawRowLCheckRiverp
					beq $t0, 12, DrawRowLCheckRiverp
					beq $t0, 13, DrawRowLCheckRiverp
					beq $t0, $t1, DrawRowLYesRiver
					j DrawRowLCheckRiverp
DrawRowLYesRiver:   lw $t0, x
					lw $t1, shiftValue
					sub $t0, $t0, $t1		#move frog left by shiftvalue
					sw $t0, x
					
DrawRowLCheckRiverp: lw $t0, y2
					lw $t1, gsize
					lw $t2, 0($s1)
					div $t2, $t1
					mflo $t1
					
					beq $t0, 9, DrawRowLExit		#check if on road first
					beq $t0, 10, DrawRowLExit
					beq $t0, 11, DrawRowLExit
					beq $t0, 12, DrawRowLExit
					beq $t0, 13, DrawRowLExit
					beq $t0, $t1, DrawRowLYesRiverp
					j DrawRowLExit
DrawRowLYesRiverp:   lw $t0, x2
					lw $t1, shiftValue
					sub $t0, $t0, $t1		#move frog left by shiftvalue
					sw $t0, x2
		 
DrawRowLExit: lw $ra, 0($sp)
		addi $sp, $sp, 4		#pop function off stack										
		jr $ra					#return 	
		
		
		
		
		
#draw row of things moving right according to array at address $s1 of size $s0
# and of colour 4($s0). Counter is at 8($s0)
DrawRowR:addi $sp, $sp, -4
		sw $ra, 0($sp)			#push function on stack	
		
		sw $zero, shiftValue
		lw $t2, 8($s0)				#what value to count to
		lw $t3, 12($s0)				#counter
		addi $t3, $t3, 1
		sw $t3, 12($s0)	
		
		ble $t3, $t2, DrawRowRnoShift
		addi $t2, $zero, 1
		sw $t2, shiftValue			#shiftValue becomes 1
		sw $zero, 12($s0)			#reset counter
		
		
DrawRowRnoShift:
		addi $s7, $zero, 0			#init index variable
		lw $s2, gsize				#init constant gsize
		lw $s3, 0($s0)
		
DrawRowR1:	bge $s7, $s3, DrawRowRCheckRiver
		add $s5, $s7, $s7
		add $s5, $s5, $s5			#$s5 now has offset from index*4
	
		add $s5, $s5, $s1			#adding start of array address
		lw $s4, 0($s5)				#$s5 contains block position
		
		add $t0, $s4, $zero			#save old value of $s4

		lw $t2, shiftValue
		add $s4, $s4, $t2			#move car right if shiftValue 1
		
		div $t0, $s2
		mflo $t0
		
		div $s4, $s2
		mflo $t1
		
		
		beq $t0, $t1, DrawRowR2		#on same row iff same quotient
		sub $s4, $s4, $s2			#if not on screen, then shift 
		
DrawRowR2:

		sw $s4, 0($s5)				#update car position in array
		
		add $a0, $zero, $s4			#copy value of $s4 into $a0
		li $a1, 1
		li $a2, 1
		lw $a3, 4($s0)
		jal DrawLRectangle			#draw block
		
		###CHECKING IF FROG IS HIT BY CAR####
		
		jal xyToOffset
		add $t0, $zero, $v0
		
		bne $t0, $a0, FrogSafeR1
		jal frogDead
	
FrogSafeR1:
		###CHECKING IF FROG2 IS HIT BY OBJECT####
		jal xyToOffset2
		add $t0, $zero, $v0
		
		bne $t0, $a0, FrogSafeR2
		jal frogDead2
		

FrogSafeR2:
		addi $s7, $s7, 1			#update loop index
		j DrawRowR1
		
		 ###CHECKING IF FROG IS ON LOG###
DrawRowRCheckRiver: lw $t0, y
					lw $t1, gsize
					lw $t2, 0($s1)
					div $t2, $t1
					mflo $t1
					
					beq $t0, 9, DrawRowRCheckRiverp		#check if on road first
					beq $t0, 10, DrawRowRCheckRiverp
					beq $t0, 11, DrawRowRCheckRiverp
					beq $t0, 12, DrawRowRCheckRiverp
					beq $t0, 13, DrawRowRCheckRiverp
					beq $t0, $t1, DrawRowRYesRiver
					j DrawRowRCheckRiverp
					
DrawRowRYesRiver:   lw $t0, x
					lw $t1, shiftValue
					add $t0, $t0, $t1		#move frog left by shiftValue
					sw $t0, x
					
DrawRowRCheckRiverp: lw $t0, y2
					lw $t1, gsize
					lw $t2, 0($s1)
					div $t2, $t1
					mflo $t1
					
					beq $t0, 9, DrawRowRExit		#check if on road first
					beq $t0, 10, DrawRowRExit
					beq $t0, 11, DrawRowRExit
					beq $t0, 12, DrawRowRExit
					beq $t0, 13, DrawRowRExit
					beq $t0, $t1, DrawRowRYesRiverp
					j DrawRowRExit

DrawRowRYesRiverp: 	lw $t0, x2
					lw $t1, shiftValue
					add $t0, $t0, $t1		#move frog left by shiftvalue
					sw $t0, x2

DrawRowRExit:   lw $ra, 0($sp)
		addi $sp, $sp, 4		#pop function off stack										
		jr $ra					#return 	 				
	
	
#function to check the keyboard input	
IOcheck: 	addi $sp, $sp, -4		#push onto stack
		sw $ra, 0($sp)	
		
		lw $t0, 0xffff0000
		lw $t2, lives
		lw $t3, lives2
		
		beq $t0, 1, keyboardInput
		j IOCheckExit
keyboardInput:  lw $t0, 0xffff0004
		beq $t2, $zero, noplayer1check		#ignore inputs if no lives
		beq $t3, $zero, noplayer2check		#ignore inputs if no lives
		
		beq $t0, 0x77, wPress				
		beq $t0, 0x61, aPress
		beq $t0, 0x73, sPress
		beq $t0, 0x64, dPress
		beq $t0, 0x69, iPress
		beq $t0, 0x6A, jPress
		beq $t0, 0x6B, kPress
		beq $t0, 0x6C, lPress
		j IOCheckExit
		
noplayer2check:
		beq $t0, 0x77, wPress
		beq $t0, 0x61, aPress
		beq $t0, 0x73, sPress
		beq $t0, 0x64, dPress
		j IOCheckExit
noplayer1check:
		beq $t0, 0x69, iPress
		beq $t0, 0x6A, jPress
		beq $t0, 0x6B, kPress
		beq $t0, 0x6C, lPress
		j IOCheckExit
		
wPress:	lw $t0, y
		la $t1, y			#store address of y
		beq $t0, 0, IOCheckExit
		addi $t0, $t0, -1		#decrease y coord
		sw $t0, 0($t1)
		
		li $v0, 31 
		lw $a0, movepitch
		lw $a1, moveduration 
		lw $a2, moveinstrument
		lw $a3, movevolume 
		syscall
		j IOCheckExit			
		
aPress:		lw $t0, x
		la $t1, x			#store address of x
		beq $t0, 0, IOCheckExit
		addi $t0, $t0, -1		#decrease x coord
		sw $t0, 0($t1)
		
		li $v0, 31 
		lw $a0, movepitch
		lw $a1, moveduration 
		lw $a2, moveinstrument
		lw $a3, movevolume 
		syscall
		j IOCheckExit			
		
sPress:		lw $t0, y
		la $t1, y			#store address of y
		beq $t0, 15, IOCheckExit
		addi $t0, $t0, 1		#increase y coord
		sw $t0, 0($t1)
		
		li $v0, 31 
		lw $a0, movepitch
		lw $a1, moveduration 
		lw $a2, moveinstrument
		lw $a3, movevolume 
		syscall
		j IOCheckExit	
				
dPress:		lw $t0, x
		la $t1, x			#store address of x
		beq $t0, 15, IOCheckExit
		addi $t0, $t0, 1		#increase x coord
		sw $t0, 0($t1)
				
		li $v0, 31 
		lw $a0, movepitch
		lw $a1, moveduration 
		lw $a2, moveinstrument
		lw $a3, movevolume 
		syscall
		j IOCheckExit	
iPress:	lw $t0, y2
		la $t1, y2			#store address of y2
		beq $t0, 0, IOCheckExit
		addi $t0, $t0, -1		#decrease y2 coord
		sw $t0, 0($t1)
				
		li $v0, 31 
		lw $a0, movepitch
		lw $a1, moveduration 
		lw $a2, moveinstrument
		lw $a3, movevolume 
		syscall
		j IOCheckExit		
		
jPress:	lw $t0, x2
		la $t1, x2			#store address of x
		beq $t0, 0, IOCheckExit
		addi $t0, $t0, -1		#decrease x coord
		sw $t0, 0($t1)
				
		li $v0, 31 
		lw $a0, movepitch
		lw $a1, moveduration 
		lw $a2, moveinstrument
		lw $a3, movevolume 
		syscall
		j IOCheckExit		
		
kPress:	lw $t0, y2
		la $t1, y2			#store address of y
		beq $t0, 15, IOCheckExit
		addi $t0, $t0, 1		#increase y coord
		sw $t0, 0($t1)
				
		li $v0, 31 
		lw $a0, movepitch
		lw $a1, moveduration 
		lw $a2, moveinstrument
		lw $a3, movevolume 
		syscall
		j IOCheckExit
				
lPress:	lw $t0, x2
		la $t1, x2			#store address of x
		beq $t0, 15, IOCheckExit
		addi $t0, $t0, 1		#increase x coord
		sw $t0, 0($t1)
				
		li $v0, 31 
		lw $a0, movepitch
		lw $a1, moveduration 
		lw $a2, moveinstrument
		lw $a3, movevolume 
		syscall
		j IOCheckExit
				
IOCheckExit:	lw $ra, 0($sp)
		lw $ra, 0($sp)
		addi $sp, $sp, 4		#pop function off stack										
		jr $ra					#return


#loads converts x,y to offset and stores into $v0 register	
xyToOffset:		addi $sp, $sp, -4		#push onto stack
			sw $ra, 0($sp)	
			
			lw $v0, y
			lw $t0, gsize
			mult $v0, $t0
			mflo $v0
			lw $t0, x
			add $v0, $v0, $t0		#now $v0 is offset
			
			lw $ra, 0($sp)
			addi $sp, $sp, 4		#pop function off stack										
			jr $ra					#return
			
			
#loads converts x,y to offset and stores into $v0 register of FROG 2
xyToOffset2:addi $sp, $sp, -4		#push onto stack
			sw $ra, 0($sp)	
			
			lw $v0, y2
			lw $t0, gsize
			mult $v0, $t0
			mflo $v0
			lw $t0, x2
			add $v0, $v0, $t0		#now $v0 is offset
			
			lw $ra, 0($sp)
			addi $sp, $sp, 4		#pop function off stack										
			jr $ra					#return



#call this function when the frog dies		
frogDead: 
		addi $sp, $sp, -4		#push onto stack
		sw $ra, 0($sp)	
		
		li $v0, 31 
		lw $a0, deathpitch
		lw $a1, deathduration 
		lw $a2, deathinstrument
		lw $a3, deathvolume 
		syscall
			
		la $t1, x
		addi $t0, $zero, 6		#reset x coord
		sw $t0, 0($t1)		

		la $t1, y
		addi $t0, $zero, 15		#reset y coord
		sw $t0, 0($t1)
		
		lw $t0, lives
		la $t1, lives
		addi $t0, $t0, -1		#update lives
		sw $t0, 0($t1)			
		
		lw $ra, 0($sp)
		addi $sp, $sp, 4		#pop function off stack										
		jr $ra					#return
		
#call this function when the frog dies		
frogDead2: 
		addi $sp, $sp, -4		#push onto stack
		sw $ra, 0($sp)	
			
		li $v0, 31 
		lw $a0, deathpitch
		lw $a1, deathduration 
		lw $a2, deathinstrument
		lw $a3, deathvolume 

		syscall
		
		la $t1, x2
		addi $t0, $zero, 9		#reset x2 coord
		sw $t0, 0($t1)		

		la $t1, y2
		addi $t0, $zero, 15		#reset y2 coord
		sw $t0, 0($t1)
		
		lw $t0, lives2
		la $t1, lives2
		addi $t0, $t0, -1		#update lives
		sw $t0, 0($t1)			
		
		lw $ra, 0($sp)
		addi $sp, $sp, 4		#pop function off stack										
		jr $ra					#return


checkGoal:		
		addi $sp, $sp, -4		#push onto stack
		sw $ra, 0($sp)	
		
		jal xyToOffset			#offset stored in $v0
		
		
		beq $v0, 34, checkGoal1
		beq $v0, 37, checkGoal2
		beq $v0, 40, checkGoal3
		beq $v0, 43, checkGoal4
		beq $v0, 46, checkGoal5
		
		lw $ra, 0($sp)
		addi $sp, $sp, 4			#pop function off stack										
		jr $ra					#return
		
checkGoal1: 	lw $a3, goalColours + 0
			beq $a3, 0x00FF00, frogDead
			
			jal increaseSpeed		#increase speed
			
			li $v0, 31 
			lw $a0, goalpitch
			lw $a1, goalduration 
			lw $a2, goalinstrument
			lw $a3, goalvolume 
			syscall

			la $t1, x
			addi $t0, $zero, 6		#reset x coord
			sw $t0, 0($t1)
			

			la $t1, y
			addi $t0, $zero, 15		#reset y coord
			sw $t0, 0($t1)
			
			la $t1, goalColours			
			lw $t0, green				
			sw $t0, 0($t1)			#update colour 
			
			lw $ra, 0($sp)
			addi $sp, $sp, 4		#pop function off stack										
			jr $ra					#return
			
checkGoal2: lw $a3, goalColours + 4
			beq $a3, 0x00FF00, frogDead
			
			jal increaseSpeed		#increase speed
			
			li $v0, 31 
			lw $a0, goalpitch
			lw $a1, goalduration 
			lw $a2, goalinstrument
			lw $a3, goalvolume 
			syscall
			
			la $t1, x
			addi $t0, $zero, 6		#reset x coord
			sw $t0, 0($t1)
			

			la $t1, y
			addi $t0, $zero, 15		#reset y coord
			sw $t0, 0($t1)
			
			la $t1, goalColours			
			lw $t0, green				
			sw $t0, 4($t1)			#update colour 
			
			lw $ra, 0($sp)
			addi $sp, $sp, 4		#pop function off stack										
			jr $ra					#return
			
checkGoal3: lw $a3, goalColours + 8
			beq $a3, 0x00FF00, frogDead
			
			jal increaseSpeed		#increase speed
			
			li $v0, 31 
			lw $a0, goalpitch
			lw $a1, goalduration 
			lw $a2, goalinstrument
			lw $a3, goalvolume 
			syscall
			
			la $t1, x
			addi $t0, $zero, 6		#reset x coord
			sw $t0, 0($t1)
			

			la $t1, y
			addi $t0, $zero, 15		#reset y coord
			sw $t0, 0($t1)
			
			la $t1, goalColours			
			lw $t0, green				
			sw $t0, 8($t1)			#update colour 
			
			lw $ra, 0($sp)
			addi $sp, $sp, 4		#pop function off stack										
			jr $ra					#return
			
checkGoal4: lw $a3, goalColours + 12
			beq $a3, 0x00FF00, frogDead
			
			jal increaseSpeed		#increase speed
			
			li $v0, 31 
			lw $a0, goalpitch
			lw $a1, goalduration 
			lw $a2, goalinstrument
			lw $a3, goalvolume 
			syscall
			
			la $t1, x
			addi $t0, $zero, 6		#reset x coord
			sw $t0, 0($t1)
			

			la $t1, y
			addi $t0, $zero, 15		#reset y coord
			sw $t0, 0($t1)
			
			la $t1, goalColours			
			lw $t0, green				
			sw $t0, 12($t1)			#update colour 
			
			lw $ra, 0($sp)
			addi $sp, $sp, 4		#pop function off stack										
			jr $ra					#return
checkGoal5: lw $a3, goalColours + 16
			beq $a3, 0x00FF00, frogDead
			
			jal increaseSpeed		#increase speed
			
			li $v0, 31 
			lw $a0, goalpitch
			lw $a1, goalduration 
			lw $a2, goalinstrument
			lw $a3, goalvolume 
			syscall
			
			la $t1, x
			addi $t0, $zero, 6		#reset x coord
			sw $t0, 0($t1)
			

			la $t1, y
			addi $t0, $zero, 15		#reset y coord
			sw $t0, 0($t1)
			
			la $t1, goalColours			
			lw $t0, green				
			sw $t0, 16($t1)			#update colour 
			
			lw $ra, 0($sp)
			addi $sp, $sp, 4		#pop function off stack										
			jr $ra					#return
			
checkGoalp:		
		addi $sp, $sp, -4		#push onto stack
		sw $ra, 0($sp)	
		
		jal xyToOffset2			#offset stored in $v0
		
		
		beq $v0, 34, checkGoalp1
		beq $v0, 37, checkGoalp2
		beq $v0, 40, checkGoalp3
		beq $v0, 43, checkGoalp4
		beq $v0, 46, checkGoalp5
		
		lw $ra, 0($sp)
		addi $sp, $sp, 4			#pop function off stack										
		jr $ra						#return
		
checkGoalp1: 	lw $a3, goalColours + 0
			beq $a3, 0x00FF00, frogDead2
			
			jal increaseSpeed		#increase speed
			
			li $v0, 31 
			lw $a0, goalpitch
			lw $a1, goalduration 
			lw $a2, goalinstrument
			lw $a3, goalvolume 
			syscall

			la $t1, x2
			addi $t0, $zero, 9		#reset x2 coord
			sw $t0, 0($t1)
			

			la $t1, y2
			addi $t0, $zero, 15		#reset y2 coord
			sw $t0, 0($t1)
			
			la $t1, goalColours			
			lw $t0, green				
			sw $t0, 0($t1)			#update colour 
			
			lw $ra, 0($sp)
			addi $sp, $sp, 4		#pop function off stack										
			jr $ra					#return
			
checkGoalp2: lw $a3, goalColours + 4
			beq $a3, 0x00FF00, frogDead2
			
			jal increaseSpeed		#increase speed
			
			li $v0, 31 
			lw $a0, goalpitch
			lw $a1, goalduration 
			lw $a2, goalinstrument
			lw $a3, goalvolume 
			syscall
			
			la $t1, x2
			addi $t0, $zero, 9		#reset x2 coord
			sw $t0, 0($t1)

			la $t1, y2
			addi $t0, $zero, 15		#reset y2 coord
			sw $t0, 0($t1)
			
			la $t1, goalColours			
			lw $t0, green				
			sw $t0, 4($t1)			#update colour 
			
			lw $ra, 0($sp)
			addi $sp, $sp, 4		#pop function off stack										
			jr $ra					#return
			
checkGoalp3: lw $a3, goalColours + 8
			beq $a3, 0x00FF00, frogDead2
			
			jal increaseSpeed		#increase speed
			
			li $v0, 31 
			lw $a0, goalpitch
			lw $a1, goalduration 
			lw $a2, goalinstrument
			lw $a3, goalvolume 
			syscall
			
			la $t1, x2
			addi $t0, $zero, 9		#reset x2 coord
			sw $t0, 0($t1)
			

			la $t1, y2
			addi $t0, $zero, 15		#reset y2 coord
			sw $t0, 0($t1)
			
			la $t1, goalColours			
			lw $t0, green				
			sw $t0, 8($t1)			#update colour 
			
			lw $ra, 0($sp)
			addi $sp, $sp, 4		#pop function off stack										
			jr $ra					#return
			
checkGoalp4: lw $a3, goalColours + 12
			beq $a3, 0x00FF00, frogDead2
			
			jal increaseSpeed		#increase speed
			
			li $v0, 31 
			lw $a0, goalpitch
			lw $a1, goalduration 
			lw $a2, goalinstrument
			lw $a3, goalvolume 
			syscall
			
			la $t1, x2
			addi $t0, $zero, 9		#reset x2 coord
			sw $t0, 0($t1)
			

			la $t1, y2
			addi $t0, $zero, 15		#reset y2 coord
			sw $t0, 0($t1)
			
			la $t1, goalColours			
			lw $t0, green				
			sw $t0, 12($t1)			#update colour 
			
			lw $ra, 0($sp)
			addi $sp, $sp, 4		#pop function off stack										
			jr $ra					#return
checkGoalp5: lw $a3, goalColours + 16
			beq $a3, 0x00FF00, frogDead2
			
			jal increaseSpeed		#increase speed
			
			li $v0, 31 
			lw $a0, goalpitch
			lw $a1, goalduration 
			lw $a2, goalinstrument
			lw $a3, goalvolume 
			syscall
			
			la $t1, x2
			addi $t0, $zero, 9		#reset x2 coord
			sw $t0, 0($t1)
			

			la $t1, y2
			addi $t0, $zero, 15		#reset y2 coord
			sw $t0, 0($t1)
			
			la $t1, goalColours			
			lw $t0, green				
			sw $t0, 16($t1)			#update colour 
			
			lw $ra, 0($sp)
			addi $sp, $sp, 4		#pop function off stack										
			jr $ra					#return
			
checkTopp: 	addi $sp, $sp, -4		#push onto stack
			sw $ra, 0($sp)	
			
			jal xyToOffset2
			
			beq $v0, 32, frogDead2
			beq $v0, 33, frogDead2
			beq $v0, 35, frogDead2
			beq $v0, 36, frogDead2
			beq $v0, 38, frogDead2
			beq $v0, 39, frogDead2
			beq $v0, 41, frogDead2
			beq $v0, 42, frogDead2
			beq $v0, 44, frogDead2
			beq $v0, 45, frogDead2
			beq $v0, 47, frogDead2
		
		
			lw $ra, 0($sp)
			addi $sp, $sp, 4		#pop function off stack										
			jr $ra					#return			
			
			
			
	
checkTop: 	addi $sp, $sp, -4		#push onto stack
			sw $ra, 0($sp)	
			
			jal xyToOffset
			
			beq $v0, 32, frogDead
			beq $v0, 33, frogDead
			beq $v0, 35, frogDead
			beq $v0, 36, frogDead
			beq $v0, 38, frogDead
			beq $v0, 39, frogDead
			beq $v0, 41, frogDead
			beq $v0, 42, frogDead
			beq $v0, 44, frogDead
			beq $v0, 45, frogDead
			beq $v0, 47, frogDead
		
		
			lw $ra, 0($sp)
			addi $sp, $sp, 4		#pop function off stack										
			jr $ra					#return
			
checkTop2: 	addi $sp, $sp, -4		#push onto stack
			sw $ra, 0($sp)	
			
			jal xyToOffset2
			
			beq $v0, 32, frogDead2
			beq $v0, 33, frogDead2
			beq $v0, 35, frogDead2
			beq $v0, 36, frogDead2
			beq $v0, 38, frogDead2
			beq $v0, 39, frogDead2
			beq $v0, 41, frogDead2
			beq $v0, 42, frogDead2
			beq $v0, 44, frogDead2
			beq $v0, 45, frogDead2
			beq $v0, 47, frogDead2
		
		
			lw $ra, 0($sp)
			addi $sp, $sp, 4		#pop function off stack										
			jr $ra					#return
			
increaseSpeed:
			addi $sp, $sp, -4		#push onto stack
			sw $ra, 0($sp)	
			
			lw $t9, carData1 + 8
			addi $t9, $t9, -1
			
			lw $t9, carData2 + 8
			addi $t9, $t9, -1
			
			lw $t9, carData3 + 8
			addi $t9, $t9, -1
			
			lw $t9, carData4 + 8
			addi $t9, $t9, -1
			
			lw $t9, carData5 + 8
			addi $t9, $t9, -1
			
			lw $t9, riverData1 + 8
			addi $t9, $t9, -1
			
			lw $t9, riverData2 + 8
			addi $t9, $t9, -1
			
			lw $t9, riverData3 + 8
			addi $t9, $t9, -1
			
			lw $t9, riverData4 + 8
			addi $t9, $t9, -1
			
			lw $t9, riverData5 + 8
			addi $t9, $t9, -1
		
			lw $ra, 0($sp)
			addi $sp, $sp, 4		#pop function off stack										
			jr $ra					#return
			
			
		
gameOver:

		li $a0, 0
		li $a1, 16
		li $a2, 16
		lw $a3, red
		jal DrawLRectangle
		
		
		li $a0, 85
		li $a1, 1
		li $a2, 1
		lw $a3, black
		jal DrawLRectangle
		
		li $a0, 89
		jal DrawLRectangle
		
		li $a0, 180
		jal DrawLRectangle
		
		li $a0, 186
		jal DrawLRectangle
		
		li $a0, 165
		li $a1, 5
		jal DrawLRectangle	
		
		li $v0, 10 # terminate the program gracefully
		syscall