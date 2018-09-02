function passed = check_iRSFC_params(analmode)

global FMRI

passed = 1;
if isempty(FMRI.prep.subjList),
    errordlg('Subject list does not specified.');
    passed = 0;
end


if isempty(FMRI.prep.DATApath),
    errordlg('DATApath does not specified.');
    passed = 0;
end


if analmode==1,
    if isempty(FMRI.anal.FC.OUTpath),
        errordlg('OUT path does not specified.');
        passed = 0;
    end
end