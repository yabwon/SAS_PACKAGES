/*** HELP START ***/     

/**############################################################################**/
/*                                                                              */
/*  Copyright Bartosz Jablonski, July 2019.                                     */
/*                                                                              */
/*  Code is free and open source. If you want - you can use it.                 */
/*  I tested it the best I could                                                */
/*  but it comes with absolutely no warranty whatsoever.                        */
/*  If you cause any damage or something - it will be your own fault.           */
/*  You've been warned! You are using it on your own risk.                      */
/*  However, if you decide to use it don't forget to mention author:            */
/*  Bartosz Jablonski (yabwon@gmail.com)                                        */
/*                                                                              */
/*  Here is the official version:                                               */
/*
  Copyright (c) 2019 Bartosz Jablonski (yabwon@gmail.com)

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included 
  in all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.
                                                                                 */
/**#############################################################################**/

/* Macros to load or to unload SAS packages */
/* A SAS package is a zip file containing a group 
   of SAS codes (macros, functions, datasteps generating 
   data, etc.) wrapped up together and %INCLUDEed by
   a single load.sas file (also embedded inside the zip).
*/
/*
TODO:
- macro for testing available packages in the packages' folder [DONE] checkout: %listPackages()
- add MD5(&packageName.) value hash instead "package" word in filenames [DONE]
*/
/*** HELP END ***/

/*** HELP START ***/

%macro loadPackage(
  packageName                         /* name of a package, 
                                         e.g. myPackageFile.zip, 
                                         required and not null  */
, path = %sysfunc(pathname(packages)) /* location of a package, 
                                         by default it looks for 
                                         location of "packages" fileref */
, options = %str(LOWCASE_MEMNAME)     /* possible options for ZIP filename */
, source2 = /*source2*/               /* option to print out details, 
                                         null by default */
, requiredVersion = .                 /* option to test if loaded package 
                                         is provided in required version */
, lazyData =                          /* a list of names of a lazy datasets 
                                         to be loaded, if not null then
                                         datasets from the list are loaded
                                         instead of a package, asterisk 
                                         means "load all datasets" */
)/secure minoperator;
/*** HELP END ***/
  %local ls_tmp ps_tmp notes_tmp source_tmp fullstimer_tmp stimer_tmp;
  %let ls_tmp     = %sysfunc(getoption(ls));      
  %let ps_tmp     = %sysfunc(getoption(ps));      
  %let notes_tmp  = %sysfunc(getoption(notes));   
  %let source_tmp = %sysfunc(getoption(source));
  %let stimer_tmp = %sysfunc(getoption(stimer));
  %let fullstimer_tmp = %sysfunc(getoption(fullstimer)); 
  options NOnotes NOsource ls=MAX ps=MAX NOfullstimer NOstimer;
  %local _PackageFileref_;
  %let _PackageFileref_ = P%sysfunc(MD5(%lowcase(&packageName.)),hex7.);

  filename &_PackageFileref_. ZIP 
  /* put location of package myPackageFile.zip here */
    "&path./%lowcase(&packageName.).zip" %unquote(&options.)
  ;
  %if %sysfunc(fexist(&_PackageFileref_.)) %then
    %do;
      %include &_PackageFileref_.(packagemetadata.sas) / &source2.;
      filename &_PackageFileref_. clear;

      /* test if required version of package is "good enough" */
      %if %sysevalf(&requiredVersion. > &packageVersion.) %then
        %do;
          %put ERROR: Required version is &requiredVersion.;
          %put ERROR- Provided version is &packageVersion.;
          %ABORT;
        %end;

      options ls = &ls_tmp. ps = &ps_tmp. &notes_tmp. &source_tmp.;
      filename &_PackageFileref_. ZIP 
        "&path./%lowcase(&packageName.).zip" %unquote(&options.)  
        ENCODING =
          %if %bquote(&packageEncoding.) NE %then &packageEncoding. ;
                                            %else utf8 ;
      ;
      %if %bquote(&lazyData.) = %then
        %do;
          %include &_PackageFileref_.(load.sas) / &source2.;
        %end;
      %else
        %do;
          %include &_PackageFileref_.(lazydata.sas) / &source2.;
        %end;

    %end;
  %else %put ERROR:[&sysmacroname] File "&path./&packageName..zip" does not exist;
  filename &_PackageFileref_. clear;
  options ls = &ls_tmp. ps = &ps_tmp. 
          &notes_tmp. &source_tmp. 
          &stimer_tmp. &fullstimer_tmp.;
%mend loadPackage;

/*** HELP START ***/

%macro unloadPackage(
  packageName                         /* name of a package, 
                                         e.g. myPackageFile.zip, 
                                         required and not null  */
, path = %sysfunc(pathname(packages)) /* location of a package, 
                                         by default it looks for 
                                         location of "packages" fileref */
, options = %str(LOWCASE_MEMNAME)     /* possible options for ZIP filename */
, source2 = /*source2*/               /* option to print out details, 
                                         null by default */
)/secure;
/*** HELP END ***/
  %local ls_tmp ps_tmp notes_tmp source_tmp;
  %let ls_tmp     = %sysfunc(getoption(ls));      
  %let ps_tmp     = %sysfunc(getoption(ps));      
  %let notes_tmp  = %sysfunc(getoption(notes));   
  %let source_tmp = %sysfunc(getoption(source));  
  options NOnotes NOsource ls=MAX ps=MAX;
  %local _PackageFileref_;
  %let _PackageFileref_ = P%sysfunc(MD5(%lowcase(&packageName.)),hex7.);

  filename &_PackageFileref_. ZIP 
  /* put location of package myPackageFile.zip here */
    "&path./%lowcase(&packageName.).zip" %unquote(&options.)
  ;
  %if %sysfunc(fexist(&_PackageFileref_.)) %then
    %do;
      %include &_PackageFileref_.(packagemetadata.sas) / &source2.;
      filename &_PackageFileref_. clear;
      options ls = &ls_tmp. ps = &ps_tmp. &notes_tmp. &source_tmp.;
      filename &_PackageFileref_. ZIP 
        "&path./%lowcase(&packageName.).zip" %unquote(&options.)  
        ENCODING =
          %if %bquote(&packageEncoding.) NE %then &packageEncoding. ;
                                            %else utf8 ;
      ;
      %include &_PackageFileref_.(unload.sas) / &source2.;
    %end;
  %else %put ERROR:[&sysmacroname] File "&path./&packageName..zip" does not exist;
  filename &_PackageFileref_. clear;
  options ls = &ls_tmp. ps = &ps_tmp. &notes_tmp. &source_tmp.;
%mend unloadPackage;

/*** HELP START ***/

%macro helpPackage(
  packageName                         /* name of a package, 
                                         e.g. myPackageFile.zip, 
                                         required and not null  */
, helpKeyword                         /* phrase to search in help,
                                         when empty prints description 
                                         "*" means prints all help 
                                         "license" prints license */
, path = %sysfunc(pathname(packages)) /* location of a package, 
                                         by default it looks for 
                                         location of "packages" fileref */
, options = %str(LOWCASE_MEMNAME)     /* possible options for ZIP filename */
, source2 = /*source2*/               /* option to print out details, 
                                         null by default */
)/secure;
/*** HELP END ***/
  %local ls_tmp ps_tmp notes_tmp source_tmp;
  %let ls_tmp     = %sysfunc(getoption(ls));      
  %let ps_tmp     = %sysfunc(getoption(ps));      
  %let notes_tmp  = %sysfunc(getoption(notes));   
  %let source_tmp = %sysfunc(getoption(source));  
  options NOnotes NOsource ls=MAX ps=MAX;
  %local _PackageFileref_;
  %let _PackageFileref_ = P%sysfunc(MD5(%lowcase(&packageName.)),hex7.);

  filename &_PackageFileref_. ZIP 
  /* put location of package myPackageFile.zip here */
    "&path./%lowcase(&packageName.).zip" %unquote(&options.)
  ;
  %if %sysfunc(fexist(&_PackageFileref_.)) %then
    %do;
      %include &_PackageFileref_.(packagemetadata.sas) / &source2.;
      filename &_PackageFileref_. clear;
      options ls = &ls_tmp. ps = &ps_tmp. &notes_tmp. &source_tmp.;
      filename &_PackageFileref_. ZIP 
        "&path./%lowcase(&packageName.).zip" %unquote(&options.) 
        ENCODING =
          %if %bquote(&packageEncoding.) NE %then &packageEncoding. ;
                                            %else utf8 ;
      ;
      %include &_PackageFileref_.(help.sas) / &source2.;
    %end;
  %else %put ERROR:[&sysmacroname] File "&path./&packageName..zip" does not exist;
  filename &_PackageFileref_. clear;
  options ls = &ls_tmp. ps = &ps_tmp. &notes_tmp. &source_tmp.;
%mend helpPackage;


/*** HELP START ***/

/* 
 * Filenames references "packages" and "package" are keywords;
 * the first one should be used to point folder with packages;
 * the second is used internally by macros;

 * Example 1: 
 * assuming that _THIS_FILE_ and the SQLinDS package (sqlinds.zip file)
 * are located in the "C:/SAS_PACKAGES/" folder 
 * copy the following code into autoexec.sas
 * or run it in your SAS session
**/
/*

filename packages "C:/SAS_PACKAGES";
%include packages(loadpackage.sas);

%loadpackage(SQLinDS)
%helpPackage(SQLinDS)
%unloadPackage(SQLinDS)

optional:

libname packages "C:/SAS_PACKAGES/";
%include "%sysfunc(pathname(packages))/loadpackage.sas";

%loadPackage(SQLinDS)
%helpPackage(SQLinDS)
%unloadPackage(SQLinDS)

*/
/*** HELP END ***/
