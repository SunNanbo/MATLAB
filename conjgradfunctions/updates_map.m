function [varargout, peval]=updates_map(peval, varargin)
% [varargout, peval]=updates_map(peval, varargin)
% Computes Maximum aposteriori of Gamma - Poisson model (GaP)
% dvec = varargin{1};   % data (N x T)
% w = varargin{2};      % initialization for basis (N x peval.ncomp)
% h = varargin{3};      % initialization for a (peval.ncomp x T) and b

mfprintf(peval.fid, 'MAP conjgrad updates.\n')
[optionsW, optionsH]=setDefaultValuesOptions(peval);
dvec = varargin{1};
w = varargin{2};        % initialization for w coordinates (pelva.ncomp x 2) NOT TRANSPOSE!!!
h = varargin{3};        % initialization for h (peval.ncomp x T) and b

Hres=log(reshape(h, 1,peval.ncomp*peval.nt));       %must be log! (1 x peval.ncomp*T)
Wres=reshape(w, 1,peval.ncomp*2);                   %(1 x 2*peval.ncomp)

pointlogWall=[]; flog=[]; pointlogHall=[];
for kk=1:peval.nIterAlter %alternating optimization    
    cx=Wres(1:peval.ncomp); 
    cy=Wres(peval.ncomp+1:end);
    % W fixed, optimizing H (intensities)
    [Hres, optionsH, flogH, pointlogH] = conjgrad(peval.Hupdate, Hres, optionsH, ['grad' peval.Hupdate],dvec, peval.sigmaPSF, peval.alpha, peval.beta, peval, cx,cy);    
    flog=[flog; flogH];
    pointlogHall=[pointlogHall; pointlogH];    
    % H fixed, optimizing W (positions)
    [Wres, optionsW, flogW, pointlogW] = conjgrad(peval.Wupdate, Wres, optionsW, ['grad' peval.Wupdate],dvec, peval.sigmaPSF, peval.alpha, peval.beta, peval, Hres);    
    flog=[flog; flogW];
    pointlogWall=[pointlogWall; pointlogW];                    
end
    
varargout = struct('w',Wres,'h',Hres,'flog',flog);

end % Main function

% Nested fucntions:
function [optionsW, optionsH]=setDefaultValuesOptions(peval)
%optimization parameters
optionsW = zeros(1,18);
optionsW(1)=1;                  %to display error values
optionsW(7)=1;
optionsW(9)=0;                   %to check gradient
optionsW(14)=peval.Witer;         %maximum number of iterations

optionsH=optionsW;
optionsH(14)=peval.Hiter;
end
function plotprogress(w,lb,peval)
imstiled(reshape(w, peval.nx, peval.ny, peval.ncomp),10, 'gray',[],[],1)
plot(lb)
end