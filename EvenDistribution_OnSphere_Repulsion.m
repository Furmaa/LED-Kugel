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
radius = 100;
n = 99;

##Parameters:
c = 5000;
dt = 0.1;
check1 = 10;
check2 = 50;

dist = OnSphere(n, radius, c);
dist = dist.Init();
particleSize = 20;

checkval1 = 0;
convval = [norm(mean(dist.Particles))];
iterations = 0;

do 
  
  
  dist = dist.StepCenter( dt); 
  convval = [convval, norm(mean(dist.Particles))];
  iterations++;
  
  if (iterations == check1)
    checkval = convval(iterations);
  endif
  if (iterations >= check2)
    if ( convval(iterations) >= checkval )
       printf("Divergence at iteration checkpoint %i\n",check2++);
      break
    endif
  endif
  
##until ( ( dist.Velocities < radius/c ) && ( center(iterations) < radius/50 ) )
until ( convval(iterations)/radius < 0.0001 )

plot(convval/radius);
xlabel("iterations");
ylabel("rel. distance of particle cloud center from sphere center [%]");
##dist.Plot();



