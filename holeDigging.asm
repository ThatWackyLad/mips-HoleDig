.data
	#general information storage
	userInput: 	.space 5
	
	holeDepth:	.word 0
	shovelPower:	.word 1
	
	digValue:	.word 0
	sizeValue:	.word 1
	shopValue:	.word 2
	endValue:	.word 3
	
	woodValue:	.word 0
	ironValue:	.word 1
	platValue:	.word 2
	
	woodWorth:	.word 20
	ironWorth:	.word 1000
	platWorth:	.word 10000
	
	woodMult:	.word 5
	ironMult:	.word 15
	platMult:	.word 30

	# Responses
	holeStatus:	.asciiz "\n\nYou look up and estimate your hole is "
	holeStatus2:	.asciiz "ft deep.\n"
	shovelStatus:	.asciiz "Your shovel digs "
	shovelStatus2:	.asciiz "ft per dig. Let's keep digging!\n"
	
	exit:		.asciiz "\nYou ended your run at "
	exit2:		.asciiz "ft deep in your hole and with a shovel strength of "
	exit3:		.asciiz "ft/dig.\nGood work out there!"
	
	error:		.asciiz "\n\nYou did ... something else! Okay!\n"
	digged:		.asciiz "\n\nYou dig your hole deeper.\n"
	
	broke:		.asciiz "\n\nNot enough funds to afford this upgrade...\n"
	purchased:	.asciiz "\nYou buy the shovel and a bit of dirt falls back in the hole.\n"
	
	# Text Fluff
	awaken:  	.asciiz "You have an irritating urge to dig a hole.\n"
	shopEnter:	.asciiz "\n\nYou walk into the store to peruse many wares...\n"
	shopLeave:	.asciiz "\nYou leave the shop and get back to digging.\n"
	
	# Control Prompts
	digPrompt:   	.asciiz "\nType '0' to dig the hole.\nType '1' to see your stats.\nType '2' to view the shovel shop.\nType '3' to end the game.\nEnter Input: "
	shopPrompt:	.asciiz "\nWooden Shovel - Costs 20ft (Type '0')\nIron Shovel - Costs 1000ft (Type '1')\nPlatinum Shovel - Costs 10000ft (Type '2')\nType anything else to leave the shop.\nEnter Input: "	
	
.text
    main:
    
    	#stored info
    	
    	lw $t0, holeDepth
    	lw $t1, shovelPower

    	lw $t2, digValue
    	lw $t3, sizeValue
    	lw $t4, shopValue
	lw $t8, endValue

	lw $t5, woodValue
	lw $t6, ironValue
	lw $t7, platValue
	
	lw $s0, woodWorth
	lw $s1, ironWorth
	lw $s2, platWorth
	
	lw $s3, woodMult
	lw $s4, ironMult
	lw $s5, platMult
	
	# Introduction
	
	li $v0, 4
	la $a0, awaken
	syscall
	j dig_loop
	
    dig_loop: # Gameplay Loop
    
    	# Controls
    	la $a0, digPrompt
    	syscall
    	
    	# Input Read
    	li $v0, 5
    	la $a0, userInput
    	li $a1, 1
    	syscall
    	move $t9, $v0
    	
    	# Branch
    	beq $t9, $t2, dig_hole
    	beq $t9, $t3, check
    	beq $t9, $t4, shop_enter
    	beq $t9, $t8, end
    	
    	# Failsafe
    	#li $v0, 4
    	
	la $a0, error
	syscall
    	j dig_loop
    	
    dig_hole: # Increase Value
    
    	add $t0, $t0, $t1 # Depth = Depth + Shovel's Power
    	
    	li $v0, 4
	la $a0, digged
	syscall
    	
    	j dig_loop
 
    check: # Stats  Communication
    
    	# Depth
    		# First Segment
    		li $v0, 4
		la $a0, holeStatus
		syscall
    		# Number Response
    		li $v0, 1
    		move $a0, $t0
    		syscall
    		# Second Segment
    		li $v0, 4
		la $a0, holeStatus2
		syscall
		
	# Shovel
    		# First Segment
    		li $v0, 4
		la $a0, shovelStatus
		syscall
    		# Number Response
    		li $v0, 1
    		move $a0, $t1
    		syscall
    		# Second Segment
    		li $v0, 4
		la $a0, shovelStatus2
		syscall	
	
	j dig_loop
	
    shop_enter: # Entry
    
    	li $v0, 4
	la $a0, shopEnter
	syscall
	
    	j shop
	
    shop: # Enter branch to get upgrades
	
	# Controls
    	la $a0, shopPrompt
    	syscall
    	
    	# Input Read
    	li $v0, 5
    	la $a0, userInput
    	syscall
    	move $t9, $v0
    	
    	beq $t9, $t5, wood_buy
    	beq $t9, $t6, iron_buy
    	beq $t9, $t7, plat_buy
    	
    	# leave
    	li $v0, 4
    	la $a0, shopLeave
    	syscall
    	
    	j dig_loop
    	
    # Purchases 
    
    wood_buy:
    	bgt $s0, $t0, too_poor
    	
    	#success
    	mul $t1, $t1, $s3 # Shovel Power = Shovel Power * Mult
    	sub $t0, $t0, $s0 # Hole Depth = Hole Depth - Price
    	j successful_purchase
    
    iron_buy:
    	bgt $s1, $t0, too_poor
    	
    	#success
    	mul $t1, $t1, $s4 # Shovel Power = Shovel Power * Mult
    	sub $t0, $t0, $s1 # Hole Depth = Hole Depth - Price
    	j successful_purchase
    
    plat_buy: 
    	bgt $s2, $t0, too_poor
    	#success
    	mul $t1, $t1, $s5 # Shovel Power = Shovel Power * Mult
    	sub $t0, $t0, $s2 # Hole Depth = Hole Depth - Price
    	j successful_purchase
    	
    # Shop results
       	
    successful_purchase:
    	li $v0, 4
    	la $a0, purchased
    	syscall
    	
    	j shop
    
    too_poor:
    	li $v0, 4
	la $a0, broke
	syscall
	
	j shop
    
    end: # Terminate Program and show Stats

	# First Segment
    	li $v0, 4
	la $a0, exit
	syscall
    	# Hole Response
    	li $v0, 1
    	move $a0, $t0
    	syscall
       	# Second Segment
    	li $v0, 4
	la $a0, exit2
	syscall
	# Shovel Response
	li $v0, 1
    	move $a0, $t1
    	syscall
    	# Third Segment
    	li $v0, 4
	la $a0, exit3
	syscall