.ORIG x3000
    
    AND R0,R0,#0        ; Print Reg
    AND R6,R6,#0        ; Temp Reg
    AND R1,R1,#0        ; Digit counter
    ADD R1,R1,#4
DIGIT_COUNTER_LOOP
    ADD R1,R1,#-1
    BRn DONE
    AND R4,R4,#0        ; Digit
    AND R2,R2,#0        ; Bit counter
    ADD R2,R2,#4
BIT_COUNTER_LOOP
    ADD R2,R2,#-1
    BRn CONVERT
    ADD R4,R4,R4        ; Shift Digit Left
    AND R3,R3,R3
    BRn ADD_ONE
ADD_ZERO
    ADD R4,R4,#0
    BR #1
ADD_ONE
    ADD R4,R4,#1
    
    ADD R3,R3,R3        ; Shift R3 Left
    BR BIT_COUNTER_LOOP
CONVERT
    ADD R6, R4, #-9
    BRp ADD_A
    LD R6,ZERO
    ADD R0,R4,R6        ; ADD '0' to R4, Store in R0
    BR #3
ADD_A
    LD R6,A
    ADD R0,R4,R6        ; ADD 'A' to R4, Store in R0
    ADD R0,R0,#-10      ; Subtract 10

    OUT
    BR DIGIT_COUNTER_LOOP

DONE
    HALT
ZERO
    .FILL x0030
A
    .FILL x0041

.END