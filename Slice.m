# Run it after EvenDistribution_OnSphere_Repulsion.m 
# Finds the plane furthest from particles, to slice sphere through center

function varargout = FindBestSlice ( varargin )
  particles = [];
  dangle = 0.1; # 0.1° default resolution
  startAngle = 0; 
  endAngle = 90, # assuming close to symm. distribution: one quadrant is enough
  sliceNorm = [0 0 1]; # normal vector of first slice 
  wrongInput = "Feed OnSphere object or an nx3 matrix with non-complex numerical x y z coordinates of n particles!";
  
  if (nargin > 1)
    warning ("Correct usage: particles, dangle");
  endif
  
  switchType = typeinfo(varargin{1});
  switchClass = class(varargin{1});
  switch (switchType)
    
    case "object" 
      if (class(varargin{1}) == "OnSphere")
        particles = varargin{1}.Particles;
        disp("Slicing OnSphere object");
      else
        error(wrongInput);
    case "matrix"
       if (size(varargin{1},2) != 3)
         error(wrongInput);
       endif
        
       switch (switchClass)
         case {"double", "single", "int8", "int16", "int32", "int64", "uint8","uint16", "uint32", "uint64"}
           particles = varargin{1};
           disp("Slicing non-complex numerical matrix");
          otherwise
           error(wrongInput);
       endswitch
     otherwise
       error(wrongInput);
          
  endswitch

endfunction

function varargout = ApplySlice ( particles, sliceNorm )
  
endfunction
