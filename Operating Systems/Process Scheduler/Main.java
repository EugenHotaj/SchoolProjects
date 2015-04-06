import java.util.Scanner;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.Collections;
import java.io.File;

public class Main{
 
    /* Scheduler types and variables */
    public static final int FCFS = 0;
    
    public static final int RR = 1;
    private static int RR_quantum = 2;
    private static ArrayList<Process> RR_btc;
    
    public static final int UNI = 2;
    private static boolean UNI_canRun = true;
    private static boolean UNI_wait = false;
    
    public static final int SJF = 3;

    /* Random backend variables */
    private static boolean VERBOSE_FLAG = false;
    
    private static Scanner randScanner;
    private static Scanner inScanner;

    /* Processes lists and variables */
    private static ArrayList<Process> processesList;
    private static ArrayList<Process> processes;
    private static ArrayList<Process> readyProcesses;
    private static ArrayList<Process> blockedProcesses;
    private static ArrayList<Process> finishedProcesses;
    
    private static Process runningProcess;
    private static int cycle;
    private static int actualBlockedTime;
    
    public static void main(String[] args){
	/* Initialize variables*/
	processesList = new ArrayList<Process>();
	processes = new ArrayList<Process>();
	readyProcesses = new ArrayList<Process>();
	blockedProcesses = new ArrayList<Process>();
	finishedProcesses = new ArrayList<Process>();
	RR_btc = new ArrayList<Process>();

	/* Acount for --verbose tag */
	String fileName = "";
	if(args.length > 1){
	    if(args[0].equals("--verbose")){
		VERBOSE_FLAG = true;
	    }
	    else{
		System.err.println("The argument \'" + args[0] + "\' is unrecognized.");
		System.exit(1);
	    }

	    fileName = args[1];
	}
	else{
	    fileName = args[0];
	}
       
	/*
	 * Drivers for the four different types of schedulers. 
	 * Drivers are basically carbon copies of each other (could be offloaded to a method)
	 * but they pass specific variables depending on which shceduler type we are running.
	 */

	/* First Come First Serve */
	System.out.println("The scheduling algorithm used was First Come First Serve.");
	init(fileName);
	if(VERBOSE_FLAG){ verbosePrint(FCFS); }
	while(processes.size() > 0 || readyProcesses.size() > 0 || blockedProcesses.size() > 0 || runningProcess!=null){
	    makeReadyProcesses(FCFS);
	    incrementTime(FCFS);
	    if(VERBOSE_FLAG){ verbosePrint(FCFS); }
	    doBlockedProcesses(FCFS);
	    doRunningProcess(FCFS);
	}
	print();
	System.out.println();
	
	System.out.println("\n\nThe scheduling algorithm used was Round Robin with quantum of 2.");
	init(fileName);
	if(VERBOSE_FLAG){ verbosePrint(RR); }
	while(processes.size() > 0 || readyProcesses.size() > 0 || blockedProcesses.size() > 0 || runningProcess!=null){
	    makeReadyProcesses(RR);
	    incrementTime(RR);
	    if(VERBOSE_FLAG){ verbosePrint(RR); }
	    doBlockedProcesses(RR);
	    doRunningProcess(RR);
	}
	print();
	System.out.println();

	System.out.println("\n\nThe scheduling algorithm used was Uniprogrammed.");
	init(fileName);
	if(VERBOSE_FLAG){ verbosePrint(UNI); }
	while(processes.size() > 0 || readyProcesses.size() > 0 || blockedProcesses.size() > 0 || runningProcess!=null){
	    makeReadyProcesses(UNI);
	    incrementTime(UNI);
	    if(VERBOSE_FLAG){ verbosePrint(UNI); }
	    doBlockedProcesses(UNI);
	    doRunningProcess(UNI);
	}
	print();
	System.out.println();

	System.out.println("\n\nThe scheduling algorithm used was Shortest Job First.");
	init(fileName);
	if(VERBOSE_FLAG){ verbosePrint(SJF); }
	while(processes.size() > 0 || readyProcesses.size() > 0 || blockedProcesses.size() > 0 || runningProcess!=null){
	    makeReadyProcesses(SJF);
	    incrementTime(SJF);
	    if(VERBOSE_FLAG){ verbosePrint(SJF); }
	    doBlockedProcesses(SJF);
	    doRunningProcess(SJF);
	}
	print();
	System.out.println();
    }
	
	
    public static void print(){
	int totalTime = 0;
	int totalWaitTime = 0;
	int totalCpuTime = 0;
	int totalTurnAroundTime = 0;
	
	for(int i = 0; i < processesList.size(); i++){
	    System.out.printf("\nProcess %d:\n", i);
	    processesList.get(i).print();
	    /* Increment variables */
	    if(totalTime < processesList.get(i).getTotalTime()){
		totalTime = processesList.get(i).getTotalTime();
	    }
	    totalCpuTime+=processesList.get(i).getTotalTime() - 
		processesList.get(i).getArrivalTime() - 
		processesList.get(i).getIoTime() -
		processesList.get(i).getWaitTime();
	    totalWaitTime+=processesList.get(i).getWaitTime();
	    totalTurnAroundTime+=processesList.get(i).getTotalTime() - processesList.get(i).getArrivalTime();
	}

	System.out.println("\nSummary Data:");
	System.out.printf("        Finishing time: %d\n",totalTime);
	System.out.printf("        CPU Utilization: %f\n",(float)totalCpuTime/totalTime);
	System.out.printf("        I/O Utilization: %f\n",(float)actualBlockedTime/totalTime);
	System.out.printf("        Throughput: %f processes per hundred cycles\n", ((float)processesList.size()/totalTime)*100);
	System.out.printf("        Avarage turnaround time: %f\n", (float)totalTurnAroundTime/processesList.size());
	System.out.printf("        Avarage wait time: %f\n", (float)totalWaitTime/processesList.size());
    }
    
    /* 
     * init() - clears lists and (re)initializes scanners and 
     * (re)makes processes.
     */
    public static void init(String fileName){
	cycle = 0;
	actualBlockedTime = 0;
	processes.clear();
	processesList.clear();
	runningProcess = null;
	blockedProcesses.clear();
	finishedProcesses.clear();
	initScanners(fileName);
	createProcesses();
    }

    public static void initScanners(String fileName){ 
        try{
            randScanner = new Scanner(new File("random-numbers"));
	    inScanner = new Scanner(new File(fileName));
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    /* The original version */
    public static int randomOS(int modVal){
	return 1 + randScanner.nextInt() % modVal;
    }

    /* This version is only used for debug purposes => currently unused */
    public static int randomOS(int modVal, int type){
	int num = randScanner.nextInt();
	if(type ==0){
	    System.out.println("Find burst when choosing ready process to run " + num);
	}
	if(type ==1){
	    System.out.println("Find burst when blocking a process " + num);
	}
 
	return 1 + num%modVal;
    }
    
    /*
     * createProcesses() - creates new processes passing in needed arguments
     * from the input file.
     */
    public static void createProcesses(){
	int numProcesses = inScanner.nextInt();
	
	/* Create new processes */
	System.out.print("The original input was: ");
	for(int i = 0; i < numProcesses; i++){
	    while(!inScanner.hasNextInt()){ inScanner.next(); }
	    processes.add(new Process(
				      i,
				      inScanner.nextInt(),
				      inScanner.nextInt(),
				      inScanner.nextInt(),
				      inScanner.nextInt())
			  );
	    System.out.print(processes.get(i));
	}

	/* Sort processes */
	Collections.sort(processes, new Comparator<Process>(){
		@Override public int compare(Process p1, Process p2){
		    return ((Integer)p1.getArrivalTime()).compareTo((Integer)p2.getArrivalTime());
		}
	    });
	
	/* Print out sorted processes */
	System.out.print("\nThe (sorted) input is: ");
	for(Process p : processes){
	    processesList.add(p);
	    System.out.print(p);
	}

	if(VERBOSE_FLAG){System.out.println("\n\nThis detailed printout gives the state and remaining burst for each process:");}
    }

    /*
     * Checks to see if any processes need to be made ready this cycle. If no running
     * process exists, it sets a new running process from the ready list. If no
     * processes are in the ready list it then assigsn the current process which was 
     * made ready to be the new running process.
     */
    public static void makeReadyProcesses(int scheduler){
	
	if(scheduler == SJF){
	    for(int i =0; i < processes.size(); i++){
		if(processes.get(i).getArrivalTime() == cycle){
		    readyProcesses.add(processes.get(i));
		    processes.get(i).setState(Process.READY);
		    processes.remove(i);
		    i--;
		}
	    }
	    
	    Collections.sort(readyProcesses, new Comparator<Process>(){
		    @Override public int compare(Process p1, Process p2){
			return ((Integer)p1.getCpuTime()).compareTo((Integer)p2.getCpuTime());
		    }
		});
	    
	    if(runningProcess == null && readyProcesses.size() > 0){
		runningProcess = readyProcesses.get(0);
		if(runningProcess.getRunTimeLeft() == -100){ 
		    runningProcess.setRunTime(randomOS(runningProcess.getCpuBurst()));
		}
		runningProcess.setState(Process.RUNNING);
		readyProcesses.remove(0);
	    }
	}
	else{
	    if(runningProcess == null && readyProcesses.size() > 0){
		runningProcess = readyProcesses.get(0);
		if(runningProcess.getRunTimeLeft() == -100){ 
		    runningProcess.setRunTime(randomOS(runningProcess.getCpuBurst()));
		}
		runningProcess.setState(Process.RUNNING);
		readyProcesses.remove(0);
	    }
	    
	    for(int i =0; i < processes.size(); i++){
		if(processes.get(i).getArrivalTime() == cycle){
		    if(runningProcess == null){
			runningProcess = processes.get(i);
			runningProcess.setRunTime(randomOS(runningProcess.getCpuBurst()));
			processes.get(i).setState(Process.RUNNING);
		    }
		    else{
			readyProcesses.add(processes.get(i));
			processes.get(i).setState(Process.READY);
		    }
		    processes.remove(i);
		    i--;
		}
	    }
	}
    }
    
    /*
     * Handles blocking
     */
    public static void doBlockedProcesses(int scheduler){
	ArrayList<Process> btc = new ArrayList<Process>();
	
	switch(scheduler){
	case FCFS:
	    for(int i = 0; i < blockedProcesses.size(); i++){
		if(blockedProcesses.get(i).block()){
		    btc.add(blockedProcesses.get(i));
		    blockedProcesses.get(i).setState(Process.READY);
		    blockedProcesses.remove(i);
		    i--;
		}
	    }
	    break;
	case RR:
	    for(int i = 0; i < blockedProcesses.size(); i++){
		if(blockedProcesses.get(i).block()){
		    RR_btc.add(blockedProcesses.get(i));
		    blockedProcesses.get(i).setState(Process.READY);
		    blockedProcesses.remove(i);
		    i--;
		}
	    }
	    break;
	case UNI:
	    if(blockedProcesses.size() > 0){
		if(blockedProcesses.get(0).block()){
		    blockedProcesses.get(0).setState(Process.RUNNING);
		    if(blockedProcesses.get(0).getRunTimeLeft() == -100){ 
			blockedProcesses.get(0).setRunTime(randomOS(blockedProcesses.get(0).getCpuBurst()));
		    }
		    blockedProcesses.remove(0);
		    UNI_canRun = true;
		    UNI_wait = true;
		}
	    }
	    break;
	case SJF:
	    for(int i = 0; i < blockedProcesses.size(); i++){
		if(blockedProcesses.get(i).block()){
		    btc.add(blockedProcesses.get(i));
		    blockedProcesses.get(i).setState(Process.READY);
		    blockedProcesses.remove(i);
		    i--;
		}
	    }
	    break;
	default:
	    System.err.println("ERROR: Invalid scheduler state.");
	    System.exit(1);
	}
	Collections.sort(btc, new Comparator<Process>(){
		@Override public int compare(Process p1, Process p2){
		   if(p1.getArrivalTime() == p2.getArrivalTime()){
		       return ((Integer)p1.getArrivalNumber()).compareTo((Integer)p2.getArrivalNumber());
		   }
		   else{
		       return ((Integer)p1.getArrivalTime()).compareTo((Integer)p2.getArrivalTime());
		   }
		}
	    });

	for(int i = 0; i < btc.size(); i++){
	    readyProcesses.add(btc.get(i));
	    btc.remove(i);
	    i--;
	}
    }
    
    /* Handles running */
    public static void doRunningProcess(int scheduler){
	switch(scheduler){
	case FCFS:
	    if(runningProcess != null){
		if(runningProcess.run()){
		    if(runningProcess.getCpuTime() == 0){
			finishedProcesses.add(runningProcess);
			runningProcess.setState(Process.TERMINATED);
			runningProcess = null;
		    }
		    else{
			blockedProcesses.add(runningProcess);
			if(runningProcess.getBlockedTimeLeft() == -100){ 
			    runningProcess.setBlockedTime(randomOS(runningProcess.getIoBurst()));
			}
			runningProcess.setState(Process.BLOCKED);
			runningProcess = null;
		    }
		}
	    }
	    break;
	case RR:
	    if(runningProcess != null){
		if(RR_quantum < 0){
		    System.err.println("Error: quantum < 0!");
		    System.exit(1);
		}
		if(runningProcess.run()){
		    if(runningProcess.getCpuTime() == 0){
			finishedProcesses.add(runningProcess);
			runningProcess.setState(Process.TERMINATED);
			runningProcess = null;
		    }
		    else{
			blockedProcesses.add(runningProcess);
			if(runningProcess.getBlockedTimeLeft() == -100){ 
			    runningProcess.setBlockedTime(randomOS(runningProcess.getIoBurst()));
			}
			runningProcess.setState(Process.BLOCKED);
			runningProcess = null;
		    }
		    RR_quantum = 2;
		}
		else{
		    RR_quantum--;
		    if(RR_quantum == 0){
			if(readyProcesses.size() > 0){
			    runningProcess.setState(Process.READY);
			    RR_btc.add(runningProcess);
			    runningProcess = readyProcesses.get(0);
			    runningProcess.setState(Process.RUNNING);
			    if(runningProcess.getRunTimeLeft() == -100){
				runningProcess.setRunTime(randomOS(runningProcess.getCpuBurst()));
			    }
			    readyProcesses.remove(0);
			    Collections.sort(RR_btc, new Comparator<Process>(){
				    @Override public int compare(Process p1, Process p2){
					if(p1.getArrivalTime() == p2.getArrivalTime()){
					    return ((Integer)p1.getArrivalNumber()).compareTo((Integer)p2.getArrivalNumber());
					}
					else{
					    return ((Integer)p1.getArrivalTime()).compareTo((Integer)p2.getArrivalTime());
					}
				    }
				});
			    for(int i = 0; i < RR_btc.size(); i++){
				readyProcesses.add(RR_btc.get(i));
				RR_btc.remove(i);
				i--;
			    }
			    RR_quantum = 2;
			}
			else if(RR_btc.size() > 0){
			    Collections.sort(RR_btc, new Comparator<Process>(){
				    @Override public int compare(Process p1, Process p2){
					if(p1.getArrivalTime() == p2.getArrivalTime()){
					    return ((Integer)p1.getArrivalNumber()).compareTo((Integer)p2.getArrivalNumber());
					}
					else{
					    return ((Integer)p1.getArrivalTime()).compareTo((Integer)p2.getArrivalTime());
					}
				    }   
				});
			    runningProcess.setState(Process.READY);
			    RR_btc.add(runningProcess);
			    runningProcess = RR_btc.get(0);
			    runningProcess.setState(Process.RUNNING);
			    if(runningProcess.getRunTimeLeft() == -100){
				runningProcess.setRunTime(randomOS(runningProcess.getCpuBurst()));
			    }
			    RR_btc.remove(0);
			    Collections.sort(RR_btc, new Comparator<Process>(){
				    @Override public int compare(Process p1, Process p2){
					if(p1.getArrivalTime() == p2.getArrivalTime()){
					    return ((Integer)p1.getArrivalNumber()).compareTo((Integer)p2.getArrivalNumber());
					}
					else{
					    return ((Integer)p1.getArrivalTime()).compareTo((Integer)p2.getArrivalTime());
					}	
				    }
				});
			    for(int i = 0; i < RR_btc.size(); i++){
				readyProcesses.add(RR_btc.get(i));
				RR_btc.remove(i);
				i--;
			    }
			    RR_quantum = 2;
			}
			else{
			    RR_quantum = 2;
			}

		    }
		}	
	    } 
	    if(RR_btc.size() > 0){
		Collections.sort(RR_btc, new Comparator<Process>(){
			@Override public int compare(Process p1, Process p2){
			    if(p1.getArrivalTime() == p2.getArrivalTime()){
					    return ((Integer)p1.getArrivalNumber()).compareTo((Integer)p2.getArrivalNumber());
			    }
			    else{
				return ((Integer)p1.getArrivalTime()).compareTo((Integer)p2.getArrivalTime());
			    }
			}
		    });
		for(int i = 0; i < RR_btc.size(); i++){
		    readyProcesses.add(RR_btc.get(i));
		    RR_btc.remove(i);
		    i--;
		}
	    }
	    break;
	case UNI:
	    if(runningProcess != null){
		if(UNI_canRun && !UNI_wait){
		    if(runningProcess.run()){
			if(runningProcess.getCpuTime() == 0){
			    finishedProcesses.add(runningProcess);
			    runningProcess.setState(Process.TERMINATED);
			    runningProcess = null;
			    UNI_canRun = true;
			}
			else{
			    if(runningProcess.getBlockedTimeLeft() == -100){ 
				runningProcess.setBlockedTime(randomOS(runningProcess.getIoBurst()));
			    }
			    runningProcess.setState(Process.BLOCKED);
			    blockedProcesses.add(runningProcess);
			    UNI_canRun = false;
			}
		    }
		}
		UNI_wait = false;
	    }
	    break;
	case SJF:
	    if(runningProcess != null){
		if(runningProcess.run()){
		    if(runningProcess.getCpuTime() == 0){
			finishedProcesses.add(runningProcess);
			runningProcess.setState(Process.TERMINATED);
			runningProcess = null;
		    }
		    else{
			blockedProcesses.add(runningProcess);
			if(runningProcess.getBlockedTimeLeft() == -100){ 
			    runningProcess.setBlockedTime(randomOS(runningProcess.getIoBurst()));
			}
			runningProcess.setState(Process.BLOCKED);
			runningProcess = null;
		    }
		}
	    }
	    break;
	default:
	    System.err.println("ERROR: invalid scheduler state");
	    System.exit(0);
	    break;
	}
    }

    /* Increment total time of all 'active' processes */
    public static void incrementTime(int scheduler){
	boolean flag = false;
	for(Process p: processes){
	    p.increment();
	}
	for(Process p: readyProcesses){
	    p.increment();
	}
	for(Process p: blockedProcesses){
	    p.increment();
	    flag = true;
	}
	if(flag){
	    actualBlockedTime++;
	}
	flag = false;
	if(runningProcess != null){
	    if(scheduler == UNI){
		if(runningProcess.getState() == Process.RUNNING){
		    runningProcess.increment();
		}
	    }
	    else{
		runningProcess.increment();
	    }
	}
     
	cycle++;
    }
    
    /* Print verbose for each process */
    public static void verbosePrint(int scheduler){
	System.out.printf("Before cylce %5d:", cycle); 
	for(Process p : processesList){
	    switch(p.getState()){
	    case Process.UNSTARTED:
		System.out.printf("%12s%3d", "unstarted", 0);
		break;
	    case Process.READY:
		System.out.printf("%12s%3d", "ready", 0);
		break;
	    case Process.RUNNING:
		if(scheduler == RR){
		    System.out.printf("%12s%3d", "running", Math.min(RR_quantum,p.getRunTimeLeft()));
		}
		else{
		    System.out.printf("%12s%3d", "running", p.getRunTimeLeft());
		}
		break;
	    case Process.BLOCKED:
		System.out.printf("%12s%3d", "blocked", p.getBlockedTimeLeft());
		break;
	    case Process.TERMINATED:
		System.out.printf("%12s%3d", "terminated", 0);
		break;
	    default:
		System.err.println("ERROR: Invalid process state");
		System.exit(0);
	    }
	}
	System.out.printf("\n");
    }  
}