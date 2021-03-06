  
#include <stdio.h>
#include <stdlib.h>
#include "helpers.cuh"
  
struct Edge {
    int vertex;
    struct Edge * next;
};

 
// Inserts Node to the Linked List by Head Insertion - O(1)
// Returns address of head which is the newly created node.
struct Edge * AddEdge(struct Edge * currentHead, int newVertex){

    struct Edge * newHead;
    cudaMallocManaged(&newHead,sizeof(struct Edge)*1);	
    checkCudaError();
  
    newHead->vertex = newVertex;
    newHead->next = currentHead;
  
    return newHead;
}

__global__ void recursiveTraverse(int index, struct Edge ** adjacencyList,int * level,int * parent,int  levC, int * finalLevel){
                struct Edge * traverse;
               
                traverse = adjacencyList[index];
                
                 //next vertex in the next level
               
              
               
               while (traverse != NULL) {
                  int nextElement = traverse->vertex;
                 if(level[nextElement]==-1 ){
                        level[nextElement] = levC + 1;
                        parent[nextElement] = index;
                       if(levC+1!=*finalLevel) {
                              recursiveTraverse<<<1,1>>>(nextElement,adjacencyList,level,parent,levC+1,finalLevel);
                              cudaDeviceSynchronize();
                            
                       }
                 
                  }
                
                  traverse= traverse->next;
            
                }
                
       


}
 
 
__global__ void BreadthFirstSearch( struct Edge ** adjacencyList,
                        int * vertices,
                        int * parent,
                        int * level,
                        int* startVertices,int * lev, int * finalLevel,int count){
                        
                        
          int index = startVertices[threadIdx.x];
          
           if(index<count){
           recursiveTraverse<<<1,1>>> (index,adjacencyList,level,parent,*lev,finalLevel ); 
           cudaDeviceSynchronize();
           }
           
          
                  


} 


int main(){


cudaDeviceSetCacheConfig(cudaFuncCachePreferL1);
//cudaDeviceSetCacheConfig(cudaFuncCachePreferShared:);

   //global variable asigning
   
   int * vertices;
   int * edges;
   int * lev;
   int * level;
   int * parent;
   int * inputsCircuits;
   int * startArrayCount;
   int * finalLevel;
   struct Edge ** adjacencyList;
   
   
   //CPU variables only
   
   int v1,v2,i; //int levelSize=2;
   
   //unfied memory allocation for int values
   cudaMallocManaged(&vertices,sizeof(int)*1);	
   checkCudaError();
   cudaMallocManaged(&edges,sizeof(int)*1);	
   checkCudaError();
   cudaMallocManaged(&lev,sizeof(int)*1);	
   checkCudaError();
   cudaMallocManaged(&startArrayCount,sizeof(int)*1);	
   checkCudaError();
   cudaMallocManaged(&finalLevel,sizeof(int)*1);	
   checkCudaError();
   
   
   
   //*finalLevel = 2;
   //scan first line of graph data
    int noOfRows;
    FILE * graphFile =fopen("data3/circuitV2.txt","r");
    
    fscanf(graphFile,"%d" ,finalLevel);
    printf("Total  no of levels %d \n", *finalLevel);
    fscanf(graphFile, "%d %d %d",&noOfRows, vertices, edges);
        printf("No fo rows %d, No of Cols %d, nnz %d \n",noOfRows,*vertices,*edges);    //- done
        
        
    //unified memory allocation for arrays
   cudaMallocManaged(&level,sizeof(int)*(*vertices));	
   checkCudaError(); 
   cudaMallocManaged(&parent,sizeof(int)*(*vertices));	
   checkCudaError();
   cudaMallocManaged(&(adjacencyList),sizeof(struct Edge*)*(*vertices));	
   checkCudaError();   

   //initialise main arrays
        for (i = 0; i < *vertices; ++i) {
                adjacencyList[i] = NULL;
                parent[i] = 0;
                level[i] = -1;
         }
         
   //scan rest of the graph and create the adjacency list
   
        for (i = 0; i < *edges; ++i) {
                 int val;
                 fscanf(graphFile, "%d %d %d",&v1, &v2, &val);
          
                // Adding edge v1 --> v2
                adjacencyList[v1] = AddEdge(adjacencyList[v1], v2);
  
         }
         
    // Printing Adjacency List
           printf("\nAdjacency List - of graph \n\n");
            for (i = 0; i < *vertices; ++i) {
                printf("adjacencyList[%d] -> ", i);
          
                struct Edge * traverse = adjacencyList[i];
          
                while (traverse != NULL) {
                    printf("%d -> ", traverse->vertex);
                    traverse = traverse->next;
                }
          
                printf("NULL\n");
            }
            
     //scan the input vertices file, here only the input pins vertices are only available
     
      FILE * vectorFile= fopen("data3/inputV1.txt","r");
      fscanf(vectorFile,"%d",startArrayCount);
      
    //unified memory allocation for input vertice vector
       cudaMallocManaged(&inputsCircuits,sizeof(int)*(*startArrayCount));	
       checkCudaError(); 
       
    //asign values for input vector
      for(i=0;i<*startArrayCount;i++){
                int tempVal; 
                fscanf(vectorFile,"%d",&tempVal);
                inputsCircuits[i]= tempVal;
                level[tempVal]=0;
                
        }     

         *lev = 0;
        int count= *startArrayCount;
    //start Time measurement
	cudaEvent_t start,stop;
	float elapsedtime;
	cudaEventCreate(&start);
	cudaEventRecord(start,0);	
	//ceil(*vertices/256.0),256
	BreadthFirstSearch<<<ceil(count/256.0),256>>>(adjacencyList, vertices, parent, level, inputsCircuits, lev,finalLevel,count);
	cudaDeviceSynchronize();
	checkCudaError();

	//stop Time measurement
	cudaEventCreate(&stop);
	cudaEventRecord(stop,0);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&elapsedtime,start,stop);
	fprintf(stderr,"Time spent for kernel : %.10f seconds\n",elapsedtime/(float)1000);
	
	
	//print the output
	
	
	 printf("\nLevel and Parent Arrays -\n");
            for (i = 0; i < *vertices; ++i) {
                printf("Level of Vertex %d is %d, Parent is %d\n",
                                          i, level[i], parent[i]);
            }
            
            printf("vertices in level order when traversing :\n");
            
            int b;
             for(b=0;b<=*finalLevel;b++){
               for (i = 0; i < *vertices; ++i) {
                   if(level[i]==b){
                        printf("%d ,", i);
                   }
                  
               }
                printf("  |  ");
             }
             
             
             
        return 0;
}






