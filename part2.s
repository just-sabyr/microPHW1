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
        PUSH {R0-R6, LR} ; Save registers

        ; n1 = q - p + 1
        SUB R3, R2, R0
        ADD R3, R3, #1  ; R3 = n1

        ; n2 = r - q
        SUB R4, R1, R2  ; R4 = n2

        ; Allocate space for two temporary arrays, L and R, on the stack.
        ; Total space needed is (n1+n2)*4 bytes. Max is 8*4=32
        SUB SP, SP, #32 ; Allocate space for temp buffer
        MOV R5, SP      ; R5 = base address of L
        ADD R6, SP, #16 ; R6 = base address of R (assuming max n1=4)

        ; Copy data to temp array L
        ; for (i = 0; i < n1; i++) L[i] = arr[p + i];
        MOV R8, #0      ; i = 0
CopyL_Loop
        CMP R8, R3      ; i < n1?
        BGE CopyR_Setup
        ADD R9, R0, R8  ; p + i
        LDR R10, [R7, R9, LSL #2] ; arr[p+i]
        STR R10, [R5, R8, LSL #2] ; L[i] = arr[p+i]
        ADD R8, R8, #1
        B CopyL_Loop

CopyR_Setup
        ; Copy data to temp array R
        ; for (j = 0; j < n2; j++) R[j] = arr[q + 1 + j];
        MOV R8, #0      ; j = 0
CopyR_Loop
        CMP R8, R4      ; j < n2?
        BGE Merge_Setup
        ADD R9, R2, #1  ; q + 1
        ADD R9, R9, R8  ; q + 1 + j
        LDR R10, [R7, R9, LSL #2] ; arr[q+1+j]
        STR R10, [R6, R8, LSL #2] ; R[j] = arr[q+1+j]
        ADD R8, R8, #1
        B CopyR_Loop

Merge_Setup
        ; Merge the temp arrays back into arr[p..r]
        MOV R8, #0      ; i = 0 (L index)
        MOV R9, #0      ; j = 0 (R index)
        MOV R10, R0     ; k = p (main array index)
Merge_Loop
        CMP R8, R3      ; i >= n1?
        BGE CopyRemR    ; If so, copy remaining of R
        CMP R9, R4      ; j >= n2?
        BGE CopyRemL    ; If so, copy remaining of L

        LDR R11, [R5, R8, LSL #2] ; L[i]
        LDR R12, [R6, R9, LSL #2] ; R[j]

        CMP R11, R12
        BGT Else_Merge
        ; if (L[i] <= R[j])
        STR R11, [R7, R10, LSL #2] ; arr[k] = L[i]
        ADD R8, R8, #1  ; i++
        B After_If_Else
Else_Merge
        STR R12, [R7, R10, LSL #2] ; arr[k] = R[j]
        ADD R9, R9, #1  ; j++
After_If_Else
        ADD R10, R10, #1 ; k++
        B Merge_Loop

CopyRemL
        ; Copy remaining elements of L[] if any
        CMP R8, R3
        BGE Merge_Cleanup
        LDR R11, [R5, R8, LSL #2]
        STR R11, [R7, R10, LSL #2]
        ADD R8, R8, #1
        ADD R10, R10, #1
        B CopyRemL

CopyRemR
        ; Copy remaining elements of R[] if any
        CMP R9, R4
        BGE Merge_Cleanup
        LDR R12, [R6, R9, LSL #2]
        STR R12, [R7, R10, LSL #2]
        ADD R9, R9, #1
        ADD R10, R10, #1
        B CopyRemR

Merge_Cleanup
        ADD SP, SP, #32 ; Deallocate temp arrays
        POP {R0-R6, LR} ; Restore registers
        BX LR           ; Return
        ENDP

        AREA    MyData, DATA, READWRITE
arrayB  DCD     13, 27, 10, 7, 22, 56, 28, 2

        END
