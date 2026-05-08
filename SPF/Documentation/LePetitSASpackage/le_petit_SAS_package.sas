/*
# **Le petit SAS package** 
## a workshop about the "*Hello World*" SAS package.

by [**Bartosz Jabłoński**](https://linkedin.com/in/yabwon)

[LinkedIn](https://linkedin.com/in/yabwon)
[GitHub](https://github.com/yabwon)

---

<!-- ![Cover](./le_petit_SAS_package.png) -->
<img src="./le_petit_SAS_package.png" alt="Le petit SAS package" style="height:800px;"/>



---
*/

/*
---

## Links and locations

[**SAS Packages Framework**](https://github.com/yabwon/SAS_PACKAGES) - this is the place where the SAS Packages Framework lives.


[**Hands on Workshop Materials**](https://github.com/yabwon/HoW-SASPackages) - this is the location for tutorial materials that will teach you how to work with SAS packages and that will take you "from 0 to hero" in SAS packages world.

[SPF's introductory video series](https://www.youtube.com/playlist?list=PLeMzGEImIT5eV13IGXQIgWmTFCJt_cLZG) - this is a YouTube introductory video series explaining the basics.


[**SAS Packages Archive**](https://github.com/SASPAC) - some of publicly available SAS packages are located here.

[PharmaForest](https://github.com/PharmaForest) - pharma industry dedicated SAS packages are there.

---
*/

options nofullstimer stimer nomprint nosymbolgen nomlogic; 
data _null_;
  put "WARNING- Welcome at NJSUG meetup!";
run;

/*
## autoexec.sas

I'm keeping my session setup in the `autoexec.sas` file.
*/

/* this is an optional step - I basically have my session configuration in autoexec */
/*
%include "C:\SAS_WORK\autoexec.sas";

%put %workpath();

%put &sysLoadedPackages.;
*/

/*
But it can be replaced, for example, by something like this:
*/

/* set "current working path" to WORK location */
%put %sysfunc(DLGCDIR(%sysfunc(PATHNAME(work))));
filename _ ".";
filename _ list;
filename _ clear;


/* enable the SAS Packages Framework */
filename packages "C:\SAS_WORK\SAS_PACKAGES"; /* filename packages "/sas/PACKAGES"; */
%include packages(SPFinit.sas);

/* Load SAS packages */
%loadPackageS(SQLinDS BasePlus)
/* %loadPackageS(macroArray, DFA, GSM, bpUTiL, maxims4sas, evExpress) */


resetline;
/* List loaded packages */
%put NOTE- SAS session with SAS Packages: &SYSLoadedPackages.;

%put NOTE- %workpath(); /* basePlus macro */

/*
---

# Code types

SAS Packages can contain various code types, including: 
- macros, 
- FCMP functions, 
- formats & informats, 
- IML modules, 
- DS2 packages & threads, 
- CAS-L functions, 
- data sets, 
- libraries, etc.

Full list is provided in the [Training Materials](https://github.com/yabwon/HoW-SASPackages).

Today we will go with 3 basic: a macros, a function, and a format.
*/

/*
## A Macro

This macro prints the fox's quotes to the log.
*/

resetline;

%macro fox(quote);
  %local n e w;
  %let n = NOTE;
  %let e = ERROR;
  %let w = WARNING;
  %if 1=%superq(quote) %then 
    %do;
      %put &n.- And now here is my secret, a very simple secret:; 
      %put &n.- It is only with the heart that one can see rightly%str(;);
      %put &n.- what is essential is invisible to the eye.;
    %end;
  %else
  %if 2=%superq(quote) %then 
    %do;
      %put &w.- It is the time you have wasted for your rose;
      %put &w.- that makes your rose so important.;
      %put &w.- Men have forgotten this truth. But you must not forget it.; 
      %put &w.- You become responsible, forever, for what you have tamed.;
      %put &w.- You are responsible for your rose...;
    %end;
  %else
    %do;
      %put &e.- One only understands the things that one tames.; 
      %put &e.- Men have no more time to understand anything.;
      %put &e.- They buy things all ready made at the shops.; 
      %put &e.- But there is no shop anywhere where one can buy friendship,; 
      %put &e.- and so men have no friends any more. If you want a friend, tame me...;
    %end;
%mend fox;

%fox(1)
%fox(2)
%fox()

/*
## A Format

This format displays values from 1 to 4 as rose's quotes.
*/

resetline;

PROC FORMAT;
  value rose
  1="Ah! I am scarcely awake. I beg that you will excuse me. My petals are still all disarranged..."
  2="Of course I love you. It is my fault that you have not known it all the while. [...] Try to be happy..."
  3="My cold is not so bad as all that... The cool night air will do me good. I am a flower."
  4="Well, I must endure the presence of two or three caterpillars if I wish to become acquainted with the butterflies."
  other="ERROR: QUOTE OUT OF RANGE!"
  ;
RUN;


data _null_;
  do i = 1 to 5;
    put "NOTE- " i rose. /;
  end;
run;

/*
## A Function

This FCMP function returns the prince's quote: "*If you please--draw me a sheep!*", and generates random rose's quote in the LOG.
*/

resetline;

PROC FCMP outlib=work.little.prince;
  function prince() $ 42;
    file log;

    length i $ 256;
    r=rand('integer',1,4);
    i = put(r, rose.);
    put @1 "RANDOM NOTE:" i /;

    return("If you please--draw me a sheep!");
  endfunc;
QUIT;

proc options option=cmplib;
run;

/*
For an FCMP function to work the `CMPLIB` option has to be updated.
*/

options append=(cmplib=work.little);

proc options option=cmplib;
run;

data _null_;
  do i = 1 to 5;
    prince=prince();
    rc=sleep(1,0.2);
  end;
  put prince=;
run;

/*
---

# **##############################**

# *If you please - build me a SAS package!*

# **##############################**

---
*/

/*
## The Directory

In the firs step, a directory for the package source has to be created.
*/

options dlcreatedir;
%let dir = R:\NJSUG\LePetitSASpackageDirectory;

libname p "&dir.";

libname p list;

/*
## The Description

This is the **description** file for the package.

It should be named `description.sas` and located in the package source directory. 

The colon (`:`) is a field separator and is restricted in lines of the header part.

The part between `DESCRIPTION START:` and `DESCRIPTION END:` is a "free format" text part where the developer provides package description, additional notes, information, etc.
*/

/* **HEADER** */
Type: Package
Package: LePetitSASpackage
Title: Le petit SAS package - a workshop about the "*Hello World*" SAS package.
Version: 0.0.1
Author: Bartosz Jablonski
Maintainer: Bartosz Jablonski (yabwon@gmail.com)
License: MIT
Encoding: UTF8

Required: "Base SAS Software"
ReqPackages: "SQLinDS(2.3.3)"


/* **DESCRIPTION** */
/* All the text below will be used for help notes */
DESCRIPTION START:

The **LePetitSASpackage** package is an implementation 
of a little "*Hello World*" SAS package presented during 
**NJSUG** meetup.

It is build for fun, but also (or foremost) to show us 
how easy it is to build SAS packages.

*"I have serious reason to believe that the planet from which 
the little package came is the asteroid known as B612.
This asteroid has only once been seen through the telescope. 
That was by a Turkish astronomer, in 1909."*

---

DESCRIPTION END:

/*
[**NOTE**] The `SQLinDS` package is added as a dependency just to show the it can be done. In normal circumstances, when a package doesn't have dependencies the `ReqPackage:` tag is skipped. The `Required:` tag is also just for demonstration.
*/

/*
## The Directory, cont.
*/

/*
### Ordering

Code files have to be placed in proper type-directories. And ordered accordingly. In this case teh following setup will work.
*/

/* 01_macro -> fox.sas */

/* 02_formats -> rose.sas */

/* 03_functions -> prince.sas */

/*
Directories structure can be easily created by ourselves with the `dlcreatedir` option. If the option is not available, then it can be done by hand.
*/

resetline;
options dlcreatedir;

libname p "&dir.\01_macro";
libname p "&dir.\02_formats";
libname p "&dir.\03_functions";

libname p clear;

/*
## Code Preparation
*/

/*
### Help Notes
*/

/*** HELP START ***//*

This is a little help note.

*//*** HELP END ***/

/*** HELP START ***//*

The `%fox()` macro prints what does the fox says...

---

### Syntax: ############################### 

~~~~~~~~~~sas
%fox(<quote>)
~~~~~~~~~~

### Arguments: ############################

- `quote` - The number of fox's quote.
            When missing or incorrect, 
            the default quote is displayed.


### Example: ##############################

Print quote number 1:
~~~~~~~~~~sas
%fox(1)
~~~~~~~~~~

---

*//*** HELP END ***/

/*** HELP START ***//*

The `rose.` format prints what does the rose says...

---

### Example: ##############################

Print quote number 2:
~~~~~~~~~~sas
data _null_;
  r=2;
  put r rose.;
run;
~~~~~~~~~~

---

*//*** HELP END ***/

/*** HELP START ***//*

The `prince()` function asks to draw a sheep...

---

### Arguments: ############################

The function has no arguments.

### Dependencies: #########################

The `prince()` function requires 
the `rose.` format to work.

### Example: ##############################

Ask for a sheep:
~~~~~~~~~~sas
data _null_;
  s=prince();
  put s=;
run;
~~~~~~~~~~

---

*//*** HELP END ***/

/*
### One file - one object
*/

resetline;

/* 01_macro -> fox.sas */
filename f "&dir.\01_macro\fox.sas";
data _null_;
  file f;
  infile CARDS4;
  input;
  put _infile_;
CARDS4;
/*** HELP START ***//*

The `%fox()` macro prints what does the fox says...

---

### Syntax: ############################### 

~~~~~~~~~~sas
%fox(<quote>)
~~~~~~~~~~

### Arguments: ############################

- `quote` - The number of fox's quote.
            When missing or incorrect, 
            the default quote is displayed.


### Example: ##############################

Print quote number 1:
~~~~~~~~~~sas
%fox(1)
~~~~~~~~~~

---

*//*** HELP END ***/

%macro fox(quote);
  %local n e w;
  %let n = NOTE;
  %let e = ERROR;
  %let w = WARNING;
  %if 1=%superq(quote) %then 
    %do;
      %put &n.- And now here is my secret, a very simple secret:; 
      %put &n.- It is only with the heart that one can see rightly%str(;);
      %put &n.- what is essential is invisible to the eye.;
    %end;
  %else
  %if 2=%superq(quote) %then 
    %do;
      %put &w.- It is the time you have wasted for your rose;
      %put &w.- that makes your rose so important.;
      %put &w.- Men have forgotten this truth. But you must not forget it.; 
      %put &w.- You become responsible, forever, for what you have tamed.;
      %put &w.- You are responsible for your rose...;
    %end;
  %else
    %do;
      %put &e.- One only understands the things that one tames.; 
      %put &e.- Men have no more time to understand anything.;
      %put &e.- They buy things all ready made at the shops.; 
      %put &e.- But there is no shop anywhere where one can buy friendship,; 
      %put &e.- and so men have no friends any more. If you want a friend, tame me...;
    %end;
%mend fox;
;;;;
run;

/* 02_formats -> rose.sas */
filename f "&dir.\02_formats\rose.sas";
data _null_;
  file f;
  infile CARDS4;
  input;
  put _infile_;
CARDS4;
/*** HELP START ***//*

The `rose.` format prints what does the rose says...

---

### Example: ##############################

Print quote number 2:
~~~~~~~~~~sas
data _null_;
  r=2;
  put r rose.;
run;
~~~~~~~~~~

---

*//*** HELP END ***/

value rose
1="Ah! I am scarcely awake. I beg that you will excuse me. My petals are still all disarranged..."
2="Of course I love you. It is my fault that you have not known it all the while. [...] Try to be happy..."
3="My cold is not so bad as all that... The cool night air will do me good. I am a flower."
4="Well, I must endure the presence of two or three caterpillars if I wish to become acquainted with the butterflies."
other="ERROR: QUOTE OUT OF RANGE!"
;
;;;;
run;

/* 03_functions -> prince.sas */
filename f "&dir.\03_functions\prince.sas";
data _null_;
  file f;
  infile CARDS4;
  input;
  put _infile_;
CARDS4;
/*** HELP START ***//*

The `prince()` function asks to draw a sheep...

---

### Arguments: ############################

The function has no arguments.

### Dependencies: #########################

The `prince()` function requires 
the `rose.` format to work.

### Example: ##############################

Ask for a sheep:
~~~~~~~~~~sas
data _null_;
  s=prince();
  put s=;
run;
~~~~~~~~~~

---

*//*** HELP END ***/

function prince() $ 42;
  file log;

  length i $ 256;
  r=rand('integer',1,4);
  i = put(r, rose.);
  put @1 "RANDOM NOTE:" i /;

  return("If you please--draw me a sheep!");
endfunc;
;;;;
run;

/*
### Tests

Tests are optionally available, i.e., they are available if the `XCMD` option is on. 

One test of loading a package is always automatically executed. All other tests are developer's job to do.

The SPF automatically points to the package location for tests, developer doesn't have to worry.
*/

resetline;
options dlcreatedir;

libname p "&dir.\99_test";
libname p clear;

/* 99_test -> test_success.sas */
filename f "&dir.\99_test\test_success.sas";
data _null_;
  file f;
  infile CARDS4;
  input;
  put _infile_;
CARDS4;
%put testing macro:;
%fox(1)
%fox(2)
%fox()

data _null_;
  put "Testing format:";
  do i = 1 to 4;
    put "NOTE- " i rose. /;
  end;
run;

data _null_;
  put "Testing function:";
  do i = 1 to 5;
    prince=prince();
    rc=sleep(1,0.2);
  end;
  put;
run;
;;;;
run;

/* 99_test -> test_fail_e1w0.sas */
filename f "&dir.\99_test\test_fail_e1w0.sas";
data _null_;
  file f;
  infile CARDS4;
  input;
  put _infile_;
CARDS4;
data _null_;
  put "Testing format (should print error):";
  do i = 5;
    put i rose. /;
  end;
run;
;;;;
run;

/*
## Generate Package

In this session we already have the SPF enabled, but in the development process you have to point the location for packages and enable the framework.
*/

filename packages "C:\SAS_WORK\SAS_PACKAGES";
%include packages(SPFinit.sas);

/*
Options can be easily reminded (in he LOG) by calling the macro with the `HELP` keyword.
*/

%generatePackage(HELP)

resetline;

/* Generate Package */

%generatePackage(
 R:\NJSUG\LePetitSASpackageDirectory
,markdownDoc=1
,packages=C:\SAS_WORK\SAS_PACKAGES
)

/* REMEMBER! Always check the log.*/

/*
# --The End--

The package is ready! It can be shared with other SAS programmers now.

---
*/

/*
#

##

###

---

# Start New SAS Session

In a brand new SAS session try out how the created package works.
*/

/* create directory for SAS packages */

resetline;
options dlcreatedir;
libname p "R:\NJSUG\trySASpackages";
libname p clear;

/* install the SAS Packages Framework and the SQLinDS package */

filename packages "R:\NJSUG\trySASpackages";

filename SPFinit url "https://bit.ly/SPFinit";
%include SPFinit; /* enable the framework */
filename SPFinit clear;

%installPackage(SPFinit SQLinDS)

/*
Copy, manually for now, the LePetitSASpackage (the zip file) to packages directory.
*/

/* enable the SPF and load the LePetitSASpackage */

filename packages "R:\NJSUG\trySASpackages";
%include packages(SPFinit.sas);
%listPackages()


%loadPackage(LePetitSASpackage)

/* try it */
%fox(1)
%fox(2)

%put %sysfunc(prince());

data _null_;
  p = prince();
  put p=;
run;

/*
---
*/

/*
---
*/
