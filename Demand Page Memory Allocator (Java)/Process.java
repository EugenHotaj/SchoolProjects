public class Process{
    
    private float A;
    private float B;
    private float C;
    
    private int size;
    private int refLeft;
    private int prevRef;
    private int faults;
    private int evictions;
    private int residency;
    private int currentReference;

    private boolean initial_flag;
    private boolean finished;
    
    public Process(float A, float B, float C, int size, int refLeft){
	this.A = A;
	this.B = B;
	this.C = C;
	this.size = size;
	this.refLeft = refLeft;
	
	initial_flag = true;
	finished = false;
	prevRef = Integer.MIN_VALUE;
	faults = 0;
	evictions = 0;
	residency = 0;
    }

    public float getA(){ return A; }
    public float getB(){ return B; }
    public float getC(){ return C; }

    public int getSize(){ return size; }
    public int getRefLeft(){ return refLeft; }
    public int getPrevRef(){ return prevRef; }
    public int getFaults(){ return faults; }
    public int getEvictions(){ return evictions; }
    public int getResidency(){ return residency; }
    public int getCurrentReference() { return currentReference; }
    
    public boolean getInitial(){ return initial_flag; }
    public boolean getFinished(){ return finished; }

    public boolean decrementRef(){ 
	refLeft--;
	if(refLeft > 0){
	    return false;
	}
	finished = true;
	Main.totalFinished++;
	return true;
    }
    public void falsifyInitial(){ initial_flag = false; }
    public void setPrevRef(int ref){ prevRef = ref; }
    public void incFaults(){ faults++; }
    public void incEvictions(){ evictions++; }
    public void setResidency(int i){ residency += i; }
    public void setCurrentReference(int i) { currentReference = i; }
}