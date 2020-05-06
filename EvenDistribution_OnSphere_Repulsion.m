##
##
##Iterative approximation of even particle distribution on a sphere surface 
##based on particle-particle repulsion. 
##All measures are undimensional, aka. w/o units.
##
##Variables: radius d of sphere, number n of particles
##
##Parameters: repulsive force constant c, time step dt, 
##convergence checkpoints check1, check2 (number of iterations at which convergence is checked)
##
##
##
##
##Variables:
radius = 50; 
n = 78; 

#Variables
##radius = 2;
##n = 12;

##Simulation Parameters:
##c = 4*radius^2/(n*(n-1));
c_m = 0:0.05:20;
hoch_m = -1:-0.1:-9;
drag_m = 0:1:10;
dt_max = 3.2*radius/n;
dt_min = 0.000001;
check1 = 10;
check2 = 50;
checkval1 = 0;
measure = 0;
measures = [];
min = 2*radius;
min_c = 0;

for i=1:length(c_m)
##for i = 1:100

dt = zeros(n,1);  
dt_all = [ dt + dt_min ];
StdAcc_all = [];
convval = zeros ( n, 1 );
vel_all = zeros ( n, 1 );
##convval = [0];
iteration = 1;
iterations = [ iteration ];
##time = 0;
##times = [0];
step_check = 0;
c = c_m(i);
##c = 3;
##drag = drag_m(i);
drag = 5;
##hoch = hoch_m(i);
hoch = -3.5;

##initialize OnSphere
dist = OnSphere(n, radius, c);
dist.drag = drag;
dist.hoch = hoch;
particleSize = 20;

dist = dist.Init();

##dist = dist.CalcDistances();
##min = dist.StdDistance;

dist = dist.CalcAcc();
minInit = dist.StdAcc;

minInit_dist = dist;

for j = 1:50
  
  dist = dist.Init();
##  
##  dist = dist.CalcDistances();
##  measure = dist.StdDistance;
  
  dist = dist.CalcAcc();
##  measure = dist.StdAcc;
  
##  measures = [ measures , measure ];
  
##  if ( dist.StdDistance < min )
  if ( dist.StdAcc < minInit )
    
##    min = dist.StdDistance;
    minInit = dist.StdAcc;
    minInit_dist = dist;
    
  endif
  
endfor

dist = minInit_dist;
dist = dist.CalcVel ( dt_max );

##
convval ( : , iteration ) = sqrt ( sum ( dist.Accelerations.^2 , 2 ) );
vel_all ( : , iteration ) = sqrt ( sum ( dist.Velocities.^2 , 2 ) );

###repeat until converging to equilibrium in force - not necessarily stationary in terms of movement! 

do 
  
  
  dt(:) = dt_max;
  iteration++;
  iterations = [ iterations, iteration ];
   
  do 
    
    new_dist = dist.StepAway( dt ); 
    convval( : , iteration ) = sqrt( sum ( new_dist.Accelerations.^2 , 2 ) );
    step_check = ( ( convval( : , iteration ) - convval( : , iteration-1 ) ) < 0 );
    
    dt_check = ( !step_check & dt > dt_min );
    if ( !dt_check )
      break
    else
      dt ( dt_check ) /= 10;  
    endif
    
  until ( step_check )
  
##  time += dt;
##  times = [ times, time ];
  
  dt_all = [ dt_all, dt ];
  vel_all ( : , iteration ) = sqrt ( sum ( dist.Velocities.^2 , 2 ) );
  dist = new_dist;
  
##  if (iterations > check1)
##    checkval = mean(convval(:,iterations-round(check1/2):iterations-1),2);
##  endif
##  if (iterations >= check2)
##    if ( checkval*1.5 > convval(:,iterations) )
##       1;
##     else
##       printf("Divergence at iteration %i\n", iterations);
##       break
##    endif
##  endif
  
until ( abs ( convval ( : , iteration ) - convval( : , iteration-1 ) ) < 0.001 ) 
##until ( convval(iterations) < 0.01 )

##plot(times,convval);
##plot(iterations(end-iteration+2:end),convval(:,end-iteration+2:end));
##xlabel("time");
##xlabel("iteration");
##ylabel("convergence value");
##dist.Plot();
dist = dist.CalcDistances();
measure = dist.StdDistance;
measures = [ measures , measure ];
if ( measure < min )
  min = measure;
  min_dist = dist;
  min_iterations = iterations;
  min_convval = convval;
  min_vel_all = vel_all;
endif

endfor

##plot ( min_iterations, min_convval );
plot ( c_m , measures );
##plot ( measures );
##IT = 1:100;
##plot(IT,measures);
##printf("mean: %f, std: %f, min: %f\n", mean(measures),std(measures),min);


