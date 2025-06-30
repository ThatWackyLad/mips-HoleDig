.data
	shovelStatus: 	.word 0
	userInput: 	.space 20

	#text
	holeStatus:	.asciiz "\nYour hole is" #blahblahblah feet deep
	shopEnter:	.asciiz "\nYou walk into the store to peruse many wares..."
	
	#prompts
	awaken:  	.asciiz "You have an urge to dig a hole. Type 'dig' to dig.\nEnter Input:"
	digPrompt:   	.asciiz "\nType 'dig' to dig the hole.\nType 'check' to see your hole's size. \nType 'shop' to view upgrades.\nEnter Input:"
	shopItems:	.asciiz "\nWooden Shovel - 20ft ('buy wood')\nIron Shovel - 100ft ('buy iron')\nPlatinum Shovel - 1000ft ('buy platinum')"
.text
    main:
    	#establish hole depth
	li $t0, 0
	
	#print intro tutorial message
	li $v0, 4
	la $a0, awaken
	syscall

	#read user input
	li $v0, 8
	la $a0, userInput
	li $a1, 20
	syscall
	
	#enter main game loop
	j dig_loop
	
	
    dig_loop: #main structure to go thru
    
    	# print prompt
    	li $v0, 4
    	la $a0, digPrompt
    	li $a1, 20
    	
    	#read user input
    	li $v0, 8
    	la $a0, userInput
    	li $a1, 3
    	
    	j dig_loop
 
    check:
    
    