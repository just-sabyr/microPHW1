AREA    MergeSort_M0, CODE, READONLY
        THUMB
        ENTRY
        ALIGN
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

		
		
stop    B       stop ; put breakpoint here to work
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
    MOV R4, R1             ; Save end index in R4
    MOV R1, R3             ; Set end = mid
    BL my_MergeSort        ; Call my_MergeSort(start, mid)

    ; Recursive call: my_MergeSort(mid+1, end)
    MOV R1, R4             ; Restore end index
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

    ; Initialize pointers
    MOV R4, R0             ; Left pointer = start
    ADDS R5, R1, #1        ; Right pointer = mid + 1
    MOV R6, R0             ; Temp pointer = start

merge_loop
    ; Check if left pointer > mid
    CMP R4, R1
    BGT right_remain

    ; Check if right pointer > end
    CMP R5, R2
    BGT left_remain

    ; Compare elements at left and right pointers
    LDR R7, [R3, R4, LSL #2] ; Load left element
    LDR R0, [R3, R5, LSL #2] ; Load right element
    CMP R7, R0
    BLE copy_left

    ; Copy right element to temp
    STR R0, [R3, R6, LSL #2]
    ADDS R5, R5, #1        ; Increment right pointer
    B next_merge

copy_left
    ; Copy left element to temp
    STR R7, [R3, R6, LSL #2]
    ADDS R4, R4, #1        ; Increment left pointer

next_merge
    ADDS R6, R6, #1        ; Increment temp pointer
    B merge_loop

left_remain
    ; Copy remaining left elements
    CMP R4, R1
    BGT merge_done
    LDR R7, [R3, R4, LSL #2]
    STR R7, [R3, R6, LSL #2]
    ADDS R4, R4, #1
    ADDS R6, R6, #1
    B left_remain

right_remain
    ; Copy remaining right elements
    CMP R5, R2
    BGT merge_done
    LDR R0, [R3, R5, LSL #2]
    STR R0, [R3, R6, LSL #2]
    ADDS R5, R5, #1
    ADDS R6, R6, #1
    B right_remain

merge_done
    POP {R4-R7, PC}        ; Restore registers and return
    ENDP