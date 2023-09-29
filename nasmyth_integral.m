%% nasmyth
% Generate a Nasmyth integrated universal shear spectrum
%%
% <latex>\index{Type A!nasmyth}</latex>
%
%%% Syntax
%   [phi, varargout] = nasmyth( varargin )
%
% * [e] Rate of dissipation in units of W/kg.  
% * [nu] Kinematic viscosity in units of m^2/s. Default value is 1e-6.
% * [N] Number of spectral points. Default value is 1000.
% * [k] Wavenumber in cpm. 
% * []
% * [phi] Nasmyth spectrum in units of s^-2 cpm^-1. The length of 
%       phi is N, or the length of k.
% * [k] Wavenumber in cpm.
%
%%% Description
% This function generates a Nasmyth universal shear spectrum.  There are 
% four basic forms of this function:
%
%    1) [phi,k] = nasmyth( e, nu, N);
%    2)  phi    = nasmyth( e, nu, k);
%    3) [phi,k] = nasmyth( 0, N );
%    4)  phi    = nasmyth( 0, k );
%
% Form 1: Return the Nasmyth spectrum for the dissipation rate $e$ and viscosity 
% $nu$.  The length of the returned spectrum $phi$ is $N$ and $k$ is the 
% wavenumber in cpm.  Default values are $nu$ = 1e-6 and $N$ = 1000.
%
% Form 2: Same as form 1) except that the Nasmyth spectrum is evaluated at 
% the wavenumbers given in the input vector $k$ (in cpm).
%
% Form 3: Return the non-dimensional Nasmyth spectrum (G2 spectrum) of length
% $N$ points.  The wavenumber is $k = k'/ks$ [where $k'$ is in cpm 
% (see Oakey 1982)] and runs from 1e-4 to 1.
%
% Form 4: Same as form 3) except that the non-dimensional spectrum is evaluated 
% at the wavenumbers given in the input vector $k$ (in $k'/ks$).
%
%%% Note
% For forms 1) and 2), the dissipation rate can be a vector, 
% e.g. $e$ = [1e-7 1e-6 1e-5],  in which case $phi$ is a matrix 
% whose columns contain the scaled Nasmyth spectra for the elements in $e$. 
%
% The form of the spectrum is computed from Lueck's (1995) fit to the 
% Nasmyth points listed by Oakey (1982).
%
%%% Examples
% Form 1:
%
%    >> [phi,k] = nasmyth( 1e-7, 1.2e-6, 512 )
%    >> [phi,k] = nasmyth( 1e-7, 1.2e-6 )
%    >> [phi,k] = nasmyth( 1e-7 )
%
% Form 2:
%
%    >> phi = nasmyth( 1e-7, 1.2e-6, logspace(-1,3,512) )
%
% Form 4:
%
%    >> phi = nasmyth( 0, logspace(-3,0,512) )
%
%%% References: 
%
% # Oakey, N. S., 1982: J. Phys. Ocean., 12, 256-271.
% # Wolk, F., H. Yamazaki, L. Seuront and R. G. Lueck, 2002: A new free-fall
%   profiler for measuring biophysical microstructure. J. Atmos. and Oceanic
%   Techno., 19, 780-793.

% *Version History:*
%
% * original Version By D. Huang, SEOS, UVic.
% * 1996-02-05 (RGL) CEOR UVic: G2's formula fitted
% * 1997-07-01 (FW) SEOS UVic: allow input for vector epsilon
% * 2000-07-28 (FW) Alec Electronics: non-dimensional output (forms 3 and 4)
% * 2000-09-28 (FW) Alec Electronics: wavenumber input (form 2)
% * 2011-09-01 (AWS) added documentation tags for matlab publishing
% * 2012-09-08 (WID) improved documentation for matlab publishing
% 2015- CBluteau wanted also the integrated version from Tech Note 28. 
%       I want to accept only forms 1 or 2...

function [phi,varargout] = nasmyth_integrated(varargin)

% argument checking
error(nargchk(1,3,nargin));
[scaled,e,nu,N,k] = checkArgs(varargin,nargin);

if scaled  % forms 1) and 2)
   e = e(:)';
   Ne = length(e);
   ks = (e./nu.^3).^(1/4); % Kolmogorov wavenumber(s)    
   ks = ks(ones(N,1),:);   
   if isempty(k) % form 1)
      x = logspace(-4,0,N)';
      x = x(:, ones(1,Ne)); 
   else          % form 2)
      k = k(:,ones(1,Ne));
      x = k./ks;
   end
   G2 = 8.05*x.^(1/3)./(1+(20*x).^(3.7)); % Lueck's fit
   Gint=tanh(48.*x.^(4/3))-(2.9.*x.^(4/3)).*exp(-22.3.*x.^(4/3));
   k = x.*ks;    
   e = e(ones(N,1),:);   
   phi = e.* Gint;
   varargout{1} = k;            
else    % forms 3) and 4)
   if isempty(k) % form 3)
      k = logspace(-4,0,N)';  % k = k_hat/k_s, as in Oakey 1982.
      varargout{1} = k;
   end
    Gint=tanh(48.*k.^(4/3))-(2.9.*k.^(4/3)).*exp(-22.3.*k.^(4/3));
   phi = Gint;%8.05*k.^(1/3)./(1+(20*k).^(3.7)); % Lueck's fit
end
   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [scaled,e,nu,N,k] = checkArgs(arg,narg);
% Helper function for Nasmyth.m

% the default values:
scaled = 0;
e  = 1e-6;
nu = 1e-6;
N  = 1000;
k  = [];


if any(arg{1} ~= 0) % it's form 1) or 2)
   scaled = 1;
   if narg == 3
      e = arg{1};
      nu = arg{2};
      N = arg{3};
   elseif narg == 2
      e = arg{1};
      nu = arg{2};
   elseif narg == 1
      e = arg{1};
   end
else                % it is form 3) or 4)
   scaled = 0;
   N = arg{2};
end

if length(N) > 1 % last argument is vector means it's a wavenumber vector
   if all(size(N)>1)
      error('Sorry, can''t have matrix wavenumber input.');
   else
      k = N(:);
      N = length(k);
   end
end



   
   
