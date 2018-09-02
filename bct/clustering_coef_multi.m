function [CNTb CNTw] = clustering_coef_multi(subG, normalize)

CNTb = zeros(4,1);
CNTw = zeros(4,1);

K = length(subG);
for j=2:K,
    r12 = subG(1,j);
    for k=(j+1):K,
        r13 = subG(1,k);
        r23 = subG(j,k);
        
        rrr = r12*r13*r23;
        if rrr==0, continue; end;
        
        motiftype = sum(sign([r12 r13 r23]));
        wTriangles = (abs(r12*r13*r23))^(1./3);
        switch motiftype,
            case 3
                CNTb(1) = CNTb(1) + 1;
                CNTw(1) = CNTw(1) + 0.5*wTriangles;
            case 1
                CNTb(2) = CNTb(2) + 1;
                CNTw(2) = CNTw(2) + 0.5*wTriangles;
            case -1
                CNTb(3) = CNTb(3) + 1;
                CNTw(3) = CNTw(3) + 0.5*wTriangles;
            case -3
                CNTb(4) = CNTb(4) + 1;
                CNTw(4) = CNTw(4) + 0.5*wTriangles;
        end
    end
end


norm = K*(K-1)/2;
if normalize==1,
    CNTb = CNTb/norm;
    CNTw = CNTw/norm;
end