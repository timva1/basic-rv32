#define N 100

extern int reserved_results[17];

void *memset(void *dest, int val, unsigned int len) {
    unsigned char *ptr = dest;
    while (len-- > 0)
        *ptr++ = (unsigned char)val;
    return dest;
}

int main() {
    reserved_results[16] = 380; // preload tb result reference value: sum of first 16 primes - 1

    int nums[N] = {0};
    int num_primes = 0;
    int n;
    int m;

    for (n = 2; n < N / 2; n++) {
        for (m = n; m < N / 2; m++) {
            if (n * m < N) {
                nums[n * m] = 1;
            }
        }
    }

    for (n = 2; n < N && num_primes < 16; n++) {
        if (nums[n] == 0) {
            reserved_results[num_primes] = n;
            num_primes++;
        }
    }
}