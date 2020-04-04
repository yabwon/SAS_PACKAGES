# SAS_PACKAGES - a SAS Packages Repository

## Intro:

A **SAS package** is an automatically generated, single, stand alone *zip* file containing organised and ordered code structures, created by the developer and extended with additional automatically generated "driving" files (i.e. description, metadata, load, unload, and help files). 

The *purpose of a package* is to be a simple, and easy to access, code sharing medium, which will allow: on the one hand, to separate the code complex dependencies created by the developer from the user experience with the final product and, on the other hand, reduce developer's and user's unnecessary frustration related to a remote deployment process.

In this repository we are presenting a *standalone Base SAS framework* which allows to develop and use SAS packages.

General overwiev video:
  - `https://www.youtube.com/watch?v=BFhdUBQgjYQ&t=0s`

### The User:
To use a package:
- Create a folder for your packages, under Windows OS family, e.g. `C:/SAS_PACKAGES` or under Linux/UNIX OS family, e.g. `/home/<username>/SAS_PACKAGES`.
- Download the `loadpackage.sas` file (user part of the framework) into the packages folder.
- Download the `<packageName>.zip` file into the packages folder.
- Execute:
```
filename packages "<directory/containing/packages/>";
%include packages(loadpackage.sas);
%helpPackage(packageName) /* to get help about package */
%loadPackage(packageName) /* to load package content */
```
### The Developer:
To create your own package:
- Read the `SAS(r) packages - the way to share (a how to)- Paper 4725-2020.pdf` to learn more.
- Download and use the `generatePackage.sas` file (developer part of the framework) and the `loadpackage.sas` file (required for testing).

#### If you have any questions, suggestions, or ideas do not hesitate to contact me!

## Available packages:
Currently the following packages are available:

- **SQLinDS**, based on Mike Rhoads' article *Use the Full Power of SAS in Your Function-Style Macros*. The package allows to write SQL queries in the datastep, e.g.
```
data class;
  set %SQL(select * from sashelp.class order by age);
run;
```
- **DFA** (Dynamic Function Arrays), contains set of macros and FCMP functions which implement: a dynamically allocated array, a stack, a fifo queue, an ordered stack, and a priority queue, run `%helpPackage(DFA,createDFArray)` to find examples.
- **macroArray**, implementation of an array concept in a macrolanguage, e.g. 
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
- **dynMacroArray**, set of macros (wrappers for a hash table) emulating dynamic array in the datastep (macro predecessor of DFA)

### ======
