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

c = 40*radius^2/(n*(n-1));
##Parameters:
dt = 0;
dt_max = 0.4;
dt_min = dt_max/256;
check1 = 10;
check2 = 50;

dist = OnSphere(n, radius, c);
dist = dist.Init();
particleSize = 20;

checkval1 = 0;
convval = zeros(n,1);
##convval = [0];
iterations = 1;
time = 0;
times = [0];

###calculate initial forces
dist = dist.CalcAcc(); 
convval(:,iterations) = sqrt(sum(dist.Accelerations.^2,2));

###repeat until converging to equilibrium in force - not necessarily stationary in terms of movement! 
do 
  
  dt = dt_max;
  iterations++;
##  dist = dist.StepCenter( dt); 
   
  dist = dist.StepAway( dt); 
  convval(:,iterations) = sqrt(sum(dist.Accelerations.^2,2));
  ####  convval = [convval, norm(mean(dist.Particles))];
  while ((convval(:,iterations)-convval(:,iterations-1)) <= 0 && dt != dt_min)
    
    if (dt > dt_min)
      dt /= 2;
##      dist = dist.StepCenter( dt);
      dist = dist.StepAway( dt); 
      convval(:,iterations) = sqrt(sum(dist.Accelerations.^2,2));
##      convval(iterations) = norm(mean(dist.Particles));
    endif
##  if (dt>dt_min)
##  dt /= 2;
##  endif
  endwhile 
  
  time += dt;
  times = [times, time];
  
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
  
until ( abs(convval(:,iterations)-convval(:,iterations-1)) < 0.001 ) 
##until ( convval(iterations) < 0.01 )

plot(times,convval);
xlabel("time");
ylabel("convergence value");
##dist.Plot();



