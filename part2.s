; At the beginning of the program, the 8-element array (13, 27, 10, 7, 22, 56, 28, 2) 
; must be placed in memory, and its base address must be loaded into register R7. 
; You are required to sort this array using the Merge Sort algorithm. 
; During the Merge Sort procedure, all partial merge results must be temporarily 
; stored in a temporary buffer on the stack.
; After the Merge Sort process is fully completed, the final sorted array must be 
; stored across registers R0–R7. Accordingly, the final register assignment becomes 
; R0=2, R1=7, R2=10, R3=13, R4=22, R5=27, R6=28, R7=56.

        AREA    MergeSort_Part2, CODE, READONLY
        THUMB
        ENTRY
        EXPORT  main

main    PROC
        ; Load base address of arrayB into R7
        LDR R7, =arrayB

        ; Initial call to my_MergeSort(p, r)
        ; p = 0, r = 7 for an 8-element array
        MOV R0, #0      ; p = 0
        MOV R1, #7      ; r = 7
        BL my_MergeSort

        ; After sorting, load the sorted array from memory into R0-R7
        LDR R0, [R7, #0]
        LDR R1, [R7, #4]
        LDR R2, [R7, #8]
        LDR R3, [R7, #12]
        LDR R4, [R7, #16]
        LDR R5, [R7, #20]
        LDR R6, [R7, #24]
        LDR R7, [R7, #28]

stop    B       stop             ; put breakpoint here to work 
        ENDP

my_MergeSort PROC
        ; my_MergeSort(p in R0, r in R1)
        ; R7 holds the base address of the array.
        PUSH {R0, R1, R4-R6, LR} ; Save p, r, callee-saved registers, and LR

        CMP R0, R1      ; Compare p and r
        BGE MergeSort_End ; if p >= r, return

        ; Calculate mid q = (p+r)/2
        ADD R2, R0, R1  ; p + r
        LSR R2, R2, #1  ; (p + r) / 2. R2 is now q.

        ; Save current p, r, and q for the merge step later
        PUSH {R0, R1, R2}

        ; Recursive call: my_MergeSort(p, q)
        ; R0 is already p. We need to set r = q.
        MOV R1, R2
        BL my_MergeSort

        ; Restore q, and original p, r
        POP {R0, R1, R2}
        PUSH {R0, R1, R2} ; Save them again for the next call

        ; Recursive call: my_MergeSort(q+1, r)
        ; R1 is already r. We need to set p = q+1.
        ADD R0, R2, #1
        BL my_MergeSort

        ; Restore q, and original p, r for the merge call
        POP {R0, R1, R2}

        ; Call my_Merge(p, q, r)
        ; p is in R0, q is in R2, r is in R1
        BL my_Merge

MergeSort_End
        POP {R0, R1, R4-R6, LR} ; Restore registers
        BX LR           ; Return
        ENDP

my_Merge PROC
        ; my_Merge(p in R0, q in R2, r in R1)
        ; R7 is array base address
        PUSH {R4-R7, LR} ; Save registers

        ; Allocate stack
        ; Locals: p(4), q(4), r(4), n1(4), n2(4), padding(8), base(4) -> 32 bytes
        ; L array: 4 words -> 16 bytes
        ; R array: 4 words -> 16 bytes
        ; Total: 64 bytes
        SUB SP, SP, #64

        ; Copy inputs to local frame
        ; Saved R4-R7, LR are at SP+64
        ; R0 (p), R1 (r), R2 (q) are in registers.
        ; R7 (base) is at SP+64+12 = SP+76.

        STR R0, [SP, #32] ; Store p
        STR R2, [SP, #36] ; Store q
        STR R1, [SP, #40] ; Store r
        LDR R3, [SP, #76] ; Load base from saved regs
        STR R3, [SP, #60] ; Store base locally

        ; Calculate n1 = q - p + 1
        LDR R0, [SP, #36] ; q
        LDR R1, [SP, #32] ; p
        SUB R3, R0, R1
        ADD R3, R3, #1
        STR R3, [SP, #44] ; n1

        ; Calculate n2 = r - q
        LDR R0, [SP, #40] ; r
        LDR R1, [SP, #36] ; q
        SUB R3, R0, R1
        STR R3, [SP, #48] ; n2

        ; Copy data to temp array L[]
        MOV R4, #0      ; i = 0
CopyL_Loop
        LDR R3, [SP, #44] ; n1
        CMP R4, R3
        BGE CopyR_Setup

        LDR R0, [SP, #32] ; p
        ADD R0, R0, R4    ; p+i
        LSL R0, R0, #2    ; (p+i)*4
        LDR R1, [SP, #60] ; base
        LDR R5, [R1, R0]  ; arr[p+i]

        MOV R0, SP
        ADD R0, R0, #16   ; L base (at SP+16)
        LSL R1, R4, #2    ; i*4
        STR R5, [R0, R1]

        ADD R4, R4, #1
        B CopyL_Loop

CopyR_Setup
        MOV R5, #0      ; j = 0
CopyR_Loop
        LDR R3, [SP, #48] ; n2
        CMP R5, R3
        BGE Merge_Setup

        LDR R0, [SP, #36] ; q
        ADD R0, R0, #1
        ADD R0, R0, R5    ; q+1+j
        LSL R0, R0, #2
        LDR R1, [SP, #60] ; base
        LDR R6, [R1, R0]  ; arr[q+1+j]

        MOV R0, SP        ; R base (at SP+0)
        LSL R1, R5, #2
        STR R6, [R0, R1]

        ADD R5, R5, #1
        B CopyR_Loop

Merge_Setup
        MOV R4, #0      ; i = 0
        MOV R5, #0      ; j = 0
        LDR R6, [SP, #32] ; k = p

Merge_Loop
        LDR R0, [SP, #44] ; n1
        CMP R4, R0
        BGE CopyRemR

        LDR R0, [SP, #48] ; n2
        CMP R5, R0
        BGE CopyRemL

        MOV R0, SP
        ADD R0, R0, #16
        LSL R1, R4, #2
        LDR R2, [R0, R1] ; L[i]

        MOV R0, SP
        LSL R1, R5, #2
        LDR R3, [R0, R1] ; R[j]

        CMP R2, R3
        BGT Else_Merge

        LDR R0, [SP, #60] ; base
        LSL R1, R6, #2
        STR R2, [R0, R1]
        ADD R4, R4, #1
        B After_If_Else

Else_Merge
        LDR R0, [SP, #60] ; base
        LSL R1, R6, #2
        STR R3, [R0, R1]
        ADD R5, R5, #1

After_If_Else
        ADD R6, R6, #1
        B Merge_Loop

CopyRemL
        LDR R0, [SP, #44] ; n1
        CMP R4, R0
        BGE Merge_Cleanup

        MOV R0, SP
        ADD R0, R0, #16
        LSL R1, R4, #2
        LDR R2, [R0, R1]

        LDR R0, [SP, #60] ; base
        LSL R1, R6, #2
        STR R2, [R0, R1]

        ADD R4, R4, #1
        ADD R6, R6, #1
        B CopyRemL

CopyRemR
        LDR R0, [SP, #48] ; n2
        CMP R5, R0
        BGE Merge_Cleanup

        MOV R0, SP
        LSL R1, R5, #2
        LDR R3, [R0, R1]

        LDR R0, [SP, #60] ; base
        LSL R1, R6, #2
        STR R3, [R0, R1]

        ADD R5, R5, #1
        ADD R6, R6, #1
        B CopyRemR

Merge_Cleanup
        ADD SP, SP, #64
        POP {R4-R7, PC}
        ENDP

        AREA    MyData, DATA, READWRITE
arrayB  DCD     13, 27, 10, 7, 22, 56, 28, 2

        END
