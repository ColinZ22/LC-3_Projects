.ORIG    x3000        ; starting address is x3000

;
; Counts the occurrences of each letter (A to Z) in an ASCII string
; terminated by a NUL character.  Lower case and upper case are
; counted together, and a count is also kept for all non-alphabetic
; characters (not counting the terminal NUL).
;
; The string is specified at the end of the program (STR_START)
;
; The resulting histogram (which will NOT be initialized in advance)
; should be stored starting at x3F00, with the non-alphabetic count
; at x3F00, and the count for each letter in x3F01 (A) through x3F1A (Z).
;
; table of register use in this part of the code
;    R0 holds a pointer to the histogram (x3F00)
;    R1 holds a pointer to the current position in the string
;       and as the loop count during histogram initialization
;    R2 holds the current character being counted
;       and is also used to point to the histogram entry
;    R3 holds the additive inverse of ASCII '@' (xFFC0)
;    R4 holds the difference between ASCII '@' and 'Z' (xFFE6)
;    R5 holds the difference between ASCII '@' and '`' (xFFE0)
;    R6 is used as a temporary register
;

    LD R0,HIST_ADDR          ; point R0 to the start of the histogram
   
    ; fill the histogram with zeroes
    AND R6,R6,#0        ; put a zero into R6
    LD R1,NUM_BINS        ; initialize loop count to 27
    ADD R2,R0,#0        ; copy start of histogram into R2

    ; loop to fill histogram starts here
HFLOOP    STR R6,R2,#0        ; write a zero into histogram
    ADD R2,R2,#1        ; point to next histogram entry
    ADD R1,R1,#-1        ; decrement loop count
    BRp HFLOOP        ; continue until loop count reaches zero

    ; initialize R1, R3, R4, and R5 from memory
    LD R3,NEG_AT        ; set R3 to additive inverse of ASCII '@'
    LD R4,AT_MIN_Z        ; set R4 to difference between ASCII '@' and 'Z'
    LD R5,AT_MIN_BQ        ; set R5 to difference between ASCII '@' and '`'
    LEA R1,STR_START        ; point R1 to start of string

    ; the counting loop starts here
COUNTLOOP
    LDR R2,R1,#0        ; read the next character from the string
    BRz PRINT_HIST        ; found the end of the string

    ADD R2,R2,R3        ; subtract '@' from the character
    BRp AT_LEAST_A        ; branch if > '@', i.e., >= 'A'
NON_ALPHA
    LDR R6,R0,#0        ; load the non-alpha count
    ADD R6,R6,#1        ; add one to it
    STR R6,R0,#0        ; store the new non-alpha count
    BRnzp GET_NEXT        ; branch to end of conditional structure
AT_LEAST_A
    ADD R6,R2,R4        ; compare with 'Z'
    BRp MORE_THAN_Z         ; branch if > 'Z'

ALPHA    ADD R2,R2,R0        ; point to correct histogram entry
    LDR R6,R2,#0        ; load the count
    ADD R6,R6,#1        ; add one to it
    STR R6,R2,#0        ; store the new count
    BRnzp GET_NEXT        ; branch to end of conditional structure

; subtracting as below yields the original character minus '`'
MORE_THAN_Z
    ADD R2,R2,R5        ; subtract '`' - '@' from the character
    BRnz NON_ALPHA        ; if <= '`', i.e., < 'a', go increment non-alpha
    ADD R6,R2,R4        ; compare with 'z'
    BRnz ALPHA        ; if <= 'z', go increment alpha count
    BRnzp NON_ALPHA        ; otherwise, go increment non-alpha

GET_NEXT
    ADD R1,R1,#1        ; point to next character in string
    BRnzp COUNTLOOP        ; go to start of counting loop


; table of register use in this part of the code
; R0 is used as bit counter and is also used for OUT Trap
; R1 is used as digit coutner in PRINT_HEX
; R2 stores the address of a histogram bin
; R3 stores the value of a histogram bin
; R4 stores Digit
; R5 is Print loop counter
; R6 is Temp
PRINT_HIST

    LD R2,HIST_ADDR       ; Start address of Histogram
    AND R5,R5,#0          ; Print loop counter init

PRINT_LOOP

    LD R0,AT              ; Point R0 to '@'
    ADD R0,R0,R5          ; Calculate which column header to print
    OUT                   ; Print Column Header
    LD R0,SPACE
    OUT                   ; Print Space 

    ADD R5,R5,#1
    LDR R3,R2,#0          ; Loads the value of a histogram into R0
    ADD R2,R2,#1          ; Increments histrogram pointer
PRINT_HEX
    AND R1,R1,#0        ; Digit counter
    ADD R1,R1,#4
DIGIT_COUNTER_LOOP
    ADD R1,R1,#-1
    BRn END_BIN
    AND R4,R4,#0        ; Digit
    AND R0,R0,#0        ; Bit counter
    ADD R0,R0,#4
BIT_COUNTER_LOOP
    ADD R0,R0,#-1
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
    ADD R0,R4,R6        ; ADD '0' to R3 then set to R0
    BR #3
ADD_A
    LD R6,A
    ADD R0,R4,R6        ; ADD 'A' to R3 then set to R0
    ADD R0,R0,#-10      ; Subtract 10

    OUT
    BR DIGIT_COUNTER_LOOP

END_BIN

    LD R6,NUM_BINS        ; Calculate the additive inverse of 27
    NOT R6,R6
    ADD R6,R6,#1          ; R6 is now the additive inverse of 27
    ADD R6,R5,R6          
    BRz DONE              ; Halt if all 27 bins have been printed

    LD R0,NEW_LINE
    OUT                   ; Print New Line Char
    BR PRINT_LOOP

; the data needed by the program
DONE
    HALT
ZERO
    .FILL x0030
A
    .FILL x0041
AT
    .FILL x0040
NEW_LINE
    .FILL x000A
SPACE
    .FILL x0020
NUM_BINS    
    .FILL #27    
NEG_AT
    .FILL xFFC0    ; the additive inverse of ASCII '@'
AT_MIN_Z    
    .FILL xFFE6    ; the difference between ASCII '@' and 'Z'
AT_MIN_BQ    
    .FILL xFFE0    ; the difference between ASCII '@' and '`'
HIST_ADDR    
    .FILL x3F00     

STR_START   
    .STRINGZ "This is a test of the counting frequency code. AbCd...WxYz. "

.END