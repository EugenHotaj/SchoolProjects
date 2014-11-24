public class Process{
    
    public static final int UNSTARTED = 0;
    public static final int READY = 4;
    public static final int RUNNING = 1;
    public static final int BLOCKED = 2;
    public static final int TERMINATED = 3;
    
    private int state;

    private int arrivalNumber;
    private int arrivalTime;
    private int cpuBurst;
    private int cpuTime;
    private int oCpuTime;
    private int ioBurst;
    
    private int totalTime;
    private int waitTime;
    private int ioTime;
    
    private int runTime;
    private int blockedTime; 

    public Process(int arrivalNumber, int arrivalTime, int cpuBurst, int cpuTime, int ioBurst){
	this.arrivalNumber = arrivalNumber;
	this.arrivalTime = arrivalTime;
	this.cpuBurst = cpuBurst;
	this.cpuTime = cpuTime;
	this.oCpuTime = cpuTime;
	this.ioBurst = ioBurst;

	state = UNSTARTED;
	
	totalTime = 0;
	waitTime = 0;
	ioTime = 0;
	
	runTime = -100;
	blockedTime = -100;
    }

    /* Getters */

    public int getArrivalNumber(){
	return arrivalNumber;
    }
    
    public int getArrivalTime(){
	return arrivalTime;
    }

    public int getCpuTime(){
	return cpuTime;
    }
    
    public int getCpuBurst(){
	return cpuBurst;
    }

    public int getIoBurst(){
	return ioBurst;
    }
    
    public int getState(){
	return state;
    }

    public void setState(int i){
	state = i;
    }

    public int getRunTimeLeft(){
	return runTime;
    }

    public void setRunTime(int i){
	runTime = i;
    }
    
    public void setBlockedTime(int i){
	blockedTime = i;
    }

    public int getBlockedTimeLeft(){
	return blockedTime;
    }
    
    public int getTotalTime(){
	return totalTime;
    }
    
    public int getWaitTime(){
	return waitTime;
    }
    
    public int getIoTime(){
	return ioTime;
    }
    
    
    public void increment(){
	totalTime++;
	switch(state){
	case READY:
	    waitTime++;
	    break;
	case BLOCKED:
	    ioTime++;
	    break;
	case RUNNING:
	    break;
	}
    }

    public boolean block(){
	if(blockedTime <= 0 && blockedTime != -100){
	    System.err.println("Error: Process should not be blocked! Blocked time <= 0!");
	    System.exit(1);
	}
	
	blockedTime--;
	
	if(blockedTime == 0){
	    blockedTime = -100;
	    return true;
	}
	return false;
    }

    public boolean run(){
	if((runTime <= 0 && runTime !=-100)){
	    System.err.println("Error: Process should not be running! ruTime or cpuTime <= 0!");
	    System.exit(1);
	}
	
	runTime --;
	cpuTime --;
	
	if(runTime == 0 || cpuTime == 0){
	    runTime = -100;
	    return true;
	}

	return false;
    }
    
    @Override public String toString(){
	return "(" + arrivalTime + " " + cpuBurst + " " + cpuTime + " " + ioBurst + ") ";
    }

    public void print(){
	System.out.printf("        %s = (%d,%d,%d,%d)\n","(A,B,C,IO )",arrivalTime,cpuBurst,oCpuTime, ioBurst);
	System.out.printf("        %s %d\n","Finishing time:",totalTime);
	System.out.printf("        %s %d\n","Turnaround time:",totalTime - arrivalTime);
	System.out.printf("        %s %d\n","I/O time:",ioTime);
	System.out.printf("        %s %d\n","Waiting time:",waitTime);
    }
}