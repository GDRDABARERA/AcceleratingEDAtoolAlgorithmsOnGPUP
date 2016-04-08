# include <stdlib.h>
# include <limits.h>
# include <math.h>
# include <stdio.h>

# include "csparse.h"

int main ( void )
{
  cs *A;
  cs *AT;
  cs *C;
  cs *D;
  cs *Eye;

  cs *H;
  cs *G;
  cs *N;
  int i;
  int m;
  cs *T;
  FILE *file;
  file = fopen("kershaw.st","r");
  printf ( "\n" );
  printf ( "CS_DEMO1:\n" );
  printf ( "  Demonstration of the CSPARSE package.\n" );

  FILE *fp;
  fp = fopen("input.st","r");
/* 
  Load the triplet matrix T from standard input.
*/
  T = cs_load ( file );
  H = cs_load ( fp );	

printf ( "H:\n" ); 
  cs_print ( H, 0 );
/*
  Print T.
*/
  printf ( "T:\n" ); 
  cs_print ( T, 0 );
/*
  A = compressed-column form of T.
*/
  A = cs_triplet ( T );
  printf ( "A:\n" ); 
  cs_print ( A, 0 );
/*
  Clear T.
*/
  cs_spfree ( T );

  G = cs_triplet ( H );
  cs_spfree ( H );
/*
  AT = A'.
*/ 
  AT = cs_transpose ( A, 1 );
  printf ( "AT:\n" ); 
  cs_print ( AT, 0 );
/*
  M = number of rows of A.
*/
  m = A->m;
/*
  Create triplet identity matrix.
*/
  T = cs_spalloc ( m, m, m, 1, 1 );

  for ( i = 0; i < m; i++ ) 
  {
    cs_entry ( T, i, i, 1 );
  }
/* 
  Eye = speye ( m ) 
*/
  Eye = cs_triplet ( T );
  cs_spfree ( T );
/* 
  Compute C = A * A'.
*/
  //C = cs_multiply ( A, AT );
  C = cs_multiply (  AT,G);
  N = cs_multiply (  AT,C);
	printf ( "N:\n" ); 
  cs_print ( N, 0 );		
/* 
  Compute D = C + Eye * norm (C,1).
*/
/*  D = cs_add ( C, Eye, 1, cs_norm ( C ) );   

  printf ( "D:\n" ); 
  cs_print ( D, 0 );*/
/* 
  Clear A, AT, C, D, Eye, 
*/
  cs_spfree ( A );			
  cs_spfree ( AT );
  cs_spfree ( C );
  //cs_spfree ( D );
  cs_spfree ( Eye );
  cs_spfree ( G );
  cs_spfree ( N );
/*
  Terminate.
*/
  printf ( "\n" );
  printf ( "CS_DEMO1:\n" );
  printf ( "  Normal end of execution.\n" );

  return ( 0 );
}
