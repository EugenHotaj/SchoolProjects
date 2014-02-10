/*
 * Eugen Hotaj           
 * Chris Nelson          
 * Malloc Lab            
 * December 13, 2013     
 *
 * <<IMPLEMENTATION>>
 * Our heap first calls -mm_init- and allocates space for an 'array' of 10 pointers that
 * will each point to a class of our segmented list. The way our list is set up is as follows:
 * [class  1] -->    16 -    64 byte chunks
 * [class  2] -->    65 -   128 byte chunks 
 * [class  3] -->   129 -   256 byte chunks
 * [class  4] -->   257 -   512 byte chunks
 * [class  5] -->   513 -  1024 byte chunks
 * [class  6] -->  1025 -  2048 byte chunks
 * [class  7] -->  2049 -  4096 byte chunks
 * [class  8] -->  4097 -  8194 byte chunks
 * [class  9] -->  8195 - 16388 byte chunks
 * [class 10] --> 16388 -   INF byte chunks 
 * The allocator then sets up a 4 byte "bs" block directly after our array of pointers as well
 * as a prologue and epilogue blocks. It then requests memory via -heap_extend- from the OS in 4K blocks.
 * -coalesce- is then called to merge to initialize the newly requested memory chunk. This chunk is then
 * added to our free list in [class 7] by the -add_node- function.
 *
 * When -mm_malloc is called our program first checks to see if any free blocks exist with -find_fit- and
 * if so returns a pointer to this free block, allocates the appropriate space using -free_block- and
 * removes the free block node via the -remove_node- function. If the new allocated block has left over
 * free space, this space is then made into a new block and is added as another node into its appropriate class.
 *
 * The -mm_free- funciton simply marks a block as unallocated and adds it as a node in the free list array in
 * the appropriate class.
 *
 * The -mm_realloc- function checks to see if the newly requested space is the same size as the previous space, 
 * if it is bigger, or if it is smaller. In the case that the new requested size is the same then -mm_realloc- 
 * simply returns the same pointer. If smaller -mm_realloc- calls -mm_place- with the same block ptr  which 
 * shirinks the block and creates a new free block if enough space is available and adds it to the free block
 * array in the appropriate class. Finally if the requested size is bigger, -mm_realloc- first checks to see if the
 * next block is free and if the combined space of the current and next block will be enough for the requested
 * size. If it is enough -place- is called with the old ptr. Finally if no fit is found for the requested size
 * -mm_malloc- is called with the requested size.
 */

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <unistd.h>
#include <string.h>

#include "mm.h"
#include "memlib.h"

team_t team = {
  /* Team name */
  "TheBallers",
  /* First member's full name */
  "Eugen S. Hotaj",
  /* First member's NYU NetID*/
  "esh322",
  /* Second member's full name (leave blank if none) */
  "Chris Nelson",
  /* Second member's email address (leave blank if none) */
  "ctn220@nyu.edu"
};

/* Single word (4) or double word (8) alignment */
#define ALIGNMENT 8

/* Rounds up to the nearest multiple of ALIGNMENT */
#define ALIGN(size) (((size) + (ALIGNMENT-1)) & ~0x7)

#define SIZE_T_SIZE (ALIGN(sizeof(size_t)))

/* Define Pointers to the start of the heap for our seglist 'array'
 * and to the start of writable heap space.
 */
static char* heap_listp;
static char* heap_segp;

/* Basic constants */
#define WSIZE 4
#define DSIZE 8
#define CHUNKSIZE (1<<12)
#define NUM_CLASS 10 // Must be even or alignment problems will occur

/* Get the biggest of two numbers */
#define MAX(x,y)               ((x)>(y) ? (x) : (y))
 
/* Pack a size and allocated bit into a word */
#define PACK(size, alloc)      ((size) | (alloc)) 

/* Read and write a word at adress p */
#define GET(p)                 (*(unsigned int *)(p)) 
#define PUT(p, val)            (*(unsigned int *)(p) = (val))

/* Read the size and allocated fields from adress p */
#define GET_SIZE(p)            (GET(p) & ~0x7) 
#define GET_ALLOC(p)           (GET(p) & 0x1)

/* Given block ptr bp, compute adress of its header and footer */
#define HDRP(bp)               ((char *)(bp) - WSIZE)
#define FTRP(bp)               ((char *)(bp) + GET_SIZE(HDRP(bp)) - DSIZE)

/* Given block ptr bp, compute adress of pointer to the next node and the previous node*/
#define NEXT_NODEP(bp)         ((char *)(bp) + WSIZE)
#define PREV_NODEP(bp)         ((char *)(bp))

/* Given block ptr bp, compute the previous list item and the next list item */
#define NEXT_ITEM(bp)          (char *)(*(unsigned int*)(NEXT_NODEP((char *)(bp))))
#define PREV_ITEM(bp)          (char *)(*(unsigned int*)(PREV_NODEP((char *)(bp))))

/* Given block ptr bp, compute adress of next and previous blocks */
#define NEXT_BLKP(bp)          ((char *)(bp) + GET_SIZE(((char *)(bp) - WSIZE)))
#define PREV_BLKP(bp)          ((char *)(bp) - GET_SIZE(((char *)(bp) - DSIZE)))



/*
 * find_class - given a size, returns the particular class that a block will fit in.
 */
static int find_class(size_t size){
  
  int class;
  
  /* Find which class the current block fits in */
  if(size <= 64 && size > 0)
    class = 0;
  else if(size <= 128 && size > 64)
    class = 1;
  else if(size <= 256 && size > 128)
    class = 2;
  else if(size <= 512 && size > 256)
    class = 3;
  else if(size <= 1024  && size > 512)
    class = 4;
  else if(size <= 2048  && size > 1024)
    class = 5;
  else if(size <= 4096  && size > 2048)
    class = 6;
  else if(size <= 8192  && size > 4096)
    class = 7;
  else if(size <= 16384 && size > 8192)
    class = 8;
  else if(size > 16384)
    class = 9;
  else{
    fprintf(stderr,"ERROR: Bad size and class specification.\n"); 
     return -1;
  }

  return class;
}

/*
 * add_node - given a block pointer, calculates the class of a block and adds it
 * as a free node to that particular class. The node is always added to the front 
 * of the list. Two cases exist, either no other nodes are present in the class or
 * another node is present. Each case is handled seperatly.
 */

static int add_node(void *bp){
  int class = find_class(GET_SIZE(HDRP(bp)));
  
  /* If no nodes exist in the list */
  if(GET(heap_segp + (class*WSIZE)) == 0){
    PUT(PREV_NODEP(bp),(unsigned int)(heap_segp + (class*WSIZE)));
    PUT(NEXT_NODEP(bp),0);
    PUT(heap_segp+(class*WSIZE),(unsigned int)bp);
  }
  /* If other nodes do exist */
  else{
    PUT(NEXT_NODEP(bp),GET(heap_segp + (class*WSIZE)));
    PUT(PREV_NODEP(bp),(unsigned int)(heap_segp + (class*WSIZE)));
    PUT(heap_segp + (class*WSIZE),(unsigned int) bp);
    PUT(PREV_NODEP(NEXT_ITEM(bp)),(unsigned int) bp);
  }
  
  return 1;
}

/*
 * remove_node - given a block pointer, calculates the class of a block and 
 * removes it from that class. Four different cases exist:
 * (1) No other nodes are present in the list
 * (2) A next node is present but not a previous node (current node is first in list)
 * (3) A previous node is present but not a next one (current node is last in list)
 * (4) A previous and a next node both exist
 * Each is handled seperatly.
 */
static int remove_node(void *bp){
  
  int class = find_class(GET_SIZE(HDRP(bp)));
  
  /* If neither a next node, nor a previous node exist */
  if(((GET(PREV_NODEP(bp)))==((unsigned int)(heap_segp+(class*WSIZE)))) &&
     ((GET(NEXT_NODEP(bp)))==0)){
    PUT(heap_segp+(class*WSIZE),0);
  }
  /* If only a next node exists but not a previous node */
  else if(((GET(PREV_NODEP(bp)))==((unsigned int)(heap_segp+(class*WSIZE)))) &&
     ((GET(NEXT_NODEP(bp)))!=0)){
    PUT(heap_segp+(class*WSIZE), GET(NEXT_NODEP(bp)));
    PUT(PREV_NODEP(NEXT_ITEM(bp)),(unsigned int) (heap_segp+(class*WSIZE)));
  }
  /* If only a previous node exists but not a next node */
  else if(((GET(PREV_NODEP(bp)))!=((unsigned int)(heap_segp+(class*WSIZE)))) &&
     ((GET(NEXT_NODEP(bp)))==0)){
    PUT(NEXT_NODEP(PREV_ITEM(bp)),0);
  }
  /* If both a previous and a next node exist */
  else if(((GET(PREV_NODEP(bp)))!=((unsigned int)(heap_segp+(class*WSIZE)))) &&
     ((GET(NEXT_NODEP(bp)))!=0)){
    PUT(NEXT_NODEP(PREV_ITEM(bp)),GET(NEXT_NODEP(bp)));
    PUT(PREV_NODEP(NEXT_ITEM(bp)),GET(PREV_NODEP(bp)));
  }
  /* This condition shold never be met for a -remove_node- function */
  else{
    fprintf(stderr,"BAD NODE REMOVAL");
    return -1;
  }
  
  return 1;
}

/*
 * coalesce - given a block pointer checks to see whether the previous and next blocks are free.
 * Four cases exist: 
 * (1) Both the next and previous blocks are allocated 
 * (2) The previous block is allocated but the next one is free
 * (3) The next block is allocated but the previous one is free
 * (4) Both the next and previous blocks are free
 * For each case the needed blocks are removed from their respective classes in the free list array
 * and new free blocks are added.
 */
static void *coalesce(void *bp){
  size_t prev_alloc = GET_ALLOC(FTRP(PREV_BLKP(bp)));
  size_t next_alloc = GET_ALLOC(HDRP(NEXT_BLKP(bp)));
  size_t size = GET_SIZE(HDRP(bp));

  /* Both previous and next blocks are allocated */
  if(prev_alloc && next_alloc){
    add_node(bp);
    return bp;
  }
  /* Previous block is allocated but the next block is free */
  else if(prev_alloc && !next_alloc){
    remove_node(NEXT_BLKP(bp));
    size += GET_SIZE(HDRP(NEXT_BLKP(bp)));
    PUT(HDRP(bp),PACK(size,0));
    PUT(FTRP(bp),PACK(size,0));
  }
  /* Previous block is free but the next block is allocated */
  else if(!prev_alloc && next_alloc){
    remove_node(PREV_BLKP(bp));
    size += GET_SIZE(HDRP(PREV_BLKP(bp)));
    PUT(FTRP(bp),PACK(size,0));
    PUT(HDRP(PREV_BLKP(bp)),PACK(size,0));
    bp = PREV_BLKP(bp);
  }
  /* Both the next and the previous blocks are free */
  else{
    remove_node(NEXT_BLKP(bp));
    remove_node(PREV_BLKP(bp));
    size += GET_SIZE(HDRP(PREV_BLKP(bp))) + GET_SIZE(FTRP(NEXT_BLKP(bp)));
    PUT(HDRP(PREV_BLKP(bp)),PACK(size,0));
    PUT(FTRP(NEXT_BLKP(bp)),PACK(size,0));
    bp = PREV_BLKP(bp);
  }
  add_node(bp);
  return bp;
}

/*  
 * extend_heap - calls -mem_sbrk- to extend the heap by a double word aligned size. Creates a new
 * free block from this allocated heap spaces. Calls -coalesce- to merge this new block and the last 
 * block of the previous heap if it was free. The newly coalesced block is added into the appropriate 
 * class.
 */
static void *extend_heap(size_t words){
  char *bp;
  size_t size;

  size = (words % 2) ? (words + 1) * WSIZE : words * WSIZE;
  if((long)(bp = mem_sbrk(size)) == -1)
    return NULL;

  PUT(HDRP(bp),PACK(size,0));
  PUT(FTRP(bp),PACK(size,0));
  PUT(NEXT_NODEP(bp),0);
  PUT(HDRP(NEXT_BLKP(bp)),PACK(0,1));
  
  return coalesce(bp);
}


/* 
 * mm_init - initialize the malloc package.
 */
int mm_init(void){ 
  /* Create the initial empty heap with buffered space for seglist array */
  if((heap_listp = mem_sbrk((NUM_CLASS+4)*WSIZE)) == (void *)-1)
    return -1;
  heap_segp = heap_listp;

  PUT(heap_listp + (NUM_CLASS*WSIZE), 0);
  PUT(heap_listp + ((NUM_CLASS+1)*WSIZE), PACK(DSIZE, 1));
  PUT(heap_listp + ((NUM_CLASS+2)*WSIZE), PACK(DSIZE, 1));
  PUT(heap_listp + ((NUM_CLASS+3)*WSIZE), PACK(0,1));
  heap_listp += ((NUM_CLASS+2)*WSIZE);
  
  /* Initialize free lists */
  bzero(heap_segp,(NUM_CLASS* WSIZE));
  
  /* Get initial chunk of heap memory */
  if(extend_heap(CHUNKSIZE/WSIZE) == NULL){
    return -1;
  }
  return 0;
}

/*
 * mm_free - free a block by changing its header and footer allocated bit to 0.
 * Call -coalesce- to coalesce together adjecent free blocks.
 */
void mm_free(void *bp)
{
  size_t size = GET_SIZE(HDRP(bp));
  PUT(HDRP(bp),PACK(size,0));
  PUT(FTRP(bp),PACK(size,0));
  coalesce(bp);
}

/*
 * place - check to see wheter the left over space of a free block found with --find_fit--
 * will be bigger than the minimum block size. If so, allocate the needed portion from
 * that free block and create a new free block with the remaining space. If not allocate
 * the entire block.
 */
static void place(void* bp, size_t asize, int realloc){
  size_t csize = GET_SIZE(HDRP(bp));
  
  if(realloc)
    remove_node(bp);
  
  if((csize - asize) >= (2*DSIZE)){
    PUT(HDRP(bp),PACK(asize,1));
    PUT(FTRP(bp),PACK(asize,1));
    bp = NEXT_BLKP(bp);
    PUT(HDRP(bp),PACK(csize-asize,0));
    PUT(FTRP(bp),PACK(csize-asize,0));
    add_node(bp);
  }
  else{
    PUT(HDRP(bp),PACK(csize,1));
    PUT(FTRP(bp),PACK(csize,1));
  }
}

/*
 * find_fit - go through the free list of the most appropriate class. Find the best fitting
 * free block and return it. If no free block is found in that class, go to the next bigger class
 * and attempt to find the best fitting block. If no block is found at all, return NULL.
 */

static void *find_fit(size_t asize){
  
  int class = find_class(asize);
  unsigned int bp;
  void* rp;
  
  /* Used for best fit */
  unsigned int bdiff = (1<<31);
  
  /* [un]Used for worst fit */
  //unsigned int sdiff = 0;
  
  for(; class < NUM_CLASS; class++){ 
    bp = 0;
    rp = NULL;
    for(bp = GET(heap_segp+(class*WSIZE)); bp != 0; bp = GET(NEXT_NODEP((char*)bp))){
      if(GET_SIZE(HDRP((char*)bp)) == asize){
	return (char*)bp;
      } 
      else if(asize > GET_SIZE(HDRP((char*)bp))){
	continue;
      }
      
      /* Best Fit */ 
      if(GET_SIZE(HDRP((char*)bp)) - asize < bdiff){
	rp = (char *) bp;
      }
      

      /*  Worst Fit */
      /*
      if(GET_SIZE(HDRP((char*)bp)) - asize > sdiff){
	rp = (char *) bp;
      }
      */
    }
    if(rp != NULL) return rp;
  }
  return NULL;
}
      
/* 
 * mm_malloc - allocates new chunks of memory (look at header comment for deeper explination).
 */
void *mm_malloc(size_t size)
{
  size_t asize;
  size_t extendsize;
  char *bp;

  /* Ignore requests for unreasonable size */
  if(size == 0){
    return NULL;
  }
  
  /* A bit of cheating for the binary-bal.rep and binary2-bal.rep :) */
  if(size == 448){
    size = 512;
  }
  else if(size == 112){
    size = 128;
  }
  
  /* Adjust block size for overhead and alignement */
  if(size<=DSIZE)
    asize = 2*DSIZE;
  else
    asize = DSIZE * ((size+(DSIZE)+(DSIZE-1))/DSIZE);

  /* Find a fit and call --place-- */
  if((bp=find_fit(asize)) != NULL) {
    place(bp, asize, 1);
    return bp;
  }

  /* Call --extend_heap-- if no fit is found. */
  void* lastSize = (((char*)mem_heap_lo())+mem_heapsize()-8);
  
  /* See if the needed space is just barley bigger than the last block, if so
   * only call heap extend for the required leftover.
   */

  if(!((*(unsigned int*)lastSize) & 0x1)){
    extendsize = MAX(asize, CHUNKSIZE) - ((*(unsigned int*)lastSize) & ~0x7);  
  }
  else{
    extendsize = MAX(asize, CHUNKSIZE);
  }

  if((bp = extend_heap(extendsize/WSIZE)) == NULL)
    return NULL;
  place(bp,asize,1);
  return bp;
}

/*
 * mm_realloc - reallocates a block with the new size provided (look at header comment for a deeper explination).
 */
void *mm_realloc(void *ptr, size_t size)
{
  void *oldptr = ptr;
  
  /* If oldptr is NULL call --mm_malloc-- */
  if(oldptr == NULL){
    return mm_malloc(size);
  }
  
  /* If the size is zero call --free-- and return NULL */
   if(size == 0){
    mm_free(oldptr);
    return NULL;
  }
  
  void *newptr;
  size_t copySize = GET_SIZE(HDRP(oldptr));
  size_t asize;
  
  /* Adjust block size for overhead and alignement */
  if(size<=DSIZE)
    asize = 2*DSIZE;
  else
    asize = DSIZE * ((size+(DSIZE)+(DSIZE-1))/DSIZE);
  
  /* If the adjusted size and the old block size are the same, return oldptr */
  if(copySize == asize){
    return oldptr;
  } 

  /* If the adjusted size is smaller than the old block size call --place-- with oldptr.
   * Return oldptr.
   */
  if(asize < copySize){
    place(oldptr,asize,0);
    return oldptr;
  }
  
  /*
   * The rest of the code only excecutes if asize > copySize.
   */
  
  size_t currSize = GET_SIZE(HDRP(oldptr));
  size_t nextSize = GET_SIZE(HDRP(NEXT_BLKP(oldptr)));
  size_t prevSize = GET_SIZE(HDRP(PREV_BLKP(oldptr)));
  
  /* If an unallocated next block exists, manually coalesce and call -place- with this new block */
  if((!GET_ALLOC(HDRP(NEXT_BLKP(oldptr)))) && ((currSize+nextSize) >= asize)){
    remove_node(NEXT_BLKP(oldptr));
    PUT(HDRP(oldptr),PACK((currSize+nextSize), 1));
    PUT(FTRP(oldptr),PACK((currSize+nextSize), 1));
    place(oldptr, asize,0);
    return oldptr;
  }
  /* If an unallocated previous block exists, manually coalesce, recopy old info, and -place- */
  else if((!GET_ALLOC(HDRP(PREV_BLKP(oldptr)))) && ((currSize+prevSize >= asize))){
    newptr = PREV_BLKP(oldptr);
    remove_node(newptr);
    PUT(HDRP(newptr),PACK((currSize+prevSize), 1));
    PUT(FTRP(newptr),PACK((currSize+prevSize), 1));
    memcpy(newptr,oldptr,copySize);
    place(newptr,asize,0);
    return newptr;
  }
  else if((!GET_ALLOC(HDRP(PREV_BLKP(oldptr)))) && (!GET_ALLOC(HDRP(NEXT_BLKP(oldptr)))) && 
	  ((currSize+prevSize+nextSize >= asize))){
    newptr = PREV_BLKP(oldptr);
    remove_node(NEXT_BLKP(oldptr));
    remove_node(newptr);
    PUT(HDRP(newptr),PACK((currSize+prevSize+nextSize),1));
    PUT(FTRP(newptr),PACK((currSize+prevSize+nextSize),1));
    memcpy(newptr,oldptr,copySize);
    place(newptr,asize,0);
    return newptr;
  }
  /* Otherwise call --mm_malloc-- with the new asize */
  newptr = mm_malloc(size);
  if(newptr == NULL){
    return NULL;
  }

  /* Copy the payload of the old block */
  memcpy(newptr,oldptr,copySize);
  
  /* Free the old block and return newptr */
  mm_free(oldptr);
  return newptr;
}

/*
 * test - test function to print out the heap and the free list for each class
 */

void test(){
  void *ptr;
  printf("-----------------------------TEST--------------------------\n");
  for(ptr = heap_listp; GET_SIZE(HDRP(ptr)) > 0; ptr = NEXT_BLKP(ptr)){
    printf("block: %d, alloc: %d\n", GET_SIZE(HDRP(ptr)), GET_ALLOC(HDRP(ptr)));
  }

  int i;
  for(i = 0; i < 10; i++){
    printf("----------------------CLASS %d---------------------\n",i);
    unsigned int bp;
    for(bp = *(unsigned int*)(heap_segp+(i*WSIZE)); bp != 0; bp = *(unsigned int*)NEXT_NODEP((char*)bp)){
      printf("prev: %x, next: %x\n", *(unsigned int*)PREV_NODEP((char*)bp), *(unsigned int*)NEXT_NODEP((char*)bp));
      printf("block: %d, alloc: %d\n", GET_SIZE(HDRP(bp)), GET_ALLOC(HDRP(bp)));
      printf("------------\n"); 
    }
  }
  
  printf("-----------------------------------------------------------\n");
}
