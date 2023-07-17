// Include standard functions
#include <tcclib.h>
#include <string.h>
// MODULE 'Operations'.ex
// -------- --------
void *Operations_sum(int arity, char *types, ...){
if(arity == 2 && strcmp(types, "2_integer_integer") == 0){
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
void *Operations_sub(int arity, char *types, ...){
if(arity == 2 && strcmp(types, "2_integer_integer") == 0){
	va_list args;
	va_start(args, types);
	int a = va_arg(args, int);
	int b = va_arg(args, int);
	va_end(args);
;	int *__return__;
	__return__ = malloc(sizeof(int));
*__return__ = a-b;
	return __return__;
}
	return NULL;
}
void *Operations_mul(int arity, char *types, ...){
if(arity == 2 && strcmp(types, "2_integer_integer") == 0){
	va_list args;
	va_start(args, types);
	int a = va_arg(args, int);
	int b = va_arg(args, int);
	va_end(args);
;	int *__return__;
	__return__ = malloc(sizeof(int));
*__return__ = a*b;
	return __return__;
}
	return NULL;
}
void *Operations_div(int arity, char *types, ...){
if(arity == 2 && strcmp(types, "2_integer_integer") == 0){
	va_list args;
	va_start(args, types);
	int a = va_arg(args, int);
	int b = va_arg(args, int);
	va_end(args);
;	int *__return__;
	__return__ = malloc(sizeof(int));
*__return__ = a/b;
	return __return__;
}
	return NULL;
}
void *Operations_main(int arity, char *types, ...){
if(arity == 0 && strcmp(types, "0") == 0){
	va_list args;
	va_start(args, types);
	va_end(args);

int *a;
a = malloc(sizeof(int));
a = 	Operations_sum(2,"2_integer_integer",1, 2);

int *b;
b = malloc(sizeof(int));
b = 	Operations_sub(2,"2_integer_integer",2, 1);

int *c;
c = malloc(sizeof(int));
c = 	Operations_mul(2,"2_integer_integer",3, 2);

int *d;
d = malloc(sizeof(int));
d = 	Operations_div(2,"2_integer_integer",2, 2);
printf("%d %d %d %d\n", *a, *b, *c, *d);
printf("\n");
printf("*****************\n\n");
	return NULL;
}
	return NULL;
}
int main(int argc, char *argv[]) {
 Operations_main(0, "0");
return 0;
}
