    AREA    MergeSort_M0, CODE, READONLY
        THUMB
        ENTRY
        ALIGN
        EXPORT  main
        EXPORT  my_MergeSort
        EXPORT  my_Merge

main
    ; Copy values from R0-R4 to memory
    LDR R5, =array          ; Base address of array
    LDR R0, [R5, #0]        ; Load array[0] into R0 (38 / 0x26)
    LDR R1, [R5, #4]        ; Load array[1] into R1 (27 / 0x1B)
    LDR R2, [R5, #8]        ; Load array[2] into R2 (43 / 0x2B)
    LDR R3, [R5, #12]       ; Load array[3] into R3 (10 / 0x0A)
    LDR R4, [R5, #16]       ; Load array[4] into R4 (55 / 0x37)

    ; Call my_MergeSort to sort the array
    MOVS R0, #0             ; Start index
    MOVS R1, #4             ; End index (4 elements)
    LDR R2, =array          ; Base address of array
    BL my_MergeSort         ; Sort the array

    ; Copy sorted values back to R0-R4
    LDR R0, [R5, #0]        ; Load sorted array[0] into R0 (10 / 0x0A)
    LDR R1, [R5, #4]        ; Load sorted array[1] into R1 (27 / 0x1B)
    LDR R2, [R5, #8]        ; Load sorted array[2] into R2 (38 / 0x26)
    LDR R3, [R5, #12]       ; Load sorted array[3] into R3 (43 / 0x2B)
    LDR R4, [R5, #16]       ; Load sorted array[4] into R4 (55 / 0x37)

stop    B       stop         ; Breakpoint to inspect sorted values
        ENDP

my_MergeSort PROC
; Recursive merge sort implementation
; Input: R0 = start index, R1 = end index, R2 = base address of array
; Uses: R3-R7 for temporary values
; Output: Sorted array in memory

    PUSH {R4-R7, LR}       ; Save registers and link register

    CMP R0, R1             ; Check if start >= end
    BGE merge_sort_done    ; If true, return

    ; Calculate mid = (start + end) / 2
    ADDS R3, R0, R1        ; R3 = start + end
    ASRS R3, R3, #1        ; R3 = mid

    ; Recursive call: my_MergeSort(start, mid)
    MOVS R4, R1            ; Save end index in R4
    MOVS R1, R3            ; Set end = mid
    BL my_MergeSort        ; Call my_MergeSort(start, mid)

    ; Recursive call: my_MergeSort(mid+1, end)
    MOVS R1, R4            ; Restore end index
    ADDS R0, R3, #1        ; Set start = mid + 1
    BL my_MergeSort        ; Call my_MergeSort(mid+1, end)

    ; Merge the two halves
    SUBS R0, R3, #1        ; Restore start index
    BL my_Merge            ; Call my_Merge(start, mid, end)

merge_sort_done
    POP {R4-R7, PC}        ; Restore registers and return
    ENDP

my_Merge PROC
; Merge two sorted subarrays
; Input: R0 = start index, R1 = mid index, R2 = end index, R3 = base address of array
; Uses: R4-R7 for temporary values
; Output: Merged array in memory

    PUSH {R4-R7, LR}       ; Save registers and link register
    SUB SP, SP, #8         ; Allocate 8 bytes on stack for temp storage

    ; Initialize pointers
    MOVS R4, R0            ; Left pointer = start
    ADDS R5, R1, #1        ; Right pointer = mid + 1
    MOVS R6, R0            ; Temp pointer = start

merge_loop
    ; Check if left pointer > mid
    CMP R4, R1
    BGT right_remain

    ; Check if right pointer > end
    CMP R5, R2
    BGT left_remain

    ; Compare elements at left and right pointers
    MOVS R7, R4            ; R7 = left index
    LSLS R7, R7, #2        ; R7 = left index * 4
    ADDS R7, R3, R7        ; R7 = address of left element
    LDR R7, [R7]           ; Load left element into R7
    STR R7, [SP, #0]       ; Save left element on stack
    
    MOVS R0, R5            ; R0 = right index
    LSLS R0, R0, #2        ; R0 = right index * 4
    ADDS R0, R3, R0        ; R0 = address of right element
    LDR R0, [R0]           ; Load right element into R0
    STR R0, [SP, #4]       ; Save right element on stack
    
    LDR R7, [SP, #0]       ; Load left element
    CMP R7, R0             ; Compare left and right
    BLE copy_left

    ; Copy right element to temp
    MOVS R7, R6            ; R7 = temp index
    LSLS R7, R7, #2        ; R7 = temp index * 4
    ADDS R7, R3, R7        ; R7 = address of temp
    LDR R0, [SP, #4]       ; Load right element
    STR R0, [R7]           ; Store right element at temp
    ADDS R5, R5, #1        ; Increment right pointer
    B next_merge

copy_left
    ; Copy left element to temp
    MOVS R0, R6            ; R0 = temp index
    LSLS R0, R0, #2        ; R0 = temp index * 4
    ADDS R0, R3, R0        ; R0 = address of temp
    LDR R7, [SP, #0]       ; Load left element
    STR R7, [R0]           ; Store left element at temp
    ADDS R4, R4, #1        ; Increment left pointer

next_merge
    ADDS R6, R6, #1        ; Increment temp pointer
    B merge_loop

left_remain
    ; Copy remaining left elements
    CMP R4, R1
    BGT merge_done
    MOVS R7, R4            ; R7 = left index
    LSLS R7, R7, #2        ; R7 = left index * 4
    ADDS R7, R3, R7        ; R7 = address of left element
    LDR R7, [R7]           ; Load left element
    
    MOVS R0, R6            ; R0 = temp index
    LSLS R0, R0, #2        ; R0 = temp index * 4
    ADDS R0, R3, R0        ; R0 = address of temp
    STR R7, [R0]           ; Store left element at temp
    
    ADDS R4, R4, #1
    ADDS R6, R6, #1
    B left_remain

right_remain
    ; Copy remaining right elements
    CMP R5, R2
    BGT merge_done
    MOVS R7, R5            ; R7 = right index
    LSLS R7, R7, #2        ; R7 = right index * 4
    ADDS R7, R3, R7        ; R7 = address of right element
    LDR R7, [R7]           ; Load right element
    
    MOVS R0, R6            ; R0 = temp index
    LSLS R0, R0, #2        ; R0 = temp index * 4
    ADDS R0, R3, R0        ; R0 = address of temp
    STR R7, [R0]           ; Store right element at temp
    
    ADDS R5, R5, #1
    ADDS R6, R6, #1
    B right_remain

merge_done
    ADDS SP, SP, #8         ; Deallocate stack space
    POP {R4-R7, PC}        ; Restore registers and return
    ENDP

        AREA    MergeSort_Data, DATA, READWRITE
array   DCD     38, 27, 43, 10, 55  ; Prepopulate array with unsorted values

        END