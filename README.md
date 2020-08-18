# SAS_PACKAGES - a SAS Packages Repository

## Intro:

A **SAS package** is an automatically generated, single, stand alone *zip* file containing organised and ordered code structures, created by the developer and extended with additional automatically generated "driving" files (i.e. description, metadata, load, unload, and help files). 

The *purpose of a package* is to be a simple, and easy to access, code sharing medium, which will allow: on the one hand, to separate the code complex dependencies created by the developer from the user experience with the final product and, on the other hand, reduce developer's and user's unnecessary frustration related to a remote deployment process.

In this repository we are presenting the **SAS Packages Framework** which allows to develop and use SAS packages. The latest version of SPF is `20200815`.  

To get started with SAS Packages try this [**`Getting Started with SAS Packages`**](https://github.com/yabwon/SAS_PACKAGES/blob/master/SPF/Documentation/Getting_Started_with_SAS_Packages.pdf "Getting Started with SAS Packages") presentation (see the `./SPF/Documentation` directory).

The documentation and more advance reading would be the [**`SAS(r) packages - the way to share (a how to)- Paper 4725-2020 - extended.pdf`**](https://github.com/yabwon/SAS_PACKAGES/blob/master/SPF/Documentation/SAS(r)%20packages%20-%20the%20way%20to%20share%20(a%20how%20to)-%20Paper%204725-2020%20-%20extended.pdf "SAS packages - the way to share") article (see the `./SPF/Documentation` directory).

**General overview video:**
  - [SAS Global Forum 2020 V.E.](https://www.youtube.com/watch?v=qCkb-bx0Dv8&t=0s "SGF2020")
  - [Sasensei Internationa Dojo](https://www.youtube.com/watch?v=BFhdUBQgjYQ&t=0s "SID no. 1")

### The User:
To use a package:
- Create a folder for your packages, under Windows OS family, e.g. `C:/SAS_PACKAGES` or under Linux/UNIX OS family, e.g. `/home/<username>/SAS_PACKAGES`.

and then either:

- Download the `SPFinit.sas` file (the SAS Packages Framework) into the local packages folder.
- \[Optional\] Manually download the `<packageName>.zip` file into the local packages folder.
- and Execute:
```
filename packages "<directory/containing/packages/>"; /* setup directory for packages */
%include packages(SPFinit.sas); /* enable the framework */

/* %installPackage(packageName) */ /* install the package, unless you downloaded it manually */

%helpPackage(packageName)    /* get help about the package */
%loadPackage(packageName)    /* load the package content into the SAS session */
```

or if you need it just for "one time" only Execute: 

```
filename packages "%sysfunc(pathname(work))"; /* setup temporary directory for packages in the WORK */
filename SPFinit url "https://raw.githubusercontent.com/yabwon/SAS_PACKAGES/master/SPF/SPFinit.sas";
%include SPFinit; /* enable the framework */

%installPackage(packageName) /* install the package */
%helpPackage(packageName)    /* get help about the package */
%loadPackage(packageName)    /* load the package content into the SAS session */
```

 [**Workshop video for the User**](https://youtu.be/qX_-HJ76g8Y)\[May 6th, 2020\] [a bit outdated but gives the idea how it works]
 
### The Developer:
To create your own package:
- Read the [**`SAS(r) packages - the way to share (a how to)- Paper 4725-2020 - extended.pdf`**](https://github.com/yabwon/SAS_PACKAGES/blob/master/SPF/Documentation/SAS(r)%20packages%20-%20the%20way%20to%20share%20(a%20how%20to)-%20Paper%204725-2020%20-%20extended.pdf "SAS packages - the way to share") to learn more details.
- Download and use the `SPFinit.sas` file (the SAS Packages Framework), the part of the framework required for *testing* is there too.

#### If you have any questions, suggestions, or ideas do not hesitate to contact me!

 **Update**\[June 3rd, 2020\]**:** `%installPackage()` **macro is available**. The `%installPackage()` macro is embedded in the `loadpackage.sas` part of the framework.
 
  **Update**\[June 10th, 2020\]**:** To see help info about framework macros and their parameters just run: `%generatePackage()`, `%installPackage()`, `%helpPackage()`, `%loadPackage()`, and `%unloadPackage()` with empty parameter list.
  
  **Update**\[July 30th, 2020\]**:** All components of SAS Packages Framework are now in one file `SPFinit.sas` (located in the `./SPF` directory). Documentation moved to `./SPF/Documentation` directory. Packages zip files moved to `./packages` directory.

## Available packages:
Currently the following packages are available (see the `./packages` directory):

- **SQLinDS**\[2.1\], based on Mike Rhoads' article *Use the Full Power of SAS in Your Function-Style Macros*. The package allows to write SQL queries in the data step, e.g.
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

- **BasePlus**\[0.61\] adds a bunch of functionalities I am missing in BASE SAS, such as:
```
call arrMissToRight(myArray); 
call arrFillMiss(17, myArray); 
call arrFill(42, myArray); 

rc = delDataset("DataSetToDrop"); 

string = catXFn("date9.", "#", myArray);

format x bool.;

%put %getVars(sashelp.class, pattern = ght$, sep = +, varRange = _numeric_);
```

- **dynMacroArray**\[0.2\], set of macros (wrappers for a hash table) emulating dynamic array in the data step (macro predecessor of DFA)

### ======
