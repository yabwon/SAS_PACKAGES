## SAS Packages: 
To get started with SAS Packages try this [**`Getting Started with SAS Packages`**](https://github.com/yabwon/SAS_PACKAGES/blob/main/SPF/Documentation/Getting_Started_with_SAS_Packages.pdf "Getting Started with SAS Packages") presentation (see the `./SPF/Documentation` directory).

## Available packages: 
For "backward compatibility"/historical point of view the following packages are available under the `./packages` directory.

Since *September 2022* the default location for packages is **SASPAC - the SAS Packages Archive** located under: [`https://github.com/SASPAC`](https://github.com/SASPAC) where each package is stored as a separate repository with historical versions too.

Packages:

---

- **SQLinDS**\[2.2.6\], based on Mike Rhoads' article *Use the Full Power of SAS in Your Function-Style Macros*. The package allows to write SQL queries in the data step, e.g.
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
SHA256 digest for SQLinDS: F*3BB422E8C94515DEE9E13E674A0D119794F464D9597C28D5D536E71F64EB5298

[Documentation for SQLinDS](https://github.com/yabwon/SAS_PACKAGES/blob/main/packages/sqlinds.md "Documentation for SQLinDS")

---

- **DFA** (Dynamic Function Arrays)\[0.5.5\], contains set of macros and FCMP functions which implement: a dynamically allocated array, a stack, a fifo queue, an ordered stack, and a priority queue, run `%helpPackage(DFA,createDFArray)` to find examples.
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
SHA256 digest for DFA: F*924711C77E413B8CFC18336DDA2293A9F5294D02E267C1BB7BC876B4AF0AABE4

[Documentation for DFA](https://github.com/yabwon/SAS_PACKAGES/blob/main/packages/dfa.md "Documentation for DFA")

---

- **macroArray**\[1.0.5\], implementation of an array concept in a macro language, e.g. 
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
SHA256 digest for macroArray: F*85E3BE4D163AC5223B6EC9D3C25C46564A656E3830998B4555A963180D767160

[Documentation for macroArray](https://github.com/yabwon/SAS_PACKAGES/blob/main/packages/macroarray.md "Documentation for macroArray")

---

- **BasePlus**\[1.29.0\] adds a bunch of functionalities I am missing in BASE SAS, such as: 
```sas
call arrMissToRight(myArray); 
call arrFillMiss(17, myArray); 
call arrFill(42, myArray); 

rc = delDataset("DataSetToDrop"); 

string = catXFn("date9.", "#", myArray);

format x bool.;

%put %getVars(sashelp.class, pattern = ght$, sep = +, varRange = _numeric_);

%rainCloudPlot(sashelp.cars,DriveTrain,Invoice)

%zipLibrary(sashelp,libOut=work)

%bpPIPE(ls -la ~/)

%dirsAndFiles(C:\SAS_WORK\,ODS=work.result)

%put %repeatTxt(#,15,s=$) HELLO SAS! %repeatTxt(#,15,s=$);
```
SHA256 digest for BasePlus: F*9EEE4F4B99EA725B60141645AB6A50BFEBA32CE54848593F8D832D907D63CAD7

[Documentation for BasePlus](https://github.com/yabwon/SAS_PACKAGES/blob/main/packages/baseplus.md "Documentation for BasePlus")

---

- **GSM** (Generate Secure Macros)\[0.21.0\], package allows
 to create secured macros stored in SAS Proc FCMP functions.
 The dataset with functions can be shared between different operating systems
 and allows to generate macros on site without showing their code.

SHA256 digest for GSM: F*56DC0DCCE06B4281BF3FA6FA3875CBA87772BDA7FAB601B06740A7980FFB0E07

[Documentation for GSM](https://github.com/yabwon/SAS_PACKAGES/blob/main/packages/gsm.md "Documentation for GSM")

---

- **dynMacroArray**\[0.2.5\], set of macros (wrappers for a hash table) emulating dynamic array in the data step (macro predecessor of DFA). Development of this package is currently on hold.

SHA256 digest for dynMacroArray: F*6E087F38BB39B93CBF983124272812E14693C4EF5EE0A3A218BD2BAA069A74BF

---
