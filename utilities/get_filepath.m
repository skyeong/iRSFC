function f_mri = get_filepath(fmripath, fns)

f_mri={};

if length(fns)==0,
    error('There are no functional MRI images.\n');
    return;
else,
    v=1;
    for i=1:length(fns),
        fn = fullfile(fmripath, fns(i).name);
        vs = spm_vol(fn);
        if length(vs)>1,
            for j=1:length(vs),
                f_mri{v} = [fullfile(fmripath, fns(i).name) ',' num2str(j)];
                v = v+1;
            end
        else,
            f_mri{v} = fullfile(fmripath, fns(i).name);
            v = v+1;
        end
    end
end
