function DEG = degrees_und(Cij)
%DEGREES_UND        Degree
%
%   deg = degrees_und(Cij);
%
%   Node degree is the number of links connected to the node.
%
%   Input:      Cij,    undirected (binary/weighted) connection matrix
%
%   Output:     deg,    node degree
%
%   Note: Weight information is discarded.
%
%
%   Olaf Sporns, Indiana University, 2002/2006/2008


% ensure Cij is binary...
% Cij = double(Cij~=0);

DEG = sum(Cij);
DEG = DEG(:);
