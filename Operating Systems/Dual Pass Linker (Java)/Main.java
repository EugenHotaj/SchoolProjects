import java.util.Scanner;
import java.util.ArrayList;
import java.io.File;


public class Main{
    /* Variables */
    public static File inFile;
    public static Scanner scanner;
    public static String uts = "";
    public static String memMap = "Memory Map \n";
    public static String[] tokens;
    
    public static MetaData data;
    
    public static void main(String[] args){
	data = new MetaData();
	
	TokenizeInput(args[0]);
	LinkerPassOne();
	data.printSymbolTable();
	LinkerPassTwo();
	PrintOutput();
    }

    public static void LinkerPassTwo(){
	ArrayList<String> useList = new ArrayList<String>();

	int ptr = 0;
	int ctr = 0;
	int memCtr = 0;
	int modNum = 0;
	
	while(ptr < tokens.length){
	    
	    useList.clear();

	    /* Skip external symbol defenitions */
	    ptr += 1 + 2*Integer.parseInt(tokens[ptr]);

	    /* Keep track of used elements */
	    ctr = Integer.parseInt(tokens[ptr++]);
	    for(int i = 0; i < ctr; i++){
		useList.add(tokens[ptr++]);
	    }

	    /* Handle Instructions */
	    ctr = Integer.parseInt(tokens[ptr++]); 
	    boolean[] used = new boolean[useList.size()];
	    for(int i = 0; i < used.length; i++){
		used[i] = false;
	    }

	    for(int i = 0; i < ctr; i++){
		
		if(tokens[ptr].equals("I") || tokens[ptr].equals("A")){
		    String type = tokens[ptr];
		    if(Integer.parseInt(tokens[++ptr]) % 1000>599 && type.equals("A")){
			memMap += memCtr++ + ": " + tokens[ptr++].charAt(0) + "000";
			memMap += " Error: Absolute address exceeds machine size; zero used.\n";
		    }
		    else{
			memMap += memCtr++ + ": " + tokens[ptr++] + "\n";
		    }
		}
		else if(tokens[ptr].equals("R")){
		    int relAdd = (Integer.parseInt(tokens[++ptr]) % 1000) + data.getModuleAdress(modNum);
		    int addMeasure = 0;
		    if(modNum + 1 > data.getNumModules()){
			addMeasure = data.getLastAdress();
		    }
		    else{
			addMeasure = data.getModuleAdress(modNum + 1) -1;
		    }
		    if(relAdd > addMeasure){
			memMap += memCtr++ + ": " + tokens[ptr++].charAt(0) + "000";
			memMap += " Error: Relative adress exceeds module size; zero used.\n";
		    }
		    else{
			memMap += memCtr++ + ": " + tokens[ptr++].charAt(0) + String.format("%03d",relAdd) + "\n";
		    }
		}
		else if(tokens[ptr].equals("E")){
		    int extAdd = 0;
		    
		    if(Integer.parseInt(tokens[++ptr]) % 1000 < useList.size()){
			if(data.getSymAdd(useList.get((Integer.parseInt(tokens[ptr]) % 1000))) != null){
			    extAdd = data.getSymAdd(useList.get((Integer.parseInt(tokens[ptr]) % 1000)));
			    data.setUsed(useList.get(Integer.parseInt(tokens[ptr]) % 1000),true);
			    used[Integer.parseInt(tokens[ptr]) % 1000] = true;
			    memMap += memCtr++ + ": " + tokens[ptr++].charAt(0) + String.format("%03d",extAdd) + "\n";
			}
			else{
			    memMap += memCtr++ + ": " + tokens[ptr].charAt(0) + String.format("%03d",extAdd);
			    memMap += " Error: Symbol " + useList.get((Integer.parseInt(tokens[ptr++]) % 1000)) + " is not defined; zero used.\n";
			}
		    }
		    else{
			memMap += memCtr++ + ": " + tokens[ptr++];
			memMap += " Error: External adress exceeds length of use list; treated as immediate.\n";
		    }
		}
		else{
		    System.err.println("ERROR: Something went wrong in instruction handling during the second pass.");
		    System.err.println("PTR: " + ptr);
		    System.err.println("Current Token: " + tokens[ptr]);
		    System.exit(0);
		}
	    }
	    
	    for(int i = 0; i < useList.size(); i++){
		if(!used[i]){
		    data.addWarning("Warning: In module " + modNum + useList.get(i) + " appreared in the use list but was not actually used.\n"); 
		}
	    }

	    modNum++;
	}
    }
    
    public static void LinkerPassOne(){
	int ptr = 0;
	int memCtr = 0;
	int modCtr = 1;
	int ctr = 0;

	/* Handle individual modules */
	while(ptr < tokens.length){
	    
	    /* Handle external symbol defenitions */
	    ctr = 2 * Integer.parseInt(tokens[ptr++]);
	    
	    for(int i = 0; i < ctr; i+=2){
		data.addSymbol(tokens[ptr++],memCtr + Integer.parseInt(tokens[ptr++]), modCtr);
	    }
	    
	    /* Skip uses for now */
	    ctr = Integer.parseInt(tokens[ptr++]);
	    ptr += ctr;
	    
	    /* Count memory, add to the module, then skip instructions for now */
	    ctr = 2 * Integer.parseInt(tokens[ptr++]);
	    memCtr += ctr/2;
	    data.addModule(memCtr);
	    ptr += ctr;
	    modCtr++;
	}
	data.setLastAdress(memCtr);
    }
    
    public static void TokenizeInput(String fileName){
	
	/* Load Input File */
        try{
            inFile = new File(fileName);
        }
        catch(Exception e){
            e.printStackTrace();
        }

        /* Build Input String From Input File */
        try{
            scanner = new Scanner(inFile);
        }
        catch(Exception e){
            e.printStackTrace();
        }
        while(scanner.hasNextLine()){
            uts += scanner.nextLine() + " ";
        }

        /* Split String Into Tokens */
        uts = uts.trim();
	tokens = uts.split("\\s+");
    }
    
    public static void PrintOutput(){
	System.out.println(memMap);
	data.printWarningList();
    }
}