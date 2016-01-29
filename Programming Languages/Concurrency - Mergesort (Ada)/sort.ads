package Sort is
   SIZE : constant Integer := 40;
   subtype AllowableRange is Integer range -500 .. 500;
   subtype IndexRange is Integer range 1 .. SIZE;
   type Arr is array (1 .. SIZE) of AllowableRange;
   procedure MergeSort(InArr : in out Arr; Lo : in IndexRange; Hi : in IndexRange);
end Sort;
   
