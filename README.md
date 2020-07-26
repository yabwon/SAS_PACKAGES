# SAS_PACKAGES - a SAS Packages Repository

## Intro:

A **SAS package** is an automatically generated, single, stand alone *zip* file containing organised and ordered code structures, created by the developer and extended with additional automatically generated "driving" files (i.e. description, metadata, load, unload, and help files). 

The *purpose of a package* is to be a simple, and easy to access, code sharing medium, which will allow: on the one hand, to separate the code complex dependencies created by the developer from the user experience with the final product and, on the other hand, reduce developer's and user's unnecessary frustration related to a remote deployment process.

In this repository we are presenting a **standalone Base SAS framework** which allows to develop and use SAS packages. Read the **`SAS(r) packages - the way to share (a how to)- Paper 4725-2020 - extended.pdf`** to learn more. Latest version is `20200725`.

**General overview video:**
  - SAS Global Forum 2020 V.E.: `https://www.youtube.com/watch?v=qCkb-bx0Dv8&t=0s`
  - Sasensei Internationa Dojo: `https://www.youtube.com/watch?v=BFhdUBQgjYQ&t=0s`

### The User:
To use a package:
- Create a folder for your packages, under Windows OS family, e.g. `C:/SAS_PACKAGES` or under Linux/UNIX OS family, e.g. `/home/<username>/SAS_PACKAGES`.

and then either:

- Download the `loadpackage.sas` file (user part of the framework) into the packages folder.
- \[Optional\] Download the `<packageName>.zip` file into the packages folder.
- and Execute:
```
filename packages "<directory/containing/packages/>"; /* setup directory for packages */
%include packages(loadpackage.sas); /* enable the framework */

%installPackage(packageName) /* install the package, unless you downloaded it manually */
%helpPackage(packageName)    /* get help about the package */
%loadPackage(packageName)    /* load the package content into the SAS session */
```

or if you need it just for "one time" only Execute: 

```
filename packages "<directory/containing/packages/>"; /* setup directory for packages */
filename spfinit url "https://raw.githubusercontent.com/yabwon/SAS_PACKAGES/master/loadpackage.sas";
%include spfinit; /* enable the framework */

%installPackage(packageName) /* install the package */
%helpPackage(packageName)    /* get help about the package */
%loadPackage(packageName)    /* load the package content into the SAS session */
```

 **Workshop video for User**\[May 6th, 2020\]**: `https://youtu.be/qX_-HJ76g8Y`**
 
### The Developer:
To create your own package:
- Read the **`SAS(r) packages - the way to share (a how to)- Paper 4725-2020 - extended.pdf`** to learn more.
- Download and use the `generatePackage.sas` file (developer part of the framework) and the `loadpackage.sas` file (user part of the framework but required for *testing*).

#### If you have any questions, suggestions, or ideas do not hesitate to contact me!

 **Update**\[June 3rd, 2020\]**:** `%installPackage()` **macro is available**. The `%installPackage()` macro is embedded in the `loadpackage.sas` part of the framework.
 
  **Update**\[June 10th, 2020\]**:** To see help info about framework macros and their parameters just run: `%generatePackage()`, `%installPackage()`, `%helpPackage()`, `%loadPackage()`, and `%unloadPackage()` with empty parameter list.

## Available packages:
Currently the following packages are available:

- **SQLinDS**\[2.1\], based on Mike Rhoads' article *Use the Full Power of SAS in Your Function-Style Macros*. The package allows to write SQL queries in the datastep, e.g.
```
data class;
  set %SQL(select * from sashelp.class order by age);
run;
```

- **DFA** (Dynamic Function Arrays)\[0.2\], contains set of macros and FCMP functions which implement: a dynamically allocated array, a stack, a fifo queue, an ordered stack, and a priority queue, run `%helpPackage(DFA,createDFArray)` to find examples.
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

- **FunctionsImissinBASE**\[0.4\] A bunch of functions and functionalities I am missing in BASE SAS, such as:
```
call arrShiftLeft(myArray); 
call arrRepNull(17, myArray); 
call arrFill(42, myArray); 

rc = delDataset("DataSetToDrop"); 

string = catXFn("date9.", "#", myArray);

format x bool.;

%put %getVars(sashelp.class, patern = ght$, sep = +, varRange = _numeric_);
```

- **dynMacroArray**\[0.2\], set of macros (wrappers for a hash table) emulating dynamic array in the datastep (macro predecessor of DFA)

### ======
