/*** HELP START ***/      

/**############################################################################**/
/*                                                                              */
/*  Copyright Bartosz Jablonski, July 2019.                                     */
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

/* Macros to load, to get help, or to unload SAS packages, version 20020725  */
/* A SAS package is a zip file containing a group of files
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
des = 'Macro to load SAS package, version 20020725. Run %loadPackage() for help info.'
;
%if %superq(packageName) = %then
  %do;
    %put ;
    %put ###############################################################################;
    %put #        This is short help information for the loadPackage macro             #;
    %put ###############################################################################;
    %put #                                                                             #;
    %put # Macro to load SAS packages, version 20020725                                #;
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
des = 'Macro to unload SAS package, version 20020725. Run %unloadPackage() for help info.'
;
%if %superq(packageName) = %then
  %do;
    %put ;
    %put ###############################################################################;
    %put #        This is short help information for the unloadPackage macro           #;
    %put ###############################################################################;
    %put #                                                                             #;
    %put # Macro to unload SAS packages, version 20020725                              #;
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
des = 'Macro to get help about SAS package, version 20020725. Run %helpPackage() for help info.'
;
%if %superq(packageName) = %then
  %do;
    %put ;
    %put ###############################################################################;
    %put #        This is short help information for the helpPackage macro             #;
    %put ###############################################################################;
    %put #                                                                             #;
    %put # Macro to get help about SAS packages, version 20020725                      #;
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

 * optional;

  libname packages "C:/SAS_PACKAGES/";
  %include "%sysfunc(pathname(packages))/loadpackage.sas";

  %loadPackage(SQLinDS)
  %helpPackage(SQLinDS)
  %unloadPackage(SQLinDS)

 * in case when user SAS session does not support ZIP fileref ;
 * the following solution could be used,                      ;
 * unzip packagename.zip content into packagename.disk folder ;
 * and run macros with following options:                     ;

  %loadPackage(packageName,zip=disk,options=)
  %helpPackage(packageName,,zip=disk,options=) %* mind double comma! ;
  %unloadPackage(packageName,zip=disk,options=) 

*/
/*** HELP END ***/


/*** HELP START ***/
/* Macros to install SAS packages, version 20200603  */
/* A SAS package is a zip file containing a group of files
   with SAS code (macros, functions, datasteps generating 
   data, etc.) wrapped up together and %INCLUDEed by
   a single load.sas file (also embedded inside the zip).
*/

/*** HELP END ***/

/*** HELP START ***/
%macro installPackage(
  packageName  /* package name, without the zip extension */
, sourcePath = /* location of the package, e.g. "www.some.page/", mind the "/" at the end */
, replace = 1  /* 1 = replace if the package already exist, 0 = otherwise */
)
/secure  
/*** HELP END ***/
des = 'Macro to install SAS package, version 20020725. Run %%installPackage() for help info.'
;
%if %superq(packageName) = %then
  %do;
    %put ;
    %put ###############################################################################;
    %put #        This is short help information for the installPackage macro          #;
    %put ###############################################################################;
    %put #                                                                             #;
    %put # Macro to install SAS packages, version 20020725                             #;
    %put #                                                                             #;
    %put # A SAS package is a zip file containing a group                              #;
    %put # of SAS codes (macros, functions, datasteps generating                       #;
    %put # data, etc.) wrapped up together and included by                             #;
    %put # a single load.sas file (also embedded inside the zip).                      #;
    %put #                                                                             #;
    %put # Parameters:                                                                 #;
    %put #                                                                             #;
    %put #  packageName  Name of a package, e.g. myPackage,                            #;
    %put #               Required and not null, default use case:                      #;
    %put #                %nrstr(%%installPackage(myPackage)).                                  #;
    %put #               If empty displays this help information.                      #;
    %put #                                                                             #;
    %put #  sourcePath=  Location of the package, e.g. "www.some.web.page/"            #;
    %put #               Mind the "/" at the end of the path!                          #;
    %put #               Current default location:                                     #;
    %put #               https://raw.githubusercontent.com/yabwon/SAS_PACKAGES/master/ #;    
    %put #                                                                             #;
    %put #  replace=     With default value of 1 it causes existing package file       #;
    %put #               to be replaceed by new downloaded file.                       #;
    %put #                                                                             #;
    %put ###############################################################################;
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
      %let sourcePath = https://raw.githubusercontent.com/yabwon/SAS_PACKAGES/master/;
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
/* Example 1:

  filename packages "C:/Users/&sysuserid/Desktop/download_test/";

  %installPackage(SQLinDS);
  %installPackage(SQLinDS);
  %installPackage(SQLinDS,replace=0);


  %installPackage(NotExistingPackage);

*/
/*** HELP END ***/
