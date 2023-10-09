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
  Copyright (c) 2019 - 2023 Bartosz Jablonski (yabwon@gmail.com)

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

  Version 20231009.
  See examples below.

  A SAS package is a zip file containing a group of files
  with SAS code (macros, functions, data steps generating 
  data, etc.) wrapped up together and %INCLUDEed by
  a single load.sas file (also embedded inside the zip).
*/

/*** HELP END ***/

/*+loadPackage+*/
/*** HELP START ***/

%macro loadPackage(
  packageName                         /* name of a package, 
                                         e.g. myPackage, 
                                         required and not null  */
, path = %sysfunc(pathname(packages)) /* location of a package, 
                                         by default it looks for 
                                         location of "packages" fileref */
, options = %str(LOWCASE_MEMNAME)     /* possible options for ZIP filename */
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
                                         if the zip is not available use a folder
                                         unpack data to "pipackage.disk" folder
                                         and use loadPackage in the form: 
                                         %loadPackage(PiPackage, zip=disk, options=) */
, cherryPick=*                        /* space separated list of selected elements of the package
                                         to be loaded into the session, default value "*" means
                                         "load all elements of the package" */
, loadAddCnt=0                        /* should the additional content be loaded?
                                         default is 0 - means No, 1 means Yes */
, suppressExec=0                      /* indicates if loading of exec files 
                                         should be suppressed, 1=suppress 
                                       */
)/secure 
/*** HELP END ***/
des = 'Macro to load SAS package, version 20231009. Run %loadPackage() for help info.'
minoperator
;
%if (%superq(packageName) = ) OR (%qupcase(&packageName.) = HELP) %then
  %do;
    %local options_tmp ;
    %let options_tmp = ls=%sysfunc(getoption(ls))ps=%sysfunc(getoption(ps))
     %sysfunc(getoption(notes)) %sysfunc(getoption(source))
     msglevel=%sysfunc(getoption(msglevel))
    ;
    options NOnotes NOsource ls=MAX ps=MAX msglevel=N;
    %put ;
    %put #################################################################################;
    %put ###      This is short help information for the `loadPackage` macro             #;
    %put #-------------------------------------------------------------------------------#;
    %put #                                                                               #;
    %put # Macro to *load* SAS packages, version `20231009`                              #;
    %put #                                                                               #;
    %put # A SAS package is a zip file containing a group                                #;
    %put # of SAS codes (macros, functions, data steps generating                        #;
    %put # data, etc.) wrapped up together and included by                               #;
    %put # a single `load.sas` file (also embedded inside the zip).                      #;
    %put #                                                                               #;
    %put # The `%nrstr(%%loadPackage())` macro loads package content, i.e. macros,                #;
    %put # functions, formats, etc., from the zip into the SAS session.                  #;
    %put #                                                                               #;
    %put #-------------------------------------------------------------------------------#;
    %put #### Parameters:                                                                #;
    %put #                                                                               #;
    %put # 1. `packageName`      *Required.* Name of a package, e.g. myPackage,          #;
    %put #                       Required and not null, default use case:                #;
    %put #                        `%nrstr(%%loadPackage(myPackage)).`                             #;
    %put #                       If empty displays this help information.                #;
    %put #                                                                               #;
    %put # - `path=`             *Optional.* Location of a package. By default it        #;
    %put #                       looks for location of the **packages** fileref, i.e.    #;
    %put #                        `%nrstr(%%sysfunc(pathname(packages)))`                         #;
    %put #                                                                               #;
    %put # - `options=`          *Optional.* Possible options for ZIP filename,          #;
    %put #                       default value: `LOWCASE_MEMNAME`                        #;
    %put #                                                                               #;
    %put # - `source2=`          *Optional.* Option to print out details about           #;
    %put #                       what is loaded, null by default.                        #;
    %put #                                                                               #;
    %put # - `requiredVersion=`  *Optional.* Option to test if the loaded                #;
    %put #                       package is provided in required version,                #;
    %put #                       default value: `.`                                      #;
    %put #                                                                               #;
    %put # - `lazyData=`         *Optional.* A space separated list of names of lazy     #;
    %put #                       datasets to be loaded. If not null datasets from the    #;
    %put #                       list are loaded instead of the package.                 #;
    %put #                       An asterisk (*) means *load all lazy datasets*.         #;
    %put #                                                                               #;
    %put # - `zip=`              *Optional.* Standard package is zip (lowcase),          #;
    %put #                        e.g. `%nrstr(%%loadPackage(PiPackage))`.                        #;
    %put #                       If the zip is not available use a folder.               #;
    %put #                       Unpack data to "pipackage.disk" folder                  #;
    %put #                       and use loadPackage in the following form:              #;
    %put #                        `%nrstr(%%loadPackage(PiPackage, zip=disk, options=))`          #;
    %put #                                                                               #;
    %put # - `cherryPick=`       *Optional.* A space separated list of selected elements #;
    %put #                       of the package to be loaded into the SAS session.       #;
    %put #                       Default value of an asterisk (*) means:                 #;
    %put #                       "load all elements of the package".                     #;
    %put #                                                                               #;
    %put # - `loadAddCnt=`       *Optional.* A package zip may contain additional        #;
    %put #                       content. The option indicates if it should be loaded    #;
    %put #                       Default value of zero (`0`) means "No", one (`1`)       #;
    %put #                       means "Yes". Content is extracted into the **Work**     #;
    %put #                       directory in `<packageName>_AdditionalContent` folder.  #;
    %put #                       For other locations use `%nrstr(%%loadPackageAddCnt())` macro.   #;
    %put #                                                                               #;
    %put # - `suppressExec=`     *Optional.* Indicates if loading of `exec` type files   #;
    %put #                       should be suppressed, default value is `0`,             #;
    %put #                       when set to `1` `exec` files are *not* loaded           #;
    %put #                                                                               #;
    %put #-------------------------------------------------------------------------------#;
    %put #                                                                               #;
    %put # Visit: `https://github.com/yabwon/SAS_PACKAGES/tree/main/SPF/Documentation`   #;
    %put # to learn more.                                                                #;
    %put #                                                                               #;
    %put ### Example 1 ###################################################################;
    %put #                                                                               #;
    %put #   Enabling the SAS Package Framework                                          #;
    %put #   from the local directory and installing & loading                           #;
    %put #   the SQLinDS package from the Internet.                                      #;
    %put #                                                                               #;
    %put #   Assume that the `SPFinit.sas` file                                          #;
    %put #   is located in the "C:/SAS_PACKAGES/" folder.                                #;
    %put #                                                                               #;
    %put #   Run the following code in your SAS session:                                 #;
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas;
    %put  %nrstr( filename packages "C:/SAS_PACKAGES"; %%* setup a directory for packages;        );
    %put  %nrstr( %%include packages(SPFinit.sas);      %%* enable the framework;                 );
    %put  ;
    %put  %nrstr( %%installPackage(SQLinDS)  %%* install the package from the Internet;           );
    %put  %nrstr( %%helpPackage(SQLinDS)     %%* get help about the package;                      );
    %put  %nrstr( %%loadPackage(SQLinDS)     %%* load the package content into the SAS session;   );
    %put  %nrstr( %%unloadPackage(SQLinDS)   %%* unload the package content from the SAS session; );
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
    %put #                                                                               #;
    %put ### Example 2 ###################################################################;
    %put #                                                                               #;
    %put #   Enabling the SAS Package Framework                                          #;
    %put #   from the local directory and installing & cherry picking                    #;
    %put #   elements of the BasePlus package.                                           #;
    %put #                                                                               #;
    %put #   Assume that the `SPFinit.sas` file                                          #;
    %put #   is located in the "C:/SAS_PACKAGES/" folder.                                #;
    %put #                                                                               #;
    %put #   Run the following code in your SAS session:                                 #;
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas;
    %put  %nrstr( filename packages "C:/SAS_PACKAGES"; %%* setup a directory for packages;        );
    %put  %nrstr( %%include packages(SPFinit.sas);      %%* enable the framework;                 );
    %put  ;
    %put  %nrstr( %%installPackage(BasePlus) %%* install the package from the Internet;           );
    %put  %nrstr( %%loadPackage(BasePlus, cherryPick=getVars) %%* cherry pick the content;        );
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
    %put #                                                                               #;
    %put #################################################################################;
    %put ;
    options &options_tmp.;
    %GOTO ENDofloadPackage;
  %end;
  /* local variables for options */
  %local ls_tmp ps_tmp notes_tmp source_tmp stimer_tmp fullstimer_tmp msglevel_tmp;
  %let ls_tmp         = %sysfunc(getoption(ls));
  %let ps_tmp         = %sysfunc(getoption(ps));
  %let notes_tmp      = %sysfunc(getoption(notes));
  %let source_tmp     = %sysfunc(getoption(source));
  %let stimer_tmp     = %sysfunc(getoption(stimer));
  %let fullstimer_tmp = %sysfunc(getoption(fullstimer));
  %let msglevel_tmp   = %sysfunc(getoption(msglevel));

  options NOnotes NOsource ls=MAX ps=MAX NOfullstimer NOstimer msglevel=N;

  %local _PackageFileref_;
  /* %let _PackageFileref_ = P%sysfunc(MD5(%lowcase(&packageName.)),hex7.); */
  data _null_; call symputX("_PackageFileref_", "P" !! put(MD5("%lowcase(&packageName.)"), hex7. -L), "L"); run;

  /* when the packages reference is multi-directory search for the first one containing the package */
  data _null_;
    exists = 0;
    length packages $ 32767 p $ 4096;
    packages = resolve(symget("path"));
    if char(packages,1) ^= "(" then packages = quote(strip(packages)); /* for paths with spaces */
    do i = 1 to kcountw(packages, "()", "QS");
      p = dequote(kscanx(packages, i, "()", "QS"));
      exists + fileexist(catx("/", p, "%lowcase(&packageName.).&zip."));
      if exists then leave;
    end;
    if exists then call symputx("path", p, "L");
  run;
  
  /* convert cherryPick to lower case if needed */
  %if NOT (%str(*) = %superq(cherryPick)) %then
    %do;
      data _null_;
        call symputX("cherryPick",lowcase(compbl(compress(symget("cherryPick"),". _","KDA"))),"L");
      run;
    %end;
  /* empty list is equivalent to "*" */ 
  %if %superq(cherryPick)= %then 
    %do;
      %let cherryPick=*;
    %end;

  %if %superq(loadAddCnt) NE 1 %then
    %do;
      %let loadAddCnt = 0;
    %end;

  %if %superq(suppressExec) NE 1 %then
    %do;
      %let suppressExec = 0;
    %end;

  filename &_PackageFileref_. &ZIP. 
  /* put location of package myPackageFile.zip here */
    "&path./%lowcase(&packageName.).&zip." %unquote(&options.)
  ;
  %if %sysfunc(fexist(&_PackageFileref_.)) %then
    %do;
      %include &_PackageFileref_.(packagemetadata.sas) / &source2.;
      filename &_PackageFileref_. clear;

      /* test if required version of package is "good enough" */
      %local rV pV;
      %let pV = %sysfunc(compress(&packageVersion.,.,kd));
      %let pV = %sysevalf((%scan(&pV.,1,.,M)+0)*1e8
                        + (%scan(&pV.,2,.,M)+0)*1e4
                        + (%scan(&pV.,3,.,M)+0)*1e0);
      %let rV = %sysfunc(compress(&requiredVersion.,.,kd));
      %let rV = %sysevalf((%scan(&rV.,1,.,M)+0)*1e8
                        + (%scan(&rV.,2,.,M)+0)*1e4
                        + (%scan(&rV.,3,.,M)+0)*1e0);
      
      %if %sysevalf(&rV. > &pV.) %then
        %do;
          %put ERROR: Package &packageName. will not be loaded!;
          %put ERROR- Required version is &requiredVersion.;
          %put ERROR- Provided version is &packageVersion.;
          %put ERROR- Verify installed version of the package.;
          %put ERROR- ;
          %GOTO WrongVersionOFPackage; /*%RETURN;*/
        %end;

      options ls = &ls_tmp. ps = &ps_tmp. &notes_tmp. &source_tmp.;
      filename &_PackageFileref_. &ZIP. 
        "&path./%lowcase(&packageName.).&zip." %unquote(&options.)
        ENCODING =
          %if %bquote(&packageEncoding.) NE %then &packageEncoding. ;
                                            %else utf8 ;
      ;
      %if %superq(lazyData) = %then
        %do;
          %local tempLoad_minoperator;
          %let tempLoad_minoperator = %sysfunc(getoption(minoperator));
          options minoperator; /* MinOperator option is required for cherryPicking to work */
          %include &_PackageFileref_.(load.sas) / &source2.;
          options &tempLoad_minoperator.;
          %if 1 = &loadAddCnt. %then
            %do;
              %put; %put - Additional content loading - Start -;
              %loadPackageAddCnt(&packageName., 
                                 path=&path.)
              %put - Additional content loading - End -;
            %end;
        %end;
      %else
        %do;
          %include &_PackageFileref_.(lazydata.sas) / &source2.;
        %end;

    %end;
  %else %put ERROR:[&sysmacroname] File "&path./&packageName..&zip." does not exist!;
  filename &_PackageFileref_. clear;
  
  %WrongVersionOFPackage:

  /* restore optionos */
  options ls = &ls_tmp. ps = &ps_tmp. 
          &notes_tmp. &source_tmp. 
          &stimer_tmp. &fullstimer_tmp.
          msglevel=&msglevel_tmp.;

%ENDofloadPackage:
%mend loadPackage;

/*+unloadPackage+*/
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
                                         if the zip is not available use a folder
                                         unpack data to "pipackage.disk" folder
                                         and use unloadPackage in the form: 
                                         %unloadPackage(PiPackage, zip=disk, options=) 
                                       */
)/secure
/*** HELP END ***/
des = 'Macro to unload SAS package, version 20231009. Run %unloadPackage() for help info.'
;
%if (%superq(packageName) = ) OR (%qupcase(&packageName.) = HELP) %then
  %do;
    %local options_tmp ;
    %let options_tmp = ls=%sysfunc(getoption(ls))ps=%sysfunc(getoption(ps))
     %sysfunc(getoption(notes)) %sysfunc(getoption(source))
     msglevel=%sysfunc(getoption(msglevel))
    ;
    options NOnotes NOsource ls=MAX ps=MAX msglevel=N;
    %put ;
    %put #################################################################################;
    %put ###      This is short help information for the `unloadPackage` macro           #;
    %put #-------------------------------------------------------------------------------#;
    %put #                                                                               #;
    %put # Macro to unload SAS packages, version `20231009`                              #;
    %put #                                                                               #;
    %put # A SAS package is a zip file containing a group                                #;
    %put # of SAS codes (macros, functions, data steps generating                        #;
    %put # data, etc.) wrapped up together and provided with                             #;
    %put # a single `unload.sas` file (also embedded inside the zip).                    #;
    %put #                                                                               #;
    %put # The `%nrstr(%%unloadPackage())` macro clears the package content                       #;
    %put # from the SAS session.                                                         #;
    %put #                                                                               #;
    %put #-------------------------------------------------------------------------------#;
    %put #                                                                               #;
    %put #### Parameters:                                                                #;
    %put #                                                                               #;
    %put # 1. `packageName`      *Required.* Name of a package, e.g. myPackage,          #;
    %put #                       Required and not null, default use case:                #;
    %put #                        `%nrstr(%%unloadPackage(myPackage)).`                           #;
    %put #                       If empty displays this help information.                #;
    %put #                                                                               #;
    %put # - `path=`             *Optional.* Location of a package. By default it        #;
    %put #                       looks for location of the **packages** fileref, i.e.    #;
    %put #                        `%nrstr(%%sysfunc(pathname(packages)))`                         #;
    %put #                                                                               #;
    %put # - `options=`          *Optional.* Possible options for ZIP filename,          #;
    %put #                       default value: `LOWCASE_MEMNAME`                        #;
    %put #                                                                               #;
    %put # - `source2=`          *Optional.* Option to print out details about           #;
    %put #                       what is loaded, null by default.                        #;
    %put #                                                                               #;
    %put # - `zip=`              Standard package is zip (lowcase),                      #;
    %put #                        e.g. `%nrstr(%%unloadPackage(PiPackage))`.                      #;
    %put #                       If the zip is not available use a folder.               #;
    %put #                       Unpack data to "pipackage.disk" folder                  #;
    %put #                       and use unloadPackage in the following form:            #;
    %put #                        `%nrstr(%%unloadPackage(PiPackage, zip=disk, options=))`        #;
    %put #                                                                               #;
    %put #-------------------------------------------------------------------------------#;
    %put #                                                                               #;
    %put # Visit: `https://github.com/yabwon/SAS_PACKAGES/tree/main/SPF/Documentation`   #;
    %put # to learn more.                                                                #;
    %put #                                                                               #;
    %put ### Example #####################################################################;
    %put #                                                                               #;
    %put #   Enabling the SAS Package Framework                                          #;
    %put #   from the local directory and installing & loading                           #;
    %put #   the SQLinDS package from the Internet.                                      #;
    %put #                                                                               #;
    %put #   Assume that the `SPFinit.sas` file                                          #;
    %put #   is located in the "C:/SAS_PACKAGES/" folder.                                #;
    %put #                                                                               #;
    %put #   Run the following code in your SAS session:                                 #;
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas;
    %put  %nrstr( filename packages "C:/SAS_PACKAGES"; %%* setup a directory for packages;        );
    %put  %nrstr( %%include packages(SPFinit.sas);      %%* enable the framework;                 );
    %put  ;
    %put  %nrstr( %%installPackage(SQLinDS)  %%* install the package from the Internet;           );
    %put  %nrstr( %%helpPackage(SQLinDS)     %%* get help about the package;                      );
    %put  %nrstr( %%loadPackage(SQLinDS)     %%* load the package content into the SAS session;   );
    %put  %nrstr( %%unloadPackage(SQLinDS)   %%* unload the package content from the SAS session; );
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
    %put #################################################################################;
    %put ;
    options &options_tmp.;
    %GOTO ENDofunloadPackage;
  %end;

  /* local variables for options */
  %local ls_tmp ps_tmp notes_tmp source_tmp msglevel_tmp;
  %let ls_tmp       = %sysfunc(getoption(ls));
  %let ps_tmp       = %sysfunc(getoption(ps));
  %let notes_tmp    = %sysfunc(getoption(notes));
  %let source_tmp   = %sysfunc(getoption(source));
  %let msglevel_tmp = %sysfunc(getoption(msglevel));

  options NOnotes NOsource ls=MAX ps=MAX msglevel=N;

  %local _PackageFileref_;
  /* %let _PackageFileref_ = P%sysfunc(MD5(%lowcase(&packageName.)),hex7.); */
  data _null_; call symputX("_PackageFileref_", "P" !! put(MD5("%lowcase(&packageName.)"), hex7. -L), "L"); run;

  /* when the packages reference is multi-directory search for the first one containing the package */
  data _null_;
    exists = 0;
    length packages $ 32767 p $ 4096;
    packages = resolve(symget("path"));
    if char(packages,1) ^= "(" then packages = quote(strip(packages)); /* for paths with spaces */
    do i = 1 to kcountw(packages, "()", "QS");
      p = dequote(kscanx(packages, i, "()", "QS"));
      exists + fileexist(catx("/", p, "%lowcase(&packageName.).&zip."));
      if exists then leave;
    end;
    if exists then call symputx("path", p, "L");
  run;
 
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
  %else %put ERROR:[&sysmacroname] File "&path./&packageName..&zip." does not exist!;
  filename &_PackageFileref_. clear;

  options ls = &ls_tmp. ps = &ps_tmp. &notes_tmp. &source_tmp. msglevel = &msglevel_tmp.;

%ENDofunloadPackage:
%mend unloadPackage;

/*+helpPackage+*/
/*** HELP START ***/

%macro helpPackage(
  packageName                         /* name of a package, 
                                         e.g. myPackageFile.zip, 
                                         required and not null  */
, helpKeyword                         /* phrase to search in help,
                                         when empty prints description 
                                         "*" means print all help 
                                         "license" prints license */
, path = %sysfunc(pathname(packages)) /* location of a package, 
                                         by default it looks for 
                                         location of "packages" fileref */
, options = %str(LOWCASE_MEMNAME)     /* possible options for ZIP filename */
, source2 = /*source2*/               /* option to print out details, 
                                         null by default */
, zip = zip                           /* standard package is zip (lowcase), 
                                         e.g. %helpPackage(PiPackage,*)
                                         if the zip is not available use a folder
                                         unpack data to "pipackage.disk" folder
                                         and use helpPackage in the form: 
                                         %helpPackage(PiPackage, *, zip=disk, options=) */
, packageContentDS = 0                 /* indicates if a data set with package 
                                          content should be generated in WORK,
                                          if set to 1 then WORK.packageName_content
                                          dataset is created 
                                        */
)/secure
/*** HELP END ***/
des = 'Macro to get help about SAS package, version 20231009. Run %helpPackage() for help info.'
;
%if (%superq(packageName) = ) OR (%qupcase(&packageName.) = HELP) %then
  %do;
    %local options_tmp ;
    %let options_tmp = ls=%sysfunc(getoption(ls))ps=%sysfunc(getoption(ps))
     %sysfunc(getoption(notes)) %sysfunc(getoption(source))
     msglevel=%sysfunc(getoption(msglevel))
    ;
    options NOnotes NOsource ls=MAX ps=MAX msglevel=N;
    %put ;
    %put #################################################################################;
    %put ###       This is short help information for the `helpPackage` macro            #;
    %put #-------------------------------------------------------------------------------#;
    %put #                                                                               #;
    %put # Macro to get help about SAS packages, version `20231009`                      #;
    %put #                                                                               #;
    %put # A SAS package is a zip file containing a group                                #;
    %put # of SAS codes (macros, functions, data steps generating                        #;
    %put # data, etc.) wrapped up together and provided with                             #;
    %put # a single `help.sas` file (also embedded inside the zip).                      #;
    %put #                                                                               #;
    %put # The `%nrstr(%%helpPackage())` macro prints in the SAS log help                         #;
    %put # information about the package provided by the developer.                      #;
    %put #                                                                               #;
    %put #-------------------------------------------------------------------------------#;
    %put #                                                                               #;
    %put #### Parameters:                                                                #;
    %put #                                                                               #;
    %put # 1. `packageName`      *Required.* Name of a package, e.g. myPackage,          #;
    %put #                       Required and not null, default use case:                #;
    %put #                        `%nrstr(%%helpPackage(myPackage)).`                             #;
    %put #                       If empty displays this help information.                #;
    %put #                                                                               #;
    %put # 2. `helpKeyword`      *Optional.*  A phrase to search in help,                #;
    %put #                       - when empty prints description,                        #;
    %put #                       - "*" means: print all help,                            #;
    %put #                       - "license" prints the license.                         #;
    %put #                                                                               #;
    %put # - `path=`             *Optional.* Location of a package. By default it        #;
    %put #                       looks for location of the **packages** fileref, i.e.    #;
    %put #                        `%nrstr(%%sysfunc(pathname(packages)))`                         #;
    %put #                                                                               #;
    %put # - `options=`          *Optional.* Possible options for ZIP filename,          #;
    %put #                       default value: `LOWCASE_MEMNAME`                        #;
    %put #                                                                               #;
    %put # - `source2=`          *Optional.* Option to print out details about           #;
    %put #                       what is loaded, null by default.                        #;
    %put #                                                                               #;
    %put # - `zip=`              Standard package is zip (lowcase),                      #;
    %put #                        e.g. `%nrstr(%%helpPackage(PiPackage))`.                        #;
    %put #                       If the zip is not available use a folder.               #;
    %put #                       Unpack data to "pipackage.disk" folder                  #;
    %put #                       and use helpPackage in the following form:              #;
    %put #                        `%nrstr(%%helpPackage(PiPackage, ,zip=disk, options=))`         #;
    %put #                                                                               #;
    %put # - `packageContentDS=` *Optional.* Indicates if a data set with package        #;
    %put #                       content should be generated in `WORK`,                  #;
    %put #                       with default value (`0`) the dataset is not produced,   #;
    %put #                       if set to `1` then `WORK.packageName_content`.          #;
    %put #                                                                               #;
    %put #-------------------------------------------------------------------------------#;
    %put #                                                                               #;
    %put # Visit: `https://github.com/yabwon/SAS_PACKAGES/tree/main/SPF/Documentation`   #;
    %put # to learn more.                                                                #;
    %put #                                                                               #;
    %put #### Example ####################################################################;
    %put #                                                                               #;
    %put #   Enabling the SAS Package Framework                                          #;
    %put #   from the local directory and installing & loading                           #;
    %put #   the SQLinDS package from the Internet.                                      #;
    %put #                                                                               #;
    %put #   Assume that the `SPFinit.sas` file                                          #;
    %put #   is located in the "C:/SAS_PACKAGES/" folder.                                #;
    %put #                                                                               #;
    %put #   Run the following code in your SAS session:                                 #;
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas;
    %put  %nrstr( filename packages "C:/SAS_PACKAGES"; %%* setup a directory for packages;        );
    %put  %nrstr( %%include packages(SPFinit.sas);      %%* enable the framework;                 );
    %put  ;
    %put  %nrstr( %%installPackage(SQLinDS)  %%* install the package from the Internet;           );
    %put  %nrstr( %%helpPackage(SQLinDS)     %%* get help about the package;                      );
    %put  %nrstr( %%loadPackage(SQLinDS)     %%* load the package content into the SAS session;   );
    %put  %nrstr( %%unloadPackage(SQLinDS)   %%* unload the package content from the SAS session; );
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
    %put #################################################################################;
    %put ;
    options &options_tmp.;
    %GOTO ENDofhelpPackage;
  %end;

  /* local variables for options */
  %local ls_tmp ps_tmp notes_tmp source_tmp msglevel_tmp;
  %let ls_tmp       = %sysfunc(getoption(ls));
  %let ps_tmp       = %sysfunc(getoption(ps));
  %let notes_tmp    = %sysfunc(getoption(notes));
  %let source_tmp   = %sysfunc(getoption(source));
  %let msglevel_tmp = %sysfunc(getoption(msglevel));

  options NOnotes NOsource ls=MAX ps=MAX msglevel=N;

  %local _PackageFileref_;
  /* %let _PackageFileref_ = P%sysfunc(MD5(%lowcase(&packageName.)),hex7.); */
  data _null_; call symputX("_PackageFileref_", "P" !! put(MD5("%lowcase(&packageName.)"), hex7. -L), "L"); run;

  /* when the packages reference is multi-directory search for the first one containing the package */
  data _null_;
    exists = 0;
    length packages $ 32767 p $ 4096;
    packages = resolve(symget("path"));
    if char(packages,1) ^= "(" then packages = quote(strip(packages)); /* for paths with spaces */
    do i = 1 to kcountw(packages, "()", "QS");
      p = dequote(kscanx(packages, i, "()", "QS"));
      exists + fileexist(catx("/", p, "%lowcase(&packageName.).&zip."));
      if exists then leave;
    end;
    if exists then call symputx("path", p, "L");
  run;

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
      %if 1=%superq(packageContentDS) %then %let packageContentDS=work.&packageName._content;
                                      %else %let packageContentDS=;

      %include &_PackageFileref_.(help.sas) / &source2.;
    %end;
  %else %put ERROR:[&sysmacroname] File "&path./&packageName..&zip." does not exist!;
  filename &_PackageFileref_. clear;

  options ls = &ls_tmp. ps = &ps_tmp. &notes_tmp. &source_tmp. msglevel = &msglevel_tmp.;

%ENDofhelpPackage:
%mend helpPackage;

/*
TODO:
- macro for testing available packages in the packages folder [DONE] checkout: %listPackages()
- add MD5(&packageName.) value hash instead "package" word in filenames [DONE]
*/

/* Macros to install SAS packages, version 20231009  */
/* A SAS package is a zip file containing a group of files
   with SAS code (macros, functions, data steps generating 
   data, etc.) wrapped up together and %INCLUDEed by
   a single load.sas file (also embedded inside the zip).
*/

/*+installPackage+*/
/*** HELP START ***/

%macro installPackage(
  packagesNames /* space separated list of packages names, without the zip extension */
, sourcePath =  /* location of the package, e.g. "www.some.page/", mind the "/" at the end */
, mirror = 0    /* indicates which location for package source should be used */
, version =     /* indicates which version of a package to install */
, replace = 1   /* 1 = replace if the package already exist, 0 = otherwise */
, URLuser =     /* user name for the password protected URLs */
, URLpass =     /* password for the password protected URLs */
, URLoptions =  /* options for the `sourcePath` URLs */
, loadAddCnt=0  /* should the additional content be loaded?
                   default is 0 - means No, 1 means Yes */
)
/secure
minoperator 
/*** HELP END ***/
des = 'Macro to install SAS package, version 20231009. Run %%installPackage() for help info.'
;
%if (%superq(packagesNames) = ) OR (%qupcase(&packagesNames.) = HELP) %then
  %do;
    %local options_tmp ;
    %let options_tmp = ls=%sysfunc(getoption(ls))ps=%sysfunc(getoption(ps))
     %sysfunc(getoption(notes)) %sysfunc(getoption(source))
     msglevel=%sysfunc(getoption(msglevel))
    ;
    options NOnotes NOsource ls=MAX ps=MAX msglevel=N;
    %put ;
    %put ##############################################################################################;
    %put ###       This is short help information for the `installPackage` macro                      #;
    %put #--------------------------------------------------------------------------------------------#;;
    %put #                                                                                            #;
    %put # Macro to install SAS packages, version `20231009`                                          #;
    %put #                                                                                            #;
    %put # A SAS package is a zip file containing a group                                             #;
    %put # of SAS codes (macros, functions, data steps generating                                     #;
    %put # data, etc.) wrapped up together and embedded inside the zip.                               #;
    %put #                                                                                            #;
    %put # The `%nrstr(%%installPackage())` macro installs the package zip                                     #;
    %put # in the packages folder. The process of installation is equivalent with                     #;
    %put # manual downloading the package zip file into the packages folder.                          #;
    %put #                                                                                            #;
    %put # In case the packages fileref is a multi-directory one the first directory                  #;
    %put # will be selected as a destination.                                                         #;
    %put #                                                                                            #;
    %put #--------------------------------------------------------------------------------------------#;
    %put #                                                                                            #;
    %put #### Parameters:                                                                             #;
    %put #                                                                                            #;
    %put # 1. `packagesNames` Space separated list of packages names _without_                        #;
    %put #                    the zip extension, e.g. myPackage1 myPackage2,                          #;
    %put #                    Required and not null, default use case:                                #;
    %put #                    `%nrstr(%%installPackage(myPackage1 myPackage2))`.                               #;
    %put #                    If empty displays this help information.                                #;
    %put #                    If the package name is *SPFinit* or *SASPackagesFramework*              #;
    %put #                    then the framework itself is downloaded.                                #;
    %put #                                                                                            #;
    %put # - `sourcePath=`   Location of the package, e.g. "www.some.web.page/"                       #;
    %put #                   Mind the "/" at the end of the path!                                     #;
    %put #                   Current default location for packages is:                                #;
    %put #                   `https://github.com/SASPAC/`                                             #;
    %put #                   Current default location for the framework is:                           #;
    %put #                   `https://raw.githubusercontent.com/yabwon/SAS_PACKAGES/main/SPF/`        #;
    %put #                                                                                            #;
    %put # - `mirror=`       Indicates which web location for packages installation is used.          #;
    %put #                   Value `0` indicates:                                                     #;
    %put #                   `https://github.com/SASPAC/`                                             #;
    %put #                   Value `1` indicates:                                                     #;
    %put #                   `https://raw.githubusercontent.com/yabwon/SAS_PACKAGES/main`             #;
    %put #                   Value `2` indicates:                                                     #;
    %put #                   `https://pages.mini.pw.edu.pl/~jablonskib/SASpublic/SAS_PACKAGES`        #;
    %put #                   Default value is `0`.                                                    #;
    %put #                                                                                            #;
    %put # - `version=`      Indicates which historical version of a package to install.              #;
    %put #                   Historical version are available only if `mirror=0` is set.              #;
    %put #                   Default value is null which means "install the latest".                  #;
    %put #                   When there are multiple packages to install version                      #;
    %put #                   is scan sequentially.                                                    #;
    %put #                                                                                            #;
    %put # - `replace=`      With default value of `1` it causes existing package file                #;
    %put #                   to be replaced by new downloaded file.                                   #;
    %put #                                                                                            #;
    %put # - `URLuser=`      A user name for the password protected URLs, no quotes needed.           #;
    %put #                                                                                            #;
    %put # - `URLpass=`      A password for the password protected URLs, no quotes needed.            #;
    %put #                                                                                            #;
    %put # - `URLoptions=`   Options for the `sourcePath` URLs filename. Consult the SAS              #;
    %put #                   documentation for the further details.                                   #;
    %put #                                                                                            #;
    %put # - `loadAddCnt=`   *Optional.* A package zip may contain additional                         #;
    %put #                   content. The option indicates if it should be loaded                     #;
    %put #                   Default value of zero (`0`) means "No", one (`1`)                        #;
    %put #                   means "Yes". Content is extracted into the **packages** fileref          #;
    %put #                   directory in `<packageName>_AdditionalContent` folder.                   #;
    %put #                   For other locations use `%nrstr(%%loadPackageAddCnt())` macro.                    #;
    %put #                                                                                            #;
    %put #--------------------------------------------------------------------------------------------#;
    %put #                                                                                            #;
    %put # Visit: `https://github.com/yabwon/SAS_PACKAGES/tree/main/SPF/Documentation`                #;
    %put # to learn more.                                                                             #;
    %put #                                                                                            #;
    %put #### Example #################################################################################;
    %put #                                                                                            #;
    %put #   Enabling the SAS Package Framework                                                       #;
    %put #   from the local directory and installing & loading                                        #;
    %put #   the SQLinDS package from the Internet.                                                   #;
    %put #                                                                                            #;
    %put #   Assume that the `SPFinit.sas` file                                                       #;
    %put #   is located in the "C:/SAS_PACKAGES/" folder.                                             #;
    %put #                                                                                            #;
    %put #   Run the following code in your SAS session:                                              #;
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas;
    %put  %nrstr( filename packages "C:/SAS_PACKAGES"; %%* setup a directory for packages;                     );
    %put  %nrstr( %%include packages(SPFinit.sas);      %%* enable the framework;                              );
    %put  ;
    %put  %nrstr( %%installPackage(SQLinDS)  %%* install the package from the Internet;                        );
    %put  %nrstr( %%helpPackage(SQLinDS)     %%* get help about the package;                                   );
    %put  %nrstr( %%loadPackage(SQLinDS)     %%* load the package content into the SAS session;                );
    %put  %nrstr( %%unloadPackage(SQLinDS)   %%* unload the package content from the SAS session;              );
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
    %put #### Example #################################################################################;
    %put #                                                                                            #;
    %put #   Enabling the SAS Package Framework                                                       #;
    %put #   from the local directory and installing & loading                                        #;
    %put #   the multiple packages from the Internet.                                                 #; 
    %put #                                                                                            #;
    %put #   Assume that the `SPFinit.sas` file                                                       #;
    %put #   is located in the "C:/SAS_PACKAGES/" folder.                                             #;
    %put #                                                                                            #;
    %put #   Run the following code in your SAS session:                                              #;
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas;
    %put  %nrstr( filename packages "C:/SAS_PACKAGES";                                                         );
    %put  %nrstr( %%include packages(SPFinit.sas);                                                             );
    %put ;
    %put  %nrstr( %%installPackage(baseplus(1.17) macroarray(1.0) dfa(0.5) GSM)                                );
    %put  %nrstr( %%loadPackageS(GSM, baseplus(1.17), macroarray(1.0), dfa(0.5))                               );
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
    %put ##############################################################################################;
    %put ;
    options &options_tmp.;
    %GOTO ENDofinstallPackage;
  %end;

  /* local variables for options */ 
  %local ls_tmp ps_tmp notes_tmp source_tmp stimer_tmp fullstimer_tmp msglevel_tmp;

  %let ls_tmp         = %sysfunc(getoption(ls));
  %let ps_tmp         = %sysfunc(getoption(ps));
  %let notes_tmp      = %sysfunc(getoption(notes));
  %let source_tmp     = %sysfunc(getoption(source));
  %let stimer_tmp     = %sysfunc(getoption(stimer));
  %let fullstimer_tmp = %sysfunc(getoption(fullstimer));
  %let msglevel_tmp   = %sysfunc(getoption(msglevel));

  options NOnotes NOsource ls=MAX ps=MAX NOfullstimer NOstimer msglevel=N;

  /*
  Reference:
  https://blogs.sas.com/content/sasdummy/2011/06/17/how-to-use-sas-data-step-to-copy-a-file-from-anywhere/
  */

  /* in case the 'packages' fileref is multi-directory the first directory will be selected as a destination */
  data _null_;
    if "(" =: pathname("packages") then
    /*      get the firstPackagesPath                                                           */
      call symputX("firstPackagesPath", dequote(kscanx(pathname("packages"), 1, "()", "QS")), "L");
    else
      call symputX("firstPackagesPath", pathname("packages"), "L");
  run;

  %if %superq(sourcePath)= %then
    %do;
      %local SPFinitMirror;
      /* the defaults are: */
      %let SPFinitMirror = https://raw.githubusercontent.com/yabwon/SAS_PACKAGES/main/SPF/SPFinit.sas;
      %let sourcePath = https://raw.githubusercontent.com/yabwon/SAS_PACKAGES/main/packages/;

      %if 0 = %superq(mirror) %then
        %do;
          %let SPFinitMirror = https://raw.githubusercontent.com/yabwon/SAS_PACKAGES/main/SPF/SPFinit.sas;
          %let sourcePath = https://github.com/SASPAC/; /*usercontent*/
          %goto mirrorEnd;
        %end;

      %if 1 = %superq(mirror) %then
        %do;
          %let SPFinitMirror = https://raw.githubusercontent.com/yabwon/SAS_PACKAGES/main/SPF/SPFinit.sas;
          %let sourcePath = https://raw.githubusercontent.com/yabwon/SAS_PACKAGES/main/packages/;
          %goto mirrorEnd;
        %end;
      
      %if 2 = %superq(mirror) %then
        %do;
          %let SPFinitMirror = https://pages.mini.pw.edu.pl/~jablonskib/SASpublic/SAS_PACKAGES/SPF/SPFinit.sas;
          %let sourcePath = https://pages.mini.pw.edu.pl/~jablonskib/SASpublic/SAS_PACKAGES/packages/;
          %goto mirrorEnd;
        %end;
      %mirrorEnd:
      %put INFO: Source path is &sourcePath.;
    %end;
  %else
    %do;
      %let mirror=-1;
      %let SPFinitMirror = &sourcePath.SPFinit.sas;
    %end;

  %local i str;
  /* standardise list of packages */
  %let str = %qsysfunc(compress(%superq(packagesNames),[{(. _)}],kad));
  %let str = %qsysfunc(translate(%superq(str),[[]],{()}));
  %let str = %qsysfunc(transtrn(%superq(str),],%str(] )));
  %let str = %qsysfunc(compbl(%superq(str)));
  %let str = %qsysfunc(transtrn(%superq(str),%str([ ),[));
  %let str = %qsysfunc(transtrn(%superq(str),%str( [),[));
  %let str = %qsysfunc(transtrn(%superq(str),%str( ]),]));
  %let str = %unquote(&str.);
  %let packagesNames = %qsysfunc(translate(%superq(str),(),[]));
  
  %if %length("%sysfunc(compress(%superq(str),[,k))") NE %length("%sysfunc(compress(%superq(str),],k))") %then
    %do;
      %put ERROR: Syntax error in list of packages!;
      %put ERROR- %superq(packagesNames);
      %goto packagesListError;
    %end;
    
  %put ;
  %put INFO: Calling: &packagesNames.;
  
  %do i = 1 %to %sysfunc(countw(&packagesNames., , S));
  /*-++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-*/
    %local packageName packageSubDir vers versA versB;
    %put ;
    /*%put ### %scan(&packagesNames., &i., , S) ###;*/
    %let packageName = %scan(%scan(&packagesNames., &i., , S),1,{[()]});
    %let versA       = %scan(%scan(&packagesNames., &i., , S),2,{[()]});
    %let versB       =       %scan(&version.,       &i., , S);
    %let vers=;
    %if %superq(versB) ne %then %let vers = &versB.;
    %if %superq(versA) ne %then %let vers = &versA.;
    %if -1 = &mirror %then /* ignore version when direct path is provided */
      %do;
        %let vers=;
      %end;
    %put ### &packageName.(&vers.) ###;
    
    %put *** %lowcase(&packageName.) start *****************************************;
    %local in out _IOFileref_;
    data _null_; call symputX("_IOFileref_", put(MD5("%lowcase(&packageName.)"), hex7. -L), "L"); run;
    %let  in = i&_IOFileref_.;
    %let out = o&_IOFileref_.;
    /* %let  in = i%sysfunc(md5(&packageName.),hex7.); */
    /* %let out = o%sysfunc(md5(&packageName.),hex7.); */

    /*options MSGLEVEL=i;*/
    %if %upcase(&packageName.) in (SPFINIT SASPACKAGEFRAMEWORK SASPACKAGESFRAMEWORK) %then
      %do;
        /* allows to install/download the framework file like any other package */
        %if %superq(mirror) in (0 1) AND (%superq(vers) ne) %then
          %do;
            %let SPFinitMirror = https://raw.githubusercontent.com/yabwon/SAS_PACKAGES/&vers./SPF/SPFinit.sas;
          %end;
        
        filename &in URL 
          "&SPFinitMirror." 
          recfm=N lrecl=1;
        filename &out    
          "&firstPackagesPath./SPFinit.sas" 
          recfm=N lrecl=1;
      %end;
    %else
      %do;
        %if 0 = %superq(mirror) %then
          %do;
            %let packageSubDir = %lowcase(&packageName.)/raw/main/;
            
            %if %superq(vers) ne %then
              %do;
                /*%let packageSubDir = %lowcase(&packageName.)/main/hist/&version./;*/
                %let packageSubDir = %lowcase(&packageName.)/raw/&vers./;
              %end;
          %end;
        filename &in URL "&sourcePath.&packageSubDir.%lowcase(&packageName.).zip" 
        %if (%superq(URLuser) ne ) %then
          %do;
            user = "&URLuser."
            pass = "&URLuser."
          %end;
        &URLoptions.
        recfm=N lrecl=1;
        filename &out    "&firstPackagesPath./%lowcase(&packageName.).zip" recfm=N lrecl=1;
      %end;
    /*
    filename in  list;
    filename out list;
    */ 
    /* copy the file byte-by-byte  */
    %local installationRC;
    %let installationRC=1;
    data _null_;
      length filein 8 out_path in_path $ 4096;
      out_path = pathname ("&out");
       in_path = pathname ("&in" );


      filein = fopen( "&in", 'S', 1, 'B');
      if filein = 0 then
        put "ERROR: Source file:" / 
            "ERROR- " in_path /
            "ERROR- is unavailable!";    
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
          put @2 "Installing the &packageName. package" 
            / @2 "in the &firstPackagesPath. directory.";
          rc = FCOPY("&in", "&out");
        end;
      else if FEXIST("&out") = 1 then 
        do;
          if symgetn("replace")=1 then
            do;
              put @2 "The following file will be replaced during "
                / @2 "installation of the &packageName. package: " 
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
        
      put @2 "Done with return code " rc= "(zero = success)";
      call symputX("installationRC", rc, "L");
    run;
     
    filename &in  clear;
    filename &out clear;

    %if 1 = &loadAddCnt. 
        AND 0 = &installationRC. 
        AND NOT (%upcase(&packageName.) in (SPFINIT SASPACKAGEFRAMEWORK SASPACKAGESFRAMEWORK)) 
    %then
      %do;
        %put; %put - Additional content loading - Start -;
        %loadPackageAddCnt(&packageName.
                           ,path=&firstPackagesPath.
                           ,target=&firstPackagesPath.
                           )
        %put - Additional content loading - End -;
      %end;
    %put *** %lowcase(&packageName.) end *******************************************;
  /*-++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-*/
  %end;

  %packagesListError:
  
  options ls = &ls_tmp. ps = &ps_tmp. 
          &notes_tmp. &source_tmp. 
          &stimer_tmp. &fullstimer_tmp.
          msglevel=&msglevel_tmp.;

%ENDofinstallPackage:
%mend installPackage;

/*** HELP START ***/

/* 
  Filenames references "packages" and "package" are reserved keywords.
  The first one should be used to point local folder with packages.
  The second is used internally by macros.
  Do not use them otherwise than:
    filename packages "</the/folder/with/sas/packages>";
  since it may affect stability of the framework.
**/

/* Example 1: Enabling the SAS Package Framework 
    and loading the SQLinDS package from the local directory.

    Assume that the SPFinit.sas file and the SQLinDS 
    package (sqlinds.zip file) are located in 
    the "C:/SAS_PACKAGES/" folder.

    Run the following code in your SAS session:

  filename packages "C:/SAS_PACKAGES"; %* setup a directory for packages; 
  %include packages(SPFinit.sas);      %* enable the framework;

  %helpPackage(SQLinDS)                %* get help about the package;
  %loadPackage(SQLinDS)                %* load the package content into the SAS session;
  %unloadPackage(SQLinDS)              %* unload the package content from the SAS session;
*/

/* Example 2: Enabling the SAS Package Framework 
    from the local directory and installing & loading
    the SQLinDS package from the Internet.

    Assume that the SPFinit.sas file
    is located in the "C:/SAS_PACKAGES/" folder.

    Run the following code in your SAS session:

  filename packages "C:/SAS_PACKAGES"; %* setup a directory for packages; 
  %include packages(SPFinit.sas);      %* enable the framework;

  %installPackage(SQLinDS)             %* install the package from the Internet;
  %helpPackage(SQLinDS)                %* get help about the package;
  %loadPackage(SQLinDS)                %* load the package content into the SAS session;
  %unloadPackage(SQLinDS)              %* unload the package content from the SAS session;
*/

/* Example 3: Enabling the SAS Package Framework 
    and installing & loading the SQLinDS package 
    from the Internet.

    Run the following code in your SAS session:

  filename packages "%sysfunc(pathname(work))"; %* setup WORK as a temporary directory for packages;
   
  filename spfinit url "https://raw.githubusercontent.com/yabwon/SAS_PACKAGES/main/SPFinit.sas";
  %include spfinit;                    %* enable the framework;

  %installPackage(SQLinDS)             %* install the package from the Internet;
  %helpPackage(SQLinDS)                %* get help about the package;
  %loadPackage(SQLinDS)                %* load the package content into the SAS session;
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

/* Example 5: Enabling the SAS Package Framework from the local directory
    and installing the SQLinDS package from the Internet.

    Assume that the SPFinit.sas file is located in 
    the "C:/SAS_PACKAGES/" folder.

  filename packages "C:/SAS_PACKAGES"; %* setup a directory for packages; 
  %include packages(SPFinit.sas);      %* enable the framework;

  %installPackage(SQLinDS);            %* install package;
  %installPackage(SQLinDS);            %* overwrite already installed package;
  %installPackage(SQLinDS,replace=0);  %* prevent overwrite installed package;


  %installPackage(NotExistingPackage); %* handling with not existing package;

*/

/*** HELP END ***/

/*** HELP START ***/

/* Macro to list SAS packages in packages folder. 

  Version 20231009 

  A SAS package is a zip file containing a group 
  of SAS codes (macros, functions, data steps generating 
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

/*+listPackages+*/

%macro listPackages()/secure PARMBUFF
des = 'Macro to list SAS packages from `packages` fileref, type %listPackages(HELP) for help, version 20231009.'
;
%if %QUPCASE(&SYSPBUFF.) = %str(%(HELP%)) %then
  %do;
    %local options_tmp ;
    %let options_tmp = ls=%sysfunc(getoption(ls))ps=%sysfunc(getoption(ps))
     %sysfunc(getoption(notes)) %sysfunc(getoption(source))
     msglevel=%sysfunc(getoption(msglevel))
    ;
    options NOnotes NOsource ls=MAX ps=MAX msglevel=N;
    %put ;
    %put ###########################################################################################;
    %put ###       This is short help information for the `listPackages` macro                     #;
    %put #-----------------------------------------------------------------------------------------#;;
    %put #                                                                                         #;
    %put # Macro to list available SAS packages, version `20231009`                                #;
    %put #                                                                                         #;
    %put # A SAS package is a zip file containing a group                                          #;
    %put # of SAS codes (macros, functions, data steps generating                                  #;
    %put # data, etc.) wrapped up together and embedded inside the zip.                            #;
    %put #                                                                                         #;
    %put # The `%nrstr(%%listPackages())` macro lists packages available                                    #;
    %put # in the packages folder. List is printed inthe SAS Log.                                  #;
    %put #                                                                                         #;
    %put #### Parameters:                                                                          #;
    %put #                                                                                         #;
    %put # NO PARAMETERS                                                                           #;
    %put #                                                                                         #;
    %put # When used as: `%nrstr(%%listPackages(HELP))` it displays this help information.                  #;
    %put #                                                                                         #;
    %put #-----------------------------------------------------------------------------------------#;
    %put #                                                                                         #;
    %put # Visit: `https://github.com/yabwon/SAS_PACKAGES/tree/main/SPF/Documentation`             #;
    %put # to learn more.                                                                          #;
    %put #                                                                                         #;
    %put #### Example ##############################################################################;
    %put #                                                                                         #;
    %put #   Enabling the SAS Package Framework                                                    #;
    %put #   from the local directory and listing                                                  #;
    %put #   available packages.                                                                   #;
    %put #                                                                                         #;
    %put #   Assume that the `SPFinit.sas` file                                                    #;
    %put #   is located in the "C:/SAS_PACKAGES/" folder.                                          #;
    %put #                                                                                         #;
    %put #   Run the following code in your SAS session:                                           #;
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas;
    %put  %nrstr( filename packages "C:/SAS_PACKAGES"; %%* setup a directory for packages;                  );
    %put  %nrstr( %%include packages(SPFinit.sas);      %%* enable the framework;                           );
    %put  ;
    %put  %nrstr( %%listPackages()                      %%* list available packages;                        );
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
    %put ###########################################################################################;
    %put ;
    options &options_tmp.;
    %GOTO ENDoflistPackages;
  %end;

%local ls_tmp ps_tmp notes_tmp source_tmp filesWithCodes;

%let filesWithCodes = WORK._%sysfunc(datetime(), hex16.)_;

%let ls_tmp     = %sysfunc(getoption(ls));
%let ps_tmp     = %sysfunc(getoption(ps));
%let notes_tmp  = %sysfunc(getoption(notes));
%let source_tmp = %sysfunc(getoption(source));

options NOnotes NOsource ls=MAX ps=MAX;

data _null_;
  length baseAll $ 32767;
  baseAll = pathname("packages");

  if baseAll = " " then
    do;
      put "NOTE: The file reference PACKAGES is not assigned.";
      stop;
    end;

  if char(baseAll,1) ^= "(" then baseAll = quote(strip(baseAll)); /* for paths with spaces */
  
  do k = 1 to kcountw(baseAll, "()", "QS"); drop k;
    base = dequote(kscanx(baseAll, k, "()", "QS"));

    length folder $ 64 file $ 1024 folderRef fileRef $ 8;

    folderRef = "_%sysfunc(datetime(), hex6.)0";

    rc=filename(folderRef, base);
    folderid=dopen(folderRef);

    putlog " ";
    put "/*" 100*"+" ;
    do i=1 to dnum(folderId); drop i;

      if i = 1 then
        do;
              put " #";
              put " # Listing packages for: " base;
              put " #";
        end;

      folder = dread(folderId, i);

      fileRef = "_%sysfunc(datetime(), hex6.)1";
      rc = filename(fileRef, catx("/", base, folder));
      fileId = dopen(fileRef);

      EOF = 0;
      if fileId = 0 and lowcase(kscanx(folder, -1, ".")) = 'zip' then 
        do;
          file = catx('/',base, folder);
          
          rc1 = filename("package", strip(file), 'zip', 'member="description.sas"');
          rcE = fexist("package"); 
          rc2 = filename("package", " ");

          if rcE then /* if the description.sas exists in the zip then read it */
            do;
              putlog " *  ";
              length nn $ 96;
              if (96-lengthn(file)) < 1 then
                put " * " file;  
              else
                do;
                  nn = repeat("*", (96-lengthn(file)));   
                  put " * " file nn;
                end;
              
              infile _DUMMY_ ZIP FILEVAR=file member="description.sas" end=EOF;
              
              do until(EOF);
                input;
                if strip(upcase(kscanx(_INFILE_,1,":"))) in ("PACKAGE" "TITLE" "VERSION" "AUTHOR" "MAINTAINER" "LICENSE") then
                  do;
                    _INFILE_ = kscanx(_INFILE_,1,":") !! ":" !! kscanx(_INFILE_,2,":");
                    putlog " *  " _INFILE_;
                  end;                
                if strip(upcase(strip(_INFILE_))) =: "DESCRIPTION START:" then leave;
              end;
            end;
        end;
      
      rc = dclose(fileId);
      rc = filename(fileRef);
    end;

    putlog " *  ";
    put 100*"+" "*/";
    rc = dclose(folderid);
    rc = filename(folderRef);
  end;

  stop;
run;

options ls = &ls_tmp. ps = &ps_tmp. &notes_tmp. &source_tmp.;

%ENDoflistPackages:
%mend listPackages;


/*** HELP START ***/

/* Macro to generate SAS packages.

   Version 20231009

   A SAS package is a zip file containing a group 
   of SAS codes (macros, functions, data steps generating 
   data, etc.) wrapped up together and %INCLUDEed by
   a single load.sas file (also embedded inside the zip).

   See examples below.
*/

/*** HELP END ***/

/*+generatePackage+*/
/*** HELP START ***/

%macro generatePackage(
 filesLocation   /* location of package files 
                    e.g. %sysfunc(pathname(work))/%lowcase(&packageName.) */
/* testing options: */
,testPackage=Y   /* indicator if tests should be executed, 
                    default value Y means "execute tests" */
,packages=       /* location of other packages if there are
                    dependencies in loading, must be a single directory
                    if more than one are provided only the first is used */
,testResults=    /* location where tests results should be stored,
                    if null (the default) the WORK is used */
,sasexe=         /* a DIRECTORY where the SAS binary is located,
                    if null (the default) then the !SASROOT is used */
,sascfgFile=     /* a FILE with testing session configuration parameters
                    if null (the default) then no config file is pointed
                    during the SAS invocation,
                    if set to DEF then the !SASROOT/sasv9.cfg is used */
,delTestWork=1   /* indicates if `WORK` directories generated by user tests
                    should be deleted, i.e. the (NO)WORKTERM option is set,
                    default value 1 means "delete tests work" */
)/ secure minoperator
/*** HELP END ***/
des = 'Macro to generate SAS packages, version 20231009. Run %generatePackage() for help info.'
;
%if (%superq(filesLocation) = ) OR (%qupcase(&filesLocation.) = HELP) %then
  %do;
    %local options_tmp ;
    %let options_tmp = ls=%sysfunc(getoption(ls)) ps=%sysfunc(getoption(ps))
     %sysfunc(getoption(notes)) %sysfunc(getoption(source))
     msglevel=%sysfunc(getoption(msglevel))
    ;
    options NOnotes NOsource ls=MAX ps=MAX msglevel=N;
    %put ;
    %put #################################################################################;
    %put ###      This is short help information for the `generatePackage` macro         #;
    %put #-------------------------------------------------------------------------------#;
    %put #                                                                               #;
    %put # Macro to generate SAS packages, version `20231009`                            #;
    %put #                                                                               #;
    %put # A SAS package is a zip file containing a group                                #;
    %put # of SAS codes (macros, functions, data steps generating                        #;
    %put # data, etc.) wrapped up together and embedded inside the zip.                  #;
    %put #                                                                               #;
    %put # The `%nrstr(%%generatePackage())` macro generates SAS packages.                        #;
    %put # It wraps-up the package content, i.e. macros, functions, formats, etc.,       #;
    %put # into the zip file and generate all metadata content required by other         #;
    %put # macros from the SAS Packages Framework.                                       #;
    %put #                                                                               #;
    %put #-------------------------------------------------------------------------------#;
    %put #                                                                               #;
    %put # Visit: `https://github.com/yabwon/SAS_PACKAGES/tree/main/SPF/Documentation`   #;
    %put # to read about the details of package generation process.                      #;
    %put #                                                                               #;
    %put #### Parameters:                                                                #;
    %put #                                                                               #;
    %put # 1. `filesLocation=` Location of package files, example value:                 #;
    %put #                      `%nrstr(%%sysfunc(pathname(work))/packagename)`.                  #;
    %put #                     Default use case:                                         #;
    %put #                      `%nrstr(%%generatePackage(filesLocation=/path/to/packagename))`   #;
    %put #                     If empty displays this help information.                  #;
    %put #                                                                               #;
    %put # Testing parameters:                                                           #;
    %put #                                                                               #;
    %put # - `testPackage=`    Indicator if tests should be executed.                    #;
    %put #                     Default value: `Y`, means "execute tests"                 #;
    %put #                                                                               #;
    %put # - `packages=`       Location of other packages for testing                    #;
    %put #                     if there are dependencies in loading the package.         #;
    %put #                     Has to be a single directory, if more than one are        #;
    %put #                     provided than only the first is used.                     #;
    %put #                     If path to location contains spaces it should be quoted!  #;
    %put #                                                                               #;
    %put # - `testResults=`    Location where tests results should be stored,            #;
    %put #                     if null (the default) then the session WORK is used.      #;
    %put #                                                                               #;
    %put # - `sasexe=`         Location of a DIRECTORY where the SAS binary is located,  #;
    %put #                     if null (the default) then the `!SASROOT` is used.        #;
    %put #                                                                               #;
    %put # - `sascfgFile=`     Location of a FILE with testing session configuration     #;
    %put #                     parameters, if null (the default) then no config file     #;
    %put #                     is pointed during the SAS invocation,                     #;
    %put #                     if set to `DEF` then the `!SASROOT/sasv9.cfg` is used.    #;
    %put #                                                                               #;
    %put # - `delTestWork=`    Indicates if `WORK` directories generated by user tests   #;
    %put #                     should be deleted, i.e. the (NO)WORKTERM option is set.   #;
    %put #                     The default value: `1` means "delete tests work".         #;
    %put #                     Available values are `0` and `1`.                         #;
    %put #                                                                               #;
    %put #-------------------------------------------------------------------------------#;
    %put #################################################################################;
    %put ;
    options &options_tmp.;
    %GOTO ENDofgeneratePackage;
  %end;

%put --- generatePackage START ---;
%local zipReferrence filesWithCodes _DESCR_ _LIC_ _DUMMY_ _RC_ _PackageFileref_ additionalContent;
%let   zipReferrence = _%sysfunc(datetime(), hex6.)_;
%let   filesWithCodes = WORK._%sysfunc(datetime(), hex16.)_;
%let   _DESCR_ = _%sysfunc(datetime(), hex6.)d;
%let   _LIC_   = _%sysfunc(datetime(), hex6.)l;
%let   _DUMMY_ = _%sysfunc(datetime(), hex6.)_;

/* collect package metadata from the description.sas file */
filename &_DESCR_. "&filesLocation./description.sas" lrecl = 1024;
/* file contains licence */
filename &_LIC_.   "&filesLocation./license.sas" lrecl = 1024;

%if %sysfunc(fexist(&_DESCR_.)) %then 
  %do;
    %put NOTE- ;
    %put NOTE: Verifying package metadata; 
    %put NOTE- ^^^^^^^^^^^^^^^^^^^^^^^^^^; 
    %put NOTE- ; 

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
           
    %local qlenmax_fstimer_tmp;
    %let qlenmax_fstimer_tmp = %sysfunc(getoption(quotelenmax)) %sysfunc(getoption(stimer)) %sysfunc(getoption(fullstimer));
    options NOquotelenmax NOstimer NOfullstimer;
    data _null_;
      infile &_DESCR_.;
      input;
    
      %local metaExtStr; /* metadata Extraction String; */
      %let metaExtStr=kscanx(_INFILE_, 2, ":");

      select( strip(upcase(kscanx(_INFILE_, 1, ":"))) );
        when("PACKAGE")     call symputX("packageName",        &metaExtStr., "L");
        when("VERSION")     call symputX("packageVersion",     &metaExtStr., "L");
        when("AUTHOR")      call symputX("packageAuthor",      &metaExtStr., "L");
        when("MAINTAINER")  call symputX("packageMaintainer",  &metaExtStr., "L");
        when("TITLE")       call symputX("packageTitle",       &metaExtStr., "L");
        when("ENCODING")    call symputX("packageEncoding",    &metaExtStr., "L");
        when("LICENSE")     call symputX("packageLicense",     &metaExtStr., "L");
        when("REQUIRED")    call symputX("packageRequired",    &metaExtStr., "L");
        when("REQPACKAGES") call symputX("packageReqPackages", &metaExtStr., "L");

        /* stop at the beginning of description */
        when("DESCRIPTION START") stop;
        otherwise;
      end;
    run;
    /* package generation timestamp, in iso8601 YYYY-MM-DDThh:mm:ss */
    %local packageGenerated;
    %let packageGenerated = %sysfunc(datetime(), E8601DT19.);
    %put NOTE: &=packageGenerated.;

    options &qlenmax_fstimer_tmp.;
 
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
          %put ERROR- They are required to create a package.;
          %put ERROR- packageName=%superq(packageName);
          %put ERROR- packageTitle=%superq(packageTitle);
          %put ERROR- packageVersion=%superq(packageVersion);
          %put ERROR- packageAuthor=%superq(packageAuthor);
          %put ERROR- packageMaintainer=%superq(packageMaintainer);
          %put ERROR- packageEncoding=%superq(packageEncoding);
          %put ERROR- packageLicense=%superq(packageLicense); 
          %put ERROR- ;
          %put ERROR- Aborting.;
          %abort;
        %end;

    /* test for package name */
    %if %sysfunc(lengthn(&packageName.)) > 24 %then
      %do;
        %put ERROR: Package name is more than 24 characters long.;
        %put ERROR- The name is used for functions dataset name;
        %put ERROR- and for formats catalog name (with suffix).;
        %put ERROR: The length is %sysfunc(lengthn(&packageName.)). Try something shorter.;
        %put ERROR- Aborting.;
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
        %put ERROR- The name is used for functions dataset name;
        %put ERROR- and for formats catalog name.;
        %put ERROR- Only English letters, underscore(_), and digits are allowed.;
        %put ERROR: Try something else. Maybe: %qsysfunc(compress(&packageName.,,KDF)) will do?;
        %put ERROR- Aborting.;
        %abort;
      %end;

    /* test first symbol in package name */
    %if %qsubstr(&packageName.,1,1) IN (1 2 3 4 5 6 7 8 9 0) %then
      %do;
        %put ERROR: Package name cannot start with a number.;
        %put ERROR- The name is used for functions dataset name;
        %put ERROR- and for formats catalog name.;
        %put ERROR- Only English letters and underscore(_) are allowed as the first symbol.;
        %put ERROR: Try something else which not start with a digit;
        %put ERROR- Aborting.;
        %abort;
      %end;

  %if %superq(packageRequired) ne %then
    %do;
      /* turn off the note about quoted string length */
      %local qlenmax_fstimer_tmp;
      %let qlenmax_fstimer_tmp = %sysfunc(getoption(quotelenmax)) %sysfunc(getoption(stimer)) %sysfunc(getoption(fullstimer));
      options NOquotelenmax NOstimer NOfullstimer;
      %local tryExcept;
      %let tryExcept = 0;
      data _null_;
        rc = dosubl('options nonotes nosource;
        filename &_DUMMY_. DUMMY;
        proc printto log = &_DUMMY_.; run;' !!
       '%let SYSCC = 0;
        data _null_;
          length rq $ 164;
          do rq = &packageRequired.;
          end;
        run;' !!
       '%let tryExcept = &SYSCC.; filename &_DUMMY_. clear;');

        tryExcept = symgetn('tryExcept');

        put "NOTE: Required test: " rc= tryExcept= "(double 0 is success)";

        if tryExcept then 
          do;
            put 'ERROR: Your Required list seems to be problematic.';
            put 'ERROR- Check the description.sas file.';
            put 'ERROR- Expected form is "Quoted" Comma, ..., Separated List, e.g.';
            put 'ERROR- "SAS Component1", "SAS Component2", "SAS Component3"';
            put 'ERROR- Provided value is:';
            length R $ 32767;
            R = symget('packageRequired');
            put 'ERROR- ' R;
          end;
        else
          rc = dosubl('title; options nonotes nosource ps=min ls=99 nodate nonumber nostimer;
            data _null_;
              length rq $ 64; put "Required:";
              do rq = &packageRequired.;
                put "- " rq;
              end;
            run;');
      run;
      /* turn on the original value of the note about quoted string length */
      options &qlenmax_fstimer_tmp.;
      %if &tryExcept. %then %abort;
    %end;

  %if %superq(packageReqPackages) ne %then
    %do;
      /* turn off the note about quoted string length */
      %local qlenmax_fstimer_tmp;
      %let qlenmax_fstimer_tmp = %sysfunc(getoption(quotelenmax)) %sysfunc(getoption(stimer)) %sysfunc(getoption(fullstimer));
      options NOquotelenmax NOstimer NOfullstimer;

      %local tryExcept;
      %let tryExcept = 0;
      data _null_;
        rc = dosubl('options nonotes nosource;
        filename &_DUMMY_. DUMMY;
        proc printto log = &_DUMMY_.; run;' !!
       '%let SYSCC = 0;
        data _null_;
          length rq $ 64;
          do rq = &packageReqPackages.;
          end;
        run;' !!
       '%let tryExcept = &SYSCC.; filename &_DUMMY_. clear;');

        tryExcept = symgetn('tryExcept');

        put "NOTE: ReqPackages test: " rc= tryExcept= "(double 0 is success)";

        if tryExcept then 
          do;
            put 'ERROR: Your ReqPackages list seems to be problematic.';
            put 'ERROR- Check the description.sas file.';
            put 'ERROR- Expected form is "Quoted" Comma, ..., Separated List, e.g.';
            put 'ERROR- "Package1 (X.X)", "Package2 (Y.Y)", "Package3 (Z.Z)"';
            put 'ERROR- Provided value is:';
            length R $ 32767;
            R = symget('packageReqPackages');
            put 'ERROR- ' R;
          end;
        else
          rc = dosubl('title; options nonotes nosource ps=min ls=66 nodate nonumber nostimer;
            data _null_;
              length rq $ 64; put "ReqPackages:";
              do rq = &packageReqPackages.;
                put "- " rq;
              end;
            run;');
      run;
      /* turn on the original value of the note about quoted string length */
      options &qlenmax_fstimer_tmp.;
      %if &tryExcept. %then %abort;
    %end;

  %end;
%else
  %do;
    %put ERROR: The description.sas file is missing!;
    %put ERROR- The file is required to create package metadata;
    %put ERROR- Aborting.;
    %abort;
  %end;


%local qlenmax_fstimer_tmp;
%let qlenmax_fstimer_tmp = %sysfunc(getoption(quotelenmax)) %sysfunc(getoption(stimer)) %sysfunc(getoption(fullstimer));
options NOquotelenmax NOstimer NOfullstimer;

/* generate package fileref with MD5 to allow 
   different file reference for each package 
   while loading package with %loadPackage() macro
  */
/* %let _PackageFileref_ = P%sysfunc(MD5(%lowcase(&packageName.)),hex7.); */
data _null_; call symputX("_PackageFileref_", "P" !! put(MD5("%lowcase(&packageName.)"), hex7. -L), "L"); run;

/* test if version is a number */
data _null_;
  v = "&packageVersion.";
  version = coalesce(input(scan(v,1,".","M"), ?? best32.),0)*1e8
          + coalesce(input(scan(v,2,".","M"), ?? best32.),0)*1e4
          + coalesce(input(scan(v,3,".","M"), ?? best32.),0)*1e0
  ;
  if not (version > 0) then
    do;
      put 'ERROR: Package version should be a positive NUMBER.';
      put 'ERROR- Current value is: ' "&packageVersion.";
      put 'ERROR- Try something small, e.g. 0.1';
      put 'ERROR- Aborting.';
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
    %put NOTE: &=_RC_;
  %end;
%if %sysfunc(fexist(&zipReferrence.)) %then 
  %do;
    %put ERROR: File "&filesLocation./%lowcase(&packageName.).zip" cannot be deleted.;
    %put ERROR- Check if the file is not blocked by another process.; 
    %put ERROR- Aborting.;
    %abort;
  %end;


/*** HELP START ***/
/* 
  Locate all files with code in base folder, i.e. at `filesLocation` directory. 
*/
/*
  Remember to prepare the `description.sas` file for you package.
  The colon (:) is a field separator and is restricted 
  in lines of the header part.                          
  The file should contain the following obligatory information:
--------------------------------------------------------------------------------------------
>> **HEADER** <<
Type: Package
Package: PackageName
Title: A title/brief info for log note about your packages.
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

  Name of the `type` of folder and `files.sas` inside must be in the _low_ case letters.

  If order of loading is important, the sequential number
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
   +-00n_clean [if you need to clean something up after exec file execution,
   |         |  content of the files will be printed to the log before execution]
   |         |
   |         +-<no file, in this case folder may be skipped>
   |
   +-...
   |
   +-998_addcnt [additional content for the package, can be only one!, content of this 
   |          |  directory is copied "as is"]
   |          |
   |          +-arbitrary_file1 [an arbitrary file ]
   |          |
   |          +-subdirectory_with_files [an arbitrary directory with some files inside]
   |          |
   |          +-...
   |
   +-999_test [tests executed during package generation, XCMD options must be turned-on]
   |        |
   |        +-test1.sas [a file with a code for test1]
   |        |
   |        +-test2.sas [a file with a code for test2]
   |
   +-...
   ...
--------------------------------------------------------------------------------------------

*/
/*** HELP END ***/

/* collect the data */
data &filesWithCodes.;
  putlog "NOTE- ";
  putlog "NOTE: Generating content dataset: &filesWithCodes..";
  putlog "NOTE- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^";
  putlog "NOTE- ";
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
        put 'ERROR- Try to use: ' lowcase_name;
        put;
        _abort_ + 1;
      end;
    order = kscanx(folder, 1, "_");
    type  = kscanx(folder,-1, "_");

    fileRef = "_%sysfunc(datetime(), hex6.)1";
    rc = filename(fileRef, catx("/", base, folder));
    fileId = dopen(fileRef);

    file = ' ';

    /* ignore folders which name starts with ! */
    if fileId AND "!" =: folder then
      do;
        put "INFO: Folder " folder "name starts with ! and will be ignored. " /
            "      No content from it will be used to generate the package." / " ";
        goto ignoreFolder;
      end;

    /* ignore unknown types for folders */
    if fileId AND not (upcase(type) in: 
      ('LIBNAME' 'MACRO' /*'MACROS'*/ 'DATA' 
       'FUNCTION' /*'FUNCTIONS'*/ 'FORMAT' /*'FORMATS'*/ 
       'IMLMODULE' 'PROTO' 'EXEC' 'CLEAN' 
       'LAZYDATA' 'TEST' 'CASLUDF'
       'ADDCNT'
      )) 
    then 
      do;
        put "WARNING: Type " type 'is not yet supported.' /
            "WARNING- Folder " folder " will be ignored. " /
            "WARNING- No content from it will be used to generate the package." / " ";
        goto ignoreFolder;
      end;

    /* if it is a directory then read its content... */
    if fileId then 
    do;
      /* ...but! do not use files from "additional content" directory */
      if NOT (upcase(type) =: 'ADDCNT') then
        do j = 1 to dnum(fileId); drop j;
          file = dread(fileId, j);
              if file NE lowcase(file) then
                do;
                  put 'ERROR: File with code should be named ONLY with low case letters.';
                  put 'ERROR- Current value is: ' file;
                  lowcase_name = lowcase(file);
                  put 'ERROR- Try to use: ' lowcase_name;
                  put;
                  _abort_ + 1;
                end;
          fileshort = substr(file, 1, length(file) - 4); /* filename.sas -> filename */

          if strip(reverse(file)) in: ('sas.') then output; /* ignore not ".sas" files */
          else
            do;
              put "WARNING: Only *.sas files are supported." /
                  "WARNING- The file: " file "will be ignored." /
                  "WARNING- ";
            end;
        end;
      else
        do;
          file = "additionalcontent";
          fileshort = file;
          additionalContent+1;
          if additionalContent > 1 then
            do;
              put "WARNING: Only ONE directory with additional content is allowed!" /
                  "WARNING- Store all additional content in a single directory." /
                  "WARNING- The directory: " folder "will be ignored." /
                  "WARNING- ";
            end;
          else
            do;
              /*output;*/
              put "NOTE: Additional content located in " folder;
              call symputX('additionalContent', folder, "L");
            end;
        end;
    end;

    ignoreFolder: ;
    rc = dclose(fileId);
    rc = filename(fileRef);
  end;

  rc = dclose(folderid);
  rc = filename(folderRef);

  if _abort_ then
  do;
    put 'ERROR: Aborting due to previous errors.';
    abort;
  end;
  put " ";
  stop;
run;

%local notesSourceOptions;
%let notesSourceOptions = %sysfunc(getoption(notes)) %sysfunc(getoption(source));
options NOnotes NOsource;

proc sort data = &filesWithCodes.;
  by order type file;
run;

/* quality check for EXEC and CLEAN types */
data _null_;
  set &filesWithCodes. (where=(upcase(type) in ('EXEC' 'CLEAN'))) end=EOF;

  if _N_ = 1 then
    do;
      declare hash EXEC(); /* store EXECs */
      EXEC.defineKey('file');
      EXEC.defineData('ne');
      EXEC.defineDone();
      declare hash CLEAN(); /* store CLEANs */
      CLEAN.defineKey('file');
      CLEAN.defineData('nc');
      CLEAN.defineDone();

      declare hash F(ordered:"A");
      F.defineKey('file');
      F.defineData('file');
      F.defineDone();
      declare hiter IF("F");
    end;

  F.replace();
  if upcase(type) = 'EXEC' then
    do;
      e + 1;
      if EXEC.find() then EXEC.add(key:file,data:1);
                     else EXEC.replace(key:file,data:ne+1);
    end;

  if upcase(type) = 'CLEAN' then
    do;
      c + 1;
      if CLEAN.find() then CLEAN.add(key:file,data:1);
                      else CLEAN.replace(key:file,data:nc+1);
    end;

  if EOF then
    do;
      /* if number of EXECs and CLEANs differs but both are positive issue a Warning */
      if (0 < e < c) or (0 < c < e) or not(EXEC.NUM_ITEMS = CLEAN.NUM_ITEMS = F.NUM_ITEMS) then
        do;
          put "WARNING: Number of EXEC type and CLEAN type files differs!" /
              "WARNING- Each EXEC file should have CLEAN file counterpart and vice versa." /
              'WARNING- Please create appropriate files and make your package a "role model".' /
              'WARNING- ' /
              'WARNING- The list of differences:';
          do while(IF.next()=0);
            ne = 0;
            nc = 0;
            df = EXEC.find();
            df = CLEAN.find();
            df = abs(ne - nc);
            put "WARNING- File " file char36. "EXEC: " ne 3. +1 "CLEAN: " nc 3. +1 "diff: " df 3.;
          end;
          put "WARNING- ";
        end;
      /* if EXECs are positive but CLEANs are zero (or other way around) issue an Error */
      if (0 = e < c) or (0 = c < e) then
        do;
          put "ERROR: There are " e "EXECs files and " c "CLEANs files!" /
              "ERROR- Each EXEC file should have CLEAN file counterpart and vice versa." /
              'ERROR- Please create appropriate files and make your package a "role model".' /
              'ERROR: [&sysmacroname.] Aborting package generation!' ;
          abort;
        end;
    end;
run;


/*======== test for duplicated names of the same type ========*/
proc sort 
  data = &filesWithCodes. 
  out = &filesWithCodes._DUPSCHECK
;
  by type file order;
run;

data _null_;
  set &filesWithCodes._DUPSCHECK;
  by type file;

  if first.file NE last.file then
    do;
      if 0 = warnPrinted then
        do;
          put "WARNING: The following names are duplicated:";
          warnPrinted+1;
        end;
      put "WARNING- " type= file= folder=;
    end;

run;
proc delete data = &filesWithCodes._DUPSCHECK;
run;
/*=============================================================*/

%if %superq(additionalContent) NE %then
  %do;
    /* code inspired by Kurt Bremser's "Talking to Your Host" article */
    /* https://communities.sas.com/t5/SAS-User-Groups-Library/WUSS-Presentation-Talking-to-Your-Host/ta-p/838344 */
    /* WUSS 2022 */
    
    data &filesWithCodes.addCnt;
    run;

    data &filesWithCodes.addCnt;
      length root dname $ 8192 filename $ 256 dir level 8;
      root = "&filesLocation./&additionalContent.";
      retain filename dname ' ' level 0 dir 1;
      label 
        filename = "file"
        dname = "folder"
        ;
    run;

    data &filesWithCodes.addCnt;
      modify &filesWithCodes.addCnt;
      rc1=filename('tmp',catx('/',root,dname,filename));
      rc2=dopen('tmp');
      dir = 1 & rc2;
      if dir then 
        do;
          dname=catx('/',dname,filename);
          filename=' ';
        end;
      replace;

      if dir;

      level=level+1;

      do i=1 to dnum(rc2);
        filename=dread(rc2,i);
        output;
      end;
      rc3=dclose(rc2);
    run;

    proc sort data=&filesWithCodes.addCnt(where=(filename is not null));
      by root dname filename;
    run;
  %end;



/*
proc contents data = &filesWithCodes.;
run;
*/
title1 "Package location is: &filesLocation.";
title2 "User: &SYSUSERID., Datetime: &packageGenerated., SAS version: &SYSVLONG4.";
title3 "Package encoding: '&packageEncoding.', Session encoding: '&SYSENCODING.'.";
title4 " ______________________________ ";
title5 "List of files for package: &packageName. (version &packageVersion.), license: &packageLicense.";
title6 "MD5 hashed fileref of package lowcase name: &_PackageFileref_.";
%if (%superq(packageRequired) ne ) 
 or (%superq(packageReqPackages) ne ) 
%then
  %do;
    title7 "Required SAS licences: %qsysfunc(compress(%superq(packageRequired),   %str(%'%")))" ;   /* ' */
    title8 "Required SAS packages: %qsysfunc(compress(%superq(packageReqPackages),%str(%'%")))" ;   /* " */
  %end;

footnote1 "SAS Packages Framework, version 20231009";

proc print data = &filesWithCodes.(drop=base folderRef fileRef rc folderid _abort_ fileId additionalContent);
run;
title;

%if %superq(additionalContent) NE %then
  %do;
    data _null_;
      if not nobs then 
        do;
          put "WARNING: Directory with additional content is empty.";
          put "WARNING- Additional content will not be generated.";
          call symputX("additionalContent", "", "L");
        end;
      stop;
      set &filesWithCodes.addCnt nobs=nobs;
    run;
    title2 "Package additional content:";
    proc print 
      data=&filesWithCodes.addCnt(drop=root dir level)
      label
    ;
    run;
  %end;

title;
footnote;
options &notesSourceOptions.;


/* packages description */
%put NOTE-;
%put NOTE: Preparing description file.;
%put NOTE- ^^^^^^^^^^^^^^^^^^^^^^^^^^^;
%put NOTE-;
data _null_;
  infile &_DESCR_.;
  file &zipReferrence.(description.sas) encoding = &packageEncoding.;
  input; 
  put _INFILE_;
run;

/* package license */
%put NOTE-;
%put NOTE: Preparing license file.;
%put NOTE- ^^^^^^^^^^^^^^^^^^^^^^^;
%put NOTE-;
%if %sysfunc(fexist(&_LIC_.)) %then 
  %do;
    data _null_;
      infile &_LIC_.;
      file &zipReferrence.(license.sas) encoding = &packageEncoding.;
      input; 
      put _INFILE_;
    run;
  %end;
%else
  %do;
    %put WARNING:[License] No license.sas file provided, default (MIT) licence file will be generated.;
    %let packageLicense = MIT;
     data _null_;
      file &zipReferrence.(license.sas) encoding = &packageEncoding.;
      length packageAuthor $ 1024;
      packageAuthor = symget('packageAuthor');
      put " ";
      put "  Copyright (c) since %sysfunc(today(),year4.) " packageAuthor                   ;
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
%put NOTE-;
%put NOTE: Preparing metadata file.;
%put NOTE- ^^^^^^^^^^^^^^^^^^^^^^^^;
%put NOTE-;
data _null_;
  if 0 then set &filesWithCodes. nobs=NOBS;
  if NOBS = 0 then
    do;
      putlog "WARNING:[&sysmacroname.] No files to create package.";
      stop;
    end;
  file &zipReferrence.(packagemetadata.sas) encoding = &packageEncoding.;

  length packageName $ 32 packageVersion packageGenerated $ 24
         packageTitle packageAuthor packageMaintainer $ 2048
         packageEncoding $ 8 packageLicense $ 128;
  packageName       = quote(strip(symget('packageName')),'"');
  packageVersion    = quote(strip(symget('packageVersion')),'"');
  packageTitle      = quote(strip(symget('packageTitle')),'"');
  packageAuthor     = quote(strip(symget('packageAuthor')),'"');
  packageMaintainer = quote(strip(symget('packageMaintainer')),'"');
  packageEncoding   = quote(strip(symget('packageEncoding')),'"');
  packageLicense    = quote(strip(symget('packageLicense')),'"');
  packageGenerated  = quote(strip(symget('packageGenerated')),'"');

  put ' data _null_; '; /* simple "%local" returns error while loading package */
  put '  call symputX("packageName",       ' packageName       ', "L");';
  put '  call symputX("packageVersion",    ' packageVersion    ', "L");';
  put '  call symputX("packageTitle",      ' packageTitle      ', "L");';
  put '  call symputX("packageAuthor",     ' packageAuthor     ', "L");';
  put '  call symputX("packageMaintainer", ' packageMaintainer ', "L");';
  put '  call symputX("packageEncoding",   ' packageEncoding   ', "L");';
  put '  call symputX("packageLicense",    ' packageLicense    ', "L");';
  put '  call symputX("packageGenerated",  ' packageGenerated  ', "L");';
  put ' run; ';

  stop;
run;

/* emergency ICEloadPackage macro to load package when loadPackage() 
   is unavailable for some reasons, example of use:
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
%put NOTE-;
%put NOTE: Preparing iceloadpackage file.;
%put NOTE- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^;
%put NOTE-;
data _null_;
  file &zipReferrence.(iceloadpackage.sas) encoding = &packageEncoding.;
  put " ";
  put '  /* Temporary replacement of loadPackage() macro. */                      ';
  put '  %macro ICEloadPackage(                                                   ';
  put '    packageName                         /* name of a package */            ';
  put '  , path = %sysfunc(pathname(packages)) /* location of a package */        ';
  put '  , options = %str(LOWCASE_MEMNAME)     /* possible options for ZIP */     ';
  put '  , zip = zip                           /* file ext. */                    ';
  put '  , requiredVersion = .                 /* required version */             ';
  put '  , source2 = /* source2 */                                                ';
  put '  , suppressExec = 0                    /* suppress execs */               ';
  put '  )/secure;                                                                ';
  put '    %PUT ** NOTE: Package ' "&packageName." ' loaded in ICE mode **;       ';
  put '    %local _PackageFileref_;                                               ';
  put '    /* %let _PackageFileref_ = P%sysfunc(MD5(%lowcase(&packageName.)),hex7.); */                  ';
  put '    data _null_;                                                                                  ';
  put '     call symputX("_PackageFileref_", "P" !! put(MD5("%lowcase(&packageName.)"), hex7. -L), "L"); ';
  put '    run;                                                                                          ';
  
  put '    filename &_PackageFileref_. &ZIP.                                      ';
  put '      "&path./%lowcase(&packageName.).&zip." %unquote(&options.)           ';
  put '    ;                                                                      ';
  put '    %include &_PackageFileref_.(packagemetadata.sas) / &source2.;          ';
  put '    filename &_PackageFileref_. clear;                                     ';

           /* test if required version of package is "good enough" */
  put '    %local rV pV;                                                          ';
  put '    %let pV = %sysfunc(compress(&packageVersion.,.,kd));                   ';
  put '    %let pV = %sysevalf((%scan(&pV.,1,.,M)+0)*1e8                          ';
  put '                      + (%scan(&pV.,2,.,M)+0)*1e4                          ';
  put '                      + (%scan(&pV.,3,.,M)+0)*1e0);                        ';
  put '    %let rV = %sysfunc(compress(&requiredVersion.,.,kd));                  ';
  put '    %let rV = %sysevalf((%scan(&rV.,1,.,M)+0)*1e8                          ';
  put '                      + (%scan(&rV.,2,.,M)+0)*1e4                          ';
  put '                      + (%scan(&rV.,3,.,M)+0)*1e0);                        ';
  put '    %if %sysevalf(&requiredVersion. > &packageVersion.) %then              ';
  put '      %do;                                                                 ';
  put '        %put ERROR: Required version is &requiredVersion.;                 ';
  put '        %put ERROR- Provided version is &packageVersion.;                  ';
  put '        %GOTO WrongVersionOFPackage; /*%RETURN;*/                          '; 
  put '      %end;                                                                ';


  put '    filename &_PackageFileref_. &ZIP.                                      ';
  put '      "&path./%lowcase(&packageName.).&zip." %unquote(&options.)           ';
  put '      ENCODING =                                                           ';
  put '        %if %bquote(&packageEncoding.) NE %then &packageEncoding. ;        ';
  put '                                          %else utf8 ;                     ';
  put '    ;                                                                      ';
  
  put '    %local cherryPick; %let cherryPick=*;                                  ';
  put '    %local tempLoad_minoperator;                                           ';
  put '    %let tempLoad_minoperator = %sysfunc(getoption(minoperator));          ';
  put '    options minoperator;                                                   ';

  put '    %if %superq(suppressExec) NE 1 %then %let suppressExec = 0;            ';

  put '    %include &_PackageFileref_.(load.sas) / &source2.;                     ';
  put '    options &tempLoad_minoperator.;                                        ';
  
  put '    filename &_PackageFileref_. clear;                                     ';
  put '    %WrongVersionOFPackage:                                                ';

  put '  %mend ICEloadPackage;                                                    ';
  put " ";
run;

/* loading package files */
%put NOTE-;
%put NOTE: Preparing load file.;
%put NOTE- ^^^^^^^^^^^^^^^^^^^^;
%put NOTE-;
data _null_;
  if NOBS = 0 then stop;

  file &zipReferrence.(load.sas) lrecl=32767 encoding = &packageEncoding.;
 
  put "filename &_PackageFileref_. list;" /;
  put ' %put NOTE- ;'; 
  put ' %put NOTE: ' @; put "Loading package &packageName., version &packageVersion., license &packageLicense.; ";

  put ' %put NOTE: ' @; put '*** %superq(packageTitle) ***; ';
  put ' %put NOTE- ' @; put "Generated: &packageGenerated.; ";
  put ' %put NOTE- ' @; put 'Author(s): %superq(packageAuthor); ';
  put ' %put NOTE- ' @; put 'Maintainer(s): %superq(packageMaintainer); ';
  put ' %put NOTE- ;';
  put ' %put NOTE- Run %nrstr(%%)helpPackage(' "&packageName." ') for the description;';
  put ' %put NOTE- ;';
  put ' %put NOTE- *** START ***; ' /;
  
  put 'data _null_; ';
  put ' if NOT ("*"=symget("cherryPick")) then do; '; /* Cherry Pick test0 start */
  put '  put "NOTE- "; ' /
      '  put "NOTE: *** Cherry Picking ***"; ' /
      '  put "NOTE- Cherry Picking in action!! Be advised that"; ' /
      '  put "NOTE- dependencies/required packages will not be loaded!"; ' /
      '  put "NOTE- "; ' ;
  put ' end; ' ; /* Cherry Pick test0 end */
  put 'run; ';


  put '%include ' " &_PackageFileref_.(packagemetadata.sas) / nosource2; " /; /* <- copied also to loadPackage macro */
  
  isFunction  = 0;
  isFormat    = 0;
  isProto     = 0;
  isIMLmodule = 0;
  isCASLudf   = 0;

  %if (%superq(packageRequired) ne ) 
   or (%superq(packageReqPackages) ne ) 
  %then
    %do;
      put ' data _null_;                                                     ';
      put '  call symputX("packageRequiredErrors", 0, "L");                  ';
      put ' run;                                                             ';
    %end;

  %if %superq(packageRequired) ne %then
    %do;
      put ' %put NOTE- *Testing required SAS components*%sysfunc(DoSubL(     '; /* <- DoSubL() is here */
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
    /*put '   put "*> " _infile_ %str(;)                                     '; */ /* for testing */
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
      put '       put "WARNING- ###########################################" %str(;) ';
      put '       put "WARNING:  The following SAS components are missing! " %str(;) ';
      put '       call symputX("packageRequiredErrors", 0, "L") %str(;)              ';
      put '       do while(iR.next() = 0) %str(;)                                    ';
      put '         put "WARNING-   " req %str(;)                                    ';
      put '       end %str(;)                                                        ';
      put '       put "WARNING:  The package may NOT WORK as expected      " %str(;) ';
      put '       put "WARNING:  or even result with ERRORS!               " %str(;) ';
      put '       put "WARNING- ###########################################" %str(;) ';
      put '       put %str(;)                                                ';
      put '     end %str(;)                                                  ';
      put ' run %str(;)                                                      ';
      put ' filename _stinit_ clear %str(;)                                  ';
      put ' options notes source %str(;)                                     ';
      put ' ))*;                                                             ';
    %end;

  %if %superq(packageReqPackages) ne %then
    %do;

      length packageReqPackages $ 32767;
      packageReqPackages = lowcase(symget('packageReqPackages'));
      
      /* try to load required packages */
      put 'data _null_ ;                                                                                 ';
      put ' if "*" NE symget("cherryPick") then do; put "NOTE: No required packages loading."; stop; end; ';
      put '  length req name $ 64 vers verR $ 24 versN verRN 8 SYSloadedPackages $ 32767;                ';
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
      put '    req = kscanx(SYSloadedPackages, _N_, " ");                                                ';
      put '    name = lowcase(strip(kscanx(req, 1, "(")));                                               ';
      put '    vers = compress(kscanx(req,-1, "("), ".", "KD");                                          ';
      put '    _RC_ = LP.add();                                                                          ';
      put '  end;                                                                                        ';
      /* check if elements of the framework are available */
      put '       LoadPackageExist = input(resolve(''%SYSMACEXIST(   loadPackage)''), best.);            ';
      put '    ICELoadPackageExist = input(resolve(''%SYSMACEXIST(ICEloadPackage)''), best.);            '; 

      put '  do req = ' / packageReqPackages / ' ;                                                       ';
/*    put '    req = compress(req, "(.)", "KDF");                                                        ';*/
      put '    name = lowcase(strip(kscanx(req, 1, "(")));                                               ';
      put '    verR = compress(kscanx(req,-1, "("), ".", "KD"); vers = "";                               ';
      put '    LP_find = LP.find();                                                                      ';

      /* convert major.minor.patch to number*/
      put '    array V verR vers ;                                                                       ';
      put '    array VN verRN versN;                                                                     ';
      put '    do over V;                                                                                ';
      put '      VN = input("0"!!scan(V,1,".","M"),?? best.)*1e8                                         ';
      put '         + input("0"!!scan(V,2,".","M"),?? best.)*1e4                                         ';
      put '         + input("0"!!scan(V,3,".","M"),?? best.)*1e0;                                        ';
      put '    end;                                                                                      ';

      put '    if (LP_find ne 0) or (LP_find = 0 and . < versN < verRN) then                                     ';
      put '     do;                                                                                              ';
      put '      put "NOTE: Trying to load required SAS package: " req;                                          ';
      put '       if LoadPackageExist then                                                                       ';
      put '         call execute(cats(''%nrstr(%loadPackage('', name, ", requiredVersion = ", verR, "))"));      ';
      put '       else if ICELoadPackageExist then                                                               ';
      put '         call execute(cats(''%nrstr(%ICEloadPackage('', name, ", requiredVersion = ", verR, "))"));   ';
      put '     end ;                                                                                            ';
      put '  end ;                                                                                               ';
      put ' stop;                                                                                        ';
      put 'run;                                                                                          ';

      /* test if required packages are loaded */
      put 'data _null_ ;                                                                                 ';
      put ' if "*" NE symget("cherryPick") then do; put "NOTE: No required packages checking."; stop; end; ';
      put '  length req name $ 64 vers verR $ 24 versN verRN 8 SYSloadedPackages $ 32767;                ';
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
      put '        req = kscanx(SYSloadedPackages, _N_, " ");                                            ';
      put '        name = lowcase(strip(kscanx(req, 1, "(")));                                           ';
      put '        vers = compress(kscanx(req,-1, "("), ".", "KD");                                      ';
      put '        _RC_ = LP.add();                                                                      ';
      put '      end;                                                                                    ';

      put '      missingPackagr = 0;                                                                     ';
      put '      do req = ' / packageReqPackages / ' ;                                                   ';
/*    put '        req = compress(req, "(.)", "KDF");                                                    ';*/
      put '        name = lowcase(strip(kscanx(req, 1, "(")));                                           ';
      put '        verR = compress(kscanx(req,-1, "("), ".", "KD"); vers = " ";                          ';
      put '        LP_find = LP.find();                                                                  ';

      /* convert major.minor.patch to number*/
      put '    array V verR vers ;                                                                       ';
      put '    array VN verRN versN;                                                                     ';
      put '    do over V;                                                                                ';
      put '      VN = input("0"!!scan(V,1,".","M"),?? best.)*1e8                                         ';
      put '         + input("0"!!scan(V,2,".","M"),?? best.)*1e4                                         ';
      put '         + input("0"!!scan(V,3,".","M"),?? best.)*1e0;                                        ';
      put '    end;                                                                                      ';

      put '        if (LP_find ne 0) or (LP_find = 0 and . < versN < verRN) then                         ';
      put '         do;                                                                                  ';
      put '          missingPackagr = 1;                                                                 ';
      put '          put "ERROR: SAS package: " req "is missing! Download it by hand or if the SAS session";';
      put '          put "ERROR- has access to the Internet and the package is available at SASPAC repository";';
      put '          put ''ERROR- use %installPackage('' name +(-1) "(" verR +(-1) ")) to install it."/; ';
      put '          put ''ERROR- Use %loadPackage('' name +(-1) ", requiredVersion=" verR +(-1) ") to load it."/;';
      put '         end ;                                                                                ';
      put '      end ;                                                                                   ';
      put '      if missingPackagr then call symputX("packageRequiredErrors", 1, "L");                   ';
      put '    end;                                                                                      ';
      put '  else                                                                                        ';
      put '    do;                                                                                       ';
      put '      put "ERROR: No package loaded!";                                                        ';
      put '      call symputX("packageRequiredErrors", 1, "L");                                          ';
      put '      do req = ' / packageReqPackages / ' ;                                                   ';
      put '        name = lowcase(strip(kscanx(req, 1, "(")));                                           ';
      put '        vers = compress(kscanx(req,-1, "("), ".", "KD");                                      ';
      put '        put "ERROR: SAS package " req "is missing! Download it by hand or if the SAS session";';
      put '        put "ERROR- has access to the Internet and the package is available at SASPAC repository";';
      put '        put ''ERROR- use %installPackage('' name +(-1) "(" vers +(-1) ")) to install it."/;   ';
      put '        put ''ERROR- Use %loadPackage('' name +(-1)", requiredVersion=" vers +(-1) ") to load it."/;';
      put '      end ;                                                                                   ';
      put '    end;                                                                                      ';
      put '  stop;                                                                                       ';
      put 'run;                                                                                          ';
    %end;

  %if (%superq(packageRequired) ne ) 
     or (%superq(packageReqPackages) ne ) 
  %then
    %do;
      put ' data _null_;                                                     ';
      put '  if 1 = symgetn("packageRequiredErrors") then                    ';
      put '    do;                                                           ';
      put '      put "ERROR: Loading package &packageName. will be aborted!";';
      put '      put "ERROR- Required components are missing.";              ';
      put '      put "ERROR- *** STOP ***";                                  ';
      put '      ABORT;                                                      ';
      put '    end;                                                          ';
      put ' run;                                                             ';
    %end;


  do until(eof); /* loopOverTypes - start */

    set &filesWithCodes. end = EOF nobs=NOBS;
    by TYPE notsorted;
    if (upcase(type) in: ('CLEAN' 'LAZYDATA' 'TEST' 'CASLUDF' 'ADDCNT')) 
      then continue;                                          /* CASLUDF type will go in the next loop */
                                                              /* cleaning files are only included in unload.sas */
                                                              /* lazy data are only loaded on demand 
                                                                 %loadPackage(packagename, lazyData=set1 set2 set3)
                                                                 test files are used only during package generation
                                                               */
    /* test for supported types */
    if not (upcase(type) in: 
      ('LIBNAME' 'MACRO' /*'MACROS'*/ 'DATA' 
       'FUNCTION' /*'FUNCTIONS'*/ 'FORMAT' /*'FORMATS'*/ 
       'IMLMODULE' 'PROTO' 'EXEC' 'CLEAN' 
       'LAZYDATA' 'TEST' 'ADDCNT')) 
    then 
      do;
        putlog 'WARNING: Type ' type 'is not yet supported.';
        continue;
      end;

    isFunction  + (upcase(type)=:'FUNCTION');
    isFormat    + (upcase(type)=:'FORMAT'); 
    isProto     + (upcase(type)=:'PROTO');
    isIMLmodule + (upcase(type)=:'IMLMODULE');

    /* HEADERS for IML, FCMP, and PROTO - start */
    if 1 = isFunction and upcase(type)=:'FUNCTION' then 
      do;
        /* macro variable for test if cherry picking used FCMP */
        put 'data _null_;                                ';
        put "  call symputX('cherryPick_FCMP', exist('work.%lowcase(&packageName.fcmp)'), 'L'); ";
        put 'run;                                        ';
      end;
    if 1 = FIRST.type and upcase(type)='FUNCTIONS' then 
      do;
        /* header for multiple functions in one FCMP run */
        put "proc fcmp outlib = work.%lowcase(&packageName.fcmp).package ; ";
      end;
    if 1 = isProto and upcase(type)='PROTO' then 
      do;
        /* macro variable for test if cherry picking used PROTO */
        put 'data _null_;                                ';
        put "  call symputX('cherryPick_PROTO', exist('work.%lowcase(&packageName.proto)'), 'L'); ";
        put 'run;                                        ';
      end;
    if 1 = FIRST.type and upcase(type)='PROTO' then 
      do;
        protoGrpNum+1; /* number of proto directory to create "packageXX" subgroup to prevent overwrite in case 
                          of multiple proc proto dirs because multiple proc proto executed with the same
                          value of "package=" overwrites previously created content
                        */
        /* header for multiple functions in one PROTO run */
        put "proc proto package = work.%lowcase(&packageName.proto).package" ProtoGrpNum /
            " LABEL='Proc Proto C functions for &packageName. package, part" ProtoGrpNum "' ; ";
      end;
    if 1 = isFormat and upcase(type)=:'FORMAT' then 
      do;
        /* macro variable for test if cherry picking used FORMAT */
        put 'data _null_;                                  ';
        put "  call symputX('cherryPick_FORMAT', cexist('work.%lowcase(&packageName.format)'), 'L'); ";
        put 'run;                                          ';
      end;
    if 1 = FIRST.type and upcase(type)='FORMATS' then 
      do;
        /* header, for FORMATS */
        put "proc format lib = work.%lowcase(&packageName.format) ; ";
      end;
    if 1 = isIMLmodule and upcase(type)='IMLMODULE' then 
      do;
        /* macro variable for test if cherry picking used IML */
        put 'data _null_;                               ';
        put '  call symputX("cherryPick_IML_ALL",  0, "L"); ';
        put 'run;                                       ';
      end;
    if 1 = FIRST.type and upcase(type)='IMLMODULE' then 
      do;
        /* macro variable for test if cherry picking used IML */
        put 'data _null_;                               ';
        put '  call symputX("cherryPick_IML",      0, "L"); ';
        put 'run;                                       ';
        /* header, for IML modules */
        put "proc iml ; ";
      end;
    /* HEADERS for IML, FCMP, and PROTO - end */

    put ' ' /
        '%if (%str(*)=%superq(cherryPick)) or (' fileshort +(-1) ' in %superq(cherryPick)) %then %do; '; /* Cherry Pick test1 start */
    put '  %put NOTE- ;';
    put '  %put NOTE: >> Element of type ' type 'from the file "' file +(-1) '" will be included <<;';
    
    if upcase(type)=:'MACRO' then
      put '  %put %sysfunc(ifc(%SYSMACEXIST(' fileshort +(-1) ')=1, NOTE# Macro ' fileshort 
          "exist. It will be overwritten by the macro from the &packageName. package, ));";

    if upcase(type)=:'EXEC' then
      do;
        /* User can suppress running the exec files */
        put ' %sysfunc(ifc(1 = %superq(suppressExec)'
          / '  ,%nrstr(%%put INFO: Inclusion of EXEC files is suppressed!;)'
          / '  ,%str('
          / '    data _null_;'
          / '      if _N_=1 then'
          / '        put "NOTE- " /'
          / '            "NOTE- Executing the following code:" /'
          / '            "NOTE- *****************************" / ;'
          / "      infile &_PackageFileref_.(_" folder +(-1) "." file +(-1) ') lrecl=32767 end=EOF;'
          / '      input;'
          / '      putlog "*> " _infile_;'
          / '      if EOF=1 then'
          / '        put "NOTE- *****************************" /'
          / '            "NOTE- " / ;'
          / '    run;'
          / '    %include' " &_PackageFileref_.(_" folder +(-1) "." file +(-1) ') / nosource2;'
          / ' )));'
          ;
      end;
    else
      do;
        /* include the file with the code of the element */
        put '  %include' " &_PackageFileref_.(_" folder +(-1) "." file +(-1) ') / nosource2;';
      end;
    
    if upcase(type)=:'IMLMODULE' then 
      put '  %let cherryPick_IML = %eval(&cherryPick_IML. + 1);';

    if upcase(type)=:'FUNCTION' then 
      put '  %let cherryPick_FCMP = %eval(&cherryPick_FCMP. + 1);';

    if upcase(type)=:'PROTO' then 
      put '  %let cherryPick_PROTO = %eval(&cherryPick_PROTO. + 1);';

    if upcase(type)=:'FORMAT' then 
      put '  %let cherryPick_FORMAT = %eval(&cherryPick_FORMAT. + 1);';

    put '%end; ' /; /* Cherry Pick test1 end */


    /* FOOTERS for IML, FCMP, and PROTO - start */
    if 1 = LAST.type and upcase(type) in ('FUNCTIONS' 'PROTO' 'FORMATS') then 
      do; /* footer, for multiple functions in one FCMP run, one PROTO run, or one FORMAT run */
        put "run; " / ;
      end;
    if 1 = LAST.type and upcase(type)='IMLMODULE' then /* footer, for IML modules */
      do;
        put '%if 0 < &cherryPick_IML. %then %do;    ' /
            '%let cherryPick_IML_ALL = %eval(&cherryPick_IML_ALL. + &cherryPick_IML.);' /
            "reset storage = WORK.&packageName.IML; " / /* set the storage location for modules */
            "store module = _ALL_;                  " / /* and store all created modules */
            '%end;                                  ' / 
            "quit;                                  " / ;
      end;
    /* FOOTERS for IML, FCMP, and PROTO - end */

    /* add the link to the functions dataset, only for the first occurrence */
    /*if 1 = isFunction and (upcase(type)=:'FUNCTION') then
      do;
        put "options APPEND=(cmplib = work.%lowcase(&packageName.fcmp));"/;
      end;*/
    if 1 = FIRST.type and (upcase(type)=:'FUNCTION') then
      do;
        put '%sysfunc(ifc(0<' /
            '  %sysfunc(findw((%sysfunc(getoption(cmplib)))' /
            "                ,work.%lowcase(&packageName.fcmp),""'( )'"",RIO))" /
            ',,%str(options' " APPEND=(cmplib = work.%lowcase(&packageName.fcmp));)" /
            '))' ;
      end;

    /* add the link to the proto functions dataset, only for the first occurrence */
    /*if 1 = isProto and (upcase(type)=:'PROTO') then
      do;
        put "options APPEND=(cmplib = work.%lowcase(&packageName.proto));"/;
      end;*/
    if 1 = FIRST.type and (upcase(type)=:'PROTO') then
      do;
        put '%sysfunc(ifc(0<' /
            '  %sysfunc(findw((%sysfunc(getoption(cmplib)))' /
            "                ,work.%lowcase(&packageName.proto),""'( )'"",RIO))" /
            ',,%str(options' " APPEND=(cmplib = work.%lowcase(&packageName.proto));)" /
            '))' ;
      end;

    /* add the link to the formats catalog, only for the first occurrence  */
    /*if 1 = isFormat and (upcase(type)=:'FORMAT') then
      do;
        put "options INSERT=(fmtsearch = work.%lowcase(&packageName.format));"/;
      end;*/
    if 1 = FIRST.type and (upcase(type)=:'FORMAT') then
      do;
        put '%sysfunc(ifc(0<' /
            '  %sysfunc(findw((%sysfunc(getoption(fmtsearch)))' /
            "                ,work.%lowcase(&packageName.format),""'( )'"",RIO))" /
            ',,%str(options' " INSERT=(fmtsearch = work.%lowcase(&packageName.format));)" /
            '))' ;
      end;


  end; /* loopOverTypes - start */

  /* this is a header for CASLudf macro */
  put 'data _null_;                                   ';
  put '  call symputX("cherryPick_CASLUDF",  0, "L"); ';
  put 'run;                                           ';
  put 'data _null_;';
  put 'length CASLUDF $ 32767;';
  put 'dtCASLudf = datetime();';
  put 'CASLUDF =                                      ';
  put '    ''%macro ' "&packageName.CASLudf('         ";
  put ' !! "list=1,depList="                          ';
      %if %superq(packageReqPackages) ne %then
        %do;
          length reqPackage $ 32;
          do i = 1 to countw(packageReqPackages, ",", "Q");
            reqPackage = compress(scan(scan(packageReqPackages, i, ",", "Q"), 1, "[{( )}]"),"_","KAD") ;
            put ' !! " ' reqPackage ' " ';
          end;
        %end;
  put " !! ')/ des = ''CASL User Defined Functions loader for &packageName. package'';'";

  put ' !! ''  %if HELP = %superq(list) %then                               ''' /
      ' !! ''    %do;                                                       ''' / 
      ' !! ''      %put ****************************************************************************;''' /
      ' !! ''      %put This is help for the `' "&packageName.CASLudf" '` macro;''' /
      ' !! ''      %put Parameters (optional) are the following:;''' /

      ' !! ''      %put - `list` indicates if the list of loaded CASL UDFs should be displayed,;''' /
      ' !! ''      %put %str(  )when set to the value of `1` (the default) runs `FUNCTIONLIST USER%str(;)`,;''' /
      ' !! ''      %put %str(  )when set to the value of `HELP` (upcase letters!) displays this help message.;''' /

      ' !! ''      %put - `depList` [technical] contains the list of dependencies required by the package.;''' /
      ' !! ''      %put %str(  )for _this_ instance of the macro the default value is: `' @;
          %if %superq(packageReqPackages) ne %then
            %do;
              do i = 1 to countw(packageReqPackages, ",", "Q");
                reqPackage = compress(scan(scan(packageReqPackages, i, ",", "Q"), 1, "[{( )}]"),"_","KAD") ;
                put reqPackage @;
              end;
            %end; 
      put +(-1) '`.;''' /
      ' !! ''      %put The macro generated: '' !! put(dtCASLudf, E8601DT19.-L) !! ";"' /
      ' !! ''      %put with the SAS Packages Framework version 20231009.;''' / 
      ' !! ''      %put ****************************************************************************;''' /
      ' !! ''    %GOTO theEndOfTheMacro;''' / 
      ' !! ''    %end;''' ;


  put ' !! ''  %if %superq(depList) ne %then                                ''' / 
      ' !! ''    %do;                                                       ''' / 
      ' !! ''      %do i = 1 %to %sysfunc(countw(&depList.,%str( )));       ''' / 
      ' !! ''        %let depListNm = %scan(&depList.,&i.,%str( ));         ''' / 
      ' !! ''        %if %SYSMACEXIST(&depListNm.CASLudf) %then             ''' / 
      ' !! ''          %do;                                                 ''' / 
      ' !! ''            %&depListNm.CASLudf(list=0)                        ''' / 
      ' !! ''          %end;                                                ''' / 
      ' !! ''      %end;                                                    ''' / 
      ' !! ''    %end;                                                      ''' ; 

  put ' !! ''  %local tmp_NOTES;''                                                                     ';
  put ' !! ''  %let tmp_NOTES = %sysfunc(getoption(NOTES));''                                          ';
  /* the PATH macrovariable will be resolved when the load.sas file is executed */
  put ' !! "  filename ' "&_PackageFileref_." ' &ZIP. ''&path./' "%lowcase(&packageName.)" '.&zip.'';"';

  /* this loop lists includes for CASLUDFs in the macro definition */
  do until(eof1); /* loopOverTypes1 - start */
    set &filesWithCodes. end = EOF1;
    by TYPE notsorted;
    if not (upcase(type) = 'CASLUDF') then continue; /* only CASLUDF type in this loop */
    isCASLudf + 1;

    put ' ' /
        '%if (%str(*)=%superq(cherryPick)) or (' fileshort +(-1) ' in %superq(cherryPick)) %then %do; '; /* Cherry Pick test2 start */
    put '  %put NOTE- ;';
    put '  %put NOTE: >> Element of type ' type 'from the file "' file +(-1) '" will be included <<;';
    /* for CASLUDF we are building code of a macro to be run while loading */
    put '  !! ''    %include' " &_PackageFileref_.(_" folder +(-1) "." file +(-1) ') / nosource2;''';
    put '  %let cherryPick_CASLUDF = %eval(&cherryPick_CASLUDF. + 1);';
    put '%end; ' /; /* Cherry Pick test2 end */

  end; /* loopOverTypes1 - start */

  /* this is a footer for CASLudf macro */
  put ' !! "  options nonotes;"                      ' /
      " !! '  filename &_PackageFileref_. clear;'    " /
      ' !! ''  options &tmp_NOTES.;''                ' /
      ' !! ''   %if 1 = %superq(list) %then ''       ' /
      ' !! ''     %do; ''                            ' /
      ' !! "       FUNCTIONLIST USER;"               ' /
      ' !! "       run;"                             ' /
      ' !! ''     %end; ''                           ' ;
  put ' !! ''%theEndOfTheMacro: %mend;'';            ' ;

  /* generate macro for CASL user defined functions */
  if 0 < isCASLudf then
    do;
      put '%if 0 < &cherryPick_CASLUDF. %then %do;      ';
    /*put '  put / / CASLUDF / / ;                      ';*/
      put "  rc = resolve(CASLUDF);                     ";
      put '  put "NOTE: Macro named:";                  ';
      put "  put @7 '%' '&packageName.CASLudf()';       ";
      put '  put "NOTE- will be generated. Its purpose";';
      put '  put "NOTE- is to allow fast load of CASL"; ';
      put '  put "NOTE- user defined functions into";   ';
      put '  put "NOTE- the Proc CAS session.";         ';
      put '  put "NOTE-";                               ';
      put '  put "NOTE- Use it the following way:";     ';
      put "  put @7 'Proc CAS;';                        ";
      put "  put @7 '  %' '&packageName.CASLudf()';     ";
      put "  put @7 '  <... your code ...>';            ";
      put "  put @7 'quit;';                            ";
      put '  put "NOTE-";                               ';
      put '  put "NOTE-To get help run:";               ';
      put "  put @7 '  %' '&packageName.CASLudf(list=HELP)';";
      put '  put "NOTE-";                               ';
      put '%end;                                        ';
    end;
  put 'run;'/;



  /* cherry pick clean in cmplib for functions */
  if isFunction then
    do;
      put '%if 0 = &cherryPick_FCMP. %then %do;';
      put 'options cmplib = (%unquote(%sysfunc(tranwrd(' /
          '%lowcase(%sysfunc(getoption(cmplib)))' /
          ',%str(' "work.%lowcase(&packageName.fcmp)" '), %str() ))));';
      put 'options cmplib = (%unquote(%sysfunc(compress(' /
          '%sysfunc(getoption(cmplib))' /
          ',%str(()) ))));';
      put '%end;';
    end;
  /* cherry pick clean in cmplib for proto */
  if isProto then
    do; 
      put '%if 0 = &cherryPick_PROTO. %then %do;';
      put 'options cmplib = (%unquote(%sysfunc(tranwrd(' /
          '%lowcase(%sysfunc(getoption(cmplib)))' /
          ',%str(' "work.%lowcase(&packageName.proto)" '), %str() ))));';
      put 'options cmplib = (%unquote(%sysfunc(compress(' /
          '%sysfunc(getoption(cmplib))' /
          ',%str(()) ))));';
      /* proc delete is adde because "empty" PROTO creates dataset too */
      put "proc delete data=work.%lowcase(&packageName.proto); run;";
      put '%end;';
    end;
  /* list cmplib for functions */
  if isFunction OR isProto then
    do;      
      put '%put NOTE- ;';
      put '%put NOTE:[CMPLIB] %sysfunc(getoption(cmplib));' /;
    end;

  /* list fmtsearch for formats */
  if isFormat then
    do;
      put '%if 0 = &cherryPick_FORMAT. %then %do;';
      put 'options fmtsearch = (%unquote(%sysfunc(tranwrd(' /
          '%lowcase(%sysfunc(getoption(fmtsearch)))' /
          ',%str(' "work.%lowcase(&packageName.)format" '), %str() ))));';
      put 'options fmtsearch = (%unquote(%sysfunc(compress(' /
          '%sysfunc(getoption(fmtsearch))' /
          ', %str(()) ))));';
      put '%end;';
      put '%put NOTE- ;';
      put '%put NOTE:[FMTSEARCH] %sysfunc(getoption(fmtsearch));'/;
    end;

  /* create a macro loader for IML modules with dependencies */
  if isIMLmodule then
    do;
      put '%if (%str(*)=%superq(cherryPick)) or 0 < &cherryPick_IML_ALL. %then %do;';

      /* this "text wrapper" was added to get datetime generated when macro is compiled */
      put "data _null_; dtIML=datetime(); IML="; /* wrapper start */

      put '''%macro ' " &packageName.IML(list=1,err=ERROR,resetIMLstorage=1,depList=" ;
      %if %superq(packageReqPackages) ne %then
        %do;
          length reqPackage $ 32;
          do i = 1 to countw(packageReqPackages, ",", "Q");
            reqPackage = compress(scan(scan(packageReqPackages, i, ",", "Q"), 1, "[{( )}]"),"_","KAD") ;
            put " " reqPackage @;
          end;
          put ;
        %end;
      put "' !! ')/ des = ""IML Modules loader for &packageName. package"";                               ' !!" /
          '''  %if HELP = %superq(list) %then                                                               '' !!' / 
          '''    %do;                                                                                       '' !!' / 
          '''      %put ****************************************************************************;       '' !!' /
          '''      %put This is help for the `' "&packageName.IML" '` macro;                                '' !!' /
          '''      %put Parameters (optional) are the following:;                                           '' !!' /

          '''      %put - `list` indicates if the list of loaded moduls should be displayed,;                 '' !!' /
          '''      %put %str(  )when set to the value of `1` (the default) runs `SHOW MODULES%str(;)`,;       '' !!' /
          '''      %put %str(  )when set to the value of `HELP` (upcase letters!) displays this help message.;'' !!' /

          '''      %put - `resetIMLstorage` indicates if to reset default moduls storage,;                    '' !!' /
          '''      %put %str(  )when set to `1` (the default) runs `RESET STORAGE = WORK.IMLSTOR%str(;)`.;    '' !!' /

          '''      %put - `err` [technical] indicates message type in case of missing modules catalog,;       '' !!' /
          '''      %put %str(  )when set to the value of `ERROR` (the default) prints Error message.;         '' !!' /

          '''      %put - `depList` [technical] contains the list of dependencies required by the package.;   '' !!' /
          '''      %put %str(  )for _this_ instance of the macro the default value is: `' @;
          %if %superq(packageReqPackages) ne %then
            %do;
              do i = 1 to countw(packageReqPackages, ",", "Q");
                reqPackage = compress(scan(scan(packageReqPackages, i, ",", "Q"), 1, "[{( )}]"),"_","KAD") ;
                put reqPackage @;
              end;
            %end; 
      put +(-1) '`.; '' !!' /
          '''      %put The macro generated: ''' " !! put(dtIML, E8601DT19.-L) !! " ''';                    '' !!' / 
          '''      %put with the SAS Packages Framework version 20231009.;                                  '' !! ' / 
          '''      %put ****************************************************************************;       '' !! ' /
          '''    %GOTO theEndOfTheMacro;                                                                    '' !! ' / 
          '''    %end;                                                                                      '' !! ' / 

          '''  %local localSYSmacroName localPackageName i depListNm;                                       '' !! ' / 
          '''  %let localSYSmacroName = &sysmacroname.;                                                     '' !! ' / 
          '''  %let localSYSmacroName = %LOWCASE(&localSYSmacroName.);                                      '' !! ' / 
          '''  %let localPackageName = %substr(&localSYSmacroName.,1,%eval(%length(&localSYSmacroName.)-3));'' !!' / 

          '''  %if %superq(depList) ne %then                                                                '' !!' / 
          '''    %do;                                                                                       '' !!' / 
          '''      %do i = 1 %to %sysfunc(countw(&depList.,%str( )));                                       '' !!' / 
          '''        %let depListNm = %scan(&depList.,&i.,%str( ));                                         '' !!' / 
          '''        %if %SYSMACEXIST(&depListNm.IML) %then                                                 '' !!' / 
          '''          %do;                                                                                 '' !!' / 
          '''            %&depListNm.IML(list=0,err=&err.,resetIMLstorage=0)                                '' !!' / 
          '''          %end;                                                                                '' !!' / 
          '''      %end;                                                                                    '' !!' / 
          '''    %end;                                                                                      '' !!' / 
          '''  %if %sysfunc(CEXIST(WORK.&localSYSmacroName.)) %then                                         '' !!' / 
          '''    %do;                                                                                       '' !!' / 
          '''      %put NOTE: Loading IML Modules from package &localPackageName.;                          '' !!' / 
          '''      RESET STORAGE = WORK.&localSYSmacroName.;                                                '' !!' / 
          '''      LOAD MODULE = _all_;                                                                     '' !!' / 
          '''    %end;                                                                                      '' !!' / 
          '''  %else                                                                                        '' !!' / 
          '''    %do;                                                                                       '' !!' / 
          '''      %put %superq(err): IML Modules not provided;                                             '' !!' / 
          '''      %let list = 0;                                                                           '' !!' / 
          '''    %end;                                                                                      '' !!' / 
          '''  %if 1 = %superq(list) %then                                                                  '' !!' / 
          '''    %do;                                                                                       '' !!' / 
          '''      SHOW MODULES;                                                                            '' !!' / 
          '''    %end;                                                                                      '' !!' / 
          '''  %if 1 = %superq(resetIMLstorage) %then                                                       '' !!' / 
          '''    %do;                                                                                       '' !!' / 
          '''      RESET STORAGE = WORK.IMLSTOR;                                                            '' !!' / 
          '''    %end;                                                                                      '' !!' / 
          '''%theEndOfTheMacro: %mend;                                                                      ''   ' ;

      put "; rc = resolve(IML); run;"; /* wrapper end */

      put '%put NOTE: Macro named:;                          ';
      put '%put %nrstr(      %%)' "&packageName." 'IML();    ';
      put '%put NOTE- will be generated. Its purpose;        ';
      put '%put NOTE- is to allow fast load of IML;          ';
      put '%put NOTE- user defined modules into;             ';
      put '%put NOTE- the Proc IML session.;                 ';
      put '%put NOTE-;                                       ';
      put '%put NOTE- Use it the following way:;             ';
      put '%put %nrstr(      )Proc IML%str(;);               ';
      put '%put %nrstr(        %%)' "&packageName." 'IML();  ';
      put '%put %nrstr(        )<... your code ...>;         ';
      put '%put %nrstr(      )quit%str(;);                   ';
      put '%put NOTE- ;                                      ';
      put '%put NOTE- To get help info run:;                 ';
      put '%put %nrstr(      %%)' "&packageName." 'IML(list=HELP);';
      put '%put NOTE-;                                       ';

      put '%end;';
    end;


  /* update SYSloadedPackages global macrovariable */
  put '%if (%str(*)=%superq(cherryPick)) %then %do; '; /* Cherry Pick test3 start */
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
  put "          stringPCKG = kscanx(substr(SYSloadedPackages, indexPCKG+1), 1, '#');                              ";
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
  put ' run;                                                                                                        ';
  put '%end; ' / ; /* Cherry Pick test3 end */
  
  put '%put NOTE- ;';
  put '%put NOTE: '"Loading package &packageName., version &packageVersion., license &packageLicense.;";
  put '%put NOTE- *** END ***;' /;
  put "/* load.sas end */" /;
  stop;
run;

/* to load lazydata */
%put NOTE-;
%put NOTE: Preparing "lazydata" file.;
%put NOTE- ^^^^^^^^^^^^^^^^^^^^^^^^^^;
%put NOTE-;
data _null_;
  if NOBS = 0 then stop;

  file &zipReferrence.(lazydata.sas) lrecl=32767 encoding = &packageEncoding.;
 
  put "filename &_PackageFileref_. list;" /;
  put ' %put NOTE- ;'; 
  put ' %put NOTE: ' @; put "Data for package &packageName., version &packageVersion., license &packageLicense.; ";

  put ' %put NOTE: ' @; put '*** %superq(packageTitle) ***; ';
  put ' %put NOTE- ' @; put "Generated: &packageGenerated.; ";
  put ' %put NOTE- ' @; put 'Author(s): %superq(packageAuthor); ';
  put ' %put NOTE- ' @; put 'Maintainer(s): %superq(packageMaintainer); ';
  put ' %put NOTE- ;';
  put ' %put NOTE- Write %nrstr(%%)helpPackage(' "&packageName." ') for the description;';
  put ' %put NOTE- ;';
  put ' %put NOTE- *** START ***; ' /;
  
  /*put '%include ' " &_PackageFileref_.(packagemetadata.sas) / nosource2; " /;*/ /* <- copied also to loadPackage macro */

  put 'data _null_;';
  put ' length lazyData $ 32767; lazyData = lowcase(symget("lazyData"));';
  do until(eof);
    set &filesWithCodes. end = EOF nobs=NOBS;
    
    if ( upcase(type) =: 'LAZYDATA' ) then
      do;
        put 'if lazyData="*" OR findw(lazyData, "' fileshort +(-1) '") then';
        put 'do;';
        put ' put "NOTE- Dataset ' fileshort 'from the file ""' file +(-1) '"" will be loaded";';
        put ' call execute(''%nrstr(%include' " &_PackageFileref_.(_" folder +(-1) "." file +(-1) ') / nosource2;)'');';
        put 'end;' /;
      end;
    /* use lazyData to reload data type */
    if ( upcase(type) =: 'DATA' ) then
      do;
        put 'if findw(lazyData, "' fileshort +(-1) '") then';
        put 'do;';
        put ' put "NOTE- Dataset ' fileshort 'from the file ""' file +(-1) '"" will be loaded";';
        put ' call execute(''%nrstr(%include' " &_PackageFileref_.(_" folder +(-1) "." file +(-1) ') / nosource2;)'');';
        put 'end;' /;
      end;
  end;

  put 'run;';

  put '%put NOTE- ;';
  put '%put NOTE: '"Data for package &packageName., version &packageVersion., license &packageLicense.;";
  put '%put NOTE- *** END ***;' /;
  put "/* lazydata.sas end */" /;
  stop;
run;


/* unloading package objects */
%put NOTE-;
%put NOTE: Preparing unload file.;
%put NOTE- ^^^^^^^^^^^^^^^^^^^^^^;
%put NOTE-;
data _null_;
  /* break if no data */
  if NOBS = 0 then stop;

  file &zipReferrence.(unload.sas) encoding = &packageEncoding.;

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
    put '%put NOTE- ;';

    put '%include' " &_PackageFileref_.(_" folder +(-1) "." file +(-1) ') / nosource2;' /;
  end;

  /* delete macros and formats */
  put 'proc sql;';
  put '  create table WORK._%sysfunc(datetime(), hex16.)_ as';
  put '  select memname, objname, objtype';
  put '  from dictionary.catalogs';
  put '  where ';
  put '  (';
  put '   objname in ("*"' ;
  put "   ,%UPCASE('&packageName.IML')" ;
  put "   ,%UPCASE('&packageName.CASLUDF')" /;
  /* list of macros */
  EOF = 0;
  do until(EOF);
    set &filesWithCodes. end = EOF nobs = NOBS;
    if not (upcase(type)=:'MACRO') then continue;
    put '   %put NOTE- Element of type ' type 'generated from the file "' file +(-1) '" will be deleted;';
    put '   %put NOTE- ;';
    put '   ,"' fileshort upcase32. '"' /;
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
    put '   %put NOTE- Element of type ' type 'generated from the file "' file +(-1) '" will be deleted;';
    put '   %put NOTE- ;';
    put '   ,"' fileshort upcase32. '"' /;
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

  /* delete proto functions */
  isProto = 0;
  EOF = 0;
  do until(EOF);
    set &filesWithCodes. end = EOF;
    if not (upcase(type)=:'PROTO') then continue;
    put '%put NOTE- Element of type ' type 'generated from the file "' file +(-1) '" will be deleted;';
    put '%put NOTE- ;' /;
    isProto + 1;
  end;
  /* delete the link to the proto functions dataset */
  if isProto then
    do;
      put "proc delete data = work.%lowcase(&packageName.proto);";
      put "run;" /;
      put 'options cmplib = (%unquote(%sysfunc(tranwrd(' /
          '%lowcase(%sysfunc(getoption(cmplib)))' /
          ',%str(' "work.%lowcase(&packageName.proto)" '), %str() ))));';
      put 'options cmplib = (%unquote(%sysfunc(compress(' /
          '%sysfunc(getoption(cmplib))' /
          ',%str(()) ))));';
      put '%put; %put NOTE:[CMPLIB] %sysfunc(getoption(cmplib));' /;
    end;


  /* delete functions */
  put "proc fcmp outlib = work.%lowcase(&packageName.fcmp).package;";
  isFunction = 0;
  EOF = 0;
  do until(EOF);
    set &filesWithCodes. end = EOF;
    if not (upcase(type)=:'FUNCTION') then continue;
    put '%put NOTE- Element of type ' type 'generated from the file "' file +(-1) '" will be deleted;';
    put '%put NOTE- ;';
    put 'deletefunc ' fileshort ';' /;
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
    put '%put NOTE- ;';
    put 'drop table ' fileshort ';' /;
  end;
  put "quit;" /;

  /* delete libraries */
  EOF = 0;
  do until(EOF);
    set &filesWithCodes. end = EOF;
    if not (upcase(type)=:'LIBNAME') then continue; 
    put '%put NOTE- Element of type ' type 'generated from the file "' file +(-1) '" will be cleared;';
    put '%put NOTE- ;';
    put 'libname ' fileshort ' clear;' /;
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
      put '    name = strip(kscanx(req, 1, "("));                                                     ';
      put '    put ''      %unloadPackage( '' name ")" ;                                              ';
      put '  end ;                                                                                    ';
      put ' put "NOTE-" / "NOTE-"; stop;                                                              ';
      put 'run;                                                                                       ' /;
    %end;


  /* update SYSloadedPackages global macrovariable */
  put 'data _null_ ;                                                                                        ';
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
  put '%put NOTE- ;' /;
 
  put "/* unload.sas end */";
  stop;
run;

/* package preview, i.e. print out all content of the package files into the log */
%put NOTE-;
%put NOTE: Preparing preview file.;
%put NOTE- ^^^^^^^^^^^^^^^^^^^^^^^;
%put NOTE-;
data _null_;
  /* break if no data */
  if NOBS = 0 then stop;

  file &zipReferrence.(preview.sas) encoding = &packageEncoding.;
  length strX $ 32767;

  put "filename &_PackageFileref_. list;" /;
  put ' %put NOTE- ;';
  put ' %put NOTE: '"Preview of the &packageName. package, version &packageVersion., license &packageLicense.;";

  put ' %put NOTE: ' @; put '*** %superq(packageTitle) ***; ';
  put ' %put NOTE- ' @; put "Generated: &packageGenerated.; ";
  put ' %put NOTE- ' @; put 'Author(s): %superq(packageAuthor); ';
  put ' %put NOTE- ' @; put 'Maintainer(s): %superq(packageMaintainer); ';
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

  put 'data _null_;                                                 ';
  put '  if strip(symget("helpKeyword")) = " " then                 ';
  put '    do until (EOF);                                          ';
  put "      infile &_PackageFileref_.(description.sas) end = EOF;  ";
  put '      input;                                                 ';
  put '      put _infile_;                                          ';
  put '    end;                                                     ';
  put '  else stop;                                                 ';
  put 'run;                                                         ' /;

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
    set &filesWithCodes. end = EOFDS nobs = NOBS;
    if upcase(type) in: ('TEST') then continue; /* exclude tests */

    select;
      when (upcase(type) in ("DATA" "LAZYDATA")) fileshort2 = cats("'",   fileshort, "'" );
      when (upcase(type) =:  "MACRO"           ) fileshort2 = cats('''%', fileshort, "()'");
      when (upcase(type) =:  "FUNCTION"        ) fileshort2 = cats("'",   fileshort, "()'" );
      when (upcase(type) =:  "IMLMODULE"       ) fileshort2 = cats("'",   fileshort, "()'" );
      when (upcase(type) =:  "PROTO"           ) fileshort2 = cats("'",   fileshort, "()'" );
      when (upcase(type) =:  "FORMAT"          ) fileshort2 = cats("'$",  fileshort, ".'"  );
      otherwise fileshort2 = fileshort;
    end;
    strX = catx('/', folder, order, type, file, fileshort, fileshort2);
    put strX;
  end;

  put ";;;;";
  put "run;" /;

  /* loop through content found and print info to the log */
  put 'data _null_;                                                                        ';
  put 'if upcase(strip(symget("helpKeyword"))) in (" " "LICENSE") then do; stop; end;      ';
  put 'if NOBS = 0 then do; ' /
        'put; put '' *> No preview. Try %previewPackage(packageName,*) to display all.''; put; stop; ' /
      'end; ';
  put '  do until(EOFDS);                                                                  ';
  put '   set WORK._last_ end = EOFDS nobs = NOBS;                                         ';
  put '   length memberX $ 1024;                                                           ';
  put '   memberX = cats("_",folder,".",file);                                             ';
  /* inner data step in call execute to read each embedded file */
  put '   call execute("data _null_;                                                    ");';
  put "   call execute('infile &_PackageFileref_.(' || strip(memberX) || ') end = EOF;  ');";
  put '   call execute("    do until(EOF);                                              ");';
  put '   call execute("      input;                                                    ");';
  put '   call execute("      put _infile_;                                             ");';
  put '   call execute("    end;                                                        ");';
  put '   call execute("  put "" "" / "" "";                                            ");';
  put '   call execute("  stop;                                                         ");';
  put '   call execute("run;                                                            ");';
  /**/
  put "  end; ";
  put "  stop; ";
  put "run; ";
  
  /* clean-up */
  put "proc delete data = WORK._last_; ";
  put "run; ";
  put 'options ls = &ls_tmp. ps = &ps_tmp. &notes_tmp. &source_tmp.; ' /;
 
  put '%put NOTE: '"Preview of the &packageName. package, version &packageVersion., license &packageLicense.;";
  put '%put NOTE- *** END ***;' /; 
  put "/* preview.sas end */";

  stop;
run;

/* package help */
%put NOTE-;
%put NOTE: Preparing help file.;
%put NOTE- ^^^^^^^^^^^^^^^^^^^^;
%put NOTE-;
data _null_;
  /* break if no data */
  if NOBS = 0 then stop;

  file &zipReferrence.(help.sas) encoding = &packageEncoding.;
  length strX $ 32767;

  put "filename &_PackageFileref_. list;" /;
  put ' %put NOTE- ;';
  put ' %put NOTE: '"Help for package &packageName., version &packageVersion., license &packageLicense.;";

  put ' %put NOTE: ' @; put '*** %superq(packageTitle) ***; ';
  put ' %put NOTE- ' @; put "Generated: &packageGenerated.; ";
  put ' %put NOTE- ' @; put 'Author(s): %superq(packageAuthor); ';
  put ' %put NOTE- ' @; put 'Maintainer(s): %superq(packageMaintainer); ';
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

  put 'data _null_;                                                               ';
  put '  if strip(symget("helpKeyword")) = " " then                               ';
  put '    do until (EOF);                                                        ';
  put "      infile &_PackageFileref_.(description.sas) end = EOF;                ";
  put '      input;                                                               ';
  put '      if upcase(strip(_infile_)) =: "DESCRIPTION END:"   then printer = 0; ';
  put '      if printer then put "| " _infile_;                                   ';
  put '      if upcase(strip(_infile_)) =: "DESCRIPTION START:" then printer = 1; ';
  put '    end;                                                                   ';
  put '  else stop;                                                               ';


  put '  put ; put "  Package contains: "; ';
  EOFDS = 0;
  do until(EOFDS);
    /* content is created during package creation */
    set &filesWithCodes. end = EOFDS nobs = NOBS curobs = CUROBS;
    if upcase(type) in: ('TEST') then continue; /* exclude tests */

    put 'put @5 "' CUROBS +(-1) '." @10 "' type '" @21 "' fileshort '";';
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


  %if %superq(additionalContent) NE %then
  %do;
    put 'put ;' / 'put @3 ''Package contains additional content, run:  %loadPackageAddCnt(' "&packageName." ')  to load it'';';
    put "put @3 'or look for the %lowcase(&packageName.)_AdditionalContent directory in the Packages fileref';";
    put "put @3 'localization (only if additional content was deployed during the installation process).';" / "put ;";
  %end;

  put 'put "***"; put "* SAS package generated by generatePackage, version 20231009 *"; put "***";';

  put 'run;                                                                      ' /;

  /* license info */
  put 'data _null_;                                                   ';
  put '  if upcase(strip(symget("helpKeyword"))) = "LICENSE" then     ';
  put '    do until (EOF);                                            ';
  put "      infile &_PackageFileref_.(license.sas) end = EOF;        ";
  put '      input;                                                   ';
  put '      put "| " _infile_;                                       ';
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
      when (upcase(type) in ("DATA" "LAZYDATA")) fileshort2 = cats("'",   fileshort, "'" );
      when (upcase(type) =:  "MACRO"           ) fileshort2 = cats('''%', fileshort, "()'");
      when (upcase(type) =:  "FUNCTION"        ) fileshort2 = cats("'",   fileshort, "()'" );
      when (upcase(type) =:  "IMLMODULE"       ) fileshort2 = cats("'",   fileshort, "()'" );
      when (upcase(type) =:  "PROTO"           ) fileshort2 = cats("'",   fileshort, "()'" );
      when (upcase(type) =:  "FORMAT"          ) fileshort2 = cats("'$",  fileshort, ".'"  );
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
  put '   set WORK._last_ end = EOFDS nobs = NOBS;                                                               ';
  put '   length memberX $ 1024;                                                                                 ';
  put '   memberX = cats("_",folder,".",file);                                                                   ';
  /* inner data step in call execute to read each embedded file */
  put '   call execute("data _null_;                                                                          ");';
  put "   call execute('infile &_PackageFileref_.(' || strip(memberX) || ') end = EOF;                        ');";
  put '   call execute("    printer = 0;                                                                      ");';
  put '   call execute("    do until(EOF);                                                                    ");';
  put '   call execute("      input;                                                                          ");';
  put '   call execute("      _endhelpline_ = upcase(reverse(strip(_infile_)));                               ");';
  put '   call execute("      if 18 <= lengthn(_endhelpline_) AND _endhelpline_                                  ';
  put '                          =: ''/*** DNE PLEH ***/'' then printer = 0;                                  ");'; /* ends with HELP END */  
  put '   call execute("      if printer then put ""| "" _infile_;                                            ");';
  put '   call execute("      _starthelpline_ = upcase(strip(_infile_));                                      ");';
  put '   call execute("      if 20 <= lengthn(_starthelpline_) AND _starthelpline_                              ';
  put '                          =: ''/*** HELP START ***/'' then printer = 1;                                ");'; /* starts with HELP START */  
  put '   call execute("    end;                                                                              ");';
  put '   call execute("  put "" "" / "" "";                                                                  ");';
  put '   call execute("  stop;                                                                               ");';
  put '   call execute("run;                                                                                  ");';
  put '   if lowcase(type) in ("data" "lazydata") then                                                           ';
  put '    do;                                                                                                   ';
  put '     call execute("title ""Dataset " || strip(fileshort) || " from package &packageName. "";           ");';
  put '     if exist(fileshort) then call execute("proc contents data = " || strip(fileshort) || "; run;      ");';
  put '     else call execute("data _null_; put ""| Dataset " || strip(fileshort) || " does not exist.""; run;");';
  put '     call execute("title;                                                                              ");';
  put '    end;                                                                                                  ';
  /**/
  put "  end; ";
  put "  stop; ";
  put "run; ";
  
  /* clean up */
  put "proc delete data = WORK._last_; ";
  put "run; ";
  
  /* generate dataset witch content information */
  put 'data &packageContentDS. _NULL_;                                '
    / ' if "&packageContentDS." = " " then stop;                      '
    / '  infile cards4 dlm = "/";                                     '
    / '  input (folder order type file fileshort) (: $ 256.);         '
    / '  output;                                                      '
    / 'cards4;                                                        '
    ;
  
  EOFDS = 0;
  do until(EOFDS);
    /* content is created during package creation */
    set &filesWithCodes. end = EOFDS;
    if upcase(type) in: ('TEST') then continue; /* exclude tests */
    strX = catx('/', folder, order, type, file, fileshort);
    put strX;
  end;
  
  put ";;;;"
    / "run;" 
    / 'options ls = &ls_tmp. ps = &ps_tmp. &notes_tmp. &source_tmp.; ' 
    / ;
  
  put '%put NOTE: '"Help for package &packageName., version &packageVersion., license &packageLicense.;";
  put '%put NOTE- *** END ***;' /; 
  put "/* help.sas end */";
  
  stop;
run;


/* create package content */
%local notesSourceOptions;
%let notesSourceOptions = %sysfunc(getoption(notes)) %sysfunc(getoption(source));
options notes source;
%put NOTE-######################################################;
%put NOTE-# Creating package content.                          #;
%put NOTE-######################################################;
options nonotes nosource;
%local createPackageContentStatus;
%let createPackageContentStatus = 0;

data _null_;
  /* break if no data */
  if NOBS = 0 then stop;

  set &filesWithCodes. nobs = NOBS end = EOF;
  if (upcase(type) not in: ('TEST' 'ADDCNT')); /* test files and additional content are not to be copied */

  call execute(cat ('filename _SPFIN_ "', catx('/', base, folder, file), '";'));
  call execute(cats("filename _SPFOUT_ ZIP '", base, "/%lowcase(&packageName.).zip' member='_", folder, ".", file, "';") );

  /* copy code file into the zip */
  call execute('data _null_;');
  call execute('  put ;');
  call execute('  pathname = pathname("_SPFIN_");');

  call execute('  do until (ex OR Try>10) ;');
  call execute('    rc = fcopy("_SPFIN_", "_SPFOUT_");');
  call execute('    ex = fexist("_SPFOUT_"); Try + 1;');
  call execute('    put Try= " File existence in ZIP verified as: " ex;');
  call execute('  end ;');

  call execute('  if ex then put "File " pathname "copied into the package with return code: " rc "(0 = success)";');
  call execute('        else do;');
  call execute('          put "ERROR: [&sysmacroname.] File " pathname "NOT copied into the package!" ;');
  call execute('          call symputX("createPackageContentStatus",1,"L");');
  call execute('        end;');

  call execute('run;');
  /* test file content for help tags */
  call execute('data _null_;');
  call execute(' retain test .;');
  call execute(' infile _SPFIN_ lrecl=32767 dlm="0a0d"x end=EOF;');
  call execute(' input;');
  call execute(' _starthelpline_ = upcase(strip(_infile_));');
  call execute(' if 20 <= lengthn(_starthelpline_) AND _starthelpline_ =: "/*** HELP START ***/" then test + (+1); ');
  call execute(' _endhelpline_ = upcase(reverse(strip(_infile_)));');
  call execute(' if 18 <= lengthn(_endhelpline_) AND _endhelpline_ =: "/*** DNE PLEH ***/" then test + (-1); '); /* *** HELP END *** */
  call execute(' if (test not in (.,0,1)) or (EOF and test) then '); 
  call execute('   do; '); 
  call execute('     put "ERROR: [&sysmacroname.] Unmatched or nested HELP tags in ' !! catx('/', folder, file) !! '! Line: " _N_; ');
  call execute('     put "ERROR- Aborting!                      ";      ');
  call execute('     call symputX("createPackageContentStatus",1,"L");  ');
  call execute('     abort; ');
  call execute('   end; ');
  call execute(' if (EOF and test=.) then put "WARNING: No HELP tags in the file ' !! catx('/', folder, file) !! '." ; ');
  call execute('run;');

  call execute('filename _SPFIN_  clear;');
  call execute('filename _SPFOUT_ clear;');

  if EOF then
    do drivFile = 
      "packagemetadata",
      "iceloadpackage ",
      "description    ",
      "lazydata       ",
      "license        ",
      "preview        ",
      "unload         ",
      "load           ",
      "help           "
    ;
      /* test if "driving" files exist */
      call execute(cats("filename _SPFOUT_ ZIP '", base, "/%lowcase(&packageName.).zip' member='", drivFile, ".sas';") );
      call execute('data _null_;');
      call execute('  pathname = pathname("_SPFIN_");');
      call execute('  ex = fexist("_SPFOUT_");');

      call execute('  if not ex then do;');
      call execute('    put "ERROR: [&sysmacroname.] File ' !! strip(drivFile) !! '.sas DOES NOT EXIST in the package!" ;');
      call execute('    call symputX("createPackageContentStatus",1,"L"); ');
      call execute('  end;');

      call execute('run;');
      call execute('filename _SPFOUT_ clear;');
      
      stop;
    end;
run;


/* Additional Content */
/* check if a file with additional content exists in the Work library */
filename _SPFOUT_ "%sysfunc(pathname(work,L))/addcnt.zip";
%if %sysfunc(fexist(_SPFOUT_)) %then
  %do;
    %if %sysfunc(fdelete(_SPFOUT_)) NE 0 %then
      %do;
        %put ERROR: Additional content for package not generated!;
        %put ERROR- Delete "%sysfunc(pathname(work,L))/addcnt.zip" file;
        %put ERROR- and try again.;
        %let additionalContent=;
      %end;
  %end;
filename _SPFOUT_ clear;

%if %superq(additionalContent) NE %then
  %do;

    %put ;
    %put Status of additional content for the package:;
    /* create "addcnt.zip" file for Additional Content */
    data _null_;
      set &filesWithCodes.addCnt;
      if dir=0;


      rc1=filename("_SPFIN_" , catx('/',root,dname,filename), "disk", "lrecl=1 recfm=n");
      length rc1txt $ 8192;
      rc1txt=sysmsg();
      rc2=filename("_SPFOUT_", "%sysfunc(pathname(work,L))/addcnt.zip", "ZIP"
                  ,"lrecl=1 recfm=n member='" !! catx('/',dname,filename) !! "'");
      length rc2txt $ 8192;
      rc2txt=sysmsg();

      do _N_ = 1 to 10;
        rc3=fcopy("_SPFIN_","_SPFOUT_");
        length rc3txt $ 8192;
        rc3txt=sysmsg();
        if fexist("_SPFOUT_") then leave;
        else sleeprc=sleep(0.25,1);
      end;

      rc4=fexist("_SPFOUT_");
      length rc4txt $ 8192;
      rc4txt=sysmsg();

      if rc4 = 0 then
        do;
          call symputX("createPackageContentStatus",1,"L");
          put "ERROR:" @;
        end;
      put "AddCnt: " dname +(-1) "/" filename / 
          "Try=" _N_ "Return codes:" / 
          (rc:) (=);

      rc1=filename("_SPFIN_");
      rc2=filename("_SPFOUT_");
    run;

    /* inserting addcnt.zip into the package file */
    %put ;
    %put Status of inserting "addcnt.zip" into the package file:;
    data _null_;
      rc1=filename("_SPFIN_" , "%sysfunc(pathname(work,L))/addcnt.zip", "disk", "lrecl=1 recfm=n");
      length rc1txt $ 8192;
      rc1txt=sysmsg();
      rc2=filename("_SPFOUT_", pathname("&zipReferrence.","F"), "ZIP", "lrecl=1 recfm=n member='addcnt.zip'");
      length rc2txt $ 8192;
      rc2txt=sysmsg();

      do _N_ = 1 to 10;
        rc3=fcopy("_SPFIN_","_SPFOUT_");
        length rc3txt $ 8192;
        rc3txt=sysmsg();
        if fexist("_SPFOUT_") then leave;
        else sleeprc=sleep(0.25,1);
      end;
      
      rc4=fexist("_SPFOUT_");
      length rc4txt $ 8192;
      rc4txt=sysmsg();

      if rc4 then 
        rc5=fdelete("_SPFIN_");
      else
        do;
          call symputX("createPackageContentStatus",1,"L");
          put "ERROR:" @;
        end;
      put "File addcnt.zip, Try=" _N_ "Return codes:" / 
          (rc:) (=);

      rc1=filename("_SPFIN_");
      rc2=filename("_SPFOUT_");
    run;
%end;

options notes source;
%put NOTE-;
%put NOTE-######################################################;
%put NOTE-;
options &notesSourceOptions.;
/*
proc sql;
  drop table &filesWithCodes.;
quit;
*/
filename &_DESCR_. clear;
filename &_LIC_. clear;
filename &zipReferrence. clear;

/* create hash SHA256 id */
%if %sysfunc(exist(sashelp.vfunc, VIEW)) %then
%do;
  %put NOTE-;
  %put NOTE: Calculating SHA256 check sum.;
  %put NOTE- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^;
  %put NOTE-;

  filename &zipReferrence. "&filesLocation./%lowcase(&packageName.).zip";
  filename &zipReferrence. list;
  %local notesSourceOptions;
  %let notesSourceOptions = %sysfunc(getoption(notes)) %sysfunc(getoption(source));
  options NOnotes NOsource;
  data _null_;
    set sashelp.vfunc(keep=fncname);
    where fncname = "HASHING_FILE";
    call execute('
      data the_SHA256_hash_id;' !!
        /* F - file */
        " SHA256 = 'F*' !! HASHING_FILE('SHA256', pathname('&zipReferrence.','F'), 0); " !!
        ' TYPE="F"; ' !!
        ' put / @7 SHA256= / " "; output; ' !!
        /* C  - content */
        " SHA256 = 'C*' !! HASHING_FILE('SHA256', '&zipReferrence.', 4); " !!
        ' TYPE="C"; ' !!
        ' put / @7 SHA256= / " "; output; ' !!
        ' label ' !! 
        '  SHA256 = "The SHA256 hash digest for package &packageName.:" ' !!
        '  TYPE= "Type of hash digest / F = file / C = content"; ' !!
      'run;');
    call execute('proc print data = the_SHA256_hash_id noobs label split="/"; run;');
    stop;
  run;
  options &notesSourceOptions.;
  filename &zipReferrence. clear;
%end;
/*-+++++++++++++++++++++++-*/

/* verify if there were errors while package content creation */
%if %bquote(&createPackageContentStatus.) ne 0 %then
  %do;
    %put ERROR- ** [&sysmacroname.] **;
    %put ERROR: ** ERRORS IN PACKAGE CONTENT CREATION! **;
    %put ERROR- ** NO TESTING WILL BE EXECUTED.        **;
    %GOTO NOTESTING;
  %end;

/* tests of package are executed by default */
%if %bquote(&testPackage.) ne Y %then
  %do;
    %put WARNING: ** NO TESTING WILL BE EXECUTED. **;
    %GOTO NOTESTING;
  %end;


%put NOTE-;
%put NOTE: Running tests.;
%put NOTE- ^^^^^^^^^^^^^^;
%put NOTE-;
/* in case the packages macrovariable is multi-directory the first directory will be selected */
data _null_;
  length packages $ 32767;
  packages = resolve(symget("packages"));

  /* check if path contains quotes */
  quotes = lengthn(compress(packages,"""'","K"));

  /* issue error for unmatched quotes */
  if mod(quotes,2) then
    put "ERROR: Unbalanced quotes in the PACKAGES= parameter." / "ERROR- " PACKAGES= ;

  if quotes > 0 then
    call symputX("packages", dequote(kscanx(packages, 1, "()", "QS")) ,"L");
  else
    call symputX("packages", packages ,"L");
run;

/* check if systask is available  */
%if %sysfunc(GETOPTION(XCMD)) = NOXCMD %then
  %do;
    data _null_;
      put 'WARNING: NO TESTING WILL BE EXECUTED DUE TO NOXCMD.';
      put '***************************************************';
      put ;

      put 'NOTE-To execute the loading test manualy';
      put 'NOTE-run the following code:';
      put 'NOTE-';

      n=6;
      length packages $ 32767;
      packages = quote(dequote(strip(symget('packages'))));
      put @n "filename packages " packages ";" /;

      if fileexist("&packages./SPFinit.sas") then
        put @n '%include packages(SPFinit.sas);' /;
      else if fileexist("&packages./loadpackage.sas") then
        put @n '%include packages(loadpackage.sas);' / ; /* for older versions when the SPFinit.sas did not exist */

      /* load */
      put @n '%loadpackage'"(&packageName.,";
      put @n " path=&filesLocation.)" /;
      put @n '%loadpackage'"(&packageName.,";
      put @n " path=&filesLocation., lazyData=*)" /;

      /* help */
      put @n '%helpPackage'"(&packageName.,";
      put @n " path=&filesLocation.)" /;
      put @n '%helpPackage'"(&packageName.,*,";
      put @n " path=&filesLocation.)" /;
      put @n '%helpPackage'"(&packageName.,License,";
      put @n " path=&filesLocation.)" /;

      /* preview */
      put @n '%previewPackage'"(&packageName.,";
      put @n " path=&filesLocation.)" /;
      put @n '%previewPackage'"(&packageName.,*,";
      put @n " path=&filesLocation.)" /;

      /* unload */
      put @n '%unloadPackage'"(&packageName.,";
      put @n " path=&filesLocation.)         " /;

      /* additional content */
      put @n '%loadPackageAddCnt'"(&packageName.,";
      put @n " path=&filesLocation.)         " /;

      put ;
      put '***************************************************';
    run;

    %GOTO NOTESTING;
  %end;


/* locate sas binaries */
%local SASROOT SASEXE SASWORK;

%if %superq(sasexe) = %then /* empty value points to the SAS binary file based in the !sasroot directory */
  %do;
    filename sasroot "!SASROOT";
    %let SASROOT=%sysfunc(PATHNAME(sasroot));
    filename sasroot;
    %put NOTE: &=SASROOT.;
    %let SASEXE=&SASROOT./sas;
  %end;
%else
  %do;
    filename sasroot "&SASEXE.";
    %if %sysfunc(fexist(sasroot)) %then
      %do;
        %let SASROOT=%sysfunc(PATHNAME(sasroot));
        filename sasroot;
        %put NOTE: &=SASROOT.;
        %let SASEXE=&SASROOT./sas;
      %end;
    %else
      %do;
        %put ERROR: [&sysmacroname.] Provided location of the SAS binary file does not exist!;
        %put ERROR- The directory was: &SASEXE.;
        %put ERROR- Testing would not be executed.;
        filename sasroot;
        %GOTO NOTESTING;
      %end;
  %end;

%if 0 = %sysfunc(fileexist(&SASEXE.))     /* Linux/UNIX */
    AND
    0 = %sysfunc(fileexist(&SASEXE..exe)) /* WINDOWS */
%then
  %do;
    %put ERROR: [&sysmacroname.] Provided location of the SAS binary file does not contain SAS file!;
    %put ERROR- The file searched was: &SASEXE.;
    %put ERROR- Testing would not be executed.;
    %GOTO NOTESTING;
  %end;

%put NOTE: Location of the SAS binary is:;
%put NOTE- &=SASEXE. ;
%put ;

/* locate sas work */
%let SASWORK=%sysfunc(GETOPTION(work));
%put NOTE: &=SASWORK.;
%put ;

/* location of the config file */
%local SASCONFIG; /* by default a local macrovariable is empty, so no file would be pointed as a config file */

%if %Qupcase(&sascfgFile.) = DEF %then /* the DEF value points to the sasv9.cfg file in the sasroot directory */
  %do;
    %let SASCONFIG = -config ""&SASROOT./sasv9.cfg"";
    %put NOTE: The following SAS config file will be used:;
    %put NOTE- &=SASCONFIG.;
  %end;
%else %if %superq(sascfgFile) NE %then /* non-empty path points to user defined config file */
  %do;
    %if %sysfunc(fileexist(&sascfgFile.)) %then
      %do;
        %let SASCONFIG = -config ""&SASCFGFILE."";
        %put NOTE: The following SAS config file will be used:;
        %put NOTE- &=SASCONFIG.;
      %end;
    %else
      %do;
        %put ERROR: [&sysmacroname.] Provided SAS config file does not exist!;
        %put ERROR- The file was: &SASCFGFILE.;
        %put ERROR- Testing would not be executed.;
        %GOTO NOTESTING;
      %end;
  %end;


options DLCREATEDIR; /* turns-on creation of subdirectories by libname */
/* temporary location for tests results is WORK unless developer provide &testResults. */
%local testPackageTimesamp;
%let testPackageTimesamp = %lowcase(&packageName._%sysfunc(datetime(),b8601dt15.));
%if %qsysfunc(fileexist(%bquote(&testResults.))) %then
  %do;
    libname TEST "&testResults./test_&testPackageTimesamp.";
  %end;
%else
  %do;
    libname TEST "&SASWORK./test_&testPackageTimesamp.";
  %end;
/* test work points to the SAS session work */
libname TESTWORK "&SASWORK./testwork_&testPackageTimesamp.";
%local dirForTest dirForTestWork;
  %let dirForTest     = %sysfunc(pathname(TEST));
  %let dirForTestWork = %sysfunc(pathname(TESTWORK));
  %put ;
  %put NOTE: &=dirForTest.;
  %put NOTE: &=dirForTestWork.;
  %put ;

/* remember location of sessions current directory */
filename currdir ".";
filename currdir list;

/* if your package uses any other packages this points to their location */
/* test if packages fileref exists and, if do, use it */
/* if no one is provided the filesLocation is used as a replacement */
%if %bquote(&packages.)= %then %let packages=%sysfunc(pathname(packages));
%if %bquote(&packages.)= %then %let packages=&filesLocation.;
%put NOTE- ;
%put NOTE: The following location path for packages will be used during the testing:;
%put NOTE- &packages.;
/* filename packages "&packages."; */
/* filename packages list;*/

/* replace current dir with the temporary one for tests */
%put NOTE- ;
%put NOTE: Changing current folder to:;
%put NOTE- *%sysfunc(DLGCDIR(&dirForTest.))*;


/* turn off the note about quoted string length */
%local quotelenmax_tmp;
%let quotelenmax_tmp = %sysfunc(getoption(quotelenmax));
options NOquotelenmax;

/* the first test is for loading package, testing help and unloading */
/*-1-*/
data _null_;
  file "./loading.sas";

  put "proc printto";
  put "log = '&dirForTest./loading.log0'";
  put "; run;";

  put "filename packages '&packages.';" /;

  if fileexist("&packages./SPFinit.sas") then
    put '%include packages(SPFinit.sas);' /;
  else if fileexist("&packages./loadpackage.sas") then
    put '%include packages(loadpackage.sas);' / ; /* for older versions when the SPFinit.sas did not exist */

  /* load */
  put '%loadpackage'"(&packageName.,";
  put " path=&filesLocation.)" /;
  put '%loadpackage'"(&packageName.,";
  put " path=&filesLocation., lazyData=*)" /;

  /* help */
  put '%helpPackage'"(&packageName.,";
  put " path=&filesLocation.)" /;
  put '%helpPackage'"(&packageName.,*,";
  put " path=&filesLocation.)" /;
  put '%helpPackage'"(&packageName.,License,";
  put " path=&filesLocation.)" /;

  /* preview */
  put '%previewPackage'"(&packageName.,";
  put " path=&filesLocation.)" /;
  put '%previewPackage'"(&packageName.,*,";
  put " path=&filesLocation.)" /;

  /*check if package elements realy exist*/
  EOF = 0;
  do until(EOF);
    set &filesWithCodes. end = EOF;
    by type notsorted;

    fileshortUP = UPCASE(fileshort); drop fileshortUP;

    select;
      when (upcase(type) in ("LAZYDATA")) /* the "DATA" type will pop-up during deletion */
        do;
          if 1 = FIRST.type then
            put "data _null_; " ;
            put " if not exist('" fileshortUP "') then " /
                "   put 'WARNING: Dataset " fileshortUP "does not exist!'; "
                ;
          if 1 = LAST.type then
            put "run; ";
        end;

      when (upcase(type) =: "MACRO")
        do;
          if 1 = FIRST.type then
            put "data _null_; " ;
            put ' if not input(resolve(''%SYSMACEXIST(' fileshortUP ')''), best.) then ' /
                "   put 'WARNING: Macro " fileshortUP "does not exist!'; "
                ;
          if 1 = LAST.type then
            put "run; ";

        end;
        /* the "FUNCTION" type will pop-up during deletion */

        /* figure out checks for remaining list: */
        /*               
        "IMLMODULE"     
        "PROTO"         
        "FORMAT"
        */
      otherwise;
    end;
  end;

  /* unload */
  put '%unloadPackage'"(&packageName.,";
  put " path=&filesLocation.)         " /;

  /* additional content */
  put '%loadPackageAddCnt'"(&packageName.,";
  put " path=&filesLocation.)         " /;

  put "filename packages '&filesLocation.';" /
      '%listPackages()                     ' /;


  put "proc printto";
  put "; run;";

  stop;
run;

/*
setup for testing session:
  -sysin      - file with the test code
  -print      - location of the *.lst output file
  -log        - location of the log file
  -config     - location of the default config file, i.e. "&SASROOT./sasv9.cfg"
  -work       - location for work
  -noterminal - for batch execution mode
  -rsasuser   - to avoid the "Unable to copy SASUSER registry to WORK registry." warning
  -linesize   - MAX
  -pagesize   - MAX
*/
systask kill sas0 wait;
%local sasstat0 TEST_0 TESTRC_0;;
%let TEST_0 = loading;

%local STSK;
%let STSK = systask command
%str(%')"&SASEXE."
 -sysin "&dirForTest./&TEST_0..sas"
 -print "&dirForTest./&TEST_0..lst"
 -log "&dirForTest./&TEST_0..log"
 /*-altlog "&dirForTest./&TEST_0..altlog"*/
 &SASCONFIG.
  -work "&dirForTestWork."
 -noterminal
 -rsasuser -linesize MAX -pagesize MAX -noautoexec %str(%')
taskname=sas0
status=sasstat0
WAIT
;

%put NOTE: Systask:;
%put NOTE- %superq(STSK);
;
%unquote(&STSK.);
;

%let TESTRC_0 = &SYSRC.;
%put NOTE: &=sasstat0. &=TESTRC_0.;
%local notesSourceOptions;
%let notesSourceOptions = %sysfunc(getoption(notes)) %sysfunc(getoption(source));
options NOnotes NOsource;
data _null_;
  if _N_ = 1 then
    put "##########################################################################" /
        "./loading.log0" /
        "##########################################################################" ;
  infile "./loading.log0" dlm='0a0d'x end=EOF;
  input;
  if _INFILE_ =: 'WARNING:' then
    do;
      warnings+1;
      put _N_= "**" _INFILE_;
    end;
  if _INFILE_ =: 'ERROR:' then
    do;
      errors+1;
      put _N_= "$$" _INFILE_;
    end;
  if EOF then
    do;
      put "##########################################################################" ;
      put (_ALL_) (=/ "Number of ");
      call symputX("TESTW_0", warnings, "L");
      call symputX("TESTE_0", errors,   "L");
    end;
run;
options &notesSourceOptions.;
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

  _RC_ = filename(cats("_TIN_",test));
  _RC_ = filename(cats("_TOUT_",test));
run;


%local t;   
%do t = 1 %to &numberOfTests.;
/* each test is executed with autoexec loading the package */
data _null_;
  /* break if no data */
  if NOBS = 0 then stop;

  file "./autoexec.sas";

  put "proc printto";
  put "log = '&dirForTest./&&TEST_&t...log0'";
  put "; run;";

  put "filename packages '&packages.';" /;

  if fileexist("&packages./SPFinit.sas") then
    put '%include packages(SPFinit.sas);' /;
  else if fileexist("&packages./loadpackage.sas") then
    put '%include packages(loadpackage.sas);' /; /* for older versions when the SPFinit.sas did not exist */

  put '%loadpackage'"(&packageName.,";
  put " path=&filesLocation.)" /;
  put '%loadpackage'"(&packageName.,";
  put " path=&filesLocation., lazyData=*)" /;

  /* check if work should be deleted after test is done */
  delTestWork = input(symget('delTestWork'), ?? best32.);
  if not(delTestWork in (0 1)) then
    do;
      putlog "WARNING: [&sysmacroname.] The `delTestWork` parameter is invalid.";
      putlog "WARNING- [&sysmacroname.] Default value (1) is set.";
      delTestWork = 1;
    end;

  if 0 = delTestWork then
    put "options NOWORKTERM;"/;

  /*
  put "proc printto";
  put "; run;";
  */

  stop;
  set &filesWithCodes. nobs = NOBS;
run;

systask kill sas&t. wait;
%local sasstat&t. TESTRC_&t;
%let STSK =
systask command
%str(%')"&SASEXE."
 -sysin "&dirForTest./&&TEST_&t...sas"
 -print "&dirForTest./&&TEST_&t...lst"
 -log "&dirForTest./&&TEST_&t...log"
 /*-altlog "&dirForTest./&&TEST_&t...altlog"*/
 &SASCONFIG.
  -work "&dirForTestWork."
 -autoexec "&dirForTest./autoexec.sas"
 -noterminal
 -rsasuser %str(%')
taskname=sas&t.
status=sasstat&t.
WAIT
;

%put NOTE: Systask:;
%put NOTE- %superq(STSK);
;
%unquote(&STSK.);
;

%let TESTRC_&t = &SYSRC.;
%put NOTE- sasstat&t.=&&sasstat&t. TESTRC_&t=&&TESTRC_&t;
%local notesSourceOptions;
%let notesSourceOptions = %sysfunc(getoption(notes)) %sysfunc(getoption(source));
options NOnotes NOsource;
data _null_;
  if _N_ = 1 then
    put "##########################################################################" /
        "./&&TEST_&t...log0" /
        "##########################################################################" ;
  infile "./&&TEST_&t...log0" dlm='0a0d'x end=EOF;
  input;
  if _INFILE_ =: 'WARNING:' then
    do;
      warnings+1;
      /*length warningline $ 1024;
      warningline = catx(',', strip(warningline), _N_);*/
      put _N_= "**" _INFILE_;
    end;
  if _INFILE_ =: 'ERROR:' then
    do;
      errors+1;
      /*length errorline $ 1024;
      errorline = catx(',', strip(errorline), _N_);*/
      put _N_= "$$" _INFILE_;
    end;
  if EOF then
    do;
      put "##########################################################################" ;
      put (_ALL_) (=/ "Number of ");
      call symputX("TESTW_&t.", warnings, "L");
      call symputX("TESTE_&t.", errors,   "L");
    end;
run;
options &notesSourceOptions.;
%end;

data test.tests_summary;
  length testName $ 128;
  do _N_ = 0 to &numberOfTests.;
    testName = symget(cats("TEST_", _N_));
    systask  = coalesce(input(symget(cats("SASSTAT", _N_)), ?? best32.), -1);
    sysrc    = coalesce(input(symget(cats("TESTRC_", _N_)), ?? best32.), -1);
    error    = coalesce(input(symget(cats("TESTE_", _N_)),  ?? best32.), -1);
    warning  = coalesce(input(symget(cats("TESTW_", _N_)),  ?? best32.), -1);
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

%put NOTE: Changing current folder to:;
%put NOTE- *%sysfunc(DLGCDIR(%sysfunc(pathname(currdir))))*;
filename CURRDIR clear;

/* turn on the original value of the note about quoted string length */
options &quotelenmax_tmp.;

/* if you do not want any test to be executed */
%NOTESTING:

proc sql;
  drop table &filesWithCodes.;

  %if %sysfunc(exist(&filesWithCodes.addCnt)) %then
    %do;
      drop table &filesWithCodes.addCnt;
    %end;
quit;

/* turn on the original value of the note about quoted string length */
options &qlenmax_fstimer_tmp.;



%ENDofgeneratePackage:
%put --- generatePackage END ---;
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

- dodac typ "proto" [v]

- lista wymaganych komponentow potrzebnych do dzialania SASa (na bazie proc SETINIT) [v]

- sparwdzanie domknietosci, parzystosci i wystepowania tagow HELP START - HELP END w plikach [v]

- add MD5(&packageName.) value hash instead "package" word in filenames [v]

- infolista o required packahes w unloadPackage [v]

- dodac ICEloadPackage() [v]

- weryfikacja nadpisywania makr [v]

- weryfikacja srodowiska [ ]

- dodac typ "ds2" [ ]

- dodac mozliwosc szyfrowania pliku z pakietem (haslo do zip, sprawdzic istnienie funkcjonalnosci) [ ]

- doadc sprawdzanie liczby wywolan procedury fcmp, format i slowa '%macro(' w plikach z kodami [ ]

- dodac generowanie funkcji z helpem np. dla funkcji abc() mamy abc_help(), ktora wyswietla to samo co %heplPackage(package, abc()) [ ]
*/

/*** HELP START ***/  

/* Example 1: Enabling the SAS Package Framework 
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

/*+loadPackageS+*/
/*** HELP START ***/

%macro loadPackageS(
  packagesNames /* A comma separated list of packages names, 
                   e.g. myPackage, myPackage1, myPackage2, myPackage3  
                   required and not null.  
                   Package version, in brackets behind a package name, 
                   can be provided, e.g.
                    %loadPackageS(myPackage1(1.7), myPackage2(4.2))
                 */
)/secure 
/*** HELP END ***/
des = 'Macro to load multiple SAS packages at one run, version 20231009. Run %loadPackages() for help info.'
parmbuff
;
%if (%superq(packagesNames) = ) OR (%qupcase(&packagesNames.) = HELP) %then
  %do;
    %local options_tmp ;
    %let options_tmp = ls=%sysfunc(getoption(ls))ps=%sysfunc(getoption(ps))
     %sysfunc(getoption(notes)) %sysfunc(getoption(source))
     msglevel=%sysfunc(getoption(msglevel))
    ;
    options NOnotes NOsource ls=MAX ps=MAX msglevel=N;
    %put ;
    %put #################################################################################;
    %put ###      This is short help information for the `loadPackageS` macro            #;
    %put #-------------------------------------------------------------------------------#;
    %put #                                                                               #;
    %put # Macro wrapper for the loadPackage macro, version `20231009`                   #;
    %put #                                                                               #;
    %put # A SAS package is a zip file containing a group                                #;
    %put # of SAS codes (macros, functions, data steps generating                        #;
    %put # data, etc.) wrapped up together and embedded inside the zip.                  #;
    %put #                                                                               #;
    %put # The `%nrstr(%%loadPackageS())` allows to load multiple packages at one time,           #;
    %put # *ONLY* from the *ZIP* with *DEFAULT OPTIONS*, into the SAS session.           #;
    %put #                                                                               #;
    %put #### Parameters:                                                                #;
    %put #                                                                               #;
    %put # 1. `packagesNames`  A comma separated list of packages names,                 #;
    %put #                     e.g. myPackage, myPackage1, myPackage2, myPackage3        #;
    %put #                     Required and not null, default use case:                  #;
    %put #                      `%nrstr(%%loadPackageS(myPackage1, myPackage2, myPackage3))`.     #;
    %put #                     Package version, in brackets behind a package name, can   #;
    %put #                     be provided, example is the following:                    #;
    %put #                      `%nrstr(%%loadPackageS(myPackage1(1.7), myPackage2(4.2)))`.       #;
    %put #                     If empty displays this help information.                  #;
    %put #                                                                               #;
    %put #                                                                               #;
    %put #-------------------------------------------------------------------------------#;
    %put #                                                                               #;
    %put # Visit: `https://github.com/yabwon/SAS_PACKAGES/tree/main/SPF/Documentation`   #;
    %put # to learn more.                                                                #;
    %put #                                                                               #;
    %put #### Example ####################################################################;
    %put #                                                                               #;
    %put #   Enabling the SAS Package Framework                                          #;
    %put #   from the local directory and installing & loading                           #;
    %put #   the SQLinDS package from the Internet.                                      #;
    %put #                                                                               #;
    %put #   Assume that the `SPFinit.sas` file                                          #;
    %put #   is located in the "C:/SAS_PACKAGES/" folder.                                #;
    %put #                                                                               #;
    %put #   Run the following code in your SAS session:                                 #;
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas;
    %put  %nrstr( filename packages "C:/SAS_PACKAGES"; %%* setup a directory for packages;        );
    %put  %nrstr( %%include packages(SPFinit.sas);      %%* enable the framework;                 );
    %put  ;
    %put  %nrstr( %%installPackage(SQLinDS DFA)  %%* install packages from the Internet;          );
    %put  %nrstr( %%loadPackageS(SQLinDS, DFA)    %%* load packags content into the SAS session;  );
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
    %put #################################################################################;
    %put ;
    options &options_tmp.;
    %GOTO ENDofloadPackageS;
  %end;
  
  %local lengthOfsyspbuff numberOfPackagesNames i packageElement packageName packageVersion str;

  %let lengthOfsyspbuff      = %qsysfunc(length(&syspbuff.));
  %let packagesNames         = %qsysfunc(compress(%qsubstr(&syspbuff., 2, %eval(&lengthOfsyspbuff.-2)), {[(. _,)]}, KDA));
  
  %let str = %qsysfunc(translate(%superq(packagesNames),[[ ]],{(,)}));
  %let str = %qsysfunc(transtrn(%superq(str),],%str(] )));
  %let str = %qsysfunc(compbl(%superq(str)));
  %let str = %qsysfunc(transtrn(%superq(str),%str([ ),[));
  %let str = %qsysfunc(transtrn(%superq(str),%str( [),[));
  %let str = %qsysfunc(transtrn(%superq(str),%str( ]),]));
  %let str = %qsysfunc(translate(%superq(str),(),[]));
  %let packagesNames = %unquote(&str.);
  
  %let numberOfPackagesNames = %qsysfunc(countw(&packagesNames., %str( )));

  %put NOTE: List of packages to be loaded contains &numberOfPackagesNames. element(s).;
  %put NOTE- The list is: &packagesNames..;
  %put NOTE- ;

  %do i = 1 %to &numberOfPackagesNames.;
    %let packageElement = %qscan(&packagesNames., &i., %str( ) );
    %let packageName    = %qscan(&packageElement.,  1, %str(()));
    %let packageVersion = %qscan(&packageElement.,  2, %str(()));
    %if %superq(packageVersion) = %then %let packageVersion = .;

    %loadPackage(%unquote(&packageName.), requiredVersion=%unquote(&packageVersion.))
  %end;
  
%ENDofloadPackageS:
%mend loadPackageS;


/*+verifyPackage+*/
/*** HELP START ***/

%macro verifyPackage(
  packageName                         /* name of a package, 
                                         e.g. myPackage, 
                                         required and not null  */
, path = %sysfunc(pathname(packages)) /* location of a package, 
                                         by default it looks for 
                                         location of "packages" fileref */
, hash =                              /* The SHA256 hash digest for 
                                         the package generated by 
                                         hashing_file() function, SAS 9.4M6 */
)/secure 
/*** HELP END ***/
des = 'Macro to verify SAS package with the hash digest, version 20231009. Run %verifyPackage() for help info.'
;
%if (%superq(packageName) = ) OR (%qupcase(&packageName.) = HELP) %then
  %do;
    %local options_tmp ;
    %let options_tmp = ls=%sysfunc(getoption(ls))ps=%sysfunc(getoption(ps))
     %sysfunc(getoption(notes)) %sysfunc(getoption(source))
     msglevel=%sysfunc(getoption(msglevel))
    ;
    options NOnotes NOsource ls=MAX ps=MAX msglevel=N;
    %put ;
    %put #################################################################################;
    %put ###      This is short help information for the `verifyPackage` macro           #;
    %put #-------------------------------------------------------------------------------#;
    %put #                                                                               #;
    %put # Macro to verify SAS package with it hash digest, version `20231009`           #;
    %put #                                                                               #;
    %put # A SAS package is a zip file containing a group                                #;
    %put # of SAS codes (macros, functions, data steps generating                        #;
    %put # data, etc.) wrapped up together and embedded inside the zip.                  #;
    %put #                                                                               #;
    %put # The `%nrstr(%%verifyPackage())` macro generate package SHA256 hash                     #;
    %put # and compares it with the one provided by the user.                            #;
    %put #                                                                               #;
    %put #                                                                               #;
    %put # *Minimum SAS version required for the process is 9.4M6.*                      #;
    %put #                                                                               #;
    %put #### Parameters:                                                                #;
    %put #                                                                               #;
    %put # 1. `packageName`      Name of a package, e.g. myPackage,                      #;
    %put #                       Required and not null, default use case:                #;
    %put #                        `%nrstr(%%loadPackage(myPackage))`.                             #;
    %put #                       If empty displays this help information.                #;
    %put #                                                                               #;
    %put # - `hash=`             A value of the package `SHA256` hash.                   #;
    %put #                       Provided by the user.                                   #;
    %put #                                                                               #;
    %put # - `path=`             Location of a package. By default it looks for          #;
    %put #                       location of the "packages" fileref, i.e.                #;
    %put #                        `%nrstr(%%sysfunc(pathname(packages)))`                         #;
    %put #                                                                               #;
    %put #-------------------------------------------------------------------------------#;
    %put #                                                                               #;
    %put # Visit: `https://github.com/yabwon/SAS_PACKAGES/tree/main/SPF/Documentation`   #;
    %put # to learn more.                                                                #;
    %put #                                                                               #;
    %put #### Example ####################################################################;
    %put #                                                                               #;
    %put #   Enabling the SAS Package Framework                                          #;
    %put #   from the local directory and installing & loading                           #;
    %put #   the SQLinDS package from the Internet.                                      #;
    %put #                                                                               #;
    %put #   Assume that the `SPFinit.sas` file                                          #;
    %put #   is located in the "C:/SAS_PACKAGES/" folder.                                #;
    %put #                                                                               #;
    %put #   Run the following code in your SAS session:                                 #;
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas;
    %put  %nrstr( filename packages "C:/SAS_PACKAGES"; %%* set-up a directory for packages;       );
    %put  %nrstr( %%include packages(SPFinit.sas);      %%* enable the framework;                 );
    %put  ;
    %put  %nrstr( %%installPackage(SQLinDS)  %%* install the package from the Internet;           );
    %put  %nrstr( %%verifyPackage%(SQLinDS,   %%* verify the package with provided hash;          );
    %put  %nrstr(               hash=HDA478ANJ3HKHRY327FGE88HF89VH89HFFFV73GCV98RF390VB4%)        );
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
    %put #################################################################################;
    %put ;
    options &options_tmp.;
    %GOTO ENDofverifyPackage;
  %end;
  
  %local ls_tmp ps_tmp notes_tmp source_tmp stimer_tmp fullstimer_tmp msglevel_tmp;
  %let ls_tmp         = %sysfunc(getoption(ls));
  %let ps_tmp         = %sysfunc(getoption(ps));
  %let notes_tmp      = %sysfunc(getoption(notes));
  %let source_tmp     = %sysfunc(getoption(source));
  %let stimer_tmp     = %sysfunc(getoption(stimer));
  %let fullstimer_tmp = %sysfunc(getoption(fullstimer));
  %let msglevel_tmp   = %sysfunc(getoption(msglevel));
  
  options NOnotes NOsource ls=MAX ps=MAX NOfullstimer NOstimer msglevel=N;
  
  %local _PackageFileref_;
  /* %let _PackageFileref_ = P%sysfunc(MD5(%lowcase(&packageName.)),hex7.); */
  data _null_; call symputX("_PackageFileref_", "P" !! put(MD5("%lowcase(&packageName.)"), hex7. -L), "L"); run;

  /* when the packages reference is multi-directory search for the first one containing the package */
  data _null_;
    exists = 0;
    length packages $ 32767 p $ 4096;
    packages = resolve(symget("path"));
    if char(packages,1) ^= "(" then packages = quote(strip(packages)); /* for paths with spaces */
    do i = 1 to kcountw(packages, "()", "QS");
      p = dequote(kscanx(packages, i, "()", "QS"));
      exists + fileexist(catx("/", p, "%lowcase(&packageName.).zip"));
      if exists then leave;
    end;
    if exists then call symputx("path", p, "L");
  run;

  filename &_PackageFileref_. 
  /* put location of package myPackageFile.zip here */
    "&path./%lowcase(&packageName.).zip"
  ;
  %if %sysfunc(fexist(&_PackageFileref_.)) %then
    %do;
      /* create hash SHA256 id *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
      %local HASHING_FILE_exist;
      %let HASHING_FILE_exist = 0;

      %if %sysfunc(exist(sashelp.vfunc, VIEW)) %then
        %do;
          data _null_;
            set sashelp.vfunc(keep=fncname);
            where fncname = "HASHING_FILE";
            call symputX('HASHING_FILE_exist', 1, "L");
            stop;
          run;
        %end;
      
      %if &HASHING_FILE_exist. = 1 %then
        %do;
          options notes;
          filename &_PackageFileref_. list;
          
          data _null_;
            length providedHash $ 100;
            providedHash = strip(symget("hash"));
            select;
              when ( 'F*' = upcase(substr(providedHash,1,2)) ) /* F = file digest */                
                SHA256 = 'F*' !! HASHING_FILE("SHA256", pathname("&_PackageFileref_.",'F'), 0);
              when ( 'C*' = upcase(substr(providedHash,1,2)) ) /* C = content digest */                
                SHA256 = 'C*' !! HASHING_FILE("SHA256", "&_PackageFileref_.", 4);
              otherwise /* legacy approach, without C or F, digest value equivalent to C */
                SHA256 = HASHING_FILE("SHA256", "&_PackageFileref_.", 4);
            end;
            put "Provided Hash: " providedHash;
            put "SHA256 digest: " SHA256;
            put " ";
            
            if upcase(SHA256) = upcase(providedHash) then
              do;
                put "NOTE: Package verification SUCCESSFUL."; 
                put "NOTE- Generated hash is EQUAL to the provided one."; 
              end;
            else
              do;
                put "ERROR: Package verification FAILED!!"; 
                put "ERROR- Generated hash is DIFFERENT than the provided one."; 
                put "ERROR- Confirm if the package is genuine."; 
              end;
          run;
          %let HASHING_FILE_exist = 0;
        %end;
      %else 
        %put WARNING: Verification impossible! Minimum SAS version required for the process is 9.4M6. ;
    /*-+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-*/
    %end;
  %else %put ERROR:[&sysmacroname] File "&path./&packageName..zip" does not exist!;
  filename &_PackageFileref_. clear;
  
  options ls = &ls_tmp. ps = &ps_tmp. 
          &notes_tmp. &source_tmp. 
          &stimer_tmp. &fullstimer_tmp.
          msglevel=&msglevel_tmp.;
          
%ENDofverifyPackage:
%mend verifyPackage;
/**/

/*+previewPackage+*/
/*** HELP START ***/

%macro previewPackage(
  packageName                         /* name of a package, 
                                         e.g. myPackageFile.zip, 
                                         required and not null  */
, helpKeyword                         /* phrase to search for preview,
                                         when empty prints description 
                                         "*" means prints all */
, path = %sysfunc(pathname(packages)) /* location of a package, 
                                         by default it looks for 
                                         location of "packages" fileref */
, options = %str(LOWCASE_MEMNAME)     /* possible options for ZIP filename */
, source2 = /*source2*/               /* option to print out details, 
                                         null by default */
, zip = zip                           /* standard package is zip (lowcase), 
                                         e.g. %previewPackage(PiPackage,*)
                                         if the zip is not available use a folder
                                         unpack data to "pipackage.disk" folder
                                         and use previewPackage in the form: 
                                         %previewPackage(PiPackage, *, zip=disk, options=) 
                                       */
)/secure
/*** HELP END ***/
des = 'Macro to preview content of a SAS package, version 20231009. Run %previewPackage() for help info.'
;
%if (%superq(packageName) = ) OR (%qupcase(&packageName.) = HELP) %then
  %do;
    %local options_tmp ;
    %let options_tmp = ls=%sysfunc(getoption(ls))ps=%sysfunc(getoption(ps))
     %sysfunc(getoption(notes)) %sysfunc(getoption(source))
     msglevel=%sysfunc(getoption(msglevel))
    ;
    options NOnotes NOsource ls=MAX ps=MAX msglevel=N;
    %put ;
    %put #################################################################################;
    %put ###    This is short help information for the `previewPackage` macro            #;
    %put #-------------------------------------------------------------------------------#;
    %put #                                                                               #;
    %put # Macro to get previwe of a SAS packages, version `20231009`                    #;
    %put #                                                                               #;
    %put # A SAS package is a zip file containing a group                                #;
    %put # of SAS codes (macros, functions, data steps generating                        #;
    %put # data, etc.) wrapped up together and provided with                             #;
    %put # a single `preview.sas` file (also embedded inside the zip).                   #;
    %put #                                                                               #;
    %put # The `%nrstr(%%previewPackage())` macro prints, in the SAS log, content                 #;
    %put # of a SAS package. Code of a package is printed out.                           #;
    %put #                                                                               #;
    %put #-------------------------------------------------------------------------------#;
    %put #                                                                               #;
    %put #### Parameters:                                                                #;
    %put #                                                                               #;
    %put # 1. `packageName`      *Required.* Name of a package, e.g. myPackage,          #;
    %put #                       Required and not null, default use case:                #;
    %put #                        `%nrstr(%%previewPackage(myPackage)).`                          #;
    %put #                       If empty displays this help information.                #;
    %put #                                                                               #;
    %put # 2. `helpKeyword`      *Optional.*  A phrase to search in preview,             #;
    %put #                       - when empty prints description,                        #;
    %put #                       - "*" means: print all preview.                         #;
    %put #                                                                               #;
    %put # - `path=`             *Optional.* Location of a package. By default it        #;
    %put #                       looks for location of the **packages** fileref, i.e.    #;
    %put #                        `%nrstr(%%sysfunc(pathname(packages)))`                         #;
    %put #                                                                               #;
    %put # - `options=`          *Optional.* Possible options for ZIP filename,          #;
    %put #                       default value: `LOWCASE_MEMNAME`                        #;
    %put #                                                                               #;
    %put # - `source2=`          *Optional.* Option to print out details about           #;
    %put #                       what is loaded, null by default.                        #;
    %put #                                                                               #;
    %put # - `zip=`              Standard package is zip (lowcase),                      #;
    %put #                        e.g. `%nrstr(%%previewPackage(PiPackage))`.                     #;
    %put #                       If the zip is not available use a folder.               #;
    %put #                       Unpack data to "pipackage.disk" folder                  #;
    %put #                       and use previewPackage in the following form:           #;
    %put #                        `%nrstr(%%previewPackage(PiPackage, , zip=disk, options=))`     #;
    %put #                                                                               #;
    %put #-------------------------------------------------------------------------------#;
    %put #                                                                               #;
    %put # Visit: `https://github.com/yabwon/SAS_PACKAGES/tree/main/SPF/Documentation`   #;
    %put # to learn more.                                                                #;
    %put #                                                                               #;
    %put #### Example ####################################################################;
    %put #                                                                               #;
    %put #   Enabling the SAS Package Framework                                          #;
    %put #   from the local directory and installing & loading                           #;
    %put #   the SQLinDS package from the Internet.                                      #;
    %put #                                                                               #;
    %put #   Assume that the `SPFinit.sas` file                                          #;
    %put #   is located in the "C:/SAS_PACKAGES/" folder.                                #;
    %put #                                                                               #;
    %put #   Run the following code in your SAS session:                                 #;
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas;
    %put  %nrstr( filename packages "C:/SAS_PACKAGES"; %%* setup a directory for packages;        );
    %put  %nrstr( %%include packages(SPFinit.sas);      %%* enable the framework;                 );
    %put  ;
    %put  %nrstr( %%installPackage(SQLinDS)  %%* install the package from the Internet;           );
    %put  %nrstr( %%previewPackage(SQLinDS)  %%* get content of the package;                      );
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
    %put #################################################################################;
    %put ;
    options &options_tmp.;
    %GOTO ENDofpreviewPackage;
  %end;
  
  %local ls_tmp ps_tmp notes_tmp source_tmp msglevel_tmp;
  %let ls_tmp       = %sysfunc(getoption(ls));
  %let ps_tmp       = %sysfunc(getoption(ps));
  %let notes_tmp    = %sysfunc(getoption(notes));
  %let source_tmp   = %sysfunc(getoption(source));
  %let msglevel_tmp = %sysfunc(getoption(msglevel));
  options NOnotes NOsource ls=MAX ps=MAX msglevel=N;
  
  %local _PackageFileref_;
  /* %let _PackageFileref_ = P%sysfunc(MD5(%lowcase(&packageName.)),hex7.); */
  data _null_; call symputX("_PackageFileref_", "P" !! put(MD5("%lowcase(&packageName.)"), hex7. -L), "L"); run;

  /* when the packages reference is multi-directory search for the first one containing the package */
  data _null_;
    exists = 0;
    length packages $ 32767 p $ 4096;
    packages = resolve(symget("path"));
    if char(packages,1) ^= "(" then packages = quote(strip(packages)); /* for paths with spaces */
    do i = 1 to kcountw(packages, "()", "QS");
      p = dequote(kscanx(packages, i, "()", "QS"));
      exists + fileexist(catx("/", p, "%lowcase(&packageName.).&zip."));
      if exists then leave;
    end;
    if exists then call symputx("path", p, "L");
  run;

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
      %include &_PackageFileref_.(preview.sas) / &source2.;
    %end;
  %else %put ERROR:[&sysmacroname] File "&path./&packageName..&zip." does not exist!;
  filename &_PackageFileref_. clear;
  
  options ls = &ls_tmp. ps = &ps_tmp. &notes_tmp. &source_tmp. msglevel = &msglevel_tmp.;
  
%ENDofpreviewPackage:
%mend previewPackage;

/*+extendPackagesFileref+*/
/*** HELP START ***/

%macro extendPackagesFileref(
 packages /* A valid fileref name, 
             when empty the "packages" value is used */
)/secure
/*** HELP END ***/
des = 'Macro to list directories pointed by "packages" fileref, version 20231009. Run %extendPackagesFileref(HELP) for help info.'
;

%if %QUPCASE(&packages.) = HELP %then
  %do;
    %local options_tmp ;
    %let options_tmp = ls=%sysfunc(getoption(ls))ps=%sysfunc(getoption(ps))
     %sysfunc(getoption(notes)) %sysfunc(getoption(source))
     msglevel=%sysfunc(getoption(msglevel))
    ;
    options NOnotes NOsource ls=MAX ps=MAX msglevel=N;
    %put ;
    %put ###########################################################################################;
    %put ###       This is short help information for the `extendPackagesFileref` macro            #;
    %put #-----------------------------------------------------------------------------------------#;;
    %put #                                                                                         #;
    %put # Macro to list directories pointed by 'packages' fileref, version `20231009`             #;
    %put #                                                                                         #;
    %put # A SAS package is a zip file containing a group                                          #;
    %put # of SAS codes (macros, functions, data steps generating                                  #;
    %put # data, etc.) wrapped up together and embedded inside the zip.                            #;
    %put #                                                                                         #;
    %put # The `%nrstr(%%extendPackagesFileref())` macro lists directories pointed by                       #;
    %put # the packages fileref. It allows to add new dierctories to packages folder list.         #;
    %put #                                                                                         #;
    %put #### Parameters:                                                                          #;
    %put #                                                                                         #;
    %put # 1. `packages`      *Optional.* A valid fileref name, when empty the "packages" is used. #;
    %put #                       Use case:                                                         #;
    %put #                        `%nrstr(%%extendPackagesFileref()).`                                      #;
    %put #                                                                                         #;
    %put # When used as: `%nrstr(%%extendPackagesFileref(HELP))` it displays this help information.         #;
    %put #                                                                                         #;
    %put #-----------------------------------------------------------------------------------------#;
    %put #                                                                                         #;
    %put # Visit: `https://github.com/yabwon/SAS_PACKAGES/tree/main/SPF/Documentation`             #;
    %put # to learn more.                                                                          #;
    %put #                                                                                         #;
    %put #### Example ##############################################################################;
    %put #                                                                                         #;
    %put #   Enabling the SAS Package Framework                                                    #;
    %put #   from the local directory and adding                                                   #;
    %put #   new directory.                                                                        #;
    %put #                                                                                         #;
    %put #   Assume that the `SPFinit.sas` file                                                    #;
    %put #   is located in one of "C:/SAS_PK1" or "C:/SAS_PK2" folders.                            #;
    %put #                                                                                         #;
    %put #   Run the following code in your SAS session:                                           #;
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas;
    %put  %nrstr( filename packages ("C:/SAS_PK1" "C:/SAS_PK2"); %%* setup a directory for packages;        );
    %put  %nrstr( %%include packages(SPFinit.sas);               %%* enable the framework;                  );
    %put  ;
    %put  %nrstr( filename packages ("D:/NEW_DIR" %%extendPackagesFileref()); %%* add new directory;        );
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
    %put ###########################################################################################;
    %put ;
    options &options_tmp.;
    %GOTO ENDextendPackagesFileref;
  %end;

  %if %superq(packages) = %then %let packages = packages;
  %if %qsysfunc(pathname(&packages.)) ne %then
    %do;
      %if %qsubstr(%qsysfunc(pathname(&packages.)), 1, 1) = %str(%() %then
        %do;
          %local length;
          %let length = %eval(%length(%qsysfunc(pathname(&packages.)))-2);
          %unquote(%qsubstr(%qsysfunc(pathname(&packages.)), 2, &length.))
        %end;
      %else "%sysfunc(pathname(&packages.))";
  %end;
%ENDextendPackagesFileref:
%mend extendPackagesFileref; 

/* Examples:

filename packages "C:\";
%include packages(SPFinit.sas)

%extendPackagesFileref(HELP)

filename packages (%extendPackagesFileref() "D:\");
filename packages list;

filename packages clear;

filename packages "C:\";
filename packages ("D:\" %extendPackagesFileref());
filename packages list;

%put *%extendPackagesFileref()*;



*/

/*+loadPackageAddCnt+*/
/*** HELP START ***/

%macro loadPackageAddCnt(
  packageName                         /* name of a package, 
                                         e.g. myPackage, 
                                         required and not null  */
, path = %sysfunc(pathname(packages)) /* location of a package, 
                                         by default it looks for 
                                         location of "packages" fileref */
, target = %sysfunc(pathname(WORK))   /* a path in which the directory with
                                         additional content will be generated,
                                         name of directory created is set to 
                                         `&packageName._AdditionalContent` 
                                         default location is SAS work */
, source2 = /*source2*/               /* option to print out details, 
                                         null by default */
, requiredVersion = .                 /* option to test if loaded package 
                                         is provided in required version */
)/secure 
/*** HELP END ***/
des = 'Macro to load additional content for a SAS package, version 20231009. Run %loadPackageAddCnt() for help info.'
minoperator
;
%if (%superq(packageName) = ) OR (%qupcase(&packageName.) = HELP) %then
  %do;
    %local options_tmp ;
    %let options_tmp = ls=%sysfunc(getoption(ls))ps=%sysfunc(getoption(ps))
     %sysfunc(getoption(notes)) %sysfunc(getoption(source))
     msglevel=%sysfunc(getoption(msglevel))
    ;
    options NOnotes NOsource ls=MAX ps=MAX msglevel=N;
    %put ;
    %put #################################################################################;
    %put ###      This is short help information for the `loadPackageAddCnt` macro       #;
    %put #-------------------------------------------------------------------------------#;
    %put #                                                                               #;
    %put # Macro to *load* additional content for a SAS package, version `20231009`      #;
    %put #                                                                               #;
    %put # A SAS package is a zip file containing a group                                #;
    %put # of SAS codes (macros, functions, data steps generating                        #;
    %put # data, etc.) wrapped up together and included by                               #;
    %put # a single `load.sas` file (also embedded inside the zip).                      #;
    %put #                                                                               #;
    %put # The `%nrstr(%%loadPackageAddCnt())` macro loads additional content                     #;
    %put # for a package (of course only if one is provided).                            #;
    %put #                                                                               #;
    %put #-------------------------------------------------------------------------------#;
    %put #### Parameters:                                                                #;
    %put #                                                                               #;
    %put # 1. `packageName`      *Required.* Name of a package, e.g. myPackage,          #;
    %put #                       Required and not null, default use case:                #;
    %put #                        `%nrstr(%%loadPackageAddCnt(myPackage))`.                       #;
    %put #                       If empty displays this help information.                #;
    %put #                                                                               #;
    %put # - `path=`             *Optional.* Location of a package. By default it        #;
    %put #                       looks for location of the **packages** fileref, i.e.    #;
    %put #                        `%nrstr(%%sysfunc(pathname(packages)))`                         #;
    %put #                                                                               #;
    %put # - `target=`           *Optional.* Location where the directory with           #;
    %put #                       additional content will be generated,                   #;
    %put #                       name of the directory created is set to                 #;
    %put #                       `<packagename>_AdditionalContent`, the default          #;
    %put #                       location is `%nrstr(%%sysfunc(pathname(WORK)))`                  #;
    %put #                                                                               #;
    %put # - `source2=`          *Optional.* Option to print out details about           #;
    %put #                       what is loaded, null by default.                        #;
    %put #                                                                               #;
    %put # - `requiredVersion=`  *Optional.* Option to test if the loaded                #;
    %put #                       package is provided in required version,                #;
    %put #                       default value: `.`                                      #;
    %put #                                                                               #;
    %put #                                                                               #;
    %put #-------------------------------------------------------------------------------#;
    %put #                                                                               #;
    %put # Visit: `https://github.com/yabwon/SAS_PACKAGES/tree/main/SPF/Documentation`   #;
    %put # to learn more.                                                                #;
    %put #                                                                               #;
    %put ### Example 1 ###################################################################;
    %put #                                                                               #;
    %put #   Enabling the SAS Package Framework                                          #;
    %put #   from the local directory and installing & loading additional content        #;
    %put #   for the SQLinDS package.                                                    #;
    %put #                                                                               #;
    %put #   Assume that the `SPFinit.sas` file                                          #;
    %put #   is located in the "C:/SAS_PACKAGES/" folder.                                #;
    %put #                                                                               #;
    %put #   Run the following code in your SAS session:                                 #;
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas;
    %put  %nrstr( filename packages "C:/SAS_PACKAGES"; %%* setup a directory for packages;        );
    %put  %nrstr( %%include packages(SPFinit.sas);      %%* enable the framework;                 );
    %put  ;
    %put  %nrstr( %%installPackage(SQLinDS)  %%* install the package from the Internet;           );
    %put  %nrstr( %%loadPackageAddCnt(SQLinDS) %%* load additional content for the package;       );
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
    %put #                                                                               #;
    %put #################################################################################;
    %put ;
    options &options_tmp.;
    %GOTO ENDofloadPackageAddCnt;
  %end;
  /* local variables for options */
  %local ls_tmp ps_tmp notes_tmp source_tmp stimer_tmp fullstimer_tmp msglevel_tmp zip;
  %let ls_tmp         = %sysfunc(getoption(ls));
  %let ps_tmp         = %sysfunc(getoption(ps));
  %let notes_tmp      = %sysfunc(getoption(notes));
  %let source_tmp     = %sysfunc(getoption(source));
  %let stimer_tmp     = %sysfunc(getoption(stimer));
  %let fullstimer_tmp = %sysfunc(getoption(fullstimer));
  %let msglevel_tmp   = %sysfunc(getoption(msglevel));

  %let zip = zip;

  options NOnotes NOsource ls=MAX ps=MAX NOfullstimer NOstimer msglevel=N;

  %local _PackageFileref_;
  /* %let _PackageFileref_ = P%sysfunc(MD5(%lowcase(&packageName.)),hex7.); */
  data _null_; 
    call symputX("_PackageFileref_", "A" !! put(MD5("%lowcase(&packageName.)"), hex7. -L), "L"); 
    call symputX("_TargetFileref_",  "T" !! put(MD5("%lowcase(&packageName.)"), hex7. -L), "L"); 
  run;

  /* when the packages reference is multi-directory search for the first one containing the package */
  data _null_;
    exists = 0;
    length packages $ 32767 p $ 4096;
    packages = resolve(symget("path"));
    if char(packages,1) ^= "(" then packages = quote(strip(packages)); /* for paths with spaces */
    do i = 1 to kcountw(packages, "()", "QS");
      p = dequote(kscanx(packages, i, "()", "QS"));
      exists + fileexist(catx("/", p, "%lowcase(&packageName.).&zip."));
      if exists then leave;
    end;
    if exists then call symputx("path", p, "L");
  run;
  
  filename &_PackageFileref_. &ZIP. 
  /* put location of package myPackageFile.zip here */
    "&path./%lowcase(&packageName.).&zip."
  ;
  %if %sysfunc(fexist(&_PackageFileref_.)) %then
    %do;

      filename &_PackageFileref_. &ZIP. 
      /* check existence of addcnt.zip inside package */
        "&path./%lowcase(&packageName.).&zip."
        member='addcnt.zip'
      ;
      %if %sysfunc(fexist(&_PackageFileref_.)) %then
        %do;

          /* get metadata */
          filename &_PackageFileref_. &ZIP. 
            "&path./%lowcase(&packageName.).&zip."
          ;
          %include &_PackageFileref_.(packagemetadata.sas) / &source2.;
          filename &_PackageFileref_. clear;

          /* test if required version of package is "good enough" */
          %local rV pV;
          %let pV = %sysfunc(compress(&packageVersion.,.,kd));
          %let pV = %sysevalf((%scan(&pV.,1,.,M)+0)*1e8
                            + (%scan(&pV.,2,.,M)+0)*1e4
                            + (%scan(&pV.,3,.,M)+0)*1e0);
          %let rV = %sysfunc(compress(&requiredVersion.,.,kd));
          %let rV = %sysevalf((%scan(&rV.,1,.,M)+0)*1e8
                            + (%scan(&rV.,2,.,M)+0)*1e4
                            + (%scan(&rV.,3,.,M)+0)*1e0);
          
          %if %sysevalf(&rV. > &pV.) %then
            %do;
              %put ERROR: Additional content for package &packageName. will not be loaded!;
              %put ERROR- Required version is &requiredVersion.;
              %put ERROR- Provided version is &packageVersion.;
              %put ERROR- Verify installed version of the package.;
              %put ERROR- ;
              %GOTO WrongVersionOFPackageAddCnt; /*%RETURN;*/
            %end;

          /*options ls = &ls_tmp. ps = &ps_tmp. &notes_tmp. &source_tmp.;*/
          filename &_PackageFileref_. &ZIP. 
            "&path./%lowcase(&packageName.).&zip."
            member='addcnt.zip'
          ;
          /*********************/
          filename &_TargetFileref_. "&target.";
          %if %sysfunc(fexist(&_TargetFileref_.)) %then
            %do;

              %if %sysfunc(fileexist(%sysfunc(pathname(&_TargetFileref_.))/%lowcase(&packageName.)_AdditionalContent)) %then
                %do; /* dir for AC already exists */
                  %put WARNING: Target location:;
                  %put WARNING- %sysfunc(pathname(&_TargetFileref_.))/%lowcase(&packageName.)_AdditionalContent;
                  %put WARNING- already exist. Please remove it manually to upload additional contents.;
                  %put WARNING- Additional Content will not be loaded.;
                  %put WARNING- ;
                %end;
              %else
                %do;
                  /*-+-+-+-*/
                  /* create target location */
                  %put INFO:;
                  %put Additional content will be located in:;
                  %put %sysfunc(dcreate(%lowcase(&packageName.)_AdditionalContent,%sysfunc(pathname(&_TargetFileref_.))));

                  %if NOT (%sysfunc(fileexist(%sysfunc(pathname(&_TargetFileref_.))/%lowcase(&packageName.)_AdditionalContent))) %then
                    %do; /* dir for AC cannot be generated */
                      %put ERROR: Cannot create target location:;
                      %put ERROR- %sysfunc(pathname(&_TargetFileref_.))/%lowcase(&packageName.)_AdditionalContent;
                      %put ERROR- Additional Content will not be loaded.;
                      %put ERROR- ;
                    %end;
                  %else
                    %do;
                      /* extract addcnt.zip to work and, if successful, load additional content */
                      %put NOTE- **%sysfunc(DoSubL(%nrstr(
                      ;
                      options nonotes nosource ps=min ls=max;
                      data _null_;
                        call symputx("AdditionalContent", 0, "L");

                        rc1=filename("in", pathname("&_PackageFileref_."), "ZIP", "lrecl=1 recfm=n member='addcnt.zip'");
                        length rc1txt $ 8192;
                        rc1txt=sysmsg();

                        if fexist("in") then
                          do;
                            rc2=filename("out", pathname("WORK")!!"/%lowcase(&packageName.)addcnt.zip", "disk", "lrecl=1 recfm=n");
                            length rc2txt $ 8192;
                            rc2txt=sysmsg();

                            rc3=fcopy("in","out");
                            length rc3txt $ 8192;
                            rc3txt=sysmsg();

                            if rc3 then put _N_ @12 (rc:) (=);

                            if fexist("out") then 
                              do;
                                call symputx("AdditionalContent", 1, "L");
                              end;
                            else put "INFO: No additional content for package &packageName..";

                            rc1=filename("in");
                            rc2=filename("out");
                          end;
                        else
                         do;
                           call symputx("AdditionalContent", 0, "L");
                           put "INFO: No additional content for package &packageName..";
                         end;
                      run;

                      %if &AdditionalContent. %then 
                        %do;
                          filename f DUMMY;
                          filename f ZIP "%sysfunc(pathname(WORK))/%lowcase(&packageName.)addcnt.zip";
                          options dlCreateDir;
                          libname outData "%sysfunc(pathname(&_TargetFileref_.))/%lowcase(&packageName.)_AdditionalContent";

                          data WORK.__&_TargetFileref_._zip___;
                            did = dopen("f");
                            if not did then 
                              do;
                                put "ERROR: Can not access Additional Content data.";
                                stop;
                              end;
                            if did then
                             do i=1 to dnum(did);
                              length file $ 8192;
                              file = dread(did, i);
                              output;
                              keep file;
                             end;
                            did = dclose(did);
                          run;

                          data _null_; 
                          	set WORK.__&_TargetFileref_._zip___ end = EOF;
                            wc = countw(file,"/\");
                          
                            length libText pathname_f $ 8192;
                            libText = pathname("outData", "L");
                         
                            if scan(file, wc , "/\") = "" then
                              do j = 1 to wc-1;
                                libText = catx("/", libText, scan(file, j , "/\"));
                                rc = libname("test", libText);
                                rc = libname("test");
                              end;
                            else
                              do;
                                do j = 1 to wc-1;
                                  libText = catx("/", libText, scan(file, j , "/\"));
                                  rc = libname("test", libText);
                                  rc = libname("test");
                                end;

                                pathname_f = pathname("f");
                                rc1 = filename("in", strip(pathname_f), "zip", "member='" !! strip(file) !! "' lrecl=1 recfm=n");
                                length rc1txt $ 8192;
                                rc1msg = sysmsg();
                                rc2 = filename("out", catx("/", libText, scan(file, j , "/\")), "disk", "lrecl=1 recfm=n");
                                length rc2txt $ 8192;
                                rc2msg = sysmsg();
                              
                                rc3 = fcopy("in", "out");
                                length rc3txt $ 8192;
                                rc3msg = sysmsg();
                          
                                loadingProblem + (rc3 & 1);

                                if rc3 then
                                  do;
                                    put "ERROR: Cannot extract: " file;
                                    put (rc1 rc2 rc3) (=); 
                                    put (rc1msg rc2msg rc3msg) (/);
                                    put "ERROR-"; 
                                  end;
                                crc1=filename("in");
                                crc2=filename("out");
                              end;

                              if EOF and loadingProblem then
                                do;
                                  put "ERROR: Not all files from Additional Content were extracted successfully!";
                                end;
                          run;

                          data _null_;
                            rc = fdelete("f");
                          run;

                          proc delete data = WORK.__&_TargetFileref_._zip___;
                          run;

                          libname outData;
                          filename f DUMMY;
                        %end;
                      )))**;
                    %end; 
                  /*-+-+-+-*/
                %end;
 
            %end;
          %else
            %do;
              %put ERROR: Cannot access target location:;
              %put ERROR- %sysfunc(pathname(&_TargetFileref_.));
              %put ERROR- Additional Content will not be loaded.;
              %put ERROR- ;
            %end;
          filename &_TargetFileref_. clear;
          /*********************/
        %end;
      %else %put INFO: No additional content for &packageName. package.;
    %end;
  %else %put ERROR:[&sysmacroname] File "&path./&packageName..&zip." does not exist!;
  filename &_PackageFileref_. clear;
  
  %WrongVersionOFPackageAddCnt:

  /* restore optionos */
  options ls = &ls_tmp. ps = &ps_tmp. 
          &notes_tmp. &source_tmp. 
          &stimer_tmp. &fullstimer_tmp.
          msglevel=&msglevel_tmp.;

%ENDofloadPackageAddCnt:
%mend loadPackageAddCnt;




/**/
