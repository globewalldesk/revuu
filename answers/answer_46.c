#include <stdio.h>

int main() {
  char c = 'A';
  int i = 1;
  short s = 32767;
  long l = 32768;
  float f = 1.1;
  double d = 23452345636.9;
  printf("char: %c, int: %i, short: %i\n", c, i, s);
  printf("long: %li, float: %f, double: %lf\n", l, f, d);
}