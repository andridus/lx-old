// Include standard functions
#include <tcclib.h>
#include <string.h>
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
}
void *Animals_main(int arity, char *types, ...){
if(arity == 0 && strcmp(types, "0_") == 0){
	va_list args;
	va_start(args, types);
	va_end(args);
enum_animals_kind dog = enum_animals_kind_DOG;
enum_animals_kind cat = enum_animals_kind_CAT;
enum_animals_kind rabbit = enum_animals_kind_RABBIT;
Animals_print(1,"1_enum_animals_kind",dog);
Animals_print(1,"1_string","olá mundo \n");
Animals_print(1,"1_enum_animals_kind",rabbit);
	return NULL;
}
}
int main(int argc, char *argv[]) {
 Animals_main(0, "0_");
return 0;
}
