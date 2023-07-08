#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <inttypes.h>
#include <stdarg.h>

typedef struct {
  int age;
} person;

person person_copy(person *p) {
  person p0;
  p0 = *p;
  return p0;
}
void *foo(char *my_type, ...)
{
  switch (my_type[0])
  {
  case 'I':
  {
    va_list args;
    va_start(args, my_type);
    int i0 = va_arg(args, int);
    int *i;
    i = malloc(sizeof(int));
    *i = 1 + i0;
    va_end(args);
    return i;
  }
  case 'F':
  {
    va_list args;
    va_start(args, my_type);
    double f0 = va_arg(args, double);
    double *f;
    f = malloc(sizeof(double));
    *f = 1 + f0;
    va_end(args);
    return f;
  }
  case 'O':
  {
    va_list args;
    va_start(args, my_type);
    person p0 = va_arg(args, person);
    va_end(args);
    person *p;
    p = &p0;
    (*p).age += 2;
    printf("person age  em p0 is %d\n", p0.age);
    printf("person age  em p is %d\n", p->age);
    return p;
  }
  default:
    return NULL;
  }

}
int main(void)
{
  int *ii;
  double *dd;
  person *pp;
  person p;
  p.age = 1;

  ii = foo("I", 100);
  dd = foo("F");

  printf("Integer is %d\n", *ii);
  free(ii);
  printf("Double is %f\n", *dd);
  free(dd);
  pp = foo("O", p);
  printf("person age is %d\n", p.age);
  printf("person age is %d\n", pp->age);
  // free(pp);
  exit(0);
}
