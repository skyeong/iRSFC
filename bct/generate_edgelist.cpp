#include "mex.h"
#include "math.h"
#include <stdio.h>

// hjpark 2010.01.20
// modified by skyeong 2013.06.21

int generate_edgelist(float *input_x, int nchn, int ntime, float* x_pos, float rthr, int st, int ed, char *fout) {
    
    float schx, schy, schxy, schx2, schy2, r;
    
    const int nc=3;
    unsigned int cnt[nc];
    
    int i, ioff;
    int ch_i=0, ch_j=0, ct=0;
    int chnroff, choff;
    
    float sign_xi, sign_xj;
    float mx, my, vschx;
    
    // File open
    FILE * pFile;
    pFile = fopen (fout,"w");
    
    for(ch_i=st;ch_i<=ed;ch_i++) {
        
        // initialize counter
        for (i=0; i<nc; i++) cnt[i]=0;
        
        // get a MNI coordinate for ch_i
        sign_xi=x_pos[ch_i];
        
        chnroff=ch_i*ntime;
        schx=0.0f; schx2=0.0f;
        
        for (i=0; i<ntime; i++)
        {   ioff = i+chnroff;
            schx += input_x[ioff];
            schx2 += input_x[ioff]*input_x[ioff];
        }
        
        mx=schx/ntime;
        vschx=(schx2-ntime*(mx*mx))/(ntime-1);
        
        if (vschx>0.0f) {
            
            for (ch_j=ch_i+1; ch_j<nchn; ch_j++) {
                if (ch_j==ch_i) continue;
                
                // get a MNI coordinate for ch_i
                sign_xj=x_pos[ch_j];
                
                // printf("sign_x[%d]=%f, sign_y[%d]=%f\n", ch_i, sign_xi, ch_j, sign_xj);
                
                
                choff=ch_j*ntime;
                schy=0.0f; schy2=0.0f; schxy=0.0f;
                for (i=0; i<ntime; i++){
                    ioff=i+choff;
                    schy += input_x[ioff];
                    schy2+= input_x[ioff]*input_x[ioff];
                    schxy+= input_x[ioff]*input_x[i+chnroff];
                }
                
                my=schy/ntime;
                
                // calcluate Pearson's correlation coefficients
                r=sqrt((ntime*schx2-schx*schx)*(ntime*schy2-schy*schy));
                
                if (r==0.0f) continue;
                r=(ntime*schxy-schx*schy)/r;
                
                if (r<=rthr) continue;
                fprintf (pFile, "%d %d 1\n",ch_i+1, ch_j+1);
                
                
            } //for ch_j
            
        } //if vschx
        
    }; //for ch_i
    
    fclose(pFile);
}



//cnt=qswn_cpu(single(Y),st,ed);
void mexFunction( int nlhs, mxArray *plhs[],
        int nrhs, const mxArray *prhs[]) {
    
    int N, M;
    int totalvox, ntime;
    int ct=0;
    
    double* rlt;
    float* finx;
    float* frlt;
    
    N = mxGetN(prhs[0]);
    M = mxGetM(prhs[0]);
    
    totalvox=N; ntime=M;
    finx = (float *)mxGetPr(prhs[0]);
    
    float* x_pos = (float* )mxGetPr(prhs[1]);
    int nxyz = mxGetM(prhs[1]);
    
    float rthr = (float)mxGetScalar(prhs[2]);
    int st = (int)mxGetScalar(prhs[3]);
    int ed = (int)mxGetScalar(prhs[4]);
    
    char *fout;
    int n = mxGetN(prhs[5])+1;
    fout = (char*)mxCalloc(n,sizeof(char));
    mxGetString(prhs[5],fout,n);
    
    //printf("****************************************\n");
    //fprintf("writing files: %s\n",fout);
    printf("          totalvox=%d  st=%d  ed=%d, ntime=%d, rthr=%.2f\n", totalvox, st, ed, ntime, rthr);
    //printf("****************************************\n");
    
    
    // run program
    generate_edgelist(finx, totalvox, ntime, x_pos, rthr, st-1, ed-1, fout);
    
}
