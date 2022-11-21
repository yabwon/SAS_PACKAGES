# SAS_PACKAGES - a SAS Packages Framework

---

## Intro:

A **SAS package** is an automatically generated, single, stand alone *zip* file containing organised and ordered code structures, created by the developer and extended with additional automatically generated "driving" files (i.e. description, metadata, load, unload, and help files). 

The *purpose of a package* is to be a simple, and easy to access, code sharing medium, which will allow: on the one hand, to separate the code complex dependencies created by the developer from the user experience with the final product and, on the other hand, reduce developer's and user's unnecessary frustration related to a remote deployment process.

In this repository we are presenting the **SAS Packages Framework** which allows to develop and use SAS packages. 

---

### Current version:

**The latest version** of SPF is **`20221121`**.  

To get started with SAS Packages try this [**`Getting Started with SAS Packages`**](https://github.com/yabwon/SAS_PACKAGES/blob/main/SPF/Documentation/Getting_Started_with_SAS_Packages.pdf "Getting Started with SAS Packages") presentation (see the `./SPF/Documentation` directory).

The documentation and more advance reading would be the [**`SAS(r) packages - the way to share (a how to)- Paper 4725-2020 - extended.pdf`**](https://github.com/yabwon/SAS_PACKAGES/blob/main/SPF/Documentation/SAS(r)%20packages%20-%20the%20way%20to%20share%20(a%20how%20to)-%20Paper%204725-2020%20-%20extended.pdf "SAS packages - the way to share") article (see the `./SPF/Documentation` directory).

Short description of the SAS Packages Framework macros can be found [here](https://github.com/yabwon/SAS_PACKAGES/blob/main/SPF/SPFinit.md "Short description of the SAS Packages Framework macros")

### Recordings and Presentations:

Videos presenting the SPF and packages, from various conferences and meetups (the newer the better):

  - ["SAS Packages: The Way to Share" - SAS Global Forum 2020 V.E.](https://www.youtube.com/watch?v=qCkb-bx0Dv8&t=0s "SGF2020") (April 2020, ~20 minutes, general overview but with a bit obsolete technical details)
  - ["SAS Packages: The Way to Share" - SaSensei International Dojo No. 1](https://www.youtube.com/watch?v=BFhdUBQgjYQ&t=0s "SID no. 1") (April 2020, ~28 minutes, general overview but with a bit obsolete technical details)
  - ["Co nowego z pakietami SAS?" - SAS dla Administratorów i Praktyków 2020](https://www.youtube.com/watch?v=mXuep2k48Z8&feature=youtu.be&t=0s "SASAiP2020") (October 2020, in Polish, ~41 minutes, general overview and technical details how to use SPF)
  - ["SAS Packages - The Way to Share" - Boston Area SAS Users Group webinar](https://www.basug.org/videos?wix-vod-video-id=78067e61413d43d3a6951974b3bc3014&wix-vod-comp-id=comp-klv807gt "BASUG") (November 2020, ~59 minutes, general overview and technical details how to use SPF)
  - ["My First SAS Package: A How-To" - SAS Global Forum 2021 V.E.](https://www.youtube.com/watch?v=hqexaQtGw88 "SGF2021") (May 20th 2021, ~59 minutes, technical workshop on how to create a package)
  -  ["Kod SASowy ukryty na widoku" - SAS dla Administratorów i Praktyków 2021](https://www.youtube.com/watch?v=LtaWPe2sgRY&t=1s) (November 24th 2021, in Polish, ~34 minutes, technical presentation with details about the GSM package)
  - ["A BasePlus Package for SAS" - SAS Explore 2022](https://communities.sas.com/t5/SAS-Explore-Presentations/A-BasePlus-Package-for-SAS/ta-p/838246 "SASexplore2022 communities.sas.com") (September 27th-29th 2022, ~28 minutes, technical presentation with details about the BasePlus package), alternative video at YouTube is [here](https://www.youtube.com/watch?v=-Poxkx5WfOQ "SASexplore2022 TouTube")
  - ["SAS Packages - State of the Union" - SaSensei International Dojo No. 13](https://www.youtube.com/watch?v=1GEldZYQjj0&t=0s "SID no. 13") (November 10th 2022, ~50 minutes, general overview with the latest technical details)

---

### Initiative to add SAS Packages Framework to SAS Base/Viya:

A **SASware Ballot Idea** for adding *SAS Packages Framework* macros into Base SAS and Viya was submitted Friday, May 27th 2022. If you would like to support the idea visit this [communities.sas.com post](https://communities.sas.com/t5/SASware-Ballot-Ideas/Add-SAS-Packages-Framework-to-the-SAS-Base-Viya/idi-p/815508) and up vote the idea!

---

### The User:

The first step to use a package with the SAS Packages Framework:

- Create a folder for your packages, under Windows OS family e.g., `C:/SAS_PACKAGES` or under Linux/UNIX OS family e.g., `/home/<username>/SAS_PACKAGES`.

and then either:

- Manually download the `SPFinit.sas` file (the SAS Packages Framework) into the local packages folder.
- \[Optional\] Manually download the `<packageName>.zip` file into the local packages folder.
- and Execute:

```sas
filename packages "<directory/containing/packages/>";         /* setup directory for packages */
%include packages(SPFinit.sas);                               /* enable the framework */

/* %installPackage(packageName) */                            /* install the package, unless you downloaded it manually */

%helpPackage(packageName)                                     /* get help about the package */
%loadPackage(packageName)                                     /* load the package content into the SAS session */
```

or if you need it just for "one time" only:

- Execute: 

```sas
filename packages "%sysfunc(pathname(work))"; /* setup WORK as temporary directory for packages */
filename SPFinit url "https://raw.githubusercontent.com/yabwon/SAS_PACKAGES/main/SPF/SPFinit.sas";
%include SPFinit; /* enable the framework */

%installPackage(packageName) /* install a package */
%helpPackage(packageName)    /* get help about the package */
%loadPackage(packageName)    /* load the package content into the SAS session */
```

or do it pragmatically:

- Enable the framework [first time only]:

```sas
filename SPFinit url "https://raw.githubusercontent.com/yabwon/SAS_PACKAGES/main/SPF/SPFinit.sas";
%include SPFinit; /* enable the framework */
```

- Install the framework on your machine in the folder you created:

```sas
filename packages "<directory/containing/packages/>"; 
%installPackage(SPFinit) /* install the framework */
```

- And from now on run it like this:

```sas
filename packages "<directory/containing/packages/>";
%include packages(SPFinit.sas);

%installPackage(packageName) /* install a package */
%helpPackage(packageName)    /* get help about the package */
%loadPackage(packageName)    /* load the package content into the SAS session */
```

---

 [**Workshop video for the User**](https://youtu.be/qX_-HJ76g8Y) \[May 6th, 2020\] [~86 minutes, a bit outdated (installPackage macro was not there yet) but gives the idea how it works especially load, help, unload, ICEload, and other details]

---

### The Developer:

To create your own package:

- Download (and use) the `SPFinit.sas` file (the SAS Packages Framework), the part of the framework required for *testing* is there too.

- See this ["Hello World" example tutorial.](https://github.com/yabwon/SAS_PACKAGES/blob/main/SPF/Documentation/HelloWorldPackage.md "Hello World")

- Read the [**`SAS Packages - The Way to Share (a How-To) - Paper 4725-2020 - extended version`**](https://github.com/yabwon/SAS_PACKAGES/blob/main/SPF/Documentation/SAS(r)%20packages%20-%20the%20way%20to%20share%20(a%20how%20to)-%20Paper%204725-2020%20-%20extended.pdf "SAS packages - the way to share") article to learn more details.

- Read the **`My First SAS Package: A How-To - Paper 1079-2021`** article available at communities.sas.com [**`here`**](https://communities.sas.com/t5/SAS-Global-Forum-Proceedings/My-First-SAS-Package-A-How-To/ta-p/726319 "My First SAS Package: A How-To") or locally [**`here`**](https://github.com/yabwon/SAS_PACKAGES/blob/main/SPF/Documentation/Paper_1079-2021/My%20First%20SAS%20Package%20-%20a%20How%20To.pdf "My First SAS Package: A How-To")

The SAS Packages Framework [(short) documetation](https://github.com/yabwon/SAS_PACKAGES/blob/main/SPF/SPFinit.md) to quickly see macros options and parametera.

---

### If you have any questions, suggestions, or ideas do not hesitate to contact me!

---

### Updates worth mentioning:

**Update**\[November 21st, 2022\]**:** ` %loadPackage()` **macro allows Cherry Picking of content (see [here]())**.

**Update**\[September 30th, 2022\]**:** **New dedicated repository:** *SASPAC - the SAS Packages Archive* **is available as new location for packages storage**. Location of SASPAC is: [`https://github.com/SASPAC`](https://github.com/SASPAC) 

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

If you find the SPF useful **share info** about it or **give it a [star](https://github.com/yabwon/SAS_PACKAGES/stargazers)** so more people will know.

---

## Available packages:

**(!)** For "backward compatibility"/historical point of view the following packages are available under the `./packages` directory.

**(!)** Since *September 2022* the default location for packages is **SASPAC - the SAS Packages Archive** located under: [`https://github.com/SASPAC`](https://github.com/SASPAC) where each package is stored as a separate repository with historical versions too.

Packages:

- **SQLinDS**\[2.2.2\], based on Mike Rhoads' article *Use the Full Power of SAS in Your Function-Style Macros*. The package allows to write SQL queries in the data step, e.g.
```sas
  data class;
    set %SQL(select * from sashelp.class order by age);
  run;
```
SHA256 digest for SQLinDS: 085F0B8BD4A59343E2913FF9635EA6E551ADD54E9678C35F5096D4A0A895B9C5

[Documentation for SQLinDS](https://github.com/yabwon/SAS_PACKAGES/blob/main/packages/sqlinds.md "Documentation for SQLinDS")

- **MacroCore**\[1\], a macro library for SAS application developers. Over 100 macros for Base SAS, metadata, and Viya. Provided by the [SASjs framework](https://sasjs.io "SASjs framework").

SHA256 digest for MacroCore: A23C29529F3CE7D0C8BEE9545C5D22D5B5594907547374A5135B8E5A48D7687B

[Documentation for MacroCore](https://core.sasjs.io "Documentation for MacroCore")

- **DFA** (Dynamic Function Arrays)\[0.5.2\], contains set of macros and FCMP functions which implement: a dynamically allocated array, a stack, a fifo queue, an ordered stack, and a priority queue, run `%helpPackage(DFA,createDFArray)` to find examples.

SHA256 digest for DFA: 3F618EDAC8B4F4BE6C19D606E6BCC58121A16BA1383D2EE64C680B4B7FA9C96A

[Documentation for DFA](https://github.com/yabwon/SAS_PACKAGES/blob/main/packages/dfa.md "Documentation for DFA")

- **macroArray**\[1.0.2\], implementation of an array concept in a macrolanguage, e.g. 
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
SHA256 digest for macroArray: DA57FFE85F49201FD61A53411D19E97FB5A6AC3C34E34FDF4B913545699551FF

[Documentation for macroArray](https://github.com/yabwon/SAS_PACKAGES/blob/main/packages/macroarray.md "Documentation for macroArray")


- **BasePlus**\[1.17.2\] adds a bunch of functionalities I am missing in BASE SAS, such as:
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
SHA256 digest for BasePlus: EBA9EDB3D50D854288970CC0E965DA6AD5B057F6E6433EEBEC4A02B9A25CF6E2

[Documentation for BasePlus](https://github.com/yabwon/SAS_PACKAGES/blob/main/packages/baseplus.md "Documentation for BasePlus")

- **GSM** (Generate Secure Macros)\[0.20.2\], package allows
 to create secured macros stored in SAS Proc FCMP functions.
 The dataset with functions can be shared between different operating systems
 and allows to generate macros on site without showing their code.

SHA256 digest for GSM: E47C94B536B661DEE390F5C3EA1684DD1A246106F4FBBDAFA57F5E34D4BB16D5

[Documentation for GSM](https://github.com/yabwon/SAS_PACKAGES/blob/main/packages/gsm.md "Documentation for GSM")

- **dynMacroArray**\[0.2.2\], set of macros (wrappers for a hash table) emulating dynamic array in the data step (macro predecessor of DFA). Development of this package is currently on hold.

SHA256 digest for dynMacroArray: DD0BF1768DA05EBB5F8C6E7409A0929E28DF11CB499F75B433D9648855AACAE4

### ======
