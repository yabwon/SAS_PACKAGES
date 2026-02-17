## SAS Packages: 
To get started with SAS Packages try this [**`Getting Started with SAS Packages`**](https://github.com/yabwon/SAS_PACKAGES/blob/main/SPF/Documentation/Getting_Started_with_SAS_Packages.pdf "Getting Started with SAS Packages") presentation (see the `./SPF/Documentation` directory).

## Available packages: 
For "backward compatibility"/historical point of view the following packages are available under the `./packages` directory.

Since *September 2022* the default location for packages is **SASPAC - the SAS Packages Archive** located under: [`https://github.com/SASPAC`](https://github.com/SASPAC) where each package is stored as a separate repository with historical versions too.

Packages:

---

- **SQLinDS**\[2.3.3\], based on Mike Rhoads' article *Use the Full Power of SAS in Your Function-Style Macros*. The package allows to write SQL queries in the data step, e.g.
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
SHA256 digest for SQLinDS: F*6CC51325BDCE164B2E811896DD1C3A6D44242F50CC313D0721350CA49975F628

[Documentation for SQLinDS](https://github.com/SASPAC/blob/main/sqlinds.md "Documentation for SQLinDS")

---

- **DFA** (Dynamic Function Arrays)\[0.5.10\], contains set of macros and FCMP functions which implement: a dynamically allocated array, a stack, a fifo queue, an ordered stack, and a priority queue, run `%helpPackage(DFA,createDFArray)` to find examples.
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
SHA256 digest for DFA: F*C1E5126D8EDE050A758BCB5DCCA56A37125B3646CE75F1CF41EDE00890901AD9

[Documentation for DFA](https://github.com/SASPAC/blob/main/dfa.md "Documentation for DFA")

---

- **macroArray**\[1.3.2\], implementation of an array concept in a macro language, e.g. 
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
SHA256 digest for macroArray: F*35A657517CD2B1AB86C4E7C5320B5EDDDFBA9348075AE31DDAF875CF0CC193C9

[Documentation for macroArray](https://github.com/SASPAC/blob/main/macroarray.md "Documentation for macroArray")

---

- **BasePlus**\[3.1.4\] adds a bunch of functionalities I am missing in BASE SAS, such as: 
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

%put %date() %time() %datetime();

%put %date(yymmddn10.) %time(time5.) %datetime(e8601dt.);

%put %monthShift(2023,1,-5);

%put #%expandDataSetsList(lib=sashelp,datasets=_all_)#;

%workLib(ABC)
```
SHA256 digest for BasePlus: F*BD248E5F8CBD94B5F45467B723A73D97D646CD665BA98679F87C7A03A484E83E

[Documentation for BasePlus](https://github.com/SASPAC/blob/main/baseplus.md "Documentation for BasePlus")

---

- **GSM** (Generate Secure Macros)\[0.22.3\], package allows
 to create secured macros stored in SAS Proc FCMP functions.
 The dataset with functions can be shared between different operating systems
 and allows to generate macros on site without showing their code.

[Recording of presentation with "how it works" description (in Polish)](https://www.youtube.com/watch?v=LtaWPe2sgRY&t=1s "YouTube").

[The WUSS 2023 Conference article describing the idea](https://www.wuss.org/proceedings/2023/WUSS-2023-Paper-189.pdf "Article about the idea GSM")

SHA256 digest for GSM: F*411452E8388C181800023A01A3B7DC7904A80A915D506D9606638F27CBC282B1

[Documentation for GSM](https://github.com/SASPAC/blob/main/gsm.md "Documentation for GSM")

---

- **dynMacroArray**\[0.2.7\], set of macros (wrappers for a hash table) emulating dynamic array in the data step (macro predecessor of DFA). Development of this package is currently on hold.

SHA256 digest for dynMacroArray: F*C1644842102C87522E22513744B249027306A833AF7951E51D1760FF28656C16

---
