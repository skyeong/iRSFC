I = zeros(4,4);
I(eye(4)==1)=1;


cnt = 1;
for i=1:length(A)
    for j=1:length(B)
        for k=1:length(C),
            a = I + A(i).matrix + B(j).matrix + C(k).matrix;
            fn_dcm = sprintf('DCM_%02d.mat',cnt) ;
            fn_out = sprintf('model_%02d.mat',cnt);
            % save(fn_out,'a','fn_dcm');
            fprintf('%02d, %d, %d, %d\n',cnt,i,j,k);
            cnt = cnt+1;
        end
    end
end
