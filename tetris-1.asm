################ CSC258H1F Winter 2024 Assembly Final Project ##################
# This file contains our implementation of Tetris.
#
# Student 1: Jingbo Yang, 1007969165
# Student 2: Muzi Zhhao, 1009255887
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       1
# - Unit height in pixels:      1
# - Display width in pixels:    256
# - Display height in pixels:   512
# - Base Address for Display:   0x10008000 ($gp)
##############################################################################

    .data 0x10000030
bottom_array: .space 52
top_array: .space 52
left_array: .space 124
right_array: .space 124
taken_memory: .space 1404
taken_memory_index: .word 0

check_address: .word 0
check_state: .word 0
check_storage: .word 0
check_storage_2: .word 0
check_area_storage: .word 0
Tetro: .word 0
move_storage_2: .word 0
rotate_storage: .word 0
##############################################################################
# Immutable Data
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
    .data
ADDR_DSPL:
    .word 0x10008000
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
    .word 0xffff0000
    
##############################################################################
# Mutable Data
##############################################################################
    curr: .word 0
    memory_1: .word 0 
    memory_2: .word 0
    previous_4: .word 0
    previous_3: .word 0
    previous_2: .word 0
    previous: .word 0
    Shape: .word 0
    array_ra_storage: .word 0
    draw_ra_storage: .word 0
    set_ra_storage: .word 0
    remove_ra_storage: .word 0
    ra_storage: .word 0
    ra_storage_2: .word 0
    ra_storage_3: .word 0
    ra_storage_cor: .word 0
    ra_storage_ins: .word 0
    move_storage: .word 0
    ra_storage_game_loop: .word 0 
    Tetro_address: .word 0
    Tetro_current_state: .word 0
    counter: .word 0
    counter_1: .word 1
##############################################################################
# Code
##############################################################################
	.text
	.globl main
	.globl clear_screen
	.globl draw_walls
	.globl draw_vertical_wall
	.globl draw_horizontal_wall
	.globl draw_board

	# Run the Tetris agame.
main:
    # Initialize the game
    jal clear_screen
    jal load_bottom_array
    jal load_left_array
    jal load_right_array
    jal load_top_array
    jal draw_board
main_two:   
    jal draw_walls
main_three:
    li $a3, 0x10008000
    add $a3, $a3, 524288
    li $t0, 0x0F0F0F
    jal draw_big_square
    
    li $a3, 0x10008000
    add $a3, $a3, 524288
    add $a3, $a3, 32768
    add $a3, $a3, 868
    sw $a3, Tetro_address
    jal random
    sw $a0, previous_4
    jal draw
    
    li $a3, 0x10008000
    add $a3, $a3, 524288
    add $a3, $a3, 32768
    add $a3, $a3, 612
    sw $a3, Tetro_address
    jal random
    sw $a0, previous_3
    jal draw
    
    li $a3, 0x10008000
    add $a3, $a3, 524288
    add $a3, $a3, 32768
    add $a3, $a3, 356
    sw $a3, Tetro_address
    jal random
    sw $a0, previous_2
    jal draw
    
    li $a3, 0x10008000
    add $a3, $a3, 524288
    add $a3, $a3, 32768
    add $a3, $a3, 100
    sw $a3, Tetro_address
    jal random
    sw $a0, previous
    jal draw
    
    li $a0, 0x10008000
    add $a0, $a0, 484
    sw $a0, Tetro_address   
    jal random
    jal draw
    j game_loop
    
main_four:
    li $a3, 0x10008000
    add $a3, $a3, 524288
    li $t0, 0x0F0F0F
    jal draw_big_square
      
    lw $a3, previous
    sw $a3, curr
    li $a3, 0x10008000
    add $a3, $a3, 524288
    add $a3, $a3, 32768
    add $a3, $a3, 100
    sw $a3, Tetro_address
    lw $a3, previous_2
    sw $a3, previous
    sw $a3, Shape
    jal draw
    
    li $a3, 0x10008000
    add $a3, $a3, 524288
    add $a3, $a3, 32768
    add $a3, $a3, 356
    sw $a3, Tetro_address
    lw $a3, previous_3
    sw $a3, previous_2
    sw $a3, Shape
    jal draw
    
    li $a3, 0x10008000
    add $a3, $a3, 524288
    add $a3, $a3, 32768
    add $a3, $a3, 612
    sw $a3, Tetro_address
    lw $a3, previous_4
    sw $a3, previous_3
    sw $a3, Shape
    jal draw
    
    li $a3, 0x10008000
    add $a3, $a3, 524288
    add $a3, $a3, 32768
    add $a3, $a3, 868
    sw $a3, Tetro_address
    jal random
    sw $a0, previous_4
    jal draw
        
    li $a0, 0x10008000
    add $a0, $a0, 484
    sw $a0, Tetro_address   
    lw $a3, curr
    sw $a3, Shape
    jal draw
                                
    j game_loop
    
            
main_five:
end_loop:
    la $t0, 0xffff0000               # $t0 = base address for keyboard
    lw $t8, 0($t0)                  # Load first word from keyboard
    beq $t8, 1, keyboard_input_2
    b end_loop    
keyboard_input_2:                     # A key is pressed
    lw $a1, 4($t0)                  # Load second word from keyboard
    beq $a1, 0x73, action
    beq $a1, 0x64, terminate   
    j end_loop
action:
    li $t7, 0
    li $t9, 351
    li $t8, 0
action_loop:
    sw $t7, taken_memory($t8)
    add $t8, $t8, 4
    sub $t9, $t9, 1
    bnez $t9, action_loop    
    j main
    
terminate:
   li $v0, 10
   syscall    
        
    	
game_loop:
    la $t0, 0xffff0000               # $t0 = base address for keyboard
    lw $t8, 0($t0)                  # Load first word from keyboard
    beq $t8, 1, keyboard_input
   # If first word is 1, key is pressed
    jal check_remove_area
    jal game_over
    b game_loop
    
keyboard_input:                     # A key is pressed
    lw $a1, 4($t0)                  # Load second word from keyboard
    beq $a1, 0x73, move_down_Tetro
    beq $a1, 0x61, move_left_Tetro
    beq $a1, 0x64, move_right_Tetro
    beq $a1, 0x77, rotate_Tetro
    beq $a1, 0x20, terminate
    j game_loop
        
	# 1a. Check if key has been pressed
    # 1b. Check which key has been pressed
    # 2a. Check for collisions
	# 2b. Update locations (paddle, ball)
	# 3. Draw the screen
	# 4. Sleep
    #5. Go back to 1
    
    b game_loop
       
        
delay_half_second:
    sw $ra, counter_1
    li $t0, 0                # Initialize counter to 0
    sw $t0, memory_1
    li $t1, 25000         # Set up loop counter for half-second delay at 1 GHz (example)
    sw $t1, memory_2
delay_loop:
    lw $t0, memory_1
    addi $t0, $t0, 1         # Increment counter
    sw $t0, memory_1
    lw $t1, memory_2
    bne $t0, $t1, delay_loop # Keep looping until half-second has passed
    jal move_down_Tetro
    lw $ra, counter_1
    jr $ra                   # Return to the caller
    
random:
    sw $ra, counter_1
    addi $a1, $zero, 7
    addi $v0, $zero, 42
    syscall
    addi $a0, $a0, 1
    sw $a0, Shape
    lw $ra, counter_1
    jr $ra
    
draw:
    sw $ra, counter_1
    lw $a0, Shape
    beq $a0, 1, Tetro_one
    beq $a0, 2, Tetro_two_state_zero
    beq $a0, 3, Tetro_three_state_zero
    beq $a0, 4, Tetro_four_state_zero
    beq $a0, 5, Tetro_five_state_zero
    beq $a0, 6, Tetro_six_state_zero
    beq $a0, 7, Tetro_seven
    lw $ra, counter_1
    jr $ra
   
draw_G:
    li $a3, 0x10008000
    add $a3, $a3, 81920
    add $a3, $a3, 100
    jal draw_part_G
    li $a3, 0x10008000
    add $a3, $a3, 81920
    add $a3, $a3, 420
    jal draw_part_G
    j main_five
    
draw_part_G:
    sw $ra, counter
    li $t0, 0xFFFFFF
    jal draw_square
    add $a3, $a3, 64
    jal draw_square
    add $a3, $a3, 64
    jal draw_square
    add $a3, $a3, 64
    jal draw_square
    sub $a3, $a3, 192
    add $a3, $a3, 16384
    jal draw_square
    add $a3, $a3, 16384
    jal draw_square
    add $a3, $a3, 16384
    jal draw_square
    add $a3, $a3, 64
    jal draw_square
    add $a3, $a3, 64
    jal draw_square
    add $a3, $a3, 64
    jal draw_square
    sub $a3, $a3, 16384
    jal draw_square
    lw $ra, counter
    jr $ra
                    
load_top_array:
    sw $ra, counter_1
    li $s0, 0x10008000
    add $s0, $s0, 49252
    li $t9, 13
    li $t8, 0
load_loop:
    sw $s0, top_array($t8)
    add $s0, $s0, 64
    add $t8, $t8 4
    sub $t9, $t9, 1
    bnez $t9, load_loop    
    lw $ra, counter_1
    jr $ra

game_over:
    sw $ra, ra_storage_2
    li $t1, 13
    li $t2, 0
over_loop:
    lw $t6, top_array($t2)
    li $t9, 351
    li $t8, 0
inner_loop:    
    lw $t7, taken_memory($t8)
    beq $t7, $t6, draw_G
    add $t8, $t8, 4
    sub $t9, $t9, 1
    bnez $t9, inner_loop
    
    add $t2, $t2, 4
    sub $t1, $t1, 1
    bnez $t1, over_loop
            
    lw $ra, ra_storage_2
    jr $ra        
            
move_right_Tetro:
    sw $ra, move_storage_2
    lw $s0, Tetro
    beq, $s0, 1, move_right_Tetro_one
    beq, $s0, 2, move_right_Tetro_two
    beq, $s0, 3, move_right_Tetro_three
    beq, $s0, 4, move_right_Tetro_four
    beq, $s0, 5, move_right_Tetro_five
    beq, $s0, 6, move_right_Tetro_six
    beq, $s0, 7, move_right_Tetro_seven
    lw $ra, move_storage_2
    jr $ra        
    
move_left_Tetro:
    sw $ra, move_storage_2
    lw $s0, Tetro
    beq, $s0, 1, move_left_Tetro_one
    beq, $s0, 2, move_left_Tetro_two
    beq, $s0, 3, move_left_Tetro_three
    beq, $s0, 4, move_left_Tetro_four
    beq, $s0, 5, move_left_Tetro_five
    beq, $s0, 6, move_left_Tetro_six
    beq $s0, 7, move_left_Tetro_seven
    lw $ra, move_storage_2
    jr $ra
        
move_down_Tetro:
    sw $ra, move_storage_2
    lw $s0, Tetro
    beq, $s0, 1, move_down_Tetro_one
    beq, $s0, 2, move_down_Tetro_two
    beq, $s0, 3, move_down_Tetro_three
    beq, $s0, 4, move_down_Tetro_four
    beq, $s0, 5, move_down_Tetro_five
    beq $s0, 6, move_down_Tetro_six
    beq $s0, 7, move_down_Tetro_seven
    lw $ra, move_storage_2
    jr $ra
    
move_right_Tetro_six:
    sw $ra, move_storage
    lw $t0, Tetro_current_state
    beq $t0, 0, move_right_Tetro_six_state_zero
    beq $t0, 1, move_right_Tetro_six_state_one
    lw $ra, move_storage
    jr $ra
    
move_left_Tetro_six:
    sw $ra, move_storage
    lw $t0, Tetro_current_state
    beq $t0, 0, move_left_Tetro_six_state_zero
    beq $t0, 1, move_left_Tetro_six_state_one
    lw $ra, move_storage
    jr $ra
            
move_down_Tetro_six:
    sw $ra, move_storage
    lw $t0, Tetro_current_state
    beq $t0, 0, move_down_Tetro_six_state_zero
    beq $t0, 1, move_down_Tetro_six_state_one 
    lw $ra, move_storage
    jr $ra
    
move_right_Tetro_five:
    sw $ra, move_storage
    lw $t0, Tetro_current_state
    beq $t0, 0, move_right_Tetro_five_state_zero 
    beq $t0, 1, move_right_Tetro_five_state_one
    lw $ra, move_storage
    jr $ra
    
move_left_Tetro_five:
    sw $ra, move_storage
    lw $t0, Tetro_current_state
    beq $t0, 0, move_left_Tetro_five_state_zero
    beq $t0, 1, move_left_Tetro_five_state_one 
    lw $ra, move_storage
    jr $ra
    
move_down_Tetro_five:
    sw $ra, move_storage
    lw $t0, Tetro_current_state
    beq $t0, 0, move_down_Tetro_five_state_zero
    beq $t0, 1, move_down_Tetro_five_state_one  
    lw $ra, move_storage
    jr $ra
    
move_right_Tetro_four:
    sw $ra, move_storage
    lw $t0, Tetro_current_state
    beq $t0, 0, move_right_Tetro_four_state_zero
    beq $t0, 1, move_right_Tetro_four_state_one 
    beq $t0, 2, move_right_Tetro_four_state_two 
    beq $t0, 3, move_right_Tetro_four_state_three   
    lw $ra, move_storage
    jr $ra
    
move_left_Tetro_four:
    sw $ra, move_storage
    lw $t0, Tetro_current_state
    beq $t0, 0, move_left_Tetro_four_state_zero
    beq $t0, 1, move_left_Tetro_four_state_one 
    beq $t0, 2, move_left_Tetro_four_state_two
    beq $t0, 3, move_left_Tetro_four_state_three  
    lw $ra, move_storage
    jr $ra
            
move_down_Tetro_four:
    sw $ra, move_storage
    lw $t0, Tetro_current_state
    beq $t0, 0, move_down_Tetro_four_state_zero
    beq $t0, 1, move_down_Tetro_four_state_one 
    beq $t0, 2, move_down_Tetro_four_state_two
    beq $t0, 3, move_down_Tetro_four_state_three   
    lw $ra, move_storage
    jr $ra
    
move_right_Tetro_three:
    sw $ra, move_storage
    lw $t0, Tetro_current_state
    beq $t0, 0, move_right_Tetro_three_state_zero
    beq $t0, 1, move_right_Tetro_three_state_one 
    beq $t0, 2, move_right_Tetro_three_state_two
    beq $t0, 3, move_right_Tetro_three_state_three      
    lw $ra, move_storage
    jr $ra
    
move_left_Tetro_three:
    sw $ra, move_storage
    lw $t0, Tetro_current_state
    beq $t0, 0, move_left_Tetro_three_state_zero
    beq $t0, 1, move_left_Tetro_three_state_one 
    beq $t0, 2, move_left_Tetro_three_state_two
    beq $t0, 3, move_left_Tetro_three_state_three    
    lw $ra, move_storage
    jr $ra
    
move_down_Tetro_three:
    sw $ra, move_storage
    lw $t0, Tetro_current_state
    beq $t0, 0, move_down_Tetro_three_state_zero
    beq $t0, 1, move_down_Tetro_three_state_one
    beq $t0, 2, move_down_Tetro_three_state_two
    beq $t0, 3, move_down_Tetro_three_state_three       
    lw $ra, move_storage
    jr $ra
    
move_down_Tetro_two:
    sw $ra, move_storage           
    lw $t0, Tetro_current_state
    beq $t0, 0, move_down_Tetro_two_state_zero
    beq $t0, 1, move_down_Tetro_two_state_one
    lw $ra, move_storage
    jr $ra

move_left_Tetro_two:
    sw $ra, move_storage           
    lw $t0, Tetro_current_state
    beq $t0, 0, move_left_Tetro_two_state_zero
    beq $t0, 1, move_left_Tetro_two_state_one
    lw $ra, move_storage
    jr $ra

move_right_Tetro_two:
    sw $ra, move_storage           
    lw $t0, Tetro_current_state
    beq $t0, 0, move_right_Tetro_two_state_zero
    beq $t0, 1, move_right_Tetro_two_state_one
    lw $ra, move_storage
    jr $ra                        
                                            
move_right_Tetro_one:
    sw $ra, move_storage
    lw $t0, Tetro_current_state
    beq $t0, 0, move_right_Tetro_one_state_zero
    beq $t0, 1, move_right_Tetro_one_state_one
    beq $t0, 2, move_right_Tetro_one_state_two
    beq $t0, 3, move_right_Tetro_one_state_three
    lw $ra, move_storage
    jr $ra
move_left_Tetro_one:
    sw $ra, move_storage
    lw $t0, Tetro_current_state
    beq $t0, 0, move_left_Tetro_one_state_zero
    beq $t0, 1, move_left_Tetro_one_state_one
    beq $t0, 2, move_left_Tetro_one_state_two
    beq $t0, 3, move_left_Tetro_one_state_three
    lw $ra, move_storage
    jr $ra
move_down_Tetro_one:
    sw $ra, move_storage           
    lw $t0, Tetro_current_state
    beq $t0, 0, move_down_Tetro_one_state_zero
    beq $t0, 1, move_down_Tetro_one_state_one
    beq $t0, 2, move_down_Tetro_one_state_two
    beq $t0, 3, move_down_Tetro_one_state_three
    lw $ra, move_storage
    jr $ra
        
check_remove_area:
    sw $ra, check_area_storage
    li $s1, 0x10008000
    add $s1, $s1, 65636
    li $s0, 27
check_remove_area_vertical_loop:    
    sw $s1, check_address
    jal check_remove_line
    add $s1, $s1, 16384
    sub $s0, $s0, 1
    bnez $s0, check_remove_area_vertical_loop
    lw $ra, check_area_storage
    jr $ra
                                               
check_remove_line:
    sw $ra, check_storage
    lw $s3, check_address
    move $s2, $s3
    li $t1, 13
check_address_loop:    
    li $t9, 351
    li $t8, 0
check_remove_line_loop:
    lw $t7, taken_memory($t8)
    beq $t7, $s3, check_next
    add $t8, $t8, 4
    sub $t9, $t9, 1
    bnez $t9, check_remove_line_loop
    j terminate_loop
check_next:
    add $s3, $s3, 64
    sub $t1, $t1, 1
    bnez $t1, check_address_loop
    sw $s2, check_address
    jal remove_line
    jal draw_new_state    
terminate_loop:          
    lw $ra, check_storage
    jr $ra
    
draw_new_state:
    sw $ra, draw_ra_storage
    li $t9, 351
    li $t8, 0
draw_new_state_loop:    
    lw $a3, taken_memory($t8)
    beq $a3, 0, next_grid
    lw $t2, check_address
    slt $t0, $a3, $t2
    beq $t0, 0, skip_add_draw_new_state
    add $a3, $a3, 16384
skip_add_draw_new_state:    
    li $t0, 0x5C5B3E
    jal draw_square
    sw $a3, taken_memory($t8)
next_grid:
    add $t8, $t8, 4
    sub $t9, $t9, 1
    bnez $t9, draw_new_state_loop
    lw $ra, draw_ra_storage
    jr $ra
    
remove_state:
    sw $ra, remove_ra_storage
    li $t9, 351
    sw $t9, counter
    li $t8, 0
    sw $t8, counter_1
remove_state_loop:    
    lw $a1, taken_memory($t8)
    beq $a1, 0, skip_remove
    jal remove_grid
skip_remove:
    lw $t8, counter_1
    add $t8, $t8, 4
    sw $t8, counter_1
    lw $t9, counter
    sub $t9, $t9, 1
    sw $t9, counter
    bnez $t9, remove_state_loop
    lw $ra, remove_ra_storage
    jr $ra
                        
remove_line:
    sw $ra, check_storage_2
    lw $a1, check_address
    li $t9, 13
    sw $t9, counter
remove_line_loop:
    jal remove_memory
    jal remove_grid           
    add $a1, $a1, 64
    lw $t9, counter
    sub $t9, $t9, 1
    sw $t9, counter
    bnez $t9, remove_line_loop
    jal remove_state            
    lw $ra, check_storage_2
    jr $ra
    
remove_memory:
    sw $ra, remove_ra_storage
    lw $s2, check_address
    li $t6, 13
remove_memory_horizontal_loop:    
    li $t9, 351
    li $t8, 0
remove_memory_loop:
    lw $t7, taken_memory($t8)
    beq $s2, $t7, set_zero
    add $t8, $t8, 4
    sub $t9, $t9, 1
    bnez $t9, remove_memory_loop
    
    add $s2, $s2, 64
    sub $t6, $t6, 1
    bnez $t6, remove_memory_horizontal_loop    
    lw $ra, remove_ra_storage
    jr $ra
    
set_zero:
    sw $ra, set_ra_storage
    li $t7, 0
    sw $t7, taken_memory($t8)
    lw $ra, set_ra_storage
    jr $ra        
                    
insertion_loop:
    sw $ra, ra_storage_ins
    lw $a2, taken_memory($t2)
    beq $a2, 0, insert
    add $t2, $t2, 4
    j insertion_loop
insert:
    sw $a3, taken_memory($t2)     
    lw $ra, ra_storage_ins
    jr $ra
    
store_coord_Tetro_seven:
    lw $a3, Tetro_address
    li $t2, 0
    jal insertion_loop
    add $a3, $a3, 64
    li $t2, 0
    jal insertion_loop
    add $a3, $a3, 16384
    li $t2, 0
    jal insertion_loop
    sub $a3, $a3, 64
    li $t2, 0
    jal insertion_loop
    j jump_back
    
store_coord_Tetro_six_state_one:
    lw $a3, Tetro_address
    li $t2, 0
    jal insertion_loop
    add $a3, $a3, 16384
    li $t2, 0
    jal insertion_loop
    sub $a3, $a3, 64
    li $t2, 0
    jal insertion_loop
    add $a3, $a3, 16384
    li $t2, 0
    jal insertion_loop
    j jump_back
            
store_coord_Tetro_six_state_zero:
    lw $a3, Tetro_address
    li $t2, 0
    jal insertion_loop
    add $a3, $a3, 64
    li $t2, 0
    jal insertion_loop
    add $a3, $a3, 16384
    li $t2, 0
    jal insertion_loop
    add $a3, $a3, 64
    li $t2, 0
    jal insertion_loop
    j jump_back
        
store_coord_Tetro_five_state_one:
    lw $a3, Tetro_address
    li $t2, 0
    jal insertion_loop
    add $a3, $a3, 16384
    li $t2, 0
    jal insertion_loop
    add $a3, $a3, 64
    li $t2, 0
    jal insertion_loop
    add $a3, $a3, 16384
    li $t2, 0
    jal insertion_loop
    j jump_back
    
store_coord_Tetro_five_state_zero:
    lw $a3, Tetro_address
    li $t2, 0
    jal insertion_loop
    add $a3, $a3, 64
    li $t2, 0
    jal insertion_loop
    sub $a3, $a3, 128
    add $a3, $a3, 16384
    li $t2, 0
    jal insertion_loop
    add $a3, $a3, 64
    li $t2, 0
    jal insertion_loop
    j jump_back
    
store_coord_Tetro_four_state_three:
    lw $a3, Tetro_address
    li $t2, 0
    jal insertion_loop
    add $a3, $a3, 64
    li $t2, 0
    jal insertion_loop
    add $a3, $a3, 64
    li $t2, 0
    jal insertion_loop
    add $a3, $a3, 16384
    li $t2, 0
    jal insertion_loop
    j jump_back
            
store_coord_Tetro_four_state_two:
    lw $a3, Tetro_address
    li $t2, 0
    jal insertion_loop
    add $a3, $a3, 64
    li $t2, 0
    jal insertion_loop
    sub $a3, $a3, 64
    add $a3, $a3, 16384
    li $t2, 0
    jal insertion_loop
    add $a3, $a3, 16384
    li $t2, 0
    jal insertion_loop
    j jump_back
        
store_coord_Tetro_four_state_one:
    lw $a3, Tetro_address
    li $t2, 0
    jal insertion_loop
    add $a3, $a3, 16384
    li $t2, 0
    jal insertion_loop
    add $a3, $a3, 64
    li $t2, 0
    jal insertion_loop
    add $a3, $a3, 64
    li $t2, 0
    jal insertion_loop
    j jump_back
    
store_coord_Tetro_four_state_zero:
    lw $a3, Tetro_address
    li $t2, 0
    jal insertion_loop
    add $a3, $a3, 16384
    li $t2, 0
    jal insertion_loop
    add $a3, $a3, 16384
    li $t2, 0
    jal insertion_loop
    sub $a3, $a3, 64
    li $t2, 0
    jal insertion_loop
    j jump_back        
    
store_coord_Tetro_three_state_three:
    lw $a3, Tetro_address
    li $t2, 0
    jal insertion_loop
    add $a3, $a3, 64
    sub $a3, $a3, 16384
    li $t2, 0
    jal insertion_loop
    add $a3, $a3, 16384
    li $t2, 0
    jal insertion_loop
    add $a3, $a3, 16384
    li $t2, 0
    jal insertion_loop
    j jump_back
        
store_coord_Tetro_three_state_two:
    lw $a3, Tetro_address
    li $t2, 0
    jal insertion_loop
    add $a3, $a3, 64
    li $t2, 0
    jal insertion_loop
    add $a3, $a3, 16384
    li $t2, 0
    jal insertion_loop
    sub $a3, $a3, 16384
    add $a3, $a3, 64
    li $t2, 0
    jal insertion_loop
    j jump_back
    
store_coord_Tetro_three_state_one:        
    lw $a3, Tetro_address
    li $t2, 0
    jal insertion_loop
    add $a3, $a3, 16384
    li $t2, 0
    jal insertion_loop
    add $a3, $a3, 64
    li $t2, 0
    jal insertion_loop
    sub $a3, $a3, 64
    add $a3, $a3, 16384
    li $t2, 0
    jal insertion_loop
    j jump_back
    
store_coord_Tetro_three_state_zero:
    lw $a3, Tetro_address
    li $t2, 0
    jal insertion_loop
    sub $a3, $a3, 64
    add $a3, $a3, 16384
    li $t2, 0
    jal insertion_loop
    add $a3, $a3, 64        
    li $t2, 0
    jal insertion_loop
    add $a3, $a3, 64
    jal insertion_loop
    j jump_back
    
store_coord_Tetro_two_state_one:
    lw $a3, Tetro_address
    li $t2, 0
    jal insertion_loop                
    add $a3, $a3, 64 
    li $t2, 0
    jal insertion_loop
    add $a3, $a3, 64
    li $t2, 0
    jal insertion_loop
    add $a3, $a3, 64
    li $t2, 0
    jal insertion_loop
    j jump_back
    
store_coord_Tetro_two_state_zero:
    lw $a3, Tetro_address
    li $t2, 0
    jal insertion_loop
    add $a3, $a3, 16384
    li $t2, 0
    jal insertion_loop
    add $a3, $a3, 16384
    li $t2, 0
    jal insertion_loop
    add $a3, $a3, 16384
    li $t2, 0
    jal insertion_loop
    j jump_back
            
store_coord_Tetro_one_state_three:
    lw $a3, Tetro_address
    li $t2, 0
    jal insertion_loop
    add $a3, $a3, 16384
    sub $a3, $a3, 128
    li $t2, 0
    jal insertion_loop
    add $a3, $a3, 64
    li $t2, 0
    jal insertion_loop
    add $a3, $a3, 64
    jal insertion_loop
    j jump_back
         
store_coord_Tetro_one_state_two:
    lw $a3, Tetro_address
    li $t2, 0
    jal insertion_loop
    li $t2, 0
    add $a3, $a3, 64
    jal insertion_loop
    li $t2, 0
    add $a3, $a3, 16384
    jal insertion_loop
    li $t2, 0
    add $a3, $a3, 16384
    jal insertion_loop
    j jump_back
                    
store_coord_Tetro_one_state_one:
    lw $a3, Tetro_address
    li $t2, 0
    jal insertion_loop
    li $t2, 0
    add $a3, $a3, 64
    jal insertion_loop
    li $t2, 0
    add $a3, $a3, 64
    jal insertion_loop
    li $t2, 0
    add $a3, $a3, -128
    add $a3, $a3, 16384
    jal insertion_loop
    j jump_back
        
store_coord_Tetro_one_state_zero:
    lw $a3, Tetro_address
    li $t2, 0
    jal insertion_loop
    li $t2, 0
    add $a3, $a3, 16384
    jal insertion_loop
    li $t2, 0
    add $a3, $a3, 16384
    jal insertion_loop
    li $t2, 0
    add $a3, $a3, 64
    jal insertion_loop
    j jump_back
                          
jump_back:
    j main_four        

load_right_array:
    sw $ra, array_ra_storage
    li $t2, 0
    li $t1, 31
    li $t3, 0x10008000
    addi $s0, $t3, 932
load_right_loop:
    sw $s0, right_array($t2)
    addi $s0, $s0, 16384       
    add $t2, $t2, 4        
    sub $t1, $t1, 1        
    bnez $t1, load_right_loop         
    lw $ra, array_ra_storage
    jr $ra
    
load_left_array:
    sw $ra, array_ra_storage
    li $t2, 0
    li $t1, 31
    li $t3, 0x10008000
    addi $s0, $t3, 100
load_left_loop:
    sw $s0, left_array($t2)
    addi $s0, $s0, 16384       
    add $t2, $t2, 4        
    sub $t1, $t1, 1        
    bnez $t1, load_left_loop         
    lw $ra, array_ra_storage
    jr $ra                
                                                                        
load_bottom_array:
    sw $ra, array_ra_storage
    li $t2, 0
    li $t1, 13
    li $t3, 0x10008000
    addi $s0, $t3, 491620
load_bottom_loop:
    sw $s0, bottom_array($t2)
    addi $s0, $s0, 64       
    add $t2, $t2, 4        
    sub $t1, $t1, 1        
    bnez $t1, load_bottom_loop         
    lw $ra, array_ra_storage
    jr $ra

rotate_Tetro:
    sw $ra, rotate_storage
    lw $t0, Tetro
    beq $t0, 1, rotate_Tetro_one
    beq $t0, 2, rotate_Tetro_two
    beq $t0, 3, rotate_Tetro_three
    beq $t0, 4, rotate_Tetro_four
    beq $t0, 5, rotate_Tetro_five
    beq $t0, 6, rotate_Tetro_six
    beq $t0, 7, game_loop
    lw $ra, rotate_storage
    jr $ra

rotate_Tetro_six:
    sw $ra, ra_storage_2
    lw $t0, Tetro_current_state
    beq, $t0, 0, rotate_Tetro_six_state_one_helper
    beq, $t0, 1, rotate_Tetro_six_state_zero_helper
rotate_Tetro_six_state_one_helper:
    jal remove_Tetro_six_state_zero
    jal new_position_six_one
    jal Tetro_six_state_one
    li $t0, 1
    sw $t0, Tetro_current_state
    lw $ra, ra_storage_2
    jr $ra
rotate_Tetro_six_state_zero_helper:
    jal remove_Tetro_six_state_one
    jal new_position_six_zero
    jal Tetro_six_state_zero
    li $t0, 0
    sw $t0, Tetro_current_state
    lw $ra, ra_storage_2
    jr $ra    
                
rotate_Tetro_five:
    sw $ra, ra_storage_2
    lw $t0, Tetro_current_state
    beq, $t0, 0, rotate_Tetro_five_state_one_helper
    beq, $t0, 1, rotate_Tetro_five_state_two_helper
rotate_Tetro_five_state_one_helper:
    jal remove_Tetro_five_state_zero
    jal new_position_five_one
    jal Tetro_five_state_one
    li $t0, 1
    sw $t0, Tetro_current_state
    lw $ra, ra_storage_2
    jr $ra
rotate_Tetro_five_state_two_helper:
    jal remove_Tetro_five_state_one
    jal new_position_five_zero
    jal Tetro_five_state_zero
    li $t0, 0
    sw $t0, Tetro_current_state
    lw $ra, ra_storage_2
    jr $ra
              
rotate_Tetro_four:
    sw $ra, ra_storage_2
    lw $t0, Tetro_current_state
    beq, $t0, 0, rotate_Tetro_four_state_one_helper
    beq, $t0, 1, rotate_Tetro_four_state_two_helper
    beq, $t0, 2, rotate_Tetro_four_state_three_helper
    beq, $t0, 3, rotate_Tetro_four_state_zero_helper
rotate_Tetro_four_state_one_helper:
    jal remove_Tetro_four_state_zero
    jal new_position_four_one
    jal Tetro_four_state_one
    li $t0, 1
    sw $t0, Tetro_current_state
    lw $ra, ra_storage_2
    jr $ra
rotate_Tetro_four_state_two_helper:
    jal remove_Tetro_four_state_one
    jal new_position_four_two
    jal Tetro_four_state_two
    li $t0, 2
    sw $t0, Tetro_current_state
    lw $ra, ra_storage_2
    jr $ra
rotate_Tetro_four_state_three_helper:
    jal remove_Tetro_four_state_two
    jal new_position_four_three
    jal Tetro_four_state_three
    li $t0, 3
    sw $t0, Tetro_current_state
    lw $ra, ra_storage_2
    jr $ra
rotate_Tetro_four_state_zero_helper:
    jal remove_Tetro_four_state_three                
    jal new_position_four_zero
    jal Tetro_four_state_zero
    li $t0, 0
    sw $t0, Tetro_current_state
    lw $ra, ra_storage_2
    jr $ra
    
rotate_Tetro_three:
    sw $ra, ra_storage_2
    lw $t0, Tetro_current_state
    beq, $t0, 0, rotate_Tetro_three_state_one_helper
    beq, $t0, 1, rotate_Tetro_three_state_two_helper
    beq, $t0, 2, rotate_Tetro_three_state_three_helper
    beq, $t0, 3, rotate_Tetro_three_state_zero_helper
rotate_Tetro_three_state_one_helper:
    jal remove_Tetro_three_state_zero
    jal new_position_three_one
    jal Tetro_three_state_one
    li $t0, 1
    sw $t0, Tetro_current_state
    lw $ra, ra_storage_2
    jr $ra
rotate_Tetro_three_state_two_helper:
    jal remove_Tetro_three_state_one
    jal new_position_three_two
    jal Tetro_three_state_two
    li $t0, 2
    sw $t0, Tetro_current_state
    lw $ra, ra_storage_2
    jr $ra
rotate_Tetro_three_state_three_helper:        
    jal remove_Tetro_three_state_two
    jal new_position_three_three
    jal Tetro_three_state_three
    li $t0, 3
    sw $t0, Tetro_current_state
    lw $ra, ra_storage_2
    jr $ra
rotate_Tetro_three_state_zero_helper:
    jal remove_Tetro_three_state_three
    jal new_position_three_zero
    jal Tetro_three_state_zero
    li $t0, 0
    sw $t0, Tetro_current_state
    lw $ra, ra_storage_2
    jr $ra    
            
rotate_Tetro_two:
    sw $ra, ra_storage_2
    lw $t0, Tetro_current_state
    beq, $t0, 0, rotate_Tetro_two_state_one_helper
    beq, $t0, 1, rotate_Tetro_two_state_zero_helper
rotate_Tetro_two_state_one_helper:
    jal remove_Tetro_two_state_zero
    jal new_position_two_one
    jal Tetro_two_state_one
    li $t0, 1
    sw $t0, Tetro_current_state
    lw $ra, ra_storage_2
    jr $ra
rotate_Tetro_two_state_zero_helper:    
    jal remove_Tetro_two_state_one
    jal new_position_two_zero
    jal Tetro_two_state_zero
    li $t0, 0
    sw $t0, Tetro_current_state
    lw $ra, ra_storage_2
    jr $ra
                        
rotate_Tetro_one:
    sw $ra, ra_storage_2
    lw $t0, Tetro_current_state
    beq, $t0, 0, rotate_Tetro_one_state_one_helper
    beq, $t0, 1, rotate_Tetro_one_state_two_helper
    beq, $t0, 2, rotate_Tetro_one_state_three_helper
    beq, $t0, 3, rotate_Tetro_one_state_zero_helper    
rotate_Tetro_one_state_one_helper:
    jal remove_Tetro_one
    jal Tetro_one_state_one_get_new_position    
    jal Tetro_one_state_one
    li $t0, 1
    sw $t0, Tetro_current_state  # Set state here
    lw $ra, ra_storage_2
    jr $ra
rotate_Tetro_one_state_two_helper:
    jal remove_Tetro_one_state_one
    jal Tetro_one_state_two_get_new_position    
    jal Tetro_one_state_two
    li $t0, 2
    sw $t0, Tetro_current_state  # Set state here
    lw $ra, ra_storage_2
    jr $ra
rotate_Tetro_one_state_three_helper:
    jal remove_Tetro_one_state_two
    jal Tetro_one_state_three_get_new_position
    jal Tetro_one_state_three        
    li $t0, 3
    sw $t0, Tetro_current_state
    lw $ra, ra_storage_2
    jr $ra
rotate_Tetro_one_state_zero_helper:
    jal remove_Tetro_one_state_three
    jal Tetro_one_state_zero_get_new_position
    jal Tetro_one
    li $t0, 0
    sw $t0, Tetro_current_state
    lw $ra, ra_storage_2
    jr $ra

                                    
draw_square:
    move $a2, $a3
    li $t2, 16
vertical_loop_square:    	
    li $t1, 16
horizontal_loop_square:
    sw $t0, 0($a2)
    add $a2, $a2, 4
    add $t1, $t1, -1
    bnez $t1, horizontal_loop_square
    
    add $a2, $a2, -64
    add $a2, $a2, 1024
    add $t2, $t2, -1
    bnez $t2, vertical_loop_square
    jr $ra
    
draw_big_square:
    move $a2, $a3
    li $t2, 160
vertical_loop_big_square:    	
    li $t1, 256
horizontal_loop_big_square:
    sw $t0, 0($a2)
    add $a2, $a2, 4
    add $t1, $t1, -1
    bnez $t1, horizontal_loop_big_square
   
    add $t2, $t2, -1
    bnez $t2, vertical_loop_big_square
    jr $ra
       
Tetro_seven:
    sw $ra, ra_storage
    li $s0, 7
    sw $s0, Tetro
    lw $a3, Tetro_address
    li $t0, 0xD5DE23
    jal draw_square
    add $a3, $a3, 64
    jal draw_square
    add $a3, $a3, 16384
    jal draw_square
    sub $a3, $a3, 64
    jal draw_square
    lw $ra, ra_storage
    jr $ra
    
remove_Tetro_seven:    
    sw $ra, counter
    lw $a1, Tetro_address
    jal remove_grid
    add $a1, $a1, 64
    jal remove_grid
    add $a1, $a1, 16384
    jal remove_grid
    sub $a1, $a1, 64
    jal remove_grid
    lw $ra, counter
    jr $ra
    
move_right_Tetro_seven:
    sw $ra, ra_storage_2
can_move_right_Tetro_seven:
   lw $a3, Tetro_address
   add $s0, $a3, 128
   add $s1, $s0, 16384
   li $t9, 351
   li $t8, 0
can_move_right_seven_Tetro:
   lw $t7, taken_memory($t8)
   beq $t7, $s0, game_loop 
   beq $t7, $s1, game_loop
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_right_seven_Tetro
   li $t9, 31
   li $t8, 0
can_move_right_seven_right:
   lw $t7, right_array($t8)
   beq $t7, $s0, game_loop
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_right_seven_right
   lw $a3, Tetro_address
   jal remove_Tetro_seven
   add $a3, $a3, 64
   sw $a3, Tetro_address
   jal Tetro_seven       
   lw $ra, ra_storage_2
   jr $ra
       
move_left_Tetro_seven:
    sw $ra, ra_storage_2
can_move_left_Tetro_seven:
   lw $a3, Tetro_address
   sub $s0, $a3, 64
   add $s1, $s0, 16384
   li $t9, 351
   li $t8, 0
can_move_left_seven_Tetro:
   lw $t7, taken_memory($t8)
   beq $t7, $s0, game_loop 
   beq $t7, $s1, game_loop
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_left_seven_Tetro
   li $t9, 31
   li $t8, 0
can_move_left_seven_left:
   lw $t7, left_array($t8)
   beq $t7, $a3, game_loop
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_left_seven_left
   lw $a3, Tetro_address
   jal remove_Tetro_seven
   sub $a3, $a3, 64
   sw $a3, Tetro_address
   jal Tetro_seven       
   lw $ra, ra_storage_2
   jr $ra
        
move_down_Tetro_seven:
    sw $ra, ra_storage_2
can_move_down_Tetro_seven:
   lw $a3, Tetro_address
   add $a3, $a3, 16384
   add $s0, $a3, 16384
   add $s1, $s0, 64
   li $t9, 351
   li $t8, 0
can_move_down_seven_Tetro:
   lw $t7, taken_memory($t8)
   beq $t7, $s0, store_coord_Tetro_seven
   beq $t7, $s1, store_coord_Tetro_seven
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_down_seven_Tetro
   li $t9, 13
   li $t8, 0
can_move_down_seven_bottom:
   lw $t7, bottom_array($t8)
   beq $t7, $a3, store_coord_Tetro_seven
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_down_seven_bottom
   lw $a3, Tetro_address
   jal remove_Tetro_seven
   add $a3, $a3, 16384
   sw $a3, Tetro_address
   jal Tetro_seven       
   lw $ra, ra_storage_2
   jr $ra
           
new_position_six_one:
    sw $ra, counter
    lw $a3, Tetro_address
    add $s0, $a3, 64
    add $s0, $s0, 16384
    li $t9, 13
    li $t8, 0
bottom_six_one:
    lw $t7, bottom_array($t8)
    beq $t7, $s0, sub_six_one
    add $t8, $t8, 4
    sub $t9, $t9, 1
    bnez $t9, bottom_six_one
    j final_six_one
sub_six_one:
    sub $a3, $a3, 16384
    j final_six_one
final_six_one:
    add $a3, $a3, 64
    sw $a3, Tetro_address            
    lw $ra, counter
    jr $ra
        
Tetro_six_state_one:
    sw $ra, ra_storage
    li $s0, 1
    sw $s0, Tetro_current_state
    li $s0, 6
    sw $s0, Tetro
    lw $a3, Tetro_address
    li $t0, 0x1B9E9A
    jal draw_square
    add $a3, $a3, 16384
    jal draw_square
    sub $a3, $a3, 64
    jal draw_square
    add $a3, $a3, 16384
    jal draw_square
    lw $ra, ra_storage
    jr $ra

remove_Tetro_six_state_one:
   sw $ra, counter
   lw $a1, Tetro_address
   jal remove_grid
   add $a1, $a1, 16384
   jal remove_grid
   sub $a1, $a1, 64
   jal remove_grid
   add $a1, $a1, 16384
   jal remove_grid
   lw $ra, counter
   jr $ra

move_right_Tetro_six_state_one:
   sw $ra, ra_storage_2
can_move_right_Tetro_six_state_one:
   lw $a3, Tetro_address
   add $s0, $a3, 64
   add $s1, $s0, 16384
   sub $s2, $s1, 64
   add $s2, $s2, 16384
   li $t9, 351
   li $t8, 0
can_move_right_six_one_Tetro:
   lw $t7, taken_memory($t8)
   beq $t7, $s0, game_loop 
   beq $t7, $s1, game_loop
   beq $t7, $s2, game_loop
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_right_six_one_Tetro
   li $t9, 31
   li $t8, 0
can_move_right_six_one_right:
   lw $t7, right_array($t8)
   beq $t7, $s0, game_loop
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_right_six_one_right
   lw $a3, Tetro_address
   jal remove_Tetro_six_state_one
   add $a3, $a3, 64
   sw $a3, Tetro_address
   jal Tetro_six_state_one       
   lw $ra, ra_storage_2
   jr $ra
            
move_left_Tetro_six_state_one:
   sw $ra, ra_storage_2
can_move_left_Tetro_six_state_one:
   lw $a3, Tetro_address
   sub $s0, $a3, 64
   add $a3, $a3, 16384
   sub $a3, $a3, 64
   sub $s1, $a3, 64
   add $s2, $s1, 16384
   li $t9, 351
   li $t8, 0
can_move_left_six_one_Tetro:
   lw $t7, taken_memory($t8)
   beq $t7, $s0, game_loop 
   beq $t7, $s1, game_loop
   beq $t7, $s2, game_loop
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_left_six_one_Tetro
   li $t9, 31
   li $t8, 0
can_move_left_six_one_left:
   lw $t7, left_array($t8)
   beq $t7, $a3, game_loop
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_left_six_one_left
   lw $a3, Tetro_address
   jal remove_Tetro_six_state_one
   sub $a3, $a3, 64
   sw $a3, Tetro_address
   jal Tetro_six_state_one       
   lw $ra, ra_storage_2
   jr $ra
       
move_down_Tetro_six_state_one:
    sw $ra, ra_storage_2
can_move_down_Tetro_six_state_one:
   lw $a3, Tetro_address
   add $a3, $a3, 16384
   add $s0, $a3, 16384
   sub $a3, $a3, 64
   add $a3, $a3, 16384
   add $s1, $a3, 16384
   li $t9, 351
   li $t8, 0
can_move_down_six_one_Tetro:
   lw $t7, taken_memory($t8)
   beq $t7, $s0, store_coord_Tetro_six_state_one
   beq $t7, $s1, store_coord_Tetro_six_state_one
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_down_six_one_Tetro
   li $t9, 13
   li $t8, 0
can_move_down_six_one_bottom:
   lw $t7, bottom_array($t8)
   beq $t7, $a3, store_coord_Tetro_six_state_one
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_down_six_one_bottom
   lw $a3, Tetro_address
   jal remove_Tetro_six_state_one
   add $a3, $a3, 16384
   sw $a3, Tetro_address
   jal Tetro_six_state_one       
   lw $ra, ra_storage_2
   jr $ra
   
new_position_six_zero:
    sw $ra, counter
    lw $a3, Tetro_address
    add $s0, $a3, 64
    li $t9, 31
    li $t8, 0
right_six_zero:
    lw $t7, right_array($t8)
    beq $s0, $t7, sub_six_zero
    add $t8, $t8, 4
    sub $t9, $t9, 1
    bnez $t9, right_six_zero
    j final_six_zero 
sub_six_zero:
    sub $a3, $a3 64
    j final_six_zero
final_six_zero:
    sub $a3, $a3, 64 
    sw $a3, Tetro_address           
    sw $ra, counter
    jr $ra            
Tetro_six_state_zero:
    sw $ra, ra_storage
    li $s0, 0
    sw $s0, Tetro_current_state
    li $s0, 6
    sw $s0, Tetro
    lw $a3, Tetro_address
    li $t0, 0x1B9E9A
    jal draw_square
    add $a3, $a3, 64
    jal draw_square
    add $a3, $a3, 16384
    jal draw_square
    add $a3, $a3, 64
    jal draw_square
    lw $ra, ra_storage
    jr $ra
     
remove_Tetro_six_state_zero:
    sw $ra, counter
    lw $a1, Tetro_address
    jal remove_grid
    add $a1, $a1, 64
    jal remove_grid
    add $a1, $a1, 16384
    jal remove_grid
    add $a1, $a1, 64
    jal remove_grid
    lw $ra, counter
    jr $ra
move_right_Tetro_six_state_zero:
    sw $ra, ra_storage_2
can_move_right_Tetro_six_state_zero:
   lw $a3, Tetro_address
   add $s0, $a3, 128
   add $s1, $s0, 16384
   add $s1, $s1, 64
   li $t9, 351
   li $t8, 0
can_move_right_six_zero_Tetro:
   lw $t7, taken_memory($t8)
   beq $t7, $s0, game_loop 
   beq $t7, $s1, game_loop
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_right_six_zero_Tetro
   li $t9, 31
   li $t8, 0
can_move_right_six_zero_right:
   lw $t7, right_array($t8)
   beq $t7, $s1, game_loop
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_right_six_zero_right
   lw $a3, Tetro_address
   jal remove_Tetro_six_state_zero
   add $a3, $a3, 64
   sw $a3, Tetro_address
   jal Tetro_six_state_zero       
   lw $ra, ra_storage_2
   jr $ra
       
move_left_Tetro_six_state_zero:
    sw $ra, ra_storage_2
can_move_left_Tetro_six_state_zero:
   lw $a3, Tetro_address
   sub $s0, $a3, 64
   add $s1, $a3, 16384
   li $t9, 351
   li $t8, 0
can_move_left_six_zero_Tetro:
   lw $t7, taken_memory($t8)
   beq $t7, $s0, game_loop 
   beq $t7, $s1, game_loop
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_left_six_zero_Tetro
   li $t9, 31
   li $t8, 0
can_move_left_six_zero_left:
   lw $t7, left_array($t8)
   beq $t7, $a3, game_loop
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_left_six_zero_left
   lw $a3, Tetro_address
   jal remove_Tetro_six_state_zero
   sub $a3, $a3, 64
   sw $a3, Tetro_address
   jal Tetro_six_state_zero       
   lw $ra, ra_storage_2
   jr $ra
       
move_down_Tetro_six_state_zero:    
    sw $ra, ra_storage_2
can_move_down_Tetro_six_state_zero:
   lw $a3, Tetro_address
   add $s0, $a3, 16384
   add $a3, $a3, 64
   add $a3, $a3, 16384
   add $s1, $a3, 16384
   add $s2, $s1, 64
   li $t9, 351
   li $t8, 0
can_move_down_six_zero_Tetro:
   lw $t7, taken_memory($t8)
   beq $t7, $s0, store_coord_Tetro_six_state_zero
   beq $t7, $s1, store_coord_Tetro_six_state_zero
   beq $t7, $s2, store_coord_Tetro_six_state_zero
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_down_six_zero_Tetro
   li $t9, 13
   li $t8, 0
can_move_down_six_zero_bottom:
   lw $t7, bottom_array($t8)
   beq $t7, $a3, store_coord_Tetro_six_state_zero
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_down_six_zero_bottom
   lw $a3, Tetro_address
   jal remove_Tetro_six_state_zero
   add $a3, $a3, 16384
   sw $a3, Tetro_address
   jal Tetro_six_state_zero       
   lw $ra, ra_storage_2
   jr $ra    

                                
new_position_five_one:
    sw $ra, counter
    lw $a3, Tetro_address
    add $s0, $a3, 16384
    li $t9, 13
    li $t8, 0
bottom_five_one:
    lw $t7, bottom_array($t8)
    beq $t7, $s0, sub_five_one
    add $t8, $t8, 4
    sub $t9, $t9, 1
    bnez $t9, bottom_five_one
    j final_five_one
sub_five_one:
    sub $a3, $a3, 16384
    j final_five_one
final_five_one:
    sw $a3, Tetro_address            
    lw $ra, counter
    jr $ra
        
Tetro_five_state_one:
    sw $ra, ra_storage
    li $s0, 1
    sw $s0, Tetro_current_state
    li $s0, 5
    sw $s0, Tetro
    lw $a3, Tetro_address
    li $t0, 0x0F8A30
    jal draw_square
    add $a3, $a3, 16384
    jal draw_square
    add $a3, $a3, 64
    jal draw_square
    add $a3, $a3, 16384
    jal draw_square
    lw $ra, ra_storage
    jr $ra
    
remove_Tetro_five_state_one:
    sw $ra, counter
    lw $a1, Tetro_address
    jal remove_grid
    add $a1, $a1, 16384
    jal remove_grid
    add $a1, $a1, 64
    jal remove_grid
    add $a1, $a1, 16384
    jal remove_grid
    lw $ra, counter
    jr $ra
    
move_right_Tetro_five_state_one:
    sw $ra, ra_storage_2
can_move_right_Tetro_five_state_one:
   lw $a3, Tetro_address
   add $s0, $a3, 64
   add $s1, $s0, 16384
   add $s1, $s1, 64
   add $s2, $s1, 16384
   li $t9, 351
   li $t8, 0
can_move_right_five_one_Tetro:
   lw $t7, taken_memory($t8)
   beq $t7, $s0, game_loop 
   beq $t7, $s1, game_loop
   beq $t7, $s2, game_loop
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_right_five_one_Tetro
   li $t9, 31
   li $t8, 0
can_move_right_five_one_right:
   lw $t7, right_array($t8)
   beq $t7, $s1, game_loop
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_right_five_one_right
   lw $a3, Tetro_address
   jal remove_Tetro_five_state_one
   add $a3, $a3, 64
   sw $a3, Tetro_address
   jal Tetro_five_state_one       
   lw $ra, ra_storage_2
   jr $ra
   
move_left_Tetro_five_state_one:
    sw $ra, ra_storage_2
can_move_left_Tetro_five_state_one:
   lw $a3, Tetro_address
   sub $s0, $a3, 64
   add $s1, $s0, 16384
   add $s2, $a3, 16384
   add $s2, $a3, 16384
   li $t9, 351
   li $t8, 0
can_move_left_five_one_Tetro:
   lw $t7, taken_memory($t8)
   beq $t7, $s0, game_loop 
   beq $t7, $s1, game_loop
   beq $t7, $s2, game_loop
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_left_five_one_Tetro
   li $t9, 31
   li $t8, 0
can_move_left_five_one_left:
   lw $t7, left_array($t8)
   beq $t7, $a3, game_loop
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_left_five_one_left
   lw $a3, Tetro_address
   jal remove_Tetro_five_state_one
   sub $a3, $a3, 64
   sw $a3, Tetro_address
   jal Tetro_five_state_one       
   lw $ra, ra_storage_2
   jr $ra    
            
move_down_Tetro_five_state_one:    
    sw $ra, ra_storage_2
can_move_down_Tetro_five_state_one:
   lw $a3, Tetro_address
   add $a3, $a3, 16384
   add $s0, $a3, 16384
   add $a3, $a3, 64
   add $a3, $a3, 16384
   add $s1, $a3, 16384
   li $t9, 351
   li $t8, 0
can_move_down_five_one_Tetro:
   lw $t7, taken_memory($t8)
   beq $t7, $s0, store_coord_Tetro_five_state_one
   beq $t7, $s1, store_coord_Tetro_five_state_one
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_down_five_one_Tetro
   li $t9, 13
   li $t8, 0
can_move_down_five_one_bottom:
   lw $t7, bottom_array($t8)
   beq $t7, $a3, store_coord_Tetro_five_state_one
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_down_five_one_bottom
   lw $a3, Tetro_address
   jal remove_Tetro_five_state_one
   add $a3, $a3, 16384
   sw $a3, Tetro_address
   jal Tetro_five_state_one       
   lw $ra, ra_storage_2
   jr $ra
       
new_position_five_zero:
    sw $ra, counter
    lw $a3, Tetro_address
    li $t9, 31
    li $t8, 0
left_five_zero:
    lw $t7, left_array($t8)
    beq $a3, $t7, add_five_zero
    add $t8, $t8, 4
    sub $t9, $t9, 1
    bnez $t9, left_five_zero
    j final_five_zero
add_five_zero:
    add $a3, $a3, 64
    j final_five_zero
final_five_zero:
    sw $a3, Tetro_address         
    lw $ra, counter
    jr $ra        
Tetro_five_state_zero:
    sw $ra, ra_storage
    li $s0, 0
    sw $s0, Tetro_current_state
    li $s0, 5
    sw $s0, Tetro
    lw $a3, Tetro_address
    li $t0, 0x0F8A30
    jal draw_square
    add $a3, $a3, 64
    jal draw_square
    sub $a3, $a3, 128
    add $a3, $a3, 16384
    jal draw_square
    add $a3, $a3, 64
    jal draw_square
    lw $ra, ra_storage
    jr $ra
    
remove_Tetro_five_state_zero:
    sw $ra, counter
    lw $a1, Tetro_address
    jal remove_grid
    add $a1, $a1, 64
    jal remove_grid
    sub $a1, $a1, 128
    add $a1, $a1, 16384
    jal remove_grid
    add $a1, $a1, 64
    jal remove_grid
    lw $ra, counter
    jr $ra

move_right_Tetro_five_state_zero:
    sw $ra, ra_storage_2
can_move_right_Tetro_five_state_zero:
   lw $a3, Tetro_address
   add $s0, $a3, 16384
   add $s0, $s0, 64
   add $s1, $a3, 128
   li $t9, 351
   li $t8, 0
can_move_right_five_zero_Tetro:
   lw $t7, taken_memory($t8)
   beq $t7, $s0, game_loop 
   beq $t7, $s1, game_loop
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_right_five_zero_Tetro
   li $t9, 31
   li $t8, 0
can_move_right_five_zero_right:
   lw $t7, right_array($t8)
   beq $t7, $s1, game_loop
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_right_five_zero_right
   lw $a3, Tetro_address
   jal remove_Tetro_five_state_zero
   add $a3, $a3, 64
   sw $a3, Tetro_address
   jal Tetro_five_state_zero       
   lw $ra, ra_storage_2
   jr $ra
   
move_left_Tetro_five_state_zero:
    sw $ra, ra_storage_2
can_move_left_Tetro_five_state_zero:
   lw $a3, Tetro_address
   sub $s0, $a3, 64
   add $a3, $a3, 16384
   sub $a3, $a3, 64
   sub $s1, $a3, 64
   li $t9, 351
   li $t8, 0
can_move_left_five_zero_Tetro:
   lw $t7, taken_memory($t8)
   beq $t7, $s0, game_loop 
   beq $t7, $s1, game_loop
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_left_five_zero_Tetro
   li $t9, 31
   li $t8, 0
can_move_left_five_zero_left:
   lw $t7, left_array($t8)
   beq $t7, $a3, game_loop
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_left_five_zero_left
   lw $a3, Tetro_address
   jal remove_Tetro_five_state_zero
   sub $a3, $a3, 64
   sw $a3, Tetro_address
   jal Tetro_five_state_zero       
   lw $ra, ra_storage_2
   jr $ra
           
move_down_Tetro_five_state_zero:    
    sw $ra, ra_storage_2
can_move_down_Tetro_five_state_zero:
   lw $a3, Tetro_address
   add $a3, $a3, 16384
   add $s0, $a3, 64
   add $s1, $a3, 16384
   sub $s2, $s1, 64
   li $t9, 351
   li $t8, 0
can_move_down_five_zero_Tetro:
   lw $t7, taken_memory($t8)
   beq $t7, $s0, store_coord_Tetro_five_state_zero
   beq $t7, $s1, store_coord_Tetro_five_state_zero
   beq $t7, $s2, store_coord_Tetro_five_state_zero
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_down_five_zero_Tetro
   li $t9, 13
   li $t8, 0
can_move_down_five_zero_bottom:
   lw $t7, bottom_array($t8)
   beq $t7, $a3, store_coord_Tetro_five_state_zero
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_down_five_zero_bottom
   lw $a3, Tetro_address
   jal remove_Tetro_five_state_zero
   add $a3, $a3, 16384
   sw $a3, Tetro_address
   jal Tetro_five_state_zero       
   lw $ra, ra_storage_2
   jr $ra
               
                
new_position_four_three:
    sw $ra, counter
    lw $a3, Tetro_address
    li $t9, 31
    li $t8, 0
left_four_three:
    lw $t7, left_array($t8)
    beq $t7, $a3, add_four_three
    add $t8, $t8, 4
    sub $t9, $t9, 1
    bnez $t9, left_four_three
    j normal_four_three
add_four_three:
    add $a3, $a3, 16384
    j final_four_three
normal_four_three:
    sub $a3, $a3, 64
    add $a3, $a3, 16384
    j final_four_three    
final_four_three:
    sw $a3, Tetro_address                
    lw $ra, counter
    jr $ra
    
Tetro_four_state_three:
    sw $ra, ra_storage
    li $s0, 3
    sw $s0, Tetro_current_state
    li $s0, 4
    sw $s0, Tetro
    lw $a3, Tetro_address
    li $t0, 0xAB6527
    jal draw_square
    add $a3, $a3, 64
    jal draw_square
    add $a3, $a3, 64
    jal draw_square
    add $a3, $a3, 16384
    jal draw_square
    lw $ra, ra_storage
    jr $ra
    
remove_Tetro_four_state_three:
    sw $ra, counter
    lw $a1, Tetro_address
    jal remove_grid
    add $a1, $a1, 64
    jal remove_grid
    add $a1, $a1, 64
    jal remove_grid
    add $a1, $a1, 16384
    jal remove_grid
    lw $ra, counter
    jr $ra

move_right_Tetro_four_state_three:
   sw $ra, ra_storage_2
can_move_right_Tetro_four_state_three:
   lw $a3, Tetro_address
   add $s0, $a3, 192
   add $s1, $s0, 16384
   li $t9, 351
   li $t8, 0
can_move_right_four_three_Tetro:
   lw $t7, taken_memory($t8)
   beq $t7, $s0, game_loop 
   beq $t7, $s1, game_loop
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_right_four_three_Tetro
   li $t9, 31
   li $t8, 0
can_move_right_four_three_right:
   lw $t7, right_array($t8)
   beq $t7, $s0, game_loop
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_right_four_three_right
   lw $a3, Tetro_address
   jal remove_Tetro_four_state_three
   add $a3, $a3, 64
   sw $a3, Tetro_address
   jal Tetro_four_state_three       
   lw $ra, ra_storage_2
   jr $ra

move_left_Tetro_four_state_three:
   sw $ra, ra_storage_2
can_move_left_Tetro_four_state_three:
   lw $a3, Tetro_address
   sub $s0, $a3, 64
   add $s1, $a3, 16384
   add $s1, $s1, 64
   li $t9, 351
   li $t8, 0
can_move_left_four_three_Tetro:
   lw $t7, taken_memory($t8)
   beq $t7, $s0, game_loop 
   beq $t7, $s1, game_loop
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_left_four_three_Tetro
   li $t9, 31
   li $t8, 0
can_move_left_four_three_left:
   lw $t7, left_array($t8)
   beq $t7, $a3, game_loop
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_left_four_three_left
   lw $a3, Tetro_address
   jal remove_Tetro_four_state_three
   sub $a3, $a3, 64
   sw $a3, Tetro_address
   jal Tetro_four_state_three       
   lw $ra, ra_storage_2
   jr $ra
                            
move_down_Tetro_four_state_three:    
    sw $ra, ra_storage_2
can_move_down_Tetro_four_state_three:
   lw $a3, Tetro_address
   add $s0, $a3, 16384
   add $s1, $a3, 64
   add $a3, $a3, 128
   add $a3, $a3, 16384
   add $s2, $a3, 16384
   li $t9, 351
   li $t8, 0
can_move_down_four_three_Tetro:
   lw $t7, taken_memory($t8)
   beq $t7, $s0, store_coord_Tetro_four_state_three 
   beq $t7, $s1, store_coord_Tetro_four_state_three
   beq $t7, $s2, store_coord_Tetro_four_state_three
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_down_four_three_Tetro
   li $t9, 13
   li $t8, 0
can_move_down_four_three_bottom:
   lw $t7, bottom_array($t8)
   beq $t7, $a3, store_coord_Tetro_four_state_three
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_down_four_three_bottom
   lw $a3, Tetro_address
   jal remove_Tetro_four_state_three
   add $a3, $a3, 16384
   sw $a3, Tetro_address
   jal Tetro_four_state_three       
   lw $ra, ra_storage_2
   jr $ra
               
new_position_four_two:
    sw $ra, counter
    lw $a3, Tetro_address
    add $s0, $a3, 16384
    li $t9, 13
    li $t8, 0
bottom_four_two:
    lw $t7, bottom_array($t8)
    beq $s0, $t7, sub_four_two
    add $t8, $t8, 4
    sub $t9, $t9, 1
    bnez $t9, bottom_four_two
    j final_four_one
sub_four_two:
    sub $a3, $a3, 16384
final_four_two:
    add $a3, $a3, 64
    sw $a3, Tetro_address
    lw $ra, counter
    jr $ra
                
Tetro_four_state_two:
    sw $ra, ra_storage
    li $s0, 2
    sw $s0, Tetro_current_state
    li $s0, 4
    sw $s0, Tetro
    lw $a3, Tetro_address
    li $t0, 0xAB6527
    jal draw_square
    add $a3, $a3, 64
    jal draw_square
    sub $a3, $a3, 64
    add $a3, $a3, 16384
    jal draw_square
    add $a3, $a3, 16384
    jal draw_square
    lw $ra, ra_storage
    jr $ra
    
remove_Tetro_four_state_two:
    sw $ra, counter
    lw $a1, Tetro_address
    jal remove_grid
    add $a1, $a1, 64
    jal remove_grid
    sub $a1, $a1, 64
    add $a1, $a1, 16384
    jal remove_grid
    add $a1, $a1, 16384
    jal remove_grid
    lw $ra, counter
    jr $ra
    
move_right_Tetro_four_state_two:
   sw $ra, ra_storage_2
can_move_right_Tetro_four_state_two:
   lw $a3, Tetro_address
   add $s0, $a3, 128
   add $s1, $s0, 16384
   sub $s1, $s1, 64
   add $s2, $s1, 16384
   li $t9, 351
   li $t8, 0
can_move_right_four_two_Tetro:
   lw $t7, taken_memory($t8)
   beq $t7, $s0, game_loop 
   beq $t7, $s1, game_loop
   beq $t7, $s2, game_loop
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_right_four_two_Tetro
   li $t9, 31
   li $t8, 0
can_move_right_four_two_left:
   lw $t7, right_array($t8)
   beq $t7, $s0, game_loop
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_right_four_two_left
   lw $a3, Tetro_address
   jal remove_Tetro_four_state_two
   add $a3, $a3, 64
   sw $a3, Tetro_address
   jal Tetro_four_state_two       
   lw $ra, ra_storage_2
   jr $ra
   
move_left_Tetro_four_state_two:
   sw $ra, ra_storage_2
can_move_left_Tetro_four_state_two:
   lw $a3, Tetro_address
   sub $s0, $a3, 64
   add $s1, $s0, 16384
   add $s2, $s1, 16384
   li $t9, 351
   li $t8, 0
can_move_left_four_two_Tetro:
   lw $t7, taken_memory($t8)
   beq $t7, $s0, game_loop 
   beq $t7, $s1, game_loop
   beq $t7, $s2, game_loop
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_left_four_two_Tetro
   li $t9, 31
   li $t8, 0
can_move_left_four_two_left:
   lw $t7, left_array($t8)
   beq $t7, $a3, game_loop
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_left_four_two_left
   lw $a3, Tetro_address
   jal remove_Tetro_four_state_two
   sub $a3, $a3, 64
   sw $a3, Tetro_address
   jal Tetro_four_state_two       
   lw $ra, ra_storage_2
   jr $ra
                   
move_down_Tetro_four_state_two:    
    sw $ra, ra_storage_2
can_move_down_Tetro_four_state_two:
   lw $a3, Tetro_address
   add $a3, $a3, 16384
   add $s1, $a3, 64
   add $a3, $a3, 16384
   add $s0, $a3, 16384
   li $t9, 351
   li $t8, 0
can_move_down_four_two_Tetro:
   lw $t7, taken_memory($t8)
   beq $t7, $s0, store_coord_Tetro_four_state_two 
   beq $t7, $s1, store_coord_Tetro_four_state_two
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_down_four_two_Tetro
   li $t9, 13
   li $t8, 0
can_move_down_four_two_bottom:
   lw $t7, bottom_array($t8)
   beq $t7, $a3, store_coord_Tetro_four_state_two
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_down_four_two_bottom
   lw $a3, Tetro_address
   jal remove_Tetro_four_state_two
   add $a3, $a3, 16384
   sw $a3, Tetro_address
   jal Tetro_four_state_two       
   lw $ra, ra_storage_2
   jr $ra 
    
new_position_four_one:
    sw $ra, counter
    lw $a3, Tetro_address
    add $s0, $a3, 64
    li $t9, 31
    li $t8, 0
right_four_one:
    lw $t7, right_array($t8)
    beq $s0, $t7, sub_four_one
    add $t8, $t8, 4
    sub $t9, $t9, 1
    bnez $t9, right_four_one
    j normal_four_one
normal_four_one:
    sub $a3, $a3, 64
    add $a3, $a3, 16384
    j final_four_one    
sub_four_one:
    sub $a3, $a3, 128
    add $a3, $a3, 16384
    j final_four_one
final_four_one:            
    sw $a3, Tetro_address
    lw $ra, counter
    jr $ra
        
Tetro_four_state_one:
    sw $ra, ra_storage
    li $s0, 1
    sw $s0, Tetro_current_state
    li $s0, 4
    sw $s0, Tetro
    lw $a3, Tetro_address
    li $t0, 0xAB6527
    jal draw_square
    add $a3, $a3, 16384
    jal draw_square
    add $a3, $a3, 64
    jal draw_square
    add $a3, $a3, 64
    jal draw_square
    lw $ra, ra_storage
    jr $ra
    
remove_Tetro_four_state_one:
    sw $ra, counter
    lw $a1, Tetro_address
    jal remove_grid
    add $a1, $a1, 16384
    jal remove_grid
    add $a1, $a1, 64
    jal remove_grid
    add $a1, $a1, 64
    jal remove_grid
    lw $ra, counter
    jr $ra

move_right_Tetro_four_state_one:
   sw $ra, ra_storage_2
can_move_right_Tetro_four_state_one:
   lw $a3, Tetro_address
   add $s0, $a3, 64
   add $s1, $a3, 16384
   add $s1, $s1, 192
   li $t9, 351
   li $t8, 0
can_move_right_four_one_Tetro:
   lw $t7, taken_memory($t8)
   beq $t7, $s0, game_loop 
   beq $t7, $s1, game_loop
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_right_four_one_Tetro
   li $t9, 31
   li $t8, 0
can_move_right_four_one_left:
   lw $t7, right_array($t8)
   beq $t7, $s1, game_loop
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_right_four_one_left
   lw $a3, Tetro_address
   jal remove_Tetro_four_state_one
   add $a3, $a3, 64
   sw $a3, Tetro_address
   jal Tetro_four_state_one       
   lw $ra, ra_storage_2
   jr $ra

move_left_Tetro_four_state_one:
   sw $ra, ra_storage_2
can_move_left_Tetro_four_state_one:
   lw $a3, Tetro_address
   sub $s0, $a3, 64
   add $s1, $s0, 16384
   li $t9, 351
   li $t8, 0
can_move_left_four_one_Tetro:
   lw $t7, taken_memory($t8)
   beq $t7, $s0, game_loop 
   beq $t7, $s1, game_loop
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_left_four_one_Tetro
   li $t9, 31
   li $t8, 0
can_move_left_four_one_left:
   lw $t7, left_array($t8)
   beq $t7, $a3, game_loop
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_left_four_one_left
   lw $a3, Tetro_address
   jal remove_Tetro_four_state_one
   sub $a3, $a3, 64
   sw $a3, Tetro_address
   jal Tetro_four_state_one       
   lw $ra, ra_storage_2
   jr $ra
           
move_down_Tetro_four_state_one:    
    sw $ra, ra_storage_2
can_move_down_Tetro_four_state_one:
   lw $a3, Tetro_address
   add $a3, $a3, 16384
   add $s0, $a3, 16384
   add $s1, $s0, 64
   add $s2, $s1, 64
   li $t9, 351
   li $t8, 0
can_move_down_four_one_Tetro:
   lw $t7, taken_memory($t8)
   beq $t7, $s0, store_coord_Tetro_four_state_one 
   beq $t7, $s1, store_coord_Tetro_four_state_one
   beq $t7, $s2, store_coord_Tetro_four_state_one
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_down_four_one_Tetro
   li $t9, 13
   li $t8, 0
can_move_down_four_one_bottom:
   lw $t7, bottom_array($t8)
   beq $t7, $a3, store_coord_Tetro_four_state_one
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_down_four_one_bottom
   lw $a3, Tetro_address
   jal remove_Tetro_four_state_one
   add $a3, $a3, 16384
   sw $a3, Tetro_address
   jal Tetro_four_state_one       
   lw $ra, ra_storage_2
   jr $ra        

new_position_four_zero:
    sw $ra, counter
    lw $a3, Tetro_address
    sub $a3, $a3, 16384
    add $a3, $a3, 64
    sw $a3, Tetro_address
    lw $ra, counter
    jr $ra                        
Tetro_four_state_zero:
    sw $ra, ra_storage
    li $s0, 0
    sw $s0, Tetro_current_state
    li $s0, 4
    sw $s0, Tetro
    lw $a3, Tetro_address
    li $t0, 0xAB6527
    jal draw_square
    add $a3, $a3, 16384
    jal draw_square
    add $a3, $a3, 16384
    jal draw_square
    sub $a3, $a3, 64
    jal draw_square
    lw $ra, ra_storage
    jr $ra

remove_Tetro_four_state_zero:
    sw $ra, counter
    lw $a1, Tetro_address
    jal remove_grid
    add $a1, $a1, 16384
    jal remove_grid
    add $a1, $a1, 16384
    jal remove_grid
    sub $a1, $a1, 64
    jal remove_grid
    lw $ra, counter
    jr $ra

move_right_Tetro_four_state_zero:
   sw $ra, ra_storage_2
can_move_right_Tetro_four_state_zero:
   lw $a3, Tetro_address
   add $s0, $a3, 64
   add $s1, $s0, 16384
   add $s2, $s1, 16384
   li $t9, 351
   li $t8, 0
can_move_right_four_zero_Tetro:
   lw $t7, taken_memory($t8)
   beq $t7, $s0, game_loop 
   beq $t7, $s1, game_loop
   beq $t7, $s2, game_loop
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_right_four_zero_Tetro
   li $t9, 31
   li $t8, 0
can_move_right_four_zero_right:
   lw $t7, right_array($t8)
   beq $t7, $s0, game_loop
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_right_four_zero_right
   
   lw $a3, Tetro_address
   jal remove_Tetro_four_state_zero
   add $a3, $a3, 64
   sw $a3, Tetro_address
   jal Tetro_four_state_zero      
   lw $ra, ra_storage_2
   jr $ra
           
move_left_Tetro_four_state_zero:
   sw $ra, ra_storage_2
can_move_left_Tetro_four_state_zero:
   lw $a3, Tetro_address
   sub $s0, $a3, 64
   add $s1, $s0, 16384
   add $a3, $s1, 16384
   sub $s2, $a3, 64
   li $t9, 351
   li $t8, 0
can_move_left_four_zero_Tetro:
   lw $t7, taken_memory($t8)
   beq $t7, $s0, game_loop 
   beq $t7, $s1, game_loop
   beq $t7, $s2, game_loop
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_left_four_zero_Tetro
   li $t9, 31
   li $t8, 0
can_move_left_four_zero_left:
   lw $t7, left_array($t8)
   beq $t7, $a3, game_loop
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_left_four_zero_left
   lw $a3, Tetro_address
   jal remove_Tetro_four_state_zero
   sub $a3, $a3, 64
   sw $a3, Tetro_address
   jal Tetro_four_state_zero       
   lw $ra, ra_storage_2
   jr $ra
               
move_down_Tetro_four_state_zero:    
    sw $ra, ra_storage_2
can_move_down_Tetro_four_state_zero:
   lw $a3, Tetro_address
   add $a3, $a3, 16384
   add $a3, $a3, 16384
   add $s0, $a3, 16384
   sub $s1, $s0, 64
   li $t9, 351
   li $t8, 0
can_move_down_four_zero_Tetro:
   lw $t7, taken_memory($t8)
   beq $t7, $s0, store_coord_Tetro_four_state_zero 
   beq $t7, $s1, store_coord_Tetro_four_state_zero
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_down_four_zero_Tetro
   li $t9, 13
   li $t8, 0
can_move_down_four_zero_bottom:
   lw $t7, bottom_array($t8)
   beq $t7, $a3, store_coord_Tetro_four_state_zero
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_down_four_zero_bottom
   lw $a3, Tetro_address
   jal remove_Tetro_four_state_zero
   add $a3, $a3, 16384
   sw $a3, Tetro_address
   jal Tetro_four_state_zero       
   lw $ra, ra_storage_2
   jr $ra
    
new_position_three_three:
    sw $ra, counter
    lw $a3, Tetro_address
    sw $a3, Tetro_address
    lw $ra, counter
    jr $ra
      
Tetro_three_state_three:
    sw $ra, ra_storage
    li $s0, 3
    sw $s0, Tetro_current_state
    li $s0, 3
    sw $s0, Tetro
    lw $a3, Tetro_address
    li $t0, 0x2054A8
    jal draw_square
    add $a3, $a3, 64
    sub $a3, $a3, 16384
    jal draw_square
    add $a3, $a3, 16384
    jal draw_square
    add $a3, $a3, 16384
    jal draw_square
    lw $ra, ra_storage
    jr $ra
    
remove_Tetro_three_state_three: 
    sw $ra, counter
    lw $a1, Tetro_address
    jal remove_grid
    add $a1, $a1, 64
    sub $a1, $a1, 16384
    jal remove_grid
    add $a1, $a1, 16384
    jal remove_grid
    add $a1, $a1, 16384
    jal remove_grid
    lw $ra, counter
    jr $ra

move_right_Tetro_three_state_three:
   sw $ra, ra_storage_2
can_move_right_Tetro_three_state_three:
   lw $a3, Tetro_address
   add $s0, $a3, 128
   sub $s1, $s0, 64
   add $s2, $s0, 64
   li $t9, 351
   li $t8, 0
can_move_right_three_three_Tetro:
   lw $t7, taken_memory($t8)
   beq $t7, $s0, game_loop 
   beq $t7, $s1, game_loop
   beq $t7, $s2, game_loop
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_right_three_three_Tetro
   li $t9, 31
   li $t8, 0
can_move_right_three_three_right:
   lw $t7, right_array($t8)
   beq $t7, $s0, game_loop
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_right_three_three_right
   lw $a3, Tetro_address
   jal remove_Tetro_three_state_three
   add $a3, $a3, 64
   sw $a3, Tetro_address
   jal Tetro_three_state_three       
   lw $ra, ra_storage_2
   jr $ra
   
move_left_Tetro_three_state_three:
   sw $ra, ra_storage_2
can_move_left_Tetro_three_state_three:
   lw $a3, Tetro_address
   sub $s0, $a3, 16384
   sub $s1, $a3, 64
   add $s2, $a3, 16384
   li $t9, 351
   li $t8, 0
can_move_left_three_three_Tetro:
   lw $t7, taken_memory($t8)
   beq $t7, $s0, game_loop 
   beq $t7, $s1, game_loop
   beq $t7, $s2, game_loop
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_left_three_three_Tetro
   li $t9, 31
   li $t8, 0
can_move_left_three_three_left:
   lw $t7, left_array($t8)
   beq $t7, $a3, game_loop
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_left_three_three_left
   lw $a3, Tetro_address
   jal remove_Tetro_three_state_three
   sub $a3, $a3, 64
   sw $a3, Tetro_address
   jal Tetro_three_state_three       
   lw $ra, ra_storage_2
   jr $ra        

move_down_Tetro_three_state_three:
   sw $ra, ra_storage_2
can_move_down_Tetro_three_state_three:
   lw $a3, Tetro_address
   add $a3, $a3, 64
   add $a3, $a3, 16384
   sub $s0, $a3, 64
   add $s1, $a3, 16384
   li $t9, 351
   li $t8, 0
can_move_down_three_three_Tetro:
   lw $t7, taken_memory($t8)
   beq $t7, $s0, store_coord_Tetro_three_state_three 
   beq $t7, $s1, store_coord_Tetro_three_state_three
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_down_three_three_Tetro
   li $t9, 13
   li $t8, 0
can_move_down_three_three_bottom:
   lw $t7, bottom_array($t8)
   beq $t7, $a3, store_coord_Tetro_three_state_three 
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_down_three_three_bottom
   lw $a3, Tetro_address
   jal remove_Tetro_three_state_three
   add $a3, $a3, 16384
   sw $a3, Tetro_address
   jal Tetro_three_state_three       
   lw $ra, ra_storage_2
   jr $ra
           
       
new_position_three_two:
   sw $ra, counter
   lw $a3, Tetro_address
   li $t9, 27
   li $t8, 0
left_three_two:
   lw $t7, left_array($t8)
   beq $t7, $a3, not_normal_three_two
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, left_three_two
   j normal_three_two
not_normal_three_two:
   add $a3, $a3, 16384
   j final_three_two      
normal_three_two:   
   sub $a3, $a3, 64
   add $a3, $a3, 16384
final_three_two:   
   sw $a3, Tetro_address   
   lw $ra, counter
   jr $ra
       
Tetro_three_state_two:
   sw $ra, ra_storage
   li $s0, 2
   sw $s0, Tetro_current_state
   li $s0, 3
   sw $s0, Tetro
   lw $a3, Tetro_address
   li $t0, 0x2054A8
   jal draw_square
   add $a3, $a3, 64
   jal draw_square
   add $a3, $a3, 16384
   jal draw_square
   sub $a3, $a3, 16384
   add $a3, $a3, 64
   jal draw_square
   lw $ra, ra_storage
   jr $ra

remove_Tetro_three_state_two:
   sw $ra, counter
   lw $a1, Tetro_address
   jal remove_grid
   add $a1, $a1, 64
   jal remove_grid
   add $a1, $a1, 16384
   jal remove_grid
   sub $a1, $a1, 16384
   add $a1, $a1, 64
   jal remove_grid
   lw $ra, counter
   jr $ra
      

move_right_Tetro_three_state_two:
   sw $ra, ra_storage_2
can_move_right_Tetro_three_state_two:
   lw $a3, Tetro_address
   add $s0, $a3, 192
   add $s1, $a3, 16384
   add $s1, $s1, 128
   li $t9, 351
   li $t8, 0
can_move_right_three_two_Tetro:
   lw $t7, taken_memory($t8)
   beq $t7, $s0, game_loop
   beq $t7, $s1, game_loop
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_right_three_two_Tetro
   li $t9, 31
   li $t8, 0
can_move_right_three_two_right:
   lw $t7, right_array($t8)
   beq $t7, $s0, game_loop
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_right_three_two_right
   lw $a3, Tetro_address
   jal remove_Tetro_three_state_two
   add $a3, $a3, 64
   sw $a3, Tetro_address
   jal Tetro_three_state_two       
   lw $ra, ra_storage_2
   jr $ra
         

move_left_Tetro_three_state_two:
   sw $ra, ra_storage_2
can_move_left_Tetro_three_state_two:
   lw $a3, Tetro_address
   sub $s0, $a3, 64
   add $s1, $a3, 16384
   li $t9, 351
   li $t8, 0
can_move_left_three_two_Tetro:
   lw $t7, taken_memory($t8)
   beq $t7, $s0, game_loop
   beq $t7, $s1, game_loop
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_left_three_two_Tetro
   li $t9, 31
   li $t8, 0
can_move_left_three_two_left:
   lw $t7, left_array($t8)
   beq $t7, $a3, game_loop
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_left_three_two_left
   lw $a3, Tetro_address
   jal remove_Tetro_three_state_two
   sub $a3, $a3, 64
   sw $a3, Tetro_address
   jal Tetro_three_state_two       
   lw $ra, ra_storage_2
   jr $ra
   
move_down_Tetro_three_state_two:
   sw $ra, ra_storage_2
can_move_down_Tetro_three_state_two:
   lw $a3, Tetro_address
   add $a3, $a3, 64
   add $a3, $a3, 16384
   sub $s0, $a3, 64
   add $s1, $a3, 64
   add $s2, $a3, 16384
   li $t9, 351
   li $t8, 0
can_move_down_three_two_Tetro:
   lw $t7, taken_memory($t8)
   beq $t7, $s0, store_coord_Tetro_three_state_two 
   beq $t7, $s1, store_coord_Tetro_three_state_two
   beq $t7, $s2, store_coord_Tetro_three_state_two
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_down_three_two_Tetro
   li $t9, 13
   li $t8, 0
can_move_down_three_two_bottom:
   lw $t7, bottom_array($t8)
   beq $t7, $a3, store_coord_Tetro_three_state_two 
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_down_three_two_bottom
   lw $a3, Tetro_address
   jal remove_Tetro_three_state_two
   add $a3, $a3, 16384
   sw $a3, Tetro_address
   jal Tetro_three_state_two       
   lw $ra, ra_storage_2
   jr $ra                  
       
new_position_three_one:
   sw $ra, counter
   lw $a3, Tetro_address
   add $a3, $a3, 16384
   li $t9, 13
   li $t8, 0
bottom_three_one:
   lw $t7, bottom_array($t8)
   beq $t7, $a3, sub_three_one
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, bottom_three_one
   j final_three_one
sub_three_one:
   lw $a3, Tetro_address
   sub $a3, $a3, 16384
   j final_three_one
final_three_one:
   sw $a3, Tetro_address      
   lw $ra, counter
   jr $ra
       
Tetro_three_state_one:
   sw $ra, ra_storage
   li $s0, 1
   sw $s0, Tetro_current_state
   li $s0, 3
   sw $s0, Tetro
   lw $a3, Tetro_address
   li $t0, 0x2054A8
   jal draw_square
   add $a3, $a3, 16384
   jal draw_square
   add $a3, $a3, 64
   jal draw_square
   sub $a3, $a3, 64
   add $a3, $a3, 16384
   jal draw_square
   lw $ra, ra_storage
   jr $ra

remove_Tetro_three_state_one:
   sw $ra, counter
   lw $a1, Tetro_address
   jal remove_grid
   add $a1, $a1, 16384
   jal remove_grid
   add $a1, $a1, 64
   jal remove_grid
   sub $a1, $a1, 64
   add $a1, $a1, 16384
   jal remove_grid
   lw $ra, counter
   jr $ra

move_right_Tetro_three_state_one:
   sw $ra, ra_storage_2
can_move_right_Tetro_three_state_one:
   lw $a3, Tetro_address
   add $s0, $a3, 64
   add $s1, $s0, 16384
   add $s2, $s1, 16384
   add $s1, $s1, 64
   li $t9, 351
   li $t8, 0
can_move_right_three_one_Tetro:
   lw $t7, taken_memory($t8)
   beq $t7, $s0, game_loop 
   beq $t7, $s1, game_loop
   beq $t7, $s2, game_loop
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_right_three_one_Tetro
   li $t9, 31
   li $t8, 0
can_move_right_three_one_left:
   lw $t7, right_array($t8)
   beq $t7, $s1, game_loop
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_right_three_one_left
   lw $a3, Tetro_address
   jal remove_Tetro_three_state_one
   add $a3, $a3, 64
   sw $a3, Tetro_address
   jal Tetro_three_state_one         
   lw $ra, ra_storage_2
   jr $ra
        
move_left_Tetro_three_state_one:
   sw $ra, ra_storage_2
can_move_left_Tetro_three_state_one:
   lw $a3, Tetro_address
   sub $s0, $a3, 64
   add $s1, $s0, 16384
   add $s2, $s1, 16384
   li $t9, 351
   li $t8, 0
can_move_left_three_one_Tetro:
   lw $t7, taken_memory($t8)
   beq $t7, $s0, game_loop 
   beq $t7, $s1, game_loop
   beq $t7, $s2, game_loop
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_left_three_one_Tetro
   li $t9, 31
   li $t8, 0
can_move_left_three_one_left:
   lw $t7, left_array($t8)
   beq $t7, $a3, game_loop
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_left_three_one_left
   lw $a3, Tetro_address
   jal remove_Tetro_three_state_one
   sub $a3, $a3, 64
   sw $a3, Tetro_address
   jal Tetro_three_state_one         
   lw $ra, ra_storage_2
   jr $ra
   
move_down_Tetro_three_state_one:
   sw $ra, ra_storage_2
can_move_down_Tetro_three_state_one:
   lw $a3, Tetro_address
   add $a3, $a3, 16384
   add $a3, $a3, 16384
   add $s0, $a3, 64
   add $s1, $a3, 16384
   li $t9, 351
   li $t8, 0
can_move_down_three_one_Tetro:
   lw $t7, taken_memory($t8)
   beq $t7, $s0, store_coord_Tetro_three_state_one 
   beq $t7, $s1, store_coord_Tetro_three_state_one
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_down_three_one_Tetro
   li $t9, 13
   li $t8, 0
can_move_down_three_one_bottom:
   lw $t7, bottom_array($t8)
   beq $t7, $a3, store_coord_Tetro_three_state_one 
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_down_three_one_bottom
   lw $a3, Tetro_address
   jal remove_Tetro_three_state_one
   add $a3, $a3, 16384
   sw $a3, Tetro_address
   jal Tetro_three_state_one       
   lw $ra, ra_storage_2
   jr $ra
                   
new_position_three_zero: 
   sw $ra, counter
   lw $a3, Tetro_address
   add $s0, $a3, 128
   li $t9, 31
   li $t8, 0
right_wall_three_zero:
   lw $t7, right_array($t8)
   beq $s0, $t7, sub_three_zero
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, right_wall_three_zero
   j final_three_zero   
sub_three_zero:
   sub $a3, $a3, 64
final_three_zero:
   sub $a3, $a3, 16384
   add $a3, $a3, 64
   sw $a3, Tetro_address            
   lw $ra, counter
   jr $ra
      
Tetro_three_state_zero:
   sw $ra, ra_storage
   li $s0, 0
   sw $s0, Tetro_current_state
   li $s0, 3
   sw $s0, Tetro
   lw $a3, Tetro_address
   li $t0, 0x2054A8
   jal draw_square
   sub $a3, $a3, 64
   add $a3, $a3, 16384
   jal draw_square
   add $a3, $a3, 64
   jal draw_square
   add $a3, $a3, 64
   jal draw_square
   lw $ra, ra_storage
   jr $ra
   
remove_Tetro_three_state_zero:
   sw $ra, counter
   lw $a1, Tetro_address
   jal remove_grid
   sub $a1, $a1, 64
   add $a1, $a1, 16384
   jal remove_grid
   add $a1, $a1, 64
   jal remove_grid
   add $a1, $a1, 64
   jal remove_grid
   lw $ra, counter
   jr $ra
   
move_right_Tetro_three_state_zero:
   sw $ra, ra_storage_2
can_move_right_Tetro_three_state_zero:
   lw $a3, Tetro_address
   add $a2, $a3, 64
   add $s0, $a3, 16384
   add $s0, $s0, 64
   add $s1, $s0, 64
   li $t9, 351
   li $t8, 0
can_move_right_three_zero_Tetro:
   lw $t7, taken_memory($t8)
   beq $s1, $t7, game_loop
   beq $a2, $t7, game_loop
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_right_three_zero_Tetro
   li $t9, 31
   li $t8, 0
can_move_right_three_zero_left:
   lw $t7, right_array($t8)
   beq $s1, $t7, game_loop
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_right_three_zero_left
   lw $a3, Tetro_address
   jal remove_Tetro_three_state_zero
   add $a3, $a3, 64
   sw $a3, Tetro_address
   jal Tetro_three_state_zero      
   lw $ra, ra_storage_2
   jr $ra
      
move_left_Tetro_three_state_zero:
   sw $ra, ra_storage_2
can_move_left_Tetro_three_state_zero:
   lw $a3, Tetro_address
   sub $a2, $a3, 64
   add $s0, $a3, 16384
   sub $s0, $s0, 64
   sub $s1, $s0, 64
   li $t9, 351
   li $t8, 0
can_move_left_three_zero_Tetro:
   lw $t7, taken_memory($t8)
   beq $s1, $t7, game_loop
   beq $a2, $t7, game_loop
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_left_three_zero_Tetro
   li $t9, 31
   li $t8, 0
can_move_left_three_zero_left:
   lw $t7, left_array($t8)
   beq $s0, $t7, game_loop
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_left_three_zero_left
   lw $a3, Tetro_address
   jal remove_Tetro_three_state_zero
   sub $a3, $a3, 64
   sw $a3, Tetro_address
   jal Tetro_three_state_zero      
   lw $ra, ra_storage_2
   jr $ra
         
move_down_Tetro_three_state_zero:
   sw $ra, ra_storage_2
can_move_down_Tetro_three_state_zero:
   lw $a3, Tetro_address
   add $a3, $a3, 16384
   add $s0, $a3, 16384
   sub $s1, $s0, 64
   add $s2, $s0, 64
   li $t9, 351
   li $t8, 0
can_move_down_three_zero_Tetro:
   lw $t7, taken_memory($t8)
   beq $s0, $t7, store_coord_Tetro_three_state_zero
   beq $s1, $t7, store_coord_Tetro_three_state_zero
   beq $s2, $t7, store_coord_Tetro_three_state_zero
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_down_three_zero_Tetro
   li $t9, 13
   li $t8, 0
can_move_down_three_zero_bottom:
   lw $t7, bottom_array($t8)
   beq $a3, $t7, store_coord_Tetro_three_state_zero
   add $t8, $t8, 4
   sub $t9, $t9, 1
   bnez $t9, can_move_down_three_zero_bottom
   lw $a3, Tetro_address
   jal remove_Tetro_three_state_zero
   add $a3, $a3, 16384
   sw $a3, Tetro_address
   jal Tetro_three_state_zero            
   lw $ra, ra_storage_2
   jr $ra
      
   
new_position_two_one:
    sw $ra, counter
    lw $a3, Tetro_address
    add $s0, $a3, 64
    add $s1, $s0, 64
    add $s2, $s1, 64
    li $t9, 27
    li $t8, 0
check_left_wall_two_one:
    lw $t7, left_array($t8)
    beq $t7, $a3, final_two_one
    add $t8, $t8, 4
    sub $t9, $t9, 1
    bnez $t9, check_left_wall_two_one
    li $t9, 27
    li $t8, 0
check_right_wall_two_one:
    lw $t7, right_array($t8)
    beq $t7, $s0, sub_two_one
    beq $t7, $s1, sub_1_two_one
    beq $t7, $s2, sub_2_two_one
    add $t8, $t8, 4
    sub $t9, $t9, 1
    bnez $t9, check_right_wall_two_one
    j final_two_one
sub_2_two_one:
    sub $a3, $a3, 64
    j final_two_one    
sub_1_two_one:
    sub $a3, $a3, 128
    j final_two_one    
sub_two_one:
    sub $a3, $a3, 192
    j final_two_one        
final_two_one:            
    sw $a3, Tetro_address
    lw $ra, counter
             
Tetro_two_state_one:
    sw $ra, ra_storage
    li $s0, 1
    sw $s0, Tetro_current_state
    li $s0, 2
    sw $s0, Tetro
    lw $a3, Tetro_address
    li $t0, 0x732E5B
    jal draw_square
    add $a3, $a3, 64
    jal draw_square
    add $a3, $a3, 64       
    jal draw_square
    add $a3, $a3, 64
    jal draw_square
    lw $ra, ra_storage
    jr $ra

remove_Tetro_two_state_one:
    sw $ra, counter
    lw $a1, Tetro_address
    jal remove_grid
    add $a1, $a1, 64
    jal remove_grid
    add $a1, $a1, 64
    jal remove_grid
    add $a1, $a1, 64
    jal remove_grid
    lw $ra, counter
    jr $ra

move_right_Tetro_two_state_one:
    sw $ra, ra_storage_2
can_move_right_Tetro_two_state_one:
    lw $a3, Tetro_address
    add $a3, $a3, 256
    li $t9, 351
    li $t8, 0
can_move_right_two_one_Tetro:
    lw $t7, taken_memory($t8)
    beq $a3, $t7, game_loop
    add $t8, $t8, 4
    sub $t9, $t9, 1
    bnez $t9, can_move_right_two_one_Tetro
    li $t9, 31
    li $t8, 0
can_move_right_two_one_left:
    lw $t7, right_array($t8)
    beq $a3, $t7, game_loop
    add $t8, $t8, 4
    sub $t9, $t9, 1
    bnez $t9, can_move_right_two_one_left
    lw $a3, Tetro_address
    jal remove_Tetro_two_state_one
    add $a3, $a3, 64
    sw $a3, Tetro_address
    jal Tetro_two_state_one
    lw $ra, ra_storage_2
    jr $ra

move_left_Tetro_two_state_one:
    sw $ra, ra_storage_2
can_move_left_Tetro_two_state_one:
    lw $a3, Tetro_address
    sub $s0, $a3, 64
    li $t9, 351
    li $t8, 0
can_move_left_two_one_Tetro:
    lw $t7, taken_memory($t8)
    beq $s0, $t7, game_loop
    add $t8, $t8, 4
    sub $t9, $t9, 1
    bnez $t9, can_move_left_two_one_Tetro
    li $t9, 31
    li $t8, 0
can_move_left_two_one_left:
    lw $t7, left_array($t8)
    beq $a3, $t7, game_loop
    add $t8, $t8, 4
    sub $t9, $t9, 1
    bnez $t9, can_move_left_two_one_left
    lw $a3, Tetro_address
    jal remove_Tetro_two_state_one
    sub $a3, $a3, 64
    sw $a3, Tetro_address
    jal Tetro_two_state_one
    lw $ra, ra_storage_2
    jr $ra
                        
move_down_Tetro_two_state_one:
    sw $ra, ra_storage_2
can_move_down_Tetro_two_state_one:
    lw $a3, Tetro_address
    add $s0, $a3, 16384
    add $s1, $s0, 64
    add $s2, $s1, 64
    add $s3, $s2, 64
    li $t9, 351
    li $t8, 0
can_move_down_two_one_Tetro:
    lw $t7, taken_memory($t8)
    beq $s0, $t7, store_coord_Tetro_two_state_one
    beq $s1, $t7, store_coord_Tetro_two_state_one
    beq $s2, $t7, store_coord_Tetro_two_state_one
    beq $s3, $t7, store_coord_Tetro_two_state_one
    add $t8, $t8, 4
    sub $t9, $t9, 1
    bnez $t9, can_move_down_two_one_Tetro    
    li $t9, 13
    li $t8, 0
can_move_down_two_one_bottom:
    lw $t7, bottom_array($t8)
    beq $a3, $t7, store_coord_Tetro_two_state_one
    add $t8, $t8, 4
    sub $t9, $t9, 1
    bnez $t9, can_move_down_two_one_bottom
    jal remove_Tetro_two_state_one
    lw $a3, Tetro_address
    add $a3, $a3, 16384
    sw $a3, Tetro_address
    jal Tetro_two_state_one       
    lw $ra, ra_storage_2
    jr $ra        
    
    
Tetro_two_state_zero:
    sw $ra, ra_storage
    li $s0, 0
    sw $s0, Tetro_current_state
    li $s0, 2
    sw $s0, Tetro
    lw $a3, Tetro_address
    li $t0, 0x732E5B
    jal draw_square
    add $a3, $a3, 16384
    jal draw_square
    add $a3, $a3, 16384       
    jal draw_square
    add $a3, $a3, 16384
    jal draw_square
    lw $ra, ra_storage
    jr $ra
        
new_position_two_zero:
    sw $ra, counter
    lw $a3, Tetro_address
    add $s0, $a3, 16384
    add $s1, $s0, 16384
    li $t9, 13
    li $t8, 0
check_bottom_two_zero:
    lw $t7, bottom_array($t8)
    beq $t7, $a3, sub_two_zero
    beq $t7, $s0, sub_1_two_zero
    beq $s1, $t7, sub_2_two_zero
    add $t8, $t8, 4
    sub $t9, $t9, 1
    bnez $t9, check_bottom_two_zero
    j final_two_zero
sub_two_zero:
    sub $a3, $a3, 16384
    sub $a3, $a3, 16384
    sub $a3, $a3, 16384
    j final_two_zero
sub_1_two_zero:
    sub $a3, $a3, 16384
    sub $a3, $a3, 16384
    j final_two_zero
sub_2_two_zero:
    sub $a3, $a3, 16384
    j final_two_zero        
final_two_zero:
    sw $a3, Tetro_address            
    lw $ra, counter
    jr $ra
    
remove_Tetro_two_state_zero:
    sw $ra, ra_storage_3
    lw $a1, Tetro_address
    jal remove_grid
    add $a1, $a1, 16384
    jal remove_grid
    add $a1, $a1, 16384
    jal remove_grid
    add $a1, $a1, 16384
    jal remove_grid
    lw $ra, ra_storage_3
    jr $ra

move_right_Tetro_two_state_zero:
    sw $ra, ra_storage_2
can_move_right_Tetro_two_state_zero:
    lw $a3, Tetro_address
    add $a3, $a3, 64
    add $s0, $a3, 16384
    add $s1, $s0, 16384
    add $s2, $s1, 16384
    li $t9, 351
    li $t8, 0
can_move_right_two_zero_Tetro:
    lw $t7, taken_memory($t8)
    beq $a3, $t7, game_loop
    beq $s0, $t7, game_loop
    beq $s1, $t7, game_loop
    beq $s2, $t7, game_loop
    add $t8, $t8, 4
    sub $t9, $t9, 1
    bnez $t9, can_move_right_two_zero_Tetro
    li $t9, 31
    li $t8, 0    
can_move_right_two_zero_right:
    lw $t7, right_array($t8)
    beq $a3, $t7, game_loop
    add $t8, $t8, 4
    sub $t9, $t9, 1
    bnez $t9, can_move_right_two_zero_right
    jal remove_Tetro_two_state_zero
    lw $a3, Tetro_address
    add $a3, $a3, 64
    sw $a3, Tetro_address
    jal Tetro_two_state_zero      
    lw $ra, ra_storage_2
    jr $ra
            
move_left_Tetro_two_state_zero:
    sw $ra, ra_storage_2
can_move_left_Tetro_two_state_zero:
    lw $a3, Tetro_address
    sub $a2, $a3, 64
    add $s0, $a2, 16384
    add $s1, $s0, 16384
    add $s2, $s1, 16384
    li $t9, 351
    li $t8, 0
can_move_left_two_zero_Tetro:
    lw $t7, taken_memory($t8)
    beq $a3, $t7, game_loop
    beq $s0, $t7, game_loop
    beq $s1, $t7, game_loop
    beq $s2, $t7, game_loop
    add $t8, $t8, 4
    sub $t9, $t9, 1
    bnez $t9, can_move_left_two_zero_Tetro
    li $t9, 31
    li $t8, 0    
can_move_left_two_zero_left:
    lw $t7, left_array($t8)
    beq $a3, $t7, game_loop
    add $t8, $t8, 4
    sub $t9, $t9, 1
    bnez $t9, can_move_left_two_zero_left
    jal remove_Tetro_two_state_zero
    lw $a3, Tetro_address
    sub $a3, $a3, 64
    sw $a3, Tetro_address
    jal Tetro_two_state_zero      
    lw $ra, ra_storage_2
    jr $ra
                
move_down_Tetro_two_state_zero:
    sw $ra, ra_storage_2
can_move_down_Tetro_two_state_zero:
    lw $a3, Tetro_address
    add $a3, $a3, 16384
    add $a3, $a3, 16384
    add $a3, $a3, 16384
    add $s0, $a3, 16384
    li $t9, 351
    li $t8, 0
can_move_down_two_zero_Tetro:
    lw $t7, taken_memory($t8)
    beq $s0, $t7, store_coord_Tetro_two_state_zero
    add $t8, $t8, 4
    sub $t9, $t9, 1
    bnez $t9, can_move_down_two_zero_Tetro    
    li $t9, 13
    li $t8, 0
can_move_down_two_zero_bottom:
    lw $t7, bottom_array($t8)
    beq $a3, $t7, store_coord_Tetro_two_state_zero
    add $t8, $t8, 4
    sub $t9, $t9, 1
    bnez $t9, can_move_down_two_zero_bottom
    jal remove_Tetro_two_state_zero
    lw $a3, Tetro_address
    add $a3, $a3, 16384
    sw $a3, Tetro_address
    jal Tetro_two_state_zero       
    lw $ra, ra_storage_2
    jr $ra        

Tetro_one_state_zero_get_new_position:
    sw $ra, ra_storage_3
bottom_check_one_zero:
    lw $a3, Tetro_address
    add $s0, $a3, 16384
    li $t1, 13
    li $t2, 0
bottom_check_zero_loop:
    lw $t7, bottom_array($t2)
    beq $t7, $s0, move_up_one_zero
    add $t2, $t2, 4
    sub $t1, $t1, 1
    bnez $t1, bottom_check_zero_loop
    j final_one_zero
move_up_one_zero:
    sub $a3, $a3, 16384
final_one_zero:                
    add $a3, $a3, -64
    sw $a3, Tetro_address
    lw $ra, ra_storage_3
    jr $ra        

Tetro_one_state_three_get_new_position:                    
    sw $ra, ra_storage_3
    lw $a3, Tetro_address
    add $s0, $a3, 128
    add $s1, $s0, 16384
    add $a3, $a3, 64
    li $t9, 31
    li $t8, 0
check_right_one_three_loop:
    lw $t7, right_array($t8)
    beq $t7, $s0, final_one_three
    add $t8, $t8, 4
    sub $t9, $t9, 1
    bnez $t9, check_right_one_three_loop
    li $t9, 351
    li $t8, 0
check_right_one_three_Tetro_loop:
    lw $t7, taken_memory($t8)
    beq $s0, $t7, move_up_one_three
    beq $s1, $t7, move_up_one_three
    add $t8, $t8, 4
    sub $t9, $t9, 1
    bnez $t9, check_right_one_three_Tetro_loop
    j one_three 
move_up_one_three:
    sub $a3, $a3, 16384            
one_three:
    add $a3, $a3, 64    
final_one_three:        
    sw $a3, Tetro_address
    lw $ra, ra_storage_3
    jr $ra 
       
Tetro_one_state_three:
    sw $ra, ra_storage
    lw $a3, Tetro_address
    li $t0, 0xF70A0A
    jal draw_square
    add $a3, $a3, 16384
    sub $a3, $a3, 128
    jal draw_square
    add $a3, $a3, 64
    jal draw_square
    add $a3, $a3, 64
    jal draw_square
    
    lw $ra, ra_storage
    jr $ra

remove_Tetro_one_state_three:
    sw $ra, ra_storage
    lw $a1, Tetro_address
    jal remove_grid
    add $a1, $a1, 16384
    sub $a1, $a1, 128
    jal remove_grid
    add $a1, $a1, 64
    jal remove_grid
    add $a1, $a1, 64
    jal remove_grid
    lw $ra, ra_storage
    jr $ra

move_right_Tetro_one_state_three:
    sw $ra, ra_storage_2
can_move_right_Tetro_one_state_three:
    lw $a3, Tetro_address
    add $a3, $a3, 64
    add $s0, $a3, 16384
    li $t9, 351
    li $t8, 0
can_move_right_one_three_Tetro_loop:
    lw $t7, taken_memory($t8)
    beq $t7, $s0, game_loop
    beq $t7, $a3, game_loop
    add $t8, $t8, 4
    sub $t9, $t9, 1
    bnez $t9, can_move_right_one_three_Tetro_loop    
    li $t9, 31
    li $t8, 0
can_move_right_one_three_right_loop:    
    lw $t7, right_array($t8)
    beq $t7, $a3, game_loop
    add $t8, $t8, 4
    sub $t9, $t9, 1
    bnez $t9, can_move_right_one_three_right_loop               
    jal remove_Tetro_one_state_three
    lw $a1, Tetro_address
    add $a1, $a1, 64
    sw $a1, Tetro_address
    jal Tetro_one_state_three 
    lw $ra, ra_storage_2
    jr $ra
    
move_left_Tetro_one_state_three:
    sw $ra, ra_storage_2
can_move_left_Tetro_one_state_three:
    lw $a3, Tetro_address
    move $s0, $a3
    sub $s0, $s0, 64
    sub $a2, $a3, 128
    sub $a3, $a3, 192
    add $a3, $a3, 16384
    li $t9, 351
    li $t8, 0
can_move_left_one_three_Tetro_loop:
    lw $t7, taken_memory($t8)
    beq $t7, $s0, game_loop
    beq $t7, $a3, game_loop
    add $t8, $t8, 4
    sub $t9, $t9, 1
    bnez $t9, can_move_left_one_three_Tetro_loop    
    li $t9, 31
    li $t8, 0
can_move_left_one_three_left_loop:    
    lw $t7, left_array($t8)
    beq $t7, $a2, game_loop
    add $t8, $t8, 4
    sub $t9, $t9, 1
    bnez $t9, can_move_left_one_three_left_loop       
    jal remove_Tetro_one_state_three
    lw $a1, Tetro_address
    add $a1, $a1, -64
    sw $a1, Tetro_address
    jal Tetro_one_state_three 
    lw $ra, ra_storage_2
    jr $ra

move_down_Tetro_one_state_three:
    sw $ra, ra_storage_2
can_move_down_Tetro_one_state_three:
    lw $a3, Tetro_address
    add $a3, $a3, 16384
    add $s0, $a3, 16384
    sub $s1, $s0, 64
    sub $s2, $s1, 64
    li $t9, 351
    li $t8, 0
can_move_down_one_three_Tetro_loop:
    lw $t7, taken_memory($t8)
    beq $t7, $s0, store_coord_Tetro_one_state_three
    beq $t7, $s1, store_coord_Tetro_one_state_three
    beq $t7, $s2, store_coord_Tetro_one_state_three 
    add $t8, $t8, 4
    sub $t9, $t9, 1
    bnez $t9, can_move_down_one_three_Tetro_loop   
    li $t9, 13
    li $t8, 0    
can_move_down_one_three_bottom_loop:
    lw $t7, bottom_array($t8)
    beq $t7, $a3, store_coord_Tetro_one_state_three
    add $t8, $t8, 4
    sub $t9, $t9, 1
    bnez $t9,can_move_down_one_three_bottom_loop             
    jal remove_Tetro_one_state_three
    lw $a1, Tetro_address
    add $a1, $a1, 16384
    sw $a1, Tetro_address
    jal Tetro_one_state_three 
    lw $ra, ra_storage_2
    jr $ra        

Tetro_one_state_two_get_new_position:                    
    sw $ra, ra_storage_3
    lw $a3, Tetro_address
    add $a3, $a3, -16384
check_down_collision_one_two:
    add $s0, $a3, 64
    add $s0, $s0, 16384
    add $s1, $s0, 16384
    li $t9, 351
    li $t8, 0
loop_one_two:
    lw $t7, taken_memory($t8)
    beq $t7, $s0, add_one_two
    beq $t7, $s1, add_one_two
    add $t8, $t8, 4
    sub $t9, $t9, 1
    bnez $t9, loop_one_two
    j normal_one_two
add_one_two:
    add $a3, $a3, -16384
normal_one_two:                    
    sw $a3, Tetro_address
    lw $ra, ra_storage_3
    jr $ra
    
Tetro_one_state_two:
    sw $ra, ra_storage
    lw $a3, Tetro_address
    li $t0, 0xF70A0A
    jal draw_square
    add $a3, $a3, 64
    jal draw_square
    add $a3, $a3, 16384
    jal draw_square
    add $a3, $a3, 16384
    jal draw_square
    
    lw $ra, ra_storage
    jr $ra

remove_Tetro_one_state_two:
    sw $ra, ra_storage
    lw $a1, Tetro_address
    jal remove_grid
    add $a1, $a1, 64
    jal remove_grid
    add $a1, $a1, 16384
    jal remove_grid
    add $a1, $a1, 16384
    jal remove_grid
    lw $ra, ra_storage
    jr $ra
 
move_right_Tetro_one_state_two:
    sw $ra, ra_storage_2
can_move_right_Tetro_one_state_two:
    lw $a3, Tetro_address
    add $a3, $a3, 128
    add $s0, $a3, 16384
    add $s1, $s0, 16384
    li $t9, 351
    li $t8, 0
can_move_right_one_two_Tetro_loop:
    lw $t7, taken_memory($t8)
    beq $t7, $a3, game_loop
    beq $t7, $s0, game_loop
    beq $t7, $s1, game_loop
    add $t8, $t8, 4
    sub $t9, $t9, 1
    bnez $t9, can_move_right_one_two_Tetro_loop
    li $t9, 31
    li $t8, 0
can_move_right_one_two_right_loop:
    lw $t7, right_array($t8)
    beq $t7, $a3, game_loop
    add $t8, $t8, 4
    sub $t9, $t9, 1
    bnez $t9, can_move_right_one_two_right_loop            
    jal remove_Tetro_one_state_two
    lw $a1, Tetro_address
    add $a1, $a1, 64
    sw $a1, Tetro_address
    jal Tetro_one_state_two 
    lw $ra, ra_storage_2
    jr $ra
    
move_left_Tetro_one_state_two:
    sw $ra, ra_storage_2
can_move_left_Tetro_one_state_two:
    lw $a3, Tetro_address
    sub $s0, $a3, 64
    add $s1, $s0, 16384
    add $s1, $s1, 64
    add $s2, $s1, 16384
    li $t9, 351
    li $t8, 0
can_move_left_one_two_Tetro_loop:
    lw $t7, taken_memory($t8)
    beq $t7, $s0, game_loop
    beq $t7, $s1, game_loop
    beq $t7, $s2, game_loop
    add $t8, $t8, 4
    sub $t9, $t9, 1
    bnez $t9, can_move_left_one_two_Tetro_loop 
    li $t9, 31
    li $t8, 0    
can_move_left_one_two_left_loop:
    lw $t7, left_array($t8)
    beq $t7, $a3, game_loop
    add $t8, $t8, 4
    sub $t9, $t9, 1
    bnez $t9, can_move_left_one_two_left_loop           
    jal remove_Tetro_one_state_two
    lw $a1, Tetro_address
    add $a1, $a1, -64
    sw $a1, Tetro_address
    jal Tetro_one_state_two 
    lw $ra, ra_storage_2
    jr $ra

move_down_Tetro_one_state_two:
    sw $ra, ra_storage_2
can_move_down_Tetro_one_state_two:
    lw $a3, Tetro_address
    add $s0, $a3, 16384
    add $a3, $a3, 64
    add $a3, $a3, 16384
    add $a3, $a3, 16384
    add $s1, $a3, 16384
    li $t9, 351
    li $t8, 0
can_move_down_one_two_Tetro_loop:
    lw $t7, taken_memory($t8)
    beq $t7, $s0, store_coord_Tetro_one_state_two
    beq $t7, $s1, store_coord_Tetro_one_state_two
    add $t8, $t8, 4
    sub $t9, $t9, 1
    bnez $t9, can_move_down_one_two_Tetro_loop    
    li $t9, 13
    li $t8, 0
can_move_down_one_two_bottom_loop:
    lw $t7, bottom_array($t8)
    beq $t7, $a3, store_coord_Tetro_one_state_two
    add $t8, $t8, 4
    sub $t9, $t9, 1
    bnez $t9, can_move_down_one_two_bottom_loop        
    jal remove_Tetro_one_state_two
    lw $a1, Tetro_address
    add $a1, $a1, 16384
    sw $a1, Tetro_address
    jal Tetro_one_state_two 
    lw $ra, ra_storage_2
    jr $ra                    
      
                    
Tetro_one_state_one_get_new_position:
    sw $ra, ra_storage_3
    lw $a3, Tetro_address
    add $a3, $a3, 16384
    add $s0, $a3, 64
    sub $s1, $a3, 64
    add $s2, $a3, 16320
    li $t1, 351
    li $t2, 0
check_Tetro_one_one_loop:
    lw $t7, taken_memory($t2)
    beq $t7, $s0, move_up_one_one
    beq $t7, $s1, move_up_one_one
    beq $t7, $s2, move_up_one_one
    add $t2, $t2, 4
    sub $t1, $t1, 1
    bnez $t1, check_Tetro_one_one_loop
    li $t1, 31
    li $t2, 0
    j check_left_wall_one_loop
move_up_one_one:
    sub $a3, $a3, 16384
    add $s0, $a3, 64
    sub $s1, $a3, 64
    add $s2, $a3, 16320
    li $t1, 351
    li $t2, 0
    j check_Tetro_one_one_loop           
check_left_wall_one_loop:
    lw $t7, left_array($t2)
    beq $a3, $t7, skip_rotate_Tetro_one_state_one
    add $t2, $t2, 4
    sub $t1, $t1, 1
    bnez $t1, check_left_wall_one_loop
    sub $a3, $a3, 64    
skip_rotate_Tetro_one_state_one:        
    sw $a3, Tetro_address
    lw $ra, ra_storage_3
    jr $ra            
Tetro_one_state_one:
    # Assume we already at the desired location
    sw $ra, ra_storage
    lw $a3, Tetro_address
    li $t0, 0xF70A0A
    jal draw_square
    add $a3, $a3, 64
    jal draw_square
    add $a3, $a3, 64
    jal draw_square
    sub $a3, $a3, 128
    add $a3, $a3, 16384
    jal draw_square
    
    lw $ra, ra_storage
    jr $ra  

remove_Tetro_one_state_one:
    sw $ra, ra_storage
    lw $a1, Tetro_address
    jal remove_grid
    add $a1, $a1, 64
    jal remove_grid
    add $a1, $a1, 64
    jal remove_grid
    sub $a1, $a1, 128
    add $a1, $a1, 16384
    jal remove_grid
    lw $ra, ra_storage
    jr $ra

move_right_Tetro_one_state_one:
    sw $ra, ra_storage_2
can_move_right_Tetro_one_state_one:
    lw $a3, Tetro_address
    add $s0, $a3, 16384
    add $s0, $s0, 64
    add $a3, $a3, 192
    li $t9, 351
    li $t8, 0
can_move_right_one_one_Tetro_loop:
    lw $t7, taken_memory($t8)
    beq $t7, $a3, game_loop
    beq $t7, $s0, game_loop
    add $t8, $t8, 4
    sub $t9, $t9, 1
    bnez $t9, can_move_right_one_one_Tetro_loop 
    li $t9, 31
    li $t8, 0
can_move_right_one_one_right_loop:
    lw $t7, right_array($t8)
    beq $a3, $t7, game_loop
    add $t8, $t8, 4
    sub $t9, $t9, 1
    bnez $t9, can_move_right_one_one_right_loop        
    jal remove_Tetro_one_state_one
    lw $a1, Tetro_address
    add $a1, $a1, 64
    sw $a1, Tetro_address
    jal Tetro_one_state_one 
    lw $ra, ra_storage_2
    jr $ra
    
move_left_Tetro_one_state_one:
    sw $ra, ra_storage_2
can_move_left_Tetro_one_state_one:
    lw $a3, Tetro_address
    sub $a2, $a3, 64
    add $s0, $a2, 16384
    li $t9, 351
    li $t8, 0
can_move_left_one_one_Tetro_loop:
    lw $t7, taken_memory($t8)
    beq $t7, $a2, game_loop
    beq $t7, $s0, game_loop
    add $t8, $t8, 4
    sub $t9, $t9, 1
    bnez $t9, can_move_left_one_one_Tetro_loop 
    li $t9, 31
    li $t8, 0    
can_move_left_one_one_left_loop:
    lw $t7, left_array($t8)
    beq $a3, $t7, game_loop
    add $t8, $t8, 4
    sub $t9, $t9, 1
    bnez $t9, can_move_left_one_one_left_loop   
    jal remove_Tetro_one_state_one
    lw $a1, Tetro_address
    add $a1, $a1, -64
    sw $a1, Tetro_address
    jal Tetro_one_state_one 
    lw $ra, ra_storage_2
    jr $ra

move_down_Tetro_one_state_one:
    sw $ra, ra_storage_2
can_move_down_Tetro_one_state_one:
    lw $a3, Tetro_address
    add $a3, $a3, 16384
    add $a2, $a3, 16384
    add $s0, $a3, 64
    add $s1, $s0, 64
    li $t9, 351
    li $t8, 0
can_move_down_one_one_Tetro_loop:
    lw $t7, taken_memory($t8)
    beq $s0, $t7, store_coord_Tetro_one_state_one
    beq $s1, $t7, store_coord_Tetro_one_state_one
    beq $a2, $t7, store_coord_Tetro_one_state_one
    add $t8, $t8, 4
    sub $t9, $t9, 1
    bnez $t9, can_move_down_one_one_Tetro_loop
    li $t9, 13
    li $t8, 0    
can_move_down_one_one_bottom_loop:
    lw $t7, bottom_array($t8)
    beq $a3, $t7, store_coord_Tetro_one_state_one
    add $t8, $t8, 4
    sub $t9, $t9, 1
    bnez $t9, can_move_down_one_one_bottom_loop 
                
    jal remove_Tetro_one_state_one   
    lw $a1, Tetro_address
    add $a1, $a1, 16384
    sw $a1, Tetro_address
    jal Tetro_one_state_one 
    lw $ra, ra_storage_2
    jr $ra                                            
                                                          
move_right_Tetro_one_state_zero:
    sw $ra, ra_storage
can_move_right_Tetro_one_state_zero:
    lw $a3, Tetro_address
    lw $s0, Tetro_address
    add $s0, $s0, 64
    add $s1, $s0, 16384
    add $a3, $a3, 16384
    add $a3, $a3, 16384
    add $a3, $a3, 128
    li $t9, 351
    li $t8, 0
can_move_right_loop_zero_Tetro:
    lw $t7, taken_memory($t8)
    beq $a3, $t7, game_loop
    beq $s0, $t7, game_loop
    beq $s1, $t7, game_loop
    add $t8, $t8, 4
    sub $t9, $t9, 1
    bnez $t9, can_move_right_loop_zero_Tetro
    li $t9, 31
    li $t8, 0
can_move_right_loop_zero_right:
    lw $t7, right_array($t8)
    beq $a3, $t7, game_loop
    add $t8, $t8, 4
    sub $t9, $t9, 1
    bnez $t9, can_move_right_loop_zero_right
    jal remove_Tetro_one
    lw $a0, Tetro_address
    add $a0, $a0, 64
    sw $a0, Tetro_address
    jal Tetro_one
    lw $ra, ra_storage
    jr $ra
    
move_left_Tetro_one_state_zero:
    sw $ra, ra_storage
can_move_left_Tetro_one_state_zero:
    lw $a3, Tetro_address
    sub $s0, $a3, 64
    add $s1, $s0, 16384
    add $s2, $s1, 16384
    li $t9, 351
    li $t8, 0
can_move_left_loop_zero_Tetro:
    lw $t7, taken_memory($t8)
    beq $s0, $t7, game_loop
    beq $s1, $t7, game_loop
    beq $s2, $t7, game_loop
    add $t8, $t8, 4
    sub $t9, $t9, 1
    bnez $t9, can_move_left_loop_zero_Tetro
    li $t9, 31
    li $t8, 0    
can_move_left_loop_zero_left:
    lw $t7, left_array($t8) 
    beq $a3, $t7, game_loop        
    add $t8, $t8, 4
    sub $t9, $t9, 1
    bnez $t9, can_move_left_loop_zero_left         
    jal remove_Tetro_one
    lw $a0, Tetro_address
    add $a0, $a0, -64
    sw $a0, Tetro_address
    jal Tetro_one
    lw $ra, ra_storage
    jr $ra
        
move_down_Tetro_one_state_zero:
    sw $ra, ra_storage_2    
can_move_down_Tetro_one_state_zero:
    lw $a3, Tetro_address
    add $a3, $a3, 16384
    add $a3, $a3, 16384
    add $a2, $a3, 16384
    add $s0, $a2, 64
    li $t9, 351
    li $t8, 0
can_move_down_loop_zero_Tetro:
    lw $t7, taken_memory($t8)
    beq $t7, $a2, store_coord_Tetro_one_state_zero
    beq $t7, $s0, store_coord_Tetro_one_state_zero
    add $t8, $t8, 4
    sub $t9, $t9, 1
    bnez $t9, can_move_down_loop_zero_Tetro
    li $t9, 13
    li $t8, 0    
can_move_down_loop_zero_bottom:
    lw $t7, bottom_array($t8) 
    beq $a3, $t7, store_coord_Tetro_one_state_zero        
    add $t8, $t8, 4
    sub $t9, $t9, 1
    bnez $t9, can_move_down_loop_zero_bottom            
    jal remove_Tetro_one
    lw $a0, Tetro_address
    add $a0, $a0, 16384
    sw $a0, Tetro_address
    jal Tetro_one
    lw $ra, ra_storage_2
    jr $ra            
                     
remove_Tetro_one:
    # $a1 is the address that contains the left corner coordinate of Tetromino
    move $a3, $ra
    lw $a1, Tetro_address
    jal remove_grid
    add $a1, $a1, 16384
    jal remove_grid
    add $a1, $a1, 16384
    jal remove_grid
    add $a1, $a1, 64
    jal remove_grid
    move $ra, $a3
    jr $ra
                
remove_grid:
    move $t5, $ra 
    li $a2, 0x10008000
    sub $t0, $a1, $a2       # $t0 now contains the offset in bytes
    move $a2, $a1
    li $t2, 1024
    div $t0, $t2
    mflo $t3
    mfhi $t4
    li $t8, 0
    li $t9, 1
process_row:
    # Now we have y-cord in $t3, x-cord in $t4 in pixels
    li $t1, 16
    li $t2, 2
    div $t3, $t1
    mflo $t3
    div $t3, $t2
    mfhi $t3
    beq $t3, $t8, even_row
    beq $t3, $t9, odd_row
even_row:
    jal process_column    
    beq $t4, $t8, draw_white
    beq $t4, $t9, draw_black
odd_row:
    jal process_column
    beq $t4, $t8, draw_black
    beq $t4, $t9, draw_white
process_column:
    add $t6, $t3, 1
    li $t7, 100
    mul $t7, $t6, $t7
    sub $t4, $t4, $t7
    srl $t4, $t4, 2    # Shift right by 2 bits to divide the byte offset by 4
    div $t4, $t1
    mflo $t4
    div $t4, $t2
    mfhi $t4
    jr $ra
end_remove:
    move $ra, $t5
    jr $ra                    
    
# Even row and odd column: draw white (If column number divide 16 is even)
# Even row and even column: draw black (If column number divide 16 is odd)
# Odd row and odd column: draw black (If column number divide 16 is even)   
# Odd row and even column: draw white (If column number divide 16 is odd)

    
draw_black:
    li $t0, 0x00949453
    li $t2, 16
vertical_loop_black:    	
    li $t1, 16
horizontal_loop_black:
    sw $t0, 0($a2)
    add $a2, $a2, 4
    add $t1, $t1, -1
    bnez $t1, horizontal_loop_black
    
    add $a2, $a2, -64
    add $a2, $a2, 1024
    add $t2, $t2, -1
    bnez $t2, vertical_loop_black  
    j end_remove
       
draw_white:
    li $t0, 0x98A16C
    li $t2, 16
vertical_loop_white:    	
    li $t1, 16
horizontal_loop_white:
    sw $t0, 0($a2)
    add $a2, $a2, 4
    add $t1, $t1, -1
    bnez $t1, horizontal_loop_white
    
    add $a2, $a2, -64
    add $a2, $a2, 1024
    add $t2, $t2, -1
    bnez $t2, vertical_loop_white
    j end_remove
                    
Tetro_one:
    li $t0, 0
    sw $t0, Tetro_current_state
    li $s0, 1
    sw $s0, Tetro
    lw $a3, Tetro_address
    move $a2, $a3
    li $t0, 0xF70A0A
    li $t1, 32
Tetro_one_part_one_vertical_loop:
    li $t2, 16
Tetro_one_part_one_horizontal_loop:
    sw $t0, 0($a3)
    addiu $a3, $a3, 4
    sub $t2, $t2, 1
    bnez $t2, Tetro_one_part_one_horizontal_loop
    addi $a3, $a3, -64
    addi $a3, $a3, 1024
    sub $t1, $t1, 1
    bnez $t1, Tetro_one_part_one_vertical_loop
Tetro_one_part_two:    
    li $t1, 16
Tetro_one_part_two_vertical_loop:
    li $t2, 32
Tetro_one_part_two_horizontal_loop:
    sw $t0, 0($a3)
    addiu $a3, $a3, 4
    sub $t2, $t2, 1
    bnez $t2, Tetro_one_part_two_horizontal_loop
    sub $a3, $a3, 128
    addi $a3, $a3, 1024
    sub $t1, $t1, 1
    bnez $t1, Tetro_one_part_two_vertical_loop
    sw $a2, Tetro_address
    jr $ra

draw_walls_2:
    sw $ra, ra_storage_2
    la $a0, 0x10008000       # Load base address into $a0
    add $a0, $a0, 65536
    li $t0, 0x5C5B3E    # Load wall color into $t0
    li $t1, 512  # Load play area height into $t1
    li $t2, 25     # Load wall width into $t2
         
    jal draw_vertical_wall   # Draw the left wall using current $a0 and $t0 for color
    
    la $a0, 0x10008000      # Reset base address into $a0
    li $t2, 23
    li $t7, 233             # Column to start the right wall (256 - 23 = 233)
    li $t5, 4               # Bytes per pixel
    mul $t7, $t7, $t5       # Multiply by the number of bytes per pixel
    add $a0, $a0, $t7       # Add the offset to get the right wall starting address
    add $a0, $a0, 65536

    jal draw_vertical_wall_two  # Draw the right wall using the new $a0 and $t0 for color
    
    la $a0, 0x10008000   # Load base address into $a0
    li $t6, 496          # Play area height - wall height (in pixels)
    li $t2, 256
    li $t1, 16          # Thickness of the wall
    mul $t6, $t6, $t2    # Multiply the height offset by the width of the display
    mul $t6, $t6, 4    # Multiply by bytes per pixel to get the byte offset
    add $a0, $a0, $t6       # Add the offset to get the right wall starting address
    
    jal draw_horizontal_wall
    lw $ra, ra_storage_2
    jr $ra
                                                                                                        
clear_screen:
    la $a0, 0x10008000   
    li $t0, 0x00949453  
    li $t1, 512         
    li $t2, 256         
clear_row:
    move $t3, $t2
clear_column:
    sw $t0, 0($a0)      # Write word
    sw $t0, 4($a0)      # Write next word without incrementing $a0
    sw $t0, 8($a0)      # And so on...
    sw $t0, 12($a0)
    addiu $a0, $a0, 16  # Increment $a0 once after four writes
    addi $t3, $t3, -4   # Decrement loop counter by four
    bnez $t3, clear_column
    addi $t1, $t1, -1
    bnez $t1, clear_row
    jr $ra

draw_boundary:
    sw $ra, ra_storage
    la $a0, 0x10008000
    add $a0, $a0, 65536
    li $t0, 0x5C5B3E
    li $t2, 256
b_horizonta_loop:    
    sw $t0, 0($a0)
    add $a0, $a0, 4
    sub $t2, $t2, 1
    bnez $t2, b_horizonta_loop
    lw $ra, ra_storage
    jr $ra         

draw_walls:
    la $a0, 0x10008000       # Load base address into $a0
    add $a0, $a0, 65536
    li $t0, 0x5C5B3E    # Load wall color into $t0
    li $t1, 512  # Load play area height into $t1
    li $t2, 25     # Load wall width into $t2
         
    jal draw_vertical_wall   # Draw the left wall using current $a0 and $t0 for color
    
    la $a0, 0x10008000      # Reset base address into $a0
    li $t2, 23
    li $t7, 233             # Column to start the right wall (256 - 23 = 233)
    li $t5, 4               # Bytes per pixel
    mul $t7, $t7, $t5       # Multiply by the number of bytes per pixel
    add $a0, $a0, $t7       # Add the offset to get the right wall starting address
    add $a0, $a0, 65536

    jal draw_vertical_wall_two  # Draw the right wall using the new $a0 and $t0 for color
    
    la $a0, 0x10008000   # Load base address into $a0
    li $t6, 496          # Play area height - wall height (in pixels)
    li $t2, 256
    li $t1, 16          # Thickness of the wall
    mul $t6, $t6, $t2    # Multiply the height offset by the width of the display
    mul $t6, $t6, 4    # Multiply by bytes per pixel to get the byte offset
    add $a0, $a0, $t6       # Add the offset to get the right wall starting address
    
    jal draw_horizontal_wall
    j main_three
    
draw_horizontal_wall:
    # Assuming $a0 has the starting address for the bottom wall, 
    # $t0 has the color, $t1 has the height of the wall (thickness), 
    # and $t2 has the width of the wall (entire width of the screen).
    
    move $a1, $a0  # Move base address into $a1 to use as the drawing pointer
    move $t4, $t1  # Move height (thickness) into $t4, we will use $t4 as our row counter
    
horizontal_row_loop:
    move $t3, $t2  # Move wall width into $t3, we will use $t3 as our column counter
    
horizontal_column_loop:
    sw $t0, 0($a1)         # Write the wall color to the current pixel
    addiu $a1, $a1, 4      # Increment the drawing pointer to the next pixel
    addiu $t3, $t3, -1     # Decrement the column counter
    bnez $t3, horizontal_column_loop  # If we have not filled the entire width, continue
    
    # Update the drawing pointer to the next row
    li $t5, 1024 # The full width of the row in bytes (256 pixels * 4 bytes/pixel)
    addu $a1, $a1, $t5   # Move the drawing pointer to the start of the next row
    addiu $a1, $a1, -1024
    addiu $t4, $t4, -1   # Decrement the row counter
    bnez $t4, horizontal_row_loop     # If we have rows left to fill, continue         
   
       
draw_vertical_wall:
    move $a1, $a0         
    move $t4, $t1         

row_loop:
    move $t3, $t2         

column_loop:
    sw $t0, 0($a1)       
    addiu $a1, $a1, 4   
    addiu $t3, $t3, -1    
    bnez $t3, column_loop 

    addiu $a1, $a1, -100  
    addiu $a1, $a1, 1024
    addiu $t4, $t4, -1
    bnez $t4, row_loop

    jr $ra
        
draw_vertical_wall_two:
    move $a1, $a0         
    move $t4, $t1         
row_loop_two:
    move $t3, $t2         
column_loop_two:
    sw $t0, 0($a1)       
    addiu $a1, $a1, 4   
    addiu $t3, $t3, -1    
    bnez $t3, column_loop_two 

    addiu $a1, $a1, -92  
    addiu $a1, $a1, 1024
    addiu $t4, $t4, -1
    bnez $t4, row_loop_two
    jr $ra
        
            
draw_board:
   li $a0,0x10008000
   add $a0, $a0, 16384
   li $t0, 0x98A16C    
   li $5, 16
stage_one:
   jal draw_line2
stage_two:
   jal mission2 
mission2:
   li $a0,0x10008000    
   li $5, 16
stage_three:
   jal draw_line1
stage_four:      
   jal main_two      
stop_2:
    add $a0, $a0, 32768
    sub $5, $5, 1
    bnez $5, stage_three
    beqz $5, stage_four                    
draw_line1:
    move $a2, $a0
    li $t3, 7
    add $a2, $a2, 100
type_two_loop:
    jal draw_grid
    add $a2, $a2, 128
    sub $t3, $t3, 1
    bnez $t3, type_two_loop
    beqz $t3, stop_2           
stop:
    add $a0, $a0, 32768
    sub $5, $5, 1
    bnez $5, stage_one
    beqz $5, stage_two
                      
draw_line2:
    move $a2, $a0
    li $t3, 6
    add $a2, $a2, 164
type_one_loop:
    jal draw_grid
    add $a2, $a2, 128
    sub $t3, $t3, 1
    bnez $t3, type_one_loop
    beqz $t3, stop
                                    	                         	        
draw_grid:
    move $a3, $a2
    li $t2, 16
vertical_loop:    	
    li $t1, 16
horizontal_loop:
    sw $t0, 0($a3)
    add $a3, $a3, 4
    add $t1, $t1, -1
    bnez $t1, horizontal_loop
    
    add $a3, $a3, -64
    add $a3, $a3, 1024
    add $t2, $t2, -1
    bnez $t2, vertical_loop
    jr $ra      
                                                                                                    
