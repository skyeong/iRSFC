function cond = cond_RLFF_model(TR, n_dyn)


t = [100 50 25 12.5];

cond = [];
k = 1;
for i=1:4,
    
    onset = 0:t(i):1800;
    cond(k).onset = onset(onset<TR*n_dyn);
    cond(k).duration = t(i)./2;
    
    onset = t(i)/4. + onset;
    cond(k+1).onset = onset(onset<TR*n_dyn);
    cond(k+1).duration = t(i)./2;
    
    k = k+2;
end