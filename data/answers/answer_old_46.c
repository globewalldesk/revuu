#include <stdio.h>

int main() {
  char c = 'a';
  short s = 32767;
  long l = 2147483647;
  int i = 42;
  float f = 1.1;
  double d = 234872348721348723486123847623894.23423;
  printf("c: %c, s: %hi, l: %li\n", c, s, l);
  printf("i: %i, f: %f\n", i, f);
  printf("%f\n", d);
}
