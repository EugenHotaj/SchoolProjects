public class Frame{
    private int cycle;
    private int process;
    private int value;
    
    public Frame(int cycle, int process, int value){
	this.cycle = cycle;
	this.process = process;
	this.value = value;
    }

    public int getCycle() { return cycle; }
    public int getProcess() { return process; }
    public int getValue() { return value; }

    public void setCycle(int i) { cycle = i; }
    public void setProcess(int i) { process = i; }
    public void setValue(int i) { value = i; }
}