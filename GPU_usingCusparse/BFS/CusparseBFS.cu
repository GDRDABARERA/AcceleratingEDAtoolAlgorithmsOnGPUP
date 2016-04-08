#include <stdio.h>
#include <stdlib.h>
#include <err.h>	
#include <cuda_runtime.h>
#include "helpers.cuh"
#include "cusparse.h"

/*
#define CLEANUP(s)                                   \
do {                                                 \
    printf ("%s\n", s);                              \
    if (csrValAHostPtr) free(csrValAHostPtr);\
    if (csrColIndexAHostPtr) free(csrColIndexAHostPtr);\
    if (csrRowPtrAHostPtr)      free(csrRowPtrAHostPtr);     \
    if (csrValACuda)        cudaFree(csrValACuda);   \
    if (csrColIndexACuda)        cudaFree(cooColIndex);   \
    if (csrRowPtrACudaPtr)             cudaFree(csrRowPtrACudaPtr);        \
    if (handle)             cusparseDestroy(handle); \
    fflush (stdout);                                 \
} while (0)  */


void checkStatus(cusparseStatus_t status){

        if(CUSPARSE_STATUS_SUCCESS==status){
                printf("the operation completed successfully \n");
        }else if (CUSPARSE_STATUS_NOT_INITIALIZED==status){
                printf("CUSPARSE_STATUS_NOT_INITIALIZED \n");
        }else if(CUSPARSE_STATUS_ALLOC_FAILED==status){
                printf("CUSPARSE_STATUS_ALLOC_FAILED\n");
        }else if(CUSPARSE_STATUS_INVALID_VALUE==status){
                printf("CUSPARSE_STATUS_INVALID_VALUE\n");
        }else if(CUSPARSE_STATUS_ARCH_MISMATCH==status){
                printf("CUSPARSE_STATUS_ARCH_MISMATCH\n");
        }else if(CUSPARSE_STATUS_EXECUTION_FAILED==status){
                printf("CUSPARSE_STATUS_EXECUTION_FAILED\n");
        }else{
                printf("CUSPARSE_STATUS_INTERNAL_ERROR\n");
        }


}
int findMaxColNo(int array[] ){
	int k;
	int max = INT_MIN;
	for(k=0;k<(sizeof(array)/sizeof(int));k++){
		if(max<array[k]){
			max=array[k];
		}
	}
	printf("return max %d\n",max+1 );
	return max+1;

}
int main(){
    //cudaError_t cudaStat1,cudaStat2,cudaStat3; //,cudaStat4,cudaStat5,cudaStat6;
    int AColIndex[]= {0,2,1,1,2};
    double Val[] = {1.0,1.0,1.0,1.0,1.0}; 
    int rowPtr[]= {0 ,2 ,3,5}; 
    double X[]={1,1,0};

    
    int     m, n, nnz, i, j;
    

    m= sizeof(rowPtr)/sizeof(int)-1; //no of rows
    n=findMaxColNo(AColIndex); //no of cols
    nnz = rowPtr[m]; //no of non zero elements
    
    cusparseStatus_t status1,status2,status3,status4,status5;
   
   
    
    int *    csrColIndexAHostPtr=(int *)malloc(sizeof(int)*nnz);
    int *    csrRowPtrAHostPtr=(int *)malloc(sizeof(int)*(n+1));    
    double *  csrValAHostPtr=(double *)malloc(sizeof(double)*nnz);
    double * xHost=(double *)malloc(sizeof(double)*n);
    double * yHost=(double *)malloc(sizeof(double)*n);
    int *    csrColIndexACuda;
    int *    csrRowPtrACudaPtr;    
    double * csrValACuda;
    int *    cscColIndexACuda;
    int *    cscRowPtrACudaPtr;    
    double * cscValACuda;
    double * xCuda;
    double * tmpCuda;
    double * yCuda;
    
    const double alpha = 1.0;
    const double beta = 0.0;

    printf("testing example\n");

 /*****************Here m should equal to n ***********************************/ 
 
 /*************Asign  arrays to pointers***************/
 
 for(i=0;i<nnz;i++){
        csrColIndexAHostPtr[i]=AColIndex[i];
        csrValAHostPtr[i]=Val[i];
    }
    
 for(i=0;i<n+1;i++){
     csrRowPtrAHostPtr[i]=rowPtr[i];
  }
 for(i=0;i<n;i++){
     xHost[i]=X[i];
 }
    
    
   printf("\n");

	/********************************** CUDA stuff starts here *******************************/
	
	//start measuring time
	cudaEvent_t start,stop;
	float elapsedtime=0.0;
	cudaEventCreate(&start);
	cudaEventRecord(start,0);
	   for(j=0;j<nnz;j++){
                printf("%f  of csrValAHostPtr ",csrValAHostPtr[j]);
           }
	
     cudaMalloc((void**)&csrColIndexACuda,nnz*sizeof(int)); 
     cudaMalloc((void**)&csrValACuda,nnz*sizeof(double));
     cudaMalloc((void**)&csrRowPtrACudaPtr,  n*sizeof(int)); 
     cudaMalloc((void**)&cscColIndexACuda,nnz*sizeof(int)); 
     cudaMalloc((void**)&cscValACuda,nnz*sizeof(double));
     cudaMalloc((void**)&cscRowPtrACudaPtr,  n*sizeof(int)); 
     cudaMalloc((void**)&xCuda,n*sizeof(double)); 
     cudaMalloc((void**)&yCuda,n*sizeof(double));
     cudaMalloc((void**)&tmpCuda,n*sizeof(double));

     checkCuda(cudaMemcpy(csrColIndexACuda,csrColIndexAHostPtr,sizeof(int)*nnz,cudaMemcpyHostToDevice));
     checkCuda(cudaMemcpy(csrValACuda,csrValAHostPtr,sizeof(double)*nnz,cudaMemcpyHostToDevice));
     checkCuda(cudaMemcpy(csrRowPtrACudaPtr,csrRowPtrAHostPtr,sizeof(int)*n,cudaMemcpyHostToDevice));
     checkCuda(cudaMemcpy(xCuda,xHost,sizeof(double)*n,cudaMemcpyHostToDevice));
     

   /***************************Cu Sparse part ***********************/
    
    cusparseOperation_t trans= CUSPARSE_OPERATION_NON_TRANSPOSE;
    cusparseIndexBase_t idxBase = CUSPARSE_INDEX_BASE_ZERO;
    cusparseAction_t copyValues= CUSPARSE_ACTION_NUMERIC;
    cusparseHandle_t handle;
    status4=cusparseCreate(&handle);  checkStatus(status4);
    
     cusparseMatDescr_t descrA ;
    status5 =cusparseCreateMatDescr(&descrA); checkStatus(status5);
    
    
      
  /*
  cusparseStatus_t 
cusparseDcsr2csc(cusparseHandle_t handle, int m, int n, int nnz,
                 const double *csrVal, const int *csrRowPtr, 
                 const int *csrColInd, double          *cscVal,
                 int *cscRowInd, int *cscColPtr, 
                 cusparseAction_t copyValues, 
                 cusparseIndexBase_t idxBase)


Read more at: http://docs.nvidia.com/cuda/cusparse/index.html#ixzz456mkjYNe
Follow us: @GPUComputing on Twitter | NVIDIA on Facebook
*/
    
    
                 status1 =   cusparseDcsr2csc(handle,n,n,nnz,csrValACuda,csrRowPtrACudaPtr,csrColIndexACuda,cscValACuda,cscColIndexACuda,cscRowPtrACudaPtr,copyValues, idxBase);
                    
                checkStatus(status1);
    
 
    
    /*
    cusparseStatus_t 
cusparseDcsrmv(cusparseHandle_t handle, cusparseOperation_t transA, 
               int m, int n, int nnz, const double          *alpha, 
               const cusparseMatDescr_t descrA, 
               const double          *csrValA, 
               const int *csrRowPtrA, const int *csrColIndA,
               const double          *x, const double          *beta, 
               double          *y)

    */
           status2=cusparseDcsrmv(handle,trans,n,n,nnz,&alpha,descrA,cscValACuda,cscRowPtrACudaPtr,cscColIndexACuda,xCuda,&beta,tmpCuda); 
           checkStatus(status2); 
	
           status3=cusparseDcsrmv(handle,trans,n,n,nnz,&alpha,descrA,cscValACuda,cscRowPtrACudaPtr,cscColIndexACuda,tmpCuda,&beta,yCuda);  
           checkStatus(status3);		 
   
     checkCuda(cudaMemcpy(yHost,yCuda,sizeof(double)*n,cudaMemcpyDeviceToHost));
    
     
     
     //free the cuda memory
	cudaFree(csrColIndexACuda);
	cudaFree(csrValACuda);
	cudaFree(csrRowPtrACudaPtr);
	cudaFree(cscColIndexACuda);
	cudaFree(cscValACuda);
	cudaFree(cscRowPtrACudaPtr);
	cudaFree(xCuda);
	cudaFree(yCuda);
	cudaFree(tmpCuda);
	
	
	//end measuring time
	cudaEventCreate(&stop);
	cudaEventRecord(stop,0);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&elapsedtime,start,stop);
	
	//print the output yHost
	
//print the answer : CUBLAS gives the answer placed in column major order
	printf("Answer : \n");	
	for(i=0;i<n;i++){
	        printf("%f \n",yHost[i]);
	
	}
	
	
	//print the time spent to stderr
	
	fprintf(stderr,"Time spent for operation on cusparse CUDA(Including memory allocation and copying) is %1.5f seconds\n",elapsedtime/(float)1000); 


 /*   if add any of these lines get this error: *** Error in `./BFSc': munmap_chunk(): invalid pointer: 0x00007fffb0a4b9f0 ***
Aborted (core dumped) */

    free(csrColIndexAHostPtr);
        free(csrRowPtrAHostPtr);
        free(csrValAHostPtr);
        free(xHost);
        free(yHost); 
	
        return 0;
}





