with Text_IO;
use Text_IO;

package body Sort is
   
   package Int_Io is new Integer_Io(Integer);
   use Int_Io;
   
   procedure MergeSort(InArr: in out Arr; Lo : in IndexRange; Hi : in IndexRange) is
      TempArr : Arr;
      Mid: Integer := (Lo + Hi)/2;
      LoIndex : Integer := Lo;
      HiIndex : Integer := Mid+1;
      
      procedure RunTasks is
	 task Left;
	 task body Left is
	 begin
	    if(Lo < Mid) then
	      MergeSort(InArr,Lo, Mid);
	    end if;  
	 end Left;
	 
	 task Right;
	 task body Right is
	 begin
	    if(Mid+1 < Hi) then
	      MergeSort(InArr,Mid+1, Hi);
	    end if;
	 end Right;
      begin
	 null;
      end RunTasks;
   begin
      
      RunTasks;
      
      for I in Lo .. Hi loop	 
	 if (LoIndex = Mid+1) then
	   TempArr(I) := InArr(HiIndex);
	   HiIndex := HiIndex + 1; 
	 elsif (HiIndex = Hi+1) then
	   TempArr(I) := InArr(LoIndex);
	   LoIndex := LoIndex + 1;
	 else
	    if(InArr(LoIndex) <= InArr(HiIndex)) then
	       TempArr(I) := InArr(LoIndex);
	       LoIndex := LoIndex + 1;
	    else
	       TempArr(I) := InArr(HiIndex);
	       HiIndex := HiIndex + 1;
	    end if;
	 end if;
      end loop;
      
      for I in Lo .. Hi loop
	InArr(I) := TempArr(I);
      end loop;
      
   end MergeSort;
end Sort;
