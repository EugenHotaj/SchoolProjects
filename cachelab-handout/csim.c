//*****************************************************************//
//Eugen Hotaj                Cache Lab                 esh322      //
//*****************************************************************//

#include <stdlib.h>
#include <stdio.h>
#include <getopt.h>
#include <strings.h>

#include "cachelab.h"

/* Always use a 64-bit variable to hold memory addresses*/
typedef unsigned long long int mem_addr_t;

//Declare and initialize variables
int miss_count = 0;
int hit_count = 0;
int evict_count = 0;

/* a struct that groups cache parameters together */
typedef struct {
  int s; /* 2**s cache sets */
  int b; /* cacheline block size 2**b bytes */
  int E; /* number of cachelines per set */
  int S; /* number of sets, derived from S = 2**s */
  int B; /* cacheline block size (bytes), derived from B = 2**b */
} cache_param_t;

//Declare the line Struct
typedef struct {
  int tag;
  int valid;
  int timeStamp;
} line;

int verbosity;

/*
 * printUsage - Print usage info
 */
void printUsage(char* argv[])
{
  printf("Usage: %s [-hv] -s <num> -E <num> -b <num> -t <file>\n", argv[0]);
  printf("Options:\n");
  printf("  -h         Print this help message.\n");
  printf("  -v         Optional verbose flag.\n");
  printf("  -s <num>   Number of set index bits.\n");
  printf("  -E <num>   Number of lines per set.\n");
  printf("  -b <num>   Number of block offset bits.\n");
  printf("  -t <file>  Trace file.\n");
  printf("\nExamples:\n");
  printf("  %s -s 4 -E 1 -b 4 -t traces/yi.trace\n", argv[0]);
  printf("  %s -v -s 8 -E 2 -b 4 -t traces/yi.trace\n", argv[0]);
  exit(0);
}

int main(int argc, char **argv)
{
  
  cache_param_t par;
  bzero(&par, sizeof(par));
  
  char *trace_file;
  char c;
  while( (c=getopt(argc,argv,"s:E:b:t:vh")) != -1){
    switch(c){
    case 's':
      par.s = atoi(optarg);
      break;
    case 'E':
      par.E = atoi(optarg);
      break;
    case 'b':
      par.b = atoi(optarg);
      break;
    case 't':
      trace_file = optarg;
      break;
    case 'v':
      verbosity = 1;
      break;
    case 'h':
      printUsage(argv);
      exit(0);
    default:
      printUsage(argv);
      exit(1);
    }
  }
  
  if (par.s == 0 || par.E == 0 || par.b == 0 || trace_file == NULL) {
    printf("%s: Missing required command line argument\n", argv[0]);
    printUsage(argv);
    exit(1);
  } 
  
  //Find number of sets and block size
  par.S = 1 << par.s;
  par.B = 1 << par.b;
  
  //Create and initialize the cache
  int cacheSize = par.S * par.E;
  line cache[cacheSize];

  int i;
  for(i = 0; i < cacheSize; i++){
    cache[i].tag = 0;
    cache[i].timeStamp = 0;
    cache[i].valid = 0;
  }
  
  //Open file
  FILE *traceFilePointer;
  if((traceFilePointer = fopen(trace_file,"r")) == NULL){
    printf("Problem with traceFilePointer\n");
    exit(0);
  }
  
  //Define needed variables
  char buff[255];
  int ts = 0;
  mem_addr_t nextAdd;
  mem_addr_t tag;
  mem_addr_t setID;
  char nextInst;
  char address[25];

  //Parse the file and input values in cache
  while(fgets(buff,255,(FILE*) traceFilePointer)!=NULL){
        
    //Null out the adress
    for(int i = 0; i < 25; i++){
      address[i] = '\0';
    }
      
    //Parse the file and obtain the string adress and instruction type
    int i=0;
    int j=0;
    int isI = 0;
    while(/* buff[i] != '\n' && */ buff[i] != ','){
      if(buff[i] == 'I'){
	i++;
	isI = 1;
	break;
      }
      if(buff[i] == ' '){
	i++;
	if(verbosity){printf("%c",buff[i]);}
	continue;
      }
      if(buff[i] == 'M' || buff[i] == 'L' || buff[i] == 'S'){
	nextInst = buff[i];
	i++;
	if(verbosity){printf("%c",buff[i]);}
	continue;
      }
      address[j++] = buff[i];
      i++;
      if(verbosity){printf("%c",buff[i]);}
    }
    
    //Break out of main while loop if an I instruciton is found
    if(isI){continue;}

    //Print out part the rest of the valgrind instructions (following the comma)
    if(verbosity){
      i++; //increment i so we can skip the "," character
      while(buff[i]!='\n'){
	printf("%c",buff[i]);
	i++;
      }
    }
    
    //convert string address to numerical address, find tag and setID
    nextAdd =(mem_addr_t)strtoull(address,NULL,16);
    tag = nextAdd >> (par.b+par.s);
    setID = (nextAdd >> par.b) & ((1<<par.s) - 1);
    
    //If we have an M instruction then we perform a L followed by a S (two cache instructions)
    int howMany = 1;
    if (nextInst == 'M'){
      howMany = 2;
    }

    int x;
    for(x = 0; x < howMany; x++){
      //increment timestamp
      ts++;
      
      //Check to see if data is in cache (hit)
      int ishit = 0;
      int i2;
      for(i2 = 0; i2 < par.E; i2++){
	if((cache[setID*par.E+i2].tag == tag) && (cache[setID*par.E+i2].valid)){
	  cache[setID*par.E+i2].timeStamp = ts;
	  hit_count++;
	  if(verbosity){printf(" hit");} 
	  ishit = 1;
	  break;
	}
      }
      
      //If data is not in the cache...
      if(!ishit){
	miss_count++;
	if(verbosity){printf(" miss");}
	
	//...find an empty spot (if possible) to insert the data
	int wasEmpty = 0;
	int i3;
	for(i3 = 0; i3 < par.E; i3++){
	  if(!cache[setID*par.E+i3].valid){
	    cache[setID*par.E+i3].valid = 1;
	    cache[setID*par.E+i3].tag = tag;
	    cache[setID*par.E+i3].timeStamp = ts;
	    wasEmpty = 1;
	    break;
	  }
	}
	
	//...otherwise evict the Least Recently Used data and overwrite
	if(!wasEmpty){
	  evict_count++;
	  if(verbosity){printf(" eviction");}
	  int LRUi = 0;
	  int LRUStamp = cache[setID*par.E].timeStamp;
	  int i4;
	  for(i4 = 0; i4 < par.E; i4++){
	    if(cache[setID*par.E+i4].timeStamp < LRUStamp){
	      LRUStamp = cache[setID*par.E+i4].timeStamp;
	      LRUi = i4;
	    }
	  }
	  cache[setID*par.E+LRUi].tag = tag;
	  cache[setID*par.E+LRUi].timeStamp = ts;
	}
      }
    }
    if(verbosity){printf("\n");}
  }
  //Close the file
  fclose(traceFilePointer);
  
  printSummary(hit_count, miss_count, evict_count);
  return 0;
}
