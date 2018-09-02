function [global_eff, local_eff] = calc_network_efficiency_bin(rthr,R)

nthr = length(rthr);
global_eff = zeros(nthr,1);
local_eff = zeros(nthr,1);

parfor n=1:nthr,
    G = R;
    thr_pos = rthr(n);
    G(G<thr_pos)=0;
    G(G>0)=1;
    
    Eg = efficiency(G);
    leff = efficiency(G, 1);
    Eloc = sum(leff)./length(G);
    
    global_eff(n) = Eg;
    local_eff(n) = Eloc;
end
