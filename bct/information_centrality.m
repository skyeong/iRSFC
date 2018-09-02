function IC = information_centrality(Cij)

A = Cij;
J = ones(size(A));
degrees = sum(Cij);

idxD = find(eye(length(A)));

% D(r) is a diagonal matrix of the degree for each point
D_r = zeros(size(A));
D_r(idxD) = degrees;

% compute B and C
B = D_r - A + J;
C = pinv(B);


% compute T and R from C
T = sum(C(idxD));
R = sum(C)';

% compute Information centrality
n = length(A);
Cii = C(idxD);
IC = 1.0./(Cii + (T - 2*R)/n);



if 0,
    A(1,2) = 2;
    A(1,4) = 1;
    A(1,5) = 5;
    A(2,3) = 1;
    A(2,5) = 5;
    A(3,4) = 10;
    A(5,5) = 0;
    A = A + A';
end