# Flip 7 solo version | PUT ALL THESE COMMENTS BELOW FOR THE ACTUAL ASSIGNMENT REQUIREMENTS
# Input and detailed instructions appear in the Run I/O console.
# Original 94-card deck; reshuffled at the start of each solo round.
# Special actions target the only player. First to 200 points wins.

.data
.align 2
deck:           .space 376          # 94 words
seen:           .space 52           # seen[0..12]
hand:           .space 28           # at most 7 unique numbers
deck_pos:       .word 0
hand_count:     .word 0
total_score:    .word 0
round_no:       .word 0
number_sum:     .word 0
plus_sum:       .word 0
times_two:      .word 0
second_chance:  .word 0
round_score:    .word 0
round_state:    .word 0             # 0 active, 1 banked, 2 bust, 3 flip 7
forced_left:    .word 0
freeze_later:   .word 0
input_buf:      .space 32
number_buf:     .space 16

welcome: .asciiz "\n=== FLIP 7: MARS SOLO VERSION ===\nReach 200 points by banking across rounds.\nThe 94-card deck has one 0, and N copies of number N (1-12).\nA repeated number busts your round; seven different numbers bank +15.\nModifiers: +2/+4/+6/+8/+10, and x2 on number points only.\nSecond Chance cancels one repeated number. Freeze banks your round.\nFlip Three makes you draw 3 more cards. In this solo version, all\nactions target you and the deck is reshuffled each round.\nUse the console for choices; numbered cards appear in Bitmap Display.\n\n"
round_msg:    .asciiz "\n--- ROUND "
newline:      .asciiz "\n"
first_msg:    .asciiz "First card: "
draw_msg:     .asciiz "Drew: "
number_msg:   .asciiz "number "
plus_msg:     .asciiz "+"
x2_msg:       .asciiz "x2: number points are doubled.\n"
sc_msg:       .asciiz "Second Chance: your next duplicate is discarded.\n"
sc_extra:     .asciiz "Extra Second Chance discarded (limit one).\n"
saved_msg:    .asciiz "Duplicate discarded using Second Chance!\n"
bust_msg:     .asciiz "Duplicate number! BUST: 0 points this round.\n"
freeze_msg:   .asciiz "Freeze: you must bank this round.\n"
flip3_msg:    .asciiz "Flip Three: three forced draws!\n"
forced_msg:   .asciiz "  Forced draw: "
flip7_msg:    .asciiz "FLIP 7! Seven unique numbers: +15 bonus.\n"
empty_msg:    .asciiz "Deck exhausted: banking your points.\n"
prompt:       .asciiz "Choose 1=Hit, 2=Bank, 3=Quit: "
again_prompt: .asciiz "Choose 1=Next round, 2=Quit: "
bad_input:    .asciiz "Invalid choice. Type the listed digit and press Enter.\n"
bank_msg:     .asciiz "You banked "
point_msg:    .asciiz " points. Total: "
zero_msg:     .asciiz "Round score: 0. Total: "
win_msg:      .asciiz "\nYOU WIN! You reached at least 200 points.\n"
bye_msg:      .asciiz "Thanks for playing!\n"

title_text:   .asciiz "FLIP 7"
total_text:   .asciiz "TOTAL"
round_text:   .asciiz "ROUND"
hand_text:    .asciiz "HAND"
plus_text:    .asciiz "PLUS"
x2_text:      .asciiz "X2"
sc_text:      .asciiz "SC"
active_text:  .asciiz "1 HIT 2 BANK 3 QUIT"
banked_text:  .asciiz "BANKED"
busted_text:  .asciiz "BUST"
seven_text:   .asciiz "FLIP 7 BONUS"
frozen_text:  .asciiz "FROZEN"
win_text:     .asciiz "YOU WIN"

# Each glyph is seven five-bit rows, highest used bit at the left.
font_chars: .asciiz "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789+!:"
font_rows:
 .byte 14,17,17,31,17,17,17    # A
 .byte 30,17,17,30,17,17,30    # B
 .byte 14,17,16,16,16,17,14    # C
 .byte 30,17,17,17,17,17,30    # D
 .byte 31,16,16,30,16,16,31    # E
 .byte 31,16,16,30,16,16,16    # F
 .byte 14,17,16,23,17,17,14    # G
 .byte 17,17,17,31,17,17,17    # H
 .byte 31,4,4,4,4,4,31         # I
 .byte 7,2,2,2,18,18,12        # J
 .byte 17,18,20,24,20,18,17    # K
 .byte 16,16,16,16,16,16,31    # L
 .byte 17,27,21,21,17,17,17    # M
 .byte 17,25,21,19,17,17,17    # N
 .byte 14,17,17,17,17,17,14    # O
 .byte 30,17,17,30,16,16,16    # P
 .byte 14,17,17,17,21,18,13    # Q
 .byte 30,17,17,30,20,18,17    # R
 .byte 15,16,16,14,1,1,30     # S
 .byte 31,4,4,4,4,4,4          # T
 .byte 17,17,17,17,17,17,14    # U
 .byte 17,17,17,17,17,10,4     # V
 .byte 17,17,17,21,21,21,10    # W
 .byte 17,17,10,4,10,17,17     # X
 .byte 17,17,10,4,4,4,4        # Y
 .byte 31,1,2,4,8,16,31        # Z
 .byte 14,17,19,21,25,17,14    # 0
 .byte 4,12,4,4,4,4,14         # 1
 .byte 14,17,1,2,4,8,31        # 2
 .byte 30,1,1,14,1,1,30        # 3
 .byte 2,6,10,18,31,2,2        # 4
 .byte 31,16,16,30,1,1,30      # 5
 .byte 14,16,16,30,17,17,14    # 6
 .byte 31,1,2,4,8,8,8          # 7
 .byte 14,17,17,14,17,17,14    # 8
 .byte 14,17,17,15,1,1,14     # 9
 .byte 0,4,4,31,4,4,0          # +
 .byte 4,4,4,4,4,0,4           # !
 .byte 0,4,4,0,4,4,0           # :
.align 2

.text
.globl main
main:
    li   $s7, 0x10008000       # Bitmap Display base
    li   $v0, 30               # MARS system time
    syscall
    move $a1, $a0              # seed random stream 0
    li   $a0, 0
    li   $v0, 40
    syscall
    la   $a0, welcome
    jal  print_string

new_round:
    jal  reset_round
    jal  build_deck
    jal  shuffle_deck
    lw   $t0, round_no
    addiu $t0, $t0, 1
    sw   $t0, round_no
    la   $a0, round_msg
    jal  print_string
    lw   $a0, round_no
    jal  print_int
    la   $a0, newline
    jal  print_string
    jal  render_screen
    la   $a0, first_msg
    jal  print_string
    jal  draw_one
    jal  resolve_forced
    jal  render_screen

turn_loop:
    lw   $t0, round_state
    bnez $t0, finish_round
    la   $a0, prompt
    jal  print_string
    jal  read_choice
    li   $t0, 1
    beq  $v0, $t0, choose_hit
    li   $t0, 2
    beq  $v0, $t0, choose_bank
    li   $t0, 3
    beq  $v0, $t0, quit_game
    la   $a0, bad_input
    jal  print_string
    j    turn_loop

choose_hit:
    la   $a0, draw_msg
    jal  print_string
    jal  draw_one
    jal  resolve_forced
    jal  render_screen
    j    turn_loop

choose_bank:
    li   $t0, 1
    sw   $t0, round_state
    jal  render_screen

finish_round:
    jal  calculate_score
    lw   $t0, round_state
    li   $t1, 2
    beq  $t0, $t1, round_lost
    lw   $t0, round_score
    lw   $t1, total_score
    addu $t1, $t1, $t0
    sw   $t1, total_score
    la   $a0, bank_msg
    jal  print_string
    lw   $a0, round_score
    jal  print_int
    la   $a0, point_msg
    jal  print_string
    lw   $a0, total_score
    jal  print_int
    la   $a0, newline
    jal  print_string
    jal  render_screen
    j    check_win
round_lost:
    la   $a0, zero_msg
    jal  print_string
    lw   $a0, total_score
    jal  print_int
    la   $a0, newline
    jal  print_string
check_win:
    lw   $t0, total_score
    slti $t1, $t0, 200
    beqz $t1, winner
next_prompt:
    la   $a0, again_prompt
    jal  print_string
    jal  read_choice
    li   $t0, 1
    beq  $v0, $t0, new_round
    li   $t0, 2
    beq  $v0, $t0, quit_game
    la   $a0, bad_input
    jal  print_string
    j    next_prompt
winner:
    la   $a0, win_msg
    jal  print_string
    jal  render_screen
quit_game:
    la   $a0, bye_msg
    jal  print_string
    li   $v0, 10
    syscall

# Syscall helpers. read_choice accepts EXACTLY one digit and Enter.
print_string:
    li   $v0, 4
    syscall
    jr   $ra
print_int:
    li   $v0, 1
    syscall
    jr   $ra
read_choice:
    la   $a0, input_buf
    li   $a1, 32
    li   $v0, 8
    syscall
    la   $t0, input_buf
    lbu  $t1, 0($t0)
    lbu  $t2, 1($t0)
    li   $v0, -1
    li   $t3, 10              # newline or NUL after digit
    beq  $t2, $t3, choice_single
    bnez $t2, choice_done
choice_single:
    addiu $t1, $t1, -48
    sltiu $t3, $t1, 10
    beqz $t3, choice_done
    move $v0, $t1
choice_done:
    jr   $ra

reset_round:
    sw   $zero, deck_pos
    sw   $zero, hand_count
    sw   $zero, number_sum
    sw   $zero, plus_sum
    sw   $zero, times_two
    sw   $zero, second_chance
    sw   $zero, round_score
    sw   $zero, round_state
    sw   $zero, forced_left
    sw   $zero, freeze_later
    la   $t0, seen
    li   $t1, 13
reset_seen:
    sw   $zero, 0($t0)
    addiu $t0, $t0, 4
    addiu $t1, $t1, -1
    bnez $t1, reset_seen
    jr   $ra

# Card IDs: 0..12 numbers; 13..17 +2..+10; 18 x2;
# 19 Freeze, 20 Flip Three, 21 Second Chance.
build_deck:
    la   $t0, deck
    sw   $zero, 0($t0)      # one zero
    addiu $t0, $t0, 4
    li   $t1, 1             # number
build_value:
    li   $t2, 0             # copies
build_copies:
    sw   $t1, 0($t0)
    addiu $t0, $t0, 4
    addiu $t2, $t2, 1
    bne  $t2, $t1, build_copies
    addiu $t1, $t1, 1
    slti $t3, $t1, 13
    bnez $t3, build_value
    li   $t1, 13
build_modifiers:
    sw   $t1, 0($t0)
    addiu $t0, $t0, 4
    addiu $t1, $t1, 1
    slti $t3, $t1, 19
    bnez $t3, build_modifiers
    li   $t1, 19
build_actions:
    li   $t2, 3
build_action_copies:
    sw   $t1, 0($t0)
    addiu $t0, $t0, 4
    addiu $t2, $t2, -1
    bnez $t2, build_action_copies
    addiu $t1, $t1, 1
    slti $t3, $t1, 22
    bnez $t3, build_actions
    jr   $ra

# Fisher-Yates: each bounded MARS RNG call returns 0 <= a0 < i+1.
shuffle_deck:
    li   $t4, 93
shuffle_loop:
    blez $t4, shuffle_done
    li   $a0, 0
    addiu $a1, $t4, 1
    li   $v0, 42
    syscall
    la   $t0, deck
    sll  $t1, $t4, 2
    addu $t1, $t1, $t0
    sll  $t2, $a0, 2
    addu $t2, $t2, $t0
    lw   $t3, 0($t1)
    lw   $t5, 0($t2)
    sw   $t5, 0($t1)
    sw   $t3, 0($t2)
    addiu $t4, $t4, -1
    j    shuffle_loop
shuffle_done:
    jr   $ra

# Draw a physical card without replacement and resolve its effect.
draw_one:
    addiu $sp, $sp, -8
    sw   $ra, 4($sp)
    sw   $s0, 0($sp)
    lw   $t0, deck_pos
    slti $t1, $t0, 94
    bnez $t1, card_available
    la   $a0, empty_msg
    jal  print_string
    li   $t0, 1
    sw   $t0, round_state
    j    draw_return
card_available:
    la   $t1, deck
    sll  $t2, $t0, 2
    addu $t1, $t1, $t2
    lw   $s0, 0($t1)
    addiu $t0, $t0, 1
    sw   $t0, deck_pos
    slti $t0, $s0, 13
    bnez $t0, drawn_number
    slti $t0, $s0, 18
    bnez $t0, drawn_plus
    li   $t0, 18
    beq  $s0, $t0, drawn_x2
    li   $t0, 19
    beq  $s0, $t0, drawn_freeze
    li   $t0, 20
    beq  $s0, $t0, drawn_flip3
    j    drawn_chance

drawn_number:
    la   $a0, number_msg
    jal  print_string
    move $a0, $s0
    jal  print_int
    la   $a0, newline
    jal  print_string
    la   $t0, seen
    sll  $t1, $s0, 2
    addu $t0, $t0, $t1
    lw   $t1, 0($t0)
    bnez $t1, repeated_number
    li   $t1, 1
    sw   $t1, 0($t0)
    lw   $t1, hand_count
    la   $t0, hand
    sll  $t2, $t1, 2
    addu $t0, $t0, $t2
    sw   $s0, 0($t0)
    addiu $t1, $t1, 1
    sw   $t1, hand_count
    lw   $t2, number_sum
    addu $t2, $t2, $s0
    sw   $t2, number_sum
    li   $t0, 7
    bne  $t1, $t0, draw_return
    li   $t0, 3
    sw   $t0, round_state
    sw   $zero, forced_left
    la   $a0, flip7_msg
    jal  print_string
    j    draw_return
repeated_number:
    lw   $t0, second_chance
    beqz $t0, really_bust
    sw   $zero, second_chance
    la   $a0, saved_msg
    jal  print_string
    j    draw_return
really_bust:
    li   $t0, 2
    sw   $t0, round_state
    sw   $zero, forced_left
    la   $a0, bust_msg
    jal  print_string
    j    draw_return

drawn_plus:
    la   $a0, plus_msg
    jal  print_string
    addiu $s0, $s0, -12
    sll  $s0, $s0, 1
    move $a0, $s0
    jal  print_int
    la   $a0, newline
    jal  print_string
    lw   $t0, plus_sum
    addu $t0, $t0, $s0
    sw   $t0, plus_sum
    j    draw_return
drawn_x2:
    li   $t0, 1
    sw   $t0, times_two
    la   $a0, x2_msg
    jal  print_string
    j    draw_return
drawn_freeze:
    la   $a0, freeze_msg
    jal  print_string
    lw   $t0, forced_left
    bnez $t0, defer_freeze
    li   $t0, 1
    sw   $t0, round_state
    j    draw_return
defer_freeze:
    li   $t0, 1
    sw   $t0, freeze_later
    j    draw_return
drawn_flip3:
    la   $a0, flip3_msg
    jal  print_string
    lw   $t0, forced_left
    addiu $t0, $t0, 3
    sw   $t0, forced_left
    j    draw_return
drawn_chance:
    lw   $t0, second_chance
    beqz $t0, keep_chance
    la   $a0, sc_extra
    jal  print_string
    j    draw_return
keep_chance:
    li   $t0, 1
    sw   $t0, second_chance
    la   $a0, sc_msg
    jal  print_string
draw_return:
    lw   $s0, 0($sp)
    lw   $ra, 4($sp)
    addiu $sp, $sp, 8
    jr   $ra

# Additional Flip Three cards add three to this queue. Freeze is
# resolved after queued forced draws, unless a bust/Flip 7 ends first.
resolve_forced:
    addiu $sp, $sp, -4
    sw   $ra, 0($sp)
forced_loop:
    lw   $t0, round_state
    bnez $t0, forced_done
    lw   $t0, forced_left
    blez $t0, forced_done
    addiu $t0, $t0, -1
    sw   $t0, forced_left
    jal  render_screen
    la   $a0, forced_msg
    jal  print_string
    jal  draw_one
    j    forced_loop
forced_done:
    lw   $t0, freeze_later
    beqz $t0, resolve_return
    lw   $t1, round_state
    bnez $t1, resolve_return
    li   $t1, 1
    sw   $t1, round_state
resolve_return:
    lw   $ra, 0($sp)
    addiu $sp, $sp, 4
    jr   $ra

# Scoring order: (number sum * x2 if present) + plus cards + Flip 7 bonus.
calculate_score:
    lw   $t0, round_state
    li   $t1, 2
    beq  $t0, $t1, score_zero
    lw   $t0, number_sum
    lw   $t1, times_two
    beqz $t1, score_add
    sll  $t0, $t0, 1
score_add:
    lw   $t1, plus_sum
    addu $t0, $t0, $t1
    lw   $t1, round_state
    li   $t2, 3
    bne  $t1, $t2, score_save
    addiu $t0, $t0, 15
score_save:
    sw   $t0, round_score
    jr   $ra
score_zero:
    sw   $zero, round_score
    jr   $ra

# Bitmap dimensions 128x64 *logical pixels* (each pixel is 4x4 on screen).
# Drawing is by sw to video memory, not by the MARS text display.
clear_screen:
    move $t0, $s7
    li   $t1, 8192
    li   $t2, 0x00101520
clear_loop:
    sw   $t2, 0($t0)
    addiu $t0, $t0, 4
    addiu $t1, $t1, -1
    bnez $t1, clear_loop
    jr   $ra

# fill_rect(x=a0, y=a1, width=a2, height=a3, color=v1)
fill_rect:
    move $t0, $a1
    addu $t1, $a1, $a3
rect_row:
    slt  $t2, $t0, $t1
    beqz $t2, rect_done
    move $t3, $a0
    addu $t4, $a0, $a2
rect_col:
    slt  $t2, $t3, $t4
    beqz $t2, next_rect_row
    sll  $t5, $t0, 7
    addu $t5, $t5, $t3
    sll  $t5, $t5, 2
    addu $t5, $t5, $s7
    sw   $v1, 0($t5)
    addiu $t3, $t3, 1
    j    rect_col
next_rect_row:
    addiu $t0, $t0, 1
    j    rect_row
rect_done:
    jr   $ra

# draw_char(character=a0, x=a1, y=a2, color=a3)
draw_char:
    addiu $sp, $sp, -28
    sw   $s0, 0($sp)
    sw   $s1, 4($sp)
    sw   $s2, 8($sp)
    sw   $s3, 12($sp)
    sw   $s4, 16($sp)
    sw   $s5, 20($sp)
    sw   $ra, 24($sp)
    move $s1, $a1
    move $s2, $a2
    move $s3, $a3
    la   $t0, font_chars
    li   $t1, 0
find_char:
    lbu  $t2, 0($t0)
    beqz $t2, char_done      # space or unsupported character
    beq  $t2, $a0, char_found
    addiu $t0, $t0, 1
    addiu $t1, $t1, 1
    j    find_char
char_found:
    li   $t2, 7
    multu $t1, $t2
    mflo $t1
    la   $s0, font_rows
    addu $s0, $s0, $t1
    li   $s4, 0
glyph_row:
    li   $t0, 7
    beq  $s4, $t0, char_done
    lbu  $s5, 0($s0)
    li   $t0, 0
glyph_col:
    li   $t1, 5
    beq  $t0, $t1, glyph_next_row
    li   $t1, 16
    srlv $t1, $t1, $t0
    and  $t1, $t1, $s5
    beqz $t1, glyph_skip
    addu $t2, $s2, $s4
    sll  $t2, $t2, 7
    addu $t2, $t2, $s1
    addu $t2, $t2, $t0
    sll  $t2, $t2, 2
    addu $t2, $t2, $s7
    sw   $s3, 0($t2)
glyph_skip:
    addiu $t0, $t0, 1
    j    glyph_col
glyph_next_row:
    addiu $s0, $s0, 1
    addiu $s4, $s4, 1
    j    glyph_row
char_done:
    lw   $s0, 0($sp)
    lw   $s1, 4($sp)
    lw   $s2, 8($sp)
    lw   $s3, 12($sp)
    lw   $s4, 16($sp)
    lw   $s5, 20($sp)
    lw   $ra, 24($sp)
    addiu $sp, $sp, 28
    jr   $ra

# draw_text(pointer=a0, x=a1, y=a2, color=a3), 6 pixels/character.
draw_text:
    addiu $sp, $sp, -20
    sw   $s0, 0($sp)
    sw   $s1, 4($sp)
    sw   $s2, 8($sp)
    sw   $s3, 12($sp)
    sw   $ra, 16($sp)
    move $s0, $a0
    move $s1, $a1
    move $s2, $a2
    move $s3, $a3
text_loop:
    lbu  $a0, 0($s0)
    beqz $a0, text_done
    move $a1, $s1
    move $a2, $s2
    move $a3, $s3
    jal  draw_char
    addiu $s0, $s0, 1
    addiu $s1, $s1, 6
    j    text_loop
text_done:
    lw   $s0, 0($sp)
    lw   $s1, 4($sp)
    lw   $s2, 8($sp)
    lw   $s3, 12($sp)
    lw   $ra, 16($sp)
    addiu $sp, $sp, 20
    jr   $ra

# draw_number(nonnegative value=a0, x=a1, y=a2, color=a3)
draw_number:
    addiu $sp, $sp, -24
    sw   $s0, 0($sp)
    sw   $s1, 4($sp)
    sw   $s2, 8($sp)
    sw   $s3, 12($sp)
    sw   $s4, 16($sp)
    sw   $ra, 20($sp)
    move $s0, $a0
    move $s1, $a1
    move $s2, $a2
    move $s3, $a3
    la   $s4, number_buf
    addiu $s4, $s4, 15
    sb   $zero, 0($s4)
number_digit:
    li   $t0, 10
    divu $s0, $t0
    mfhi $t1
    mflo $s0
    addiu $t1, $t1, 48
    addiu $s4, $s4, -1
    sb   $t1, 0($s4)
    bnez $s0, number_digit
    move $a0, $s4
    move $a1, $s1
    move $a2, $s2
    move $a3, $s3
    jal  draw_text
    lw   $s0, 0($sp)
    lw   $s1, 4($sp)
    lw   $s2, 8($sp)
    lw   $s3, 12($sp)
    lw   $s4, 16($sp)
    lw   $ra, 20($sp)
    addiu $sp, $sp, 24
    jr   $ra

render_screen:
    addiu $sp, $sp, -16
    sw   $ra, 12($sp)
    sw   $s0, 8($sp)
    sw   $s1, 4($sp)
    sw   $s2, 0($sp)
    jal  calculate_score
    jal  clear_screen
    la   $a0, title_text
    li   $a1, 4
    li   $a2, 2
    li   $a3, 0x00FFD166
    jal  draw_text
    la   $a0, total_text
    li   $a1, 60
    li   $a2, 2
    li   $a3, 0x00B9E9FF
    jal  draw_text
    lw   $a0, total_score
    li   $a1, 94
    li   $a2, 2
    li   $a3, 0x00FFFFFF
    jal  draw_number
    la   $a0, round_text
    li   $a1, 4
    li   $a2, 12
    li   $a3, 0x00B9E9FF
    jal  draw_text
    lw   $a0, round_no
    li   $a1, 40
    li   $a2, 12
    li   $a3, 0x00FFFFFF
    jal  draw_number
    la   $a0, hand_text
    li   $a1, 70
    li   $a2, 12
    li   $a3, 0x00B9E9FF
    jal  draw_text
    lw   $a0, round_score
    li   $a1, 100
    li   $a2, 12
    li   $a3, 0x00FFFFFF
    jal  draw_number

    li   $s0, 0
render_cards:
    lw   $t0, hand_count
    beq  $s0, $t0, cards_done
    li   $t0, 18
    multu $s0, $t0
    mflo $s1
    addiu $s1, $s1, 2
    move $a0, $s1
    li   $a1, 23
    li   $a2, 16
    li   $a3, 23
    li   $v1, 0x00E2F3FF
    jal  fill_rect
    addiu $a0, $s1, 1
    li   $a1, 24
    li   $a2, 14
    li   $a3, 21
    li   $v1, 0x00213760
    jal  fill_rect
    la   $t0, hand
    sll  $t1, $s0, 2
    addu $t0, $t0, $t1
    lw   $s2, 0($t0)
    move $a0, $s2
    slti $t0, $s2, 10
    beqz $t0, card_two_digits
    addiu $a1, $s1, 5
    j    card_number
card_two_digits:
    addiu $a1, $s1, 2
card_number:
    li   $a2, 30
    li   $a3, 0x00FFFFFF
    jal  draw_number
    addiu $s0, $s0, 1
    j    render_cards
cards_done:
    la   $a0, plus_text
    li   $a1, 4
    li   $a2, 48
    li   $a3, 0x00A9D8B9
    jal  draw_text
    lw   $a0, plus_sum
    li   $a1, 34
    li   $a2, 48
    li   $a3, 0x00FFFFFF
    jal  draw_number
    la   $a0, x2_text
    li   $a1, 62
    li   $a2, 48
    li   $a3, 0x00A9D8B9
    jal  draw_text
    lw   $a0, times_two
    li   $a1, 77
    li   $a2, 48
    li   $a3, 0x00FFFFFF
    jal  draw_number
    la   $a0, sc_text
    li   $a1, 94
    li   $a2, 48
    li   $a3, 0x00A9D8B9
    jal  draw_text
    lw   $a0, second_chance
    li   $a1, 112
    li   $a2, 48
    li   $a3, 0x00FFFFFF
    jal  draw_number

    lw   $t0, total_score
    slti $t1, $t0, 200
    beqz $t1, show_win
    lw   $t0, round_state
    beqz $t0, show_active
    li   $t1, 1
    beq  $t0, $t1, show_banked
    li   $t1, 2
    beq  $t0, $t1, show_bust
    la   $a0, seven_text
    j    show_message
show_active:
    la   $a0, active_text
    j    show_message
show_banked:
    lw   $t0, freeze_later
    beqz $t0, normal_bank
    la   $a0, frozen_text
    j    show_message
normal_bank:
    la   $a0, banked_text
    j    show_message
show_bust:
    la   $a0, busted_text
    j    show_message
show_win:
    la   $a0, win_text
show_message:
    li   $a1, 4
    li   $a2, 57
    li   $a3, 0x00FFD166
    jal  draw_text
    lw   $s0, 8($sp)
    lw   $s1, 4($sp)
    lw   $s2, 0($sp)
    lw   $ra, 12($sp)
    addiu $sp, $sp, 16
    jr   $ra
