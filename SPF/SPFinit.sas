/**############################################################################**/
/*                                                                              */
/*  Copyright Bartosz Jablonski, since July 2019.                               */
/*                                                                              */
/*  Code is free and open source. If you want - you can use it.                 */
/*  I tested it the best I could                                                */
/*  but it comes with absolutely no warranty whatsoever.                        */
/*  If you cause any damage or something - it will be your own fault.           */
/*  You have been warned! You are using it on your own risk.                    */
/*  However, if you decide to use it do not forget to mention author:           */
/*  Bartosz Jablonski (yabwon@gmail.com)                                        */
/*                                                                              */
/*  Here is the official version:                                               */
/*
  Copyright (c) 2019 - 2020 Bartosz Jablonski (yabwon@gmail.com)

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

/*** HELP START ***/
/* SPF (SAS Packages Framework) is a set of macros: 
   - to install, 
   - to load, 
   - to get help,  
   - to unload, or
   - to generate SAS packages.

  Version 20200730.
  See examples below.

   A SAS package is a zip file containing a group of files
   with SAS code (macros, functions, datasteps generating 
   data, etc.) wrapped up together and %INCLUDEed by
   a single load.sas file (also embedded inside the zip).
*/

/*** HELP END ***/

/*** HELP START ***/

%macro loadPackage(
  packageName                         /* name of a package, 
                                         e.g. myPackage, 
                                         required and not null  */
, path = %sysfunc(pathname(packages)) /* location of a package, 
                                         by default it looks for 
                                         location of "packages" fileref */
, options = %str(LOWCASE_MEMNAME)     /* posible options for ZIP filename */
, source2 = /*source2*/               /* option to print out details, 
                                         null by default */
, requiredVersion = .                 /* option to test if loaded package 
                                         is provided in required version */
, lazyData =                          /* a list of names of lazy datasets 
                                         to be loaded, if not null then
                                         datasets from the list are loaded
                                         instead of a package, asterisk 
                                         means "load all datasets" */
, zip = zip                           /* standard package is zip (lowcase), 
                                         e.g. %loadPackage(PiPackage)
                                         if the zip is not avaliable use a folder
                                         unpack data to "pipackage.disk" folder
                                         and use loadPackage in the form: 
                                         %loadPackage(PiPackage, zip=disk, options=) 
                                       */
)/secure 
/*** HELP END ***/
des = 'Macro to load SAS package, version 20200730. Run %loadPackage() for help info.'
;
%if %superq(packageName) = %then
  %do;
    %put ;
    %put ###############################################################################;
    %put #        This is short help information for the loadPackage macro             #;
    %put ###############################################################################;
    %put #                                                                             #;
    %put # Macro to load SAS packages, version 20200730                                #;
    %put #                                                                             #;
    %put # A SAS package is a zip file containing a group                              #;
    %put # of SAS codes (macros, functions, datasteps generating                       #;
    %put # data, etc.) wrapped up together and included by                             #;
    %put # a single load.sas file (also embedded inside the zip).                      #;
    %put #                                                                             #;
    %put # Parameters:                                                                 #;
    %put #                                                                             #;
    %put #  packageName        Name of a package, e.g. myPackage,                      #;
    %put #                     Required and not null, default use case:                #;
    %put #                      %nrstr(%%loadPackage(myPackage)).                               #;
    %put #                     If empty displays this help information.                #;
    %put #                                                                             #;
    %put #  path=              Location of a package. By default it looks for          #;
    %put #                     location of the "packages" fileref, i.e.                #;
    %put #                      %nrstr(%%sysfunc(pathname(packages)))                           #;
    %put #                                                                             #;
    %put #  options=           Posible options for ZIP filename,                       #;
    %put #                     default value: LOWCASE_MEMNAME                          #;
    %put #                                                                             #;
    %put #  source2=           Option to print out details, null by default.           #;
    %put #                                                                             #;
    %put #  requiredVersion=   Option to test if the loaded package                    #;
    %put #                     is provided in required version,                        #;
    %put #                     default value: .                                        #;
    %put #                                                                             #;
    %put #  lazyData=          A list of names of lazy datasets to be loaded.          #;
    %put #                     If not null datasets from the list are loaded           #;
    %put #                     instead of the package.                                 #;
    %put #                     Asterisk (*) means "load all datasets".                 #;
    %put #                                                                             #;
    %put #  zip=zip            Standard package is zip (lowcase),                      #;
    %put #                     e.g. %nrstr(%%loadPackage(PiPackage)).                           #;
    %put #                     If the zip is not avaliable use a folder.               #;
    %put #                     Unpack data to "pipackage.disk" folder                  #;
    %put #                     and use loadPackage in the following form:              #;
    %put #                      %nrstr(%%loadPackage(PiPackage, zip=disk, options=))            #;
    %put #                                                                             #;
    %put ###############################################################################;
    %put ;
    %GOTO ENDloadPackage;
  %end;
  %local ls_tmp ps_tmp notes_tmp source_tmp fullstimer_tmp stimer_tmp msglevel_tmp;
  %let ls_tmp     = %sysfunc(getoption(ls));      
  %let ps_tmp     = %sysfunc(getoption(ps));      
  %let notes_tmp  = %sysfunc(getoption(notes));   
  %let source_tmp = %sysfunc(getoption(source));
  %let stimer_tmp = %sysfunc(getoption(stimer));
  %let fullstimer_tmp = %sysfunc(getoption(fullstimer)); 
  %let msglevel_tmp = %sysfunc(getoption(msglevel));  
  options NOnotes NOsource ls=MAX ps=MAX NOfullstimer NOstimer msglevel=N;
  %local _PackageFileref_;
  %let _PackageFileref_ = P%sysfunc(MD5(%lowcase(&packageName.)),hex7.);

  filename &_PackageFileref_. &ZIP. 
  /* put location of package myPackageFile.zip here */
    "&path./%lowcase(&packageName.).&zip." %unquote(&options.)
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
      filename &_PackageFileref_. &ZIP. 
        "&path./%lowcase(&packageName.).&zip." %unquote(&options.)  
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
  %else %put ERROR:[&sysmacroname] File "&path./&packageName..&zip." does not exist;
  filename &_PackageFileref_. clear;
  options ls = &ls_tmp. ps = &ps_tmp. 
          &notes_tmp. &source_tmp. 
          &stimer_tmp. &fullstimer_tmp.
          msglevel=&msglevel_tmp.;

/* jump here after running %loadPackage() - only help is displayed */
%ENDloadPackage:
%mend loadPackage;

/*** HELP START ***/

%macro unloadPackage(
  packageName                         /* name of a package, 
                                         e.g. myPackage, 
                                         required and not null  */
, path = %sysfunc(pathname(packages)) /* location of a package, 
                                         by default it looks for 
                                         location of "packages" fileref */
, options = %str(LOWCASE_MEMNAME)     /* possible options for ZIP filename */
, source2 = /*source2*/               /* option to print out details, 
                                         null by default */
, zip = zip                           /* standard package is zip (lowcase), 
                                         e.g. %unloadPackage(PiPackage)
                                         if the zip is not avaliable use a folder
                                         unpack data to "pipackage.disk" folder
                                         and use unloadPackage in the form: 
                                         %unloadPackage(PiPackage, zip=disk, options=) 
                                       */
)/secure
/*** HELP END ***/
des = 'Macro to unload SAS package, version 20200730. Run %unloadPackage() for help info.'
;
%if %superq(packageName) = %then
  %do;
    %put ;
    %put ###############################################################################;
    %put #        This is short help information for the unloadPackage macro           #;
    %put ###############################################################################;
    %put #                                                                             #;
    %put # Macro to unload SAS packages, version 20200730                              #;
    %put #                                                                             #;
    %put # A SAS package is a zip file containing a group                              #;
    %put # of SAS codes (macros, functions, datasteps generating                       #;
    %put # data, etc.) wrapped up together and included by                             #;
    %put # a single load.sas file (also embedded inside the zip).                      #;
    %put #                                                                             #;
    %put # Parameters:                                                                 #;
    %put #                                                                             #;
    %put #  packageName        Name of a package, e.g. myPackage,                      #;
    %put #                     Required and not null, default use case:                #;
    %put #                      %nrstr(%%unloadPackage(myPackage)).                             #;
    %put #                     If empty displays this help information.                #;
    %put #                                                                             #;
    %put #  path=              Location of a package. By default it looks for          #;
    %put #                     location of the "packages" fileref, i.e.                #;
    %put #                      %nrstr(%%sysfunc(pathname(packages)))                           #;
    %put #                                                                             #;
    %put #  options=           Posible options for ZIP filename,                       #;
    %put #                     default value: LOWCASE_MEMNAME                          #;
    %put #                                                                             #;
    %put #  source2=           Option to print out details, null by default.           #;
    %put #                                                                             #;
    %put #  zip=zip            Standard package is zip (lowcase),                      #;
    %put #                     e.g. %nrstr(%%unloadPackage(PiPackage)).                         #;
    %put #                     If the zip is not avaliable use a folder.               #;
    %put #                     Unpack data to "pipackage.disk" folder                  #;
    %put #                     and use loadPackage in the following form:              #;
    %put #                      %nrstr(%%unloadPackage(PiPackage, zip=disk, options=))          #;
    %put #                                                                             #;
    %put ###############################################################################;
    %put ;
    %GOTO ENDunloadPackage;
  %end;
  %local ls_tmp ps_tmp notes_tmp source_tmp msglevel_tmp;
  %let ls_tmp     = %sysfunc(getoption(ls));      
  %let ps_tmp     = %sysfunc(getoption(ps));      
  %let notes_tmp  = %sysfunc(getoption(notes));   
  %let source_tmp = %sysfunc(getoption(source));
  %let msglevel_tmp = %sysfunc(getoption(msglevel)); 
  options NOnotes NOsource ls=MAX ps=MAX msglevel=N;
  %local _PackageFileref_;
  %let _PackageFileref_ = P%sysfunc(MD5(%lowcase(&packageName.)),hex7.);

  filename &_PackageFileref_. &ZIP. 
  /* put location of package myPackageFile.zip here */
    "&path./%lowcase(&packageName.).&zip." %unquote(&options.)
  ;
  %if %sysfunc(fexist(&_PackageFileref_.)) %then
    %do;
      %include &_PackageFileref_.(packagemetadata.sas) / &source2.;
      filename &_PackageFileref_. clear;
      options ls = &ls_tmp. ps = &ps_tmp. &notes_tmp. &source_tmp.;
      filename &_PackageFileref_. &ZIP. 
        "&path./%lowcase(&packageName.).&zip." %unquote(&options.)  
        ENCODING =
          %if %bquote(&packageEncoding.) NE %then &packageEncoding. ;
                                            %else utf8 ;
      ;
      %include &_PackageFileref_.(unload.sas) / &source2.;
    %end;
  %else %put ERROR:[&sysmacroname] File "&path./&packageName..&zip." does not exist;
  filename &_PackageFileref_. clear;
  options ls = &ls_tmp. ps = &ps_tmp. &notes_tmp. &source_tmp. msglevel = &msglevel_tmp.;
/* jump here after running %unloadPackage() - only help is displayed */
%ENDunloadPackage:
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
, zip = zip                           /* standard package is zip (lowcase), 
                                         e.g. %helpPackage(PiPackage,*)
                                         if the zip is not avaliable use a folder
                                         unpack data to "pipackage.disk" folder
                                         and use helpPackage in the form: 
                                         %helpPackage(PiPackage, *, zip=disk, options=) 
                                       */
)/secure
/*** HELP END ***/
des = 'Macro to get help about SAS package, version 20200730. Run %helpPackage() for help info.'
;
%if %superq(packageName) = %then
  %do;
    %put ;
    %put ###############################################################################;
    %put #        This is short help information for the helpPackage macro             #;
    %put ###############################################################################;
    %put #                                                                             #;
    %put # Macro to get help about SAS packages, version 20200730                      #;
    %put #                                                                             #;
    %put # A SAS package is a zip file containing a group                              #;
    %put # of SAS codes (macros, functions, datasteps generating                       #;
    %put # data, etc.) wrapped up together and included by                             #;
    %put # a single load.sas file (also embedded inside the zip).                      #;
    %put #                                                                             #;
    %put # Parameters:                                                                 #;
    %put #                                                                             #;
    %put #  packageName        Name of a package, e.g. myPackage,                      #;
    %put #                     Required and not null, default use case:                #;
    %put #                      %nrstr(%%helpPackage(myPackage)).                               #;
    %put #                     If empty displays this help information.                #;
    %put #                                                                             #;
    %put #  helpKeyword        Phrase to search in help,                               #;
    %put #                     - when empty prints description,                        #;
    %put #                     - "*"  means prints all help,                           #;
    %put #                     - "license"  prints license.                            #;
    %put #                                                                             #;
    %put #  path=              Location of a package. By default it looks for          #;
    %put #                     location of the "packages" fileref, i.e.                #;
    %put #                      %nrstr(%%sysfunc(pathname(packages)))                           #;
    %put #                                                                             #;
    %put #  options=           Posible options for ZIP filename,                       #;
    %put #                     default value: LOWCASE_MEMNAME                          #;
    %put #                                                                             #;
    %put #  source2=           Option to print out details, null by default.           #;
    %put #                                                                             #;
    %put #  zip=zip            Standard package is zip (lowcase),                      #;
    %put #                     e.g. %nrstr(%%helpPackage(PiPackage)).                           #;
    %put #                     If the zip is not avaliable use a folder.               #;
    %put #                     Unpack data to "pipackage.disk" folder                  #;
    %put #                     and use loadPackage in the following form:              #;
    %put #                      %nrstr(%%helpPackage(PiPackage, zip=disk, options=))            #;
    %put #                                                                             #;
    %put ###############################################################################;
    %put ;
    %GOTO ENDhelpPackage;
  %end;
  %local ls_tmp ps_tmp notes_tmp source_tmp msglevel_tmp;
  %let ls_tmp     = %sysfunc(getoption(ls));      
  %let ps_tmp     = %sysfunc(getoption(ps));      
  %let notes_tmp  = %sysfunc(getoption(notes));   
  %let source_tmp = %sysfunc(getoption(source));
  %let msglevel_tmp = %sysfunc(getoption(msglevel)); 
  options NOnotes NOsource ls=MAX ps=MAX msglevel=N;
  %local _PackageFileref_;
  %let _PackageFileref_ = P%sysfunc(MD5(%lowcase(&packageName.)),hex7.);

  filename &_PackageFileref_. &ZIP. 
  /* put location of package myPackageFile.zip here */
    "&path./%lowcase(&packageName.).&zip." %unquote(&options.)
  ;
  %if %sysfunc(fexist(&_PackageFileref_.)) %then
    %do;
      %include &_PackageFileref_.(packagemetadata.sas) / &source2.;
      filename &_PackageFileref_. clear;
      options ls = &ls_tmp. ps = &ps_tmp. &notes_tmp. &source_tmp.;
      filename &_PackageFileref_. &ZIP. 
        "&path./%lowcase(&packageName.).&zip." %unquote(&options.) 
        ENCODING =
          %if %bquote(&packageEncoding.) NE %then &packageEncoding. ;
                                            %else utf8 ;
      ;
      %include &_PackageFileref_.(help.sas) / &source2.;
    %end;
  %else %put ERROR:[&sysmacroname] File "&path./&packageName..&zip." does not exist;
  filename &_PackageFileref_. clear;
  options ls = &ls_tmp. ps = &ps_tmp. &notes_tmp. &source_tmp. msglevel = &msglevel_tmp.;
/* jump here after running %helpPackage() - only help is displayed */
%ENDhelpPackage:
%mend helpPackage;

/*
TODO:
- macro for testing available packages in the packages folder [DONE] checkout: %listPackages()
- add MD5(&packageName.) value hash instead "package" word in filenames [DONE]
*/

/* Macros to install SAS packages, version 20200603  */
/* A SAS package is a zip file containing a group of files
   with SAS code (macros, functions, datasteps generating 
   data, etc.) wrapped up together and %INCLUDEed by
   a single load.sas file (also embedded inside the zip).
*/

/*** HELP START ***/
%macro installPackage(
  packageName  /* package name, without the zip extension */
, sourcePath = /* location of the package, e.g. "www.some.page/", mind the "/" at the end */
, replace = 1  /* 1 = replace if the package already exist, 0 = otherwise */
)
/secure  
/*** HELP END ***/
des = 'Macro to install SAS package, version 20200730. Run %%installPackage() for help info.'
;
%if %superq(packageName) = %then
  %do;
    %put ;
    %put ########################################################################################;
    %put #        This is short help information for the installPackage macro                   #;
    %put ########################################################################################;
    %put #                                                                                      #;
    %put # Macro to install SAS packages, version 20200730                                      #;
    %put #                                                                                      #;
    %put # A SAS package is a zip file containing a group                                       #;
    %put # of SAS codes (macros, functions, datasteps generating                                #;
    %put # data, etc.) wrapped up together and included by                                      #;
    %put # a single load.sas file (also embedded inside the zip).                               #;
    %put #                                                                                      #;
    %put # Parameters:                                                                          #;
    %put #                                                                                      #;
    %put #  packageName  Name of a package, e.g. myPackage,                                     #;
    %put #               Required and not null, default use case:                               #;
    %put #                %nrstr(%%installPackage(myPackage)).                                           #;
    %put #               If empty displays this help information.                               #;
    %put #                                                                                      #;
    %put #  sourcePath=  Location of the package, e.g. "www.some.web.page/"                     #;
    %put #               Mind the "/" at the end of the path!                                   #;
    %put #               Current default location:                                              #;
    %put #               https://raw.githubusercontent.com/yabwon/SAS_PACKAGES/master/packages/ #;    
    %put #                                                                                      #;
    %put #  replace=     With default value of 1 it causes existing package file                #;
    %put #               to be replaceed by new downloaded file.                                #;
    %put #                                                                                      #;
    %put ########################################################################################;
    %put ;
    %GOTO ENDinstallPackage;
  %end; 
  %local ls_tmp ps_tmp notes_tmp source_tmp fullstimer_tmp stimer_tmp msglevel_tmp;
  %let ls_tmp     = %sysfunc(getoption(ls));      
  %let ps_tmp     = %sysfunc(getoption(ps));      
  %let notes_tmp  = %sysfunc(getoption(notes));   
  %let source_tmp = %sysfunc(getoption(source));
  %let stimer_tmp = %sysfunc(getoption(stimer));
  %let fullstimer_tmp = %sysfunc(getoption(fullstimer)); 
  %let msglevel_tmp = %sysfunc(getoption(msglevel));  
  options NOnotes NOsource ls=MAX ps=MAX NOfullstimer NOstimer msglevel=N;

  %local in out;
  %let  in = i%sysfunc(md5(&packageName.),hex7.);
  %let out = o%sysfunc(md5(&packageName.),hex7.);

  /*options MSGLEVEL=i;*/
                           
  /*
  Reference:
  https://blogs.sas.com/content/sasdummy/2011/06/17/how-to-use-sas-data-step-to-copy-a-file-from-anywhere/
  */

  %if %superq(sourcePath)= %then
    %do;
      %let sourcePath = https://raw.githubusercontent.com/yabwon/SAS_PACKAGES/master/packages/;
    %end;
  filename &in URL "&sourcePath.%lowcase(&packageName.).zip" recfm=N lrecl=1;
  filename &out    "%sysfunc(pathname(packages))/%lowcase(&packageName.).zip" recfm=N lrecl=1;
  /*
  filename in  list;
  filename out list;
  */ 
  /* copy the file byte-by-byte  */
  data _null_;
    length filein 8 out_path in_path $ 4096;
    out_path = pathname ("&out");
     in_path = pathname ("&in" );


    filein = fopen( "&in", 'S', 1, 'B');
    if filein = 0 then
      put "ERROR: Source file:" / 
          "ERROR- " in_path /
          "ERROR- is unavaliable!";    
    if filein > 0; 

    put @2 "Source information:";  
    infonum = FOPTNUM(filein);
    length infoname $ 32 infoval $ 128;
    do i=1 to coalesce(infonum, -1);
      infoname = FOPTNAME(filein, i);
      infoval  = FINFO(filein, infoname);
      put @4 infoname ":" 
        / @6 infoval
        ;
    end;
    rc = FCLOSE(filein);
    put;

    

    if FEXIST("&out") = 0 then 
      do;
        put @2 "Installing the &packageName. package.";
        rc = FCOPY("&in", "&out");
      end;
    else if FEXIST("&out") = 1 then 
      do;
        if symget("replace")="1" then
          do;
            put @2 "The following file will be replaced during "
              / @2 "instalation of the &packageName. package: " 
              / @5 out_path;
            rc = FDELETE("&out");
            rc = FCOPY("&in", "&out");
          end;
        else
          do;
            put @2 "The following file will NOT be replaced: " 
              / @5 out_path;
            rc = 1;
          end;
      end;
      
    put @2 "Done with return code " rc=;
  run;
   
  filename &in  clear;
  filename &out clear;
  options ls = &ls_tmp. ps = &ps_tmp. 
          &notes_tmp. &source_tmp. 
          &stimer_tmp. &fullstimer_tmp.
          msglevel=&msglevel_tmp.;
/* jump here after running %installPackage() - only help is displayed */
%ENDinstallPackage:
%mend installPackage;

/*** HELP START ***/

/* 
  Filenames references "packages" and "package" are reserved keywords.
  The first one should be used to point local folder with packages.
  The second is used internally by macros.
  Do not use them otherwise than:
    filename packages "C:/SAS_PACKAGES";
  since it may affect stability of the framework.
**/

/* Example 1: Enabeling the SAS Package Framework 
    and loading the SQLinDS package from the local directory.

    Assume that the SPFinit.sas file and the SQLinDS 
    package (sqlinds.zip file) are located in 
    the "C:/SAS_PACKAGES/" folder.

    Run the following code in your SAS session:

  filename packages "C:/SAS_PACKAGES"; %* setup a directory for packages; 
  %include packages(SPFinit.sas);      %* enable the framework;

  %helpPackage(SQLinDS)                %* get help about the package;
  %loadpackage(SQLinDS)                %* load the package content into the SAS session;
  %unloadPackage(SQLinDS)              %* unload the package content from the SAS session;
*/

/* Example 2: Enabeling the SAS Package Framework 
    from the local directory and installing & loading
    the SQLinDS package from the Internet.

    Assume that the SPFinit.sas file
    is located in the "C:/SAS_PACKAGES/" folder.

    Run the following code in your SAS session:

  filename packages "C:/SAS_PACKAGES"; %* setup a directory for packages; 
  %include packages(SPFinit.sas);      %* enable the framework;

  %installPackage(SQLinDS)             %* install the package from the Internet;
  %helpPackage(SQLinDS)                %* get help about the package;
  %loadpackage(SQLinDS)                %* load the package content into the SAS session;
  %unloadPackage(SQLinDS)              %* unload the package content from the SAS session;
*/

/* Example 3: Enabeling the SAS Package Framework 
    and installing & loading the SQLinDS package 
    from the Internet.

    Run the following code in your SAS session:

  filename packages "%sysfunc(pathname(work))"; %* setup WORK as a temporary directory for packages;
   
  filename spfinit url "https://raw.githubusercontent.com/yabwon/SAS_PACKAGES/master/SPFinit.sas";
  %include spfinit;                    %* enable the framework;

  %installPackage(SQLinDS)             %* install the package from the Internet;
  %helpPackage(SQLinDS)                %* get help about the package;
  %loadpackage(SQLinDS)                %* load the package content into the SAS session;
  %unloadPackage(SQLinDS)              %* unload the package content from the SAS session;
*/

/* Example 4: 
    Assume that the SPFinit.sas file and the SQLinDS package (sqlinds.zip file)
    are located in the "C:/SAS_PACKAGES/" folder.

    In case when user SAS session does not support ZIP fileref
    the following solution could be used.

    Unzip the packagename.zip content into the packagename.disk folder
    and run macros with the following options:                     ;

  %loadPackage(packageName,zip=disk,options=)
  %helpPackage(packageName,,zip=disk,options=) %* mind the double comma!! ;
  %unloadPackage(packageName,zip=disk,options=) 

*/

/* Example 5: Enabeling the SAS Package Framework from the local directory
    and installing the SQLinDS package from the Internet.

    Assume that the SPFinit.sas file is located in 
    the "C:/SAS_PACKAGES/" folder.

  filename packages "C:/SAS_PACKAGES"; %* setup a directory for packages; 
  %include packages(SPFinit.sas);      %* enable the framework;

  %installPackage(SQLinDS);            %* install package;
  %installPackage(SQLinDS);            %* overwrite already instaled package;
  %installPackage(SQLinDS,replace=0);  %* prevent overwrite instaled package;


  %installPackage(NotExistingPackage); %* handling with not existing package;

*/

/*** HELP END ***/

/* optional - obsolite - deprecated;

  libname packages "C:/SAS_PACKAGES/";
  %include "%sysfunc(pathname(packages))/loadpackage.sas";

  %loadPackage(SQLinDS)
  %helpPackage(SQLinDS)
  %unloadPackage(SQLinDS)
*/



/*** HELP START ***/

/* Macro to list SAS packages in packages folder. 

  Version 20200730 

  A SAS package is a zip file containing a group 
  of SAS codes (macros, functions, datasteps generating 
  data, etc.) wrapped up together and %INCLUDEed by
  a single load.sas file (also embedded inside the zip).
*/
/*
 * Example 1: Set local packages directory, enable the framework,
              and list packages in the local repository.

  filename packages "C:\SAS_PACKAGES";
  %include packages(SPFinit.sas);
  %listPackages()

*/
/*** HELP END ***/


%macro listPackages()/
des = 'Macro to list SAS package from `package` fileref, version 20200730.'
;

%local ls_tmp ps_tmp notes_tmp source_tmp;
%let   filesWithCodes = WORK._%sysfunc(datetime(), hex16.)_;

%local ls_tmp ps_tmp notes_tmp source_tmp;
%let ls_tmp     = %sysfunc(getoption(ls));      
%let ps_tmp     = %sysfunc(getoption(ps));      
%let notes_tmp  = %sysfunc(getoption(notes));   
%let source_tmp = %sysfunc(getoption(source));  
options NOnotes NOsource ls=MAX ps=MAX;

data _null_;
  base = "%sysfunc(pathname(packages))";

  if base = " " then
    do;
      put "NOTE: The filereference PACKAGES is not assigned.";
      stop;
    end;

  length folder file $ 256 folderRef fileRef $ 8;

  folderRef = "_%sysfunc(datetime(), hex6.)0";

  rc=filename(folderRef, base);
  folderid=dopen(folderRef);

  put;
  put "/*" 100*"+" ;
  do i=1 to dnum(folderId); drop i;
    folder = dread(folderId, i);

    fileRef = "_%sysfunc(datetime(), hex6.)1";
    rc = filename(fileRef, catx("/", base, folder));
    fileId = dopen(fileRef);

    EOF = 0;
    if fileId = 0 and lowcase(scan(folder, -1, ".")) = 'zip' then 
      do;
          file = catx('/',base, folder);
          length nn $ 96;
          nn = repeat("*", (96-lengthn(file)));   
          
          putlog " ";
          put " * " file @; put nn /;
           
          infile package ZIP FILEVAR=file member="description.sas" end=EOF; 
          
            do until(EOF);
                input;
                if lowcase(scan(_INFILE_,1,":")) in ("package" "title" "version" "author" "maintainer" "license") then
                  do;
                    _INFILE_ = scan(_INFILE_,1,":") !! ":" !! scan(_INFILE_,2,":");
                    putlog " *  " _INFILE_;
                  end;
                if strip(_INFILE_) = "DESCRIPTION START:" then leave;
            end; 
      end;
    
    rc = dclose(fileId);
    rc = filename(fileRef);
  end;

  putlog " ";
  put 100*"+" "*/";
  rc = dclose(folderid);
  rc = filename(folderRef);
  stop;
run;

options ls = &ls_tmp. ps = &ps_tmp. &notes_tmp. &source_tmp.;
%mend listPackages;


/*** HELP START ***/               

/* Macros to generate SAS packages.

   Version 20200730


   A SAS package is a zip file containing a group 
   of SAS codes (macros, functions, datasteps generating 
   data, etc.) wrapped up together and %INCLUDEed by
   a single load.sas file (also embedded inside the zip).

   See examples below.
*/

/*** HELP END ***/


/*** HELP START ***/
%macro generatePackage(
 filesLocation=  /* location of package files 
                    e.g. %sysfunc(pathname(work))/%lowcase(&packageName.) */
,testPackage=Y   /* indicator if tests should be executed, 
                    default value Y means "execute tests" */
,packages=       /* location of other packages if there are
                    dependencies in loading */
)/secure
/*** HELP END ***/
des = 'Macro to generate SAS packages, version 20200730. Run %generatePackage() for help info.'
;
%if %superq(filesLocation) = %then
  %do;
    %put ;
    %put ###############################################################################;
    %put #        This is short help information for the generatePackage macro         #;
    %put ###############################################################################;
    %put #                                                                             #;
    %put # Macro to generate SAS packages, version 20200730                            #;
    %put #                                                                             #;
    %put # A SAS package is a zip file containing a group                              #;
    %put # of SAS codes (macros, functions, datasteps generating                       #;
    %put # data, etc.) wrapped up together and included by                             #;
    %put # a single load.sas file (also embedded inside the zip).                      #;
    %put #                                                                             #;
    %put # Parameters:                                                                 #;
    %put #                                                                             #;
    %put #  filesLocation=   Location of package files, example value:                 #;
    %put #                    %nrstr(%%sysfunc(pathname(work))/packagename).                    #;
    %put #                   Default use case:                                         #;
    %put #                    %nrstr(%%generatePackage(filesLocation=/path/to/packagename))     #;
    %put #                   If empty displays this help information.                  #;
    %put #                                                                             #;
    %put #  testPackage=     Indicator if tests should be executed.                    #;
    %put #                   Default value: Y, means "execute tests"                   #;
    %put #                                                                             #;
    %put #  packages=        Location of other packages for testing                    #;
    %put #                   if there are dependencies in loading the package.         #;
    %put #                                                                             #;
    %put ###############################################################################;
    %put ;
    %GOTO ENDgeneratePackage;
  %end;

%local zipReferrence filesWithCodes _DESCR_ _LIC_ _RC_ _PackageFileref_;
%let   zipReferrence = _%sysfunc(datetime(), hex6.)_;
%let   filesWithCodes = WORK._%sysfunc(datetime(), hex16.)_;
%let   _DESCR_ = _%sysfunc(datetime(), hex6.)d;
%let   _LIC_   = _%sysfunc(datetime(), hex6.)l;

/* collect package metadata from the description.sas file */
filename &_DESCR_. "&filesLocation./description.sas" lrecl = 256;
/* file contains licence */
filename &_LIC_.   "&filesLocation./license.sas" lrecl = 256;

%if %sysfunc(fexist(&_DESCR_.)) %then 
  %do;
    %put NOTE: Creating package%str(%')s metadata; 

    %local packageName        /* name of the package, required */  
           packageVersion     /* version of the package, required */
           packageTitle       /* title of the package, required*/
           packageAuthor      /* required */
           packageMaintainer  /* required */
           packageEncoding    /* required */
           packageLicense     /* required */
           packageRequired    /* optional */
           packageReqPackages /* optional */
           ;
    data _null_;
      infile &_DESCR_.;
      input;
    
      select;
        when(upcase(scan(_INFILE_, 1, ":")) = "PACKAGE")     call symputX("packageName",        scan(_INFILE_, 2, ":"),"L");
        when(upcase(scan(_INFILE_, 1, ":")) = "VERSION")     call symputX("packageVersion",     scan(_INFILE_, 2, ":"),"L");
        when(upcase(scan(_INFILE_, 1, ":")) = "AUTHOR")      call symputX("packageAuthor",      scan(_INFILE_, 2, ":"),"L");
        when(upcase(scan(_INFILE_, 1, ":")) = "MAINTAINER")  call symputX("packageMaintainer",  scan(_INFILE_, 2, ":"),"L");
        when(upcase(scan(_INFILE_, 1, ":")) = "TITLE")       call symputX("packageTitle",       scan(_INFILE_, 2, ":"),"L");
        when(upcase(scan(_INFILE_, 1, ":")) = "ENCODING")    call symputX("packageEncoding",    scan(_INFILE_, 2, ":"),"L");
        when(upcase(scan(_INFILE_, 1, ":")) = "LICENSE")     call symputX("packageLicense",     scan(_INFILE_, 2, ":"),"L");
        when(upcase(scan(_INFILE_, 1, ":")) = "REQUIRED")    call symputX("packageRequired",    scan(_INFILE_, 2, ":"),"L");
        when(upcase(scan(_INFILE_, 1, ":")) = "REQPACKAGES") call symputX("packageReqPackages", scan(_INFILE_, 2, ":"),"L");

        /* stop at the beginning of description */
        when(upcase(scan(_INFILE_, 1, ":")) = "DESCRIPTION START") stop;
        otherwise;
      end;
    run;
 
    /* test for required descriptors */
    %if (%nrbquote(&packageName.) = )
     or (%nrbquote(&packageVersion.) = )
     or (%nrbquote(&packageAuthor.) = )
     or (%nrbquote(&packageMaintainer.) = )
     or (%nrbquote(&packageTitle.) = )
     or (%nrbquote(&packageEncoding.) = )
     or (%nrbquote(&packageLicense.) = )
      %then
        %do;
          %put ERROR: At least one of descriptors is missing!;
          %put ERROR- They are required to create package.;
          %put ERROR- &=packageName.;
          %put ERROR- &=packageTitle.;
          %put ERROR- &=packageVersion.;
          %put ERROR- &=packageAuthor.;
          %put ERROR- &=packageMaintainer.;
          %put ERROR- &=packageEncoding.;
          %put ERROR- &=packageLicense.; 
          %put ERROR- ;
          %abort;
        %end;
    /* test for package name */
    %if %sysfunc(lengthn(&packageName.)) > 24 %then
      %do;
        %put ERROR: Package name is more than 24 characters long.;
        %put ERROR- The name is used for functions%str(%') dataset name;
        %put ERROR- and for formats%str(%') cataloge name (with suffix).;
        %put ERROR- The length is %sysfunc(lengthn(&packageName.)). Try something shorter.;
        %abort;
      %end;
    %else %if %sysfunc(lengthn(&packageName.)) < 3 %then
            %do;
              %put WARNING: Package name is less than 3 characters.;
              %put WARNING- Maybe consider some _meaningful_ name?;
            %end;
    /* test characters in package name */
    %if %qsysfunc(lengthn(%qsysfunc(compress(&packageName.,,KDF)))) NE %qsysfunc(lengthn(&packageName.)) %then
      %do;
        %put ERROR: Package name contains illegal symbols.;
        %put ERROR- The name is used for functions%str(%') dataset name;
        %put ERROR- and for formats%str(%') cataloge name.;
        %put ERROR- Only English letters, underscore(_), and digits are allowed.;
        %put ERROR- Try something else. Maybe: %qsysfunc(compress(&packageName.,,KDF)) will do?;
        %abort;
      %end;

  %end;
%else
  %do;
    %put ERROR: The description.sas file is missing!;
    %put ERROR- The file is required to create package%str(%')s metadata;
    %abort;
  %end;

/* generate package fileref with MD5 to allow 
   different file reference for each package 
   while loading package with %loadPackage() macro
  */
%let _PackageFileref_ = P%sysfunc(MD5(%lowcase(&packageName.)),hex7.);

/* test if version is a number */
data _null_;
  version = input("&packageVersion.", ?? best32.);
  if not (version > 0) then
    do;
      put 'ERROR: Package version should be a positive NUMBER.';
      put 'ERROR- Current value is: ' "&packageVersion.";
      put 'ERROR- Try something small, e.g. 0.1';
      put;
      abort;
    end;
run;

/* create or replace the ZIP file for package  */
filename &zipReferrence. ZIP "&filesLocation./%lowcase(&packageName.).zip";

%if %sysfunc(fexist(&zipReferrence.)) %then 
  %do;
    %put NOTE: Deleting file "&filesLocation./%lowcase(&packageName.).zip";
    %let _RC_ = %sysfunc(fdelete(&zipReferrence.));
  %end;

/*** HELP START ***/
/* 
  Locate all files with code in base folder (i.e. at filesLocation directory) 
*/
/*
  Remember to prepare the description.sas file for you package.
  The colon (:) is a field separator and is restricted 
  in lines of the header part.                          
  The file should contain the following obligatory information:
--------------------------------------------------------------------------------------------
>> **HEADER** <<
Type: Package
Package: ShortPackageName                                
Title: A title/brief info for log note about your packages                 
Version: X.Y                                    
Author: Firstname1 Lastname1 (xxxxxx1@yyyyy.com), Firstname2 Lastname2 (xxxxxx2@yyyyy.com)     
Maintainer: Firstname Lastname (xxxxxx@yyyyy.com)
License: MIT
Encoding: UTF8                                  

Required: "Base SAS Software"                    :%*optional, COMMA separated, QUOTED list, names of required SAS products, values must be like from proc setinit;run; output *;
ReqPackages: "macroArray (0.1)", "DFA (0.1)"     :%*optional, COMMA separated, QUOTED list, names of required packages *;

>> **DESCRIPTION** <<
>> All the text below will be used in help <<
DESCRIPTION START:
  Xxxxxxxxxxx xxxxxxx xxxxxx xxxxxxxx xxxxxxxx. Xxxxxxx
  xxxx xxxxxxxxxxxx xx xxxxxxxxxxx xxxxxx. Xxxxxxx xxx
  xxxx xxxxxx. Xxxxxxxxxxxxx xxxxxxxxxx xxxxxxx.
DESCRIPTION END:
--------------------------------------------------------------------------------------------

  Name of the 'type' of folder and files.sas inside must be in _low_ case letters.

  If order of loading is important, the 'sequential number'
  can be used to order multiple types in the way you wish.

  The "tree structure" of the folder could be for example as follows:

--------------------------------------------------------------------------------------------
 <packageName>
  ..
   |
   +-000_libname [one file one libname]
   |           |
   |           +-abc.sas [a file with a code creating libname ABC]
   |
   +-001_macro [one file one macro]
   |         |
   |         +-hij.sas [a file with a code creating macro HIJ]
   |         |
   |         +-klm.sas [a file with a code creating macro KLM]
   |
   +-002_function [one file one function,
   |            |  option OUTLIB= should be: work.&packageName.fcmp.package 
   |            |  option INLIB=  should be: work.&packageName.fcmp
   |            |  (both literally with macrovariable name and "fcmp" sufix)]
   |            |
   |            +-efg.sas [a file with a code creating function EFG, _with_ "Proc FCMP" header]
   |
   +-003_functions [mind the S at the end!, one file one function,
   |             |  only plain code of the function, without "Proc FCMP" header]
   |             |
   |             +-ijk.sas [a file with a code creating function EFG, _without_ "Proc FCMP" header]
   |
   +-004_format [one file one format,
   |          |  option LIB= should be: work.&packageName.format 
   |          |  (literally with macrovariable name and "format" sufix)]
   |          |
   |          +-efg.sas [a file with a code creating format EFG and informat EFG]
   |
   +-005_data [one file one dataset]
   |        |
   |        +-abc.efg.sas [a file with a code creating dataset EFG in library ABC] 
   |
   +-006_exec [so called "free code", content of the files will be printed 
   |        |  to the log before execution]
   |        |
   |        +-<no file, in this case folder may be skipped>
   |
   +-007_format [if your codes depend each other you can order them in folders, 
   |          |  e.g. code from 003_... will be executed before 006_...]
   |          |
   |          +-abc.sas [a file with a code creating format ABC, 
   |                     used in the definition of the format EFG]
   +-008_function
   |            |
   |            +-<no file, in this case folder may be skipped>
   |
   |
   +-009_lazydata [one file one dataset]
   |            |
   |            +-klm.sas [a file with a code creating dataset klm in library work
   |                       it will be created only if user request it by using:
   |                       %loadPackage(packagename, lazyData=klm)
   |                       multiple elements separated by space are allowed
   |                       an asterisk(*) means "load all data"] 
   |
   +-010_imlmodule [one file one IML module,
   |             |  only plain code of the module, without "Proc IML" header]
   |             |
   |             +-abc.sas [a file with a code creating IML module ABC, _without_ "Proc IML" header]
   |
   +-<sequential number>_<type [in lower case]>
   |
   +-...
   |
   +-00n_clean [if you need to clean something up after exec file execution,
   |         |  content of the files will be printed to the log before execution]
   |         |
   |         +-<no file, in this case folder may be skipped>
   +-...
   ...
--------------------------------------------------------------------------------------------

*/
/*** HELP END ***/

/* collect the data */
data &filesWithCodes.;
  base = "&filesLocation.";
  length folder file lowcase_name $ 256 folderRef fileRef $ 8; 
  drop lowcase_name;

  folderRef = "_%sysfunc(datetime(), hex6.)0";

  rc=filename(folderRef, base);
  folderid=dopen(folderRef);

  do i=1 to dnum(folderId); drop i;
    folder = dread(folderId, i); 
    if folder NE lowcase(folder) then
      do;
        put 'ERROR: Folder should be named ONLY with low case letters.';
        put 'ERROR- Current value is: ' folder;
        lowcase_name = lowcase(folder);
        put 'ERROR- Try: ' lowcase_name;
        put;
        abort;
      end;
    order = scan(folder, 1, "_");
    type  = scan(folder,-1, "_");

    fileRef = "_%sysfunc(datetime(), hex6.)1";
    rc = filename(fileRef, catx("/", base, folder));
    fileId = dopen(fileRef);

    file = ' ';
    if fileId then 
      do j = 1 to dnum(fileId); drop j;
        file = dread(fileId, j);
            if file NE lowcase(file) then
              do;
                put 'ERROR: File with code should be named ONLY with low case letters.';
                put 'ERROR- Current value is: ' file;
                lowcase_name = lowcase(file);
                put 'ERROR- Try: ' lowcase_name;
                put;
                abort;
              end;
        fileshort = substr(file, 1, length(file) - 4); /* filename.sas -> filename */
        output;
      end;
    rc = dclose(fileId);
    rc = filename(fileRef);
  end;

  rc = dclose(folderid);
  rc = filename(folderRef);
  stop;
run;
proc sort data = &filesWithCodes.;
  by order type file;
run;
/*
proc contents data = &filesWithCodes.;
run;
*/
title1 "Package's location is: &filesLocation.";
title2 "User: &SYSUSERID., datetime: %qsysfunc(datetime(), datetime21.), SAS version: &SYSVLONG4.";
title3 "Package's encoding: '&packageEncoding.', session's encoding: '&SYSENCODING.'.";
title4 " ______________________________ ";
title5 "List of files for package: &packageName. (version &packageVersion.), license: &packageLicense.";
title6 "MD5 hashed fileref of package lowcase name: &_PackageFileref_.";
%if (%bquote(&packageRequired.) ne ) 
 or (%bquote(&packageReqPackages.) ne )             
%then
  %do;
  title7 "Required SAS licences: %qsysfunc(compress(%bquote(&packageRequired.),   %str(%'%")))" ;   /* ' */
  title8 "Required SAS packages: %qsysfunc(compress(%bquote(&packageReqPackages.),%str(%'%")))" ;   /* " */
  %end;


proc print data = &filesWithCodes.(drop=base);
run;
title;

/* packages description */
data _null_;
  infile &_DESCR_.;
  file &zipReferrence.(description.sas);
  input; 
  put _INFILE_;
run;

/* package license */
%if %sysfunc(fexist(&_LIC_.)) %then 
  %do;
    data _null_;
      infile &_LIC_.;
      file &zipReferrence.(license.sas);
      input; 
      put _INFILE_;
    run;
  %end;
%else
  %do;
    %put WARNING:[License] No license.sas file provided, default (MIT) licence file will be generated.;
    %let packageLicense = MIT;
     data _null_;
      file &zipReferrence.(license.sas);
      put " ";
      put "  Copyright (c) %sysfunc(today(),year4.) &packageAuthor.                        ";
      put "                                                                                ";
      put "  Permission is hereby granted, free of charge, to any person obtaining a copy  ";
      put '  of this software and associated documentation files (the "Software"), to deal ';
      put "  in the Software without restriction, including without limitation the rights  ";
      put "  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell     ";
      put "  copies of the Software, and to permit persons to whom the Software is         ";
      put "  furnished to do so, subject to the following conditions:                      ";
      put "                                                                                ";
      put "  The above copyright notice and this permission notice shall be included       ";
      put "  in all copies or substantial portions of the Software.                        ";
      put "                                                                                ";
      put '  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR    ';
      put "  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,      ";
      put "  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE   ";
      put "  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER        ";
      put "  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, ";
      put "  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE ";
      put "  SOFTWARE.                                                                     ";
      put " ";
    run;
  %end;

/* package metadata */
data _null_;
  if 0 then set &filesWithCodes. nobs=NOBS;
  if NOBS = 0 then
    do;
      putlog "WARNING:[&sysmacroname.] No files to create package.";
      stop;
    end;
  file &zipReferrence.(packagemetadata.sas);

  put ' data _null_; '; /* simple "%local" returns error while loading package */
  put ' call symputX("packageName",       " ", "L");';
  put ' call symputX("packageVersion",    " ", "L");';
  put ' call symputX("packageTitle",      " ", "L");';  
  put ' call symputX("packageAuthor",     " ", "L");';
  put ' call symputX("packageMaintainer", " ", "L");';
  put ' call symputX("packageEncoding",   " ", "L");'; 
  put ' call symputX("packageLicense",    " ", "L");';  
  put ' run; ';

  put ' %let packageName       =' "&packageName.;";
  put ' %let packageVersion    =' "&packageVersion.;";
  put ' %let packageTitle      =' "&packageTitle.;";
  put ' %let packageAuthor     =' "&packageAuthor.;";
  put ' %let packageMaintainer =' "&packageMaintainer.;";
  put ' %let packageEncoding   =' "&packageEncoding.;";
  put ' %let packageLicense    =' "&packageLicense.;";
  put ' ; ';

  stop;
run;

/* emergency ICEloadPackage macro to load package when loadPackage() 
   is unavaliable for some reasons, example of use:
    1) point to a zip file, 
    2) include iceloadpackage.sas
    3) point to package folder, 
    4) load package
*//*

  filename packages zip 'C:/SAS_PACKAGES/sqlinds.zip';
  %include packages(iceloadpackage.sas);
  filename packages 'C:/SAS_PACKAGES/';
  %ICEloadpackage(sqlinds)

 */
data _null_;
  file &zipReferrence.(iceloadpackage.sas);
  put " ";
  put '  /* Temporary replacement of loadPackage() macro. */                      ';
  put '  %macro ICEloadPackage(                                                   ';
  put '    packageName                         /* name of a package */            ';
  put '  , path = %sysfunc(pathname(packages)) /* location of a package */        ';
  put '  , options = %str(LOWCASE_MEMNAME)     /* possible options for ZIP */     ';
  put '  , zip = zip                           /* file ext. */                    ';
  put '  , source2 = /* source2*/                                                 ';
  put '  )/secure;                                                                ';
  put '    %PUT ** NOTE: Package ' "&packageName." ' loaded in ICE mode **;       ';
  put '    %local _PackageFileref_;                                               ';
  put '    %let _PackageFileref_ = P%sysfunc(MD5(%lowcase(&packageName.)),hex7.); ';
  put '    filename &_PackageFileref_. &ZIP.                                      ';
  put '      "&path./%lowcase(&packageName.).&zip." %unquote(&options.)           ';
  put '    ;                                                                      ';
  put '    %include &_PackageFileref_.(packagemetadata.sas) / &source2.;          ';
  put '    filename &_PackageFileref_. clear;                                     ';
  put '    filename &_PackageFileref_. &ZIP.                                      ';
  put '      "&path./%lowcase(&packageName.).&zip." %unquote(&options.)           ';
  put '      ENCODING =                                                           ';
  put '        %if %bquote(&packageEncoding.) NE %then &packageEncoding. ;;       ';
  put '    %include &_PackageFileref_.(load.sas) / &source2.;                     ';
  put '    filename &_PackageFileref_. clear;                                     ';
  put '  %mend ICEloadPackage;                                                    ';
  put " ";
run;


/* loading package files */
data _null_;
  if NOBS = 0 then stop;

  file &zipReferrence.(load.sas) lrecl=32767;
 
  put "filename &_PackageFileref_. list;" /;
  put ' %put NOTE- ;'; 
  put ' %put NOTE: ' @; put "Loading package &packageName., version &packageVersion., license &packageLicense.; ";
  put ' %put NOTE: ' @; put "*** &packageTitle. ***; ";
  put ' %put NOTE- ' @; put "Generated: %sysfunc(datetime(), datetime21.); ";
  put ' %put NOTE- ' @; put "Author(s): &packageAuthor.; ";
  put ' %put NOTE- ' @; put "Maintainer(s): &packageMaintainer.; ";
  put ' %put NOTE- ;';
  put ' %put NOTE- Write %nrstr(%%)helpPackage(' "&packageName." ') for the description;';
  put ' %put NOTE- ;';
  put ' %put NOTE- *** START ***; ' /;

  put '%include ' " &_PackageFileref_.(packagemetadata.sas) / nosource2; " /; /* <- copied also to loadPackage macro */
  isFunction = 0;
  isFormat   = 0;

  %if (%bquote(&packageRequired.) ne ) 
   or (%bquote(&packageReqPackages.) ne )             
  %then
    %do;
      put ' data _null_;                                                     ';
      put '  call symputX("packageRequiredErrors", 0, "L");                  ';
      put ' run;                                                             ';
    %end;

  %if %bquote(&packageRequired.) ne %then
    %do;
      put ' %put NOTE- *Testing required SAS components*%sysfunc(DoSubL(     '; /* DoSubL() */
      put ' options nonotes nosource %str(;)                                 ';
      put ' options ls=max ps=max locale=en_US %str(;)                       ';
      put ' /* temporary redirect log */                                     ';
      put ' filename _stinit_ TEMP %str(;)                                   ';
      put ' proc printto log = _stinit_ %str(;) run %str(;)                  ';
      put ' /* print out setinit */                                          ';
      put ' proc setinit %str(;) run %str(;)                                 ';
      put ' proc printto %str(;) run %str(;)                                 ';

      put ' data _null_ %str(;)                                              ';
      put '   /* loadup checklist of required SAS components */              ';
      put '   if _n_ = 1 then                                                ';
      put '     do %str(;)                                                   ';
      put '       length req $ 256 %str(;)                                   ';
      put '       declare hash R() %str(;)                                   ';
      put '       _N_ = R.defineKey("req") %str(;)                           ';
      put '       _N_ = R.defineDone() %str(;)                               ';
      put '       declare hiter iR("R") %str(;)                              ';
        length packageRequired $ 32767; 
        packageRequired = upcase(symget('packageRequired'));
      put '         do req = %bquote(' / packageRequired / ') %str(;)        ';
      put '          _N_ = R.add(key:req,data:req) %str(;)   ';
      put '         end %str(;)                                              ';
      put '     end %str(;)                                                  ';
      put '                                                                  ';
      put '   /* read in output from proc setinit */                         ';
      put '   infile _stinit_ end=eof %str(;)                                ';
      put '   input %str(;)                                                  ';
      /*put ' put "*> " _infile_ %str(;)';*/ /* for testing */
      put '                                                                  ';
      put '   /* if component is in setinit remove it from checklist */      ';
      put '   if _infile_ =: "---" then                                      ';
      put '     do %str(;)                                                   ';
      put '       req = upcase(substr(_infile_, 4, 64)) %str(;)              ';
      put '       if R.find(key:req) = 0 then                                ';
      put '         do %str(;)                                               ';
      put '           _N_ = R.remove() %str(;)                               ';
      put '         end %str(;)                                              ';
      put '     end %str(;)                                                  ';
      put '                                                                  ';
      put '   /* if checklist is not null rise error */                      ';
      put '   if eof and R.num_items > 0 then                                ';
      put '     do %str(;)                                                   ';
      put '       put "ERROR- ###########################################" %str(;) ';
      put '       put "ERROR-  The following SAS components are missing! " %str(;) ';
      put '       call symputX("packageRequiredErrors", 1, "L") %str(;)      ';
      put '       do while(iR.next() = 0) %str(;)                            ';
      put '         put "ERROR-   " req %str(;)                              ';
      put '       end %str(;)                                                ';
      put '       put "ERROR- ###########################################" %str(;) ';
      put '       put %str(;)                                                ';
      put '     end %str(;)                                                  ';
      put ' run %str(;)                                                      ';
      put ' filename _stinit_ clear %str(;)                                  ';
      put ' options notes source %str(;)                                     ';
      put ' ))*;                                                             ';
    %end;

  %if %bquote(&packageReqPackages.) ne %then
    %do;

      length packageReqPackages $ 32767;
      packageReqPackages = lowcase(symget('packageReqPackages'));
      /* try to load required packages */
      put 'data _null_ ;                                                                                 ';
      put '  length req name $ 64 vers verR 8 SYSloadedPackages $ 32767;                                 ';
      put '  if SYMEXIST("SYSloadedPackages") = 1 and SYMGLOBL("SYSloadedPackages") = 1 then             ';
      put '    do;                                                                                       ';
      put '      do until(EOF);                                                                          ';
      put '        set sashelp.vmacro(where=(scope="GLOBAL" and name="SYSLOADEDPACKAGES")) end=EOF;      ';
      put '        substr(SYSloadedPackages, 1+offset, 200) = value;                                     ';
      put '      end;                                                                                    ';
      put '    end;                                                                                      ';
      put '  SYSloadedPackages = lowcase(SYSloadedPackages);                                             '; 

      put '  declare hash LP();                                                                          ';
      put '  LP.defineKey("name");                                                                       ';
      put '  LP.defineData("vers");                                                                      ';
      put '  LP.defineDone();                                                                            ';
      put '  do _N_ = 1 to countw(SYSloadedPackages);                                                    ';
      put '    req = scan(SYSloadedPackages, _N_, " ");                                                  ';
      put '    name = lowcase(strip(scan(req, 1, "(")));                                                 ';
      put '    vers = input(compress(scan(req,-1, "("), ".", "KD"),best32.);                             ';
      put '    _RC_ = LP.add();                                                                          ';
      put '  end;                                                                                        ';

      put '  do req = ' / packageReqPackages / ' ;                                                       ';
/*    put '    req = compress(req, "(.)", "KDF");                                                        ';*/
      put '    name = lowcase(strip(scan(req, 1, "(")));                                                 ';
      put '    verR = input(compress(scan(req,-1, "("), ".", "KD"),best32.); vers = .;                   ';
      put '    LP_find = LP.find();                                                                      ';
      put '    if (LP_find ne 0) or (LP_find = 0 and . < vers < verR) then                               ';
      put '     do;                                                                                      ';
      put '      put "NOTE: Trying to install required SAS package " req;                                ';
      put '      call execute(cats(''%nrstr(%loadPackage('', name, ", requiredVersion = ", verR, "))")); ';
      put '     end ;                                                                                    ';
      put '  end ;                                                                                       ';
      put ' stop;                                                                                        ';
      put 'run;                                                                                          ';

      /* test if required packages are loaded */
      put 'data _null_ ;                                                                                 ';
      put '  length req name $ 64 SYSloadedPackages $ 32767;                                             ';
      put '  if SYMEXIST("SYSloadedPackages") = 1 and SYMGLOBL("SYSloadedPackages") = 1 then             ';
      put '    do;                                                                                       ';
      put '      do until(EOF);                                                                          ';
      put '        set sashelp.vmacro(where=(scope="GLOBAL" and name="SYSLOADEDPACKAGES")) end=EOF;      ';
      put '        substr(SYSloadedPackages, 1+offset, 200) = value;                                     ';
      put '      end;                                                                                    ';
      put '      SYSloadedPackages = lowcase(SYSloadedPackages);                                         '; 

      put '      declare hash LP();                                                                      ';
      put '      LP.defineKey("name");                                                                   ';
      put '      LP.defineData("vers");                                                                  ';
      put '      LP.defineDone();                                                                        ';
      put '      do _N_ = 1 to countw(SYSloadedPackages);                                                ';
      put '        req = scan(SYSloadedPackages, _N_, " ");                                              ';
      put '        name = lowcase(strip(scan(req, 1, "(")));                                             ';
      put '        vers = input(compress(scan(req,-1, "("), ".", "KD"), best32.);                        ';
      put '        _RC_ = LP.add();                                                                      ';
      put '      end;                                                                                    ';

      put '      missingPackagr = 0;                                                                     ';
      put '      do req = ' / packageReqPackages / ' ;                                                   ';
/*    put '        req = compress(req, "(.)", "KDF");                                                    ';*/
      put '        name = lowcase(strip(scan(req, 1, "(")));                                             ';
      put '        verR = input(compress(scan(req,-1, "("), ".", "KD"),best32.); vers = .;               ';
      put '        LP_find = LP.find();                                                                  ';
      put '        if (LP_find ne 0) or (LP_find = 0 and . < vers < verR) then                           ';
      put '         do;                                                                                  ';
      put '          missingPackagr = 1;                                                                 ';
      put '          put "ERROR: SAS package " req "is missing! Download it and" ;                       ';
      put '          put ''ERROR- use  %loadPackage('' name ", requiredVersion = " verR ") to load it." ;';
      put '         end ;                                                                                ';
      put '      end ;                                                                                   ';
      put '      if missingPackagr then call symputX("packageRequiredErrors", 1, "L");                   ';
      put '    end;                                                                                      ';
      put '  else                                                                                        ';
      put '    do;                                                                                       ';
      put '      put "ERROR: No package loaded!";                                                        ';
      put '      call symputX("packageRequiredErrors", 1, "L");                                          ';
      put '      do req = ' / packageReqPackages / ' ;                                                   ';
      put '        name = lowcase(strip(scan(req, 1, "(")));                                             ';
      put '        vers = input(compress(scan(req,-1, "("), ".", "KD"), best32.);                        ';
      put '        put "ERROR: SAS package " req "is missing! Download it and" ;                         ';
      put '        put ''ERROR- use %loadPackage('' name ", requiredVersion = " vers ") to load it." ;   ';
      put '      end ;                                                                                   ';
      put '    end;                                                                                      ';
      put '  stop;                                                                                       ';
      put 'run;                                                                                          ';
    %end;

  %if (%bquote(&packageRequired.) ne ) 
     or (%bquote(&packageReqPackages.) ne )             
  %then
    %do;
      put ' data _null_;                                                     ';
      put '  if symget("packageRequiredErrors") = "1" then                   ';
      put '    do;                                                           ';
      put '      put "ERROR: Loading package &packageName. will be aborted!";';
      put '      put "ERROR- Required SAS components are missing.";          ';
      put '      put "ERROR- *** STOP ***";                                  ';
      put '      ABORT;                                                      ';
      put '    end;                                                          ';
      put ' run;                                                             ';
    %end;

  do until(eof);
    set &filesWithCodes. end = EOF nobs=NOBS;
    by TYPE notsorted;
    if (upcase(type) in: ('CLEAN' 'LAZYDATA' 'TEST')) then continue; /* cleaning files are only included in unload.sas */
                                                                     /* lazy data are only loaded on demand 
                                                                        %loadPackage(packagename, lazyData=set1 set2 set3)
                                                                        test files are used only during package generation
                                                                      */
    /* test for supported types */
    if not (upcase(type) in: 
      ('LIBNAME' 'MACRO' 'DATA' 'FUNCTION' /*'FUNCTIONS'*/ 'FORMAT' 'IMLMODULE' 'EXEC' 'CLEAN' 'LAZYDATA' 'TEST')) 
    then 
      do;
        putlog 'WARNING: Type ' type 'is not yet supported.';
        continue;
      end;
    put '%put NOTE- ;';
    put '%put NOTE- Element of type ' type 'from the file "' file +(-1) '" will be included;' /;

    if upcase(type)=:'EXEC' then
    do;
      put '%put NOTE- ;';
      put '%put NOTE- Executing the following code: ;';
      put '%put NOTE- *****************************;';
      put 'data _null_;';
      put "  infile &_PackageFileref_.(_" folder +(-1) "." file +(-1) ') lrecl=32767;';
      put '  input;';
      put '  putlog "*> " _infile_;';
      put 'run;' /;
      put '%put NOTE- *****************************;';
      put '%put NOTE- ;';
    end;

    /* HEADERS for IML and FCMP */
    if 1 = FIRST.type and upcase(type)='FUNCTIONS' then /* header, for multiple functions in one FCMP run */
      do;
        put "proc fcmp outlib = work.%lowcase(&packageName.fcmp).package; ";
      end;
    if 1 = FIRST.type and upcase(type)='IMLMODULE' then /* header, for IML modules */
      do;
        put "proc iml; ";
      end;

    /* include the file with the code of the element */
    put '%include' " &_PackageFileref_.(_" folder +(-1) "." file +(-1) ') / nosource2;' /;

    /* FOOTERS for IML and FCMP */
    if 1 = LAST.type and upcase(type)='FUNCTIONS' then /* footer, for multiple functions in one FCMP run */
      do;
        put "run; ";
      end;
    if 1 = LAST.type and upcase(type)='IMLMODULE' then /* footer, for IML modules */
      do;
        put "reset storage = WORK.&packageName.IML; "; /* set the storage location for modules */
        put "store module = _ALL_;                  "; /* and store all created modules */
        put "quit;                                  ";
      end;

    isFunction + (upcase(type)=:'FUNCTION');
    isFormat   + (upcase(type)=:'FORMAT'); 
  
    /* add the link to the functions' dataset, only for the first occurrence */
    if 1 = isFunction and (upcase(type)=:'FUNCTION') then
      do;
        put "options APPEND=(cmplib = work.%lowcase(&packageName.fcmp));";
        put '%put NOTE- ;';
        put '%put NOTE:[CMPLIB] %sysfunc(getoption(cmplib));' /;
      end;

    /* add the link to the formats' catalog, only for the first occurrence  */
    if 1 = isFormat and (upcase(type)=:'FORMAT') then
      do;
        put "options INSERT=( fmtsearch = work.%lowcase(&packageName.format) );";
        put '%put NOTE- ;';
        put '%put NOTE:[FMTSEARCH] %sysfunc(getoption(fmtsearch));'/;
      end;
  end;

  /* update SYSloadedPackages global macrovariable */
  put ' data _null_ ;                                                                                              ';
  put '  length SYSloadedPackages stringPCKG $ 32767;                                                              ';
  put '  if SYMEXIST("SYSloadedPackages") = 1 and SYMGLOBL("SYSloadedPackages") = 1 then                           ';
  put '    do;                                                                                                     ';
  put '      do until(EOF);                                                                                        ';
  put '        set sashelp.vmacro(where=(scope="GLOBAL" and name="SYSLOADEDPACKAGES")) end=EOF;                    ';
  put '        substr(SYSloadedPackages, 1+offset, 200) = value;                                                   ';
  put '      end;                                                                                                  ';
  put '      SYSloadedPackages = cats("#", translate(strip(SYSloadedPackages), "#", " "), "#");                    ';

  put "      indexPCKG = INDEX(lowcase(SYSloadedPackages), '#%lowcase(&packageName.)(');                           ";
  put "      if indexPCKG = 0 then                                                                                 ";
  put '         do;                                                                                                ';
  put "          SYSloadedPackages = catx('#', SYSloadedPackages, '&packageName.(&packageVersion.)');              ";
  put '          SYSloadedPackages = compbl(translate(SYSloadedPackages, " ", "#"));                               ';
  put '          call symputX("SYSloadedPackages", SYSloadedPackages, "G");                                        ';
  put '          put "NOTE: " SYSloadedPackages = ;                                                                ';
  put '         end ;                                                                                              ';
  put "      else                                                                                                  ";
  put '         do;                                                                                                ';
  put "          stringPCKG = scan(substr(SYSloadedPackages, indexPCKG+1), 1, '#');                                ";
  put '          SYSloadedPackages = compbl(tranwrd(SYSloadedPackages, strip(stringPCKG), "#"));                   ';
  put "          SYSloadedPackages = catx('#', SYSloadedPackages, '&packageName.(&packageVersion.)');              ";
  put '          SYSloadedPackages = compbl(translate(SYSloadedPackages, " ", "#"));                               ';
  put '          call symputX("SYSloadedPackages", SYSloadedPackages, "G");                                        ';
  put '          put "NOTE: " SYSloadedPackages = ;                                                                ';
  put '         end ;                                                                                              ';
  put '    end;                                                                                                    ';
  put '  else                                                                                                      ';
  put '    do;                                                                                                     ';
  put "      call symputX('SYSloadedPackages', '&packageName.(&packageVersion.)', 'G');                            ";
  put "      put 'NOTE: SYSloadedPackages = &packageName.(&packageVersion.)';                                      ";
  put '    end;                                                                                                    ';
  put '  stop;                                                                                                     ';
  put 'run;                                                                                                        ' / ;

  put '%put NOTE- ;';
  put '%put NOTE: '"Loading package &packageName., version &packageVersion., license &packageLicense.;";
  put '%put NOTE- *** END ***;' /;
  put "/* load.sas end */" /;
  stop;
run;

/* to load lazydata */
data _null_;
  if NOBS = 0 then stop;

  file &zipReferrence.(lazydata.sas) lrecl=32767;
 
  put "filename &_PackageFileref_. list;" /;
  put ' %put NOTE- ;'; 
  put ' %put NOTE: ' @; put "Lazy data for package &packageName., version &packageVersion., license &packageLicense.; ";
  put ' %put NOTE: ' @; put "*** &packageTitle. ***; ";
  put ' %put NOTE- ' @; put "Generated: %sysfunc(datetime(), datetime21.); ";
  put ' %put NOTE- ' @; put "Author(s): &packageAuthor.; ";
  put ' %put NOTE- ' @; put "Maintainer(s): &packageMaintainer.; ";
  put ' %put NOTE- ;';
  put ' %put NOTE- Write %nrstr(%%)helpPackage(' "&packageName." ') for the description;';
  put ' %put NOTE- ;';
  put ' %put NOTE- *** START ***; ' /;
  
  /*put '%include ' " &_PackageFileref_.(packagemetadata.sas) / nosource2; " /;*/ /* <- copied also to loadPackage macro */

  put 'data _null_;';
  put ' length lazyData $ 32767; lazyData = lowcase(symget("lazyData"));';
  do until(eof);
    set &filesWithCodes.(where=( upcase(type) =: 'LAZYDATA' )) end = EOF nobs=NOBS;

    put 'if lazyData="*" OR findw(lazyData, "' fileshort +(-1) '") then';
    put 'do;';
    put ' put "NOTE- Dataset ' fileshort 'from the file ""' file +(-1) '"" will be loaded";';
    put ' call execute(''%nrstr(%include' " &_PackageFileref_.(_" folder +(-1) "." file +(-1) ') / nosource2;)'');';
    put 'end;';
  end;
  put 'run;';

  put '%put NOTE- ;';
  put '%put NOTE: '"Lazy data for package &packageName., version &packageVersion., license &packageLicense.;";
  put '%put NOTE- *** END ***;' /;
  put "/* lazydata.sas end */" /;
  stop;
run;


/* unloading package objects */
data _null_;
  /* break if no data */
  if NOBS = 0 then stop;

  file &zipReferrence.(unload.sas);

  put "filename &_PackageFileref_. list;" /;
  put '%put NOTE: '"Unloading package &packageName., version &packageVersion., license &packageLicense.;";
  put '%put NOTE- *** START ***;' /;

  /* include "cleaning" files */
  EOF = 0;
  do until(EOF);
    set &filesWithCodes. end = EOF nobs = NOBS;
    if not (upcase(type)=:'CLEAN') then continue;
    put '%put NOTE- Code of type ' type 'generated from the file "' file +(-1) '" will be executed;';
    put '%put NOTE- ;' /;
    put '%put NOTE- Executing the following code: ;';
    put '%put NOTE- *****************************;';
    put 'data _null_;';
    put "  infile &_PackageFileref_.(_" folder +(-1) "." file +(-1) ') lrecl=32767;';
    put '  input;';
    put '  putlog "*> " _infile_;';
    put 'run;' /;
    put '%put NOTE- *****************************;';
    put '%put NOTE- ;' /;

    put '%include' " &_PackageFileref_.(_" folder +(-1) "." file +(-1) ') / nosource2;' /;
  end;

  /* delete macros and formats */
  put 'proc sql;';
  put '  create table WORK._%sysfunc(datetime(), hex16.)_ as';
  put '  select memname, objname, objtype';
  put '  from dictionary.catalogs';
  put '  where ';
  put '  (';
  put '   objname in ("*"' /;
  /* list of macros */
  EOF = 0;
  do until(EOF);
    set &filesWithCodes. end = EOF nobs = NOBS;
    if not (upcase(type)=:'MACRO') then continue;
    put '%put NOTE- Element of type ' type 'generated from the file "' file +(-1) '" will be deleted;';
    put '%put NOTE- ;' /;
    put ',"' fileshort upcase32. '"';
  end;
  /**/
  put '  )';
  put '  and objtype = "MACRO"';
  put '  and libname  = "WORK"';
  put '  )';
  put '  or';
  put '  (';
  put '   objname in ("*"' /;
  /* list of formats */
  isFormat = 0;
  EOF = 0;
  do until(EOF);
    set &filesWithCodes. end = EOF;
    if not (upcase(type)=:'FORMAT') then continue;
    put '%put NOTE- Element of type ' type 'generated from the file "' file +(-1) '" will be deleted;';
    put '%put NOTE- ;' /;
    put ',"' fileshort upcase32. '"';
    isFormat + 1;
  end;
  put '  )';
  put '  and objtype in ("FORMAT" "FORMATC" "INFMT" "INFMTC")';
  put '  and libname  = "WORK"';
  put "  and memname = '%upcase(&packageName.format)'";
  put '  )';

  put '  order by objtype, memname, objname';
  put '  ;';
  put 'quit;';

  put 'data _null_;';
  put '  do until(last.memname);';
  put '    set WORK._last_;';
  put '    by objtype memname;';
  put '    if first.memname then call execute("proc catalog cat = work." !! strip(memname) !! " force;");';
  put '    call execute("delete " !! strip(objname) !! " /  et =" !! objtype !! "; run;");';
  put '  end;';
  put '  call execute("quit;");';
  put 'run;';
  put 'proc delete data = WORK._last_;';
  put 'run;';

  /* delete the link to the formats catalog */
  if isFormat then
    do;
      put "proc delete data = work.%lowcase(&packageName.format)(mtype = catalog);";
      put 'run;';
      put 'options fmtsearch = (%unquote(%sysfunc(tranwrd(' /
          '%lowcase(%sysfunc(getoption(fmtsearch)))' /
          ',%str(' "work.%lowcase(&packageName.)format" '), %str() ))));';
      put 'options fmtsearch = (%unquote(%sysfunc(compress(' /
          '%sysfunc(getoption(fmtsearch))' /
          ', %str(()) ))));';
      put '%put NOTE:[FMTSEARCH] %sysfunc(getoption(fmtsearch));' /;
    end;

  /* delete functions */
  put "proc fcmp outlib = work.%lowcase(&packageName.fcmp).package;";
  isFunction = 0;
  EOF = 0;
  do until(EOF);
    set &filesWithCodes. end = EOF;
    if not (upcase(type)=:'FUNCTION') then continue;
    put '%put NOTE- Element of type ' type 'generated from the file "' file +(-1) '" will be deleted;';
    put '%put NOTE- ;' /;
    put 'deletefunc ' fileshort ';';
    isFunction + 1;
  end;
  put "run;" /;

  /* delete the link to the functions dataset */
  if isFunction then
    do;
      put 'options cmplib = (%unquote(%sysfunc(tranwrd(' /
          '%lowcase(%sysfunc(getoption(cmplib)))' /
          ',%str(' "work.%lowcase(&packageName.fcmp)" '), %str() ))));';
      put 'options cmplib = (%unquote(%sysfunc(compress(' /
          '%sysfunc(getoption(cmplib))' /
          ',%str(()) ))));';
      put '%put; %put NOTE:[CMPLIB] %sysfunc(getoption(cmplib));' /;
    end;
  
  /* delete IML modules */
  EOF = 0; first.IML = 1;
  do until(EOF);
    set &filesWithCodes. end = EOF;
    if not (upcase(type)=:'IMLMODULE') then continue;
    if first.iml then
      do;
        put "proc delete lib=WORK data=&packageName.IML (memtype=catalog); ";
        put "run; ";
        first.IML = 0;
      end;
    put '%put NOTE- Element of type ' type 'generated from the file "' file +(-1) '" will be deleted;';
    put '%put NOTE- ;' /;
    /* put 'remove module = ' fileshort ';'; */
  end;
 
  /* delete datasets */
  put "proc sql noprint;";
  EOF = 0;
  do until(EOF);
    set &filesWithCodes. end = EOF;
    if not (upcase(type)=:'DATA') then continue;
    put '%put NOTE- Element of type ' type 'generated from the file "' file +(-1) '" will be deleted;';
    put '%put NOTE- ;' /;
    put 'drop table ' fileshort ';';
  end;
  put "quit;" /;

  /* delete libraries */
  EOF = 0;
  do until(EOF);
    set &filesWithCodes. end = EOF;
    if not (upcase(type)=:'LIBNAME') then continue; 
    put '%put NOTE- Element of type ' type 'generated from the file "' file +(-1) '" will be cleared;';
    put '%put NOTE- ;' /;
    put 'libname ' fileshort ' clear;';
  end;
  put "run;" /;

  %if %bquote(&packageReqPackages.) ne %then
    %do;
      length packageReqPackages $ 32767;
      packageReqPackages = lowcase(symget('packageReqPackages'));
      /* note to unload required packages */
      put 'data _null_ ;                                                                              ';
      put '  length req name $ 64;                                                                    ';
      put '  put "NOTE-" / "NOTE: To unload additional required SAS packages execute: " / "NOTE-";    ';
      put '  do req = ' / packageReqPackages / ' ;                                                    ';
      put '    name = strip(scan(req, 1, "("));                                                       ';
      put '    put ''      %unloadPackage( '' name ")" ;                                              ';
      put '  end ;                                                                                    ';
      put ' put "NOTE-" / "NOTE-"; stop;                                                              ';
      put 'run;                                                                                       ';
    %end;


  /* update SYSloadedPackages global macrovariable */
  put ' data _null_ ;                                                                                        ';
  put '  length SYSloadedPackages $ 32767;                                                                   ';
  put '  if SYMEXIST("SYSloadedPackages") = 1 and SYMGLOBL("SYSloadedPackages") = 1 then                     ';
  put '    do;                                                                                               ';
  put '      do until(EOF);                                                                                  ';
  put '        set sashelp.vmacro(where=(scope="GLOBAL" and name="SYSLOADEDPACKAGES")) end=EOF;              ';
  put '        substr(SYSloadedPackages, 1+offset, 200) = value;                                             ';
  put '      end;                                                                                            ';
  put '      SYSloadedPackages = cats("#", translate(strip(SYSloadedPackages), "#", " "), "#");              ';

  put "      if INDEX(lowcase(SYSloadedPackages), '#%lowcase(&packageName.(&packageVersion.))#') > 0 then    ";
  put '         do;                                                                                          ';
  put "          SYSloadedPackages = tranwrd(SYSloadedPackages, '#&packageName.(&packageVersion.)#', '##');  ";
  put '          SYSloadedPackages = compbl(translate(SYSloadedPackages, " ", "#"));                         ';
  put '          call symputX("SYSloadedPackages", SYSloadedPackages, "G");                                  ';
  put '          put "NOTE: " SYSloadedPackages = ;                                                          ';
  put '         end ;                                                                                        ';
  put '    end;                                                                                              ';
  put '  stop;                                                                                               ';
  put 'run;                                                                                                  ' / ;

 
  put '%put NOTE: ' "Unloading package &packageName., version &packageVersion., license &packageLicense.;";
  put '%put NOTE- *** END ***;';
  put '%put NOTE- ;';
 
  put "/* unload.sas end */";
  stop;
run;

/* package help */
data _null_;
  /* break if no data */
  if NOBS = 0 then stop;

  file &zipReferrence.(help.sas);
  length strX $ 32767;

  put "filename &_PackageFileref_. list;" /;
  put ' %put NOTE- ;';
  put ' %put NOTE: '"Help for package &packageName., version &packageVersion., license &packageLicense.;";
  put ' %put NOTE: ' @; put "*** &packageTitle. ***; ";
  put ' %put NOTE- ' @; put "Generated: %sysfunc(datetime(), datetime21.); ";
  put ' %put NOTE- ' @; put "Author(s): &packageAuthor.; ";
  put ' %put NOTE- ' @; put "Maintainer(s): &packageMaintainer.; ";
  put ' %put NOTE- ;';
  put ' %put NOTE- *** START ***;' /;
  
  /* Use helpKeyword macrovariable to search for content (filename and type) */
  /* put '%local ls_tmp ps_tmp notes_tmp source_tmp;                       ';*/
  put '%let ls_tmp     = %sysfunc(getoption(ls));         ';
  put '%let ps_tmp     = %sysfunc(getoption(ps));         ';
  put '%let notes_tmp  = %sysfunc(getoption(notes));      ';
  put '%let source_tmp = %sysfunc(getoption(source));     ';
  put 'options ls = MAX ps = MAX nonotes nosource;        ';
  put '%include' " &_PackageFileref_.(packagemetadata.sas) / nosource2; " /;

  put 'data _null_;                                                              ';
  put '  if strip(symget("helpKeyword")) = " " then                              ';
  put '    do until (EOF);                                                       ';
  put "      infile &_PackageFileref_.(description.sas) end = EOF;               ";
  put '      input;                                                              ';
  put '      if upcase(strip(_infile_)) = "DESCRIPTION END:" then printer = 0;   ';
  put '      if printer then put "*> " _infile_;                                 ';
  put '      if upcase(strip(_infile_)) = "DESCRIPTION START:" then printer = 1; ';
  put '    end;                                                                  ';
  put '  else stop;                                                              ';


  put '  put ; put "  Package contains: "; ';
  EOFDS = 0;
  do until(EOFDS);
    /* content is created during package creation */
    set &filesWithCodes. end = EOFDS nobs = NOBS curobs = CUROBS;
    if upcase(type) in: ('TEST') then continue; /* exclude tests */

    put 'put @5 "' CUROBS +(-1) ')" @10 "' type '" @21 "' fileshort '";';
  end;

  %if %bquote(&packageRequired.) ne %then
  %do;
    length packageRequired $ 32767;
    packageRequired = symget('packageRequired');
    put '  length req $ 64;                                                      ';
    put '  put ; put "  Required SAS Components: ";                              ';
    put '  do req = ' / packageRequired / ' ;                                    ';
    put '    put @5 req;                                                         ';
    put '  end ;                                                                 ';
  %end;

  %if %bquote(&packageReqPackages.) ne %then
  %do;
    length packageReqPackages $ 32767;
    packageReqPackages = symget('packageReqPackages');
    put '  length req $ 64;                                                      ';
    put '  put ; put "  Required SAS Packages: ";                                ';
    put '  do req = ' / packageReqPackages / ' ;                                 ';
    put '    put @5 req;                                                         ';
    put '  end ;                                                                 ';
  %end;

  put 'put "***"; put "* SAS package generated by generatePackage, version 20200730 *"; put "***";';

  put 'run;                                                                      ' /;

  /* license info */
  put 'data _null_;                                                   ';
  put '  if upcase(strip(symget("helpKeyword"))) = "LICENSE" then     ';
  put '    do until (EOF);                                            ';
  put "      infile &_PackageFileref_.(license.sas) end = EOF;        ";
  put '      input;                                                   ';
  put '      put "*> " _infile_;                                      ';
  put '    end;                                                       ';
  put '  else stop;                                                   ';
  put 'run;                                                           ' /;

  put 'data WORK._%sysfunc(datetime(), hex16.)_;                      ';
  put 'infile cards4 dlm = "/";                                       ';
  put 'input @;                                                       ';
  put 'if 0 then output;                                              ';
  put 'length helpKeyword $ 64;                                       ';
  put 'retain helpKeyword "*";                                        ';
  put 'drop helpKeyword;                                              ';
  put 'if _N_ = 1 then helpKeyword = strip(symget("helpKeyword"));    ';
  put 'if FIND(_INFILE_, helpKeyword, "it") or helpKeyword = "*" then '; 
  put ' do;                                                           ';
  put '   input (folder order type file fileshort) (: $ 256.);        ';
  put '   output;                                                     ';
  put ' end;                                                          ';
  put 'cards4;                                                        ';

  EOFDS = 0;
  do until(EOFDS);
    /* content is created during package creation */
    set &filesWithCodes. end = EOFDS;
    if upcase(type) in: ('TEST') then continue; /* exclude tests */

    select;
      when (upcase(type) in ("DATA" "LAZYDATA")) fileshort2 = fileshort;
      when (upcase(type) = "MACRO")              fileshort2 = cats('%',fileshort,'()');
      when (upcase(type) =:"FUNCTION")           fileshort2 = cats(fileshort,'()');
      when (upcase(type) = "FORMAT")             fileshort2 = cats('$',fileshort);
      otherwise fileshort2 = fileshort;
    end;
    strX = catx('/', folder, order, type, file, fileshort, fileshort2);
    put strX;
  end;

  put ";;;;";
  put "run;" /;
/*
  put 'proc print;';
  put 'run;';
*/
  /* loop through content found and print info to the log */
  put 'data _null_;                                                                                              ';
  put 'if upcase(strip(symget("helpKeyword"))) in (" " "LICENSE") then do; stop; end;                            ';
  put 'if NOBS = 0 then do; ' /
        'put; put '' *> No help info found. Try %helpPackage(packageName,*) to display all.''; put; stop; ' / 
      'end; ';
  put '  do until(EOFDS);                                                                                        ';
  put '    set WORK._last_ end = EOFDS nobs = NOBS;                                                              ';
  put '    length memberX $ 1024;                                                                                ';
  put '    memberX = cats("_",folder,".",file);                                                                  ';
  /* inner datastep in call execute to read each embedded file */
  put '    call execute("data _null_;                                                                         ");';
  put "    call execute('infile &_PackageFileref_.(' || strip(memberX) || ') end = EOF;                       ');";
  put '    call execute("    printer = 0;                                                                     ");';
  put '    call execute("    do until(EOF);                                                                   ");';
  put '    call execute("      input;                                                                         ");';
  put '    call execute("      if upcase(strip(_infile_))                                                        ';
  put '                           = cat(""/"",""*** "",""HELP END"","" ***"",""/"") then printer = 0;         ");';   /* it looks like that because of comments */
  put '    call execute("      if printer then put ""*> "" _infile_;                                          ");';
  put '    call execute("      if upcase(strip(_infile_))                                                        ';
  put '                           = cat(""/"",""*** "",""HELP START"","" ***"",""/"") then printer = 1;       ");';   /* it looks like that because of comments */
  put '    call execute("    end;                                                                             ");';
  put '    call execute("  put ""*> "" / ""*> "";                                                             ");';
  put '    call execute("  stop;                                                                              ");';
  put '    call execute("run;                                                                                 ");';
  put '    if lowcase(type) =: "data" then                                                                       ';
  put '      do;                                                                                                 ';
  put '        call execute("title ""Dataset " || strip(fileshort) || " from package &packageName. "";        ");';
  put '        call execute("proc contents data = " || strip(fileshort) || "; run; title;                     ");';
  put '      end;                                                                                                ';
  /**/
  put "  end; ";
  put "  stop; ";
  put "run; ";
  
  /* cleanup */
  put "proc delete data = WORK._last_; ";
  put "run; ";
  put 'options ls = &ls_tmp. ps = &ps_tmp. &notes_tmp. &source_tmp.; ' /;
 
  put '%put NOTE: '"Help for package &packageName., version &packageVersion., license &packageLicense.;";
  put '%put NOTE- *** END ***;' /; 
  put "/* help.sas end */";

  stop;
run;

/* create package content */
data _null_;
  /* break if no data */
  if NOBS = 0 then stop;

  set &filesWithCodes. nobs = NOBS;
  if (upcase(type) not in: ('TEST')); /* test files are not to be copied */

  call execute(cat ('filename _IN_ "', catx('/', base, folder, file), '";'));
  call execute(cats("filename _OUT_ ZIP '", base, "/%lowcase(&packageName.).zip' member='_", folder, ".", file, "';") );
  /* copy code file into the zip */
  call execute('data _null_;');
  call execute('  rc = fcopy("_IN_", "_OUT_");');
  call execute('run;');
  /* test file content for help tags */
  call execute('data _null_;');
  call execute(' retain test .;');
  call execute(' infile _IN_ lrecl=32767 dlm="0a0d"x end=EOF;');
  call execute(' input;');
  call execute(' if upcase(strip(_infile_)) = cat("/","*** ","HELP START"," ***","/") then test + (+1); ');
  call execute(' if upcase(strip(_infile_)) = cat("/","*** ","HELP END",  " ***","/") then test + (-1); ');
  call execute(' if (test not in (.,0,1)) or (EOF and test) then '); 
  call execute('   do; '); 
  call execute('     put "ERR" "OR: unmatching or nested HELP tags!" _N_=; ');
  call execute('     abort; ');
  call execute('   end; ');
  call execute(' if (EOF and test=.) then put "WARN" "ING: no HELP tags in the file." ; ');
  call execute('run;');

  call execute('filename _IN_  clear;');
  call execute('filename _OUT_ clear;');
run;
/*
proc sql;
  drop table &filesWithCodes.;
quit;
*/
filename &zipReferrence. clear;

/* tests of package are executed by default */
%if %bquote(&testPackage.) ne Y %then 
  %do;
    %put WARNING: ** NO TESTING WILL BE EXECUTED **;
    %GOTO NOTESTING;
  %end;
/* check if systask is available  */
%if %sysfunc(GETOPTION(XCMD)) = NOXCMD %then 
  %do;
    %put WARNING: ** NO TESTING WILL BE EXECUTED DUE TO NOXCMD **;
    %GOTO NOTESTING;
  %end;


/* locate sas binaries */
filename sasroot "!SASROOT";
%let SASROOT=%sysfunc(PATHNAME(sasroot));
filename sasroot;
%put *&SASROOT.*;
%let SASEXE=&SASROOT./sas;
%put *&SASEXE.*;
%let SASWORK=%sysfunc(GETOPTION(work));
%put *&SASWORK.*;

options DLCREATEDIR; /* turns-on creation of subdirectories */
/* temporary location for tests results */
libname TEST "&SASWORK./test_%lowcase(%sysfunc(datetime(),b8601dt19.))";
libname TESTWORK "%sysfunc(pathname(TEST))/work";
%local dirForTest;
  %let dirForTest = %sysfunc(pathname(TEST));


/* remember location of sessions current directory */
filename currdir ".";
filename currdir list;

/* if your package uses any other packages this points to their location */
/* test if packages fileref exists and if do then use it */
/* if no one is provided the filesLocation is used as a repalacement */
%if %bquote(&packages.)= %then %let packages=%sysfunc(pathname(packages));
%if %bquote(&packages.)= %then %let packages=&filesLocation.;
filename packages "&packages.";
filename packages list;

/* replace current dir with the temporary one for tests */
%put *NOTE: changing current folder to:*;
%put *%sysfunc(DLGCDIR(&dirForTest.))*;

/* the first test is for loading package, testing help and unloading */
/*-1-*/
data _null_;
  file "./loading.sas";

  put "filename packages '&packages.';" /;

  if fileexist("&packages./SPFinit.sas") then
    put '%include packages(SPFinit.sas);' /;
  else if fileexist("&packages./loadpackage.sas") then
    put '%include packages(loadpackage.sas);' /; /* for older versions when the SPFinit.sas did not exist */

  /* load */
  put '%loadpackage'"(&packageName.,";
  put " path=&filesLocation.)" /;

  /* help */
  put '%helpPackage'"(&packageName.,";
  put " path=&filesLocation.)" /;
  put '%helpPackage'"(&packageName.,*,";
  put " path=&filesLocation.)" /;
  put '%helpPackage'"(&packageName.,License,";
  put " path=&filesLocation.)" /;

  /* unload */
  put '%unloadPackage'"(&packageName.,";
  put " path=&filesLocation.)         " /;
run;

systask kill sas0 wait;
%local sasstat0 TEST_0 TESTRC_0;;
%let TEST_0 = loading;
systask command
"""&SASEXE.""
 -sysin ""&dirForTest./&TEST_0..sas""
 -print ""&dirForTest./&TEST_0..lst""
   -log ""&dirForTest./&TEST_0..log""
 -config ""&SASROOT./sasv9.cfg""
  -work ""&dirForTest./work""
 -noterminal"
taskname=sas0
status=sasstat0
WAIT
;
%let TESTRC_0 = &SYSRC.;
%put *&=sasstat0.*&=TESTRC_0.*;
data _null_;
  infile "./loading.log" dlm='0a0d'x end=EOF;
  input;
  if _N_ > 10; /* due to "Unable to copy SASUSER registry to WORK registry." */
  if _INFILE_ =: 'WARNING:' then 
    do;
      warning+1; 
      put _N_= _INFILE_;
    end;
  if _INFILE_ =: 'ERROR:' then 
    do;
      error+1;
      put _N_= _INFILE_; 
    end;
  if EOF then
    do;
      put (_ALL_) (=/);
      call symputX("TESTW_0", warning, "L");
      call symputX("TESTE_0", error,   "L");
    end;
run;
/*-1-*/


/* other tests are provided by the developer */
%local numberOfTests;
%let numberOfTests = 0;
data _null_;
  /* break if no data */
  if NOBS = 0 then stop;

  set &filesWithCodes. nobs = NOBS;
  if (upcase(type) in: ('TEST')); /* only test files are used */

  test + 1; /* count the number of tests */

  _RC_ = filename(cats("_TIN_",test),  catx("/", base, folder, file));
  _RC_ = filename(cats("_TOUT_",test), cats("./", file));

  _RC_ = fcopy(cats("_TIN_",test), cats("_TOUT_", test));
  
  call symputX(cats("TEST_", test), fileshort, "L");
  call symputX("numberOfTests",     test,      "L");
run;

/* each test is executed with autoexec loading the package */
data _null_;
  file "./autoexec.sas";

  put "filename packages '&packages.';" /;

  if fileexist("&packages./SPFinit.sas") then
    put '%include packages(SPFinit.sas);' /;
  else if fileexist("&packages./loadpackage.sas") then
    put '%include packages(loadpackage.sas);' /; /* for older versions when the SPFinit.sas did not exist */

  put '%loadpackage'"(&packageName.,";
  put " path=&filesLocation.)       " /;
run;

%local t;   
%do t = 1 %to &numberOfTests.;
systask kill sas&t. wait;
%local sasstat&t. TESTRC_&t;
systask command
"""&SASEXE.""
 -sysin ""&dirForTest./&&TEST_&t...sas""
 -print ""&dirForTest./&&TEST_&t...lst""
   -log ""&dirForTest./&&TEST_&t...log""
 -config ""&SASROOT./sasv9.cfg""
  -work ""&dirForTest./work""
 -autoexec ""&dirForTest./autoexec.sas""
 -noterminal"
taskname=sas&t.
status=sasstat&t.
WAIT
;
%let TESTRC_&t = &SYSRC.;
%put *sasstat&t.=&&sasstat&t.*TESTRC_&t=&&TESTRC_&t*;
data _null_;
  infile "./&&TEST_&t...log" dlm='0a0d'x end=EOF;
  input;
  if _N_ > 10; /* due to "Unable to copy SASUSER registry to WORK registry." */
  if _INFILE_ =: 'WARNING:' then 
    do;
      warning+1; 
      /*length warningline $ 1024;
      warningline = catx(',', strip(warningline), _N_);*/
      put _N_= _INFILE_;
    end;
  if _INFILE_ =: 'ERROR:' then 
    do;
      error+1;
      /*length errorline $ 1024;
      errorline = catx(',', strip(errorline), _N_);*/ 
      put _N_= _INFILE_;
    end;
  if EOF then
    do;
      put (_ALL_) (=/);
      call symputX("TESTW_&t.", warning, "L");
      call symputX("TESTE_&t.", error,   "L");
    end;
run;
%end;

data test.tests_summary;
  length testName $ 128;
  do _N_ = 0 to &numberOfTests.;
    testName = symget(cats("TEST_", _N_));
    systask  = input(symget(cats("SASSTAT", _N_)), best32.);
    sysrc    = input(symget(cats("TESTRC_", _N_)), best32.);
    error    = input(symget(cats("TESTE_", _N_)),  best32.);
    warning  = input(symget(cats("TESTW_", _N_)),  best32.);
    output;
  end;
run;
title1 "Summary of tests.";
title2 "details can be found in:";
title3 "%sysfunc(pathname(TEST))";
footnote;
proc print data = test.tests_summary;
run;
title;

/*%put _local_;*/

%put *NOTE: changing current folder to:*;
%put *%sysfunc(DLGCDIR(%sysfunc(pathname(currdir))))*;


/* if you do not want any test to be executed */
%NOTESTING:

proc sql;
  drop table &filesWithCodes.;
quit;


/* jump here after running %generatePackage() - only help is displayed */
%ENDgeneratePackage:
%mend generatePackage;


/*
TODO: (in Polish)

- modyfikacja helpa, sprawdzanie kodu danej funkcji/makra/typu [v]

- opcjonalne sortowanie nazw folderow(<numer>_<typ>) [v]

- wewnetrzna nazwa zmiennej z nazwa pakietu (na potrzeby kompilacji) [v]

- weryfikacja "niepustosci" obowiazkowych argumentow   [v]

- dodac typ "clear" do czyszczenia po plikach 'exec' [v]

- syspackages - makrozmienna z lista zaladowanych pakietow [v] (as SYSloadedPackages)

- dodac typ "iml" [v] (as imlmodule)

- lista wymaganych komponentow potrzebnych do działania SASa (na bazie proc SETINIT) [v]

- sparwdzanie domknietosci, parzystosci i wystepowania tagow HELP START - HELP END w plikach [v]

- add MD5(&packageName.) value hash instead "package" word in filenames [v]

- infolista o required packahes w unloadPackage [v]

- weryfikacja nadpisywania makr [ ]

- dodac ICEloadPackage() [v]

- weryfikacja srodowiska [ ]

- dodac typ "ds2", "proto" [ ]

- dodac mozliwosc szyfrowania pliku z pakietem (haslo do zip, sprawdzic istnienie funkcjonalnosci) [ ]

- doadc sprawdzanie liczby wywolan procedury fcmp, format i slowa '%macro(' w plikach z kodami [ ]

- dodac generowanie funkcji z helpem np. dla funkcji abc() mamy abc_help(), ktora wyswietla to samo co %heplPackage(package, abc()) [ ]
*/

/*** HELP START ***/  

/* Example 1: Enabeling the SAS Package Framework 
    and generating the SQLinDS package from the local directory.

    Assume that the SPFinit.sas file and the SQLinDS 
    folder (containing all package components) are located in 
    the "C:/SAS_PACKAGES/" folder.

    Run the following code in your SAS session:

  filename packages "C:/SAS_PACKAGES"; %* setup a directory for packages; 
  %include packages(SPFinit.sas);      %* enable the framework;

  ods html;
  %generatePackage(filesLocation=C:/SAS_PACKAGES/SQLinDS)

*/

/*** HELP END ***/  
