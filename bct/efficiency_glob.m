function [Lambda, Eg, D] = efficiency_glob(Cij,weightmode)


if (weightmode),
    D = distance_wei(Cij);
else
    D = distance_bin(Cij);
end

[Lambda, Eg] = charpath(D);

