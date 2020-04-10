##
##
##Iterative approximation of even particle distribution on a sphere surface 
##based on particle-particle repulsion. 
##All measures are undimensional, aka. w/o units.
##
##Variables: radius d of sphere, number n of particles
##
##Parameters: repulsive force constant r, time step dt, 
##convergence checkpoint c (number of iterations at which convergence is checked)
##
##
##
##
##Variables:
rad = 100;
n = 100;

##Parameters:
r = 1;
m = 1;
dt = 0.01;
c = 10;

dist = OnSphere(n, rad);
dist = dist.Init();
particleSize = 20;
dist.Plot();

