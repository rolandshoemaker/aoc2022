#include "textflag.h"

// func day1(in []byte) (out uint8)
TEXT ·day1(SB),NOSPLIT,$0
    // Registers are all over the place, and could probably be cleaned up.
    // * R27 is used to compute and hold the result of atoi
    // * R26 is 10
    // * R12 is the current character
    // * R11 is '\n'
    // * R10 contains the index of the current highest
    // * R9 contains the current highest total
    // * R8 contains the current running total
    // * R7 contains the current index
    // * R6 is number of consumed characters, used to tell when we are done
    // * R5 is the cursor
    // * R1 is the length of the input string
    // * R0 is the base of the input string (this moves along with R5)
    MOVD in_base+0(FP), R0
    MOVD in_len+8(FP), R1

    // idk if we actually need to zero all these registers, but better safe
    // than sorry.
    MOVD ZR, R9
    MOVD ZR, R8
    MOVD ZR, R5
    MOVD $0x0a, R11 // '\n'
    MOVD $1, R7
    MOVD $1, R6
    MOVD $10, R26
    MOVD R0, R5

    // We iterate over the string, setting R5 to R0, then moving R5 forward until we
    // hit a newline character. Once we hit a newline we call atoi, which walks R0
    // forward to R5, calculating the value along the way. The result of atoi is
    // added to R8. If a line is consumed with no content, we check if the current
    // value of R8 is higher than the value in R9, and store it if so.

char_loop:
    MOVBU (R5), R12
    CMP R11, R12
    BEQ add_line
    B next_char
    RET

next_char:
    ADD $1, R5
    ADD $1, R6
    CMP R6, R1
    BLT done
    B char_loop

add_line:
    // if R0 == R5, it was just a newline
    CMP R5, R0
    BEQ finish_count
    B atoi

added:
    ADD R27, R8
    B next_line

next_line:
    // increment cursor, set R0 to R5
    ADD $1, R5
    ADD $1, R6 // this is duplicated in next_char
    CMP R6, R1
    BLT done
    MOVD R5, R0
    B char_loop

finish_count:
    // if R8 > R9, set R9 to R8, set R10 to R7
    // do we need to CMP twice? seems confusing
    CMP R9, R8
    CSEL LT, R9, R8, R9
    CMP R9, R8
    CSEL LT, R10, R7, R10
    MOVD ZR, R8
    ADD $1, R7
    B next_line

done:
    MOVD R10, out+24(FP)
    MOVD R9, out+32(FP)
    RET

atoi:
    MOVD ZR, R27 // clear R27 before we start
atoi_core:
    // walk R0 to R5, multiply R27 by ten, add (R0) to R27
    CMP R0, R5
    BEQ added // done
    MUL R26, R27
    MOVBU (R0), R12
    SUB $48, R12
    ADD R12, R27
    ADD $1, R0
    B atoi_core
