## SAS Packages: 
To get started with SAS Packages try this [**`Getting Started with SAS Packages`**](https://github.com/yabwon/SAS_PACKAGES/blob/main/SPF/Documentation/Getting_Started_with_SAS_Packages.pdf "Getting Started with SAS Packages") presentation (see the `./SPF/Documentation` directory).

## Available packages: 
Currently the following packages are available:

---

- **SQLinDS**\[2.2\], based on Mike Rhoads' article *Use the Full Power of SAS in Your Function-Style Macros*. The package allows to write SQL queries in the data step, e.g.
```sas
data class;
  set %SQL(
    select age, name, weight, height 
    from sashelp.class 
    order by age
    );
    
    WH = weight + height;
run;
```
SHA256 digest for SQLinDS: 3034A0C8AC43683AD55698861DBBDEBDE6FC8567D59ECF2BB5F3389FE6BC8062

[Documentation for SQLinDS](https://github.com/yabwon/SAS_PACKAGES/blob/main/packages/sqlinds.md "Documentation for SQLinDS")

---

- **MacroCore**\[1\], a macro library for SAS application developers. Over 100 macros for Base SAS, metadata, and Viya. Provided by the [SASjs framework](https://sasjs.io "SASjs framework").

SHA256 digest for MacroCore: A23C29529F3CE7D0C8BEE9545C5D22D5B5594907547374A5135B8E5A48D7687B

[Documentation for MacroCore](https://core.sasjs.io "Documentation for MacroCore")

---

- **DFA** (Dynamic Function Arrays)\[0.4\], contains set of macros and FCMP functions which implement: a dynamically allocated array, a stack, a fifo queue, an ordered stack, and a priority queue, run `%helpPackage(DFA,createDFArray)` to find examples.
```sas
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
SHA256 digest for DFA: E777D4578DFDEB2277D58264BAB5BFDBEAFD4E538D4831CDCBFFB4216D2441C2

[Documentation for DFA](https://github.com/yabwon/SAS_PACKAGES/blob/main/packages/dfa.md "Documentation for DFA")

---

- **macroArray**\[0.8\], implementation of an array concept in a macro language, e.g. 
```sas
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
SHA256 digest for macroArray: 42E87B80450B3E1AD462B9B63B41F34C83B7745AA0F98C3CA72AA19F3B1FF10E

[Documentation for macroArray](https://github.com/yabwon/SAS_PACKAGES/blob/main/packages/macroarray.md "Documentation for macroArray")

---

- **BasePlus**\[0.991\] adds a bunch of functionalities I am missing in BASE SAS, such as: 
```sas
call arrMissToRight(myArray); 
call arrFillMiss(17, myArray); 
call arrFill(42, myArray); 

rc = delDataset("DataSetToDrop"); 

string = catXFn("date9.", "#", myArray);

format x bool.;

%put %getVars(sashelp.class, pattern = ght$, sep = +, varRange = _numeric_);
```
SHA256 digest for BasePlus: 28F3DE865C5E3B914FFB7CC2627D8B0975527EEECEE7AFEAD7B335C3FDC1BFD3

[Documentation for BasePlus](https://github.com/yabwon/SAS_PACKAGES/blob/main/packages/baseplus.md "Documentation for BasePlus")

---

- **dynMacroArray**\[0.2\], set of macros (wrappers for a hash table) emulating dynamic array in the data step (macro predecessor of DFA)

SHA256 digest for dynMacroArray: 8B0777EA3CF41968C0B029AA57B1F809D21D1BAB1B88A35B0EA5DB3C6DD9E748

---
