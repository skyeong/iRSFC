tic
xyzs = sign(randn(100000,1));
rthr = 0.05;

Y = randn(100000,100);
nvox = size(Y,1);

nstep=8;
[steds, nt] = get_steds(nvox, nstep);

nc=3; % total, contralateral, ipsilateral connectivity
totcnt=nt*nc;

cnt=zeros(nstep,totcnt);
parfor i=1:nstep,
    st=steds(i,1); ed=steds(i,2);
    nt=(ed-st+1);
    tot=nt*nc;
    cnt1=swncpu(single(Y'),single(xyzs),rthr,st,ed);
    cnt1(tot+1:totcnt)=0;
    cnt(i,:)=cnt1;
end;


crcnt=zeros(1,nvox*nc); st1=1;
for i=1:nstep,
    st=steds(i,1); ed=steds(i,2);
    nt=(ed-st+1);
    ed1=st1+nt*nc-1;
    crcnt(st1:ed1)=cnt(i,1:nt*nc);
    fprintf('%d %d %d %d\n',i,st1,ed1,nt*nc);
    
    st1=ed1+1;
end;

crcnt=reshape(crcnt,[nc,nvox])';

toc

