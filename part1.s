	AREA    MergeSort_M0, CODE, READONLY
        THUMB
        ENTRY
        EXPORT  main
        EXPORT  my_MergeSort
        EXPORT  my_Merge

main
    ; Initialize registers with the unsorted array elements
    LDR R0, =38 ; Load R0 with the first element
    LDR R1, =27 ; Load R1 with the second element
    LDR R2, =43 ; Load R2 with the third element
    LDR R3, =10 ; Load R4 with the fourth element
    LDR R4, =55 ; Load R5 with the fifth element

    ; Prepare for the first call to my_MergeSort
    ; We are sorting the entire array of 5 elements, from index 0 to 4.
    ; R0-R4 already hold the array.
    ; We need to pass the start and end indices.
    ; Let's use R5 for the start index (p) and R6 for the end index (r).
    MOVS R5, #0      ; p = 0
    MOVS R6, #4      ; r = 4

    ; We need to pass the base address of our "array" (the registers).
    ; Since we are using registers directly, we can use the stack to store
    ; and pass array elements. Let's push the initial array onto the stack.
    PUSH {R0-R4}    ; Save original array on the stack
    ADD R7, SP, #0   ; R7 will be our base pointer to the array on the stack

    ; Call my_MergeSort(array_base, p, r)
    ; R7 = base address, R5 = p, R6 = r
    BL my_MergeSort

    ; After sorting, the result should be in R0-R4.
    ; The sorted array is on the top of the stack. Let's pop it back.
    POP {R0-R4}     ; Pop sorted array into R0-R4
		
stop    B       stop ; put breakpoint here to work
        ENDP

my_MergeSort PROC
    ; my_MergeSort(array_base in R7, p in R5, r in R6)
    PUSH {LR}       ; Save link register
    PUSH {R5, R6}   ; Save p and r

    CMP R5, R6      ; Compare p and r
    BGE MergeSort_End ; if p >= r, return

    ; Calculate mid q = (p+r)/2
    MOVS R0, R5
    ADDS R0, R0, R6  ; p + r
    LSRS R0, R0, #1  ; (p + r) / 2. R0 is now q.

    ; Recursive call: my_MergeSort(arr, p, q)
    ; R5 is p, R0 is q. R6 needs to be q.
    PUSH {R0}       ; Save q
    MOVS R6, R0      ; r = q
    BL my_MergeSort
    POP {R0}        ; Restore q

    ; Recursive call: my_MergeSort(arr, q+1, r)
    ; R6 is r. R5 needs to be q+1.
    MOVS R5, R0
    ADDS R5, R5, #1  ; p = q + 1
    BL my_MergeSort

    ; Call my_Merge(arr, p, q, r)
    POP {R5, R6}    ; Restore original p and r for this call
    PUSH {R5, R6}   ; Save them again for merge
    ; R0 is q, R5 is p, R6 is r
    BL my_Merge

    POP {R5, R6}    ; Restore p and r
MergeSort_End
    POP {LR}        ; Restore link register
    BX LR           ; Return
    ENDP

my_Merge PROC
    ; my_Merge(array_base in R7, p in R5, q in R0, r in R6)
    PUSH {R4-R7, LR} ; Save registers
    MOV R4, SP       ; R4 is Frame Pointer

    ; Push arguments to stack to free registers and allow consistent access
    ; PUSH {R0, R5, R6} -> Stack: [R0(q), R5(p), R6(r)] (Lowest reg to lowest addr)
    ; Stack layout relative to R4:
    ; [R4, #-4]  = R6 (r)
    ; [R4, #-8]  = R5 (p)
    ; [R4, #-12] = R0 (q)
    PUSH {R0, R5, R6}

    ; Calculate n1 = q - p + 1
    MOVS R0, R4
    SUBS R0, #12
    LDR R0, [R0] ; q
    MOVS R1, R4
    SUBS R1, #8
    LDR R1, [R1]  ; p
    SUBS R2, R0, R1
    ADDS R2, R2, #1     ; n1

    ; Calculate n2 = r - q
    MOVS R0, R4
    SUBS R0, #4
    LDR R0, [R0]  ; r
    MOVS R1, R4
    SUBS R1, #12
    LDR R1, [R1] ; q
    SUBS R3, R0, R1     ; n2

    ; Push n1, n2
    ; PUSH {R2, R3} -> Stack: [R2(n1), R3(n2)]
    ; [R4, #-16] = R3 (n2)
    ; [R4, #-20] = R2 (n1)
    PUSH {R2, R3}

    ; Calculate size for L and R arrays: (n1 + n2) * 4
    MOVS R0, R2
    ADDS R0, R0, R3
    LSLS R0, R0, #2     ; Total bytes needed

    ; Allocate dynamic stack: SP = SP - R0
    MOV R1, SP
    SUBS R1, R1, R0
    MOV SP, R1         ; SP points to start of L

    ; L starts at SP
    ; R starts at SP + n1*4

    ; Copy data to temp array L[]
    MOVS R5, #0      ; i = 0
CopyL_Loop
    MOVS R2, R4
    SUBS R2, #20
    LDR R2, [R2] ; n1
    CMP R5, R2
    BGE CopyR_Setup

    MOVS R0, R4
    SUBS R0, #8
    LDR R0, [R0] ; p
    ADDS R0, R0, R5    ; p+i
    LSLS R0, R0, #2    ; (p+i)*4
    LDR R1, [R4, #12] ; base (R7 is at [R4, #12])
    LDR R3, [R1, R0]  ; arr[p+i]

    MOV R0, SP        ; L base
    LSLS R1, R5, #2    ; i*4
    STR R3, [R0, R1]

    ADDS R5, R5, #1
    B CopyL_Loop

CopyR_Setup
    MOVS R6, #0      ; j = 0
CopyR_Loop
    MOVS R2, R4
    SUBS R2, #16
    LDR R2, [R2] ; n2
    CMP R6, R2
    BGE Merge_Setup

    MOVS R0, R4
    SUBS R0, #12
    LDR R0, [R0] ; q
    ADDS R0, R0, #1
    ADDS R0, R0, R6    ; q+1+j
    LSLS R0, R0, #2
    LDR R1, [R4, #12] ; base
    LDR R3, [R1, R0]  ; arr[q+1+j]

    ; R base = SP + n1*4
    MOVS R0, R4
    SUBS R0, #20
    LDR R0, [R0] ; n1
    LSLS R0, R0, #2     ; n1*4
    ADD R0, SP     ; R base
    LSLS R1, R6, #2     ; j*4
    STR R3, [R0, R1]

    ADDS R6, R6, #1
    B CopyR_Loop

Merge_Setup
    MOVS R5, #0      ; i = 0
    MOVS R6, #0      ; j = 0
    MOVS R7, R4
    SUBS R7, #8
    LDR R7, [R7] ; k = p (Use R7 as k, we can reload base later)

Merge_Loop
    MOVS R0, R4
    SUBS R0, #20
    LDR R0, [R0] ; n1
    CMP R5, R0
    BGE CopyRemR

    MOVS R0, R4
    SUBS R0, #16
    LDR R0, [R0] ; n2
    CMP R6, R0
    BGE CopyRemL

    ; Load L[i]
    MOV R0, SP
    LSLS R1, R5, #2
    LDR R2, [R0, R1]

    ; Load R[j]
    MOVS R0, R4
    SUBS R0, #20
    LDR R0, [R0] ; n1
    LSLS R0, R0, #2
    ADD R0, SP     ; R base
    LSLS R1, R6, #2
    LDR R3, [R0, R1]

    CMP R2, R3
    BGT Else_Merge

    LDR R0, [R4, #12] ; base
    LSLS R1, R7, #2
    STR R2, [R0, R1]
    ADDS R5, R5, #1
    B After_If_Else

Else_Merge
    LDR R0, [R4, #12] ; base
    LSLS R1, R7, #2
    STR R3, [R0, R1]
    ADDS R6, R6, #1

After_If_Else
    ADDS R7, R7, #1
    B Merge_Loop

CopyRemL
    MOVS R0, R4
    SUBS R0, #20
    LDR R0, [R0] ; n1
    CMP R5, R0
    BGE Merge_Cleanup

    MOV R0, SP
    LSLS R1, R5, #2
    LDR R2, [R0, R1]

    LDR R0, [R4, #12] ; base
    LSLS R1, R7, #2
    STR R2, [R0, R1]

    ADDS R5, R5, #1
    ADDS R7, R7, #1
    B CopyRemL

CopyRemR
    LDR R0, [R4, #-16] ; n2
    CMP R6, R0
    BGE Merge_Cleanup

    LDR R0, [R4, #-20] ; n1
    LSL R0, R0, #2
    ADD R0, R0, SP     ; R base
    LSL R1, R6, #2
    LDR R3, [R0, R1]

    LDR R0, [R4, #12] ; base
    LSL R1, R7, #2
    STR R3, [R0, R1]

    ADDS R6, R6, #1
    ADDS R7, R7, #1
    B CopyRemR

Merge_Cleanup
    MOV SP, R4      ; Restore SP to initial state (deallocates everything)
    POP {R4-R7, PC}

        END