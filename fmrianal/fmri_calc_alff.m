function [fALFF ALFF powerSpecFX freq]=fmri_calc_alff(X,TR,BW,Zmode)
% THIS CODES TAKEN FROM REST TOOLBOX
%    X  = Time Series (Time x Voxels)
%    TR = Volume Acquisition Time (for example, 2 sec)
%    BW = [0.009 0.08]
%    Zmode

if nargin<3, error('Error: alff needs at least 3 arguments.'); end
if nargin<4, Zmode=1; end;


%  LOW AND HIGH PASS FILTER PARAMETERIZATION
%__________________________________________________________________________

sampleLength = size(X,1);
nvoxel=size(X,2);



%  FREQUENCY DETERMINATION
%__________________________________________________________________________

freq=(0:sampleLength-1);freq=min(freq,sampleLength-freq);
freq=freq/(TR*sampleLength);


%  FILTERED DATA FOR ALFF
%__________________________________________________________________________

FX = fft(X);
powerSpecFX = abs(FX); % or sqrt(FY.*conj(FY));
% plot(f,powerSpecFY(:,1000));



%  UNFILTERED DATA FOR F-ALFF
%__________________________________________________________________________

powerSpecArea = sum(powerSpecFX);
normpowerSpecFX=bsxfun(@rdivide, powerSpecFX, powerSpecArea);
% plot(f,normpowerSpecFY(:,1000));



%  CALCULATE LOW FREQUENCY FLUCTUATION
%__________________________________________________________________________

ALFF = sum(powerSpecFX);
ALFF(isnan(ALFF)) = 0;

fALFF = sum(normpowerSpecFX);
fALFF(isnan(fALFF)) = 0;


if Zmode,
    ALFF  = (ALFF - mean(ALFF(:)))/std(ALFF(:));
    fALFF = (fALFF - mean(fALFF(:)))/std(fALFF(:));
end



