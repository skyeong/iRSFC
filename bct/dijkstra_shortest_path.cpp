#define char16_t UINT16_T

#include "mex.h"
#include "math.h"
#include <stdio.h>

#define MAX(a, b) ((a > b) ? (a) : (b))


void dijkstra(int s, int n_nodes, float *LEN_ij, float *d) {
    int i, k, mini;
    int visited[n_nodes];
    int Inf = n_nodes*n_nodes;
    for (i=0; i<n_nodes; i++) {
        d[i] = Inf;
        visited[i] = 0; /* the i-th element has not yet been visited */
    }
    
    d[s] = 0;
    
    for (k=0; k<n_nodes; k++) {
        mini = -1;
        for (i=0; i<n_nodes; i++)
            if (!visited[i] && ((mini == -1) || (d[i] < d[mini])))
                mini = i;
        
        visited[mini] = 1;
        
        for (i=0; i<n_nodes; i++)
            if (LEN_ij[mini*n_nodes+i])
                if (d[mini] + LEN_ij[mini*n_nodes+i] < d[i])
                    d[i] = d[mini] + LEN_ij[mini*n_nodes+i];
    }
}




void mexFunction( int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[])
{
    // Get Input Data Pointer
    float* LEN_ij;
    LEN_ij = (float *)mxGetPr(prhs[0]);
    
    
    // Get Number of Nodes from Input
    int n_nodes = mxGetN(prhs[0]);
    
    
    // Get Number of Nodes from Input
    int st = (int)mxGetScalar(prhs[1]);
    int ed = (int)mxGetScalar(prhs[2]);
    int datalen = ed-st+1;
    
    if (st>ed) {
        printf("Index Error\n");
        return;
    }
    
    // Get Number of Nodes from Input
    int totalelem = n_nodes*datalen;
    
    
    // threshold value for correlation coefficient calculation
    // printf("    : n_nodes=%d, st=%d, ed=%d \n", n_nodes, st, ed);
    
    
    // Calculate Correlation Coefficient
    float *PATH_ij = new float[totalelem];
    for(int i=0; i<totalelem; i++) PATH_ij[i]=0.0f;
    
    float *d = new float[n_nodes];
    for (int s=0; s<datalen; s++)
    {
        dijkstra(s+st-1, n_nodes, LEN_ij, d);
        for (int i=0; i<n_nodes; i++)
            PATH_ij[s*n_nodes+i] = d[i];
    }
    
    
    // Create Output MatPATH_ijx
    double *OUTr;
    OUTr = (double*)mxGetData(plhs[0]=mxCreateDoubleMatrix(n_nodes, datalen,mxREAL));
    for (int i=0; i<totalelem; i++)
        OUTr[i] = (double)PATH_ij[i];
    
    delete [] PATH_ij;
    delete [] d;
}
