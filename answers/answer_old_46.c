#include <stdio.h>

int main() {
  char c = 'x';
  short s = 1;
  long l = 32768;
  int i = 32768;
  float f = 1.1;
  double d = 3.4e+038;
  printf("c: %c, s: %hd, l: %ld\n", c, s, l);
  printf("i: %i, f: %f, d: %f", i, f, d);
}
