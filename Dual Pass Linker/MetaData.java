import java.util.HashMap;
import java.util.ArrayList;

public class MetaData{
    
    private HashMap<String, Integer>  symbols;
    private HashMap<String, Boolean> used;
    private HashMap<String, Integer> symMod;
    private HashMap<String, Integer> initAddSize;
    
    private ArrayList<String> symList;
    private ArrayList<Integer> modules;
    private ArrayList<String> multDef;

    private String symTable = "Symbol Talbe\n";
    private String warnings = "";
    
    private int lastAdress = 0;
    
    public MetaData(){
	symbols = new HashMap<String, Integer>();
	symList = new ArrayList<String>();
	symMod = new HashMap<String, Integer>();
	used = new HashMap<String, Boolean>();
	initAddSize = new HashMap<String, Integer>();
	multDef = new ArrayList<String>();
	modules = new ArrayList<Integer>();
	modules.add(0); //first module always starts at 0
    }

    public int getLastAdress(){
	return lastAdress;
    }

    public void addWarning(String s){
	warnings += s;
    }
    
    public void setLastAdress(int i){
	lastAdress = i;
    }
    
    public void addModule(int address){
	modules.add(address);
    }
    
    public int getNumModules(){
	return modules.size();
    }

    public Integer getModuleAdress(int module){
	return modules.get(module);
    }
    
    public void setUsed(String key, boolean b){
	used.put(key,b);
    }

    public void addSymbol(String key, int value, int module){
	if(symbols.get(key)!=null){
	    multDef.add(key);
	    //symTable += " Error: This variable is multiply defined; first value used.";
	    return;
	}
	symbols.put(key,value);
	used.put(key,false);
	symList.add(key);
	symMod.put(key,module);
    }
    
    public Integer getSymAdd(String key){
	return symbols.get(key);
    }
    
    public void printSymbolTable(){
	int modSize = 0;
	ArrayList<String> sizeList = new ArrayList<String>();
	for(int i = 0; i < symList.size(); i++){
	    if(symMod.get(symList.get(i))  > getNumModules()){
		modSize = getLastAdress() - getModuleAdress(symMod.get(symList.get(i))-1); 
	    }
	    else{
		modSize = getModuleAdress(symMod.get(symList.get(i))) - getModuleAdress(symMod.get(symList.get(i))-1); 
	    }
	    if(symbols.get(symList.get(i)) - getModuleAdress(symMod.get(symList.get(i))-1) > modSize){
		symMod.put(symList.get(i),0);
		sizeList.add(symList.get(i));
	    }
	}
	for(int i = 0; i < symList.size(); i++){
	    symTable += symList.get(i) + "=" + symbols.get(symList.get(i));
	    if(multDef.contains(symList.get(i))){
		symTable += " Error: This variable is multiply defined; first value used.";
	    }
	    if(sizeList.contains(symList.get(i))){
		symTable += " Error: Address of this variable exceeds module size; zero used.";
	    }
	    symTable +="\n";
	}
	System.out.println(symTable);
    }
    
    public void printWarningList(){
	for(int i = 0; i < symList.size(); i++){
	    if(!used.get(symList.get(i))){
		warnings += "Warning: " + symList.get(i) + " was defined in module " + symMod.get(symList.get(i)) + " but was never used.\n";
	    }
	}
	System.out.println(warnings);
    }
}