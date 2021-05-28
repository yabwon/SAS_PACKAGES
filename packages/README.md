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
SHA256 digest for SQLinDS: 1853CD6262CF66582A33C373AA612CA714B61CB88A1C51745E7A57D5A03C39B4

[Documentation for SQLinDS](https://github.com/yabwon/SAS_PACKAGES/blob/main/packages/sqlinds.md "Documentation for SQLinDS")

---

- **MacroCore**\[1\], a macro library for SAS application developers. Over 100 macros for Base SAS, metadata, and Viya. Provided by the [SASjs framework](https://sasjs.io "SASjs framework").

SHA256 digest for MacroCore: A23C29529F3CE7D0C8BEE9545C5D22D5B5594907547374A5135B8E5A48D7687B

[Documentation for MacroCore](https://core.sasjs.io "Documentation for MacroCore")

---

- **DFA** (Dynamic Function Arrays)\[0.5\], contains set of macros and FCMP functions which implement: a dynamically allocated array, a stack, a fifo queue, an ordered stack, and a priority queue, run `%helpPackage(DFA,createDFArray)` to find examples.
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
SHA256 digest for DFA: 22AB51B85E3344B8C0FB7AF164247881B656F5CBA88BBA974AD8BC41ED79327F

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
SHA256 digest for macroArray: 849629D3AF3FE3AB45D86990E303F1D5E4D5F9F31C8ED6864C95B0DFAADCA445

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
SHA256 digest for BasePlus: A321A4BC54D444B82575EC5D443553A096557AD69DC171D578A330277E67637A

[Documentation for BasePlus](https://github.com/yabwon/SAS_PACKAGES/blob/main/packages/baseplus.md "Documentation for BasePlus")

---

- **dynMacroArray**\[0.2\], set of macros (wrappers for a hash table) emulating dynamic array in the data step (macro predecessor of DFA)

SHA256 digest for dynMacroArray: 67956116578E71327748B7EB3DAFF9D872DBC6F6EDD0DC11B7CF2A54FDA71785

---
