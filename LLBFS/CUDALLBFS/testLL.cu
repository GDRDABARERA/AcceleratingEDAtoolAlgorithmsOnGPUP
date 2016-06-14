#include <stdio.h>
#define NUM_ELE 5

struct ListElem{

   int id;
   bool last;
   ListElem *next;
};

__global__ void test_kernel(ListElem *list){

  int count = 0;
  while (!(list->last)){
    printf("List element %d has id %d\n", count++, list->id);
    list = list->next;}
  printf("List element %d is the last item in the list\n", count);
}

int main(){
  ListElem *h_list, *my_list;
  cudaHostAlloc(&h_list, sizeof(ListElem), cudaHostAllocDefault);
  my_list = h_list;
  for (int i = 0; i < NUM_ELE-1; i++){
    my_list->id = i+101;
    my_list->last = false;
    cudaHostAlloc(&(my_list->next), sizeof(ListElem), cudaHostAllocDefault);
    my_list = my_list->next;}
  my_list->last = true;
  test_kernel<<<1,1>>>(h_list);
  cudaDeviceSynchronize();
}
