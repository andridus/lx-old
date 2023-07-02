// Include standard functions
#include <stdio.h>
// MODULE 'IO'.ex
// -------- --------
void IO_puts(char str[]) {
printf(str);
}
// MODULE 'HelloWorld'.ex
// -------- --------
void HelloWorld_main() {
IO_puts("Olá Novo mundo\n");
}
int main(int argc, char *argv[]) {
 HelloWorld_main();
return 0;
}
