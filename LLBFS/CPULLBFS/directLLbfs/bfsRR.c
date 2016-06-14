  
#include <stdio.h>
#include <stdlib.h>
  
struct Edge {
    int vertex;
    struct Edge * next;
};

int NNZ; 
int i,  lev, flag = 1, finalLevel=2;  
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
  
  
 void recursiveTraverse(int index, struct Edge * adjacencyList[],int level[],int parent[],int lev){
 
                printf("Welcome to recursion %d \n",index);
 
   
                struct Edge * traverse;
               
                traverse = adjacencyList[index];
               
                int par = traverse->vertex;  //next vertex in the next level
                
               
               while (traverse != NULL) {
                
         
                   if (level[traverse->vertex] != -1) {
                        traverse = traverse->next;
                        continue;
                    }
                  
                       
                    level[traverse->vertex] = lev + 1;
                  
                    parent[traverse->vertex] = index;
                   
                    if((lev+1)!=finalLevel)    recursiveTraverse(par,adjacencyList,level,parent,lev+1);
                    
                }
                
    
                    
  }
 
void BreadthFirstSearch(
                        struct Edge * adjacencyList[],
                        int vertices,
                        int parent[],
                        int level[],
                        int startVertices[],int count
                       ){
                       
                       
 
    
    // 'lev' represents the level to be assigned
    // 'par' represents the parent to be assigned
    // 'flag' used to indicate if graph is exhausted
  
   lev=0;
    for(i=0;i<count;i++){
         int k =startVertices[i];
         level[k] = lev;
    
    }
    // We start at startVertex
  
        for(i=0;i<count;i++){
              int k =startVertices[i];
              
              recursiveTraverse(k,adjacencyList,level, parent,lev)  ; 
        }
} 
  
  
int main()
{
    int vertices, edges, v1, v2;
    
    
        int noOfRows,noOfCols,k=0;
        FILE * graphFile =fopen("data1/graph1.txt","r");
        fscanf(graphFile, "%d %d %d",&noOfRows, &noOfCols, &NNZ);
        printf("No fo rows %d, No of Cols %d, nnz %d \n",noOfRows,noOfCols,NNZ);    //- done
        vertices = noOfRows;
        edges =NNZ;
        
        
        struct Edge * adjacencyList[vertices];
            // Size is made (vertices + 1) to use the
            // array as 1-indexed, for simplicity
          
        int parent[vertices];
            // Each element holds the Node value of its parent
        int level[vertices];
            // Each element holds the Level value of that node
            
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
            
         int startArrayCount;
        FILE * vectorFile= fopen("data1/input1.txt","r");
        fscanf(vectorFile,"%d",&startArrayCount);
        
       int inputsCircuits[startArrayCount];
        
        for(i=0;i<startArrayCount;i++){
                int tempVal; 
                fscanf(vectorFile,"%d",&tempVal);
                inputsCircuits[i]= tempVal;
                printf("%d ,",inputsCircuits[i]);
        }
        printf("\n");
                 
        BreadthFirstSearch(adjacencyList, vertices, parent, level, inputsCircuits ,startArrayCount);
        
            // Printing Level and Parent Arrays
    printf("\nLevel and Parent Arrays -\n");
    for (i = 0; i < vertices; ++i) {
        printf("Level of Vertex %d is %d, Parent is %d\n",
                                  i, level[i], parent[i]);
    }
  
  
    return 0;
    
}
