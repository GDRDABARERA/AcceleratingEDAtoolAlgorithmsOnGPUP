  
#include <stdio.h>
#include <stdlib.h>
#include "helpers.cuh"

 struct Element{
        int value;
        int yPosition;
        
        struct Element * next;
};


// Inserts Node to the Linked List by Head Insertion - O(1)
// Returns address of head which is the newly created node.
struct Element * AddElement(struct Element * currentHead, int newValue, int newYposition){
    struct Element * newHead;
               //  = (struct Element *) malloc(sizeof(struct Element));
    cudaMallocManaged(&newHead,sizeof(struct Element)*1);	
    checkCudaError();
  
    newHead->value = newValue;
    newHead->yPosition= newYposition;
    newHead->next = currentHead;
  
    return newHead;
}
 
 
__global__ void childtestkernelbfs( struct Element ** adjacencyList,
                        int * vertices,
                        int* inputV, int * finalLevel,int * output){
                        
                        
    
           
          int index = blockIdx.x*blockDim.x+threadIdx.x;
          
          
 
          
          
          if(*finalLevel>0 & index<*vertices){
                  printf("This is the FinalLevel : %d\n",*finalLevel);
                  
                  struct Element * traverse = adjacencyList[index];
                  
         
          
                if(traverse==NULL){
                        output[index]=0;
                                
                }else{
                       
                        int ans=0;
                        __syncthreads();
                        while (traverse != NULL) {
                               
                            int val = (traverse->value )*(inputV[traverse->yPosition]);
                            
                            
                            
                            ans= ans+ val;
                          printf("step in traversing %d* %d = val:%d , ans: %d\n",inputV[traverse->yPosition],traverse->value,val,ans);
                           // assert(traverse==NUL);
                           traverse = traverse->next;
                        } 
                       
                        
                        output[index]=ans;
                        
                         __syncthreads();
                }
         
                     /*     *finalLevel --;
                         printf("finalLevel is :%d", *finalLevel);  
	                 childtestkernelbfs<<<ceil(*vertices/256.0),256>>>(adjacencyList, vertices ,output, finalLevel, inputV);
	               
	                cudaDeviceSynchronize(); */
	               // checkCudaError(); 
           
           
       
                  
        }
      

} 

__global__ void parentkernel(struct Element ** adjacencyList,
                        int * vertices,
                        int* inputV, int * finalLevel,int * output){
                        printf("parent kernel call \n");
                        childtestkernelbfs<<<1,*vertices>>>(adjacencyList, vertices , inputV, finalLevel,output);
                        cudaDeviceSynchronize();
	               

}


int main(){


cudaDeviceSetCacheConfig(cudaFuncCachePreferL1);
//cudaDeviceSetCacheConfig(cudaFuncCachePreferShared:);

   //global variable asigning
   
   int * vertices;
   int * edges;
   int * inputArray;
   int * outputArray;
   int * startArrayCount;
   int * finalLevel;
   struct Element ** adjacencyList;
   
   
   //CPU variables only
   
   int v1,v2,i; //int levelSize=2;
   
   //unfied memory allocation for int values
   cudaMallocManaged(&vertices,sizeof(int)*1);	
   checkCudaError();
   cudaMallocManaged(&edges,sizeof(int)*1);	
   checkCudaError();
   cudaMallocManaged(&startArrayCount,sizeof(int)*1);	
   checkCudaError();
   cudaMallocManaged(&finalLevel,sizeof(int)*1);	
   checkCudaError();
   
   *finalLevel = 2;
   int modLevel= (*finalLevel)%2;
   //scan first line of graph data
    int noOfRows;
    FILE * graphFile =fopen("dataT/graphT.txt","r");
    fscanf(graphFile, "%d %d %d",&noOfRows, vertices, edges);
        printf("No fo rows %d, No of Cols %d, nnz %d \n",noOfRows,*vertices,*edges);    //- done
        

   cudaMallocManaged(&(adjacencyList),sizeof(struct Elemnt*)*(*vertices));	
   checkCudaError();   

   //initialise main arrays
        for (i = 0; i < *vertices; ++i) {
                adjacencyList[i] = NULL;
            
         }
         
   //scan rest of the graph and create the adjacency list
   
        for (i = 0; i < *edges; ++i) {
                 int val;
                 fscanf(graphFile, "%d %d %d",&v1, &v2, &val);
          
                // Adding edge v1 --> v2
                adjacencyList[v1] = AddElement(adjacencyList[v1], v2,val);
  
         }
         
    // Printing Adjacency List
           printf("\nAdjacency List - of graph \n\n");
            for (i = 0; i < *vertices; ++i) {
                printf("adjacencyList[%d] -> ", i);
          
                struct Element * traverse = adjacencyList[i];
          
                while (traverse != NULL) {
                    printf("(%d,%d) -> ", traverse->value, traverse->yPosition);
                    traverse = traverse->next;
                }
          
                printf("NULL\n");
            }
            
     //scan the input vertices file
     
      FILE * vectorFile= fopen("dataT/input.txt","r");
      fscanf(vectorFile,"%d",startArrayCount);
      
    //unified memory allocation for input vertice vector
       cudaMallocManaged(&inputArray,sizeof(int)*(*startArrayCount));	
       checkCudaError(); 
       cudaMallocManaged(&outputArray,sizeof(int)*(*startArrayCount));	
       checkCudaError(); 
       
    //asign values for input vector
      for(i=0;i<*startArrayCount;i++){
                int tempVal; 
                fscanf(vectorFile,"%d",&tempVal);
                inputArray[i]= tempVal;
                printf("%d ,",inputArray[i]);
        }     

       
       // int count= *startArrayCount;
        
    //start Time measurement
	cudaEvent_t start,stop;
	float elapsedtime;
	cudaEventCreate(&start);
	cudaEventRecord(start,0);	
	
	parentkernel<<<1,1>>>(adjacencyList, vertices , inputArray, finalLevel,outputArray);
	cudaDeviceSynchronize();
	checkCudaError();

	//stop Time measurement
	cudaEventCreate(&stop);
	cudaEventRecord(stop,0);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&elapsedtime,start,stop);
	fprintf(stderr,"Time spent for kernel : %.10f seconds\n",elapsedtime/(float)1000);
	
	
	//print the output
	
	
     printf("\nthe final output vector is:\n");
        if(modLevel==0){
                for(i=0;i<*vertices;i++){
                        printf("%d,", outputArray[i]);
                
                }
        }else{
        
                 for(i=0;i<*vertices;i++){
                        printf("%d,", inputArray[i]);
                
                }
        
        }     
             
        return 0;
}






