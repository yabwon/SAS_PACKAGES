- [The BasePlus package](#baseplus-package)
- [Content description](#content-description)
  * [`%getVars()` macro](#getvars-macro)  
  * [`%QgetVars()` macro](#qgetvars-macro)  
  * [`%symdelGlobal()` macro](#symdelglobal-macro)
  * [`bool.` format](#bool-format)
  * [`boolz.` format](#boolz-format)
  * [`ceil.` format](#ceil-format)
  * [`floor.` format](#floor-format)
  * [`int.` format](#int-format)
  * [`arrFill()` subroutine](#arrfill-subroutine)  
  * [`arrFillC()` subroutine](#arrfillc-subroutine)  
  * [`arrMissFill()` subroutine](#arrmissfill-subroutine)  
  * [`arrMissFillC()` subroutine](#arrmissfillc-subroutine)  
  * [`arrMissToLeft()` subroutine](#arrmisstoleft-subroutine)  
  * [`arrMissToLeftC()` subroutine](#arrmisstoleftc-subroutine)  
  * [`arrMissToRight()` subroutine](#arrmisstoright-subroutine)  
  * [`arrMissToRightC()` subroutine](#arrmisstorightc-subroutine)  
  * [`catXFc()` function](#catxfc-function)  
  * [`catXFi()` function](#catxfi-function)  
  * [`catXFj()` function](#catxfj-function)  
  * [`catXFn()` function](#catxfn-function)  
  * [`delDataset()` function](#deldataset-function)  
  * [`qsortInCbyProcProto()` proto function](#qsortincbyprocproto-proto-function)  
  * [`fromMissingToNumberBS()` function](#frommissingtonumberbs-function)  
  * [`fromNumberToMissing()` function](#fromnumbertomissing-function)  
  * [`quickSort4NotMiss()` subroutine](#quicksort4notmiss-subroutine)  
  * [`quickSortHash()` subroutine](#quicksorthash-subroutine)  
  * [`quickSortHashSDDV()` subroutine](#quicksorthashsddv-subroutine)  
  * [`quickSortLight()` subroutine](#quicksortlight-subroutine) 
  * [`%dedupListS()` macro](#deduplists-macro)
  * [`%dedupListC()` macro](#deduplistc-macro)
  * [`%dedupListP()` macro](#deduplistp-macro)
  * [`%dedupListX()` macro](#deduplistx-macro)
  * [`%QdedupListX()` macro](#qdeduplistx-macro)
  
  * [License](#license)
  
---

# The BasePlus package [ver. 0.9] <a name="baseplus-package"></a> ###############################################

The **BasePlus** package implements useful
functions and functionalities I miss in the BASE SAS.

It is inspired by various people, e.g.
- at the SAS-L discussion list
- at the communities.sas.com (SASware Ballot Ideas)
- at the Office...
- etc.

Kudos to all who inspired me to generate this package:
*Mark Keintz*, 
*Paul Dorfman*, 
*Richard DeVenezia*, 
*Christian Graffeuille*. 

---

### BASIC EXAMPLES AND USECASES: ####################################################

**Example 1**: One-dimensional array functions.
               Array parameters to subroutine 
               calls must be 1-based.          
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  data _null_;
   array X[4] _temporary_ (. 1 . 2);

   call arrMissToRight(X);
    do i = 1 to 4;
     put X[i]= @;
    end;
    put;

   call arrFillMiss(17, X);
    do i = 1 to 4;
     put X[i]= @;
    end;
    put;

   call arrFill(42, X);
    do i = 1 to 4;
     put X[i]= @;
    end;
  run;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


**Example 2**: Delete dataset by name.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  data toDrop;
    x = 17;
  run;
  data _null_;
    p = delDataset("toDrop");
    put p=;
  run;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


**Example 3**: Strings concatenation with format.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  data test;
    x =  1 ; y =  . ; z =  3 ;
    t = "t"; u = " "; v = "v";

    array a[*] x y z;
    array b[*] t u v;

    length s1 s2 s3 s4 $ 17;
    s1 = catXFn("z5.", "#", A);
    s2 = catXFi("z5.", "#", A);
    s3 = catXFc("upcase.", "*", B);
    s4 = catXFj("upcase.", "*", B);

    put (_all_) (=);
  run;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Example 4**: Useful formats.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  data _null_;
    input x @@;
    put @1 x= @11 x= bool. @21 x= int. @31 x= ceil. @41 x= floor.;
  cards;
  . ._ .A -10 -3.14 0 3.14 10
  ;
  run;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Example 5**: Getting variables names from datasets.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %put *%getVars(sashelp.class
                ,pattern   = ght$
                ,sep      = +
                ,varRange = _numeric_)*;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Example 6**: Quick sort as an alternative to call sortn()
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  data _null_;
    array test[25000000] _temporary_ ;

    t = time();
      call streaminit(123);
      do _N_ = 25000000 to 1 by -1;
        test[_N_] = rand("uniform");
      end;
    t = time() - t;
    put "Array population time: "  t;

    t = time();
      call quickSortLight (test);
    t = time()-t;
    put "Sorting time: " / t=;
  run;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Example 7**: Deduplicate values from a space separated list.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %let list = 4 5 6 1 2 3 1 2 3 4 5 6;
  %put *%dedupListS(&list.)*;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

---

Package contains: 
  1.   macro      deduplistc 
  2.   macro      deduplistp 
  3.   macro      deduplists 
  4.   macro      deduplistx 
  5.   macro      getvars 
  6.   macro      qdeduplistx 
  7.   macro      qgetvars 
  8.   macro      symdelglobal 
  9.   format     bool 
  10.  format     boolz 
  11.  format     ceil 
  12.  format     floor 
  13.  format     int 
  14.  functions  arrfill 
  15.  functions  arrfillc 
  16.  functions  arrmissfill 
  17.  functions  arrmissfillc 
  18.  functions  arrmisstoleft 
  19.  functions  arrmisstoleftc 
  20.  functions  arrmisstoright 
  21.  functions  arrmisstorightc 
  22.  functions  catxfc 
  23.  functions  catxfi 
  24.  functions  catxfj 
  25.  functions  catxfn 
  26.  functions  deldataset 
  27.  proto      qsortincbyprocproto 
  28.  functions  frommissingtonumberbs 
  29.  functions  fromnumbertomissing 
  30.  functions  quicksort4notmiss 
  31.  functions  quicksorthash 
  32.  functions  quicksorthashsddv 
  33.  functions  quicksortlight 

*SAS package generated by generatePackage, version 20201101*

The SHA256 hash digest for package BasePlus: 
`9AC9F71DBC890068BBD972311BEF3F0D1CA100C3F80A5C34C56B9646D04BFEFB` 

---
# Content description ############################################################################################

## >>> `%getVars()` macro: <<< <a name="getvars-macro"></a> #######################  

The getVars() and QgetVars() macro functions
allow to extract variables names form a dataset
according to a given pattern into a list.

The getVars() returns unquoted value [by %unquote()].
The QgetVars() returns quoted value [by %superq()].

See examples below for the details.

The `%getVars()` macro executes like a pure macro code.

### SYNTAX: ###################################################################

The basic syntax is the following, the `<...>` means optional parameters:
~~~~~~~~~~~~~~~~~~~~~~~sas
%getVars(
   ds               
 <,sep=>
 <,pattern=>
 <,varRange=>
 <,quote=>
 <,mcArray=> 
)
~~~~~~~~~~~~~~~~~~~~~~~

**Arguments description**:

1. `ds`              - *Required*, the name of the dataset from 
                       which variables are to be taken.

* `sep = %str( )`    - *Optional*, default value `%str( )`, 
                       a variables separator on the created list. 

* `pattern = .*`     - *Optional*, default value `.*` (i.e. any text), 
                       a variable name regexp pattern, case INSENSITIVE! 

* `varRange = _all_` - *Optional*, default value `_all_`, 
                       a named range list of variables. 

* `quote =`          - *Optional*, default value is blank, a quotation 
                       symbol to be used around values.

* `mcArray=`         - *Optional*, default value is blank.
                       1) When *null* - the macro behaves like a macro function 
                          and returns a text string with variables list.
                       2) When *not null* - behaviour of the macro is altered.
                          In such case a macro array of selected variables, named 
                          with `mcArray` value as a prefix, is created.
                          Furthermore a macro named as `mcArray` value is generated.
                          (see the macroArray package for the details).
                          When `mcArray=` parameter is active the `getVars` macro 
                          cannot be called within the `%put` statement. Execution like: 
                           `%put %getVars(..., mcArray=XXX);` will result with  
                          an Explicit & Radical Refuse Of Run (aka ERROR).


### EXAMPLES AND USECASES: ####################################################

**EXAMPLE 1.** A list of all variables from the 
               sashelp.class dataset:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %put *%getVars(sashelp.class)*;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


**EXAMPLE 2.** A list of all variables from the 
               sashelp.class dataset separated 
               by backslash:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %let x = %getVars(sashelp.class, sep=\);
  %put &=x;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


**EXAMPLE 3.** Use of regular expressions:
 a) A list of variables which name contains "i" or "a" 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %put *%getVars(sashelp.class, pattern=i|a)*;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 b) A list of variables which name starts with "w"
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas  
  %put *%getVars(sashelp.class, pattern=^w)*;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 c) A list of variables which name ends with "ght"
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas  
  %put *%getVars(sashelp.class, pattern=ght$)*;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


**EXAMPLE 4.** A list of numeric variables which name 
               starts with "w" or "h" or ends with "x"
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %put *%getVars(sashelp.class, sep=+, pattern=^(w|h)|x$, varRange=_numeric_)*;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


**EXAMPLE 5.**
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  data test;
    array x[30];
    array y[30] $ ;
    array z[30];
  run;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 a) A list of variables separated by a comma:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %put *%getVars(test, sep=%str(,))*;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 b) A list of variables separated by a comma
    with suffix 5 or 7:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %put *%getVars(test, sep=%str(,), pattern=(5|7)$)*;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 c) A list of variables separated by a comma
    with suffix 5 or 7 from a given variables range:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %put *%getVars(test, sep=%str(,), varRange=x10-numeric-z22 y6-y26, pattern=(5|7)$)*;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


**EXAMPLE 6.** Case of quotes and special characters 
               when the quote= parameter is _not_ used:

 a) one single or double qiote:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %put *%bquote(%getVars(sashelp.class, sep=%str(%")))*;
  %put *%bquote(%getVars(sashelp.class, sep=%str(%')))*;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 b) two single or double qiotes:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %put *"%bquote(%getVars(sashelp.class,sep=""))"*;
  %put *%str(%')%bquote(%getVars(sashelp.class,sep=''))%str(%')*;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 c) coma separated double quote list:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %put *"%getVars(sashelp.class,sep=%str(", "))"*;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 d) coma separated single quote list:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %put *%str(%')%getVars(sashelp.class,sep=', ')%str(%')*;
  %let x = %str(%')%getVars(sashelp.class,sep=', ')%str(%');

  %put *%str(%')%QgetVars(sashelp.class,sep=', ')%str(%')*;
  %let y = %str(%')%QgetVars(sashelp.class,sep=', ')%str(%');
  %let z = %unquote(&y.);
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 e) ampersand (&) as a separator [compare behaviour]:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %put *%getVars(sashelp.class,sep=&)*;
  %let x = %getVars(sashelp.class,sep=&);

  %put *%getVars(sashelp.class,sep=%str( & ))*;
  %let x = %getVars(sashelp.class,sep=%str( & ));

  %put *%QgetVars(sashelp.class,sep=&)*;
  %let y = %QgetVars(sashelp.class,sep=&);
  %let z = %unquote(&y.);

  %put *%QgetVars(sashelp.class,sep=%str( & ))*;
  %let y = %QgetVars(sashelp.class,sep=%str( & ));
  %let z = %unquote(&y.);

  %put *%getVars(sashelp.class,sep=&)*;
  %let x = %getVars(sashelp.class,sep=&);

  %put *%getVars(sashelp.class,sep=%str( & ))*;
  %let x = %getVars(sashelp.class,sep=%str( & ));
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 f) percent (%) as a separator [compare behaviour]:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %put *%QgetVars(sashelp.class,sep=%)*;
  %let y = %QgetVars(sashelp.class,sep=%);
  %let z = %unquote(&y.);

  %put *%QgetVars(sashelp.class,sep=%str( % ))*;
  %let y = %QgetVars(sashelp.class,sep=%str( % ));
  %let z = %unquote(&y.);
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


**EXAMPLE 7.** Case of quotes and special characters 
               when the quote= parameter is used:

a) one single or double qiote:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %put *%getVars(sashelp.class, quote=%str(%"))*;
  %put *%getVars(sashelp.class, quote=%str(%'))*;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 b) two single or double quotes:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %* this gives an error:                   ;
  %* %put *%getVars(sashelp.class,quote="")*;
  %* %put *%getVars(sashelp.class,quote='')*;

  %* this does not give an error:         ;
  %put *%QgetVars(sashelp.class,quote="")*;
  %put *%QgetVars(sashelp.class,quote='')*;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 c) coma separated double quote list:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %put *%getVars(sashelp.class,sep=%str(,),quote=%str(%"))*;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 d) coma separated single quote list:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %let x = %getVars(sashelp.class,sep=%str(,),quote=%str(%'));
  %put &=x.;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


**EXAMPLE 8.** Variables that start with `A` and do not end with `GHT`:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
data class;
  set sashelp.class;
  Aeight  = height;
run;

%put *%getVars(class, pattern = ^A(.*)(?<!ght)$, quote=%str(%"))*;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


**EXAMPLE 9.** Variables that do not start with `N` and do not end with `GHT`:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
data class;
  set sashelp.class;
  Aeight  = height;
  Neight  = height;
run;

%put *%getVars(class, pattern = ^(?!N.*)(.*)(?<!ght)$, quote=%str(%"))*;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


**EXAMPLE 10.** Composition with itself:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  data class;
    set sashelp.class;
    Age_C    = put(Age, best32.);
    Height_C = put(Height, best32.);
    Weight_C = put(Weight, best32.);
  run;

  %put #%getVars(class, varRange=_numeric_, sep=%str(: ))# <- no : at the end!!;

  %put #%getVars(class, varRange=%getVars(class, varRange=_numeric_, sep=%str(: )):, sep=\)#;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


**EXAMPLE 11.** Create a macro array `XYZ...` of variables names and an additional 
                macro `%XYZ()` which allows easy access to the list. Can be used with 
                the `%do_over()` macro (provided with the macroArray package).
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  data test;
    array x[30];
    array y[30] $ ;
    array z[30];
  run;

  %getVars(test
          ,mcArray=XYZ
          ,varRange=x10-numeric-z22 y6-y26
          ,pattern=(5|7)$
          ,quote=#)

  %put _user_;
  %put *%XYZ(1)**%XYZ(2)*%XYZ(3)*;
  
  %* Load the macroArray package first. ; 
  %put %do_over(XYZ);
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

---

## >>> `%QgetVars()` macro: <<< <a name="qgetvars-macro"></a> #######################  

The getVars() and QgetVars() macro functions
allow to extract variables names form a dataset
according to a given pattern into a list.

The getVars() returns unquoted value [by %unquote()].
The QgetVars() returns quoted value [by %superq()].

The `%QgetVars()` macro executes like a pure macro code.

### SYNTAX: ###################################################################

The basic syntax is the following, the `<...>` means optional parameters:
~~~~~~~~~~~~~~~~~~~~~~~sas
%QgetVars(
   ds               
 <,sep=>
 <,pattern=>
 <,varRange=>
 <,quote=>          
)
~~~~~~~~~~~~~~~~~~~~~~~

**Arguments description**:

1. `ds`              - *Required*, the name of the dataset from 
                       which variables are to be taken.

* `sep = %str( )`    - *Optional*, default value `%str( )`, 
                       a variables separator on the created list. 

* `pattern = .*`     - *Optional*, default value `.*` (i.e. any text), 
                       a variable name regexp pattern, case INSENSITIVE! 

* `varRange = _all_` - *Optional*, default value `_all_`, 
                       a named range list of variables. 

* `quote =`          - *Optional*, default value is blank, a quotation 
                       symbol to be used around values.

### EXAMPLES AND USECASES: ####################################################

See examples in `%getVars()` help for the details.

---

## >>> `%symdelGlobal()` macro: <<< <a name="symdelglobal-macro"></a> #######################

The `%symdelGlobal()` macro deletes all global macrovariables
created by the user. The only exceptions are read only variables
and variables the one which starts with SYS, AF, or FSP.
In that case a warning is printed in the log.

One temporary global macrovariable `________________98_76_54_32_10_` 
and a dataset, in `work` library, named `_%sysfunc(datetime(),hex7.)`
are created and deleted during the process.

The `%symdelGlobal()` macro executes like a pure macro code.

### SYNTAX: ###################################################################

The basic syntax is the following, the `<...>` means optional parameters:
~~~~~~~~~~~~~~~~~~~~~~~sas
%symdelGlobal(
 info
)
~~~~~~~~~~~~~~~~~~~~~~~

**Arguments description**:

1. `info` - *Optional*, default value should be empty, 
            if set to `NOINFO` or `QUIET` then infos and 
            warnings about variables deletion are suspended. 

 
### EXAMPLES AND USECASES: ####################################################

**EXAMPLE 1.** Basic use-case one. 
    Delete global macrovariables, info notes 
    and warnings are printed in the log.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %let a = 1;
  %let b = 2;
  %let c = 3;
  %let sys_my_var = 11;
  %let  af_my_var = 22;
  %let fsp_my_var = 33;
  %global / readonly read_only_x = 1234567890;

  %put _user_;

  %symdelGlobal();

  %put _user_;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**EXAMPLE 2.** Basic use-case two. 
    Delete global macrovariables in quite mode
    No info notes and warnings are printed in the log.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %let a = 1;
  %let b = 2;
  %let c = 3;
  %let sys_my_var = 11;
  %let  af_my_var = 22;
  %let fsp_my_var = 33;
  %global / readonly read_only_x = 1234567890;

  %put _user_;
  %put *%symdelGlobal(NOINFO)*;
  %put _user_;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
---

## >>> `bool.` format: <<< <a name="bool-format"></a> #######################

The **bool** format returns: 
*zero* for 0 or missing, 
*one* for other values.

### EXAMPLES AND USECASES: #################################################### 

It allows for a %sysevalf()'ish
conversion-type [i.e. `%sysevalf(1.7 & 4.2, boolean)`]
inside the `%sysfunc()` [e.g. `%sysfunc(aFunction(), bool.)`]

--- 

## >>> `boolz.` format: <<< <a name="boolz-format"></a> #######################

The **boolz** format returns:
*zero* for 0 or missing, 
*one* for other values.

*Fuzz* value is 0.

### EXAMPLES AND USECASES: #################################################### 

It allows for a %sysevalf()'ish
conversion-type [i.e. `%sysevalf(1.7 & 4.2, boolean)`]
inside the `%sysfunc()` [e.g. `%sysfunc(aFunction(), boolz.)`]

--- 

## >>> `ceil.` format: <<< <a name="ceil-format"></a> #######################

The **ceil** format is a "wrapper" for the `ceil()` function. 

### EXAMPLES AND USECASES: #################################################### 

It allows for a %sysevalf()'ish
conversion-type [i.e. `%sysevalf(1.7 + 4.2, ceil)`]
inside the `%sysfunc()` [e.g. `%sysfunc(aFunction(), ceil.)`]

--- 

## >>> `floor.` format: <<< <a name="floor-format"></a> #######################

The **floor** format is a "wrapper" for the `floor()` function.

### EXAMPLES AND USECASES: #################################################### 

It allows for a %sysevalf()'ish
conversion-type [i.e. `%sysevalf(1.7 + 4.2, floor)`]
inside the `%sysfunc()` [e.g. `%sysfunc(aFunction(), floor.)`]

--- 

## >>> `int.` format: <<< <a name="int-format"></a> #######################

The **int** format is a "wrapper" for the `int()` function. 

### EXAMPLES AND USECASES: #################################################### 

It allows for a %sysevalf()'ish
conversion-type [i.e. `%sysevalf(1.7 + 4.2, integer)`]
inside the `%sysfunc()` [e.g. `%sysfunc(aFunction(), int.)`]

--- 

## >>> `arrFill()` subroutine: <<< <a name="arrfill-subroutine"></a> #######################  

The **arrFill()** subroutine is a wrapper 
for the Call Fillmatrix() [a special FCMP subroutine]. 

A numeric array is filled with selected numeric value, e.g.

for array `A = [. . . .]` the subroutine
`call arrFill(42, A)` returns `A = [42 42 42 42]`

*Caution!* Array parameters to subroutine calls *must* be 1-based.

### SYNTAX: ###################################################################

The basic syntax is the following, the `<...>` means optional parameters:
~~~~~~~~~~~~~~~~~~~~~~~sas
call arrFill(N ,A)
~~~~~~~~~~~~~~~~~~~~~~~

**Arguments description**:

1. `N` - Numeric value.

2. `A` - Numeric array.

 
### EXAMPLES AND USECASES: ####################################################

**Example 1.**
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
data _null_;
 array X[*] a b c;

 put "before: " (_all_) (=);
 call arrFill(42, X);
 put "after:  " (_all_) (=);

run;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

---

## >>> `arrFillC()` subroutine: <<< <a name="arrfillc-subroutine"></a> #######################  

The **arrFillC()** subroutine fills 
a character array with selected character value, e.g. 

for array `A = [" ", " ", " "]` the subroutine
`call arrFillC("B", A)` returns `A = ["B", "B", "B"]`

*Caution!* Array parameters to subroutine calls *must* be 1-based.

### SYNTAX: ###################################################################

The basic syntax is the following, the `<...>` means optional parameters:
~~~~~~~~~~~~~~~~~~~~~~~sas
call arrFillC(C ,A)
~~~~~~~~~~~~~~~~~~~~~~~

**Arguments description**:

1. `C` - Character value.

2. `A` - Character array.

 
### EXAMPLES AND USECASES: ####################################################

**Example 1.**
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
data _null_;
 array X[*] $ a b c;

 put "before: " (_all_) (=);
 call arrFillC("ABC", X);
 put "after:  " (_all_) (=);

run;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

---

## >>> `arrMissFill()` subroutine: <<< <a name="arrmissfill-subroutine"></a> #######################  

The **arrMissFill()** subroutine fills 
all missing values (i.e. less or equal than `.Z`) 
of a numeric array with selected numeric value, e.g.

for array `A = [1 . . 4]` the subroutine
`call arrMissFill(42, A)` returns `A = [1 42 42 4]`

*Caution!* Array parameters to subroutine calls *must* be 1-based.

### SYNTAX: ###################################################################

The basic syntax is the following, the `<...>` means optional parameters:
~~~~~~~~~~~~~~~~~~~~~~~sas
call arrMissFill(N ,A)
~~~~~~~~~~~~~~~~~~~~~~~

**Arguments description**:

1. `N` - Numeric value.

2. `A` - Numeric array.

 
### EXAMPLES AND USECASES: ####################################################

**Example 1.**
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
data have;
  input a b c;
cards4;
1 . 3
. 2 .
. . 3
;;;;
run;

data _null_;
 set have ;
 array X[*] a b c;

 put "before: " (_all_) (=);
 call arrMissFill(42, X);
 put "after:  " (_all_) (=);

run;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

---

## >>> `arrMissFillC()` subroutine: <<< <a name="arrmissfillc-subroutine"></a> #######################  

The **arrMissFillC()** subroutine fills 
all missing values of a character array 
with selected character value, e.g. 

for array `A = ["A", " ", "C"]` the subroutine
`call arrMissFillC("B", A)` returns `A = ["A", "B", "C"]`

*Caution!* Array parameters to subroutine calls *must* be 1-based.

### SYNTAX: ###################################################################

The basic syntax is the following, the `<...>` means optional parameters:
~~~~~~~~~~~~~~~~~~~~~~~sas
call arrMissFillC(C, A)
~~~~~~~~~~~~~~~~~~~~~~~

**Arguments description**:

1. `C` - Character value.

2. `A` - Character array.

 
### EXAMPLES AND USECASES: ####################################################

**Example 1.**
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
data have;
  infile cards dsd dlm="," missover;
  input (a b c) (: $ 1.);
cards4;
A, ,C
 ,B, 
 , ,C
;;;;
run;

data _null_;
 set have ;
 array X[*] $ a b c;

 put "before: " (_all_) (=);
 call arrMissFillC("X", X);
 put "after:  " (_all_) (=);

run;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

---

## >>> `arrMissToLeft()` subroutine: <<< <a name="arrmisstoleft-subroutine"></a> #######################  

The **arrMissToLeft()** subroutine shifts 
all non-missing (i.e. greater than `.Z`) 
numeric elements to the right side of an array 
and missing values to the left, e.g. 

for array `A = [1 . 2 . 3]` the subroutine
`call arrMissToLeft(A)` returns `A = [. . 1 2 3]`

All missing values are replaced with the dot (`.`)

*Caution!* Array parameters to subroutine calls *must* be 1-based.

### SYNTAX: ###################################################################

The basic syntax is the following, the `<...>` means optional parameters:
~~~~~~~~~~~~~~~~~~~~~~~sas
call arrMissToLeft(A)
~~~~~~~~~~~~~~~~~~~~~~~

**Arguments description**:

1. `A` - Numeric array.


### EXAMPLES AND USECASES: ####################################################

**Example 1.**
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
data have;
  input a b c;
cards4;
1 . 3
. 2 .
. . 3
;;;;
run;

data _null_;
 set have ;
 array X[*] a b c;

 put "before: " (_all_) (=);
 call arrMissToLeft(X);
 put "after:  " (_all_) (=);

run;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

---

## >>> `arrMissToLeftC()` subroutine: <<< <a name="arrmisstoleftc-subroutine"></a> #######################  

The **arrMissToLeftC()** subroutine shifts 
all non-missing (i.e. different than empty string) 
character elements to the right side of an array 
and all missing values to the left, e.g. 

for array `A = ["A", " ", "B", " ", "C"]` the subroutine
`call arrMissToLeftC(A)` returns `A = [" ", " ", "A", "B", "C"]`

*Caution!* Array parameters to subroutine calls *must* be 1-based.

### SYNTAX: ###################################################################

The basic syntax is the following, the `<...>` means optional parameters:
~~~~~~~~~~~~~~~~~~~~~~~sas
call arrMissToLeftC(A)
~~~~~~~~~~~~~~~~~~~~~~~

**Arguments description**:

1. `A` - Character array.

 
### EXAMPLES AND USECASES: ####################################################

**Example 1.**
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
data have;
  infile cards dsd dlm="," missover;
  input (a b c) (: $ 1.);
cards4;
A, ,C
 ,B, 
 , ,C
;;;;
run;

data _null_;
 set have ;
 array X[*] $ a b c;

 put "before: " (_all_) (=);
 call arrMissToLeftC(X);
 put "after:  " (_all_) (=);

run;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

---

## >>> `arrMissToRight()` subroutine: <<< <a name="arrmisstoright-subroutine"></a> #######################  

The **arrMissToRight()** subroutine shifts 
all non-missing (i.e. greater than `.Z`) 
numeric elements to the left side of an array 
and missing values to the right, e.g.

for array `A = [1 . 2 . 3]` the subroutine
`call arrMissToRight(A)` returns `A = [1 2 3 . .]`

All missing values are replaced with the dot (`.`)

*Caution!* Array parameters to subroutine calls *must* be 1-based.

### SYNTAX: ###################################################################

The basic syntax is the following, the `<...>` means optional parameters:
~~~~~~~~~~~~~~~~~~~~~~~sas
call arrMissToRight(A)
~~~~~~~~~~~~~~~~~~~~~~~

**Arguments description**:

1. `A` - Numeric array.

 
### EXAMPLES AND USECASES: ####################################################

**Example 1.**
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
data have;
  input a b c;
cards4;
1 . 3
. 2 .
. . 3
;;;;
run;

data _null_;
 set have ;
 array X[*] a b c;

 put "before: " (_all_) (=);
 call arrMissToRight(X);
 put "after:  " (_all_) (=);

run;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

---

## >>> `arrMissToRightC()` subroutine: <<< <a name="arrmisstorightc-subroutine"></a> #######################  

The **arrMissToRightC()** subroutine shifts 
all non-missing (i.e. different than empty string) 
character elements to the left side of an array 
and missing values to the right, e.g. 

for array `A = ["A", " ", "B", " ", "C"]` the subroutine
`call arrMissToRightC(A)` returns `A = ["A", "B", "C", " ", " "]`

*Caution!* Array parameters to subroutine calls *must* be 1-based.

### SYNTAX: ###################################################################

The basic syntax is the following, the `<...>` means optional parameters:
~~~~~~~~~~~~~~~~~~~~~~~sas
call arrMissToRightC(A)
~~~~~~~~~~~~~~~~~~~~~~~

**Arguments description**:

1. `A` - Character array.

 
### EXAMPLES AND USECASES: ####################################################

**Example 1.**
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
data have;
  infile cards dsd dlm="," missover;
  input (a b c) (: $ 1.);
cards4;
A, ,C
 ,B, 
 , ,C
;;;;
run;

data _null_;
 set have ;
 array X[*] $ a b c;

 put "before: " (_all_) (=);
 call arrMissToRightC(X);
 put "after:  " (_all_) (=);

run;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

---

## >>> `catXFc()` function: <<< <a name="catxfc-function"></a> #######################  

The **catXFc()** function is a wrapper 
of the `catX()` function but with ability 
to format character values. 

For array `A = ["a", " ", "c"]` the 
`catXFc("upcase.", "*", A)` returns `"A*C"`. 

If format does not handle nulls they are ignored. 

*Caution!* Array parameters to function calls *must* be 1-based. 

### SYNTAX: ###################################################################

The basic syntax is the following, the `<...>` means optional parameters:
~~~~~~~~~~~~~~~~~~~~~~~sas
catXFc(format, delimiter, A)
~~~~~~~~~~~~~~~~~~~~~~~

**Arguments description**:

1. `format`    - A name of the *character* format to be used.

2. `delimiter` - A delimiter string to be used.

3. `A`         - Character array

 
### EXAMPLES AND USECASES: ####################################################

**Example 1.**
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
data _null_;
  t = "t";
  u = " ";
  v = "v";

  array b[*] t u v;

  length s $ 17;
  s = catXFc("upcase.", "*", B);
  put (_all_) (=);
run;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

---

## >>> `catXFi()` function: <<< <a name="catxfi-function"></a> #######################  

The **catXFi()** function is a wrapper 
of the `catX()` function but with ability 
to format numeric values but 
IGNORES missing values (i.e. `._`, `.`, `.a`, ..., `.z`). 

For array `A = [0, ., 2]` the 
`catXFi("date9.", "#", A)` returns 
`"01JAN1960#03JAN1960"` 

*Caution!* Array parameters to function calls *must* be 1-based. 

### SYNTAX: ###################################################################

The basic syntax is the following, the `<...>` means optional parameters:
~~~~~~~~~~~~~~~~~~~~~~~sas
catXFi(format, delimiter, A)
~~~~~~~~~~~~~~~~~~~~~~~

**Arguments description**:

1. `format`    - A name of the *numeric* format to be used.

2. `delimiter` - A delimiter string to be used.

3. `A`         - Numeric array

 
### EXAMPLES AND USECASES: ####################################################

**Example 1.**
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
data _null_;
  x = 1;
  y = .;
  z = 3;

  array a[*] x y z;

  length s $ 17;
  s = catXFi("z5.", "#", A);
  put (_all_) (=);
run;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

---

## >>> `catXFj()` function: <<< <a name="catxfj-function"></a> #######################  

The **catXFj()** function is a wrapper 
of the catX() function but with ability 
to format character values. 

For array `A = ["a", " ", "c"]` the 
`catXFj("upcase.", "*", A)` returns `"A**C"` 

If format does not handle nulls they are 
printed as an empty string. 

*Caution!* Array parameters to function calls *must* be 1-based. 

### SYNTAX: ###################################################################

The basic syntax is the following, the `<...>` means optional parameters:
~~~~~~~~~~~~~~~~~~~~~~~sas
catXFj(format, delimiter, A)
~~~~~~~~~~~~~~~~~~~~~~~

**Arguments description**:

1. `format`    - A name of the *character* format to be used.

2. `delimiter` - A delimiter string to be used.

3. `A`         - Character array

 
### EXAMPLES AND USECASES: ####################################################

**Example 1.**
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
data _null_;
  t = "t";
  u = " ";
  v = "v";

  array b[*] t u v;

  length s $ 17;
  s = catXFj("upcase.", "*", B);
  put (_all_) (=);
run;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

---

## >>> `catXFn()` function: <<< <a name="catxfn-function"></a> #######################  

The **catXFn()** function is a wrapper 
of the `catX()` function but with ability 
to format numeric values. 

For array `A = [0, 1, 2]` the 
`catXFn("date9.", "#", A)` returns 
`"01JAN1960#02JAN1960#03JAN1960"`

*Caution!* Array parameters to function calls *must* be 1-based. 

### SYNTAX: ###################################################################

The basic syntax is the following, the `<...>` means optional parameters:
~~~~~~~~~~~~~~~~~~~~~~~sas
catXFn(format, delimiter, A)
~~~~~~~~~~~~~~~~~~~~~~~

**Arguments description**:

1. `format`    - A name of the *numeric* format to be used.

2. `delimiter` - A delimiter string to be used.

3. `A`         - Numeric array

 
### EXAMPLES AND USECASES: ####################################################

**Example 1.**
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
data _null_;
  x = 1;
  y = .;
  z = 3;

  array a[*] x y z;

  length s $ 17;
  s = catXFn("z5.", "#", A);
  put (_all_) (=);
run;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

---

## >>> `delDataset()` function: <<< <a name="deldataset-function"></a> #######################  

The **delDataset()** function is a "wrapper" 
for the `Fdelete()` function. 
`delDataset()` function uses a text string with 
a dataset name as an argument.

Function checks for `*.sas7bdat`, `*.sas7bndx`, 
and `*.sas7bvew` files and delete them.
Return code of 0 means dataset was deleted.

For compound library files are 
deleted from _ALL_ locations!


*Note:*
Currently only the BASE SAS engine datasets/views are deleted.

Tested on Windows and Linux. Not tested on Z/OS.

### SYNTAX: ###################################################################

The basic syntax is the following, the `<...>` means optional parameters:
~~~~~~~~~~~~~~~~~~~~~~~sas
delDataset(lbds_)
~~~~~~~~~~~~~~~~~~~~~~~

**Arguments description**:

1. `lbds_` - *Required*, character argument containing 
             name of the dataset/view to be deleted.
             The `_last_` special name is honored.
 
### EXAMPLES AND USECASES: ####################################################

**EXAMPLE 1.**
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  data TEST1 TEST2(index=(x));
    x = 17;
  run;

  data TEST3 / view=TEST3;
    set test1;
  run;

  data _null_;
    p = delDataset("WORK.TEST1");
    put p=;

    p = delDataset("TEST2");
    put p=;

    p = delDataset("WORK.TEST3");
    put p=;
  run;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


**Example 2.**
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  data TEST4;
    x=42;
  run;
  data _null_;
    p = delDataset("_LAST_");
    put p=;
  run;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


**Example 3.**
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  options dlcreatedir;
  libname user "%sysfunc(pathname(work))/user";

  data TEST5;
    x=42;
  run;

  data _null_;
    p = delDataset("test5");
    put p=;
  run;

  libname user clear;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


**Example 4.**
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  data TEST6;
    x=42;
  run;

  %put *%sysfunc(delDataset(test6))*;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


**Example 5.**
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  options dlcreatedir;
  libname L1 "%sysfunc(pathname(work))/L)1";
  libname L2 "%sysfunc(pathname(work))/L(2";
  libname L3 "%sysfunc(pathname(work))/L'3";

  data L1.TEST7 L2.TEST7 L3.TEST7;
    x=42;
  run;

  libname L12 ("%sysfunc(pathname(work))/L(1" "%sysfunc(pathname(work))/L)2");
  libname L1L2 (L2 L3);

  %put *%sysfunc(delDataset(L12.test7))*;
  %put *%sysfunc(delDataset(L1L2.test7))*;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

---

## >>> `qsortInCbyProcProto()` proto function: <<< <a name="qsortincbyprocproto-proto-function"></a> #######################  

The **qsortInCbyProcProto()** is external *C* function, 
this is the implementation of the *Quick Sort* algorithm. 

The function is used **internally** by 
functions in the *BasePlus* package.

Asumptions:
- smaller subarray is sorted first, 
- subarrays of *size < 11* are sorted by *insertion sort*, 
- pivot is selected as median of low index value, 
  high index value, and (low+high)/2 index value.

`!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!`<br>
`!CAUTION! Sorted array CANNOT contains SAS missing values !`<br>
`!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!`<br>

### SYNTAX: ###################################################################

The basic syntax is the following:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
qsortInCbyProcProto(arr, low, high)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Arguments description**:

1. `arr`  - An array of double type to be sorted.

2. `low`  - An integer low index of starting position (from which the sorting is done).

3. `high` - An integer high index of ending position (up to which the sorting is done).

 
### REFERENCES: ####################################################

*Reference 1.*

Insertion sort for arrays smaller then 11 elements: 

Based on the code from the following WikiBooks page [2020.08.14]:

[https://pl.wikibooks.org/wiki/Kody_%C5%BAr%C3%B3d%C5%82owe/Sortowanie_przez_wstawianie](https://pl.wikibooks.org/wiki/Kody_%C5%BAr%C3%B3d%C5%82owe/Sortowanie_przez_wstawianie)

 
*Reference 2.*

Iterative Quick Sort:  

Based on the code from the following pages [2020.08.14]:

[https://www.geeksforgeeks.org/iterative-quick-sort/](https://www.geeksforgeeks.org/iterative-quick-sort/)

[https://www.geeksforgeeks.org/c-program-for-iterative-quick-sort/](https://www.geeksforgeeks.org/c-program-for-iterative-quick-sort/)

---

## >>> `fromMissingToNumberBS()` function: <<< <a name="frommissingtonumberbs-function"></a> #######################  

The **fromMissingToNumberBS()** function 
gets numeric missing value or a number 
as an argument and returns an integer 
from 1 to 29.

For a numeric missing argument 
the returned values are:
- 1 for `._`
- 2 for `.`
- 3 for `.a`
-   ...
- 28 for `.z` and
- 29 for *all other*.

The function is used **internally** by 
functions in the *BasePlus* package.

For *missing value arguments* the function
is an inverse of the `fromNumberToMissing()` function.

### SYNTAX: ###################################################################

The basic syntax is the following, the `<...>` means optional parameters:
~~~~~~~~~~~~~~~~~~~~~~~sas
fromMissingToNumberBS(x)
~~~~~~~~~~~~~~~~~~~~~~~

**Arguments description**:

1. `x` - A numeric missing value or a number.

 
### EXAMPLES AND USECASES: ####################################################

**EXAMPLE 1.**
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  data _null_;
    do x = ._, ., .a, .b, .c, 42;
      y = fromMissingToNumberBS(x);
      put x= y=; 
    end;
  run;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

---

## >>> `fromNumberToMissing()` function: <<< <a name="fromnumbertomissing-function"></a> #######################  

The **fromNumberToMissing()** function 
gets a number as an argument and returns 
a numeric missing value or zero.

For a numeric argument 
the returned values are:
- `._` for 1
- `.`  for 2
- `.a` for 3
-   ...
- `.z` for 28 and
- `0`  for *all other*.

The function is used **internally** by 
functions in the *BasePlus* package.

For arguments 1,2,3, ..., and 28 the function
is an inverse of the `fromMissingToNumberBS()` function.

### SYNTAX: ###################################################################

The basic syntax is the following, the `<...>` means optional parameters:
~~~~~~~~~~~~~~~~~~~~~~~sas
fromNumberToMissing(x)
~~~~~~~~~~~~~~~~~~~~~~~

**Arguments description**:

1. `x` - A numeric value.

 
### EXAMPLES AND USECASES: ####################################################

**EXAMPLE 1.**
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  data _null_;
    do x = 1 to 29;
      y = fromNumberToMissing(x);
      put x= y=; 
    end;
  run;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

---
 
## >>> `quickSort4NotMiss()` subroutine: <<< <a name="quicksort4notmiss-subroutine"></a> #######################  

The **quickSort4NotMiss()** subroutine is an alternative to the 
`CALL SORTN()` subroutine for 1-based big arrays (i.e. `> 10'000'000` elements)
when memory used by `call sortn()` may be an issue.
For smaller arrays the memory footprint is not significant.

The subroutine is based on an iterative quick sort algorithm 
implemented in the `qsortInCbyProcProto()` *C* prototype function.


**Caution 1!** Array _CANNOT_ contains missing values!

**Caution 2!** Array parameters to subroutine calls must be 1-based.

### SYNTAX: ###################################################################

The basic syntax is the following, the `<...>` means optional parameters:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
call quickSort4NotMiss(A)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Arguments description**:

1. `A` - Argument is a 1-based array of NOT missing numeric values.

 
### EXAMPLES AND USECASES: ####################################################

**EXAMPLE 1.** For session with 8GB of RAM,
               array of size 250'000'000 with values in range 
               from 0 to 99'999'999 and _NO_ missing values.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %let size = 250000000;
  options fullstimer;

  data _null_;
    array test[&size.] _temporary_ ;

    t = time();
    call streaminit(123);
    do _N_ = &size. to 1 by -1;
      test[_N_] = int(100000000*rand("uniform"));
    end;
    t = time() - t;
    put "Array population time: "  t;

    put "First 50 elements before sorting:";
    do _N_ = 1 to 20;
      put test[_N_] = @;
    end;  

    t = time();
    call quickSort4NotMiss (test);
    t = time()-t;
    put "Sorting time: " / t=;

    put; put "First 50 elements after sorting:";
    do _N_ = 1 to 20;
      put test[_N_] = @;
    end;
  run;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


**Example 2.** Resources comparison for 
               session with 8GB of RAM.

  Array of size 250'000'000 with random values 
  from 0 to 999'999'999 and _NO_ missing values.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
    Array:
      Population time     8.82s
      memory              1'953'470.62k
      OS Memory           1'977'436.00k

    Call quickSort4NotMiss:
      Sorting time        66.92s
      Memory              1'954'683.06k
      OS Memory           1'977'436.00k

    Call quickSortLight:
      Sorting time        70.98s
      Memory              1'955'479.71k
      OS Memory           1'977'436.00k
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

---
 
## >>> `quickSortHash()` subroutine: <<< <a name="quicksorthash-subroutine"></a> #######################  

The **quickSortHash()** subroutine is an alternative to the 
`CALL SORTN()` subroutine for 1-based big arrays (i.e. `> 10'000'000` elements) 
when memory used by `call sortn()` may be an issue. 
For smaller arrays the memory footprint is not significant. 

The subroutine is based on an iterative quick sort algorithm 
implemented in the `qsortInCbyProcProto()` *C* prototype function.

The number of "sparse distinct data values" is set to `100'000` to 
use the hash sort instead of the quick sort.
  E.g. when number of unique values for sorting is less then 
  100'000 then an ordered hash table is used to store the data 
  and their count and sort them.

*Caution!* Array parameters to subroutine calls *must* be 1-based.

*Note!* Due to improper memory reporting/releasing for hash 
  tables in FCMP procedure the reported memory used after running 
  the function may not be in line with the RAM memory required 
  for processing.

### SYNTAX: ###################################################################

The basic syntax is the following, the `<...>` means optional parameters:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
call quickSortHash(A)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Arguments description**:

1. `A` - Argument is a 1-based array of numeric values.

 
### EXAMPLES AND USECASES: ####################################################

**EXAMPLE 1.** For session with 8GB of RAM
   Array of size 250'000'000 with values in range 
   from 0 to 99'999'999 and around 10% of various 
   missing values.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %let size = 250000000;
  options fullstimer;

  data _null_;
    array test[&size.] _temporary_ ;

    array m[0:27] _temporary_ 
      (._ .  .A .B .C .D .E .F .G .H .I .J .K .L 
       .M .N .O .P .Q .R .S .T .U .V .W .X .Y .Z);

    t = time();
    call streaminit(123);
    do _N_ = &size. to 1 by -1;
      _I_ + 1;
      if rand("uniform") > 0.1 then test[_I_] = int(100000000*rand("uniform"));
                               else test[_I_] = m[mod(_N_,28)];
    end;
    t = time() - t;
    put "Array population time: "  t;

    put "First 50 elements before sorting:";
    do _N_ = 1 to 20;
      put test[_N_] = @;
    end;  

    t = time();
    call quickSortHash (test);
    t = time()-t;
    put "Sorting time: " / t=;

    put; put "First 50 elements after sorting:";
    do _N_ = 1 to 20;
      put test[_N_] = @;
    end;
  run;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


**Example 2.** For session with 8GB of RAM
   Array of size 250'000'000 with values in range 
   from 0 to 9'999 and around 10% of various 
   missing values.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %let size = 250000000;
  options fullstimer;

  data _null_;
    array test[&size.] _temporary_ ;

    array m[0:27] _temporary_ 
      (._ .  .A .B .C .D .E .F .G .H .I .J .K .L 
       .M .N .O .P .Q .R .S .T .U .V .W .X .Y .Z);

    t = time();
    call streaminit(123);
    do _N_ = &size. to 1 by -1;
      _I_ + 1;
      if rand("uniform") > 0.1 then test[_I_] = int(10000*rand("uniform"));
                               else test[_I_] = m[mod(_N_,28)];
    end;
    t = time() - t;
    put "Array population time: "  t;

    put "First 50 elements before sorting:";
    do _N_ = 1 to 20;
      put test[_N_] = @;
    end;  

    t = time();
    call quickSortHash (test);
    t = time()-t;
    put "Sorting time: " / t=;

    put; put "First 50 elements after sorting:";
    do _N_ = 1 to 20;
      put test[_N_] = @;
    end;
  run;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


**Example 3.** Resources comparison for 
              session with 8GB of RAM

  A) Array of size 10'000'000 with 
     random values from 0 to 9'999 range (sparse)
     and around 10% of missing data.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
    Array:
      Population time     0.61s
      Memory              78'468.50k
      OS Memory           101'668.00k

    Call sortn:
      Sorting time        0.87s
      Memory              1'120'261.53k
      OS Memory           1'244'968.00k

    Call quickSortHash:
      Sorting time        6.76s
      Memory              1'222'242.75k(*)
      OS Memory           1'402'920.00k(*)

    Call quickSortLight:
      Sorting time        23.45s
      Memory              80'527.75k
      OS Memory           101'924.00k
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  B) Array of size 10'000'000 with 
     random values from 0 to 99'999'999 range (dense)
     and around 10% of missing data.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
    Array:
      Population time     0.6s
      Memory              78'463.65k
      OS Memory           101'924.00k

    Call sortn:
      Sorting time        1.51s
      Memory              1'120'253.53k
      OS Memory           1'244'968.00k

    Call quickSortHash:
      Sorting time        6.28s
      Memory              1'222'241.93k(*)
      OS Memory           1'402'920.00k(*)

    Call quickSortLight:
      Sorting time        0.78s
      Memory              80'669.28k
      OS Memory           102'436.00k
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  C) Array of size 250'000'000 with 
     random values from 0 to 999'999'999 range (dense)
     and around 10% of missing data.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
    Array:
      Population time     15.34s
      memory              1'953'471.81k
      OS Memory           1'977'436.00k

    Call sortn:
      FATAL: Insufficient memory to execute DATA step program. 
             Aborted during the COMPILATION phase.
      ERROR: The SAS System stopped processing this step 
             because of insufficient memory.

    Call quickSortHash:
      Sorting time        124.68s
      Memory              7'573'720.34k(*)
      OS Memory           8'388'448.00k(*)

    Call quickSortLight:
      Sorting time        72.41s
      Memory              1'955'520.78k
      OS Memory           1'977'180.00k
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  D) Array of size 250'000'000 with 
     random values from 0 to 99'999 range (sparse)
     and around 10% of missing data.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
    Array:
      Population time     16.07
      Memory              1'953'469.78k
      OS Memory           1'977'180.00k

    Call sortn:
      FATAL: Insufficient memory to execute DATA step program. 
             Aborted during the COMPILATION phase.
      ERROR: The SAS System stopped processing this step 
             because of insufficient memory.

    Call quickSortHash:
      Sorting time        123.5s
      Memory              7'573'722.03k
      OS Memory           8'388'448.00k

    Call quickSortLight:
      Sorting time        1'338.25s
      Memory              1'955'529.90k
      OS Memory           1'977'436.00k
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

(*) When using hash tables in `Proc FCMP` the RAM 
    usage is not indicated properly. The memory 
    allocation is reported up to the session limit
    and then reused if needed. The really required 
    memory is in fact much less then reported.

---
 
## >>> `quickSortHashSDDV()` subroutine: <<< <a name="quicksorthashsddv-subroutine"></a> #######################  

The **quickSortHashSDDV()** subroutine is an alternative to the 
`CALL SORTN()` subroutine for 1-based big arrays (i.e. `> 10'000'000` elements) 
when memory used by `call sortn()` may be an issue. 
For smaller arrays the memory footprint is not significant.

The subroutine is based on an iterative quick sort algorithm 
implemented in the `qsortInCbyProcProto()` *C* prototype function.

The number of "sparse distinct data values" (argument `SDDV`) may 
be adjusted to use the hash sort instead of the quick sort.
  E.g. when number of unique values for sorting is less then 
  some *N* then an ordered hash table is used to store the data 
  and their count and sort them.

*Caution!* Array parameters to subroutine calls *must* be 1-based.

*Note!* Due to improper memory reporting/releasing for hash 
  tables in FCMP procedure the report memory used after running 
  the function may not be in line with the RAM memory required 
  for processing.

### SYNTAX: ###################################################################

The basic syntax is the following, the `<...>` means optional parameters:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
call quickSortHashSDDV(A, SDDV)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Arguments description**:

1. `A`    - Argument is a 1-based array of numeric values.

2. `SDDV` - A number of distinct data values, e.g. 100'000.

 
### EXAMPLES AND USECASES: ####################################################

**EXAMPLE 1.** For session with 8GB of RAM
   Array of size 250'000'000 with values in range 
   from 0 to 99'999'999 and around 10% of various 
   missing values.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %let size = 250000000;
  options fullstimer;

  data _null_;
    array test[&size.] _temporary_ ;

    array m[0:27] _temporary_ 
      (._ .  .A .B .C .D .E .F .G .H .I .J .K .L 
       .M .N .O .P .Q .R .S .T .U .V .W .X .Y .Z);

    t = time();
    call streaminit(123);
    do _N_ = &size. to 1 by -1;
      _I_ + 1;
      if rand("uniform") > 0.1 then test[_I_] = int(100000000*rand("uniform"));
                               else test[_I_] = m[mod(_N_,28)];
    end;
    t = time() - t;
    put "Array population time: "  t;

    put "First 50 elements before sorting:";
    do _N_ = 1 to 20;
      put test[_N_] = @;
    end;  

    t = time();
    call quickSortHashSDDV (test, 2e4);
    t = time()-t;
    put "Sorting time: " / t=;

    put; put "First 50 elements after sorting:";
    do _N_ = 1 to 20;
      put test[_N_] = @;
    end;
  run;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


**Example 2.** For session with 8GB of RAM
   Array of size 250'000'000 with values in range 
   from 0 to 9'999 and around 10% of various 
   missing values.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %let size = 250000000;
  options fullstimer;

  data _null_;
    array test[&size.] _temporary_ ;

    array m[0:27] _temporary_ 
      (._ .  .A .B .C .D .E .F .G .H .I .J .K .L 
       .M .N .O .P .Q .R .S .T .U .V .W .X .Y .Z);

    t = time();
    call streaminit(123);
    do _N_ = &size. to 1 by -1;
      _I_ + 1;
      if rand("uniform") > 0.1 then test[_I_] = int(10000*rand("uniform"));
                               else test[_I_] = m[mod(_N_,28)];
    end;
    t = time() - t;
    put "Array population time: "  t;

    put "First 50 elements before sorting:";
    do _N_ = 1 to 20;
      put test[_N_] = @;
    end;  

    t = time();
    call quickSortHashSDDV (test, 2e4);
    t = time()-t;
    put "Sorting time: " / t=;

    put; put "First 50 elements after sorting:";
    do _N_ = 1 to 20;
      put test[_N_] = @;
    end;
  run;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

---
 
## >>> `quickSortLight()` subroutine: <<< <a name="quicksortlight-subroutine"></a> #######################  

The **quickSortLight()** subroutine is an alternative to the 
`CALL SORTN()` subroutine for 1-based big arrays (i.e. `> 10'000'000` elements) 
when memory used by `call sortn()` may be an issue. 
For smaller arrays the memory footprint is not significant. 

The subroutine is based on an iterative quick sort algorithm 
implemented in the `qsortInCbyProcProto()` *C* prototype function.

*Caution!* Array parameters to subroutine calls *must* be 1-based.

### SYNTAX: ###################################################################

The basic syntax is the following, the `<...>` means optional parameters:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
call quickSortLight(A)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Arguments description**:

1. `A` - Argument is a 1-based array of numeric values.

 
### EXAMPLES AND USECASES: ####################################################

**EXAMPLE 1.** For session with 8GB of RAM
   Array of size 250'000'000 with values in range 
   from 0 to 99'999'999 and around 10% of various 
   missing values.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %let size = 250000000;
  options fullstimer;

  data _null_;
    array test[&size.] _temporary_ ;

    array m[0:27] _temporary_ 
      (._ .  .A .B .C .D .E .F .G .H .I .J .K .L 
       .M .N .O .P .Q .R .S .T .U .V .W .X .Y .Z);

    t = time();
    call streaminit(123);
    do _N_ = &size. to 1 by -1;
      _I_ + 1;
      if rand("uniform") > 0.1 then test[_I_] = int(100000000*rand("uniform"));
                               else test[_I_] = m[mod(_N_,28)];
    end;
    t = time() - t;
    put "Array population time: "  t;

    put "First 50 elements before sorting:";
    do _N_ = 1 to 20;
      put test[_N_] = @;
    end;  

    t = time();
    call quickSortLight (test);
    t = time()-t;
    put "Sorting time: " / t=;

    put; put "First 50 elements after sorting:";
    do _N_ = 1 to 20;
      put test[_N_] = @;
    end;
  run;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


**Example 2.** Resources comparison for 
               session with 8GB of RAM.

  Array of size 250'000'000 with random values 
  from 0 to 999'999'999 and _NO_ missing values.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
    Array:
      Population time     8.82s
      memory              1'953'470.62k
      OS Memory           1'977'436.00k

    Call quickSort4NotMiss:
      Sorting time        66.92s
      Memory              1'954'683.06k
      OS Memory           1'977'436.00k

    Call quickSortLight:
      Sorting time        70.98s
      Memory              1'955'479.71k
      OS Memory           1'977'436.00k
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Example 3.** Resources comparison for 
               session with 8GB of RAM

  A) Array of size 10'000'000 with 
     random values from 0 to 9'999 range (sparse)
     and around 10% of missing data.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
    Array:
      Population time     0.61s
      Memory              78'468.50k
      OS Memory           101'668.00k

    Call sortn:
      Sorting time        0.87s
      Memory              1'120'261.53k
      OS Memory           1'244'968.00k

    Call quickSortHash:
      Sorting time        6.76s
      Memory              1'222'242.75k(*)
      OS Memory           1'402'920.00k(*)

    Call quickSortLight:
      Sorting time        23.45s
      Memory              80'527.75k
      OS Memory           101'924.00k
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  B) Array of size 10'000'000 with 
     random values from 0 to 99'999'999 range (dense)
     and around 10% of missing data.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
    Array:
      Population time     0.6s
      Memory              78'463.65k
      OS Memory           101'924.00k

    Call sortn:
      Sorting time        1.51s
      Memory              1'120'253.53k
      OS Memory           1'244'968.00k

    Call quickSortHash:
      Sorting time        6.28s
      Memory              1'222'241.93k(*)
      OS Memory           1'402'920.00k(*)

    Call quickSortLight:
      Sorting time        0.78s
      Memory              80'669.28k
      OS Memory           102'436.00k
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  C) Array of size 250'000'000 with 
     random values from 0 to 999'999'999 range (dense)
     and around 10% of missing data.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
    Array:
      Population time     15.34s
      memory              1'953'471.81k
      OS Memory           1'977'436.00k

    Call sortn:
      FATAL: Insufficient memory to execute DATA step program. 
             Aborted during the COMPILATION phase.
      ERROR: The SAS System stopped processing this step 
             because of insufficient memory.

    Call quickSortHash:
      Sorting time        124.68s
      Memory              7'573'720.34k(*)
      OS Memory           8'388'448.00k(*)

    Call quickSortLight:
      Sorting time        72.41s
      Memory              1'955'520.78k
      OS Memory           1'977'180.00k
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  D) Array of size 250'000'000 with 
     random values from 0 to 99'999 range (sparse)
     and around 10% of missing data.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
    Array:
      Population time     16.07
      Memory              1'953'469.78k
      OS Memory           1'977'180.00k

    Call sortn:
      FATAL: Insufficient memory to execute DATA step program. 
             Aborted during the COMPILATION phase.
      ERROR: The SAS System stopped processing this step 
             because of insufficient memory.

    Call quickSortHash:
      Sorting time        123.5s
      Memory              7'573'722.03k
      OS Memory           8'388'448.00k

    Call quickSortLight:
      Sorting time        1'338.25s
      Memory              1'955'529.90k
      OS Memory           1'977'436.00k
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

(*) When using hash tables in `Proc FCMP` the RAM 
    usage is not indicated properly. The memory 
    allocation is reported up to the session limit
    and then reused if needed. The really required 
    memory is in fact much less then reported.

---

## >>> `%dedupListS()` macro: <<< <a name="deduplists-macro"></a> #######################

The `%dedupListS()` macro deletes duplicated values from 
a *SPACE separated* list of values. List, including separators,
can be no longer than a value carried by a single macrovariable.

Returned value is *unquoted*.

The `%dedupListS()` macro executes like a pure macro code.

### SYNTAX: ###################################################################

The basic syntax is the following, the `<...>` means optional parameters:
~~~~~~~~~~~~~~~~~~~~~~~sas
%dedupListS(
 list of space separated values
)
~~~~~~~~~~~~~~~~~~~~~~~

**Arguments description**:

1. `list` - A list of *space separated* values. 

 
### EXAMPLES AND USECASES: ####################################################

**EXAMPLE 1.** Basic use-case one. 
    Delete duplicated values from a list.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %put *%dedupListS(a b  c   b    c)*;

  %put *%dedupListS(a b,c b,c)*;

  %put *%dedupListS(%str(a b c b c))*;

  %put *%dedupListS(%str(a) %str(b) %str(c) b c)*;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**EXAMPLE 2.** Macro variable as an argument. 
    Delete duplicated values from a list.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %let list = 4 5 6 1 2 3 1 2 3 4 5 6;
  %put *%dedupListS(&list.)*;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

---

## >>> `%dedupListC()` macro: <<< <a name="deduplistc-macro"></a> #######################

The `%dedupListC()` macro deletes duplicated values from 
a *COMMA separated* list of values. List, including separators,
can be no longer than a value carried by a single macrovariable.

Returned value is *unquoted*. Leading and trailing spaces are ignored.

The `%dedupListC()` macro executes like a pure macro code.

### SYNTAX: ###################################################################

The basic syntax is the following, the `<...>` means optional parameters:
~~~~~~~~~~~~~~~~~~~~~~~sas
%dedupListC(
 list,of,comma,separated,values
)
~~~~~~~~~~~~~~~~~~~~~~~

**Arguments description**:

1. `list` - A list of *comma separated* values. 

 
### EXAMPLES AND USECASES: ####################################################

**EXAMPLE 1.** Basic use-case one. 
    Delete duplicated values from a list.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %put *%dedupListC(a,b,c,b,c)*;

  %put *%dedupListC(a,b c,b c)*;

  %put *%dedupListC(%str(a,b,c,b,c))*;

  %put *%dedupListC(%str(a),%str(b),%str(c),b,c)*;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**EXAMPLE 2.** Leading and trailing spaces are ignored. 
    Delete duplicated values from a list.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %put *%dedupListC( a , b b ,  c , b b, c    )*;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**EXAMPLE 3.** Macro variable as an argument. 
    Delete duplicated values from a list.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %let list = 4, 5, 6, 1, 2, 3, 1, 2, 3, 4, 5, 6;
  %put *%dedupListC(&list.)*;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

---

## >>> `%dedupListP()` macro: <<< <a name="deduplistp-macro"></a> #######################

The `%dedupListP()` macro deletes duplicated values from 
a *PIPE(`|`) separated* list of values. List, including separators,
can be no longer than a value carried by a single macrovariable.

Returned value is *unquoted*. Leading and trailing spaces are ignored.

The `%dedupListP()` macro executes like a pure macro code.

### SYNTAX: ###################################################################

The basic syntax is the following, the `<...>` means optional parameters:
~~~~~~~~~~~~~~~~~~~~~~~sas
%dedupListP(
 list|of|pipe|separated|values
)
~~~~~~~~~~~~~~~~~~~~~~~

**Arguments description**:

1. `list` - A list of *pipe separated* values. 

 
### EXAMPLES AND USECASES: ####################################################

**EXAMPLE 1.** Basic use-case one. 
    Delete duplicated values from a list.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %put *%dedupListP(a|b|c|b|c)*;

  %put *%dedupListP(a|b c|b c)*;

  %put *%dedupListP(%str(a|b|c|b|c))*;

  %put *%dedupListP(%str(a)|%str(b)|%str(c)|b|c)*;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**EXAMPLE 2.** Leading and trailing spaces are ignored. 
    Delete duplicated values from a list.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %put *%dedupListP( a | b b |  c | b b| c    )*;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**EXAMPLE 3.** Macro variable as an argument. 
    Delete duplicated values from a list.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %let list = 4|5|6|1|2|3|1|2|3|4|5|6;
  %put *%dedupListP(&list.)*;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

---

## >>> `%dedupListX()` macro: <<< <a name="deduplistx-macro"></a> #######################

The `%dedupListX()` macro deletes duplicated values from 
a *X separated* list of values, where the `X` represents 
a *single character* separator. List, including separators, 
can be no longer than a value carried by a single macrovariable.

**Caution.** The value of `X` *has to be* in **the first** byte of the list,
             just after the opening bracket, i.e. `(X...)`.

Returned value is *unquoted*. Leading and trailing spaces are ignored.

The `%dedupListX()` macro executes like a pure macro code.

### SYNTAX: ###################################################################

The basic syntax is the following, the `<...>` means optional parameters:
~~~~~~~~~~~~~~~~~~~~~~~sas
%dedupListX(
XlistXofXxXseparatedXvalues
)
~~~~~~~~~~~~~~~~~~~~~~~

**Arguments description**:

1. `list` - A list of *X separated* values. 

 
### EXAMPLES AND USECASES: ####################################################

**EXAMPLE 1.** Basic use-case one. 
    Delete duplicated values from a list.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %put *%dedupListX(|a|b|c|b|c)*;

  %put *%dedupListX( a b c b c)*;

  %put *%dedupListX(,a,b,c,b,c)*;

  %put *%dedupListX(XaXbXcXbXc)*;

  %put *%dedupListX(/a/b/c/b/c)*;

  data _null_;
    x = "%dedupListX(%str(;a;b;c;b;c))";
    put x=;
  run;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**EXAMPLE 2.** Leading and trailing spaces are ignored. 
    Delete duplicated values from a list.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %put *%dedupListX(| a | b.b |  c | b.b| c    )*;

  %put *%dedupListX(. a . b b .  c . b b. c    )*;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**EXAMPLE 3.** Macro variable as an argument. 
    Delete duplicated values from a list.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %let list = 4$5.5$6$1$2$3$1$2$3$4$5.5$6;
  %put *%dedupListX($&list.)*;

  %let list = 4$ 5.5$ 6$ 1$ 2$ 3$ 1$ 2$ 3$ 4$ 5.5$ 6$;
  %put *%dedupListX( &list.)*;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

---

## >>> `%QdedupListX()` macro: <<< <a name="qdeduplistx-macro"></a> #######################

The `%QdedupListX()` macro deletes duplicated values from 
a *X separated* list of values, where the `X` represents 
a *single character* separator. List, including separators, 
can be no longer than a value carried by a single macrovariable.

**Caution.** The value of `X` *has to be* in **the first** byte of the list,
             just after the opening bracket, i.e. `(X...)`.

Returned value is **quoted** with `%superq()`. Leading and trailing spaces are ignored.

The `%QdedupListX()` macro executes like a pure macro code.

### SYNTAX: ###################################################################

The basic syntax is the following, the `<...>` means optional parameters:
~~~~~~~~~~~~~~~~~~~~~~~sas
%QdedupListX(
XlistXofXxXseparatedXvalues
)
~~~~~~~~~~~~~~~~~~~~~~~

**Arguments description**:

1. `list` - A list of *X separated* values. 

 
### EXAMPLES AND USECASES: ####################################################

**EXAMPLE 1.** Basic use-case one. 
    Delete duplicated values from a list.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %put *%QdedupListX(|a|b|c|b|c)*;

  %put *%QdedupListX( a b c b c)*;

  %put *%QdedupListX(,a,b,c,b,c)*;

  %put *%QdedupListX(XaXbXcXbXc)*;

  %put *%QdedupListX(/a/b/c/b/c)*;

  %put *%QdedupListX(%str(;a;b;c;b;c))*;

  %put *%QdedupListX(%nrstr(&a&b&c&b&c))*;

  %put *%QdedupListX(%nrstr(%a%b%c%b%c))*;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**EXAMPLE 2.** Leading and trailing spaces are ignored. 
    Delete duplicated values from a list.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %put *%QdedupListX(| a | b.b |  c | b.b| c    )*;

  %put *%QdedupListX(. a . b b .  c . b b. c    )*;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**EXAMPLE 3.** Macro variable as an argument. 
    Delete duplicated values from a list.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %let list = 4$5.5$6$1$2$3$1$2$3$4$5.5$6;
  %put *%QdedupListX($&list.)*;

  %let list = 4$ 5.5$ 6$ 1$ 2$ 3$ 1$ 2$ 3$ 4$ 5.5$ 6$;
  %put *%QdedupListX( &list.)*;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

---

## License ####################################################################

Copyright (c) 2020 Bartosz Jablonski

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

---
