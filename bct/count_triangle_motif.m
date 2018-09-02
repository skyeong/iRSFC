function cnt = count_triangle_motif(G, normalize)

cnt = zeros(4,1);

N = length(G);
for i=1:N,
    
    idx = find(G(i,:));
    
    for jj=1:length(idx),
        
        j = idx(jj);
        if j<i, continue; end;
        
        e12 = G(i,j);
        
        for kk=(jj+1):length(idx),
            
            k = idx(kk);
            
            if k<j || k<i, continue; end;
            
            e23 = G(j,k);
            e31 = G(k,i);
            
            motif_type = sum(sign([e12 e23 e31]));
            
            switch motif_type,
                case 3
                    cnt(1) = cnt(1) + 1;
                case 1
                    cnt(2) = cnt(2) + 1;
                case -1
                    cnt(3) = cnt(3) + 1;
                case -3
                    cnt(4) = cnt(4) + 1;
            end
        end
    end
end


if normalize==1,
    cnt = cnt*100./sum(cnt);
end