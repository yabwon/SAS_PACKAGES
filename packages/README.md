## Available packages:
Currently the following packages are available:

- **SQLinDS**\[2.1\], based on Mike Rhoads' article *Use the Full Power of SAS in Your Function-Style Macros*. The package allows to write SQL queries in the data step, e.g.
```
data class;
  set %SQL(
    select age, name, weight, height 
    from sashelp.class 
    order by age
    );
    
    WH = weight + height;
run;
```

- **DFA** (Dynamic Function Arrays)\[0.2\], contains set of macros and FCMP functions which implement: a dynamically allocated array, a stack, a fifo queue, an ordered stack, and a priority queue, run `%helpPackage(DFA,createDFArray)` to find examples.
```
%createDFArray(ArrDynamic, resizefactor=17);

data _null_;
  call ArrDynamic("Allocate", -2, 2);

  do i = -2 to 2;
    call ArrDynamic("Input", i, 2**i);
  end;

  L = .; H = .;
  call ArrDynamic("Dim", L, H);
  put L= H=;

  call ArrDynamic("+", 3, 8);
  call ArrDynamic("+",-3, 0.125);
  call ArrDynamic("Dim", L, H);
  put L= H=;

  Value = .;
  do i = L to H;
    call ArrDynamic("O", i, Value);
    put i= Value=;
  end;
run;
```

- **macroArray**\[0.3\], implementation of an array concept in a macrolanguage, e.g. 
```
  %array(ABC[17] (111:127), macarray=Y); 

  %do i = 1 %to 17; 
    %put &i.) %ABC(&i.); 
  %end;

  %let %ABC(13,i) = 999; /* i = insert */

  %do i = 1 %to 17; 
    %put &i.) %ABC(&i.); 
  %end;
```

- **BasePlus**\[0.5\] adds a bunch of functionalities I am missing in BASE SAS, such as:
```
call arrMissToRight(myArray); 
call arrFillMiss(17, myArray); 
call arrFill(42, myArray); 

rc = delDataset("DataSetToDrop"); 

string = catXFn("date9.", "#", myArray);

format x bool.;

%put %getVars(sashelp.class, patern = ght$, sep = +, varRange = _numeric_);
```

- **dynMacroArray**\[0.2\], set of macros (wrappers for a hash table) emulating dynamic array in the data step (macro predecessor of DFA)

