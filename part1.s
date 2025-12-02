    AREA    MergeSort_M0, CODE, READONLY
        THUMB
        ENTRY
        ALIGN
        EXPORT  main
        EXPORT  my_MergeSort
        EXPORT  my_Merge

; Main entry point
; Input: R0-R4 contain unsorted values
; Output: R0-R4 contain sorted values
main    PROC
        ; Push callee-saved registers
        PUSH    {R4-R7, LR}
        
        ; Allocate space on stack for array (5 elements + temp space)
        ; We need: original array (5), left half (3), right half (2), merged (5) = 15 bytes
        SUBS    SP, SP, #20
        
        ; Save input values to stack
        MOVS    R4, SP          ; R4 = base pointer to array
        STRB    R0, [R4, #0]    ; array[0] = R0 (38)
        STRB    R1, [R4, #1]    ; array[1] = R1 (27)
        STRB    R2, [R4, #2]    ; array[2] = R2 (43)
        STRB    R3, [R4, #3]    ; array[3] = R3 (10)
        STRB    R3, [R4, #4]    ; Temp: save R3 for R4
        LDRB    R0, [SP, #20]   ; Load R4 from original stack (offset by 20)
        STRB    R0, [R4, #4]    ; array[4] = R4 (55)
        
        ; Call merge sort
        MOVS    R0, R4          ; R0 = array pointer
        MOVS    R1, #0          ; R1 = left index (0)
        MOVS    R2, #4          ; R2 = right index (4)
        BL      my_MergeSort
        
        ; Load sorted values back to R0-R4
        LDRB    R0, [R4, #0]
        LDRB    R1, [R4, #1]
        LDRB    R2, [R4, #2]
        LDRB    R3, [R4, #3]
        LDRB    R4, [R4, #4]
        
        ; Deallocate stack
        ADDS    SP, SP, #20
        
        ; Pop registers and return
        POP     {R4-R7, PC}
        ENDP

; Recursive Merge Sort
; R0 = array pointer
; R1 = left index
; R2 = right index
; Uses stack for temporary storage
my_MergeSort PROC
        PUSH    {R4-R7, LR}
        
        ; Base case: if left >= right, return
        CMP     R1, R2
        BCS     merge_sort_return
        
        ; Calculate mid = (left + right) / 2
        MOVS    R3, R1
        ADDS    R3, R2
        LSRS    R3, #1          ; R3 = mid
        
        ; Save left and right for later
        MOVS    R4, R1          ; R4 = left
        MOVS    R5, R2          ; R5 = right
        MOVS    R6, R0          ; R6 = array pointer
        MOVS    R7, R3          ; R7 = mid
        
        ; Sort left half: my_MergeSort(array, left, mid)
        MOVS    R1, R4
        MOVS    R2, R7
        BL      my_MergeSort
        
        ; Sort right half: my_MergeSort(array, mid+1, right)
        MOVS    R0, R6
        MOVS    R1, R7
        ADDS    R1, #1
        MOVS    R2, R5
        BL      my_MergeSort
        
        ; Merge: my_Merge(array, left, mid, right)
        MOVS    R0, R6
        MOVS    R1, R4
        MOVS    R2, R7
        MOVS    R3, R5
        BL      my_Merge
        
merge_sort_return
        POP     {R4-R7, PC}
        ENDP

; Merge function
; R0 = array pointer
; R1 = left index
; R2 = mid index
; R3 = right index
my_Merge PROC
        PUSH    {R4-R7, LR}
        SUBS    SP, SP, #10     ; Temporary space for merged array
        
        MOVS    R4, R0          ; R4 = array pointer
        MOVS    R5, R1          ; R5 = left index
        MOVS    R6, R2          ; R6 = mid index
        MOVS    R7, R3          ; R7 = right index
        
        ; R0 will track merged array index
        ; Create temp array on stack
        MOVS    R0, SP          ; R0 = temp array pointer
        
        ; Initialize left_idx = left, right_idx = mid+1
        MOVS    R1, R5          ; R1 = left_idx
        MOVS    R2, R6
        ADDS    R2, #1          ; R2 = right_idx (mid+1)
        MOVS    R3, #0          ; R3 = merged index
        
merge_loop
        ; Check if left half is exhausted
        CMP     R1, R6
        BHI     copy_right_half
        
        ; Check if right half is exhausted
        CMP     R2, R7
        BHI     copy_left_half
        
        ; Compare array[left_idx] and array[right_idx]
        LDRB    R4, [R4, R1]    ; Load array[left_idx]
        LDRB    R5, [R4, R2]    ; Load array[right_idx]
        
        MOV     R4, #0
        LDRB    R4, [SP, #12]   ; Reload R4 (array pointer from stack save)
        LDRB    R5, [R4, R1]    ; array[left_idx]
        LDRB    R6, [R4, R2]    ; array[right_idx]
        
        CMP     R5, R6
        BLS     merge_take_left
        
        ; Take from right
        STRB    R6, [R0, R3]    ; temp[merged_idx] = array[right_idx]
        ADDS    R2, #1          ; right_idx++
        B       merge_next
        
merge_take_left
        STRB    R5, [R0, R3]    ; temp[merged_idx] = array[left_idx]
        ADDS    R1, #1          ; left_idx++
        
merge_next
        ADDS    R3, #1          ; merged_idx++
        B       merge_loop
        
copy_left_half
        ; Copy remaining from left half
        CMP     R1, R6
        BHI     copy_right_half
        LDRB    R4, [R4, R1]
        MOVS    R4, #0
        LDRB    R4, [SP, #12]
        LDRB    R5, [R4, R1]
        STRB    R5, [R0, R3]
        ADDS    R1, #1
        ADDS    R3, #1
        B       copy_left_half
        
copy_right_half
        ; Copy remaining from right half
        CMP     R2, R7
        BHI     copy_done
        MOVS    R4, #0
        LDRB    R4, [SP, #12]
        LDRB    R5, [R4, R2]
        STRB    R5, [R0, R3]
        ADDS    R2, #1
        ADDS    R3, #1
        B       copy_right_half
        
copy_done
        ; Copy temp array back to original array
        MOVS    R0, SP          ; R0 = temp array pointer
        MOVS    R4, #0
        LDRB    R4, [SP, #12]   ; R4 = original array pointer
        MOVS    R1, #0          ; index = 0
        MOVS    R3, #0          ; merged_idx = 0
        
copy_back_loop
        CMP     R1, R7
        BHI     merge_done
        LDRB    R2, [R0, R3]
        STRB    R2, [R4, R1]
        ADDS    R1, #1
        ADDS    R3, #1
        B       copy_back_loop
        
merge_done
        ADDS    SP, SP, #10
        POP     {R4-R7, PC}
        ENDP

stop    B       stop         ; Breakpoint to inspect sorted values
        END

; Data area for array storage
    AREA    MergeSort_Data, DATA, READWRITE
        ALIGN
array   SPACE   5             ; Space for 5 unsorted bytes
sorted  SPACE   5             ; Space for 5 sorted bytes
        END
