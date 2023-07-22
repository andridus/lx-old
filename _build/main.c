// Include standard functions
#include <tcclib.h>
#include <string.h>

		typedef enum { NIL, ATOM, FLOAT, INTEGER, STRING, VOID } LxTypes;
		void * lx_print(void ** str, LxTypes tp) {
			if (tp == ATOM) { printf("%s",str);}
			else if (tp == INTEGER) { printf("%d",(*(int *) str));}
			else if (tp == STRING) { printf("%s", str);}
			else if (tp == FLOAT) { printf("%lf", (*(double *) str));}
			else if (tp == VOID) { printf("nil");}
			else { printf("can't print object");}
		}
// MODULE 'Animals'.ex
// -------- --------
typedef enum  {
	enum_animals_kind_DOG=1,
	enum_animals_kind_CAT,
	enum_animals_kind_RABBIT,
} enum_animals_kind;
void *Animals_print(int arity, char *types, ...){
if(arity == 1 && strcmp(types, "1_string") == 0){
	va_list args;
	va_start(args, types);
	char *a = va_arg(args, char *);
	va_end(args);
printf(a);
	return NULL;
}
if(arity == 1 && strcmp(types, "1_enum_animals_kind") == 0){
	va_list args;
	va_start(args, types);
	enum_animals_kind a = va_arg(args, enum_animals_kind);
	va_end(args);
printf("%d\n", a);
	return NULL;
}
	return NULL;
}
void *Animals_main(int arity, char *types, ...){
if(arity == 0 && strcmp(types, "0") == 0){
	va_list args;
	va_start(args, types);
	va_end(args);

enum_animals_kind *dog;
dog = malloc(sizeof(enum_animals_kind));
*dog = enum_animals_kind_DOG
;

enum_animals_kind *cat;
cat = malloc(sizeof(enum_animals_kind));
*cat = enum_animals_kind_CAT
;

enum_animals_kind *rabbit;
rabbit = malloc(sizeof(enum_animals_kind));
*rabbit = enum_animals_kind_RABBIT
;
	Animals_print(1,"1_enum_animals_kind",*dog);
	Animals_print(1,"1_string","olá mundo \n");
	Animals_print(1,"1_enum_animals_kind",*rabbit);
	return NULL;
}
	return NULL;
}
int main(int argc, char *argv[]) {
void *result;
result = Animals_main(0, "0");
if(result != NULL){
lx_print((void *)result,VOID);
}else{
printf("nil\n");
}
return 0;
}
