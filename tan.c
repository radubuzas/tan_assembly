#include <stdio.h>
#include <math.h>

double const pi = 3.14159265358979323846;

double factorial(int x)  //calculates the factorial
{
    double fact = 1;
    while(x)
    {
        fact = x * fact;
        x--;
    }
    return fact;
}

double power(double x,double n)  //calculates the power of x
{
    double output = 1;
    while(n)
    {
         output = ( x * output);
         n--;
    }
    return output;
}

float my_sin(double radians)  //value of sine by Taylors series
{
   double a,b,c;
   float result = 0;
   for(int i=0 ; i!=20 ; i++)
   {
      a =  power(-1,i);
      b =  power(radians,(2*i)+1);
      c =  factorial((2*i)+1);
      result = result + (a*b)/c;
   }
   return result;
}

double n, x, y;

int main()
{
    scanf("%lf", &n);

    n = fmod(n + pi, 2 * pi) - pi;
    
    x = my_sin(n);
    y = my_sin(n+pi/2);
    
    if(fabs(y) < 0.00001)
    	if(y < 0)
    		y = -0;
    	else
    		y = 0;
    
    x = x/y;
    	
	
    printf("%f\n", x);
    return 0;
}
