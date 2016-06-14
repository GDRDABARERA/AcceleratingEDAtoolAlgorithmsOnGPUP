/* ==========  ========== ========== ========= */
//         Breadth First Search (BFS)          //
//               Algorithm in CUDA         //
/* ========== ========== ========== ========== */
  
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>
#include "helpers.cuh"
#include <assert.h>
  

struct Edge {
    int vertex;
    struct Edge * next;
};

 struct Edge **  adjacencyList;
    // Size is made (vertices + 1) to use the
    // array as 1-indexed, for simplicity
    
 /*All global variables comes here**/   
    
    
  int * parent;                                    //int parent[vertices + 1];
    // Each element holds the Node value of its parent
  int  * level; int * startVertices;
  int * inputsCircuits;
  int * lev;
  int *flag;  
  int   startArrayCount;                                  //int level[vertices + 1];
    // Each element holds the Level value of that node 
//define variables in unified memory

  int  * vertices;
  int  * edges;
  int v1,v2,i;

 __device__ void recursiveTraverse(int lev, struct Edge * adjacencyList[],int level[],int parent[],int i,int vertices){
                int par;
         struct Edge * traverse;
            if ((level[i] == lev)&(i<vertices)) {
                flag = 1;
                traverse = adjacencyList[i];
                par = i;
                printf("%d \n",par);
                while (traverse != NULL) {
                    if (level[traverse->vertex] != -1) {
                        traverse = traverse->next;
                        continue;
                    }
  
                    level[traverse->vertex] = lev + 1;
                    printf("%d ",level[traverse->vertex]);
                    parent[traverse->vertex] = par;
                    traverse = traverse->next;
                    ++i;
                    recursiveTraverse(lev,adjacencyList,level,parent,i,vertices);
                    
                }
            }else if(i<vertices){
                 ++i;
                recursiveTraverse(lev,adjacencyList,level,parent,i,vertices);
            }
        
 }
  
// Inserts Node to the Linked List by Head Insertion - O(1)
// Returns address of head which is the newly created node.
struct Edge * AddEdge(struct Edge * currentHead, int newVertex)
{
    struct Edge * newHead
                 = (struct Edge *) malloc(sizeof(struct Edge));
  
    newHead->vertex = newVertex;
    newHead->next = currentHead;
  
    return newHead;
}
  
__global__ void BreadthFirstSearch(
                        struct Edge * adjacencyList[],
                        int vertices,
                        int parent[],
                        int level[],
                        int startVertices[],int count
                       ){
                       
                       
 int i;
    
    // 'lev' represents the level to be assigned
    // 'par' represents the parent to be assigned
    // 'flag' used to indicate if graph is exhausted
    
     cudaStream_t s1;
     cudaStreamCreateWithFlags(&s1,cudaStreamNonBlocking);
  
   lev=0;
    for(i=0;i<count;i++){
         int k =startVertices[i];
         level[k] = lev;
    
    }
    // We start at startVertex
  
    while (flag) {
        flag = 0;
        recursiveTraverse<<<1,1,0,s1>>>(lev,adjacencyList,level,parent,0,vertices);
  
        ++lev;
    }
} 



 
int main()
{
        
        
        
        cudaDeviceProp prop;
        cudaGetDeviceProperties(&prop, 0);
        cudaSetDevice(0);
             

    
        int NNZ;
        int noOfRows,noOfCols;
        FILE * graphFile =fopen("graph.txt","r");
        fscanf(graphFile, "%d %d %d",&noOfRows, &noOfCols, &NNZ);
        printf("No fo rows %d, No of Cols %d, nnz %d \n",noOfRows,noOfCols,NNZ);    //- done
        vertices = noOfRows;
        edges =NNZ;

        

  cudaMallocManaged(&parent,vertices*sizeof(int));
  cudaMallocManaged(&level,vertices*sizeof(int));
  cudaMallocManaged(&adjacencyList,vertices*sizeof(struct Edge *)); 
  cudaMallocManaged(&vertice, 1*sizeof(int));
  cudaMallocManaged(&edge, 1*sizeof(int));
  cudaMallocManaged(&lev, 1*sizeof(int));
  cudaMallocManaged(&flag, 1*sizeof(int));
  
  flag=1;
  
 // Must initialize your array
         for (i = 0; i < vertices; ++i) {
                adjacencyList[i] = NULL;
                parent[i] = 0;
                level[i] = -1;
         }
         
          for (i = 0; i < edges; ++i) {
                 int val;
                 fscanf(graphFile, "%d %d %d",&v1, &v2, &val);
          
                // Adding edge v1 --> v2
                adjacencyList[v1] = AddEdge(adjacencyList[v1], v2);
          
                // Adding edge v2 --> v1
                // Remove this if you want a Directed Graph
               // adjacencyList[v2] = AddEdge(adjacencyList[v2], v1);
         }
         
         // Printing Adjacency List
         printf("\nAdjacency List - of graph \n\n");
            for (i = 0; i < vertices; ++i) {
                printf("adjacencyList[%d] -> ", i);
          
                struct Edge * traverse = adjacencyList[i];
          
                while (traverse != NULL) {
                    printf("%d -> ", traverse->vertex);
                    traverse = traverse->next;
                }
          
                printf("NULL\n");
            }
            
        printf("geting starting list of inputs:\n");
            
        
         
         
        FILE * vectorFile= fopen("input.txt","r");
        fscanf(vectorFile,"%d",&startArrayCount);
        
     //  int inputsCircuits[startArrayCount];
     
        cudaMallocManaged(&inputsCircuits,startArrayCount*sizeof(int));
        
        for(i=0;i<startArrayCount;i++){
                int tempVal; 
                fscanf(vectorFile,"%d",&tempVal);
                inputsCircuits[i]= tempVal;
                printf("%d ,",inputsCircuits[i]);
        }
        printf("\n");
        
        
        
        cudaEvent_t start,stop;
	float elapsedtime;
	cudaEventCreate(&start);
	cudaEventRecord(start,0);	
  
          BreadthFirstSearch<<<1,1>>>(adjacencyList, vertices, parent, level, inputsCircuits ,startArrayCount);
     
          cudaDeviceSynchronize();
	  checkCudaError();

	//stop Time measurement
	cudaEventCreate(&stop);
	cudaEventRecord(stop,0);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&elapsedtime,start,stop);
	fprintf(stderr,"Time spent for kernel : %.10f seconds\n",elapsedtime/(float)1000);
     
     
  
    // Printing Level and Parent Arrays
    printf("\nLevel and Parent Arrays -\n");
    for (i = 1; i <= vertices; ++i) {
        printf("Level of Vertex %d is %d, Parent is %d\n",
                                  i, level[i], parent[i]);
    }
  
    return 0;
}
