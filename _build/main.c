// Include standard functions
#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>
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

	void * lx_match(void ** left, LxTypes type, void ** right) {
	if (type == ATOM && (*(int *)left) == (*(int *)right)) { return left; }
	else if (type == FLOAT  && (*(double *)left) == (*(double *)right)) { return left; }
	else if (type == INTEGER && (*(int *)left) == (*(int *)right)) { return left; }
	else if (type == STRING && strcmp((char *)left, (char *)right)) { return left; }
	else { printf("DONT MATCH"); exit(0); }
	}
// MODULE 'Operations'.ex
// -------- --------
void *Operations_sum_2_integer_integer(int a, int b){
int *var_3;
var_3 = &a;
int *var_4;
var_4 = &b;
	int *tmpvar_5;
	tmpvar_5 = malloc(sizeof(int));
*tmpvar_5 = (*var_3)+(*var_4);
	return tmpvar_5;

}
void *Operations_sub_2_integer_integer(int a, int b){
int *var_8;
var_8 = &a;
int *var_9;
var_9 = &b;
	int *tmpvar_10;
	tmpvar_10 = malloc(sizeof(int));
*tmpvar_10 = (*var_8)-(*var_9);
	return tmpvar_10;

}
void *Operations_mul_2_integer_integer(int a, int b){
int *var_13;
var_13 = &a;
int *var_14;
var_14 = &b;
	int *tmpvar_15;
	tmpvar_15 = malloc(sizeof(int));
*tmpvar_15 = (*var_13)*(*var_14);
	return tmpvar_15;

}
void *Operations_div_2_integer_integer(int a, int b){
int *var_18;
var_18 = &a;
int *var_19;
var_19 = &b;
	int *tmpvar_20;
	tmpvar_20 = malloc(sizeof(int));
*tmpvar_20 = (*var_18)/(*var_19);
	return tmpvar_20;

}
void *Operations_main_0(){
	int *var_21, *var_23, *var_25, *var_27;
var_21 = malloc(sizeof(int)); 
var_23 = malloc(sizeof(int)); 
var_25 = malloc(sizeof(int)); 
var_27 = malloc(sizeof(int)); 

var_21 = (int *)	Operations_sum_2_integer_integer(1, 2);
var_23 = (int *)	Operations_sub_2_integer_integer(2, 1);
var_25 = (int *)	Operations_mul_2_integer_integer(3, 2);
var_27 = (int *)	Operations_div_2_integer_integer(2, 2);
printf("%d %d %d %d\n", *var_21, *var_23, *var_25, *var_27);
printf("\n");
printf("*****************\n\n");
	int *tmpvar_32;
	tmpvar_32 = malloc(sizeof(int));
*tmpvar_32 = 3;
	int *tmpvar_33;
	tmpvar_33 = malloc(sizeof(int));
tmpvar_33 = (int *)	Operations_sum_2_integer_integer(1, 2);
	int *tmpvar_35;
	tmpvar_35 = malloc(sizeof(int));
tmpvar_35 = lx_match((void *) tmpvar_32, INTEGER, (void *) tmpvar_33);
	int *tmpvar_36;
	tmpvar_36 = malloc(sizeof(int));
*tmpvar_36 = 1;
	int *tmpvar_37;
	tmpvar_37 = malloc(sizeof(int));
tmpvar_37 = (int *)	Operations_sub_2_integer_integer(2, 1);
	int *tmpvar_39;
	tmpvar_39 = malloc(sizeof(int));
tmpvar_39 = lx_match((void *) tmpvar_36, INTEGER, (void *) tmpvar_37);
	int *tmpvar_40;
	tmpvar_40 = malloc(sizeof(int));
*tmpvar_40 = 6;
	int *tmpvar_41;
	tmpvar_41 = malloc(sizeof(int));
tmpvar_41 = (int *)	Operations_mul_2_integer_integer(3, 2);
	int *tmpvar_43;
	tmpvar_43 = malloc(sizeof(int));
tmpvar_43 = lx_match((void *) tmpvar_40, INTEGER, (void *) tmpvar_41);
	int *tmpvar_44;
	tmpvar_44 = malloc(sizeof(int));
	int *tmpvar_45;
	tmpvar_45 = malloc(sizeof(int));
*tmpvar_45 = 4;
	int *tmpvar_46;
	tmpvar_46 = malloc(sizeof(int));
tmpvar_46 = (int *)	Operations_div_2_integer_integer(8, 2);
	int *tmpvar_48;
	tmpvar_48 = malloc(sizeof(int));
tmpvar_48 = lx_match((void *) tmpvar_45, INTEGER, (void *) tmpvar_46);
return tmpvar_48;

free(var_21);
free(var_23);
free(var_25);
free(var_27);
}
int main(int argc, char *argv[]) {
void *result;
result = Operations_main_0();
if(result != NULL){
lx_print((void *)result,INTEGER);
}else{
printf("nil\n");
}
return 0;
}
