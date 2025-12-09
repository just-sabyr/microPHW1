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

	; ======================================
	;	Input AREA
	; ======================================
											; Assign input here
	LDR 	R0, 	#38
	LDR 	R1,		#27
	LDR 	R2, 	#43
	LDR 	R3,		#10
	LDR 	R4,		#55
	
	
	; ======================================	
	;	Load input to arr
	; ======================================
	LDR 	R5, 	=arr					; arr address can be passed using R5
	STM 	R5!,	{R0-R4}					; Writeback suffix: 		R5 = R4 (compulsory)


	; ======================================	
	;	Sorting	
	; ======================================
	LDR 	R0, 	#0						; R0 = 0 First Call to Recursive Mergesort, parameter setup; left
	LDR		R1,		#16						; R1 = 4												   ; right
	LDR 	R2,		#8						; R2 is 												   ; mid
	
	BLX		MergeSort						; LR = next line, PC = MergeSort; CALL MergeSort
	
	LDR		R0,		=arr
	LDR		R1, 	=arr+4
	LDR 	R2,		=arr+8
	LDR		R3,		=arr+12
	LDR		R4,		=arr+16

        ENDP
     
     
; ======================================	
; MergeSort Function
;	R0: 	left
;	R1:		right
; ======================================   
MergeSort
	CMP		R0,		R1						; left >= right
	BGT		MergeSort_Continue
	B		Mergesort_End


	; ======================================	
	;	End of MergeSort
	;	Post Process and return to the caller
	; ======================================
MergeSort_End
	BLX		LR
	
	
	; ======================================	
	;	Continue part of MergeSort
	;	Post Process and return to the caller
	; ======================================

MergeSort_Continue
	PUSH {LR}					; 
	PUSH {R0, R1, R2}			; Save current values of parameters; left, right, mid
	
	; Calculate mid
	SUBS R2, R1, R0							; mid = right - left
	ASRS R2, R2, #4							; mid = mid / 2
	ADDS R2, R2, R0							; mid = mid + left
	
	; Call MergeSort(left, mid)
	MOVS R1, R2								; right = mid
	BLX MergeSort							; 
	
	; Call MergeSort(mid+1, right)			
	POP {R0, R1, R2}						; Restore the parameters
	PUSH {R0, R1, R2}						; Save current values of parameters; left, right, mid
	ADDS R0, R2, #4							; Calculate mid+1 and save it to left
	BLX MergeSort							; 
	
	; Call Merge(arr, left, mid, right)		;
	POP {R0, R1, R2}						; Restore the parameters
	BLX Merge	
	

	POP {PC}								; Return to the caller, maybe MergeSort, maybe main
        
        

; ======================================	
;	Merge Function
;	R0 left
; 	R1 right
; 	R2 mid 

; 	R4 i
; 	R5 j
; 	R6 k

; R3 and R7 can be changed, the other registers are fixed
; 	R3			arr[i]
;   R7 			arr[k]
; 	also temp values, need to be loaded before using

; ======================================
Merge	
	LDR R4, R0								; i = left
	ADDS R5, R2, #4							; j = mid+1
	LDR R6, R0								; k = left

Compare_Merge	
	; ======================================	
	;   // Merge both subarrays into temp
    ;	while (i <= mid && j <= right) {
    ;		if (arr[i] <= arr[j]) {
    ;			temp[k++] = arr[i++];
    ;   	} else {
    ;       	temp[k++] = arr[j++];
    ;   	}
    ;	}
	; ======================================	

	; while loop (i <= mid && j <= right)
	CMP R4, R2								; i == mid
	BGT Left_Merge							; JMP i > mid 
	CMP R5, R1								; j == right
	BGT Left_Merge							; JMP j > right

	
	; if conidition (arr[i] <= arr[j]) 
	LDR R3, =arr							; pointer to start of arr
	ADDS R3, R3, R4							; pointer to [start of arr + i]
	LDR R3, [R3]							; load the value from flash memory
	; by this line R3 = arr[i]
	LDR R7, =arr							; pointer to start of arr
	ADDS R7, R7, R5							; pointer to [start of arr + j]
	LDR R7, [R7]
	; by this line R7 = arr[j]
	CMP R3, R7								; arr[i] == arr[j]
	BGT Insert_From_Right					; arr[i] > arr[j]: temp[k++] = arr[j++]
	B Insert_From_Left						; arr[i] <= arr[j]: temp[k++] = arr[i++]
Insert_From_Right
	LDR R3, =temp							; start of temp
	ADDS R3, R3, R6							; address of temp[k]
	STR R7, [R3]							; temp[k] = arr[j]
	ADDS R6, R6, #4							; k++
	ADDS R5, R5, #4							; j++
	B Compare_Merge							; next iteration 
Insert_From_Left
	LDR R7, =temp							; pointer to start of temp
	ADDS R7, R7, R6							; pointer to temp[k]
	STR R3, [R7]							; store arr[i] to temp[k]
	ADDS R6, R6, #4							; k++
	ADDS R4, R4, #4							; i++
	B Compare_Merge							; next iteration


Left_Merge
	; ======================================	
	;	// Copy remaining elements from left subarray
    ;	while (i <= mid) {
    ;   	temp[k++] = arr[i++];
    ;	}

	; R3 address of temp[k]
	; R7 value arr[i]
	; ======================================	
	CMP R4, R2								; i == mid
	BGT Right_Merge							; i > mid: right merge
	LDR R3, =temp							; pointer to start of arr
	ADDS R3, R3, R6							; address of temp[k]
	; by this line R3 = address of temp[k]
	LDR R7, =arr							; pointer to start of arr
	ADDS R7, R7, R4							; address of arr[i]
	LDR R7, [R7]							; value at arr[i]
	; by this line R7 = arr[i]
	STR R7, [R3]							; store arr[i] to temp[k]
	ADDS R6, R6, #4							; k++
	ADDS R4, R4, #4							; i++
	B Left_Merge							; next iteration

Right_Merge
	; ======================================	
	;   // Copy remaining elements from right subarray
    ;	while (j <= right) {
    ;    	temp[k++] = arr[j++];
    ;	}
	; ======================================	

	CMP R5, R1								; j == right
	BGT Remaining_Merge						; j > right
	LDR R3, =temp							; pointer to start of arr
	ADDS R3, R3, R6							; address of temp[k]
	; by this line R3 = address of temp[k]
	LDR R7, =arr							; pointer to start of arr
	ADDS R7, R7, R5							; address of arr[j]
	LDR R7, [R7]							; value at arr[j]
	; by this line R7 = arr[i]
	STR R7, [R3]							; store arr[i] to temp[k]
	ADDS R6, R6, #4							; k++
	ADDS R5, R5, #4							; j++
	B Right_Merge							; next iteration

Remaining_Merge
	; ======================================	
	;	// Copy sorted elements back to original array
    ;	for (i = left; i <= right; i++) {
    ;   	arr[i] = temp[i];
    ;	}
	;
	; this is the last section of our merge function, 
	; so overriding left, mid and right is ok
	;
	;	R0 left
	; 	R1 right
	; 	R2 mid 

	; 	R4 i
	; 	R5 j
	; 	R6 k
	;
	;
	; ======================================	

	LDR R3, =arr							; Address of arr
	LDR R7, =temp							; address of temp
	LDR R4, R0								; i (R4) = left
	CMP R4, R1								; i == right
	BGT	Merge_End							; i > right: end
	LDR R5, R3								; address of arr
	ADDS R5, R5, R4							; address of arr[i]
	LDR R6, R7								; address of temp
	ADDS R6, R6, R4							; address of temp[i]
	LDR R6, [R6]							; value of temp[i]
	STR R5, R6								; arr[i] = temp[i]
	B Remaining_Merge						; next iteration

Merge_End
	BX LR





; ======================================	
;	Read write memory on Flash
;	=arr:		R0
;	=arr+4: 	R1
;	...
;	=arr+4*4:	R4 
; ======================================
	
	AREA MergeSort_Data, DATA, READWRITE

	ALIGN 4
	arr		SPACE 20	; 5 elements, each four bytes	
	temp 	SPACE 20	; temporary array for merging
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
