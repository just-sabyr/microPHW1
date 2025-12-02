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
    MOV R5, #0      ; p = 0
    MOV R6, #4      ; r = 4

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
    ADD R0, R5, R6  ; p + r
    LSR R0, R0, #1  ; (p + r) / 2. R0 is now q.

    ; Recursive call: my_MergeSort(arr, p, q)
    ; R5 is p, R0 is q. R6 needs to be q.
    PUSH {R0}       ; Save q
    MOV R6, R0      ; r = q
    BL my_MergeSort
    POP {R0}        ; Restore q

    ; Recursive call: my_MergeSort(arr, q+1, r)
    ; R6 is r. R5 needs to be q+1.
    ADD R5, R0, #1  ; p = q + 1
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
    PUSH {LR}       ; Save link register
    PUSH {R0-R4}    ; Save registers that will be used as temps

    ; int n1 = q - p + 1;
    SUB R1, R0, R5  ; q - p
    ADD R1, R1, #1  ; n1 = q - p + 1

    ; int n2 = r - q;
    SUB R2, R6, R0  ; n2 = r - q

    ; Create temp arrays L and R on the stack
    ; We need space for n1+n2 integers. Max is 5.
    ; Let's reserve space for 5 integers for L and 5 for R for simplicity.
    SUB SP, SP, #20 ; Allocate space for L (5 words)
    MOV R3, SP      ; R3 points to L
    SUB SP, SP, #20 ; Allocate space for R (5 words)
    MOV R4, SP      ; R4 points to R

    ; Copy data to temp arrays L[] and R[]
    ; for (int i = 0; i < n1; i++) L[i] = arr[p + i];
    MOV R8, #0      ; i = 0
CopyL_Loop
    CMP R8, R1      ; i < n1?
    BGE CopyR_Setup ; if i >= n1, go to next part
    ADD R9, R5, R8  ; p + i
    LDR R10, [R7, R9, LSL #2] ; arr[p+i]
    STR R10, [R3, R8, LSL #2] ; L[i] = arr[p+i]
    ADD R8, R8, #1  ; i++
    B CopyL_Loop

CopyR_Setup
    ; for (int j = 0; j < n2; j++) R[j] = arr[q + 1 + j];
    MOV R8, #0      ; j = 0
CopyR_Loop
    CMP R8, R2      ; j < n2?
    BGE Merge_Setup ; if j >= n2, go to merge
    ADD R9, R0, #1  ; q + 1
    ADD R9, R9, R8  ; q + 1 + j
    LDR R10, [R7, R9, LSL #2] ; arr[q+1+j]
    STR R10, [R4, R8, LSL #2] ; R[j] = arr[q+1+j]
    ADD R8, R8, #1  ; j++
    B CopyR_Loop

Merge_Setup
    ; Merge the temp arrays back into arr[p..r]
    MOV R8, #0      ; i = 0
    MOV R9, #0      ; j = 0
    MOV R10, R5     ; k = p
Merge_Loop
    CMP R8, R1      ; i < n1?
    BGE CopyRemR    ; if i >= n1, copy remaining of R
    CMP R9, R2      ; j < n2?
    BGE CopyRemL    ; if j >= n2, copy remaining of L

    LDR R11, [R3, R8, LSL #2] ; L[i]
    LDR R12, [R4, R9, LSL #2] ; R[j]

    CMP R11, R12    ; L[i] <= R[j]?
    BGT Else_Merge  ; if L[i] > R[j], go to else
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
    ; Copy remaining elements of L[]
    CMP R8, R1      ; i < n1?
    BGE Merge_Cleanup ; if i >= n1, we are done
    LDR R11, [R3, R8, LSL #2] ; L[i]
    STR R11, [R7, R10, LSL #2] ; arr[k] = L[i]
    ADD R8, R8, #1  ; i++
    ADD R10, R10, #1 ; k++
    B CopyRemL

CopyRemR
    ; Copy remaining elements of R[]
    CMP R9, R2      ; j < n2?
    BGE Merge_Cleanup ; if j >= n2, we are done
    LDR R12, [R4, R9, LSL #2] ; R[j]
    STR R12, [R7, R10, LSL #2] ; arr[k] = R[j]
    ADD R9, R9, #1  ; j++
    ADD R10, R10, #1 ; k++
    B CopyRemR

Merge_Cleanup
    ADD SP, SP, #40 ; Deallocate temp arrays L and R
    POP {R0-R4}     ; Restore registers
    POP {LR}        ; Restore link register
    BX LR           ; Return

        END