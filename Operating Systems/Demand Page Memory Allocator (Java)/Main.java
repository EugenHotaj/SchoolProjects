import java.util.ArrayList;
import java.util.Scanner;
import java.io.File;
import java.lang.Math;

public class Main{
    /* Debug constant */
    public static final boolean DEBUG = false;
    
    /* Define Constants */
    public static final int QUANTUM = 3;
   
    public static Scanner scanner;
    public static int pageSize;
    public static Frame[] frameTable;
    public static int cycle = 1;
    public static int totalFinished = 0;
    
    public static ArrayList<Process> processes;
    public static ArrayList<Integer> fifo;
    public static ArrayList<Integer> lru;
    
    public static void main(String[] args){
	/* Initialize random numbers file */
	try{
	    scanner = new Scanner(new File("random-numbers"));
	}
	catch(Exception e){
	    e.printStackTrace();
	}
	
	/* Handle input */
	if(args.length < 6){
	    System.out.println("Usage: \'java Main\' [M] [P] [S] [J] [N] [R]\n" +
			       "       M = machine size in words\n" +
			       "       P = page size in words\n" +
			       "       S = process size\n" +
			       "       J = job mix\n" +
			       "       N = number of references per process\n" +
			       "       R = replacement algorithm\n");
	}
	
	/* Echo input */
	System.out.printf("The machine size is %s.\nThe page size is %s.\nThe process size is %s.\nThe job mix number is %S.\n"+
	       "The number of references per process is %s.\nThe replacement algorithm is %s.\n\n",
	       args[0],args[1],args[2],args[3],args[4],args[5]);
	
	/* Initialize other variables */
	pageSize = Integer.parseInt(args[1]);
	frameTable = new Frame[Integer.parseInt(args[0])/pageSize];
	processes = new ArrayList<Process>();
	switch(Integer.parseInt(args[3])){
	case(1):
	    processes.add(new Process(1f,0f,0f,Integer.parseInt(args[2]),Integer.parseInt(args[4])));
	    break;
	case(2):
	    for(int i = 0; i < 4; i++){
		processes.add(new Process(1f,0f,0f,Integer.parseInt(args[2]),Integer.parseInt(args[4])));
	    }
	    break;
	case(3):
	    for(int i = 0; i < 4; i++){
		processes.add(new Process(0f,0f,0f,Integer.parseInt(args[2]),Integer.parseInt(args[4])));
	    }
	    break;
	case(4):
	    processes.add(new Process(.75f,.25f,0f,Integer.parseInt(args[2]),Integer.parseInt(args[4])));
	    processes.add(new Process(.75f,0,.25f,Integer.parseInt(args[2]),Integer.parseInt(args[4])));
	    processes.add(new Process(.75f,.125f,.125f,Integer.parseInt(args[2]),Integer.parseInt(args[4])));
	    processes.add(new Process(.5f,.125f,.125f,Integer.parseInt(args[2]),Integer.parseInt(args[4])));
	    break;
	default:
	    System.out.println("Error: Bad References");
	    System.exit(0);
	    break;
	}
	lru = new ArrayList<Integer>();
	fifo = new ArrayList<Integer>();
	
	/* Handle Paging
	 * If this is the initial reference for a process use word 111*k mod S where k is the word and S is the
	 * size of the process. If this is not the first reference find the next word referenced based on the 
	 * job mix (A, B, C). Once the word is found, we calculate what page that word is resident is by doing
	 * Math.floor(word/PS) where word is the referenced word in question and S is the page size. Finally
	 * we check to see if a page is currently in the frame (this is done very inefficinetly by simply searching
	 * the entire list to see if our page is resident or not; much more effient ways can be implemented but
	 * they are not necessary for the scope of this program).If a page is in the frame update LRU references.
	 * If a page is not in the frame eitehr (1) find a free frame if one exists or (2) evict a resident frame
	 * using either a First In First Out (fifo), Least Recently Used (lru), or random implementation based 
	 * on the specified algorithm. 
	 */
	    
	while(totalFinished < processes.size()){
	    for(int i = 0; i < processes.size(); i++){
		if(!processes.get(i).getFinished()){
		    for(int j = 0; j < QUANTUM; j++){
			
			/* If this is the first reference */
			if(processes.get(i).getInitial()){
			    int freeFrame = findFreeFrame();
			    
			    /* If a free frame exists */
			    if(freeFrame != -1){
				frameTable[freeFrame] = new Frame(cycle, i, (int)Math.floor((double)((111*(i+1))%processes.get(i).getSize())/(double)pageSize)); // put PAGE in table 
				if(DEBUG){
				    System.out.printf("%d references word %d (page %d) at time %d: Fault, using frame %d.\n",
						      i,
						      (111*(i+1))%processes.get(i).getSize(), 
						      (int)Math.floor((double)((111*(i+1))%processes.get(i).getSize())/(double)pageSize),
						      cycle,
						      freeFrame);
				}
				processes.get(i).incFaults();
				fifo.add(freeFrame);
				lru.add(freeFrame);
			    }

			    /* If no free frame exists */
			    else{
				if(DEBUG){ 
				    System.out.printf("%d references word %d (page %d) at time %d: ",
						      i,
						      (111*(i+1))%processes.get(i).getSize(), 
						      (int)Math.floor((double)((111*(i+1))%processes.get(i).getSize())/(double)pageSize),
						      cycle);
				}
				processes.get(i).incFaults();
				if(args[5].equals("fifo")){
				    if(DEBUG){
					System.out.printf("Fault, evicting page %d of %d from frame %d.\n", 
							  frameTable[fifo.get(0)].getValue(), 
							  frameTable[fifo.get(0)].getProcess(),
							  fifo.get(0));
				    }
				    processes.get(frameTable[fifo.get(0)].getProcess()).setResidency(cycle - frameTable[fifo.get(0)].getCycle());
				    processes.get(frameTable[fifo.get(0)].getProcess()).incEvictions();
				    frameTable[fifo.get(0)] = new Frame(cycle, i, (int)Math.floor((double)((111*(i+1))%processes.get(i).getSize())/(double)pageSize));
				    int temp = fifo.get(0);
				    fifo.remove(0);
				    fifo.add(temp);
				}
				else if(args[5].equals("lru")){
				    if(DEBUG){
					System.out.printf("Fault, evicting page %d of %d from frame %d.\n", 
							  frameTable[lru.get(0)].getValue(), 
							  frameTable[lru.get(0)].getProcess(),
							  lru.get(0));
				    }
				    processes.get(frameTable[lru.get(0)].getProcess()).setResidency(cycle - frameTable[lru.get(0)].getCycle());
				    processes.get(frameTable[lru.get(0)].getProcess()).incEvictions();
				    frameTable[lru.get(0)] = new Frame(cycle, i, (int)Math.floor((double)((111*(i+1))%processes.get(i).getSize())/(double)pageSize));
				    int temp = lru.get(0);
				    lru.remove(0);
				    lru.add(temp);
				}
				else if(args[5].equals("random")){
				    int randFrame = scanner.nextInt()%frameTable.length;
				    if(DEBUG){
					System.out.printf("Fault, evicting page %d of %d from frame %d.\n", 
							  frameTable[randFrame].getValue(), 
							  frameTable[randFrame].getProcess(),
							  randFrame);
				    }
				    processes.get(frameTable[randFrame].getProcess()).setResidency(cycle - frameTable[randFrame].getCycle());
				    processes.get(frameTable[randFrame].getProcess()).incEvictions();
				    frameTable[randFrame] = new Frame(cycle, i, (int)Math.floor((double)((111*(i+1))%processes.get(i).getSize())/(double)pageSize));
				}
				else{
				    System.out.println("Error: bad algorithm input");
				    System.exit(0);
				}
			    }
			    
			    processes.get(i).falsifyInitial();
			    processes.get(i).setPrevRef(111*(i+1)%processes.get(i).getSize()); // update previous word reference
			}
			
			/* If this is not the first reference */
			else{
			    int frame = checkInTable(i,(int)Math.floor((double)processes.get(i).getCurrentReference()/(double)pageSize));    
			    if(DEBUG){
				System.out.printf("%d references word %d (page %d) at time %d: ",
						  i,
						  processes.get(i).getCurrentReference(), 
						  (int)Math.floor((double)processes.get(i).getCurrentReference()/(double)pageSize),
						  cycle);
			    }
			    
			    /* If a page is not in the table do as follows*/
			    if(frame == -1){
				processes.get(i).incFaults();
				int freeFrame = findFreeFrame();
				
				/* If a free frame exists put the page in that frame*/
				if(freeFrame != -1){
				    frameTable[freeFrame] = new Frame(cycle, i, (int)Math.floor((double)processes.get(i).getCurrentReference()/(double)pageSize)); 
				    if(DEBUG){ System.out.printf("Fault, using free frame %d.\n", freeFrame); }
				    lru.add(freeFrame);
				    fifo.add(freeFrame);
				}
				
				/* If free frame does not exist, evict a page based on the the algorithm */
				else{
				    if(args[5].equals("fifo")){
					if(DEBUG){
					    System.out.printf("Fault, evicting page %d of %d from frame %d.\n", 
							      frameTable[fifo.get(0)].getValue(), 
							      frameTable[fifo.get(0)].getProcess(),
							      fifo.get(0));
					}
					processes.get(frameTable[fifo.get(0)].getProcess()).setResidency(cycle - frameTable[fifo.get(0)].getCycle());
					processes.get(frameTable[fifo.get(0)].getProcess()).incEvictions();
					frameTable[fifo.get(0)] = new Frame(cycle, i, (int)Math.floor((double)processes.get(i).getCurrentReference()/(double)pageSize));
					int temp = fifo.get(0);
					fifo.remove(0);
					fifo.add(temp);
				    }
				    else if(args[5].equals("lru")){
					if(DEBUG){
					    System.out.printf("Fault, evicting page %d of %d from frame %d.\n", 
							      frameTable[lru.get(0)].getValue(), 
							      frameTable[lru.get(0)].getProcess(),
							      lru.get(0));
					}
					processes.get(frameTable[lru.get(0)].getProcess()).setResidency(cycle - frameTable[lru.get(0)].getCycle());
					processes.get(frameTable[lru.get(0)].getProcess()).incEvictions();
					frameTable[lru.get(0)] = new Frame(cycle, i, (int)Math.floor((double)processes.get(i).getCurrentReference()/(double)pageSize));
					int temp = lru.get(0);
					lru.remove(0);
					lru.add(temp);
				    }
				    else if(args[5].equals("random")){
					
					int randFrame = scanner.nextInt()%frameTable.length;
					if(DEBUG){
					    System.out.printf("Fault, evicting page %d of %d from frame %d.\n", 
							      frameTable[randFrame].getValue(), 
							      frameTable[randFrame].getProcess(),
							      randFrame);
					}
					processes.get(frameTable[randFrame].getProcess()).setResidency(cycle - frameTable[randFrame].getCycle());
					processes.get(frameTable[randFrame].getProcess()).incEvictions();
					frameTable[randFrame] = new Frame(cycle, i, (int)Math.floor((double)processes.get(i).getCurrentReference()/(double)pageSize));
				    }
				    else{
					System.out.println("Error: bad algorithm input");
					System.exit(0);
				    }
				}
			    }
			    
			    /* Update LRU references for resident pages */
			    else{
				if(DEBUG){
				    System.out.printf("Hit in frame %d.\n",frame);
				}
				for(int k = 0; k < lru.size(); k++){
				    if(frame == lru.get(k)){
					lru.remove(k);
					lru.add(frame);
					break;
				    }
				}
			    }
			    /* Set the previous word to the current word */
			    processes.get(i).setPrevRef(processes.get(i).getCurrentReference());
			}
			
			/* Calculate the next Reference for a process */
			int rand = scanner.nextInt();
			if(DEBUG){System.out.printf("%d uses random number: %d\n",i,rand);}
			double probability = rand/(Integer.MAX_VALUE + 1d);
			
			/* Find next word based on the given job mix */
			if(probability < processes.get(i).getA()){
			    processes.get(i).setCurrentReference((processes.get(i).getPrevRef()+1)%processes.get(i).getSize());
			}
			else if(probability < processes.get(i).getA() + processes.get(i).getB()){
			    processes.get(i).setCurrentReference((processes.get(i).getPrevRef()-5+processes.get(i).getSize()) % processes.get(i).getSize());
			}
			else if(probability < processes.get(i).getA() + processes.get(i).getB() + processes.get(i).getC()){
			    processes.get(i).setCurrentReference((processes.get(i).getPrevRef()+4)%processes.get(i).getSize());
			}
			else{ /* completely random case */
			    int tempRand = scanner.nextInt();
			    if(DEBUG){ System.out.printf("%d uses random number: %d\n",i,tempRand); }
			    processes.get(i).setCurrentReference(tempRand%processes.get(i).getSize());
			}
			
			if(processes.get(i).decrementRef()){
			    j = 100; //account for leftover quantum if a process finishes
			}
			cycle++;
		    }
		}
	    }
	}
	print();
    }
    
    /* print -- self explanitory */
    public static void print(){
	int totalFaults = 0;
	int totalEvictions = 0;
	int totalResidency = 0;

	System.out.println(); // formatting purposes
	for(int i = 0; i < processes.size(); i++){
	    
	    /* If evicitons existed */
	    if(processes.get(i).getEvictions()!=0){
		System.out.printf("Process %d had %d faults and %f average residency.\n",
				  i+1,
				  processes.get(i).getFaults(),
				  (double)processes.get(i).getResidency()/(double)processes.get(i).getEvictions());
		totalFaults += processes.get(i).getFaults();
		totalEvictions += processes.get(i).getEvictions();
		totalResidency += processes.get(i).getResidency();
	    }
	    
	    /* If there were no evictions */
	    else{
		System.out.printf("Process %d had %d faults.\n     With no evictions, the average residence is undefined.\n", 
				  i+1, processes.get(i).getFaults());
		totalFaults += processes.get(i).getFaults();
	    }
	}
	
	/* If total evicitons existed */
	if(totalEvictions != 0){
	    System.out.printf("\nThe total number of faults is %d and the overall average residency is %f.\n",
			      totalFaults,
			      (double)totalResidency/(double)totalEvictions);
	}
	
	/* If no total evictions existed */
	else{
	    System.out.printf("\nThe total number of faults is %d.\n     With no evictions, the overall average residence residence is undefined.\n",
			      totalFaults);
	}
    }
    
    /* checkInTable -- check to see if the page of a processes is currently in the table. 
     * If a page is in the table, return the current frame (for LRU purposes);
     * else return -1;
     */
    public static int checkInTable(int process, int page){
	for(int i = 0; i < frameTable.length; i++){
	    if(frameTable[i] != null && frameTable[i].getValue() == page && frameTable[i].getProcess() == process){
		return i;
	    }
	}
	return -1;
    }
    
    /* findFreeFrame -- find a free frame starting from the "highest numbered" frame. 
     * If it does not exit, return -1 (a bad frame).
     */
    public static int findFreeFrame(){
	for(int i = frameTable.length-1; i > -1; i--){
	    if(frameTable[i] == null){
		return i;
	    }
	}
	/* If no free blocks exist */
	return -1;
    }
}