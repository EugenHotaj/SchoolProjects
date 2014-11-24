#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Define Constraints */
#define MAX_TASKS 10
#define MAX_INST 25
#define MAX_RESOURCES 10

/* Define Debug Variable */
#define DEBUG 0

/* Define Keys for Tasks */
#define INITIATE 0
#define REQUEST 1
#define RELEASE 2
#define TERMINATE 3


/* 
 * Structure for instructions of a task:
 * This struct represents one line from input. It has an instruction code
 * which lets us know what type of instruction this is (the codes are 
 * defined above). It also keeps track of the three other numbers from 
 * input (note that not all 3 numbers are used for all instruciton types).
 * Note that the task number is not tracked since we do that implicity in the
 * "Task" struct.
 */
typedef struct{
  int instruction;
  int delay;
  int resource;
  int amount;
}Instruction;

 /*
  * Structure for a task:
  * A task has an instruction number which increments every time a new 
  * instruction is added. An initial claim of resources. And a variable
  * cyclesLeft which keeps track of how many cycles are left before the
  * next instruction is processed. Finally it contains an array of 
  * "Instruction" types which hold the logic what what this task will 
  * do throughout the program.
  */
typedef struct{
  int taskNum;
  int instNum;
  int currentInst;
  int cyclesLeft;
  int terminated;
  int aborted;
  int satisfied;
  int waitTime;
  int cycle;

  int resourceClaims[MAX_RESOURCES];
  int resourceCurrent[MAX_RESOURCES];
  
  Instruction instructions[MAX_INST]; 
}Task;

/* 
 * Structure for a resource:
 * Keep track of the total amount of the resource and the current amount.
 */
typedef struct{
  int total;
  int left;
}Resource;

/* Define need variables and structures */
int totalResources;
int totalTasks;
int totalFinished;
int releasedResources[MAX_RESOURCES];
Resource resources[MAX_RESOURCES];
Task tasks[MAX_TASKS];

/*
 * init - Opens file passed as an argument. Cleans data structures.
 * (re)initialize needed variables. 
 *
 */
void init(char *fileName){
  /* Clean variables */
  totalResources = 0;
  totalTasks = 0;
  totalFinished = 0;
  
  /* Clean data structure */
  for(int i = 0; i < MAX_TASKS; i++){
    tasks[i].taskNum = i+1;
    tasks[i].instNum = 0;
    tasks[i].currentInst = 0;
    tasks[i].cyclesLeft = 0;
    tasks[i].terminated = 0;
    tasks[i].waitTime = 0;
    tasks[i].cycle = 0;
    tasks[i].aborted = 0;
    tasks[i].satisfied = 1;
    
    for(int j = 0; j < MAX_RESOURCES; j++){
      tasks[i].resourceClaims[j] = 0;
      tasks[i].resourceCurrent[j] = 0;
      resources[j].total = 0;
      resources[j].left = 0;
      releasedResources[j] = 0;
    }
    
    for(int j = 0; j < MAX_INST; j++){
      tasks[i].instructions[j].instruction = -1;
      tasks[i].instructions[j].delay = 0;
      tasks[i].instructions[j].resource = -1;
      tasks[i].instructions[j].amount = 0;
    }
  }

  
  /* Read input from file, exit if file could not be opened */
  FILE *file = fopen(fileName, "r");
  if(file == NULL){
    printf("Could not open file\n");
    exit(0);
  }

  /* Define locally used variables for reading */
  int inputNum;
  char inputStr[10];
  
  /* Constrain number of Tasks, exit if number exceeds constraint */
  fscanf(file,"%d",&inputNum);
  totalTasks = inputNum;
  if(totalTasks > MAX_TASKS){
    printf("ERROR: cannot have more than %d tasks.", MAX_TASKS);
    exit(0);
  }
  
  /* Constrain number of Resources, exit if number exceeds constraints */
  fscanf(file, "%d", &inputNum);
  if(inputNum > MAX_RESOURCES){
    printf("ERROR: cannot have more than %d resources.", MAX_RESOURCES);
    exit(0);
  }
  
  /* Initialize Resources */
  totalResources = inputNum;
  for(int i = 0; i < totalResources; i++){
    fscanf(file, "%d", &inputNum);
    resources[i].total = inputNum;
    resources[i].left = inputNum;
  }
  
  /* Initialize instrucitons for Tasks by reading through file */
  while(fscanf(file, "%s", inputStr) != EOF){
    fscanf(file, "%d",&inputNum);
    int taskNum = inputNum-1;
    if(strcmp(inputStr,"initiate")==0){;
      tasks[taskNum].instructions[tasks[taskNum].instNum].instruction = INITIATE;
    }
    else if(strcmp(inputStr,"request")==0){
      tasks[taskNum].instructions[tasks[taskNum].instNum].instruction = REQUEST;
    }
    else if(strcmp(inputStr,"release")==0){
      tasks[taskNum].instructions[tasks[taskNum].instNum].instruction = RELEASE;
    }
    else if(strcmp(inputStr,"terminate")==0){
      tasks[taskNum].instructions[tasks[taskNum].instNum].instruction = TERMINATE;
    }
    else{
      printf("ERROR: incompatible instruction '%s'.",inputStr);
      exit(0);
    }
    fscanf(file,"%d",&inputNum);
    tasks[taskNum].instructions[tasks[taskNum].instNum].delay = inputNum;
    fscanf(file,"%d",&inputNum);
    tasks[taskNum].instructions[tasks[taskNum].instNum].resource = inputNum-1;
    fscanf(file,"%d",&inputNum);
    tasks[taskNum].instructions[tasks[taskNum].instNum++].amount = inputNum;
  }
  
  fclose(file);
} 

/* 
 * print - prints out formatted output from banker/optimistic algorithms. Figures
 * out and prints analytic data.
 */
void print(char* identifier){
  int totalRunTime = 0;;
  int totalWaitTime = 0;;
  
  /* Reorganize tasks by order of taskNum*/
  Task newTasks[totalTasks];
  for(int i = 0; i < totalTasks; i++){
    newTasks[tasks[i].taskNum-1] = tasks[i];
  }
  for(int i = 0; i < totalTasks; i++){
    tasks[i] = newTasks[i];
  }
  
  printf("%18s\n",identifier);
  for(int i = 0; i < totalTasks; i++){
    if(!tasks[i].aborted){
      printf("%10s%2d%7d%4d%4d%%\n","Task",tasks[i].taskNum,tasks[i].cycle,tasks[i].waitTime, (int)(100*((float)tasks[i].waitTime/(float)tasks[i].cycle)));
      totalRunTime += tasks[i].cycle;
      totalWaitTime += tasks[i].waitTime;
    }
    else{
      printf("%10s%2d%13s\n","Task",tasks[i].taskNum,"aborted");
    }
  }
  printf("%11s%8d%4d%4d%%\n","total",totalRunTime,totalWaitTime,(int)(100*((float)totalWaitTime/(float)totalRunTime)));
}

/*
 * checkDeadlock - checks to see if dedlock occurs. This is done by checking to see if the number of
 * tasks which cannot be satisfied is equal to the number of total tasks which are alive. It figures out
 * satisfied tasks by seeing which tasks cannot be allowed a request since the number of (both released aka 
 * availabe next cycle)  and current amount of resources is less than what the process asks for. If this is 
 * true the process is considered unsatisfied. If deadlock has indeed occured then the first unsatisfied task
 * (in a fifo manner) is aborted and all its resources are released to the manager.
 */
void checkDeadlock(){
  int totalUnsatisfied = 0;
  int totalAlive = 0;
  
  for(int i = 0; i < totalTasks; i++){
    if(!tasks[i].terminated && !tasks[i].aborted){
      totalAlive ++;
    }
    else{
      continue;
    }
    /* Check to see if a task is satisfied or not */
    if(!tasks[i].satisfied && 
       tasks[i].instructions[tasks[i].currentInst].instruction == REQUEST &&
       (resources[tasks[i].instructions[tasks[i].currentInst].resource].left +
	releasedResources[tasks[i].instructions[tasks[i].currentInst].resource]) < 
	tasks[i].instructions[tasks[i].currentInst].amount){
      totalUnsatisfied++;
    }
  }
  /* If deadlock abort a task */
  if(totalUnsatisfied == totalAlive && totalAlive != 0){
    int lowestTask = 100;
    int lowestTaskIndex = 100;
    for(int i = 0; i < totalTasks; i++){
      if(tasks[i].aborted || tasks[i].terminated){
	continue;
      }
      if((resources[tasks[i].instructions[tasks[i].currentInst].resource].left +
	 releasedResources[tasks[i].instructions[tasks[i].currentInst].resource]) < 
	 tasks[i].instructions[tasks[i].currentInst].amount){
	if(tasks[i].taskNum < lowestTask){
	  lowestTask = tasks[i].taskNum;
	  lowestTaskIndex = i;
	}
      }
    }
    if(DEBUG){ printf("aborted task %d\n",tasks[lowestTaskIndex].taskNum);}
    tasks[lowestTaskIndex].aborted++;
    totalFinished++;
    for(int j = 0; j < totalResources; j++){
      releasedResources[j] += tasks[lowestTaskIndex].resourceCurrent[j];
    }
    /* Recursivley check if deadlock is still present */
    checkDeadlock();
  }
}

/*
 * checkSafe - checks to see if a current state is safe. This is done by basically seeing if every 
 * tasks will be satisfied with the current resources left. It runs through all the tasks and tries to 
 * satisfy any of them. It does this until no more tasks can be satisfied because of two facsts:
 * (1) every task has been satisfied therefore no deadlock has occured and this state is safe -> return 1
 * (2) not every task is satisfied, deadlock has occured, state is not safe -> return 0
 */
int checkSafe(){
  Resource resourcesCopy[totalResources]; // copy resources to prevent overwring during saftey test
  int finished = -1;
  int finishedIndex[totalTasks]; // keep track of which task have terminated/are satisfied
  int alive = totalTasks - totalFinished;
  
  for(int i = 0; i < totalResources; i++){
    resourcesCopy[i] = resources[i];
  }

  for(int i = 0; i < totalTasks; i++){
    if(tasks[i].terminated || tasks[i].aborted){
      finishedIndex[i] = 1;
    }
    else{
      finishedIndex[i] = 0;
    }
  }

  while(finished != 0){
    finished = 0;
    for(int i = 0; i < totalTasks; i++){
      int totalResSatisfied = 0;
      
      if(finishedIndex[i] != 0){
	  continue;
      }

      for(int j = 0; j < totalResources; j++){
	if(tasks[i].resourceClaims[j] - tasks[i].resourceCurrent[j] <= resourcesCopy[j].left){  
	  totalResSatisfied++;
	}
      }
      /* If a task is satisfied pretend to release it's resources and see if more tasks 
         can be satisfied with these new resources */
      if(totalResSatisfied == totalResources){
	alive--;
	finished++;
	finishedIndex[i]++;
	for(int j = 0; j < totalResources; j++){
	  resourcesCopy[j].left += tasks[i].resourceCurrent[j];
	}
      }
    }
  }
  
  if(alive != 0){
    return 0;
  }
  return 1;
}

/* 
 * optimistic - reads instructions. Nothing is done during initialization besides cycle count.
 * During request, satisfy any requests if there are enough resources present. If not deny a request
 * and make the task wait. Put the denied task at the front of the list so it gets first pick when 
 * resources are released. Release is handled trivially (remove resources from task, give back to manager).
 * Termination is handled trivially (terminated task). Finally check for deadlock (explaied above).
 */
void optimistic(){
  int denialIndex = 0; // used for FIFO
  
  while(totalFinished < totalTasks){
    /*Refresh Denial Index */
    denialIndex = 0;

    /* Agregate resources from last cycle if any are present */
    for(int i = 0; i < totalResources; i++){
      resources[i].left += releasedResources[i];
      releasedResources[i] = 0;
    }
    
    for(int i = 0; i < totalTasks; i++){
      /* Account for delay */
      if(tasks[i].cyclesLeft > 0 && tasks[i].satisfied){
	tasks[i].cycle++;
	tasks[i].cyclesLeft--;
      }
      /* Read next instruction */
      else{
	/* Skip terminated tasks */ 
	if(!tasks[i].terminated && !tasks[i].aborted){
	  /* Handle delay for next task */
	  tasks[i].cyclesLeft = tasks[i].instructions[tasks[i].currentInst+1].delay;
	  
	  switch(tasks[i].instructions[tasks[i].currentInst].instruction){
	  case 0: // handle initialization
	    // Claims unused for optimistic
	    if(DEBUG){printf("initialized task %d\n",tasks[i].taskNum);}
	    tasks[i].currentInst++;
	    tasks[i].cycle++;
	    break;
	  case 1: // handle requests
	    if(resources[tasks[i].instructions[tasks[i].currentInst].resource].left >= tasks[i].instructions[tasks[i].currentInst].amount){
	      /* Satisfy request if resources available */
	      tasks[i].resourceCurrent[tasks[i].instructions[tasks[i].currentInst].resource] += tasks[i].instructions[tasks[i].currentInst].amount;
	      resources[tasks[i].instructions[tasks[i].currentInst].resource].left -= tasks[i].instructions[tasks[i].currentInst].amount;
	      tasks[i].satisfied = 1;
	      if(DEBUG){printf("allowed task %d's request\n",tasks[i].taskNum);}
	      tasks[i].cycle++;
	      tasks[i].currentInst++;
	    }
	    else{
	      /* Else mark task as unsatisfied, put to front of array */
	      tasks[i].satisfied = 0;
	      tasks[i].waitTime++;
	      tasks[i].cycle++;
	      if(denialIndex != i){
		Task tempTask = tasks[i];
		for(int j = i; j > denialIndex; j--){
		  tasks[j] = tasks[j-1];
		}
		tasks[denialIndex] = tempTask;
	      }
	      if(DEBUG){printf("denied task %d's request\n",tasks[denialIndex].taskNum);}
	      denialIndex++;
	    }
	    break;
	  case 2: // handle releases
	    tasks[i].resourceCurrent[tasks[i].instructions[tasks[i].currentInst].resource] -= tasks[i].instructions[tasks[i].currentInst].amount;
	    releasedResources[tasks[i].instructions[tasks[i].currentInst].resource] += tasks[i].instructions[tasks[i].currentInst].amount; 
	    if(DEBUG){printf("task %d released\n",tasks[i].taskNum);}
	    tasks[i].currentInst++;
	    tasks[i].cycle++;
	    break;
	  case 3: // handle terminations
	    tasks[i].terminated++;
	    totalFinished++;
	    if(DEBUG){printf("terminated task %d\n",tasks[i].taskNum);}
	    break;
	  }
	}
      }
    }
    checkDeadlock();
  }
  print("FIFO");
}
  
/*
 * banker - Initialize does the same thing as optimistic, however it also assings records claims and aborts processes
 * which claims more resources than total available. Request intially satisfies any request if resources available. It then checks if the new state
 * is safe (explained above). If a state is safe continue. If not revert resources back to before satisfaction of request.
 * Make current process wait and put in appropriate place on FIFO queue. If insufficient resources for a request
 * handle as optimistic. Release handled as optimistic. Terminate handled as optimistc.
 */
void banker(){
  int denialIndex = 0; // used for FIFO process ordering when requests get denied
  
  while(totalFinished < totalTasks){
    /*Refresh denialIndex */
    denialIndex = 0;

    /* Agregate resources from last cycle */
    for(int i = 0; i < totalResources; i++){
      resources[i].left += releasedResources[i];
      releasedResources[i] = 0;
    }
    
    for(int i = 0; i < totalTasks; i++){
      /* Account for delay */
      if(tasks[i].cyclesLeft > 0 && tasks[i].satisfied){
	tasks[i].cycle++;
	tasks[i].cyclesLeft--;
	if(DEBUG){printf("task%d delayed\n",tasks[i].taskNum);}
      }

      /* If no delay read next instruciton */
      else{
	/* (Implicitly) skip terminated tasks */ 
	if(!tasks[i].terminated && !tasks[i].aborted){
	  
	  /* Get (potential) delay from next instruction */
	  tasks[i].cyclesLeft = tasks[i].instructions[tasks[i].currentInst+1].delay;
	  
	  switch(tasks[i].instructions[tasks[i].currentInst].instruction){
	  case 0: // handle initialization
	    /* Check to see if claim exceeds total, if so abort task */
	    if(tasks[i].instructions[tasks[i].currentInst].amount > resources[tasks[i].instructions[tasks[i].currentInst].resource].total){
	      tasks[i].aborted++;
	      totalFinished++;
	      printf("Task %d's claim for resource %d (%d) exceeds number of units present (%d). Task aborted.\n",
		     tasks[i].taskNum, tasks[i].instructions[tasks[i].currentInst].resource+1, tasks[i].instructions[tasks[i].currentInst].amount, 
		     resources[tasks[i].instructions[tasks[i].currentInst].resource].total);
	    }
	    /* Else record claims */
	    else{
	      tasks[i].resourceClaims[tasks[i].instructions[tasks[i].currentInst].resource] = tasks[i].instructions[tasks[i].currentInst].amount;
	      if(DEBUG){printf("initialized task %d\n",tasks[i].taskNum);}
	      tasks[i].currentInst++;
	      tasks[i].cycle++;
	    }
	    break;
	  case 1: // handle requests
	    /* Abort task if its claims are ever exceeded, reclaim resources */
	    if(tasks[i].resourceCurrent[tasks[i].instructions[tasks[i].currentInst].resource] + tasks[i].instructions[tasks[i].currentInst].amount > tasks[i].resourceClaims[tasks[i].instructions[tasks[i].currentInst].resource]){
	      tasks[i].aborted++;
	      totalFinished++;
	      for(int j = 0; j < totalResources; j++){
		resources[j].left += tasks[i].resourceCurrent[j];
	      }
	      printf("During cycle %d-%d Task %d's request exceedes its claim. Task aborted\n",tasks[i].cycle, tasks[i].cycle+1, tasks[i].taskNum);
	      break;
	    }
	    
	    if(resources[tasks[i].instructions[tasks[i].currentInst].resource].left >= tasks[i].instructions[tasks[i].currentInst].amount){
	      /* Initially satisfy request regardless of unsafe state if resources sufficent */
	      tasks[i].resourceCurrent[tasks[i].instructions[tasks[i].currentInst].resource] += tasks[i].instructions[tasks[i].currentInst].amount;
	      resources[tasks[i].instructions[tasks[i].currentInst].resource].left -= tasks[i].instructions[tasks[i].currentInst].amount;
	     
	      /* Check for saftey */
	      if(!checkSafe()){
	       /* Reset resources if unsafe state detected */
	       tasks[i].resourceCurrent[tasks[i].instructions[tasks[i].currentInst].resource] -= tasks[i].instructions[tasks[i].currentInst].amount;
	       resources[tasks[i].instructions[tasks[i].currentInst].resource].left += tasks[i].instructions[tasks[i].currentInst].amount;
	       
	       /* Add wait and cycle time but keep same instruciton */
	       tasks[i].satisfied = 0;
	       tasks[i].waitTime++;
	       tasks[i].cycle++;
	       
	       /* Add denied tasks to current spot in FIFO ordering */
	       if(denialIndex != i){
		 Task tempTask = tasks[i];
		 for(int j = i; j > denialIndex; j--){
		   tasks[j] = tasks[j-1];
		 }
		 tasks[denialIndex] = tempTask;
	       }
	       if(DEBUG){printf("denied task %d's request: unsafe state\n",tasks[denialIndex].taskNum);}
	       denialIndex++;
	      }
	      /* If safe state satisfy request and update cycle and instuction */ 
	     else{
	       tasks[i].satisfied = 1;
	       if(DEBUG){printf("allowed task %d's request\n",tasks[i].taskNum);}
	       tasks[i].cycle++;
	       tasks[i].currentInst++;
	     }
	    }
	    /* If insufficient resources handle as in optimistic manager */
	    else{
	      tasks[i].satisfied = 0;
	      tasks[i].waitTime++;
	      tasks[i].cycle++;
	      if(denialIndex != i){
		Task tempTask = tasks[i];
		for(int j = i; j > denialIndex; j--){
		  tasks[j] = tasks[j-1];
		}
		tasks[denialIndex] = tempTask;
	      }
	      if(DEBUG){printf("denied task %d's request: insufficient resources\n",tasks[denialIndex].taskNum);}
	      denialIndex++;
	    }
	    break;
	  case 2: // handle releases -- pretty self explanitory, just give back resources and remove them from the task
	    tasks[i].resourceCurrent[tasks[i].instructions[tasks[i].currentInst].resource] -= tasks[i].instructions[tasks[i].currentInst].amount;
	    releasedResources[tasks[i].instructions[tasks[i].currentInst].resource] += tasks[i].instructions[tasks[i].currentInst].amount; 
	    if(DEBUG){printf("task %d released\n",tasks[i].taskNum);}
	    tasks[i].currentInst++;
	    tasks[i].cycle++;
	    break;
	  case 3: // handle terminations -- self explanitory, set termination flag for the task, increment total finished tasks 
	    tasks[i].terminated++;
	    totalFinished++;
	    if(DEBUG){printf("terminated task %d\n",tasks[i].taskNum);}
	    break;
	  }
	}
      }
    }
  }
  print("Banker");
}

/*
 * main - reads arguments passed by the user, calls individual manager algorithms. (Re)Initializes the main
 * data structures before each algorithm.
 */
int main(int argc, char *argv[]){
 
  /* Exit if program has no specified input file, print helpul message */
  if(argc != 2){
    printf("Usage: [%s] [filename]", argv[0]);
    exit(0);
  }
  
  /* Initialize variables and structures, run optimistic manager */
  init(argv[1]); 
  optimistic();
  
  /* Reinitialize variables and structures, run banker */
  init(argv[1]);
  banker();

}
