function [R,Z,T] = fmri_connectivity(Ts)
% ---------------------------------------------
% Syntax: [R] = rsn_corr(Ts,approx)
% Input : Ts = scan x node
% Output: R = node x node (adjacency matrix)


nscans = size(Ts,1);
R=[];Z=[];T=[];

mu = repmat(mean(Ts),size(Ts,1),1);
X = Ts-mu;
V = X'*X;
dv = diag(V); % var(X)

dv = 1 ./ sqrt(dv); 
d1=repmat(dv,1,length(dv)); % 1/Sx 
d2=repmat(dv',length(dv),1); %1/Sy
R = d1 .* d2 .* V;

if nargout>1,
    df = nscans-3;
    Z = (log(1+R) - log(1-R))*0.5*sqrt(df); % sim N(0,1)

    Z = Z .* abs(eye(size(Z))-1); % A self-connection is not allowed
    Z(isnan(Z))=0;
end;
