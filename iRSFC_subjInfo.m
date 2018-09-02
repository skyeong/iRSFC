function subjList = iRSFC_subjInfo(fn)

[a,b,data] = xlsread(fn);
hdr = data(1,:);
hasName = zeros(1,length(hdr));

for i=1:length(hdr),
     hdr_name = hdr{i};
   if strcmpi(hdr_name,'subjname' ),
       hasName(i) = 1;
   end
end

idname = hasName==1;
subjList = data(2:end,idname);
