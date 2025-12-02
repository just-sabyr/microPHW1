#include <stdio.h>

// Global variable to hold the test result.
// 1 for pass, 0 for fail.
volatile int test2_result = 0;

// Externally defined assembly function and data from part2.s
// We refer to 'main' from part2.s as 'main_part2' in C to avoid naming conflicts.
extern void main_part2(void); 
// This is the array defined in part2.s
extern int arrayB[]; 

// Expected sorted values for Part 2
const int expected_part2[] = {2, 7, 10, 13, 22, 27, 28, 56};

int main(void) {
    // Run the assembly code for Part 2. This will sort 'arrayB' in place.
    main_part2();

    // After main_part2 runs, the arrayB in memory should be sorted.
    // Now, we verify the result.
    int pass = 1; // Assume pass unless a mismatch is found
    for (int i = 0; i < 8; i++) {
        if (arrayB[i] != expected_part2[i]) {
            pass = 0; // Mismatch found, so test fails
            break;
        }
    }
    test2_result = pass;

    // The test result is now in test2_result.
    // You can inspect 'test2_result' in the Keil debugger's watch window.
    // It will be 1 if the test passed, and 0 otherwise.

    while(1); // Loop forever
}
