# MIPS Assembly
# A is at address 0, N is at address 4
lw $0, 0($0)     # Load A into $0
lw $1, 4($0)     # Load N into $1
addi $1, $1, -1  # Decrement N by 1 to get the last index
lw $2, 0($0)     # Load the first element of the array into $2
addi $0, $0, 4   # Increment the address by 4 (size of int) to point to the next element
loop:
    lw $3, 0($0)    # Load the next element of the array into $3
    slt $4, $2, $3  # Set $4 to 1 if the previous element is less than the current element, else 0
    beq $4, $0, exit # If $4 is 0 (the array is not sorted), then branch to exit
    addi $0, $0, 4   # Increment the address by 4 (size of int) to point to the next element
    addi $1, $1, -1  # Decrement the loop counter
    bne $1, $0, loop # If the loop counter is not 0, then branch to loop
exit:
    sw $4, 8($0)     # Store the result at address 8


    # Machine Code
    lw $0, 0($0)     -> 100011_00000_01000_0000000000000000
    lw $1, 4($0)     -> 100011_00000_01001_0000000000000100
    addi $1, $1, -1 -> 001000_01001_01001_1111111111111111
    lw $2, 0($0)    -> 100011_01000_01010_0000000000000000
    addi $0, $0, 4  -> 001000_01000_01000_0000000000000100
    loop:
        lw $3, 0($0)    -> 100011_01000_01011_0000000000000000
        slt $4, $2, $3 -> 000000_01010_01011_01100_00000_101010
        beq $4, $0, exit -> 000100_01100_00000_0000000000001010
        addi $0, $0, 4  -> 001000_01000_01000_0000000000000100
        addi $1, $1, -1 -> 001000_01001_01001_1111111111111111
        bne $1, $0, loop -> 000101_01001_00000_1111111111111011
    exit:
        sw $4, 8($0)     -> 101011_00000_01100_0000000000001000