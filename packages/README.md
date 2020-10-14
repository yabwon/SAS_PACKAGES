## SAS Packages: 
To get started with SAS Packages try this [**`Getting Started with SAS Packages`**](https://github.com/yabwon/SAS_PACKAGES/blob/master/SPF/Documentation/Getting_Started_with_SAS_Packages.pdf "Getting Started with SAS Packages") presentation (see the `./SPF/Documentation` directory).

## Available packages: 
Currently the following packages are available:

---

- **SQLinDS**\[2.2\], based on Mike Rhoads' article *Use the Full Power of SAS in Your Function-Style Macros*. The package allows to write SQL queries in the data step, e.g.
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
SHA256 digest for SQLinDS: FCD7EE5B59E08CD1A2E31F6A5D94D7275C99AFFAACEA3D187F60A57CD0520FCD

[Documentation for SQLinDS](https://github.com/yabwon/SAS_PACKAGES/blob/master/packages/sqlinds.md "Documentation for SQLinDS")

---

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
SHA256 digest for DFA: CC19058354D4B51F0675A8414F18089CCC583AA45822CEFC79368F06D8715846

---

- **macroArray**\[0.5\], implementation of an array concept in a macro language, e.g. 
```
  %array(ABC[17] (111:127), macarray=Y); 
  
  %macro test();
    %do i = 1 %to 17; 
      %put &i.) %ABC(&i.); 
    %end;
  %mend;
  %test() 
  
  %let %ABC(13,i) = 99999; /* i = insert */

  %do_over(ABC, phrase=%nrstr( 
      %put &_i_.%) %ABC(&_i_.); 
      ),
      which = 1:H:2
  );
```
SHA256 digest for macroArray: 96215AC04EF26C97719F6B1EDA5ACAF7DD491B7F2DDDE9985A0560CD2916ABA1

[Documentation for macroArray](https://github.com/yabwon/SAS_PACKAGES/blob/master/packages/macroarray.md "Documentation for macroArray")

---

- **BasePlus**\[0.7\] adds a bunch of functionalities I am missing in BASE SAS, such as: 
```
call arrMissToRight(myArray); 
call arrFillMiss(17, myArray); 
call arrFill(42, myArray); 

rc = delDataset("DataSetToDrop"); 

string = catXFn("date9.", "#", myArray);

format x bool.;

%put %getVars(sashelp.class, pattern = ght$, sep = +, varRange = _numeric_);
```
SHA256 digest for BasePlus: 4E0C2A45CF8A5863C0D054568C712D10A296240877D604E77A778451A740874B

[Documentation for BasePlus](https://github.com/yabwon/SAS_PACKAGES/blob/master/packages/baseplus.md "Documentation for BasePlus")

---

- **dynMacroArray**\[0.2\], set of macros (wrappers for a hash table) emulating dynamic array in the data step (macro predecessor of DFA)

SHA256 digest for dynMacroArray: 0854317DE7A97DCFE30411B37D909F04BBE12F1F9F7C45D39CBCD61641158F80

---
