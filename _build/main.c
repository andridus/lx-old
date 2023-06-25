// Include standard functions
#include <stdio.h>

// MODULE 'C'.ex
// -------- --------
int C_sum() {
return 1;
}
// MODULE 'B'.ex
// -------- --------
f32 B_one() {
C_sum();
return 2.0;
}
// MODULE 'A'.ex
// -------- --------
f32 A_main() {
return B_one();
}
int A_other() {
return C_sum();
}
int main(int argc, char *argv[]) {
 A_main();
return 0;
}
