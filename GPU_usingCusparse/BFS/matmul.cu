/* Program to do matrix multiplication in cuda
This program generates two matrices and multiply them*/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "helpers.cuh"

//Dimensions for matrix1
#define ROWS1 10
#define COLS1 20

//DImensions for matrix2
#define ROWS2 20
#define COLS2 15

/** CUDA kernel to do matrix multiplication**/
__global__ void matMul(int *matC_cuda, int *matA_cuda, int *matB_cuda){
	
	//derive the row and column based on thread configuration
	int row = blockIdx.y*blockDim.y + threadIdx.y;
	int col = blockIdx.x*blockDim.x + threadIdx.x;
	
	//Limit calculations for valid indices
	if(row < ROWS1 && col < COLS2){
	
		int prod=0;
		int k;
		for(k=0;k<COLS1;k++){
			prod=prod+matA_cuda[row*COLS1+k]*matB_cuda[k*COLS2+col];
		}
		matC_cuda[row*COLS2+col]=prod;	
		
	}
	
}

int main(){
	
	//check whether dimensions are valid for matrix mutiplication
	if(COLS1!=ROWS2){
		printf("Matrix dimensions are invalid for matrix multiplication\n");
		exit(1);
	}
	
	//Initialize arrays in RAM
	int matA[ROWS1*COLS1];
	int matB[ROWS2*COLS2];
	int matC[ROWS1*COLS2];	
	
	//generate some values for matrixA
	int i,j;
	for(i=0;i<ROWS1;i++){
		for(j=0;j<COLS1;j++){
			matA[i*COLS1+j]=i+j;
		}
	}

	//print the matA
	printf("Matrix A : \n");
	for(i=0;i<ROWS1;i++){
		for(j=0;j<COLS1;j++){
			printf("%5d ",matA[i*COLS1+j]);
		}
		printf("\n");
	}		
	printf("\n");

	
	//generate values for matrixB
	for(i=0;i<ROWS2;i++){
		for(j=0;j<COLS2;j++){
			matB[i*COLS2+j]=i-j;
		}
	}

	//print the matB
	printf("Matrix B : \n");
	for(i=0;i<ROWS2;i++){
		for(j=0;j<COLS2;j++){
			printf("%5d ",matB[i*COLS2+j]);
		}
		printf("\n");
	}	
	printf("\n");

	/********************************** CUDA stuff starts here *******************************/
	
	//pointers for memory allocation in cudaa
	int *matA_cuda;
	int *matB_cuda;
	int *matC_cuda;
	
	//allocate memory in cuda
	checkCuda(cudaMalloc((void **)&matA_cuda,sizeof(int)*ROWS1*COLS1));
	checkCuda(cudaMalloc((void **)&matB_cuda,sizeof(int)*ROWS2*COLS2));
	checkCuda(cudaMalloc((void **)&matC_cuda,sizeof(int)*ROWS1*COLS2));
	
	//copy memory from ram to cuda
	checkCuda(cudaMemcpy(matA_cuda,matA,sizeof(int)*ROWS1*COLS1,cudaMemcpyHostToDevice));
	checkCuda(cudaMemcpy(matB_cuda,matB,sizeof(int)*ROWS2*COLS2,cudaMemcpyHostToDevice));
	
	//multiply the matrices in cuda
	dim3 threadsPerBlock(16,16);
	dim3 numBlocks(ceil(COLS2/(float)16),ceil(ROWS1/(float)16));
	matMul<<<numBlocks,threadsPerBlock>>>(matC_cuda,matA_cuda,matB_cuda);
	checkCuda(cudaGetLastError());
	
	//copy the answer back from cuda to ram
	checkCuda(cudaMemcpy(matC,matC_cuda,sizeof(int)*ROWS1*COLS2,cudaMemcpyDeviceToHost));

	//free the cuda memory
	checkCuda(cudaFree(matA_cuda));
	checkCuda(cudaFree(matB_cuda));
	checkCuda(cudaFree(matC_cuda));
	
	/********************** CUDA stuff ends here ********************************/
	
	//print the answer
	printf("Answer : \n");	
	for(i=0;i<ROWS1;i++){
		for(j=0;j<COLS2;j++){
			printf("%5d ",matC[i*COLS2+j]);
		}
		printf("\n");
	}	

	return 0;

}
