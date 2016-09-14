read M[2];
load R0 M[2];
store M[3] R1;
load R0 M[0];
< R1 R0 5;
if R1 10;
load R2 1;
store M[1] R3;
goto 12
load R2 -1;
store M[1] R3;
load R2 M[0];
> R3 R2 M[0];
load R3 0;
> R4 R3 0;
store M[1] R5;
store M[0] R4;
goto 13;
print (Factorial of) M[2] (is) M[3] (\n);
