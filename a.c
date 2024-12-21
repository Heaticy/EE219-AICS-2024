extern int a[64];
extern int at[64];
extern int b[64];
extern int bt[64];
extern int c[64];
extern int ct[64];
extern int d[64];
extern int dt[64];
int main(){
    for(register int i = 0;i < 8;i++){
        for (register int j = 0; j < 8; j++){
            d[i*8+j] = c[i*8+j];
            for (register int k = 0; k < 8; k++){
                d[i*8+j] += a[i*8+k] * bt[j*8+k];
            }
        }
    }
}