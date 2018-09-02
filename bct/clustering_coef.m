function [CC Cg CCn] = clustering_coef(Cij,weightmode)


Cij(find(Cij<0)) = 0;


if (weightmode),
    [CC Cg CCn] = clustering_coef_wu(abs(Cij));
else
    [CC Cg CCn] = clustering_coef_bu(abs(Cij));
end

