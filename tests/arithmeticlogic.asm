# Test 1: ALU y Lógica
# Cubre: add, sub (con negativos), and, or (con bits altos), slt, slti, addi (inmediato negativo), li, move, $zero.

.data
    msg_add: .asciiz "add: "
    msg_sub: .asciiz "\nsub: "
    msg_and: .asciiz "\nand: "
    msg_or:  .asciiz "\nor:  "
    msg_slt: .asciiz "\nslt: "
    msg_slti:.asciiz "\nslti:"
    msg_addi:.asciiz "\naddi:"
    msg_move:.asciiz "\nmove:"
    msg_zero:.asciiz "\nzero:"

.text
main:
    # 1. add (positivos y negativos)
    li $t0, 5
    li $t1, -3
    add $t2, $t0, $t1      # 5 + (-3) = 2

    la $a0, msg_add
    li $v0, 4
    syscall
    move $a0, $t2
    jal print_hex

    # 2. sub (con operandos negativos)
    li $t0, -10
    li $t1, -4
    sub $t2, $t0, $t1      # -10 - (-4) = -6 (FFFFFFFA)

    la $a0, msg_sub
    li $v0, 4
    syscall
    move $a0, $t2
    jal print_hex

    # 3. and (unos en 16 bits altos)
    lui $t0, 0xFFFF        # FFFF0000
    ori $t1, $zero, 0x0F0F # 00000F0F
    and $t2, $t0, $t1      # 00000F00

    la $a0, msg_and
    li $v0, 4
    syscall
    move $a0, $t2
    jal print_hex

    # 4. or (unos en 16 bits altos)
    lui $t0, 0xFFFF        # FFFF0000
    ori $t1, $zero, 0x0F0F # 00000F0F
    or $t2, $t0, $t1       # FFFF0F0F

    la $a0, msg_or
    li $v0, 4
    syscall
    move $a0, $t2
    jal print_hex

    # 5. slt (negativo vs positivo, distinto resultado signed/unsigned)
    li $t0, -1             # FFFFFFFF
    li $t1, 1
    slt $t2, $t0, $t1      # -1 < 1 = 1

    la $a0, msg_slt
    li $v0, 4
    syscall
    move $a0, $t2
    jal print_hex

    # 6. slti (resultado 0 con negativo)
    li $t0, 0
    slti $t2, $t0, -1      # 0 < -1 = 0

    la $a0, msg_slti
    li $v0, 4
    syscall
    move $a0, $t2
    jal print_hex

    # 7. addi (inmediato negativo)
    li $t0, 10
    addi $t2, $t0, -15     # 10 - 15 = -5 (FFFFFFFB)

    la $a0, msg_addi
    li $v0, 4
    syscall
    move $a0, $t2
    jal print_hex

    # 8. move (usa addu por dentro) y escritura en $zero
    li $t0, 0x12345678
    move $t2, $t0          # t2 = 12345678
    add $zero, $t0, $t1    # Intento de escritura en $zero (debe fallar silenciosamente)

    la $a0, msg_move
    li $v0, 4
    syscall
    move $a0, $t2
    jal print_hex

    la $a0, msg_zero
    li $v0, 4
    syscall
    move $a0, $zero        # Debe imprimir 00000000
    jal print_hex

    # Terminar
    li $v0, 10
    syscall

# ---------------------------------------------------------
# Subrutina print_hex: Imprime $a0 en hexadecimal (8 dígitos)
# ---------------------------------------------------------
print_hex:
    li $t0, 8              # Contador de 8 dígitos
    move $t1, $a0          # Copia del valor
print_loop:
    srl $t2, $t1, 28       # Extrae los 4 bits más altos
    blt $t2, 10, print_num
    addi $t2, $t2, 55      # 'A' = 65. 65 - 10 = 55
    j print_char
print_num:
    addi $t2, $t2, 48      # '0' = 48
print_char:
    move $a0, $t2
    li $v0, 11
    syscall
    sll $t1, $t1, 4        # Desplaza para el siguiente nibble
    addi $t0, $t0, -1
    bne $t0, $zero, print_loop
    jr $ra