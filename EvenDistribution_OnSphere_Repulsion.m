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
radius = 1;
n = 24;

c = 20*radius^2/n;
##Parameters:
dt = 0;
dt_max = 0.4;
dt_min = dt_max/32;
check1 = 10;
check2 = 50;

dist = OnSphere(n, radius, c);
dist = dist.Init();
particleSize = 20;

checkval1 = 0;
convval = zeros(n,1);;
##convval = [0];
iterations = 1;
time = 0;
times = [0];

do 
  dt = dt_max;
  iterations++;
##  dist = dist.StepCenter( dt); 
  do 
  dist = dist.StepAway( dt); 
  convval(:,iterations) = sqrt(sum(dist.Accelerations.^2,2));
####  convval = [convval, norm(mean(dist.Particles))];
##  if  (convval(:,iterations) < 5)
##    if (dt < dt_max);
##      dt *= 2;
####      dist = dist.StepCenter( dt);
##      dist = dist.StepAway( dt); 
##      convval(:,iterations) = sqrt(sum(dist.Accelerations.^2,2));
####      convval(iterations) = norm(mean(dist.Particles));
##    endif
##    
##  elseif (dt > dt_min)
##      dt /= 2;
####      dist = dist.StepCenter( dt);
##      dist = dist.StepAway( dt); 
##      convval(:,iterations) = sqrt(sum(dist.Accelerations.^2,2));
####      convval(iterations) = norm(mean(dist.Particles));
##  endif
  if (dt>dt_min)
  dt /= 2;
  endif
  until (convval(:,iterations) < 5 || dt == dt_min)
  
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
  
until ( abs(convval(:,iterations)-convval(:,iterations-1)) < 0.1 )
##until ( convval(iterations) < 0.01 )

plot(times,convval);
xlabel("time");
ylabel("convergence value");
##dist.Plot();



