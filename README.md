# SAS_PACKAGES - a SAS Packages Framework and Repository

---

## Intro:

A **SAS package** is an automatically generated, single, stand alone *zip* file containing organised and ordered code structures, created by the developer and extended with additional automatically generated "driving" files (i.e. description, metadata, load, unload, and help files). 

The *purpose of a package* is to be a simple, and easy to access, code sharing medium, which will allow: on the one hand, to separate the code complex dependencies created by the developer from the user experience with the final product and, on the other hand, reduce developer's and user's unnecessary frustration related to a remote deployment process.

In this repository we are presenting the **SAS Packages Framework** which allows to develop and use SAS packages. **The latest version** of SPF is **`20220113`**.  

To get started with SAS Packages try this [**`Getting Started with SAS Packages`**](https://github.com/yabwon/SAS_PACKAGES/blob/main/SPF/Documentation/Getting_Started_with_SAS_Packages.pdf "Getting Started with SAS Packages") presentation (see the `./SPF/Documentation` directory).

The documentation and more advance reading would be the [**`SAS(r) packages - the way to share (a how to)- Paper 4725-2020 - extended.pdf`**](https://github.com/yabwon/SAS_PACKAGES/blob/main/SPF/Documentation/SAS(r)%20packages%20-%20the%20way%20to%20share%20(a%20how%20to)-%20Paper%204725-2020%20-%20extended.pdf "SAS packages - the way to share") article (see the `./SPF/Documentation` directory).

Short description of the SAS Packages Framework macros can be found [here](https://github.com/yabwon/SAS_PACKAGES/blob/main/SPF/SPFinit.md "Short description of the SAS Packages Framework macros")

**Videos** (the newer the better):

  - [SAS Global Forum 2020 V.E.](https://www.youtube.com/watch?v=qCkb-bx0Dv8&t=0s "SGF2020") (April 2020)
  - [Sasensei International Dojo](https://www.youtube.com/watch?v=BFhdUBQgjYQ&t=0s "SID no. 1") (April 2020)
  - [SAS dla Administratorów i Praktyków 2020](https://www.youtube.com/watch?v=mXuep2k48Z8&feature=youtu.be&t=0s "SASAiP2020") (October 2020, in Polish)
  - [Boston Area SAS Users Group webinar](https://www.basug.org/videos?wix-vod-video-id=78067e61413d43d3a6951974b3bc3014&wix-vod-comp-id=comp-klv807gt "BASUG") (November 2020)
  - [SAS Global Forum 2021 V.E.](https://www.youtube.com/watch?v=hqexaQtGw88 "SGF2021") (May 20th, 2021)
---

### The User:
To use a package:
- Create a folder for your packages, under Windows OS family, e.g. `C:/SAS_PACKAGES` or under Linux/UNIX OS family, e.g. `/home/<username>/SAS_PACKAGES`.

and then either:

- Download the `SPFinit.sas` file (the SAS Packages Framework) into the local packages folder.
- \[Optional\] Manually download the `<packageName>.zip` file into the local packages folder.
- and Execute:

```sas
filename packages "<directory/containing/packages/>"; /* setup directory for packages */
%include packages(SPFinit.sas); /* enable the framework */

/* %installPackage(packageName) */ /* install the package, unless you downloaded it manually */

%helpPackage(packageName)    /* get help about the package */
%loadPackage(packageName)    /* load the package content into the SAS session */
```

or if you need it just for "one time" only Execute: 

```sas
filename packages "%sysfunc(pathname(work))"; /* setup temporary directory for packages in the WORK */
filename SPFinit url "https://raw.githubusercontent.com/yabwon/SAS_PACKAGES/main/SPF/SPFinit.sas";
%include SPFinit; /* enable the framework */

%installPackage(packageName) /* install the package */
%helpPackage(packageName)    /* get help about the package */
%loadPackage(packageName)    /* load the package content into the SAS session */
```

 [**Workshop video for the User**](https://youtu.be/qX_-HJ76g8Y) \[May 6th, 2020\] [a bit outdated but gives the idea how it works]

---

### The Developer:
To create your own package:
- Read the [**`SAS Packages - The Way to Share (a How-To) - Paper 4725-2020 - extended version`**](https://github.com/yabwon/SAS_PACKAGES/blob/main/SPF/Documentation/SAS(r)%20packages%20-%20the%20way%20to%20share%20(a%20how%20to)-%20Paper%204725-2020%20-%20extended.pdf "SAS packages - the way to share") article to learn more details.
- Read the **`My First SAS Package: A How-To - Paper 1079-2021`** article available at communities.sas.com [**`here`**](https://communities.sas.com/t5/SAS-Global-Forum-Proceedings/My-First-SAS-Package-A-How-To/ta-p/726319 "My First SAS Package: A How-To") or locally [**`here`**](https://github.com/yabwon/SAS_PACKAGES/blob/main/SPF/Documentation/Paper_1079-2021/My%20First%20SAS%20Package%20-%20a%20How%20To.pdf "My First SAS Package: A How-To")
- Download and use the `SPFinit.sas` file (the SAS Packages Framework), the part of the framework required for *testing* is there too.

---

#### If you have any questions, suggestions, or ideas do not hesitate to contact me!

---

**Update**\[November 11th, 2021\]**:** `%extendPackagesFileref()` **macro is available**.

**Update**\[October 15th, 2020\]**:** `%previewPackage()` **macro is available**.

**Update**\[September 11th, 2020\]**:** ` %loadPackageS()` and `%verifyPackage()` **macros are available**.

**Update**\[July 30th, 2020\]**:** All components of SAS Packages Framework are now in one file `SPFinit.sas` (located in the `./SPF` directory). Documentation moved to `./SPF/Documentation` directory. Packages zip files moved to `./packages` directory.

**Update**\[June 10th, 2020\]**:** To see help info about framework macros and their parameters just run: `%generatePackage()`, `%installPackage()`, `%helpPackage()`, `%loadPackage()`, and `%unloadPackage()` with empty parameter list.

**Update**\[June 3rd, 2020\]**:** `%installPackage()` **macro is available**. The `%installPackage()` macro is embedded in the `loadpackage.sas` part of the framework.

---

## Where the SAS Packages Framework is used:
This is a list of locations where the SAS Packages Framework is used:
 - Warsaw (Poland)

If you want to share that you are using the SPF let me know and I'll update the list.

If you find the SPF usefull **share info** about it or **give it a [star](https://github.com/yabwon/SAS_PACKAGES/stargazers)** so more people will know.

---

## Available packages:
Currently the following packages are available (see the `./packages` directory):

- **SQLinDS**\[2.2\], based on Mike Rhoads' article *Use the Full Power of SAS in Your Function-Style Macros*. The package allows to write SQL queries in the data step, e.g.
```sas
  data class;
    set %SQL(select * from sashelp.class order by age);
  run;
```
SHA256 digest for SQLinDS: DCAB62267B52822F416BA7E6713A696D843E8092A4E3A37DF06CBE1E1D5DAD11

[Documentation for SQLinDS](https://github.com/yabwon/SAS_PACKAGES/blob/main/packages/sqlinds.md "Documentation for SQLinDS")

- **MacroCore**\[1\], a macro library for SAS application developers. Over 100 macros for Base SAS, metadata, and Viya. Provided by the [SASjs framework](https://sasjs.io "SASjs framework").

SHA256 digest for MacroCore: A23C29529F3CE7D0C8BEE9545C5D22D5B5594907547374A5135B8E5A48D7687B

[Documentation for MacroCore](https://core.sasjs.io "Documentation for MacroCore")

- **DFA** (Dynamic Function Arrays)\[0.5\], contains set of macros and FCMP functions which implement: a dynamically allocated array, a stack, a fifo queue, an ordered stack, and a priority queue, run `%helpPackage(DFA,createDFArray)` to find examples.

SHA256 digest for DFA: 5F89AC6AE628EB27D87FF6A9D72A515FFA3FF6694D04DE0D9811BFFB81444ABB

[Documentation for DFA](https://github.com/yabwon/SAS_PACKAGES/blob/main/packages/dfa.md "Documentation for DFA")

- **macroArray**\[1.0\], implementation of an array concept in a macrolanguage, e.g. 
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
SHA256 digest for macroArray: DAEB87654D99965BF2B7A6AB14626B3E617D0ABF526E77725DF89A1AB4C812C2

[Documentation for macroArray](https://github.com/yabwon/SAS_PACKAGES/blob/main/packages/macroarray.md "Documentation for macroArray")


- **BasePlus**\[1.14\] adds a bunch of functionalities I am missing in BASE SAS, such as:
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
```
SHA256 digest for BasePlus: A60A300E083628C65DD6899E7EF95588916F8F66B6A25B32B3228987B6F74857

[Documentation for BasePlus](https://github.com/yabwon/SAS_PACKAGES/blob/main/packages/baseplus.md "Documentation for BasePlus")

- **GSM** (Generate Secure Macros)\[0.19\], package allows
 to create secured macros stored in SAS Proc FCMP functions.
 The dataset with functions can be shared between different operating systems
 and allows to generate macros on site without showing their code.

SHA256 digest for GSM: F63B8C602C1DB02F4107D9AF78182D87CD64AEA6521163067B7EB6D5C1B368AF

[Documentation for GSM](https://github.com/yabwon/SAS_PACKAGES/blob/main/packages/gsm.md "Documentation for GSM")

- **dynMacroArray**\[0.2\], set of macros (wrappers for a hash table) emulating dynamic array in the data step (macro predecessor of DFA)

SHA256 digest for dynMacroArray: 766DF3F330B87E99FAC32A00A569D9A45DA1157F591DE34DD0892CD864779409

### ======
