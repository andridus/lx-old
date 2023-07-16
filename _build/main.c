// Include standard functions
#include <tcclib.h>
#include <string.h>
// MODULE 'IO'.ex
// -------- --------
void *IO_puts(int arity, char *types, ...){
if(arity == 1 && strcmp(types, "1_string") == 0){
	va_list args;
	va_start(args, types);
	char *str = va_arg(args, char *);
	va_end(args);
printf("%s\n", str);
;	return NULL;
}
if(arity == 1 && strcmp(types, "1_int") == 0){
	va_list args;
	va_start(args, types);
	int integer = va_arg(args, int);
	va_end(args);
printf("%d\n", integer);
;	return NULL;
}
	return NULL;
}
void *IO_sum(int arity, char *types, ...){
if(arity == 2 && strcmp(types, "2_int_int") == 0){
	va_list args;
	va_start(args, types);
	int a = va_arg(args, int);
	int b = va_arg(args, int);
	va_end(args);
;	int *__return__;
	__return__ = malloc(sizeof(int));
*__return__ = a+b;
	return __return__;
}
	return NULL;
}
// MODULE 'HelloWorld'.ex
// -------- --------
void *HelloWorld_main(int arity, char *types, ...){
if(arity == 0 && strcmp(types, "0") == 0){
	va_list args;
	va_start(args, types);
	va_end(args);
	IO_puts(1,"1_string","Olá Novo mundo\n");
int *a;
a = malloc(sizeof(int));
a = 	IO_sum(2,"2_int_int",1, 2);	int *__return__;
	__return__ = malloc(sizeof(int));
__return__ = 	IO_puts(1,"1_int",*a);
	return __return__;
}
	return NULL;
}
int main(int argc, char *argv[]) {
 HelloWorld_main(0, "0");
return 0;
}
