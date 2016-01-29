with Text_Io; use Text_IO;
with Sort; use Sort;

procedure ProgMain is
  package Int_Io is new Integer_Io(Integer);
  use Int_Io;  
  InArr : Arr; 
  
  task Reader is
     entry Read;
  end Reader;
  
  task body Reader is
  begin
     accept Read do
	for I in 1 .. SIZE loop
	   Get(InArr(I));
	end loop;
     end Read;
  end Reader;
  
  procedure SumAndPrint is
     
     Total : Integer := 0;
     
     task Sum is
	entry DoneWithSum;
     end Sum;
     
     task Printer;
     
     task body Sum is
     begin
	for I in 1 .. SIZE loop
	   Total := Total + InArr(I);
	end loop;
	
	accept DoneWithSum do
	   null;
	end DoneWithSum;
     end Sum;
     
     task body Printer is
     begin
	for I in 1 .. SIZE loop
	   Put(InArr(I), 0);
	   Put(" ");
	end loop; 
	
	Sum.DoneWithSum;
      
	New_Line;
	Put("Sum = ");
	Put(Total, 0);
     end Printer;
  begin
     null;
  end SumAndPrint;

begin
   Reader.Read;
   MergeSort(InArr,1,40);
   SumAndPrint;
end ProgMain;
