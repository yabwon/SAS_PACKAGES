## SAS Packages: 
To get started with SAS Packages try this [**`Getting Started with SAS Packages`**](https://github.com/yabwon/SAS_PACKAGES/blob/main/SPF/Documentation/Getting_Started_with_SAS_Packages.pdf "Getting Started with SAS Packages") presentation (see the `./SPF/Documentation` directory).

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
SHA256 digest for SQLinDS: 9788D7ED2863B2B0A575EB9AB07B5F88AE79A56D9ED9B3B4F15A02E34DF7AA64

[Documentation for SQLinDS](https://github.com/yabwon/SAS_PACKAGES/blob/main/packages/sqlinds.md "Documentation for SQLinDS")

---

- **MacroCore**\[1\], a macro library for SAS application developers. Over 100 macros for Base SAS, metadata, and Viya. Provided by the [SASjs framework](https://sasjs.io "SASjs framework").

SHA256 digest for MacroCore: A23C29529F3CE7D0C8BEE9545C5D22D5B5594907547374A5135B8E5A48D7687B

[Documentation for MacroCore](https://core.sasjs.io "Documentation for MacroCore")

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
SHA256 digest for DFA: 069BD1BD482634F2D6EB3EFF68E7F8569D2F2C232BFF5D7D44BBD839D8F224A4

---

- **macroArray**\[0.7\], implementation of an array concept in a macro language, e.g. 
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
SHA256 digest for macroArray: 0DB634148FA104F4AD9D6A522466D605118EE8696774DC1BB7C4145ED3BB9B9B

[Documentation for macroArray](https://github.com/yabwon/SAS_PACKAGES/blob/main/packages/macroarray.md "Documentation for macroArray")

---

- **BasePlus**\[0.9\] adds a bunch of functionalities I am missing in BASE SAS, such as: 
```
call arrMissToRight(myArray); 
call arrFillMiss(17, myArray); 
call arrFill(42, myArray); 

rc = delDataset("DataSetToDrop"); 

string = catXFn("date9.", "#", myArray);

format x bool.;

%put %getVars(sashelp.class, pattern = ght$, sep = +, varRange = _numeric_);
```
SHA256 digest for BasePlus: 612095260F73D00A08D64C49FC57F4D5BEE0AFBA9D8194AE63EA5BCF7A15E068

[Documentation for BasePlus](https://github.com/yabwon/SAS_PACKAGES/blob/main/packages/baseplus.md "Documentation for BasePlus")

---

- **dynMacroArray**\[0.2\], set of macros (wrappers for a hash table) emulating dynamic array in the data step (macro predecessor of DFA)

SHA256 digest for dynMacroArray: CA9BFF0747019BA6FDB2107C60F58D2D6C5E686EADFA4E1C6A81BC469CBC9F4A

---
