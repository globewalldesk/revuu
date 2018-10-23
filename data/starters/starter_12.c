#include <stdio.h>
int main() {
    int fahr, celsius;
    int lower, upper, step;
    lower = 0;    /* lower limit of temperature table */
    upper = 300;  /* upper limit */
    step = 20;    /* step size */

    fahr = lower;
    while (fahr <= upper) {
        celsius = (5.0/9) * (fahr-32);
  /* fill in this line */
        fahr = fahr + step;
    }
}
