## -*- texinfo -*-
## @deftypefn  {} {} OnSphere ()
## @deftypefnx {} {} OnSphere (@var{n}, @var{radius})
## Creates an object representing particles of a population Pop
## on a sphere described by radius Size
##
## @example
## obj = OnSphere(10); 
## obj.Init();
## particleSize = 20;
## obj.PlotIt(particleSize);
## @end example
##
## @noindent
## having n = 10 points initialized randomly distributed in a plane grid then projected to sphere.
## @end deftypefn

classdef OnSphere 
  
  properties (SetAccess = 'private', GetAccess = 'public')
    
    Pop = 0; #of particles
    Size = 0; #of sphere
    Particles = []; #descartes coordinates of particles, Pop x 3
    Rnormed = []; #normed to Size descartes coordinates of particles, Pop x 3
    Velocities = []; #descartes coordinates of particle velocity vectors, Pop x 3
    Accelerations = []; #descartes coordinates of particle acceleration vectors, Pop x 3
    StdAcc = 0; #standard deviation of acceleration norms
    StdDistance = 0; #of particles
    Distances = []; #Pop x Pop matrix
    Closest = []; #Pop x 1 
    ClosestIdx = []; #Pop x 1
    dr = [];
    c = 0; #repulsive force constant
    
    
  endproperties
  
  properties (Access = 'public') 
    
    drag = 0; #drag force constant
    hoch = 0; #repulsive force order
    
  endproperties

  methods
    
    function obj = OnSphere ( varargin )

      if ( nargin == 0 )
        print_usage();
      endif
      
      if ( nargin > 3 )
        error ("@OnSphere: expecting maximum three input variables.");
      endif

      if ( nargin == 1 )
        if ( isa ( varargin, "OnSphere" ) )
          obj.Pop = varargin.Pop;
          obj.Size = varargin.Size;
        elseif ( isreal ( varargin ) )
          obj.Pop = round ( abs ( varargin ) );   #number of points distributed
##          obj = class (obj, "OnSphere"); #for old style class declaration
          obj.Size = obj.Pop*3; #radius of obj
        else
          error ("@OnSphere: population must be a simple real number");
        endif
        obj.c = 1;
      endif
      
      if ( nargin == 2 )
        if (isreal (varargin{1}) && size(varargin{1},1)==1 && size(varargin{1},2)==1)
          obj.Pop = round(abs(varargin{1}));
        else 
          error ("@OnSphere: population must be a simple real number");
        endif
        if (isreal (varargin{2}) && size(varargin{2},1)==1 && size(varargin{2},2)==1)
          obj.Size = abs(varargin{2});
        else 
          error ("@OnSphere: size must be a simple real number");
        endif
        obj.c = 1;
      endif
      
      if ( nargin == 3)
        if (isreal (varargin{1}) && size(varargin{1},1)==1 && size(varargin{1},2)==1)
          obj.Pop = round(abs(varargin{1}));
        else 
          error ("@OnSphere: population must be a simple real number");
        endif
        if (isreal (varargin{2}) && size(varargin{2},1)==1 && size(varargin{2},2)==1)
          obj.Size = abs(varargin{2});
        else 
          error ("@OnSphere: size must be a simple real number");
        endif
        if (isreal (varargin{3}) && size(varargin{3},1)==1 && size(varargin{3},2)==1)
          obj.c = abs(varargin{3});
        else 
          error ("@OnSphere: force constant must be a simple real number");
        endif
      endif 

    endfunction

    function varargout = disp ( obj )
      
      printf("OnSphere population: %i\nOnSphere size: %f\n", obj.Pop, obj.Size);
      
    endfunction
    
    function obj = Init ( obj )  
      
        #random points initialized, spherical coordinates
        r = ones(obj.Pop,1);
        phi = rand(obj.Pop,1)*2*pi;
        theta = rand(obj.Pop,1)*2*pi;
        
        #transforming to cartesian coordinates
        [obj.Particles(:,1), obj.Particles(:,2), obj.Particles(:,3)] = sph2cart( theta, phi, r);

        #scaling
        
        obj.Particles *= obj.Size;
        
        #initialize particle dynamics
        obj.Accelerations = zeros(obj.Pop,3);
        obj.Velocities = zeros(obj.Pop,3);
        
        #other variables initialized
        obj.Distances = zeros(obj.Pop,obj.Pop);; #Pop x Pop matrix
        obj.Closest = zeros(obj.Pop,1);; #Pop x 1 
        obj.dr = zeros(obj.Pop,1);
     
    endfunction
    
    function varargout = Plot ( obj, varargin )        
        
        #drawing particles on sphere
        if ( nargin == 1 )
          
          particleSize = 20;
          idx = 1:obj.Pop;
          
        elseif ( nargin == 2 )
          
          particleSize = 20;  
          idx = varargin{1};      
        
        elseif ( nargin == 3 )
            
          particleSize = varargin{2};  
          idx = varargin{1};  
          
        else
          
          error("OnSphere: Plot: expecting zero to 2 arguments");
          
        endif
        
        x = obj.Particles(idx,1);
        y = obj.Particles(idx,2);
        z = obj.Particles(idx,3);
       
        obj.Draw ( x, y, z, particleSize );
 
    endfunction
  
    function obj = CalcDistances ( obj ) #calculates mean distance of particles
      
        obj.Distances = zeros ( obj.Pop , obj.Pop );
        obj.Closest = zeros ( obj.Pop, 1 );
        obj.ClosestIdx = zeros ( obj.Pop, 1);
        obj.Closest(:) = 2*obj.Size; #sphere diameter
    
        for i = 1 : (obj.Pop-1)           
          
          for j = (i+1) : obj.Pop
            
            dr = obj.Particles(i,:) - obj.Particles(j,:);
            dr_ = norm(dr);
            obj.Distances ( i, j ) = dr_;
            obj.Distances ( j, i ) = dr_;
            
            if ( dr_ < obj.Closest ( i ) )
              obj.Closest ( i ) = dr_;
              obj.ClosestIdx ( i ) = j;  
            endif
            if ( dr_ < obj.Closest ( j ) )
              obj.Closest ( j ) = dr_;  
              obj.ClosestIdx ( j ) = i;  
            endif
          
          endfor
          
        endfor
        
        obj.StdDistance = mean(std(transpose(sort(obj.Distances)))(2:end));
        
    endfunction
      
    function obj = StepAway ( obj, dt ) 
      
      #Euler forward 
      obj.Particles = obj.Particles + obj.Velocities.*dt; 
##      obj.Particles = obj.Particles + obj.Accelerations*dt^2/2; 
      r_ = sqrt(sum(obj.Particles.^2,2)); #norm vector of positions
      obj.Particles = obj.Particles./[r_,r_,r_]*obj.Size; #project to sphere
      
      obj = obj.CalcVel ( dt );
      
      #particle dynamics
      obj  = obj.CalcAcc();  
      
    endfunction
    
    function obj = CalcAcc ( obj )
      
      #particle dynamics

      for i = 1:obj.Pop
        
        AwayParticles = [obj.Particles(1:(i-1),:);obj.Particles((i+1):obj.Pop,:)];
        dr = obj.Particles(i,:) - AwayParticles; #position difference vector (Pop-1) x 3
        dr = dr + (dr==0)*0.1;
        dr_ = sqrt(sum(dr.^2,2)); #norm vector of position differences        
        obj.Accelerations(i,:) = sum(obj.c * dr.*(dr_.^obj.hoch)); #raw acceleration from q-q repulsion
        
      endfor
      
      obj.Rnormed = obj.Particles/obj.Size; #normed position vectors
      accrad_ = sum(obj.Accelerations.*obj.Rnormed,2); #scalar product vector 
      obj.Accelerations = obj.Accelerations - [accrad_,accrad_,accrad_].*obj.Rnormed; #substract radial parts    
      vel_ = sqrt(sum(obj.Velocities.^2,2)); #norm vector of 
      
      obj.Accelerations = obj.Accelerations - obj.drag*obj.Velocities.*vel_;
      
      obj.StdAcc = std ( sqrt( sum ( obj.Accelerations.^2,2 ) ) );
      
    endfunction
    
    function obj = CalcVel ( obj, dt ) 
      
      obj.Velocities = obj.Velocities + obj.Accelerations.*dt;
      velrad_ = sum(obj.Velocities.*obj.Rnormed,2); #scalar product vector 
      obj.Velocities = obj.Velocities - [velrad_, velrad_, velrad_].*obj.Rnormed; #subtract radial parts      

    endfunction
    
  endmethods
  
  methods (Static = true)
  
    function varargout = Draw ( x, y, z, particleSize )
      
      #drawing a sphere scaled up to obj size
      [x_, y_, z_] = sphere();
      r = sqrt( x.^ 2 + y.^ 2 + z.^ 2 );
      r_ = mean ( r );
      x_ *= r_;
      y_ *= r_;
      z_ *= r_;
      surf ( x_, y_, z_ );
        
      hold on;
      
      #drawing particles given by x, y, z coordinates
    
      scatter3 ( x, y, z, particleSize, 'r', "filled" );
      scatter3 ( x, y, z, particleSize, 'r', ':', "linewidth", 10 );
      xlabel("x");
      ylabel("y");
      zlabel("z");

    endfunction
 
  endmethods
    
  
endclassdef



