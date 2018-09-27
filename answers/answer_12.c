#include <stdio.h>
int main() {
    int fahr;

    for (fahr = 20; fahr <= 120; fahr = fahr + 10)
        printf("%d\t%f\n", fahr, ((5.0/9) * (fahr-32)) );
}

