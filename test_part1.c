#include <stdio.h>

// Global variable to hold the test result.
// 1 for pass, 0 for fail.
volatile int test1_result = 0;

// Externally defined assembly function from part1.s
extern void main_part1(void);

// Expected sorted values for Part 1
const int expected_part1[] = {10, 27, 38, 43, 55};

// This function will be called from assembly to check the results.
void check_results_part1(int r0, int r1, int r2, int r3, int r4) {
    if (r0 == expected_part1[0] &&
        r1 == expected_part1[1] &&
        r2 == expected_part1[2] &&
        r3 == expected_part1[3] &&
        r4 == expected_part1[4]) {
        test1_result = 1; // Pass
    } else {
        test1_result = 0; // Fail
    }
}

int main(void) {
    // Run the assembly code for Part 1
    main_part1();

    // The test result is now in test1_result.
    // You can inspect 'test1_result' in the Keil debugger's watch window.
    // It will be 1 if the test passed, and 0 otherwise.

    while(1); // Loop forever
}
