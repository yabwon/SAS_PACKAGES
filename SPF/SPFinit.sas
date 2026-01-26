
/**############################################################################**/
/*                                                                              */
/*  Copyright Bartosz Jablonski, since July 2019 onward.                        */
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
  Copyright (c) 2019 - 2026 Bartosz Jablonski (yabwon@gmail.com)

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

  Version 20260126.
  See examples below.

  A SAS package is a zip file containing a group of files
  with SAS code (macros, functions, data steps generating 
  data, etc.) wrapped up together and %INCLUDEed by
  a single load.sas file (also embedded inside the zip).

Contributors: 
- Stu Sztukowski 
    LinkedIn: https://www.linkedin.com/in/statsguy/ 
    GitHub: https://github.com/stu-code
- Ken Nakamatsu 
    LinkedIn: https://www.linkedin.com/in/k-nkmt 
    GitHub: https://github.com/k-nkmt

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
                                         should be suppressed, 1=suppress */
, DS2force=0                          /* indicates if PROC DS2 packages and threads
                                         should be loaded if a data set exists, 0=do not load
                                       */
)/secure
/*** HELP END ***/
des = 'Macro to load SAS package, version 20260126. Run %loadPackage() for help info.'
minoperator
;
%if (%superq(packageName) = ) OR (%qupcase(&packageName.) = HELP) %then
  %do;
    %local options_tmp ;
    %let options_tmp = ls=%sysfunc(getoption(ls)) ps=%sysfunc(getoption(ps))
     %sysfunc(getoption(notes)) %sysfunc(getoption(source))
     msglevel=%sysfunc(getoption(msglevel))
    ;
    options NOnotes NOsource ls=MAX ps=MAX msglevel=N;
    %put ;
    %put #################################################################################;
    %put ###      This is short help information for the `loadPackage` macro             #;
    %put #-------------------------------------------------------------------------------#;
    %put #                                                                               #;
    %put # Macro to *load* SAS packages, version `20260126`                              #;
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
    %put # - `DS2force=`         *Optional.* Indicates if loading of `PROC DS2` packages #;
    %put #                       or threads should overwrite existing SAS data sets.     #;
    %put #                       Default value of `0` means "do not overwrite".          #;
    %put #                                                                               #;
    %put #-------------------------------------------------------------------------------#;
    %put #                                                                               #;
    %put # Visit: `https://github.com/yabwon/SAS_PACKAGES/tree/main/SPF/Documentation`   #;
    %put # to learn more.                                                                #;
    %put # Tutorials available at: `https://github.com/yabwon/HoW-SASPackages`           #;
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
  %local ls_tmp ps_tmp notes_tmp source_tmp stimer_tmp fullstimer_tmp msglevel_tmp mautocomploc_tmp;
  %let ls_tmp         = %sysfunc(getoption(ls));
  %let ps_tmp         = %sysfunc(getoption(ps));
  %let notes_tmp      = %sysfunc(getoption(notes));
  %let source_tmp     = %sysfunc(getoption(source));
  %let stimer_tmp     = %sysfunc(getoption(stimer));
  %let fullstimer_tmp = %sysfunc(getoption(fullstimer));
  %let msglevel_tmp   = %sysfunc(getoption(msglevel));
  %let mautocomploc_tmp = %sysfunc(getoption(mautocomploc));

  options NOnotes NOsource ls=MAX ps=MAX NOfullstimer NOstimer msglevel=N NOmautocomploc;

  %local _PackageFileref_;
  data _null_; 
    call symputX("_PackageFileref_", "P" !! put(MD5(lowcase("&packageName.")), hex7. -L), "L"); 
  run;

  /* when the packages reference is multi-directory search for the first one containing the package */
  data _null_;
    exists = 0;
    length packages $ 32767 p $ 4096;
    packages = resolve(symget("path"));
    if char(packages,1) ^= "(" then packages = quote(strip(packages)); /* for paths with spaces */
    do i = 1 to kcountw(packages, "()", "QS");
      p = dequote(kscanx(packages, i, "()", "QS"));
      exists + fileexist(catx("/", p, lowcase("&packageName.") !! ".&zip."));
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

  %if %superq(DS2force) NE 1 %then
    %do;
      %let DS2force = 0;
    %end;

  filename &_PackageFileref_. &ZIP. 
  /* put location of package myPackageFile.zip here */
    "&path./%sysfunc(lowcase(&packageName.)).&zip." %unquote(&options.)
  ;
  %if %sysfunc(fexist(&_PackageFileref_.)) %then
    %do;
      %include &_PackageFileref_.(packagemetadata.sas) / &source2.;
      filename &_PackageFileref_. clear;

      /* test if required version of package is "good enough" */
      %local rV pV rV0 pV0 rVsign;
      %let pV0 = %sysfunc(compress(&packageVersion.,.,kd));
      %let pV = %sysevalf((%scan(&pV0.,1,.,M)+0)*1e8
                        + (%scan(&pV0.,2,.,M)+0)*1e4
                        + (%scan(&pV0.,3,.,M)+0)*1e0);

      %let rV0 = %sysfunc(compress(&requiredVersion.,.,kd));
      %let rVsign = %sysfunc(compress(&requiredVersion.,<=>,k));
      %if %superq(rVsign)= %then %let rVsign=<=;
      %else %if NOT (%superq(rVsign) IN (%str(=) %str(<=) %str(=<) %str(=>) %str(>=) %str(<) %str(>))) %then 
        %do;
          %put WARNING: Illegal operatopr "%superq(rVsign)"! Default(<=) will be used.;
          %put WARNING- Supported operators are: %str(= <= =< => >= < >);
          %let rVsign=<=;
        %end;
      %let rV = %sysevalf((%scan(&rV0.,1,.,M)+0)*1e8
                        + (%scan(&rV0.,2,.,M)+0)*1e4
                        + (%scan(&rV0.,3,.,M)+0)*1e0);
      
      %if NOT %sysevalf(&rV. &rVsign. &pV.) %then
        %do;
          %put ERROR: Package &packageName. will not be loaded!;
          %put ERROR- Required version is &rV0.;
          %put ERROR- Provided version is &pV0.;
          %put ERROR- Condition %bquote((&rV0. &rVsign. &pV0.)) evaluates to %sysevalf(&rV. &rVsign. &pV.);
          %put ERROR- Verify installed version of the package.;
          %put ERROR- ;
          %GOTO WrongVersionOFPackage; /*%RETURN;*/
        %end;

      options ls = &ls_tmp. ps = &ps_tmp. &notes_tmp. &source_tmp.;
      filename &_PackageFileref_. &ZIP. 
        "&path./%sysfunc(lowcase(&packageName.)).&zip." %unquote(&options.)
        ENCODING =
          %if %bquote(&packageEncoding.) NE %then &packageEncoding. ;
                                            %else utf8 ;
      ;
      %if %superq(lazyData) = %then
        %do;
          %local tempLoad_minoperator temp_noNotes_etc /* for hiding notes */ ;
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
          msglevel=&msglevel_tmp. &mautocomploc_tmp.;

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
des = 'Macro to unload SAS package, version 20260126. Run %unloadPackage() for help info.'
;
%if (%superq(packageName) = ) OR (%qupcase(&packageName.) = HELP) %then
  %do;
    %local options_tmp ;
    %let options_tmp = ls=%sysfunc(getoption(ls)) ps=%sysfunc(getoption(ps))
     %sysfunc(getoption(notes)) %sysfunc(getoption(source))
     msglevel=%sysfunc(getoption(msglevel))
    ;
    options NOnotes NOsource ls=MAX ps=MAX msglevel=N;
    %put ;
    %put #################################################################################;
    %put ###      This is short help information for the `unloadPackage` macro           #;
    %put #-------------------------------------------------------------------------------#;
    %put #                                                                               #;
    %put # Macro to unload SAS packages, version `20260126`                              #;
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
    %put # Tutorials available at: `https://github.com/yabwon/HoW-SASPackages`           #;
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
  %local ls_tmp ps_tmp notes_tmp source_tmp msglevel_tmp mautocomploc_tmp;
  %let ls_tmp       = %sysfunc(getoption(ls));
  %let ps_tmp       = %sysfunc(getoption(ps));
  %let notes_tmp    = %sysfunc(getoption(notes));
  %let source_tmp   = %sysfunc(getoption(source));
  %let msglevel_tmp = %sysfunc(getoption(msglevel));
  %let mautocomploc_tmp = %sysfunc(getoption(mautocomploc));

  options NOnotes NOsource ls=MAX ps=MAX msglevel=N NOmautocomploc;

  %local _PackageFileref_;
  data _null_; 
    call symputX("_PackageFileref_", "P" !! put(MD5(lowcase("&packageName.")), hex7. -L), "L"); 
  run;

  /* when the packages reference is multi-directory search for the first one containing the package */
  data _null_;
    exists = 0;
    length packages $ 32767 p $ 4096;
    packages = resolve(symget("path"));
    if char(packages,1) ^= "(" then packages = quote(strip(packages)); /* for paths with spaces */
    do i = 1 to kcountw(packages, "()", "QS");
      p = dequote(kscanx(packages, i, "()", "QS"));
      exists + fileexist(catx("/", p, lowcase("&packageName.") !! ".&zip."));
      if exists then leave;
    end;
    if exists then call symputx("path", p, "L");
  run;
 
  filename &_PackageFileref_. &ZIP. 
  /* put location of package myPackageFile.zip here */
    "&path./%sysfunc(lowcase(&packageName.)).&zip." %unquote(&options.)
  ;
  %if %sysfunc(fexist(&_PackageFileref_.)) %then
    %do;
      %include &_PackageFileref_.(packagemetadata.sas) / &source2.;
      filename &_PackageFileref_. clear;
      options ls = &ls_tmp. ps = &ps_tmp. &notes_tmp. &source_tmp.;
      filename &_PackageFileref_. &ZIP. 
        "&path./%sysfunc(lowcase(&packageName.)).&zip." %unquote(&options.)
        ENCODING =
          %if %bquote(&packageEncoding.) NE %then &packageEncoding. ;
                                            %else utf8 ;
      ;
      %include &_PackageFileref_.(unload.sas) / &source2.;
    %end;
  %else %put ERROR:[&sysmacroname] File "&path./&packageName..&zip." does not exist!;
  filename &_PackageFileref_. clear;

  options ls = &ls_tmp. ps = &ps_tmp. &notes_tmp. &source_tmp. 
          msglevel = &msglevel_tmp. &mautocomploc_tmp.;

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
des = 'Macro to get help about SAS package, version 20260126. Run %helpPackage() for help info.'
;
%if (%superq(packageName) = ) OR (%qupcase(&packageName.) = HELP) %then
  %do;
    %local options_tmp ;
    %let options_tmp = ls=%sysfunc(getoption(ls)) ps=%sysfunc(getoption(ps))
     %sysfunc(getoption(notes)) %sysfunc(getoption(source))
     msglevel=%sysfunc(getoption(msglevel))
    ;
    options NOnotes NOsource ls=MAX ps=MAX msglevel=N;
    %put ;
    %put #################################################################################;
    %put ###       This is short help information for the `helpPackage` macro            #;
    %put #-------------------------------------------------------------------------------#;
    %put #                                                                               #;
    %put # Macro to get help about SAS packages, version `20260126`                      #;
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
    %put # Tutorials available at: `https://github.com/yabwon/HoW-SASPackages`           #;
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
  %local ls_tmp ps_tmp notes_tmp source_tmp msglevel_tmp mautocomploc_tmp;
  %let ls_tmp       = %sysfunc(getoption(ls));
  %let ps_tmp       = %sysfunc(getoption(ps));
  %let notes_tmp    = %sysfunc(getoption(notes));
  %let source_tmp   = %sysfunc(getoption(source));
  %let msglevel_tmp = %sysfunc(getoption(msglevel));
  %let mautocomploc_tmp = %sysfunc(getoption(mautocomploc));

  options NOnotes NOsource ls=MAX ps=MAX msglevel=N NOmautocomploc;

  %local _PackageFileref_;
  data _null_; 
    call symputX("_PackageFileref_", "P" !! put(MD5(lowcase("&packageName.")), hex7. -L), "L"); 
  run;

  /* when the packages reference is multi-directory search for the first one containing the package */
  data _null_;
    exists = 0;
    length packages $ 32767 p $ 4096;
    packages = resolve(symget("path"));
    if char(packages,1) ^= "(" then packages = quote(strip(packages)); /* for paths with spaces */
    do i = 1 to kcountw(packages, "()", "QS");
      p = dequote(kscanx(packages, i, "()", "QS"));
      exists + fileexist(catx("/", p, lowcase("&packageName.") !! ".&zip."));
      if exists then leave;
    end;
    if exists then call symputx("path", p, "L");
  run;

  filename &_PackageFileref_. &ZIP. 
  /* put location of package myPackageFile.zip here */
    "&path./%sysfunc(lowcase(&packageName.)).&zip." %unquote(&options.)
  ;
  %if %sysfunc(fexist(&_PackageFileref_.)) %then
    %do;
      %include &_PackageFileref_.(packagemetadata.sas) / &source2.;
      filename &_PackageFileref_. clear;
      options ls = &ls_tmp. ps = &ps_tmp. &notes_tmp. &source_tmp.;
      filename &_PackageFileref_. &ZIP. 
        "&path./%sysfunc(lowcase(&packageName.)).&zip." %unquote(&options.)
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

  options ls = &ls_tmp. ps = &ps_tmp. &notes_tmp. &source_tmp. 
          msglevel = &msglevel_tmp. &mautocomploc_tmp.;

%ENDofhelpPackage:
%mend helpPackage;

/*
TODO:
- macro for testing available packages in the packages folder [DONE] checkout: %listPackages()
- add MD5(&packageName.) value hash instead "package" word in filenames [DONE]
*/

/*+installPackage+*/
/* Macros to install SAS packages, version 20260126  */
/* A SAS package is a zip file containing a group of files
   with SAS code (macros, functions, data steps generating 
   data, etc.) wrapped up together and %INCLUDEed by
   a single load.sas file (also embedded inside the zip).
*/
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
, instDoc=0     /* should the markdown file with documentation be installed?
                   default is 0 - means No, 1 means Yes */
, SFRCVN =      /* name of a macro variable to store success-failure return code value */
, github =      /* name of a user or an organization in GitHub, all characters except [A-z0-9_.-] are compressed */
)
/secure
minoperator 
/*** HELP END ***/
des = 'Macro to install SAS package, version 20260126. Run %%installPackage() for help info.'
;
%if (%superq(packagesNames) = ) OR (%qupcase(&packagesNames.) = HELP) %then
  %do;
    %local options_tmp ;
    %let options_tmp = ls=%sysfunc(getoption(ls)) ps=%sysfunc(getoption(ps))
     %sysfunc(getoption(notes)) %sysfunc(getoption(source))
     msglevel=%sysfunc(getoption(msglevel))
    ;
    options NOnotes NOsource ls=MAX ps=MAX msglevel=N;
    %put ;
    %put ##############################################################################################;
    %put ###       This is short help information for the `installPackage` macro                      #;
    %put #--------------------------------------------------------------------------------------------#;;
    %put #                                                                                            #;
    %put # Macro to install SAS packages, version `20260126`                                          #;
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
    %put #                   Value `0` or `SASPAC` indicates:                                         #;
    %put #                    `https://github.com/SASPAC/`                                            #;
    %put #                   Value `1` indicates:                                                     #;
    %put #                    `https://raw.githubusercontent.com/yabwon/SAS_PACKAGES/main`            #;
    %put #                   Value `2` indicates:                                                     #;
    %put #                    `https://pages.mini.pw.edu.pl/~jablonskib/SASpublic/SAS_PACKAGES`       #;
    %put #                   Value `3` or `PharmaForest` indicates:                                   #;
    %put #                    `https://github.com/PharmaForest/`                                      #;
    %put #                   Default value is `0`.                                                    #;
    %put #                                                                                            #;
    %put # - `version=`      Indicates which historical version of a package to install.              #;
    %put #                   Historical version are currently available only if `mirror=0` is set.    #;
    %put #                   Default value is null which means "install the latest".                  #;
    %put #                   When there are multiple packages to install the `version` variable       #;
    %put #                   is scan sequentially.                                                    #;
    %put #                                                                                            #;
    %put # - `replace=`      With default value of `1`, it causes existing package file 0             #;
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
    %put # - `instDoc=`      *Optional.* A package may be provided with a markdown file               #;
    %put #                   containing combined documentation of the package. The option             #;
    %put #                   indicates if the `.md` file should be also downloaded.                   #;
    %put #                   Default value of zero (`0`) means "No", one (`1`) means "Yes".           #;
    %put #                                                                                            #;
    %put # - `SFRCVN=`       *Optional.* Provides a NAME for a macro variable to store value of the   #;
    %put #                   *success-failure return code* of the installation process. Return value  #;
    %put #                   has the following form: `<number of successes>.<number of failures>`     #;
    %put #                   The macro variable is created as a *global* macro variable.              #;
    %put #                                                                                            #;
    %put #  - `github=`      *Optional.* A name of a user or an organization in GitHub.               #;
    %put #                   Allows an easy set of the search path for packages available on GitHub:  #;
    %put #                    `https://github.com/<github>/<packagename>/raw/.../`                    #;
    %put #                   All characters except `[A-z0-9_.-]` are compressed.                      #;
    %put #                                                                                            #;
    %put #--------------------------------------------------------------------------------------------#;
    %put #                                                                                            #;
    %put # Visit: `https://github.com/yabwon/SAS_PACKAGES/tree/main/SPF/Documentation`                #;
    %put # to learn more.                                                                             #;
    %put # Tutorials available at: `https://github.com/yabwon/HoW-SASPackages`                        #;
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
    %put #   multiple packages with versions from the Internet.                                       #; 
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
  %local ls_tmp ps_tmp notes_tmp source_tmp stimer_tmp fullstimer_tmp msglevel_tmp mautocomploc_tmp;

  %let ls_tmp         = %sysfunc(getoption(ls));
  %let ps_tmp         = %sysfunc(getoption(ps));
  %let notes_tmp      = %sysfunc(getoption(notes));
  %let source_tmp     = %sysfunc(getoption(source));
  %let stimer_tmp     = %sysfunc(getoption(stimer));
  %let fullstimer_tmp = %sysfunc(getoption(fullstimer));
  %let msglevel_tmp   = %sysfunc(getoption(msglevel));
  %let mautocomploc_tmp = %sysfunc(getoption(mautocomploc));

  options NOnotes NOsource ls=MAX ps=MAX NOfullstimer NOstimer msglevel=N NOmautocomploc;

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

  %let loadAddCnt = %sysevalf(NOT(0=%superq(loadAddCnt)));
  %let instDoc    = %sysevalf(NOT(0=%superq(instDoc)));
  
  %let replace    = %sysevalf(1=%superq(replace));

  %if %superq(sourcePath)= %then
    %do;
      %local SPFinitMirror SPFinitMirrorMD;
      /* the defaults are: */
      %let SPFinitMirror   = https://raw.githubusercontent.com/yabwon/SAS_PACKAGES/main/SPF/SPFinit.sas;
      %let SPFinitMirrorMD = https://raw.githubusercontent.com/yabwon/SAS_PACKAGES/main/SPF/SPFinit.md;
      %let sourcePath = https://raw.githubusercontent.com/yabwon/SAS_PACKAGES/main/packages/;

      %if %qupcase(%superq(mirror))=SASPAC       %then %let mirror = 0;
      %if %qupcase(%superq(mirror))=PHARMAFOREST %then %let mirror = 3;
      %if %superq(github) NE                     %then %let mirror = 4;
      
      %if NOT (%superq(mirror) IN (0 1 2 3 4)) %then 
        %do;
          %put WARNING: Unknown mirror: %superq(mirror)!;
          %put WARNING- Default will be used.;
          %let mirror = 0;
        %end;

      %if 0 = %superq(mirror) %then
        %do;
          %let SPFinitMirror   = https://raw.githubusercontent.com/yabwon/SAS_PACKAGES/main/SPF/SPFinit.sas;
          %let SPFinitMirrorMD = https://raw.githubusercontent.com/yabwon/SAS_PACKAGES/main/SPF/SPFinit.md;
          %let sourcePath = https://github.com/SASPAC/; /*users content*/
          %goto mirrorEnd;
        %end;

      %if 1 = %superq(mirror) %then
        %do;
          %let SPFinitMirror   = https://raw.githubusercontent.com/yabwon/SAS_PACKAGES/main/SPF/SPFinit.sas;
          %let SPFinitMirrorMD = https://raw.githubusercontent.com/yabwon/SAS_PACKAGES/main/SPF/SPFinit.md;
          %let sourcePath = https://raw.githubusercontent.com/yabwon/SAS_PACKAGES/main/packages/;
          %goto mirrorEnd;
        %end;
      
      %if 2 = %superq(mirror) %then
        %do;
          %let SPFinitMirror   = https://pages.mini.pw.edu.pl/~jablonskib/SASpublic/SAS_PACKAGES/SPF/SPFinit.sas;
          %let SPFinitMirrorMD = https://pages.mini.pw.edu.pl/~jablonskib/SASpublic/SAS_PACKAGES/SPF/SPFinit.md;
          %let sourcePath = https://pages.mini.pw.edu.pl/~jablonskib/SASpublic/SAS_PACKAGES/packages/;
          %goto mirrorEnd;
        %end;

      %if 3 = %superq(mirror) %then
        %do;
          %let SPFinitMirror   = https://raw.githubusercontent.com/yabwon/SAS_PACKAGES/main/SPF/SPFinit.sas;
          %let SPFinitMirrorMD = https://raw.githubusercontent.com/yabwon/SAS_PACKAGES/main/SPF/SPFinit.md;
          /* ingnore version support for pharmaForest for now */
          %let sourcePath = https://github.com/PharmaForest/; /*users content*/
          %goto mirrorEnd;
        %end;

      %if 4 = %superq(mirror) %then
        %do;
          %let SPFinitMirror   = https://raw.githubusercontent.com/yabwon/SAS_PACKAGES/main/SPF/SPFinit.sas;
          %let SPFinitMirrorMD = https://raw.githubusercontent.com/yabwon/SAS_PACKAGES/main/SPF/SPFinit.md;
          /* ingnore version support for pharmaForest for now */
          %let github = %sysfunc(compress(%superq(github),%str(,.-),KAD));
          %put INFO: GitHub location used is: %superq(github).;
          %let sourcePath = https://github.com/&github./; /*users content*/
          %goto mirrorEnd;
        %end;

      %mirrorEnd:
      %put INFO: Source path is &sourcePath.;
    %end;
  %else
    %do;
      %let sourcePath = %sysfunc(dequote(%superq(sourcePath)))/;
      %let mirror=-1;
      %let SPFinitMirror   = &sourcePath.SPFinit.sas;
      %let SPFinitMirrorMD = &sourcePath.SPFinit.md;
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
      %put ERROR: Syntax error in the provided list of packages!;
      %put ERROR- %superq(packagesNames);
      %goto packagesListError;
    %end;
    
  %put ;
  %put INFO: Calling: &packagesNames.;
  
  %Local PackagesInstalledSussess PackagesInstalledFail;
  %Let PackagesInstalledSussess=;
  %let PackagesInstalledFail=;

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
    %if %eval(-1 = &mirror) OR %eval(3 = &mirror) %then /* ignore version when direct path or PharmaForest is provided */
      %do;
        %let vers=;
      %end;
    %put ### &packageName.(&vers.) ###;
    
    %put *** %sysfunc(lowcase(&packageName.)) start *****************************************;
    %local in out inMD outMD _IOFileref_;
    data _null_; call symputX("_IOFileref_", put(MD5(lowcase("&packageName.")), hex7. -L), "L"); run;
    %let  in = i&_IOFileref_.;
    %let out = o&_IOFileref_.;
    %let  inMD = j&_IOFileref_.;
    %let outMD = u&_IOFileref_.;

    /* %let  in = i%sysfunc(md5(&packageName.),hex7.); */
    /* %let out = o%sysfunc(md5(&packageName.),hex7.); */

    /*options MSGLEVEL=i;*/
    %if %upcase(&packageName.) in (SPFINIT SASPACKAGEFRAMEWORK SASPACKAGESFRAMEWORK) %then
      %do;
        /* allows to install/download the framework file like any other package */
        %if %superq(mirror) in (0 1) AND (%superq(vers) ne) %then
          %do;
            %let SPFinitMirror   = https://raw.githubusercontent.com/yabwon/SAS_PACKAGES/&vers./SPF/SPFinit.sas;
            %let SPFinitMirrorMD = https://raw.githubusercontent.com/yabwon/SAS_PACKAGES/&vers./SPF/SPFinit.md;
          %end;
        %if %superq(mirror) > 1 %then
          %put %str( )Mirror %superq(mirror) does not support versioning.;
 
        /* source code file */
        filename &in. URL 
          "&SPFinitMirror." 
          recfm=N lrecl=1;
        filename &out.    
          "&firstPackagesPath./SPFinit.sas" 
          recfm=N lrecl=1;
         
        /* documentation MD file */ 
        filename &inMD. URL 
          "&SPFinitMirrorMD." 
          recfm=N lrecl=1;
        filename &outMD.    
          "&firstPackagesPath./SPFinit.md" 
          recfm=N lrecl=1;
      %end;
    %else
      %do;
        %if %superq(mirror) IN (0 3 4) %then /* SASPAC or PharmaForest or an arbitrary GitHub repo */
          %do;
            %let packageSubDir = %sysfunc(lowcase(&packageName.))/raw/main/;
            
            %if %superq(vers) ne %then
              %do;
                /*%let packageSubDir = %sysfunc(lowcase(&packageName.))/main/hist/&version./;*/
                %let packageSubDir = %sysfunc(lowcase(&packageName.))/raw/&vers./;
              %end;
          %end;
        %else
          %do;
            %if %superq(mirror) NE 0 %then
              %put %str( )Mirror %superq(mirror) does not support versioning.;
          %end;

        /* zip */
        filename &in. URL "&sourcePath.&packageSubDir.%sysfunc(lowcase(&packageName.)).zip" 
        %if (%superq(URLuser) ne ) %then
          %do;
            user = "&URLuser."
            pass = "&URLuser."
          %end;
        &URLoptions.
        recfm=N lrecl=1;
        filename &out. "&firstPackagesPath./%sysfunc(lowcase(&packageName.)).zip" recfm=N lrecl=1;
        /* markdown */
        filename &inMD. URL "&sourcePath.&packageSubDir.%sysfunc(lowcase(&packageName.)).md" 
        %if (%superq(URLuser) ne ) %then
          %do;
            user = "&URLuser."
            pass = "&URLuser."
          %end;
        &URLoptions.
        recfm=N lrecl=1;
        filename &outMD. "&firstPackagesPath./%sysfunc(lowcase(&packageName.)).md" recfm=N lrecl=1;
      %end;
    /*
    filename in  list;
    filename out list;
    */ 
    /* copy the file byte-by-byte  */
    %local installationRC;
    %let installationRC=1;
    data _null_;
      length filein fileinMD 8 
        out_path in_path out_pathMD in_pathMD rcTXT $ 4096
        out_ref in_ref out_refMD in_refMD $ 8
      ;
      out_path = pathname ("&out");
       in_path = pathname ("&in" );
      out_pathMD = pathname ("&outMD");
       in_pathMD = pathname ("&inMD" );
      out_ref = symget ("out");
       in_ref = symget ("in" );
      out_refMD = symget ("outMD");
       in_refMD = symget ("inMD" );
      rcTXT=' ';

      filein = fopen(in_ref, 'S', 1, 'B');
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

      if FEXIST(out_ref) = 0 then 
        do;
          put @2 "Installing the &packageName. package" 
            / @2 "in the &firstPackagesPath. directory.";
          rc = FCOPY(in_ref, out_ref);
          rcTXT=sysmsg();
        end;
      else if FEXIST(out_ref) = 1 then 
        do;
          if symgetn("replace")=1 then
            do;
              put @2 "The following file will be replaced during "
                / @2 "installation of the &packageName. package: " 
                / @5 out_path;
              rc = FDELETE(out_ref);
              rc = FCOPY(in_ref, out_ref);
              rcTXT=sysmsg();
            end;
          else
            do;
              put @2 "The following file will NOT be replaced: " 
                / @5 out_path;
              rc = 1;
            end;
        end;
      put @2 "Done with return code " rc= "(zero = success)" / rcTXT;
      call symputX("installationRC", rc, "L");

      /* try to install documentation file */
      if 1=symgetn("instDoc") then
        do;
          fileinMD = fopen(in_refMD, 'S', 1, 'B');
          rcMD = FCLOSE(fileinMD);

          if fileinMD then 
            do;
              if 0=FEXIST(out_refMD) then 
                do;
                  rcMD = FCOPY(in_refMD, out_refMD);
                  if rcMD=0 then
                    put @2 "Package documentation installed on request." ; /* / out_pathMD / in_pathMD; */
                end;
              else if 1=FEXIST(out_refMD) and 1=symgetn("replace") then
                do;
                  rcMD = FDELETE(out_refMD);
                  if rcMD=0 then
                    rcMD2 = FCOPY(in_refMD, out_refMD);
                  if rcMD=0 AND rcMD2=0 then
                    put @2 "Package documentation installed on demand." ; /* / out_pathMD / in_pathMD; */
                end;
            end;
          else 
            put @2 "Package documentation in markdown format not available." ; /* / out_pathMD / in_pathMD;*/
        end;
    run;
     
    filename &in.  clear;
    filename &out. clear;
    filename &inMD.  clear;
    filename &outMD. clear;

    %if 0 = &installationRC. %then
      %do;
        %if %superq(vers)= %then
          %Let PackagesInstalledSussess=&PackagesInstalledSussess. &packageName.;
        %else
          %Let PackagesInstalledSussess=&PackagesInstalledSussess. &packageName.(&vers.);
      %end;
    %else
      %do;
        %if %superq(vers)= %then
          %Let PackagesInstalledFail=&PackagesInstalledFail. &packageName.;
        %else
          %let PackagesInstalledFail=&PackagesInstalledFail. &packageName.(&vers.);
      %end;

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
    %put *** %sysfunc(lowcase(&packageName.)) end *******************************************;
  /*-++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-*/
  %end;
  

  %local sucsCount sucsCountWords;
  %let sucsCount=0;
  %if NOT(%superq(PackagesInstalledSussess)=) %then
    %do;
      %put %str( );
      %let sucsCount=%sysfunc(countw(%superq(PackagesInstalledSussess),%str( )));
      %if 1=&sucsCount. %then
        %put INFO: Package %superq(PackagesInstalledSussess) installed.;
      %else %if 1<&sucsCount. %then
        %do;
          %let sucsCountWords=%sysfunc(abs(&sucsCount.),words.);
          %put INFO: Successfully installed &sucsCountWords. packages:;
          %put %str(      )&PackagesInstalledSussess.;
        %end;
    %end;

  %local failCount failCountWords;
  %let failCount=0;
  %if NOT(%superq(PackagesInstalledFail)=) %then
    %do;
      %put %str( );
      %let failCount=%sysfunc(countw(%superq(PackagesInstalledFail),%str( )));
      %if 1=&failCount. %then
        %put WARNING: Failed to install %superq(PackagesInstalledFail) package.;
      %else %if 1<&failCount. %then
        %do;
          %let failCountWords=%sysfunc(abs(&failCount.),words.);
          %put WARNING: Failed to install &failCountWords. packages:;
          %put WARNING- &PackagesInstalledFail.;
        %end;
    %end;
  %put %str( );

  %if NOT(%superq(SFRCVN)=) %then
    %do;
      data _null_;
        length SFRCVN $ 32;
        SFRCVN = compress(symget('SFRCVN'),"_","KAD");
        value = "&sucsCount..&failCount.";
        put 'INFO: Success-Failure-Return-Code macroVariable Name is: ' SFRCVN
          / '      with value: ' value 
          / ;
        call symputX(SFRCVN, value, "G");
      run;
    %end;

  %packagesListError:
  
  options ls = &ls_tmp. ps = &ps_tmp. 
          &notes_tmp. &source_tmp. 
          &stimer_tmp. &fullstimer_tmp.
          msglevel=&msglevel_tmp. &mautocomploc_tmp.;
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


/*+listPackages+*/
/*** HELP START ***//* 

  Macro to list SAS packages in packages folder. 

  Version 20260126 

  A SAS package is a zip file containing a group 
  of SAS codes (macros, functions, data steps generating 
  data, etc.) wrapped up together and %INCLUDEed by
  a single load.sas file (also embedded inside the zip).
  

 * Example 1: Set local packages directory, enable the framework,
              and list packages in the local repository.

  filename packages "C:\SAS_PACKAGES";
  %include packages(SPFinit.sas);
  %listPackages()

*//*** HELP END ***/


%macro listPackages(
  listDataSet /* Name of a data set to save results */
, quiet = 0   /* Indicate if results should be printed in log */
)/secure parmbuff
des = 'Macro to list SAS packages from `packages` fileref, type %listPackages(HELP) for help, version 20260126.'
;
%if (%QUPCASE(&listDataSet.) = HELP) %then
  %do;
    %local options_tmp ;
    %let options_tmp = ls=%sysfunc(getoption(ls)) ps=%sysfunc(getoption(ps))
     %sysfunc(getoption(notes)) %sysfunc(getoption(source))
     msglevel=%sysfunc(getoption(msglevel))
    ;
    options NOnotes NOsource ls=MAX ps=MAX msglevel=N;
    %put ;
    %put ###########################################################################################;
    %put ###       This is short help information for the `listPackages` macro                     #;
    %put #-----------------------------------------------------------------------------------------#;;
    %put #                                                                                         #;
    %put # Macro to list available SAS packages, version `20260126`                                #;
    %put #                                                                                         #;
    %put # A SAS package is a zip file containing a group                                          #;
    %put # of SAS codes (macros, functions, data steps generating                                  #;
    %put # data, etc.) wrapped up together and embedded inside the zip.                            #;
    %put #                                                                                         #;
    %put # The `%nrstr(%%listPackages())` macro lists packages available                                    #;
    %put # in the packages folder. List is printed in the SAS Log.                                 #;
    %put #                                                                                         #;
    %put #### Parameters:                                                                          #;
    %put #                                                                                         #;
    %put # 1. `listDataSet`  Name of a SAS data set to store results in.                           #;
    %put #                   No data set options are honored.                                      #;
    %put #                                                                                         #;
    %put # - `quiet=`      *Optional.* Indicates if the LOG printout should be suspended.          #;
    %put #                 Default value of zero (`0`) means "Do printout", other means "No".      #;
    %put #                                                                                         #;
    %put # When used as: `%nrstr(%%listPackages(HELP))` it displays this help information.                  #;
    %put #                                                                                         #;
    %put #-----------------------------------------------------------------------------------------#;
    %put #                                                                                         #;
    %put # Visit: `https://github.com/yabwon/SAS_PACKAGES/tree/main/SPF/Documentation`             #;
    %put # to learn more.                                                                          #;
    %put # Tutorials available at: `https://github.com/yabwon/HoW-SASPackages`                     #;
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
    %put  ;
    %put  %nrstr( %%listPackages(ListDS,quiet=1)        %%* save packages list in ListDS data set;          );
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
    %put ###########################################################################################;
    %put ;
    options &options_tmp.;
    %GOTO ENDoflistPackages;
  %end;

%local ls_tmp ps_tmp notes_tmp source_tmp listDataSetCheck ;

%let ls_tmp     = %sysfunc(getoption(ls));
%let ps_tmp     = %sysfunc(getoption(ps));
%let notes_tmp  = %sysfunc(getoption(notes));
%let source_tmp = %sysfunc(getoption(source));
%let listDataSetCheck=0;

%let quiet = %sysevalf(NOT(0=%superq(quiet)));

options NOnotes NOsource ls=MAX ps=MAX;

data _null_;
  length listDataSet $ 41;
  listDataSet = strip(scan(symget('listDataSet'),1,'( )'));
  call symputX('listDataSet',listDataSet,"L");
  if not (listDataSet = " ") then 
    call symputX('listDataSetCheck',1,"L");
  else call symputX('quiet',0,"L");
run;

data _null_ 
  %if 1=&listDataSetCheck. %then
    %do;
      &listDataSet.(compress=yes keep=k base PackageZIPNumber folder n tag value rename=(folder=PackageZIP k=baseNumber n=tagNumber))
    %end;
;
  length k 8 baseAll $ 32767 base $ 1024 PackageZIPNumber 8;
  baseAll = pathname("packages");

  array TAGSLIST[6] $ 16 _temporary_ ("PACKAGE" "TITLE" "VERSION" "AUTHOR" "MAINTAINER" "LICENSE");

  if baseAll = " " then
    do;
      put "WARNING: The file reference PACKAGES is not assigned.";
      stop;
    end;

  if char(baseAll,1) ^= "(" then baseAll = quote(strip(baseAll)); /* for paths with spaces */
  
  do k = 1 to kcountw(baseAll, "()", "QS"); /*drop k;*/
    base = dequote(kscanx(baseAll, k, "()", "QS"));

    length folder $ 64 file $ 1024 folderRef fileRef $ 8;

    folderRef = "_%sysfunc(datetime(), hex6.)0";

    rc=filename(folderRef, base);
    folderid=dopen(folderRef);

    %if 0=&quiet. %then 
      %do; 
        putlog " ";
        put "/*" 100*"+" ;
      %end;
    do i=1 to dnum(folderId); drop i;

      if i = 1 then
        do;
          %if 0=&quiet. %then 
            %do; 
              put " #";
              put " # Listing packages for: " base;
              put " #";
            %end;
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
              PackageZIPNumber+1;
              length nn $ 96;
              %if 0=&quiet. %then 
                %do; 
                  putlog " *  ";
                  if (96-lengthn(file)) < 1 then
                    put " * " file;  
                  else
                    do;
                      nn = repeat("*", (96-lengthn(file)));   
                      put " * " file nn;
                    end;
                %end;

              infile _DUMMY_ ZIP FILEVAR=file member="description.sas" end=EOF;
              
              n = 0;
              do lineinfile = 1 by 1 until(EOF);
                input;

                length tag $ 16 value $ 4096;

                tag = strip(upcase(kscanx(_INFILE_,1,":")));
                value = kscanx(_INFILE_,2,":");
                n = whichc(tag, of TAGSLIST[*]);

                if (n > 0) then
                  do;
                    %if 0=&quiet. %then 
                      %do; 
                        putlog " *  " tag +(-1) ":" @ 17 value;
                      %end;
                    %if 1=&listDataSetCheck. %then
                      %do;
                        output &listDataSet.;
                      %end;
                    n=0;
                  end;                
                if strip(upcase(strip(_INFILE_))) =: "DESCRIPTION START:" then leave;
              end;
            end;
        end;
      
      rc = dclose(fileId);
      rc = filename(fileRef);
    end;

    %if 0=&quiet. %then 
      %do; 
        putlog " *  ";
        put 100*"+" "*/";
      %end;
    rc = dclose(folderid);
    rc = filename(folderRef);
  end;

  stop;
  label
    k = "Packages path ordering number."
    base = "Packages path."
    PackageZIPNumber = "Packages ZIP file number."
    folder = "Packages ZIP file."
    n = "Tag number"
    tag = "Package Tag Name"
    value = "Value"
    ;
run;

%if 1=&listDataSetCheck. %then
  %do;
    proc sort data=&listDataSet. out=&listDataSet.(compress=yes label='Output from the %listPackages() macro');
      by baseNumber PackageZIPNumber tagNumber;
    run;

    %if 0=&quiet. %then 
      %do; 
        %put %str( );
        %put # Results ptovided in the &listDataSet. data set. #;
        %put %str( );
      %end;
  %end;

options ls = &ls_tmp. ps = &ps_tmp. &notes_tmp. &source_tmp.;

%ENDoflistPackages:
%mend listPackages;


/*+generatePackage+*/
/*** HELP START ***//* 

   Macro to generate SAS packages.

   Version 20260126

   A SAS package is a zip file containing a group 
   of SAS codes (macros, functions, data steps generating 
   data, etc.) wrapped up together and %INCLUDEed by
   a single load.sas file (also embedded inside the zip).

   See examples below.
   
*//*** HELP END ***/

/*** HELP START ***/

%macro generatePackage(
 filesLocation   /* location of package files 
                    e.g. /path/to/package/files/location or C:\my\package\files */
,buildLocation=  /* location of package ZIP file and md (optional) 
                    when empty takes filesLocation */
/* testing options: */
,testPackage=Y        /* indicator if tests should be executed, 
                         default value Y means "execute tests" */
,packages=            /* location of other packages if there are
                         dependencies in loading, must be a single directory
                         if more than one are provided only the first is used */
,testResults=         /* location where tests results should be stored,
                         if null (the default) the WORK is used */
,workInTestResults=0  /* indicates if WORK directories for tests should be located 
                         in the same place as results  */
,testWorkPath=        /* location where tests SAS sessions' work directories 
                         should be stored, if null (the default) the main SAS 
                         session WORK is used. Takes precedence over workInTestResults= */
,sasexe=              /* a DIRECTORY where the SAS binary is located,
                         if null (the default) then the !SASROOT is used */
,sascfgFile=          /* a FILE with testing session configuration parameters
                         if null (the default) then no config file is pointed
                         during the SAS invocation,
                         if set to DEF then the !SASROOT/sasv9.cfg is used */
,delTestWork=1        /* indicates if `WORK` directories generated by user tests
                         should be deleted, i.e. the (NO)WORKTERM option is set,
                         default value 1 means "delete tests work" */
/* documentation options: */
,markdownDoc=0        /* indicates if a markdown file with documentation 
                         be generated from help info blocks */
,easyArch=0           /* when creating documentation file indicates if a copy of 
                         the zip and markdown files with the version number in the 
                         file name be created */
,archLocation=        /* location for package ZIP files and md (optional) archive 
                         when empty takes buildLocation */
)/ secure minoperator
/*** HELP END ***/
des = 'Macro to generate SAS packages, version 20260126. Run %generatePackage() for help info.'
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
    %put ######################################################################################;
    %put ###      This is short help information for the `generatePackage` macro              #;
    %put #------------------------------------------------------------------------------------#;
    %put #                                                                                    #;
    %put # Macro to generate SAS packages, version `20260126`                                 #;
    %put #                                                                                    #;
    %put # A SAS package is a zip file containing a group                                     #;
    %put # of SAS codes (macros, functions, data steps generating                             #;
    %put # data, etc.) wrapped up together and embedded inside the zip.                       #;
    %put #                                                                                    #;
    %put # The `%nrstr(%%generatePackage())` macro generates SAS packages.                             #;
    %put # It wraps-up the package content, i.e. macros, functions, formats, etc.,            #;
    %put # into the zip file and generate all metadata content required by other              #;
    %put # macros from the SAS Packages Framework.                                            #;
    %put #                                                                                    #;
    %put #------------------------------------------------------------------------------------#;
    %put #                                                                                    #;
    %put # Visit: `https://github.com/yabwon/SAS_PACKAGES/tree/main/SPF/Documentation`        #;
    %put # to read about the details of package generation process.                           #;
    %put # Tutorials available at: `https://github.com/yabwon/HoW-SASPackages`                #;
    %put #                                                                                    #;
    %put #### Parameters:                                                                     #;
    %put #                                                                                    #;
    %put # 1. `filesLocation=`      Location of package files, example value:                 #;
    %put #                           `%nrstr(%%sysfunc(pathname(work))/packagename)`.                  #;
    %put #                          Default use case:                                         #;
    %put #                           `%nrstr(%%generatePackage(filesLocation=/path/to/packagename))`   #;
    %put #                          If empty displays this help information.                  #;
    %put #                                                                                    #;
    %put # - `buildLocation=`       Points to a location where the ZIP file with the package  #;
    %put #                          should be generated. If the value is null (default)       #;
    %put #                          the `filesLocation=` value is used.                       #;
    %put #                                                                                    #;
    %put # Testing parameters:                                                                #;
    %put #                                                                                    #;
    %put # - `testPackage=`         Indicator if tests should be executed.                    #;
    %put #                          Default value: `Y`, means "execute tests"                 #;
    %put #                                                                                    #;
    %put # - `packages=`            Location of other packages for testing                    #;
    %put #                          if there are dependencies in loading the package.         #;
    %put #                          Has to be a single directory, if more than one are        #;
    %put #                          provided than only the first is used.                     #;
    %put #                          If path to location contains spaces it should be quoted!  #;
    %put #                                                                                    #;
    %put # - `testResults=`         Location where tests results should be stored,            #;
    %put #                          if null (the default) then the session WORK is used.      #;
    %put #                                                                                    #;
    %put # - `workInTestResults=`   Indicates if WORK directories for test sessions should    #;
    %put #                          be located in the same place as results.                  #;
    %put #                          The default value: `0` means "do not do this".            #;
    %put #                          Available values are `0` and `1`.                         #;
    %put #                                                                                    #;
    %put # - `testWorkPath=`        Points a location where tests sessions work directories   #;
    %put #                          should be stored. By default it is null what means that   #;
    %put #                          a sub-directory of the main SAS session WORK is used.     #;
    %put #                          Takes precedence over `workInTestResults=`.               #;
    %put #                                                                                    #;
    %put # - `sasexe=`              Location of a DIRECTORY where the SAS binary is located,  #;
    %put #                          if null (the default) then the `!SASROOT` is used.        #;
    %put #                                                                                    #;
    %put # - `sascfgFile=`          Location of a FILE with testing session configuration     #;
    %put #                          parameters, if null (the default) then no config file     #;
    %put #                          is pointed during the SAS invocation,                     #;
    %put #                          if set to `DEF` then the `!SASROOT/sasv9.cfg` is used.    #;
    %put #                                                                                    #;
    %put # - `delTestWork=`         Indicates if `WORK` directories generated by user tests   #;
    %put #                          should be deleted, i.e. the (NO)WORKTERM option is set.   #;
    %put #                          The default value: `1` means "delete tests work".         #;
    %put #                          Available values are `0` and `1`.                         #;
    %put #                                                                                    #;
    %put # Documentation parameters:                                                          #;
    %put #                                                                                    #;
    %put # - `markdownDoc=`         Indicates if a markdown file with documentation           #;
    %put #                          be generated from help information blocks.                #;
    %put #                          The default value: `0` means "do not generate the file".  #;
    %put #                          Available values are `0` and `1`.                         #;
    %put #                                                                                    #;
    %put # - `easyArch=`            When creating documentation file (`markdownDoc=1`)        #;
    %put #                          indicates if a copy of the zip and markdown files         #;
    %put #                          with the version number in the file name be created       #;
    %put #                          The default value: `0` means "do not create files".       #;
    %put #                          Available values are `0` and `1`.                         #;
    %put #                                                                                    #;
    %put # - `archLocation=`        Location for versioned package ZIP file (if `easyArch=1`) #;
    %put #                          If empty (default) the `buildLocation` value is used.     #;
    %put #                                                                                    #;
    %put #------------------------------------------------------------------------------------#;
    %put ######################################################################################;
    %put ;
    options &options_tmp.;
    %GOTO ENDofgeneratePackage;
  %end;

%put --- generatePackage START ---;
%local zipReferrence zipReferrenceV filesWithCodes _DESCR_ _LIC_ _DUMMY_ _RC_ _PackageFileref_ additionalContent
       packageHashF packageHashC
;
%let   zipReferrence = _%sysfunc(datetime(), hex6.)_;
%let   zipReferrenceV = _%sysfunc(datetime(), hex6.)V;
%let   filesWithCodes = WORK._%sysfunc(datetime(), hex16.)_;
%let   _DESCR_ = _%sysfunc(datetime(), hex6.)d;
%let   _LIC_   = _%sysfunc(datetime(), hex6.)l;
%let   _DUMMY_ = d%sysfunc(datetime(), hex6.)d;

/* Verify source existence */
%if 0=%sysfunc(FILEEXIST(%superq(filesLocation))) %then
  %do;
    %put ERROR: The %superq(filesLocation) directory does NOT exist!;
    %put ERROR- Aborting.;
    %abort;
  %end;

/* Determine build location for ZIP and MD(optional) */
/* Priority: 1. buildLocation, 2. filesLocation */
/* The buildLocation is used for testing too! */
%if %sysevalf(%superq(buildLocation)=,boolean) %then
  %do;
    %let buildLocation = &filesLocation.;
  %end;
%else
  %do;
    %if 0=%sysfunc(FILEEXIST(%superq(buildLocation))) %then
      %do;
        %put WARNING: The %superq(buildLocation) directory does NOT exist!;
        %put WARNING- ;
        %put WARNING- The %superq(filesLocation) directory will be used.;
        %let buildLocation = &filesLocation.;
      %end;
  %end;
%put NOTE: Build location is: %superq(buildLocation).;

data _null_;
  length path $ 4096;
  do x='filesLocation','buildLocation';
    path = symget(x);
    str = kcompress(path,'({[<_ !@#$%^&*-=+/\?"'';:|~`>]})','pdfs');
    if str NE " " then put "NOTE: There are non-ASCII characters in the " x "path: " str 
                         / "NOTE- If you are working with SAS9.4M7 or earlier it may cause problems.";
  end;
run;

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
    %if (%superq(packageName) = )
     or (%superq(packageVersion) = )
     or (%superq(packageAuthor) = )
     or (%superq(packageMaintainer) = )
     or (%superq(packageTitle) = )
     or (%superq(packageEncoding) = )
     or (%superq(packageLicense) = )
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
            put 'ERROR: Your Required list seems to be problematic.'
              / 'ERROR- Check the description.sas file.'
              / 'ERROR- Expected form is "Quoted" Comma, ..., Separated List, e.g.'
              / 'ERROR- "SAS Component1", "SAS Component2", "SAS Component3"'
              / 'ERROR- Provided value is:';
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
            put 'ERROR: Your ReqPackages list seems to be problematic.'
              / 'ERROR- Check the description.sas file.'
              / 'ERROR- Expected form is "Quoted" Comma, ..., Separated List, e.g.'
              / 'ERROR- "Package1 (X.X)", "Package2 (Y.Y)", "Package3 (Z.Z)"'
              / 'ERROR- Provided value is:';
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
data _null_; 
  call symputX("_PackageFileref_", "P" !! put(MD5(lowcase("&packageName.")), hex7. -L), "L"); 
run;

/* test if version is a number */
data _null_;
  v = "&packageVersion.";
  version = coalesce(input(scan(v,1,".","M"), ?? best32.),0)*1e8
          + coalesce(input(scan(v,2,".","M"), ?? best32.),0)*1e4
          + coalesce(input(scan(v,3,".","M"), ?? best32.),0)*1e0
  ;
  if not (version > 0) then
    do;
      put 'ERROR: Package version should be a positive NUMBER.'
        / 'ERROR- Current value is: ' "&packageVersion."
        / 'ERROR- Try something small, e.g. 0.1'
        / 'ERROR- Aborting.';
      put;
      abort;
    end;
run;

/* create or replace the ZIP file for package  */
filename &zipReferrence. ZIP "&buildLocation./%sysfunc(lowcase(&packageName.)).zip";

%if %sysfunc(fexist(&zipReferrence.)) %then 
  %do;
    %put NOTE: Deleting file "&buildLocation./%sysfunc(lowcase(&packageName.)).zip";
    %let _RC_ = %sysfunc(fdelete(&zipReferrence.));
    %put NOTE: &=_RC_;
  %end;
%if %sysfunc(fexist(&zipReferrence.)) %then 
  %do;
    %put ERROR: File "&buildLocation./%sysfunc(lowcase(&packageName.)).zip" cannot be deleted.;
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

Required: "Base SAS Software"                    :%*optional, COMMA separated, QUOTED list, names of required SAS products, values must be like from "proc setinit" output *;
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
   |          |  (literally with macrovariable name and "format" suffix)]
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
   |                       an asterisk("*") means "load all data"] 
   |
   +-010_imlmodule [one file one IML module,
   |             |  only plain code of the module, without "Proc IML" header]
   |             |
   |             +-abc.sas [a file with a code creating IML module ABC, _without_ "Proc IML" header]
   |
   +-011_casludf [one file one CAS-L user defined function,
   |             |  only plain code of the function, without "Proc CAS" header]
   |             |
   |             +-abc.sas [a file with a code creating CAS-L user defined function ABC, _without_ "Proc CAS" header]
   |
   +-012_kmfsnip [one file one KMF-abbreviation snippet,
   |             |  code snipped proper tagging]
   |             |
   |             +-abc.sas [a file with a KMF-abbreviation snippet ABC, _with_ proper tagging, snippets names are in low-case]
   |
   +-013_ds2pck [one file one PROC DS2 package]
   |             |
   |             +-abc.sas [a data set with a package ABC stored in WORK.ABC data set]
   |             |
   |             +-library.xyz.sas [a data set with a package LIBRARY.XYZ stored in LIBRARY.XYZ data set]
   |
   +-014_ds2thr [one file one PROC DS2 thread]
   |             |
   |             +-abc.sas [a data set with a thread ABC stored in WORK.ABC data set]
   |             |
   |             +-library.xyz.sas [a data set with a thread LIBRARY.XYZ stored in LIBRARY.XYZ data set]
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
  base = "&filesLocation.";  /* location for source */
  build = "&buildLocation."; /* location for ZIP */

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
       'ADDCNT' 'KMFSNIP'
       'DS2PCK' 'DS2THR'
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
                  put 'ERROR: File with code should be named ONLY with low case letters.'
                    / 'ERROR- Current value is: ' file;
                  lowcase_name = lowcase(file);
                  put 'ERROR- Try to use: ' lowcase_name;
                  put;
                  _abort_ + 1;
                end;
          length fileshort $ 256;
          fileshort = substr(file, 1, length(file) - 4); /* filename.sas -> filename */

          if strip(reverse(file)) in: ('sas.') then output; /* ignore not ".sas" files */
          else
            do;
              put "WARNING: Only *.sas files are supported."
                / "WARNING- The file: " file "will be ignored."
                / "WARNING- ";
            end;
        end;
      else
        do;
          file = "additionalcontent";
          fileshort = file;
          additionalContent+1;
          if additionalContent > 1 then
            do;
              put "WARNING: Only ONE directory with additional content is allowed!"
                / "WARNING- Store all additional content in a single directory."
                / "WARNING- The directory: " folder "will be ignored."
                / "WARNING- ";
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

options mprint;
options notes source;

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
          put "WARNING: Number of EXEC type and CLEAN type files differs!"
            / "WARNING- Each EXEC file should have CLEAN file counterpart and vice versa."
            / 'WARNING- Please create appropriate files and make your package a "role model".'
            / 'WARNING- '
            / 'WARNING- The list of differences:';
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
          put "ERROR: There are " e "EXECs files and " c "CLEANs files!"
            / "ERROR- Each EXEC file should have CLEAN file counterpart and vice versa."
            / 'ERROR- Please create appropriate files and make your package a "role model".'
            / 'ERROR: [&sysmacroname.] Aborting package generation!';
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
%local _titleNumber_;
%let _titleNumber_=6;
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
    %let _titleNumber_=%eval(&_titleNumber_.+1);
    title&_titleNumber_. "Required SAS licences: %qsysfunc(compress(%superq(packageRequired),   %str(%'%")))" ;   /* ' */
    %let _titleNumber_=%eval(&_titleNumber_.+1);
    title&_titleNumber_. "Required SAS packages: %qsysfunc(compress(%superq(packageReqPackages),%str(%'%")))" ;   /* " */
  %end;
%if %superq(buildLocation) NE %superq(filesLocation) %then
  %do;
    %let _titleNumber_=%eval(&_titleNumber_.+1);
    title&_titleNumber_. "Package ZIP file location is: &buildLocation.";
  %end;

footnote1 "SAS Packages Framework, version 20260126";

proc print 
  data = &filesWithCodes.(drop=base build folderRef fileRef rc folderid _abort_ fileId additionalContent)
  width=full
;
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
      label width=full
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
      put "  "
        / "Copyright (c) since %sysfunc(today(),year4.) " packageAuthor 
        / "  "
        / "Permission is hereby granted, free of charge, to any person obtaining a copy"
        / 'of this software and associated documentation files (the "Software"), to deal'
        / "in the Software without restriction, including without limitation the rights"
        / "to use, copy, modify, merge, publish, distribute, sublicense, and/or sell"
        / "copies of the Software, and to permit persons to whom the Software is"
        / "furnished to do so, subject to the following conditions:"
        / "  "
        / "The above copyright notice and this permission notice shall be included"
        / "in all copies or substantial portions of the Software."
        / "  "
        / 'THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR'
        / "IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,"
        / "FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE"
        / "AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER"
        / "LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,"
        / "OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE"
        / "SOFTWARE."
        / "  ";
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

  put ' data _null_; ' /* simple "%local" returns error while loading package */
    / '  call symputX("packageName",       ' packageName       ', "L");'
    / '  call symputX("packageVersion",    ' packageVersion    ', "L");'
    / '  call symputX("packageTitle",      ' packageTitle      ', "L");'
    / '  call symputX("packageAuthor",     ' packageAuthor     ', "L");'
    / '  call symputX("packageMaintainer", ' packageMaintainer ', "L");'
    / '  call symputX("packageEncoding",   ' packageEncoding   ', "L");'
    / '  call symputX("packageLicense",    ' packageLicense    ', "L");'
    / '  call symputX("packageGenerated",  ' packageGenerated  ', "L");'
    / ' run; ';

  stop;
run;

/* emergency ICEloadPackage macro to load package when loadPackage() 
   is unavailable for some reasons, example of use:
    1) point to a zip file, 
    2) include iceloadpackage.sas
    3) point to package folder, 
    4) load package
*//*

  filename ice ZIP 'C:/SAS_PACKAGES/sqlinds.zip';
  %include ice(iceloadpackage.sas);
  filename packages 'C:/SAS_PACKAGES/';
  %ICEloadpackage(sqlinds)

 */
%put NOTE-;
%put NOTE: Preparing iceloadpackage file.;
%put NOTE- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^;
%put NOTE-;
data _null_;
  file &zipReferrence.(iceloadpackage.sas) encoding = &packageEncoding.;
  put " "
    / '  /* Temporary replacement of loadPackage() macro. */                      '
    / '  %macro ICEloadPackage(                                                   '
    / '    packageName                         /* name of a package */            '
    / '  , path = %sysfunc(pathname(packages)) /* location of a package */        '
    / '  , options = %str(LOWCASE_MEMNAME)     /* possible options for ZIP */     '
    / '  , zip = zip                           /* file ext. */                    '
    / '  , requiredVersion = .                 /* required version */             '
    / '  , source2 = /* source2 */                                                '
    / '  , suppressExec = 0                    /* suppress execs */               '
    / '  )/secure;                                                                '
    / '    %PUT ** NOTE: Package ' "&packageName." ' loaded in ICE mode **;       '
    / '    %local _PackageFileref_;                                               '
    / '    data _null_;                                                                                 '
    / '     call symputX("_PackageFileref_", "P" !! put(MD5(lowcase("&packageName.")), hex7. -L), "L"); '
    / '    run;                                                                                         '
  
    / '    filename &_PackageFileref_. &ZIP.                                      '
    / '      "&path./%sysfunc(lowcase(&packageName.)).&zip." %unquote(&options.)  '
    / '    ;                                                                      '
    / '    %include &_PackageFileref_.(packagemetadata.sas) / &source2.;          '
    / '    filename &_PackageFileref_. clear;                                     '

           /* test if required version of package is "good enough" */
    / '    %local rV pV rV0 pV0 rVsign;                                           '
    / '    %let pV0 = %sysfunc(compress(&packageVersion.,.,kd));                  '
    / '    %let pV = %sysevalf((%scan(&pV0.,1,.,M)+0)*1e8                         '
    / '                      + (%scan(&pV0.,2,.,M)+0)*1e4                         '
    / '                      + (%scan(&pV0.,3,.,M)+0)*1e0);                       '
    / '                                                                           '
    / '    %let rV0 = %sysfunc(compress(&requiredVersion.,.,kd));                 '
    / '    %let rVsign = %sysfunc(compress(&requiredVersion.,<=>,k));             '
    / '    %if %superq(rVsign)= %then %let rVsign=<=;                             '
    / '    %else %if NOT (%superq(rVsign) IN (%str(=) %str(<=) %str(=<) %str(=>) %str(>=) %str(<) %str(>))) %then '
    / '      %do;                                                                                                 '
    / '        %put WARNING: Illegal operatopr "%superq(rVsign)"! Default(<=) will be used.;                      '
    / '        %put WARNING- Supported operators are: %str(= <= =< => >= < >);                                    '
    / '        %let rVsign=<=;                                                    '
    / '      %end;                                                                '
    / '    %let rV = %sysevalf((%scan(&rV0.,1,.,M)+0)*1e8                         '
    / '                      + (%scan(&rV0.,2,.,M)+0)*1e4                         '
    / '                      + (%scan(&rV0.,3,.,M)+0)*1e0);                       '
    / '                                                                           '
    / '    %if NOT %sysevalf(&rV. &rVsign. &pV.) %then                            '
    / '      %do;                                                                 '
    / '        %put ERROR: Package &packageName. will not be loaded!;             '
    / '        %put ERROR- Required version is &rV0.;                             '
    / '        %put ERROR- Provided version is &pV0.;                             '
    / '        %put ERROR- Condition %bquote((&rV0. &rVsign. &pV0.)) evaluates to %sysevalf(&rV. &rVsign. &pV.);  '
    / '        %put ERROR- Verify installed version of the package.;              '
    / '        %put ERROR- ;                                                      '
    / '        %GOTO WrongVersionOFPackage; /*%RETURN;*/                          '
    / '      %end;                                                                '
    / '    filename &_PackageFileref_. &ZIP.                                      '
    / '      "&path./%sysfunc(lowcase(&packageName.)).&zip." %unquote(&options.)  '
    / '      ENCODING =                                                           '
    / '        %if %superq(packageEncoding) NE %then &packageEncoding. ;          '
    / '                                        %else utf8 ;                       '
    / '    ;                                                                      '
    / '    %local cherryPick; %let cherryPick=*;                                  '
    / '    %local tempLoad_minoperator;                                           '
    / '    %let tempLoad_minoperator = %sysfunc(getoption(minoperator));          '
    / " "
    / '    %if %superq(suppressExec) NE 1 %then %let suppressExec = 0;            '
    / '    %include &_PackageFileref_.(load.sas) / &source2.;                     '
    / '    options &tempLoad_minoperator.;                                        '
    / '    filename &_PackageFileref_. clear;                                     '
    / '    %WrongVersionOFPackage:                                                '
    / '  %mend ICEloadPackage;                                                    '
    / " ";
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
  put '  put "NOTE- "; '
    / '  put "NOTE: *** Cherry Picking ***"; '
    / '  put "NOTE- Cherry Picking in action!! Be advised that"; '
    / '  put "NOTE- dependencies/required packages will not be loaded!"; '
    / '  put "NOTE- "; ';
  put ' end; ' ; /* Cherry Pick test0 end */
  put 'run; ';


  put '%include ' " &_PackageFileref_.(packagemetadata.sas) / nosource2; " /; /* <- copied also to loadPackage macro */
  
  isFunction  = 0;
  isFormat    = 0;
  isProto     = 0;
  isIMLmodule = 0;
  isCASLudf   = 0;
  isDS2pck    = 0;
  isDS2thr    = 0;

  %if (%superq(packageRequired) ne ) 
   or (%superq(packageReqPackages) ne ) 
  %then
    %do;
      put ' data _null_;                                                     '
        / '  call symputX("packageRequiredErrors", 0, "L");                  '
        / ' run;                                                             ';
    %end;

  %if %superq(packageRequired) ne %then
    %do;
      put ' %put NOTE- *Testing required SAS components*%sysfunc(DoSubL(' /* <- DoSubL() is here */
        / ' options nonotes nosource %str(;)                            '
        / ' options ls=max ps=max locale=en_US %str(;)                  '
        / ' /* temporary redirect log */                                '
        / ' filename _stinit_ TEMP %str(;)                              '
        / ' proc printto log = _stinit_ %str(;) run %str(;)             '
        / ' /* print out setinit */                                     '
        / ' proc setinit %str(;) run %str(;)                            '
        / ' proc printto %str(;) run %str(;)                            '
        / ' options ps=min %str(;)                                      '
        / ' data _null_ %str(;)                                         '
        / '   /* loadup checklist of required SAS components */         '
        / '   if _n_ = 1 then                                           '
        / '     do %str(;)                                              '
        / '       length req $ 256 %str(;)                              '
        / '       declare hash R() %str(;)                              '
        / '       _N_ = R.defineKey("req") %str(;)                      '
        / '       _N_ = R.defineDone() %str(;)                          '
        / '       declare hiter iR("R") %str(;)                         ';
        length packageRequired $ 32767; 
        packageRequired = upcase(symget('packageRequired'));
      put '         do req = %bquote(' / packageRequired / ') %str(;)   '
        / '          _N_ = R.add(key:req,data:req) %str(;)              '
        / '         end %str(;)                                         '
        / '     end %str(;)                                             '
        / '                                                             '
        / '   /* read in output from proc setinit */                    '
        / '   infile _stinit_ end=eof %str(;)                           '
        / '   input %str(;)                                             '
    /*  / '   put "*> " _infile_ %str(;)                                ' */ /* for testing */
        / '                                                             '
        / '   /* if component is in setinit remove it from checklist */ '
        / '   if _infile_ =: "---" then                                 '
        / '     do %str(;)                                              '
        / '       req = upcase(substr(_infile_, 4, 64)) %str(;)         '
        / '       if R.find(key:req) = 0 then                           '
        / '         do %str(;)                                          '
        / '           _N_ = R.remove() %str(;)                          '
        / '         end %str(;)                                         '
        / '     end %str(;)                                             '
        / '                                                             '
        / '   /* if checklist is not null rise error */                 '
        / '   if eof and R.num_items > 0 then                           '
        / '     do %str(;)                                              '
        / '       put "WARNING- ###########################################" %str(;) '
        / '       put "WARNING:  The following SAS components are missing! " %str(;) '
        / '       call symputX("packageRequiredErrors", 0, "L") %str(;)              '
        / '       do while(iR.next() = 0) %str(;)                                    '
        / '         put "WARNING-   " req %str(;)                                    '
        / '       end %str(;)                                                        '
        / '       put "WARNING:  The package may NOT WORK as expected      " %str(;) '
        / '       put "WARNING:  or even result with ERRORS!               " %str(;) '
        / '       put "WARNING- ###########################################" %str(;) '
        / '       put %str(;)                                           '
        / '     end %str(;)                                             '
        / ' run %str(;)                                                 '
        / ' filename _stinit_ clear %str(;)                             '
        / ' options notes source %str(;)                                '
        / ' ))*;                                                        ';
    %end;

  %if %superq(packageReqPackages) ne %then
    %do;

      length packageReqPackages $ 32767;
      packageReqPackages = lowcase(symget('packageReqPackages'));
      
      /* try to load required packages */
      put '%let temp_noNotes_etc=%sysfunc(getoption(NOTES));'
        / 'options noNotes;'
        / 'data _null_ ;                                                                                 '
        / ' if "*" NE symget("cherryPick") then do; put "INFO: No required packages loading."; stop; end; '
        / '  length req name $ 64 vers verR $ 24 versN verRN 8 SYSloadedPackages $ 32767;                '
        / '  if SYMEXIST("SYSloadedPackages") = 1 and SYMGLOBL("SYSloadedPackages") = 1 then             '
        / '    do;                                                                                       '
        / '      do until(EOF);                                                                          '
        / '        set sashelp.vmacro(where=(scope="GLOBAL" and name="SYSLOADEDPACKAGES")) end=EOF;      '
        / '        substr(SYSloadedPackages, 1+offset, 200) = value;                                     '
        / '      end;                                                                                    '
        / '    end;                                                                                      '
        / '  SYSloadedPackages = lowcase(SYSloadedPackages);                                             '

        / '  declare hash LP();                                                                          '
        / '  LP.defineKey("name");                                                                       '
        / '  LP.defineData("vers");                                                                      '
        / '  LP.defineDone();                                                                            '
        / '  do _N_ = 1 to countw(SYSloadedPackages);                                                    '
        / '    req = kscanx(SYSloadedPackages, _N_, " ");                                                '
        / '    name = lowcase(strip(kscanx(req, 1, "(")));                                               '
        / '    vers = compress(kscanx(req,-1, "("), ".", "KD");                                          '
        / '    _RC_ = LP.add();                                                                          '
        / '  end;                                                                                        '
      /* check if elements of the framework are available */
        / '       LoadPackageExist = input(resolve(''%SYSMACEXIST(   loadPackage)''), best.);            '
        / '    ICELoadPackageExist = input(resolve(''%SYSMACEXIST(ICEloadPackage)''), best.);            ' 

        / '  do req = ' / packageReqPackages / ' ;                                                       '
/*      / '    req = compress(req, "(.)", "KDF");                                                        '*/
        / '    name = lowcase(strip(kscanx(req, 1, "(")));                                               '
        / '    verR = compress(kscanx(req,-1, "("), ".", "KD"); vers = "";                               '
        / '    LP_find = LP.find();                                                                      '

      /* convert major.minor.patch to number*/
        / '    array V verR vers ;                                                                       '
        / '    array VN verRN versN;                                                                     '
        / '    do over V;                                                                                '
        / '      VN = input("0"!!scan(V,1,".","M"),?? best.)*1e8                                         '
        / '         + input("0"!!scan(V,2,".","M"),?? best.)*1e4                                         '
        / '         + input("0"!!scan(V,3,".","M"),?? best.)*1e0;                                        '
        / '    end;                                                                                      '

        / '    if (LP_find ne 0) or (LP_find = 0 and . < versN < verRN) then                                     '
        / '     do;                                                                                              '
        / '      put "INFO: Trying to load required SAS package: " req;                                          '
        / '       if LoadPackageExist then                                                                       '
        / '         call execute(cats(''%nrstr(%loadPackage('', name, ", requiredVersion = ", verR, "))"));      '
        / '       else if ICELoadPackageExist then                                                               '
        / '         call execute(cats(''%nrstr(%ICEloadPackage('', name, ", requiredVersion = ", verR, "))"));   '
        / '     end ;                                                                                            '
        / '  end ;                                                                                               '
        / ' stop;                                                                                        '
        / 'run;                                                                                          '

      /* test if required packages are loaded */
        / 'data _null_ ;                                                                                 '
        / ' if "*" NE symget("cherryPick") then do; put "INFO: No required packages checking."; stop; end; '
        / '  length req name $ 64 vers verR $ 24 versN verRN 8 SYSloadedPackages $ 32767;                '
        / '  if SYMEXIST("SYSloadedPackages") = 1 and SYMGLOBL("SYSloadedPackages") = 1 then             '
        / '    do;                                                                                       '
        / '      do until(EOF);                                                                          '
        / '        set sashelp.vmacro(where=(scope="GLOBAL" and name="SYSLOADEDPACKAGES")) end=EOF;      '
        / '        substr(SYSloadedPackages, 1+offset, 200) = value;                                     '
        / '      end;                                                                                    '
        / '      SYSloadedPackages = lowcase(SYSloadedPackages);                                         ' 

        / '      declare hash LP();                                                                      '
        / '      LP.defineKey("name");                                                                   '
        / '      LP.defineData("vers");                                                                  '
        / '      LP.defineDone();                                                                        '
        / '      do _N_ = 1 to countw(SYSloadedPackages);                                                '
        / '        req = kscanx(SYSloadedPackages, _N_, " ");                                            '
        / '        name = lowcase(strip(kscanx(req, 1, "(")));                                           '
        / '        vers = compress(kscanx(req,-1, "("), ".", "KD");                                      '
        / '        _RC_ = LP.add();                                                                      '
        / '      end;                                                                                    '

        / '      missingPackagr = 0;                                                                     '
        / '      do req = ' / packageReqPackages / ' ;                                                   '
/*      / '        req = compress(req, "(.)", "KDF");                                                    '*/
        / '        name = lowcase(strip(kscanx(req, 1, "(")));                                           '
        / '        verR = compress(kscanx(req,-1, "("), ".", "KD"); vers = " ";                          '
        / '        LP_find = LP.find();                                                                  '

      /* convert major.minor.patch to number*/
        / '    array V verR vers ;                                                                       '
        / '    array VN verRN versN;                                                                     '
        / '    do over V;                                                                                '
        / '      VN = input("0"!!scan(V,1,".","M"),?? best.)*1e8                                         '
        / '         + input("0"!!scan(V,2,".","M"),?? best.)*1e4                                         '
        / '         + input("0"!!scan(V,3,".","M"),?? best.)*1e0;                                        '
        / '    end;                                                                                      '
        / '        if (LP_find ne 0) or (LP_find = 0 and . < versN < verRN) then                         '
        / '         do;                                                                                  '
        / '          missingPackagr = 1;                                                                 '
        / '          put "ERROR: SAS package: " req "is missing! Download it by hand or if the SAS session";       '
        / '          put "ERROR- has access to the Internet and the package is available at SASPAC repository";    '
        / '          put ''ERROR- use %installPackage('' name +(-1) "(" verR +(-1) ")) to install it."/;           '
        / '          put ''ERROR- Use %loadPackage('' name +(-1) ", requiredVersion=" verR +(-1) ") to load it."/; '
        / '         end ;                                                                                '
        / '      end ;                                                                                   '
        / '      if missingPackagr then call symputX("packageRequiredErrors", 1, "L");                   '
        / '    end;                                                                                      '
        / '  else                                                                                        '
        / '    do;                                                                                       '
        / '      put "ERROR: No package loaded!";                                                        '
        / '      call symputX("packageRequiredErrors", 1, "L");                                          '
        / '      do req = ' / packageReqPackages / ' ;                                                   '
        / '        name = lowcase(strip(kscanx(req, 1, "(")));                                           '
        / '        vers = compress(kscanx(req,-1, "("), ".", "KD");                                      '
        / '        put "ERROR: SAS package " req "is missing! Download it by hand or if the SAS session";       '
        / '        put "ERROR- has access to the Internet and the package is available at SASPAC repository";   '
        / '        put ''ERROR- use %installPackage('' name +(-1) "(" vers +(-1) ")) to install it."/;          '
        / '        put ''ERROR- Use %loadPackage('' name +(-1)", requiredVersion=" vers +(-1) ") to load it."/; '
        / '      end ;                                                                                   '
        / '    end;                                                                                      '
        / '  stop;                                                                                       '
        / 'run;                                                                                          '
        / 'options &temp_noNotes_etc.;';
    %end;

  %if (%superq(packageRequired) ne ) 
     or (%superq(packageReqPackages) ne ) 
  %then
    %do;
      put ' %let temp_noNotes_etc=%sysfunc(getoption(NOTES));'
        / ' options noNotes;'
        / ' data _null_;                                                     '
        / '  if 1 = symgetn("packageRequiredErrors") then                    '
        / '    do;                                                           '
        / '      put "ERROR: Loading package &packageName. will be aborted!";'
        / '      put "ERROR- Required components are missing.";              '
        / '      put "ERROR- *** STOP ***";                                  '
        / '      call symputX("packageRequiredErrors",'
        / '     ''options ls = &ls_tmp. ps = &ps_tmp. '
        / '       &notes_tmp. &source_tmp. msglevel=&msglevel_tmp. '
        / '       &stimer_tmp. &fullstimer_tmp. ;'
        / '       data _null_;abort;run;'', "L");              '
        / '    end;                                            '
        / '  else                                              '
        / '    call symputX("packageRequiredErrors", " ", "L");'
        / ' run;                                               '
        / ' &packageRequiredErrors.                            '
        / ' options &temp_noNotes_etc.;                        ';
    %end;


  do until(eof); /* loopOverTypes - start */

    set &filesWithCodes. end = EOF nobs=NOBS;
    by TYPE notsorted;
    if (upcase(type) in: ('CLEAN' 'LAZYDATA' 'TEST' 'CASLUDF' 'ADDCNT' 'KMFSNIP')) 
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
       'LAZYDATA' 'TEST' 'ADDCNT' 'KMFSNIP' 'DS2PCK' 'DS2THR')) 
    then 
      do;
        putlog 'WARNING: Type ' type 'is not yet supported.';
        continue;
      end;

    isFunction  + (upcase(type)=:'FUNCTION');
    isFormat    + (upcase(type)=:'FORMAT'); 
    isProto     + (upcase(type)=:'PROTO');
    isIMLmodule + (upcase(type)=:'IMLMODULE');
    isDS2pck    + (upcase(type)=:'DS2PCK');
    isDS2thr    + (upcase(type)=:'DS2THR');

    
    /* HEADERS for PROC IML, FCMP, and PROTO - start */
    if 1 = isFunction and upcase(type)=:'FUNCTION' then 
      do;
        /* macro variable for test if cherry picking used FCMP */
        put 'data _null_; '
          / "  call symputX('cherryPick_FCMP', exist('work.&packageName.fcmp'), 'L'); "
          / 'run; ';
      end;
    if 1 = FIRST.type and upcase(type)='FUNCTIONS' then 
      do;
        /* header for multiple functions in one FCMP run */
        put "proc fcmp outlib = work.&packageName.fcmp.package ; ";
      end;
    if 1 = isProto and upcase(type)='PROTO' then 
      do;
        /* macro variable for test if cherry picking used PROTO */
        put 'data _null_; '
          / "  call symputX('cherryPick_PROTO', exist('work.&packageName.proto'), 'L'); "
          / 'run; ';
      end;
    if 1 = FIRST.type and upcase(type)='PROTO' then 
      do;
        protoGrpNum+1; /* number of proto directory to create "packageXX" subgroup to prevent overwrite in case 
                          of multiple proc proto dirs because multiple proc proto executed with the same
                          value of "package=" overwrites previously created content
                        */
        /* header for multiple functions in one PROTO run */
        put "proc proto package = work.&packageName.proto.package" ProtoGrpNum
          / " LABEL='Proc Proto C functions for &packageName. package, part" ProtoGrpNum "' ; ";
      end;
    if 1 = isFormat and upcase(type)=:'FORMAT' then 
      do;
        /* macro variable for test if cherry picking used FORMAT */
        put 'data _null_; '
          / "  call symputX('cherryPick_FORMAT', cexist('work.&packageName.format'), 'L'); "
          / 'run; ';
      end;
    if 1 = FIRST.type and upcase(type)='FORMATS' then 
      do;
        /* header, for FORMATS */
        put "proc format lib = work.&packageName.format ; ";
      end;
    if 1 = isIMLmodule and upcase(type)='IMLMODULE' then 
      do;
        /* macro variable for test if cherry picking used IML */
        put 'data _null_; '
          / '  call symputX("cherryPick_IML_ALL",  0, "L"); '
          / 'run; ';
      end;
    if 1 = FIRST.type and upcase(type)='IMLMODULE' then 
      do;
        /* macro variable for test if cherry picking used IML */
        put 'data _null_; '
          / '  call symputX("cherryPick_IML",      0, "L"); '
          / 'run; ';
        /* header, for IML modules */
        put "proc iml ; ";
      end;
    /* HEADERS for PROC IML, FCMP, and PROTO - end */

    put ' '
      / '%if (%str(*)=%superq(cherryPick)) or (' fileshort +(-1) ' in %superq(cherryPick)) %then %do; ' /* Cherry Pick test1 start */
      / '  %put NOTE- ;'
      / '  %put NOTE: >> Element of type ' type 'from the file "' file +(-1) '" will be included <<;';
    
    if upcase(type)=:'MACRO' then
      put '  %put %sysfunc(ifc(%SYSMACEXIST(' fileshort +(-1) ')=1, NOTE# Macro ' fileshort 
          "exist. It will be overwritten by the macro from the &packageName. package, ));";

         
    /* separate approach for EXEC */
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
    /* separate approach for DS2 */
    else if (upcase(type) in: ('DS2PCK' 'DS2THR')) then
      do;
        if 1 = isDS2pck and upcase(type)=:'DS2PCK' then 
          do;
            /* macro variable for test if cherry picking used DS2 package */
            put 'data _null_;                                 '
              / "  call symputX('cherryPick_DS2PCK', 0, 'L'); "
              / 'run;                                         ';
          end;
        if 1 = isDS2thr and upcase(type)=:'DS2THR' then 
          do;
            /* macro variable for test if cherry picking used DS2 threads */
            put 'data _null_;                                 '
              / "  call symputX('cherryPick_DS2THR', 0, 'L'); "
              / 'run;                                         ';
          end;


        /* since DS2 packages and threads are stored in SAS data sets */
        /* we have to check (before loading) if there is no "regular" */
        /* data set (or view) with the same name to avoid overwriting */
        if upcase(type) in: ('DS2PCK' 'DS2THR') then
          do;
            length DS2lib $ 8 DS2ds $ 32;
            DS2lib = coalescec(scan(fileshort,-2,"."), "WORK");
            DS2ds  = scan(fileshort,-1,".");

          put '%put %sysfunc(ifc(%sysfunc(exist(' fileshort +(-1) '))=1,'  
            / '%sysfunc(dosubl(%str(options ps=min; title; options msglevel=n nodate notes source nomprint;' 
            / '  data _null_;' 
            / '    id = OPEN("' fileshort +(-1) '");' 
            / '    if id then do;' 
            / '      x = VARNUM(id, "SAS_CHECKSUM_") AND VARNUM(id, "SAS_ROWID_") AND (VARNUM(id, "SAS_TEXTTHREAD_") OR VARNUM(id, "SAS_TEXTPACKAGE_"));' 
            / '      y = ("DATA"=ATTRC(id, "MTYPE"));'
            / '      if symexist("DS2force") then z = symgetn("DS2force"); else z = 0;'
            / '      if (x AND y) OR z then do;' 
            / '        call execute("proc delete data=' fileshort +(-1) '; run;");' 
            / "        put 'NOTE# The " fileshort "will be overwritten by the PROC DS2 package/thread from the &packageName. package.';" 

            /*         header for each DS2 packages or threads in PROC DS2 run */
            / '        call execute("proc ds2;");'

            / '        call execute(''%include' " &_PackageFileref_.(_" folder +(-1) "." file +(-1) ') / nosource2;'');'

            /*         footer for each DS2 packages or threads in PROC DS2 run */
            / '        call execute("run; quit;");'
            / '        call execute("options nonotes; proc datasets lib=' DS2lib 'noprint;");'
            / "        call execute('modify " DS2ds "(label=""Package: &packageName. ; Type: " type "; Name: " fileshort """);');"
            / '        call execute("run; quit;");'
            / '      end;'
            / '      else put "WARNING: Data set ' fileshort 'exist and is not a PROC DS2 package/thread!"' 
            / '             / "WARNING- PROC DS2 package/thread ' fileshort 'will not be generated..."; '
            / '      id = CLOSE(id);' 
            / '    end;' 
            / '  run;))),'
            / '%sysfunc(dosubl(%str(options ps=min; title; options msglevel=n nodate notes source nomprint;' 
            /*  header for each DS2 packages or threads in PROC DS2 run */
            / ' proc ds2;'

            / ' %include' " &_PackageFileref_.(_" folder +(-1) "." file +(-1) ') / nosource2;'

            /*  footer for each DS2 packages or threads in PROC DS2 run */
            / ' run; quit;'
            / ' options nonotes; proc datasets lib=' DS2lib 'noprint;'
            / "  modify " DS2ds "(label=""Package: &packageName. ; Type: " type "; Name: " fileshort """);"
            / ' run; quit;'
            / '))),'
            / '));'
            / " " 
            / ; 

          end;

      end;
    else 
      do;
        /* include the file with the code of the element, all other cases */
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

    if upcase(type)=:'DS2PCK' then 
      put '  %let cherryPick_DS2PCK = %eval(&cherryPick_DS2PCK. + 1);';

    if upcase(type)=:'DS2THR' then 
      put '  %let cherryPick_DS2THR = %eval(&cherryPick_DS2THR. + 1);';

    put '%end; ' /; /* Cherry Pick test1 end */


    /* FOOTERS for PROC IML, FCMP, and PROTO - start */
    if 1 = LAST.type and upcase(type) in ('FUNCTIONS' 'PROTO' 'FORMATS') then 
      do; /* footer, for multiple functions in one FCMP run, one PROTO run, or one FORMAT run */
        put "quit; " / ;
      end;
    if 1 = LAST.type and upcase(type)='IMLMODULE' then /* footer, for IML modules */
      do;
        put '%if 0 < &cherryPick_IML. %then %do;    ' 
          / '%let cherryPick_IML_ALL = %eval(&cherryPick_IML_ALL. + &cherryPick_IML.);' 
          / "reset storage = WORK.&packageName.IML; "  /* set the storage location for modules */
          / "store module = _ALL_;                  "  /* and store all created modules */
          / '%end;                                  '  
          / "quit;                                  "  ;
      end;
    /* FOOTERS for PROC IML, FCMP, and PROTO - end */

    /* add the link to the functions dataset, only for the first occurrence */
    /*if 1 = isFunction and (upcase(type)=:'FUNCTION') then
      do;
        put "options APPEND=(cmplib = work.%sysfunc(lowcase(&packageName.fcmp)));"/;
      end;*/
    if 1 = FIRST.type and (upcase(type)=:'FUNCTION') then
      do;
        put '%sysfunc(ifc(0<' 
          / '  %sysfunc(findw((%sysfunc(getoption(cmplib)))' 
          / "                ,work.%sysfunc(lowcase(&packageName.fcmp)),""'( )'"",RIO))" 
          / ',,%str(options' " APPEND=(cmplib = work.%sysfunc(lowcase(&packageName.fcmp)));)" 
          / '))' ;
      end;

    /* add the link to the proto functions dataset, only for the first occurrence */
    /*if 1 = isProto and (upcase(type)=:'PROTO') then
      do;
        put "options APPEND=(cmplib = work.%sysfunc(lowcase(&packageName.proto)));"/;
      end;*/
    if 1 = FIRST.type and (upcase(type)=:'PROTO') then
      do;
        put '%sysfunc(ifc(0<' 
          / '  %sysfunc(findw((%sysfunc(getoption(cmplib)))' 
          / "                ,work.%sysfunc(lowcase(&packageName.proto)),""'( )'"",RIO))" 
          / ',,%str(options' " APPEND=(cmplib = work.%sysfunc(lowcase(&packageName.proto)));)" 
          / '))' ;
      end;

    /* add the link to the formats catalog, only for the first occurrence  */
    /*if 1 = isFormat and (upcase(type)=:'FORMAT') then
      do;
        put "options INSERT=(fmtsearch = work.%sysfunc(lowcase(&packageName.format)));"/;
      end;*/
    if 1 = FIRST.type and (upcase(type)=:'FORMAT') then
      do;
        put '%sysfunc(ifc(0<'
          / '  %sysfunc(findw((%sysfunc(getoption(fmtsearch)))'
          / "                ,work.%sysfunc(lowcase(&packageName.format)),""'( )'"",RIO))"
          / ',,%str(options' " INSERT=(fmtsearch = work.%sysfunc(lowcase(&packageName.format)));)"
          / '))';
      end;


  end; /* loopOverTypes - start */

  /* this is a header for CASLudf macro */
  put 'data _null_;                                   '
    / '  call symputX("cherryPick_CASLUDF",  0, "L"); '
    / 'run;                                           '
    / 'data _null_;                                   '
    / 'length CASLUDF $ 32767;                        '
    / 'dtCASLudf = datetime();                        '
    / 'CASLUDF =                                      '
    / '    ''%macro ' "&packageName.CASLudf('         "
    / ' !! "list=1,depList="                          ';
     
  %if %superq(packageReqPackages) ne %then
    %do;
      length reqPackage $ 32;
      do i = 1 to countw(packageReqPackages, ",", "Q");
        reqPackage = compress(scan(scan(packageReqPackages, i, ",", "Q"), 1, "[{( )}]"),"_","KAD") ;
        put ' !! " ' reqPackage ' " ';
      end;
    %end;
  put " !! ')/ des = ''CASL User Defined Functions loader for &packageName. package'';'";

  put ' !! ''  %if HELP = %superq(list) %then                               ''' 
    / ' !! ''    %do;                                                       ''' 
    / ' !! ''      %put ****************************************************************************;''' 
    / ' !! ''      %put This is help for the `' "&packageName.CASLudf" '` macro;''' 
    / ' !! ''      %put Parameters (optional) are the following:;''' 

    / ' !! ''      %put - `list` indicates if the list of loaded CASL UDFs should be displayed,;''' 
    / ' !! ''      %put %str(  )when set to the value of `1` (the default) runs `FUNCTIONLIST USER%str(;)`,;''' 
    / ' !! ''      %put %str(  )when set to the value of `HELP` (upcase letters!) displays this help message.;''' 

    / ' !! ''      %put - `depList` [technical] contains the list of dependencies required by the package.;''' 
    / ' !! ''      %put %str(  )for _this_ instance of the macro the default value is: `' @;
  %if %superq(packageReqPackages) ne %then
    %do;
      do i = 1 to countw(packageReqPackages, ",", "Q");
        reqPackage = compress(scan(scan(packageReqPackages, i, ",", "Q"), 1, "[{( )}]"),"_","KAD") ;
        put reqPackage @;
      end;
    %end; 
  put +(-1) '`.;''' 
    / ' !! ''      %put The macro generated: '' !! put(dtCASLudf, E8601DT19.-L) !! ";"' 
    / ' !! ''      %put with the SAS Packages Framework version 20260126.;''' 
    / ' !! ''      %put ****************************************************************************;''' 
    / ' !! ''    %GOTO theEndOfTheMacro;''' 
    / ' !! ''    %end;''' ;

  put ' !! ''  %if %superq(depList) ne %then                                '''
    / ' !! ''    %do;                                                       '''
    / ' !! ''      %do i = 1 %to %sysfunc(countw(&depList.,%str( )));       '''
    / ' !! ''        %let depListNm = %scan(&depList.,&i.,%str( ));         '''
    / ' !! ''        %if %SYSMACEXIST(&depListNm.CASLudf) %then             '''
    / ' !! ''          %do;                                                 '''
    / ' !! ''            %&depListNm.CASLudf(list=0)                        '''
    / ' !! ''          %end;                                                '''
    / ' !! ''      %end;                                                    '''
    / ' !! ''    %end;                                                      '''

    / ' !! ''  %local tmp_NOTES;''                           '
    / ' !! ''  %let tmp_NOTES = %sysfunc(getoption(NOTES));''' ;
  /* the PATH macrovariable will be resolved when the load.sas file is executed */
  put ' !! "  filename ' "&_PackageFileref_." ' &ZIP. ''&path./' "%sysfunc(lowcase(&packageName.))" '.&zip.'';"';

  /* this loop lists includes for CASLUDFs in the macro definition */
  do until(eof1); /* loopOverTypes1 - start */
    set &filesWithCodes. end = EOF1;
    by TYPE notsorted;
    if not (upcase(type) = 'CASLUDF') then continue; /* only CASLUDF type in this loop */
    isCASLudf + 1;

    put ' '
      / '%if (%str(*)=%superq(cherryPick)) or (' fileshort +(-1) ' in %superq(cherryPick)) %then %do; ' /* Cherry Pick test2 start */
      / '  %put NOTE- ;'
      / '  %put NOTE: >> Element of type ' type 'from the file "' file +(-1) '" will be included <<;'
    /* for CASLUDF we are building code of a macro to be run while loading */
      / '  !! ''    %include' " &_PackageFileref_.(_" folder +(-1) "." file +(-1) ') / nosource2;'''
      / '  %let cherryPick_CASLUDF = %eval(&cherryPick_CASLUDF. + 1);'
      / '%end; ' / ; /* Cherry Pick test2 end */

  end; /* loopOverTypes1 - end */

  /* this is a footer for CASLudf macro */
  put ' !! "  options nonotes;"                      '
    / " !! '  filename &_PackageFileref_. clear;'    "
    / ' !! ''  options &tmp_NOTES.;''                '
    / ' !! ''   %if 1 = %superq(list) %then ''       '
    / ' !! ''     %do; ''                            '
    / ' !! "       FUNCTIONLIST USER;"               '
    / ' !! "       run;"                             '
    / ' !! ''     %end; ''                           '
    / ' !! ''%theEndOfTheMacro: %mend;'';            ' ;

  /* generate macro for CASL user defined functions */
  if 0 < isCASLudf then
    do;
      put '%if 0 < &cherryPick_CASLUDF. %then %do;      '
    /*  / '  put / / CASLUDF / / ;                      '*/
        / "  rc = resolve(CASLUDF);                     "
        / '  put "NOTE: Macro named:";                  '
        / "  put @7 '%' '&packageName.CASLudf()';       "
        / '  put "NOTE- will be generated. Its purpose";'
        / '  put "NOTE- is to allow fast load of CASL"; '
        / '  put "NOTE- user defined functions into";   '
        / '  put "NOTE- the Proc CAS session.";         '
        / '  put "NOTE-";                               '
        / '  put "NOTE- Use it the following way:";     '
        / "  put @7 'Proc CAS;';                        "
        / "  put @7 '  %' '&packageName.CASLudf()';     "
        / "  put @7 '  <... your code ...>';            "
        / "  put @7 'quit;';                            "
        / '  put "NOTE-";                               '
        / '  put "NOTE-To get help run:";               '
        / "  put @7 '  %' '&packageName.CASLudf(list=HELP)';"
        / '  put "NOTE-";                               '
        / '%end;                                        ';
    end;
  put 'run;'/;

  /* cherry pick clean in cmplib for functions */
  if isFunction then
    do;
      put '%if 0 = &cherryPick_FCMP. %then %do;'
        / 'options cmplib = (%unquote(%sysfunc(tranwrd('
        / '%sysfunc(lowcase(%sysfunc(getoption(cmplib))))'
        / ',%str(' "work.%sysfunc(lowcase(&packageName.fcmp))" '), %str() ))));'
        / 'options cmplib = (%unquote(%sysfunc(compress('
        / '%sysfunc(getoption(cmplib))'
        / ',%str(()) ))));'
        / '%end;';
    end;
  /* cherry pick clean in cmplib for proto */
  if isProto then
    do; 
      put '%if 0 = &cherryPick_PROTO. %then %do;'
        / 'options cmplib = (%unquote(%sysfunc(tranwrd('
        / '%sysfunc(lowcase(%sysfunc(getoption(cmplib))))'
        / ',%str(' "work.%sysfunc(lowcase(&packageName.proto))" '), %str() ))));'
        / 'options cmplib = (%unquote(%sysfunc(compress('
        / '%sysfunc(getoption(cmplib))'
        / ',%str(()) ))));';
      /* proc delete is adde because "empty" PROTO creates dataset too */
      put "proc delete data=work.&packageName.proto; run;"
        / '%end;';
    end;


  /* list fmtsearch for formats */
  if isFormat then
    do;
      put '%if 0 = &cherryPick_FORMAT. %then %do;'
        / 'options fmtsearch = (%unquote(%sysfunc(tranwrd('
        / '%sysfunc(lowcase(%sysfunc(getoption(fmtsearch))))'
        / ',%str(' "work.%sysfunc(lowcase(&packageName.))format" '), %str() ))));'
        / 'options fmtsearch = (%unquote(%sysfunc(compress('
        / '%sysfunc(getoption(fmtsearch))'
        / ', %str(()) ))));'
        / '%end;'
        / '%put NOTE- ;';
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

          '''      %put - `list` indicates if the list of loaded modules should be displayed,;                '' !!' /
          '''      %put %str(  )when set to the value of `1` (the default) runs `SHOW MODULES%str(;)`,;       '' !!' /
          '''      %put %str(  )when set to the value of `HELP` (upcase letters!) displays this help message.;'' !!' /

          '''      %put - `resetIMLstorage` indicates if to reset default modules storage,;                   '' !!' /
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
          '''      %put The macro generated: ''' " !! put(dtIML, E8601DT19.-L) !! " ''';                    '' !! ' / 
          '''      %put with the SAS Packages Framework version 20260126.;                                  '' !! ' / 
          '''      %put ****************************************************************************;       '' !! ' / 
          '''    %GOTO theEndOfTheMacro;                                                                    '' !! ' / 
          '''    %end;                                                                                      '' !! ' / 

          '''  %local localSYSmacroName localPackageName i depListNm;                                       '' !! ' / 
          '''  %let localSYSmacroName = &sysmacroname.;                                                     '' !! ' / 
          '''  %let localSYSmacroName = %sysfunc(lowcase(&localSYSmacroName.));                             '' !! ' / 
          '''  %let localPackageName = %substr(&localSYSmacroName.,1,%eval(%length(&localSYSmacroName.)-3));'' !! ' / 

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

      put '%put NOTE: Macro named:;                          '
        / '%put %nrstr(      %%)' "&packageName." 'IML();    '
        / '%put NOTE- will be generated. Its purpose;        '
        / '%put NOTE- is to allow fast load of IML;          '
        / '%put NOTE- user defined modules into;             '
        / '%put NOTE- the Proc IML session.;                 '
        / '%put NOTE-;                                       '
        / '%put NOTE- Use it the following way:;             '
        / '%put %nrstr(      )Proc IML%str(;);               '
        / '%put %nrstr(        %%)' "&packageName." 'IML();  '
        / '%put %nrstr(        )<... your code ...>;         '
        / '%put %nrstr(      )quit%str(;);                   '
        / '%put NOTE- ;                                      '
        / '%put NOTE- To get help info run:;                 '
        / '%put %nrstr(      %%)' "&packageName." 'IML(list=HELP);'
        / '%put NOTE-;                                       ';

      put '%end;';
    end;

  /* KMF -------------------------------------------------------------------------------- start */
  /*
    The Key Macro Function Abbreviations part of the framework is based on PhUSE 2012 article:

    "Dynamically generating macro invocations using SAS keyboard abbreviations" (Paper CC03)

    by:
      Tom Van Campen, SGS Life Science Services, Mechelen, Belgium
      Benny Haemhouts, SGS Life Science Services, Mechelen, Belgium

    Link to materials:
      https://www.lexjansen.com/phuse/2012/cc/CC03.pdf
  */

  do until(eof2); /* loopOverKMF - start */
    set &filesWithCodes. end = EOF2;
    by TYPE notsorted;
    if not (upcase(type) = 'KMFSNIP') then continue; /* only CASLUDF type in this loop */
    isKMF + 1;
    if 1=isKMF then
      do; 
        put 'data _null_;                               '
          / '  call symputX("cherryPick_KMF", 0, "L");  '
          / 'run;                                       '
          / "data work.&packageName.kmf;                "
          / "length member $ 128; call missing(member); "
          / "if 0 then output;                          ";
      end;

    put ' '
      / '%if (%str(*)=%superq(cherryPick)) or (' fileshort +(-1) ' in %superq(cherryPick)) %then %do; ' /* Cherry Pick KMF start */
      / '  %put NOTE- ;'
      / '  %put NOTE: >> Element of type ' type 'from the file "' file +(-1) '" will be included <<;'
      / '  member = "_' folder +(-1) "." file +(-1) '"; output;'
      / '  %let cherryPick_KMF = %eval(&cherryPick_KMF. + 1);'
      / '%end; ' /; /* Cherry Pick KMF end */
  end; /* loopOverKMF - end */
  put 'data _null_;';
  put 'run;';

  if isKMF then
    do;
      put '%let temp_noNotes_etc=%sysfunc(getoption(NOTES));'
        / 'options noNotes;';
      put '%if &cherryPick_KMF. %then %do;';
      put 'filename __KMFgen temp;'
        / 'data _null_;'
        / "  set work.&packageName.kmf nobs=nobs;"

        / '  call symputX("numberKMF",nobs,"L");'
        / '  file __KMFgen;'

        / '  length _KMF_name_$ 130;'
        / '  _KMF_name_ = quote(scan(member,-2,"."));'

        / "  put 'end=0; append=0; i+1;'" 
        / "    / '_KMF_name_[i]=' _KMF_name_ ';'"
        / "    / 'do until(end);'"
        / "    / ' infile &_PackageFileref_.(' member +(-1) ') end=end;'"
        / "    / ' input codeLine $char2048. @;'"
        / "    / ' if upcase(codeLine) =: ""KMFCODEDESC:"" then'"
        / "    / '   _KMF_desc_[i] = strip(substr(codeLine,13));'"

        / "    / ' if upcase(codeLine) =: ""KMFCODEEND:"" then append=0;'"
        / "    / ' if append then'"
        / "    / '   do;'"
        / "    / '     if lengthn(codeLine) then'"
        / "    / '       _KMF_code_[i] = trim(_KMF_code_[i]) !! trim(codeLine) !! CrNl;'"
        / "    / '     else _KMF_code_[i] = trim(_KMF_code_[i]) !! CrNl;'"
        / "    / '     _KMF_NoLi_[i]+1;'"
        / "    / '   end;'"
        / "    / ' if upcase(codeLine) =: ""KMFCODESTART:"" then append=1;'"
        / "    / 'end;'"
        / "    / '_KMF_code_[i]=substr(_KMF_code_[i],1,lengthn(_KMF_code_[i])-1);'"
        / "    ;"
        / "run;"
        ;

      put 'data _nulL_;'
        / '  file "%sysfunc(pathname(WORK))/%sysfunc(lowcase(&packageName..kmf))" termstr=NL lrecl=32767;'
        / '  putlog "INFO: The &packageName. package provides KMF-abbreviations."; '
        / '  putlog   @7 "By default the file with abbreviations is located in:";'
        / '  putlog / @9 "%sysfunc(pathname(WORK))/%sysfunc(lowcase(&packageName..kmf))";'
        / '  putlog / @7 "To import code abbreviations to your SAS session:";'
        / '  putlog   @7 "- in SAS DMS go to: Tools -> Keyboard Macros -> Macros... -> Import... ";'
        / '  putlog   @7 "- in SAS EG go to: Program -> Manage Macros and Snippets -> Import... ";'
        / '  putlog   @7 "and navigate to the location of the KMF file.";'

        / '  putlog / @7 "Should you have any problem with finding the file consider moving";'
        / '  putlog   @7 "it to a location of your choice with the help of the following snippet:";'
        / '  putlog / @7 "  filename KMFin " "''%sysfunc(pathname(WORK))/%sysfunc(lowcase(&packageName..kmf))''" " lrecl=1 recfm=n;";'
        / '  putlog / @7 "  filename KMFout " "''</directory/of/your/choice>/%sysfunc(lowcase(&packageName..kmf))''" " lrecl=1 recfm=n;";'
        / '  putlog   @7 ''  %put *%sysfunc(fcopy(KMFin, KMFout))*(0=success)*;'';'
        / '  putlog / "0a"x / " ";'


        / '  array _KMF_name_[&numberKMF.] $ 128;'
        / '  array _KMF_desc_[&numberKMF.] $ 256;'
        / '  array _KMF_seqn_[&numberKMF.] (1:&numberKMF.);'
        / '  array _KMF_code_[&numberKMF.] $ 32767;'
        / '  array _KMF_NoLi_[&numberKMF.] ;'
        / '  array _KMF_Byte_[&numberKMF.] $ 7;'

        / '  noDef = symgetn("numberKMF");'
        / '  tmpByteD2 = floor(noDef/256);'
        / '  tmpByteD1 = noDef - (tmpByteD2*256);'
        / '  noDefByte = "KM" !! byte(0) !! byte(2) !! byte(tmpByteD1) !! byte(tmpByteD2) !! byte(0) !! byte(0);'

        / '  CrNl=byte(13)!!byte(10);'

        / '  %include __KMFgen / &source2.;'

        / '  do i = 1 to &numberKMF.;'
        / '    X1=lengthn(trim(_KMF_code_[i]));'
        / '    X2=lengthn(strip(_KMF_name_[i]));'
        / '    X3=lengthn(strip(_KMF_desc_[i]));'
        / '    X4=lengthn(put(_KMF_seqn_[i], best3.-l));'
        / '    X5=lengthn(put(_KMF_NoLi_[i], best12.-l));'
        / '    noChar = sum(X1, X2, X3, X4, X5, 20);'
        / '    tmpByteC2 = floor(noChar/256);'
        / '    tmpByteC1 = noChar - (tmpByteC2*256);'

        / '    _KMF_Byte_[i] = byte(tmpByteC1) !! byte(tmpByteC2) !! byte(0) !! byte(0) !! "252";'
        / '  end;'

        / '  do i = 1 to &numberKMF.;'
        / '    if i=1 then put noDefByte +(-1) @@;'
        / '    /* 1*/ put _KMF_Byte_[i];'
        / '    /* 2*/ put "3";'
        / '    /* 3*/ put _KMF_name_[i];'
        / '    /* 4*/ if lengthn(_KMF_desc_[i]) then put _KMF_desc_[i]; else put;'
        / '    /* 5*/ put "1"'
        / '    /* 6*/   / "332"'
        / '    /* 7*/   / "1";'
        / '    /* 8*/ put _KMF_NoLi_[i];'
        / '    /* 8*/ put _KMF_code_[i];'
        / '    /*10*/ put _KMF_seqn_[i];'
        / '    /*11*/ put "1";'
        / '    ;'
        / '  end;'
        / 'stop;'
        / 'run;'
        / '%symdel numberKMF / noWarn;'
        / 'filename __KMFgen clear;'
        ;
      put '%end;';
      put "proc delete data=work.&packageName.kmf; run;";
      put 'options &temp_noNotes_etc.;';
    end;
  put 'data _null_;';
  put 'run;';
  /* KMF -------------------------------------------------------------------------------- end */

  /*=add meta function========================================================================*/
    isFunction+1;

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
    /* add quotes to hide special characters */
    %if (%superq(packageReqPackages) ne ) %then /* required packages list */
      %do;
        packageReqPackages = quote(strip(packageReqPackages)); 
      %end;
    %if (%superq(packageRequired) ne ) %then /* required SAS products */
      %do;
        packageRequired = quote(strip(packageRequired));
      %end;

    put "proc fcmp outlib = work.&packageName.fcmp.packagemeta ; "
      / " function &packageName.META(meta $) $ 32767;"
      / '  m = char(upcase(meta),1);'
      / "   if m = 'V' then return(strip(" packageVersion    +(-1) "));"
      / "   if m = 'D' then return(strip(" packageGenerated  +(-1) "));"
      / "   if m = 'A' then return(strip(" packageAuthor     +(-1) "));"
      / "   if m = 'M' then return(strip(" packageMaintainer +(-1) "));"
      / "   if m = 'T' then return(strip(" packageTitle      +(-1) "));"
      / "   if m = 'E' then return(strip(" packageEncoding   +(-1) "));"
      / "   if m = 'L' then return(strip(" packageGenerated  +(-1) "));"
      %if (%superq(packageReqPackages) ne ) %then /* required packages list */
        %do;
          / "   if m = 'P' then return(strip(" packageReqPackages +(-1) "));" 
        %end;
      %if (%superq(packageRequired) ne ) %then /* required SAS products */
        %do;
          / "   if m = 'S' then return(strip(" packageRequired +(-1) "));" 
        %end;
      / '  return(" ");'
      / ' endfunc;'
      / 'quit;';

    put '%sysfunc(ifc(0<' 
      / '  %sysfunc(findw((%sysfunc(getoption(cmplib)))' 
      / "                ,work.%sysfunc(lowcase(&packageName.fcmp)),""'( )'"",RIO))" 
      / ',,%str(options' " APPEND=(cmplib = work.%sysfunc(lowcase(&packageName.fcmp)));)" 
      / '))' ;

    put '%macro ' "&packageName.META(meta)/parmbuff;" /* returned values are quoted to mask special chars*/
      / '%if %superq(meta) = %then %return;'
      / '%do;%qsysfunc(strip(%qsysfunc(' "&packageName.META" '&syspbuff.)))%end;'
      / '%mend;' / /;

  /*==========================================================================================*/

  /* list cmplib for functions and fmtsearch for formats*/
  if isFunction OR isProto then
    do;      
      put '%put NOTE- ;';
      put '%put NOTE:[CMPLIB] %sysfunc(getoption(cmplib));' /;
    end;
  if isFormat then
    do;
      put '%put NOTE- ;';
      put '%put NOTE:[FMTSEARCH] %sysfunc(getoption(fmtsearch));' /;
    end;

  /* update SYSloadedPackages global macrovariable */

  put '%if (%str(*)=%superq(cherryPick)) %then %do; ' /* Cherry Pick test3 start */
    / ' %let temp_noNotes_etc=%sysfunc(getoption(NOTES));'
    / ' options noNotes;'
    / ' data _null_ ;                                                                                              '
    / '  length SYSloadedPackages stringPCKG $ 32767;                                                              '
    / '  if SYMEXIST("SYSloadedPackages") = 1 and SYMGLOBL("SYSloadedPackages") = 1 then                           '
    / '    do;                                                                                                     '
    / '      do until(EOF);                                                                                        '
    / '        set sashelp.vmacro(where=(scope="GLOBAL" and name="SYSLOADEDPACKAGES")) end=EOF;                    '
    / '        substr(SYSloadedPackages, 1+offset, 200) = value;                                                   '
    / '      end;                                                                                                  '
    / '      SYSloadedPackages = cats("#", translate(strip(SYSloadedPackages), "#", " "), "#");                    '

    / "      indexPCKG = INDEX(lowcase(SYSloadedPackages), '#%sysfunc(lowcase(&packageName.))(');                  "
    / "      if indexPCKG = 0 then                                                                                 "
    / '         do;                                                                                                '
    / "          SYSloadedPackages = catx('#', SYSloadedPackages, '&packageName.(&packageVersion.)');              "
    / '          SYSloadedPackages = compbl(translate(SYSloadedPackages, " ", "#"));                               '
    / '          call symputX("SYSloadedPackages", SYSloadedPackages, "G");                                        '
    / '          put / "INFO: [SYSLOADEDPACKAGES] " SYSloadedPackages ;                                             '
    / '         end ;                                                                                              '
    / "      else                                                                                                  "
    / '         do;                                                                                                '
    / "          stringPCKG = kscanx(substr(SYSloadedPackages, indexPCKG+1), 1, '#');                              "
    / '          SYSloadedPackages = compbl(tranwrd(SYSloadedPackages, strip(stringPCKG), "#"));                   '
    / "          SYSloadedPackages = catx('#', SYSloadedPackages, '&packageName.(&packageVersion.)');              "
    / '          SYSloadedPackages = compbl(translate(SYSloadedPackages, " ", "#"));                               '
    / '          call symputX("SYSloadedPackages", SYSloadedPackages, "G");                                        '
    / '          put / "INFO: [SYSLOADEDPACKAGES] " SYSloadedPackages ;                                             '
    / '         end ;                                                                                              '
    / '    end;                                                                                                    '
    / '  else                                                                                                      '
    / '    do;                                                                                                     '
    / "      call symputX('SYSloadedPackages', '&packageName.(&packageVersion.)', 'G');                            "
    / "      put / 'INFO: [SYSLOADEDPACKAGES] &packageName.(&packageVersion.)';                                     "
    / '    end;                                                                                                    '
    / '  stop;                                                                                                     '
    / ' run;                                                                                                       '
    / ' options &temp_noNotes_etc.;'
    / '%end; ' / ; /* Cherry Pick test3 end */

  put 'options NOTES;'
    / '%put NOTE- ;'
    / '%put NOTE: '"Loading package &packageName., version "'%'"&packageName.META(V), license &packageLicense.;"
    / '%put NOTE- *** END ***;' /;
  
  put 'options &temp_noNotes_etc.;'
    / '%symdel temp_noNotes_etc / noWarn;';
  
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
 
  put "filename &_PackageFileref_. list;"
    / ' %put NOTE- ;'
    / ' %put NOTE: ' @; put "Data for package &packageName., version &packageVersion., license &packageLicense.; ";

  put ' %put NOTE: ' @; put '*** %superq(packageTitle) ***; ';
  put ' %put NOTE- ' @; put "Generated: &packageGenerated.; ";
  put ' %put NOTE- ' @; put 'Author(s): %superq(packageAuthor); ';
  put ' %put NOTE- ' @; put 'Maintainer(s): %superq(packageMaintainer); ';
  put ' %put NOTE- ;';
  put ' %put NOTE- Write %nrstr(%%)helpPackage(' "&packageName." ') for the description;';
  put ' %put NOTE- ;';
  put ' %put NOTE- *** START ***; ' /;
  
  /*put '%include ' " &_PackageFileref_.(packagemetadata.sas) / nosource2; " /;*/ /* <- copied also to loadPackage macro */

  put 'data _null_;'
    / ' length lazyData $ 32767; lazyData = lowcase(symget("lazyData"));';
  do until(eof);
    set &filesWithCodes. end = EOF nobs=NOBS;
    
    if ( upcase(type) =: 'LAZYDATA' ) then
      do;
        put 'if lazyData="*" OR findw(lazyData, "' fileshort +(-1) '") then'
          / 'do;'
          / ' put "NOTE- Dataset ' fileshort 'from the file ""' file +(-1) '"" will be loaded";'
          / ' call execute(''%nrstr(%include' " &_PackageFileref_.(_" folder +(-1) "." file +(-1) ') / nosource2;)'');'
          / 'end;' ;
      end;
    /* use lazyData to reload data type */
    if ( upcase(type) =: 'DATA' ) then
      do;
        put 'if findw(lazyData, "' fileshort +(-1) '") then'
          / 'do;'
          / ' put "NOTE- Dataset ' fileshort 'from the file ""' file +(-1) '"" will be loaded";'
          / ' call execute(''%nrstr(%include' " &_PackageFileref_.(_" folder +(-1) "." file +(-1) ') / nosource2;)'');'
          / 'end;' ;
      end;
  end;

  put 'run;';

  put '%put NOTE- ;'
    / '%put NOTE: '"Data for package &packageName., version &packageVersion., license &packageLicense.;"
    / '%put NOTE- *** END ***;'
    / "/* lazydata.sas end */" ;
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

  put "filename &_PackageFileref_. list;"
    / '%put NOTE: '"Unloading package &packageName., version &packageVersion., license &packageLicense.;"
    / '%put NOTE- *** START ***;';

  /* include "cleaning" files */
  EOF = 0;
  do until(EOF);
    set &filesWithCodes. end = EOF nobs = NOBS;
    if not (upcase(type)=:'CLEAN') then continue;
    put '%put NOTE- Code of type ' type 'generated from the file "' file +(-1) '" will be executed;'
      / '%put NOTE- ;'
      / '%put NOTE- Executing the following code: ;'
      / '%put NOTE- *****************************;'
      / 'data _null_;'
      / "  infile &_PackageFileref_.(_" folder +(-1) "." file +(-1) ') lrecl=32767;'
      / '  input;'
      / '  putlog "*> " _infile_;'
      / 'run;'
      / '%put NOTE- *****************************;'
      / '%put NOTE- ;';

    put '%include' " &_PackageFileref_.(_" folder +(-1) "." file +(-1) ') / nosource2;' /;
  end;

  /* delete macros and formats */
  put 'proc sql;'
    / '  create table WORK._%sysfunc(datetime(), hex16.)_ as'
    / '  select memname, objname, objtype'
    / '  from dictionary.catalogs'
    / '  where '
    / '  ('
    / '   objname in ("*"'
    / "   ,%UPCASE('&packageName.META')" 
    / "   ,%UPCASE('&packageName.IML')" 
    / "   ,%UPCASE('&packageName.CASLUDF')";
  /* list of macros */
  EOF = 0;
  do until(EOF);
    set &filesWithCodes. end = EOF nobs = NOBS;
    if not (upcase(type)=:'MACRO') then continue;
    put '   %put NOTE- Element of type ' type 'generated from the file "' file +(-1) '" will be deleted;'
      / '   %put NOTE- ;'
      / '   ,"' fileshort upcase64. '"';
  end;
  /**/
  put '  )'
    / '  and objtype = "MACRO"'
    / '  and libname  = "WORK"'
    / '  )'
    / '  or'
    / '  ('
    / '   objname in ("*"';
  /* list of formats */
  isFormat = 0;
  EOF = 0;
  do until(EOF);
    set &filesWithCodes. end = EOF;
    if not (upcase(type)=:'FORMAT') then continue;
    put '   %put NOTE- Element of type ' type 'generated from the file "' file +(-1) '" will be deleted;'
      / '   %put NOTE- ;'
      / '   ,"' fileshort upcase64. '"';
    isFormat + 1;
  end;
  put '  )'
    / '  and objtype in ("FORMAT" "FORMATC" "INFMT" "INFMTC")'
    / '  and libname  = "WORK"'
    / "  and memname = '%upcase(&packageName.format)'"
    / '  )'
    / '  order by objtype, memname, objname'
    / '  ;'
    / 'quit;'
    / 'data _null_;'
    / '  do until(last.memname);'
    / '    set WORK._last_;'
    / '    by objtype memname;'
    / '    if first.memname then call execute("proc catalog cat = work." !! strip(memname) !! " force;");'
    / '    call execute("delete " !! strip(objname) !! " /  et =" !! objtype !! "; run;");'
    / '  end;'
    / '  call execute("quit;");'
    / 'run;'
    / 'proc delete data = WORK._last_;'
    / 'run;';

  /* delete the link to the formats catalog */
  if isFormat then
    do;
      put "proc delete data = work.&packageName.format(mtype = catalog);"
        / 'run;'
        / 'options fmtsearch = (%unquote(%sysfunc(tranwrd('
        / '%sysfunc(lowcase(%sysfunc(getoption(fmtsearch))))'
        / ',%str(' "work.%sysfunc(lowcase(&packageName.))format" '), %str() ))));'
        / 'options fmtsearch = (%unquote(%sysfunc(compress('
        / '%sysfunc(getoption(fmtsearch))'
        / ', %str(()) ))));'
        / '%put NOTE:[FMTSEARCH] %sysfunc(getoption(fmtsearch));';
    end;

  /* delete proto functions */
  isProto = 0;
  EOF = 0;
  do until(EOF);
    set &filesWithCodes. end = EOF;
    if not (upcase(type)=:'PROTO') then continue;
    put '%put NOTE- Element of type ' type 'generated from the file "' file +(-1) '" will be deleted;'
      / '%put NOTE- ;' /;
    isProto + 1;
  end;
  /* delete the link to the proto functions dataset */
  if isProto then
    do;
      put "proc delete data = work.&packageName.proto;"
        / "run;"
        / 'options cmplib = (%unquote(%sysfunc(tranwrd('
        / '%sysfunc(lowcase(%sysfunc(getoption(cmplib))))'
        / ',%str(' "work.%sysfunc(lowcase(&packageName.proto))" '), %str() ))));'
        / 'options cmplib = (%unquote(%sysfunc(compress('
        / '%sysfunc(getoption(cmplib))'
        / ',%str(()) ))));'
        / '%put; %put NOTE:[CMPLIB] %sysfunc(getoption(cmplib));';
    end;


  /* delete functions */
  put "proc fcmp outlib = work.&packageName.fcmp.package;";
  isFunction = 0;
  EOF = 0;
  do until(EOF);
    set &filesWithCodes. end = EOF;
    if not (upcase(type)=:'FUNCTION') then continue;
    put '%put NOTE- Element of type ' type 'generated from the file "' file +(-1) '" will be deleted;'
      / '%put NOTE- ;'
      / 'deletefunc ' fileshort ';';
    isFunction + 1;
  end;
  put "quit;" /;

  put "proc fcmp outlib = work.&packageName.fcmp.packagemeta;"
    / "deletefunc &packageName.META;"
    / "quit;" /;
  isFunction + 1;

  /* delete the link to the functions dataset */
  if isFunction then
    do;
      put 'options cmplib = (%unquote(%sysfunc(tranwrd('
        / '%sysfunc(lowcase(%sysfunc(getoption(cmplib))))'
        / ',%str(' "work.%sysfunc(lowcase(&packageName.fcmp))" '), %str() ))));'
        / 'options cmplib = (%unquote(%sysfunc(compress('
        / '%sysfunc(getoption(cmplib))'
        / ',%str(()) ))));'
        / '%put; %put NOTE:[CMPLIB] %sysfunc(getoption(cmplib));';
    end;
  
  /* delete IML modules */
  EOF = 0; first.IML = 1;
  do until(EOF);
    set &filesWithCodes. end = EOF;
    if not (upcase(type)=:'IMLMODULE') then continue;
    if first.iml then
      do;
        put "proc delete lib=WORK data=&packageName.IML (memtype=catalog); "
          / "run; ";
        first.IML = 0;
      end;
    put '%put NOTE- Element of type ' type 'generated from the file "' file +(-1) '" will be deleted;'
      / '%put NOTE- ;' /;
    /* put 'remove module = ' fileshort ';'; */
  end;
 
  /* delete data sets */
  put "proc SQL noprint;";
  EOF = 0;
  do until(EOF);
    set &filesWithCodes. end = EOF;
    if not (upcase(type) in: ('DATA')) then continue;
    put '%put NOTE- Element of type ' type 'generated from the file "' file +(-1) '" will be deleted;'
      / '%put NOTE- ;'
      / '%sysfunc(ifc(%sysfunc(exist(' fileshort ')),drop table ' fileshort ',));';
  end;
  put "quit;" /;

  /* delete PROC DS2 packages or threads */
  put 'data _null_; call symputx("_DS2_2_del_",0,"L"); run;';
  put "proc SQL noprint;";
  EOF = 0;
  do until(EOF);
    set &filesWithCodes. end = EOF;
    if not (upcase(type) in: ('DS2PCK' 'DS2THR')) then continue;
    put '%put NOTE- Element of type ' type 'generated from the file "' file +(-1) '" will be deleted;'
      / '%put NOTE- ;'
      / '%let _DS2_2_del_ = %sysfunc(open(' fileshort '));'
      / '%sysfunc(ifc(&_DS2_2_del_. AND %sysfunc(ATTRC(&_DS2_2_del_.,LABEL))='
      / '%str(' "Package: &packageName. ; Type: " type "; Name: " fileshort +(-1) '),drop table ' fileshort ',)) '
      / '%let _DS2_2_del_ = %sysfunc(close(&_DS2_2_del_.));'
      ;
    put ';' /; /* this is semicolon closing drop table statement */
  end;
  put "quit;" /;

  /* delete libraries */
  EOF = 0;
  do until(EOF);
    set &filesWithCodes. end = EOF;
    if not (upcase(type)=:'LIBNAME') then continue; 
    put '%put NOTE- Element of type ' type 'generated from the file "' file +(-1) '" will be cleared;'
      / '%put NOTE- ;'
      / 'libname ' fileshort ' clear;';
  end;
  put "run;" /;

  %if %bquote(&packageReqPackages.) ne %then
    %do;
      length packageReqPackages $ 32767;
      packageReqPackages = lowcase(symget('packageReqPackages'));
      /* note to unload required packages */
      put 'data _null_ ;                                                                              '
        / '  length req name $ 64;                                                                    '
        / '  put "NOTE-" / "NOTE: To unload additional required SAS packages execute: " / "NOTE-";    '
        / '  do req = ' / packageReqPackages / ' ;                                                    '
        / '    name = strip(kscanx(req, 1, "("));                                                     '
        / '    put ''      %unloadPackage( '' name ")" ;                                              '
        / '  end ;                                                                                    '
        / ' put "NOTE-" / "NOTE-"; stop;                                                              '
        / 'run;                                                                                       ';
    %end;


  /* update SYSloadedPackages global macrovariable */
  put 'data _null_ ;                                                                                         '
    / '  length SYSloadedPackages $ 32767;                                                                   '
    / '  if SYMEXIST("SYSloadedPackages") = 1 and SYMGLOBL("SYSloadedPackages") = 1 then                     '
    / '    do;                                                                                               '
    / '      do until(EOF);                                                                                  '
    / '        set sashelp.vmacro(where=(scope="GLOBAL" and name="SYSLOADEDPACKAGES")) end=EOF;              '
    / '        substr(SYSloadedPackages, 1+offset, 200) = value;                                             '
    / '      end;                                                                                            '
    / '      SYSloadedPackages = cats("#", translate(strip(SYSloadedPackages), "#", " "), "#");              '

    / "      if INDEX(lowcase(SYSloadedPackages),'#%sysfunc(lowcase(&packageName.(&packageVersion.)))#')>0 then "
    / '         do;                                                                                          '
    / "          SYSloadedPackages = tranwrd(SYSloadedPackages, '#&packageName.(&packageVersion.)#', '##');  "
    / '          SYSloadedPackages = compbl(translate(SYSloadedPackages, " ", "#"));                         '
    / '          call symputX("SYSloadedPackages", SYSloadedPackages, "G");                                  '
    / '          put "NOTE: " SYSloadedPackages = ;                                                          '
    / '         end ;                                                                                        '
    / '    end;                                                                                              '
    / '  stop;                                                                                               '
    / 'run;                                                                                                  '
 
    / '%put NOTE: ' "Unloading package &packageName., version &packageVersion., license &packageLicense.;"
    / '%put NOTE- *** END ***;'
    / '%put NOTE- ;'
 
    / "/* unload.sas end */";
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

  put "filename &_PackageFileref_. list;"
    / ' %put NOTE- ;'
    / ' %put NOTE: '"Preview of the &packageName. package, version &packageVersion., license &packageLicense.;"

    / ' %put NOTE: ' @; put '*** %superq(packageTitle) ***; '
    / ' %put NOTE- ' @; put "Generated: &packageGenerated.; "
    / ' %put NOTE- ' @; put 'Author(s): %superq(packageAuthor); '
    / ' %put NOTE- ' @; put 'Maintainer(s): %superq(packageMaintainer); '
    / ' %put NOTE- ;'
    / ' %put NOTE- *** START ***;';
  
  /* Use helpKeyword macrovariable to search for content (filename and type) */
  /* put '%local ls_tmp ps_tmp notes_tmp source_tmp;                       ';*/
  put '%let ls_tmp     = %sysfunc(getoption(ls));         '
    / '%let ps_tmp     = %sysfunc(getoption(ps));         '
    / '%let notes_tmp  = %sysfunc(getoption(notes));      '
    / '%let source_tmp = %sysfunc(getoption(source));     '
    / 'options ls = MAX ps = MAX nonotes nosource;        '
    / '%include' " &_PackageFileref_.(packagemetadata.sas) / nosource2; "

    / 'data _null_;                                                 '
    / '  if strip(symget("helpKeyword")) = " " then                 '
    / '    do until (EOF);                                          '
    / "      infile &_PackageFileref_.(description.sas) end = EOF;  "
    / '      input;                                                 '
    / '      put _infile_;                                          '
    / '    end;                                                     '
    / '  else stop;                                                 '
    / 'run;                                                         '

    / 'data WORK._%sysfunc(datetime(), hex16.)_;                      '
    / 'infile cards4 dlm = "/";                                       '
    / 'input @;                                                       '
    / 'if 0 then output;                                              '
    / 'length helpKeyword $ 64;                                       '
    / 'retain helpKeyword "*";                                        '
    / 'drop helpKeyword;                                              '
    / 'if _N_ = 1 then helpKeyword = strip(symget("helpKeyword"));    '
    / 'if FIND(_INFILE_, helpKeyword, "it") or helpKeyword = "*" then ' 
    / ' do;                                                           '
    / '   input (folder order type file fileshort) (: $ 256.);        '
    / '   output;                                                     '
    / ' end;                                                          '
    / 'cards4;                                                        ';

  EOFDS = 0;
  do until(EOFDS);
    /* content is created during package creation */
    set &filesWithCodes. end = EOFDS nobs = NOBS;
    if upcase(type) in: ('TEST') then continue; /* exclude tests */

    length fileshort2 $ 256;
    select;
      when (upcase(type) in ("DATA" "LAZYDATA")) fileshort2 = cats("'",   fileshort, "'"   );
      when (upcase(type) =:  "MACRO"           ) fileshort2 = cats('''%', fileshort, "()'" );
      when (upcase(type) =:  "FUNCTION"        ) fileshort2 = cats("'",   fileshort, "()'" );
      when (upcase(type) =:  "IMLMODULE"       ) fileshort2 = cats("'",   fileshort, "()'" );
      when (upcase(type) =:  "PROTO"           ) fileshort2 = cats("'",   fileshort, "()'" );
      when (upcase(type) =:  "FORMAT"          ) fileshort2 = cats("'$",  fileshort, ".'"  );
      when (upcase(type) in ('DS2PCK' 'DS2THR')) fileshort2 = cats("'DS2",  fileshort, "'" );
      otherwise fileshort2 = fileshort;
    end;
    strX = catx('/', folder, order, type, file, fileshort, fileshort2);
    put strX;
  end;

  put ";;;;"
    / "run;";

  /* loop through content found and print info to the log */
  put 'data _null_;                                                                        '
    / 'if upcase(strip(symget("helpKeyword"))) in (" " "LICENSE") then do; stop; end;      '
    / 'if NOBS = 0 then do; '
    /   'put; put '' *> No preview. Try %previewPackage(packageName,*) to display all.''; put; stop; '
    / 'end; '
    / '  do until(EOFDS);                                                                  '
    / '   set WORK._last_ end = EOFDS nobs = NOBS;                                         '
    / '   length memberX $ 1024;                                                           '
    / '   memberX = cats("_",folder,".",file);                                             '
  /* inner data step in call execute to read each embedded file */
    / '   call execute("data _null_;                                                    ");'
    / "   call execute('infile &_PackageFileref_.(' || strip(memberX) || ') end = EOF;  ');"
    / '   call execute("    do until(EOF);                                              ");'
    / '   call execute("      input;                                                    ");'
    / '   call execute("      put _infile_;                                             ");'
    / '   call execute("    end;                                                        ");'
    / '   call execute("  put "" "" / "" "";                                            ");'
    / '   call execute("  stop;                                                         ");'
    / '   call execute("run;                                                            ");'
  /**/
    / "  end; "
    / "  stop; "
    / "run; "
  
  /* clean-up */
    / "proc delete data = WORK._last_; "
    / "run; "
    / 'options ls = &ls_tmp. ps = &ps_tmp. &notes_tmp. &source_tmp.; '
 
    / '%put NOTE: '"Preview of the &packageName. package, version &packageVersion., license &packageLicense.;"
    / '%put NOTE- *** END ***;'
    / "/* preview.sas end */";

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

  put "filename &_PackageFileref_. list;"
    / ' %put NOTE- ;'
    / ' %put NOTE: '"Help for package &packageName., version &packageVersion., license &packageLicense.;"

    / ' %put NOTE: ' @; put '*** %superq(packageTitle) ***; '
    / ' %put NOTE- ' @; put "Generated: &packageGenerated.; "
    / ' %put NOTE- ' @; put 'Author(s): %superq(packageAuthor); '
    / ' %put NOTE- ' @; put 'Maintainer(s): %superq(packageMaintainer); '
    / ' %put NOTE- ;'
    / ' %put NOTE- *** START ***;'
  
  /* Use helpKeyword macrovariable to search for content (filename and type) */
  /* put '%local ls_tmp ps_tmp notes_tmp source_tmp;                       ';*/
    / '%let ls_tmp     = %sysfunc(getoption(ls));         '
    / '%let ps_tmp     = %sysfunc(getoption(ps));         '
    / '%let notes_tmp  = %sysfunc(getoption(notes));      '
    / '%let source_tmp = %sysfunc(getoption(source));     '
    / 'options ls = MAX ps = MAX nonotes nosource;        '
    / '%include' " &_PackageFileref_.(packagemetadata.sas) / nosource2; "

    / 'data _null_;                                                               '
    / '  if strip(symget("helpKeyword")) = " " then                               '
    / '    do until (EOF);                                                        '
    / "      infile &_PackageFileref_.(description.sas) end = EOF;                "
    / '      input;                                                               '
    / '      if upcase(strip(_infile_)) =: "DESCRIPTION END:"   then printer = 0; '
    / '      if printer then put "| " _infile_;                                   '
    / '      if upcase(strip(_infile_)) =: "DESCRIPTION START:" then printer = 1; '
    / '    end;                                                                   '
    / '  else stop;                                                               ';

  put '  put ; put "  Package contains: "; ';
  EOFDS = 0;
  do until(EOFDS);
    /* content is created during package creation */
    set &filesWithCodes. end = EOFDS nobs = NOBS curobs = CUROBS;
    if upcase(type) in: ('TEST') then continue; /* exclude tests */

    put 'put @5 "' CUROBS +(-1) '." @10 "' type '" @21 "' fileshort '";';
  end;

  %if %superq(packageRequired) ne %then
  %do;
    length packageRequired $ 32767;
    packageRequired = symget('packageRequired');
    put '  length req $ 256;                        '
      / '  put ; put "  Required SAS Components: "; '
      / '  do req = ' / packageRequired / ' ;       '
      / '    put @3 "-" @5 req;                     '
      / '  end ;                                    ';
  %end;

  %if %superq(packageReqPackages) ne %then
  %do;
    length packageReqPackages $ 32767;
    packageReqPackages = symget('packageReqPackages');
    put '  length req $ 256;                        '
      / '  put ; put "  Required SAS Packages: ";   '
      / '  do req = ' / packageReqPackages / ' ;    '
      / '    put @3 "-" @5 req;                     '
      / '  end ;                                    ';
  %end;


  %if %superq(additionalContent) NE %then
  %do;
    put 'put ;' / 'put @3 ''Package contains additional content, run:  %loadPackageAddCnt(' "&packageName." ')  to load it'';'
      / "put @3 'or look for the %sysfunc(lowcase(&packageName.))_AdditionalContent directory in the Packages fileref';"
      / "put @3 'localization (only if additional content was deployed during the installation process).';" / "put ;";
  %end;

  put 'put " " / @3 "---------------------------------------------------------------------" / " ";' 
    /       'put @3 "*SAS package generated by SAS Package Framework, version `20260126`*";' 
    /       "put @3 '*under `&sysscp.`(`&sysscpl.`) operating system,*';"
    /       "put @3 '*using SAS release: `&sysvlong4.`.*';"
    / 'put " " / @3 "---------------------------------------------------------------------";';

  put 'run;                                                                      ' /;

  /* license info */
  put 'data _null_;                                                   '
    / '  if upcase(strip(symget("helpKeyword"))) = "LICENSE" then     '
    / '    do until (EOF);                                            '
    / "      infile &_PackageFileref_.(license.sas) end = EOF;        "
    / '      input;                                                   '
    / '      put "| " _infile_;                                       '
    / '    end;                                                       '
    / '  else stop;                                                   '
    / 'run;                                                           ';

  put 'data WORK._%sysfunc(datetime(), hex16.)_;                      '
    / 'infile cards4 dlm = "/";                                       '
    / 'input @;                                                       '
    / 'if 0 then output;                                              '
    / 'length helpKeyword $ 64;                                       '
    / 'retain helpKeyword "*";                                        '
    / 'drop helpKeyword;                                              '
    / 'if _N_ = 1 then helpKeyword = strip(symget("helpKeyword"));    '
    / 'if FIND(_INFILE_, helpKeyword, "it") or helpKeyword = "*" then ' 
    / ' do;                                                           '
    / '   input (folder order type file fileshort) (: $ 256.);        '
    / '   output;                                                     '
    / ' end;                                                          '
    / 'cards4;                                                        ';

  EOFDS = 0;
  do until(EOFDS);
    /* content is created during package creation */
    set &filesWithCodes. end = EOFDS;
    if upcase(type) in: ('TEST') then continue; /* exclude tests */

    length fileshort2 $ 256;
    select;
      when (upcase(type) in ("DATA" "LAZYDATA")) fileshort2 = cats("'",   fileshort, "'"   );
      when (upcase(type) =:  "MACRO"           ) fileshort2 = cats('''%', fileshort, "()'" );
      when (upcase(type) =:  "FUNCTION"        ) fileshort2 = cats("'",   fileshort, "()'" );
      when (upcase(type) =:  "IMLMODULE"       ) fileshort2 = cats("'",   fileshort, "()'" );
      when (upcase(type) =:  "PROTO"           ) fileshort2 = cats("'",   fileshort, "()'" );
      when (upcase(type) =:  "FORMAT"          ) fileshort2 = cats("'$",  fileshort, ".'"  );
      when (upcase(type) =:  "CASLUDF"         ) fileshort2 = cats("'",   fileshort, "()'" );
      when (upcase(type) in ('DS2PCK' 'DS2THR')) fileshort2 = cats("'DS2",  fileshort, "'" );
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
  put 'data _null_;                                                                                              '
    / 'if upcase(strip(symget("helpKeyword"))) in (" " "LICENSE") then do; stop; end;                            '
    / 'if NOBS = 0 then do; '
    /   'put; put '' *> No help info found. Try %helpPackage(packageName,*) to display all.''; put; stop; '
    / 'end; '
    / '  do until(EOFDS);                                                                                        '
    / '   set WORK._last_ end = EOFDS nobs = NOBS;                                                               '
    / '   length memberX $ 1024;                                                                                 '
    / '   memberX = cats("_",folder,".",file);                                                                   '
  /* inner data step in call execute to read each embedded file */
    / '   call execute("data _null_;                                                                          ");'
    / "   call execute('infile &_PackageFileref_.(' || strip(memberX) || ') end = EOF;                        ');"
    / '   call execute("    printer = 0;                                                                      ");'
    / '   call execute("    do until(EOF);                                                                    ");'
    / '   call execute("      input;                                                                          ");'
    / '   call execute("      _endhelpline_ = upcase(reverse(strip(_infile_)));                               ");'
    / '   call execute("      if 18 <= lengthn(_endhelpline_) AND _endhelpline_                                  '
    / '                          =: ''/*** DNE PLEH ***/'' then printer = 0;                                  ");' /* ends with HELP END */  
    / '   call execute("      if printer then put ""| "" _infile_;                                            ");'
    / '   call execute("      _starthelpline_ = upcase(strip(_infile_));                                      ");'
    / '   call execute("      if 20 <= lengthn(_starthelpline_) AND _starthelpline_                              '
    / '                          =: ''/*** HELP START ***/'' then printer = 1;                                ");' /* starts with HELP START */  
    / '   call execute("    end;                                                                              ");'
    / '   call execute("  put "" "" / "" "";                                                                  ");'
    / '   call execute("  stop;                                                                               ");'
    / '   call execute("run;                                                                                  ");'
    / '   if lowcase(type) in ("data" "lazydata") then                                                           '
    / '    do;                                                                                                   '
    / '     call execute("title ""Dataset " || strip(fileshort) || " from package &packageName. "";           ");'
    / '     if exist(fileshort) then call execute("proc contents data = " || strip(fileshort) || "; run;      ");'
    / '     else call execute("data _null_; put ""| Dataset " || strip(fileshort) || " does not exist.""; run;");'
    / '     call execute("title;                                                                              ");'
    / '    end;                                                                                                  '
  /**/
    / "  end; "
    / "  stop; "
    / "run; ";
  
  /* clean up */
  put "proc delete data = WORK._last_; "
    / "run; ";
  
  /* generate dataset witch content information */
  put 'data &packageContentDS. _NULL_;                        '
    / ' if "&packageContentDS." = " " then stop;              '
    / '  infile cards4 dlm = "/";                             '
    / '  input (folder order type file fileshort) (: $ 256.); '
    / '  output;                                              '
    / 'cards4;                                                '
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
    / 'options ls = &ls_tmp. ps = &ps_tmp. &notes_tmp. &source_tmp.; ';
  
  put '%put NOTE: '"Help for package &packageName., version &packageVersion., license &packageLicense.;"
    / '%put NOTE- *** END ***;'
    / "/* help.sas end */";
  
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
  call execute(cats("filename _SPFOUT_ ZIP '", build, "/%sysfunc(lowcase(&packageName.)).zip' member='_", folder, ".", file, "';") );

  /* copy code file into the zip */
  call execute('data _null_;');
  call execute('  put ; length pathname $ 8192;');
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
      call execute(cats("filename _SPFOUT_ ZIP '", build, "/%sysfunc(lowcase(&packageName.)).zip' member='", drivFile, ".sas';") );
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

  filename &zipReferrence. "&buildLocation./%sysfunc(lowcase(&packageName.)).zip";
  filename &zipReferrence. list;
  %local notesSourceOptions;
  %let notesSourceOptions = %sysfunc(getoption(notes)) %sysfunc(getoption(source));
  options NOnotes NOsource;
  data _null_;
    set sashelp.vfunc(keep=fncname);
    where fncname = "HASHING_FILE";
    call execute('
      data work.the_SHA256_hash_id;' !!
        /* F - file */
        " SHA256 = 'F*' !! HASHING_FILE('SHA256', pathname('&zipReferrence.','F'), 0); " !!
        ' TYPE="F"; ' !!
        ' put / @7 SHA256= / " "; output; ' !!
        ' call symputX("packageHashF",SHA256,"L");' !!
        /* C  - content */
        " SHA256 = 'C*' !! HASHING_FILE('SHA256', '&zipReferrence.', 4); " !!
        ' TYPE="C"; ' !!
        ' put / @7 SHA256= / " "; output; ' !!
        ' call symputX("packageHashC",SHA256,"L");' !!
        ' label ' !! 
        '  SHA256 = "The SHA256 hash digest for package &packageName.:" ' !!
        '  TYPE= "Type of hash digest / F = file / C = content"; ' !!
      'run;');
    call execute('proc print data = work.the_SHA256_hash_id noobs label split="/"; run;');
    stop;
  run;
  options &notesSourceOptions.;
  filename &zipReferrence. clear;
%end;
/*-+++++++++++++++++++++++-*/ /*-+++++++++++++++++++++++-*/ /*-+++++++++++++++++++++++-*/ /*-+++++++++++++++++++++++-*/


/*---------------------------------------------------------------- *
*                                                                  *
* tests for a package are encapsulated in the next macro           *
*                                                                  *
* ---------------------------------------------------------------- */
/* locate sas binaries for testing part of the framework */
%local SASROOT SASEXE SASWORK;

/* location of the config file */
%local SASCONFIG; /* by default a local macrovariable is empty, so no file would be pointed as a config file */

/* temporary location for tests results is WORK unless developer provide &testResults. */
%local testPackageTimesamp;

/* location for test and test work */
%local dirForTest dirForTestWork;

%SPFint_gnPckg_tests()

/*------------------------------------------------------------------- *
*                                                                     *
* markdown documentation generation is encapsulated in the next macro *
*                                                                     *
* ------------------------------------------------------------------- */
%SPFint_gnPckg_markdown()

/*-------------------------------------------------------------------- *
*                                                                      *
* copying (with version in the name) is encapsulated in the next macro *
*                                                                      *
* -------------------------------------------------------------------- */
%SPFint_gnPckg_arch()


/* clean temporary files */
proc sql;
  drop table &filesWithCodes.;

  %if %sysfunc(exist(&filesWithCodes.addCnt)) %then
    %do;
      drop table &filesWithCodes.addCnt;
    %end;

  %if %sysfunc(exist(&filesWithCodes.markdown)) %then
    %do;
      drop table &filesWithCodes.markdown;
    %end;
quit;

/* turn on the original value of the note about quoted string length */
options &qlenmax_fstimer_tmp.;

%ENDofgeneratePackage:
%put --- generatePackage END ---;
%mend generatePackage;


/* START macros extracted outside generatePackage macro */

/*+SPFint_gnPckg_tests+*/
%macro SPFint_gnPckg_tests()/secure minoperator
des='SAS Packages Framework internal macro. Executable only inside the %generatePackage() macro. The macro encapsulates the test part of the process. Version 20260126.';
/* macro picks up all macrovariables from external scope, so from the %generatePackage() macro */
%if %sysmexecname(%sysmexecdepth-1) in (GENERATEPACKAGE) %then
%do;
/*=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=*/

/* verify if there were errors while package content creation */
%if %superq(createPackageContentStatus) ne 0 %then
  %do;
    %put ERROR- ** [&sysmacroname.] **;
    %put ERROR: ** ERRORS IN PACKAGE CONTENT CREATION! **;
    %put ERROR- ** NO TESTING WILL BE EXECUTED.        **;
    %GOTO NOTESTING;
  %end;

/* tests of package are executed by default */
%if NOT (%superq(testPackage) in (Y y 1)) %then
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
      put @n " path=&buildLocation.)" /;
      put @n '%loadpackage'"(&packageName.,";
      put @n " path=&buildLocation., lazyData=*)" /;

      /* meta */
      put @n '%put >>>%'"&packageName."'META( )<<<;'/
          @n '%put >>>%'"&packageName."'META(V)<<<;'/
          @n '%put >>>%'"&packageName."'META(D)<<<;'/
          @n '%put >>>%'"&packageName."'META(A)<<<;'/
          @n '%put >>>%'"&packageName."'META(M)<<<;'/
          @n '%put >>>%'"&packageName."'META(L)<<<;'/
          @n '%put >>>%'"&packageName."'META(E)<<<;'/
          @n '%put >>>%'"&packageName."'META(T)<<<;'/
          @n '%put >>>%'"&packageName."'META(P)<<<;'/
          @n '%put >>>%'"&packageName."'META(S)<<<;'/;

      /* help */
      put @n '%helpPackage'"(&packageName.,";
      put @n " path=&buildLocation.)" /;
      put @n '%helpPackage'"(&packageName.,*,";
      put @n " path=&buildLocation.)" /;
      put @n '%helpPackage'"(&packageName.,License,";
      put @n " path=&buildLocation.)" /;

      /* preview */
      put @n '%previewPackage'"(&packageName.,";
      put @n " path=&buildLocation.)" /;
      put @n '%previewPackage'"(&packageName.,*,";
      put @n " path=&buildLocation.)" /;

      /* unload */
      put @n '%unloadPackage'"(&packageName.,";
      put @n " path=&buildLocation.)         " /;

      /* additional content */
      put @n '%loadPackageAddCnt'"(&packageName.,";
      put @n " path=&buildLocation.)         " /;

      put ;
      put '***************************************************';
    run;

    %GOTO NOTESTING;
  %end;


/* locate sas binaries for testing part of the framework */
/**** %local SASROOT SASEXE SASWORK; ****/

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
/**** %local SASCONFIG; ****/ /* by default a local macrovariable is empty, so no file would be pointed as a config file */

%if %Qupcase(&sascfgFile.) = DEF %then /* the DEF value points to the sasv9.cfg file in the sasroot directory */
  %do;
    %let SASCONFIG = -config "&SASROOT./sasv9.cfg";
    %put NOTE: The following SAS config file will be used:;
    %put NOTE- &=SASCONFIG.;
  %end;
%else %if %superq(sascfgFile) NE %then /* non-empty path points to user defined config file */
  %do;
    %if %sysfunc(fileexist(&sascfgFile.)) %then
      %do;
        %let SASCONFIG = -config "&SASCFGFILE.";
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
/**** %local testPackageTimesamp; ****/
%let testPackageTimesamp = %sysfunc(lowcase(&packageName._%sysfunc(datetime(),b8601dt15.)));
%if %qsysfunc(fileexist(%superq(testResults))) %then
  %do;
    libname TEST "&testResults./test_&testPackageTimesamp.";
  %end;
%else
  %do;
    %if NOT %sysevalf(%superq(testResults)=,boolean) %then
      %do;
        %put WARNING: The testResults path:;
        %put WARNING- %superq(testResults);
        %put WARNING- does not exist. WORK will be used.;
        %put WARNING- ;
      %end;
    libname TEST "&SASWORK./test_&testPackageTimesamp.";
  %end;

/* test WORK points to the SAS session WORK or to directory pointed by the developer */
%if %qsysfunc(fileexist(%superq(testWorkPath))) %then
  %do;
    libname TESTWORK "&testWorkPath./testwork_&testPackageTimesamp.";
    %put NOTE- ;
    %PUT NOTE: WORK libname directories from test SAS sessions will not be deleted.;
    %if %sysevalf(1=%superq(workInTestResults),boolean) %then
      %do;
        %put NOTE- Parameter workInTestResults is ignored;
      %end;
    %put NOTE- ;

    %let delTestWork=0;
  %end;
%else %if %sysevalf(1=%superq(workInTestResults),boolean) %then
  %do;
    libname TESTWORK "%sysfunc(pathname(TEST))";
    %put NOTE- ;
    %PUT NOTE: WORK libname directories from test SAS sessions will be located in the;
    %PUT NOTE- same directory where test resulrs are stored, and will not be deleted.;
    %put NOTE- ;
    %let delTestWork=0;
  %end;
%else
  %do;
    %if NOT %sysevalf(%superq(testWorkPath)=,boolean) %then
      %do;
        %put WARNING: The testWorkPath path:;
        %put WARNING- %superq(testWorkPath);
        %put WARNING- does not exist. WORK will be used.;
        %put WARNING- ;
      %end;
    libname TESTWORK "&SASWORK./testwork_&testPackageTimesamp."; 
  %end;

/**** %local dirForTest dirForTestWork; ****/
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
/* test if packages fileref exists and, if it does, use it */
/* if no one is provided the buildLocation is used as a replacement */
%if %superq(packages)= %then %let packages=%sysfunc(pathname(packages));
%if %superq(packages)= %then %let packages=&buildLocation.;
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

  put "proc printto"
    / "log = '&dirForTest./loading.log0'"
    / "; run;";

  put "filename packages '&packages.';" /;

  if fileexist("&packages./SPFinit.sas") then
    put '%include packages(SPFinit.sas);' /;
  else if fileexist("&packages./loadpackage.sas") then
    put '%include packages(loadpackage.sas);' / ; /* for older versions when the SPFinit.sas did not exist */

  /* load */
  put '%loadpackage'"(&packageName.,"
    / " path=&buildLocation.)" /;
  put '%loadpackage'"(&packageName.,"
    / " path=&buildLocation., lazyData=*)" /;

  /* meta */
  put '%put >>null        >%'"&packageName."'META( )<<<;'/
      '%put >>unknown     >%'"&packageName."'META(U)<<<;'/ /* test for unknown values */
      '%put >>version     >%'"&packageName."'META(V)<<<;'/
      '%put >>datetime    >%'"&packageName."'META(D)<<<;'/
      '%put >>authors     >%'"&packageName."'META(A)<<<;'/
      '%put >>maintainers >%'"&packageName."'META(M)<<<;'/
      '%put >>license     >%'"&packageName."'META(L)<<<;'/
      '%put >>encoding    >%'"&packageName."'META(E)<<<;'/
      '%put >>title       >%'"&packageName."'META(T)<<<;'/
      '%put >>req packages>%'"&packageName."'META(P)<<<;'/
      '%put >>req SAS     >%'"&packageName."'META(S)<<<;'/;

  /* help */
  put '%helpPackage'"(&packageName.,"
    / " path=&buildLocation.)" /;
  put '%helpPackage'"(&packageName.,*,"
    / " path=&buildLocation.)" /;
  put '%helpPackage'"(&packageName.,License,"
    / " path=&buildLocation.)" /;

  /* preview */
  put '%previewPackage'"(&packageName.,";
  put " path=&buildLocation.)" /;
  put '%previewPackage'"(&packageName.,*,";
  put " path=&buildLocation.)" /;

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
            put "data _null_; " 
              / " if not exist('" fileshortUP "') then " 
              / "   put 'WARNING: Dataset " fileshortUP "does not exist!'; " ;
          if 1 = LAST.type then
            put "run; ";
        end;

      when (upcase(type) =: "MACRO")
        do;
          if 1 = FIRST.type then
            put "data _null_; " 
              / ' if not input(resolve(''%SYSMACEXIST(' fileshortUP ')''), best.) then ' 
              / "   put 'WARNING: Macro " fileshortUP "does not exist!'; " ;
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
  put '%unloadPackage'"(&packageName.,"
    / " path=&buildLocation.)         " /;

  /* additional content */
  put '%loadPackageAddCnt'"(&packageName.,"
    / " path=&buildLocation.)         " /;

  put "filename packages '&buildLocation.';" 
    / '%listPackages()                     ' /;

  /* check if work should be deleted after test is done */
  delTestWork = input(symget('delTestWork'), ?? best32.);
  if 0 = delTestWork then
    put "options NOWORKTERM;"/;

  put "proc printto"
    / "; run;";

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

  /* check if work should be deleted after test is done */
  delTestWork = input(symget('delTestWork'), ?? best32.);
  if not(delTestWork in (0 1)) then
    do;
      putlog "WARNING: [&sysmacroname.] The `delTestWork` parameter is invalid.";
      putlog "WARNING- [&sysmacroname.] Default value (1) is set.";
      delTestWork = 1;
    end;

  if 0 = delTestWork then
    do;
      put "libname _ '&dirForTest.';" /
          "data TESTWORK_&t.;" /
          "  length testName $ 128 testWork $ 2048;" /
          "  testNumber=&t.; testName='&&TEST_&t..';" /
          "  testWork = pathname('WORK');" /
          "run;" /
          "proc append base=_.TESTWORK data=TESTWORK_&t.; run;" /
          "proc delete data=TESTWORK_&t.; run;" /
          "libname _ clear;" ;
    end; 

  put "proc printto";
  put "log = '&dirForTest./&&TEST_&t...log0'";
  put "; run;";

  put "filename packages '&packages.';" /;

  if fileexist("&packages./SPFinit.sas") then
    put '%include packages(SPFinit.sas);' /;
  else if fileexist("&packages./loadpackage.sas") then
    put '%include packages(loadpackage.sas);' /; /* for older versions when the SPFinit.sas did not exist */

  put '%loadpackage'"(&packageName.,";
  put " path=&buildLocation.)" /;
  put '%loadpackage'"(&packageName.,";
  put " path=&buildLocation., lazyData=*)" /;

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
  do testNumber = 0 to &numberOfTests.;
    testName = symget(cats("TEST_", testNumber));
    systask  = coalesce(input(symget(cats("SASSTAT", testNumber)), ?? best32.), -1);
    sysrc    = coalesce(input(symget(cats("TESTRC_", testNumber)), ?? best32.), -1);
    error    = coalesce(input(symget(cats("TESTE_", testNumber)),  ?? best32.), -1);
    warning  = coalesce(input(symget(cats("TESTW_", testNumber)),  ?? best32.), -1);
    
    output;
  end;
run;
title1 "Summary of tests.";
title2 "details can be found in:";
title3 "%sysfunc(pathname(TEST))";
footnote;
proc print data = test.tests_summary(drop=testNumber);
run;
title;

%if 0=&delTestWork. %then
  %do;
    data test.tests_summary;
      merge 
        test.tests_summary 
        %if %sysfunc(EXIST(test.testwork)) %then 
          %do; test.testwork %end;
        %else 
          %do; %PUT INFO: Cannot add work path location info.; %end;
      ;
      by testNumber;
    run;
    %if %sysfunc(EXIST(test.testwork)) %then 
      %do; 
        proc delete data=test.testwork; 
        run; 
      %end;
  %end;

/*%put _local_;*/

%put NOTE: Changing current folder to:;
%put NOTE- *%sysfunc(DLGCDIR(%sysfunc(pathname(currdir))))*;
filename CURRDIR clear;

/* turn on the original value of the note about quoted string length */
options &quotelenmax_tmp.;

/* if you do not want any test to be executed */
%NOTESTING:
/*=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=*/
%end;
%else
  %do;
    %put INFO: SAS Packages Framework internal macro. Executable only inside the %nrstr(%%)generatePackage() macro.;
  %end;
%mend SPFint_gnPckg_tests;



/*+SPFint_gnPckg_markdown+*/
%macro SPFint_gnPckg_markdown()/secure minoperator
des='SAS Packages Framework internal macro. Executable only inside the %generatePackage() macro. The macro encapsulates the markdown documentation part of the process. Version 20260126.';
/* macro picks up all macrovariables from external scope, so from the %generatePackage() macro */
%if %sysmexecname(%sysmexecdepth-1) in (GENERATEPACKAGE) %then
%do;
/*=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=*/

/* generate MarkDown documentation file */
/* check param value */
%if %superq(markdownDoc) NE 1 %then %let markdownDoc=0;
/* if true then execute */
%if &markdownDoc.=1 %then
%do;
  %if %superq(createPackageContentStatus) NE 0 %then
    %do;
      %put ERROR- ** [&sysmacroname.] **;
      %put ERROR: ** ERRORS IN PACKAGE CONTENT CREATION! **;
      %put ERROR- ** NO MARKDOWN DOCUMMENTATION WILL BE GENERATED. **;
      %GOTO NOmarkdownDoc;
    %end;
/*= generate MarkDown documentation START =================================================================================*/
%put NOTE-;
%put NOTE: Preparing markdown documentation file.;
%put NOTE- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^;
%put NOTE-;

%local MarkDownOptionsTmp;
%let MarkDownOptionsTmp = 
 %sysfunc(getoption(notes)) %sysfunc(getoption(source)) msglevel=%sysfunc(getoption(msglevel));
options NOnotes NOsource msglevel=N;

filename &zipReferrence. "&buildLocation./%sysfunc(lowcase(&packageName.)).md";
filename &_PackageFileref_. ZIP "&buildLocation./%sysfunc(lowcase(&packageName.)).zip";

data &filesWithCodes.markdown;
  /* break if no data */
  if NOBS = 0 then stop;

  file &zipReferrence. encoding = &packageEncoding.;
  put "# Documentation for the `&packageName.` package.";

  length packageLicense packageGenerated $ 64
         packageTitle packageAuthor packageMaintainer $ 4096 
         packageHashF packageHashC $ 128 
         ;
  packageLicense=symget("packageLicense");
  packageTitle=symget("packageTitle");
  packageGenerated=symget("packageGenerated");
  packageAuthor=symget("packageAuthor");
  packageMaintainer=symget("packageMaintainer");
  packageHashF=symget("packageHashF");
  packageHashC=symget("packageHashC");
  drop package:;

  put "  " / 64*"-" / " "
    / ' *' packageTitle +(-1)'* '
    / "  " / 64*"-" / " "
    / "### Version information:"
    / "  "  
    / "- Package: &packageName."
    / "- Version: &packageVersion." 
    / "- Generated: " packageGenerated
    / "- Author(s): " packageAuthor
    / "- Maintainer(s): " packageMaintainer
    / "- License: " packageLicense
    / "- File SHA256: `" packageHashF +(-1) "` for this version"
    / "- Content SHA256: `" packageHashC  +(-1) "` for this version"
    / "  " / "---" / " ";

  put "# The `&packageName.` package, version: `&packageVersion.`;"
    / "  " / "---" / " ";

  do until (EOF);                                                        
    infile &_PackageFileref_.(description.sas) end = EOF;                
    input;                                                               
    if upcase(strip(_infile_)) =: "DESCRIPTION END:"   then printer = 0; 
    if printer then put _infile_;                                   
    if upcase(strip(_infile_)) =: "DESCRIPTION START:" then printer = 1; 
  end;                                                                   

  put "  " / "---" / " ";

  %if %superq(packageRequired) ne %then
  %do;
    put "  " / "---" / " ";
    length req $ 256;                        
    put "Required SAS Components: ";
    do req = &packageRequired. ;      
      put @3 "-" @5 req;                    
    end ;                                   
  %end;

  %if %superq(packageReqPackages) ne %then
  %do;
    put "  " / "---" / " ";
    length req2 $ 256;                     
    put "Required SAS Packages: ";     
    do req2 = &packageReqPackages.;
      put @3 "-" @5 req2;                 
    end ;                                
  %end;

  put "  " / "---" / " ";

  %if %superq(additionalContent) NE %then
  %do;
    put "  " / "---" / " ";
    put 'Package contains additional content, run:  `%loadPackageAddCnt(' "&packageName." ')`  to load it'
      / "or look for the `%sysfunc(lowcase(&packageName.))_AdditionalContent` directory in the `packages` fileref"
      / "localization (only if additional content was deployed during the installation process).";
  %end;

  put " " / "---------------------------------------------------------------------" / " " 
          / "*SAS package generated by SAS Package Framework, version `20260126`,*"
          / "*under `&sysscp.`(`&sysscpl.`) operating system,*" 
          / "*using SAS release: `&sysvlong4.`.*" 
    / " " / "---------------------------------------------------------------------" / " ";

  put "# The `&packageName.` package content";
  put "The `&packageName.` package consists of the following content:" / " ";
  EOFDS = 0;
  do until(EOFDS);
    /* content is created during package creation */
    set &filesWithCodes. end = EOFDS nobs = NOBS curobs = CUROBS;
    if upcase(type) in: ('TEST') then continue; /* exclude tests */
    
    /*
      To exclude file from being added to the documentation 
      insert the "excluding" text(see below) as a comment 
      in the FIRST or SECOND line of the file! 
      Do not add spaces.
      
      For each file the first line is read in and checked.
    */
    length _FILEVARPATH_ $ 4096;
    _FILEVARPATH_=catx("/",base,folder,file);
    infile _dummy_ FILEVAR=_FILEVARPATH_;
    input;
    if strip(_infile_) IN (
        '/*##DoNotUse4Documentation##*/'
        '/*##ExcludeFromDocumentation##*/'
        '/*##ExcludeFromMarkdownDoc##*/'
      )
    then continue; /* exclude file from documentation after FIRST line */
    input;
    if strip(_infile_) IN (
        '/*##DoNotUse4Documentation##*/'
        '/*##ExcludeFromDocumentation##*/'
        '/*##ExcludeFromMarkdownDoc##*/'
      )
    then continue; /* exclude file from documentation after SECOND line */
                   /* this is because %splitCodeForPackage() macro adds one extra line */ 
    
    type2=type;
    length link $ 256;
    link=catx("-",compress(fileshort,,"KAD"),type,CUROBS);
    length fileshort $ 256;
    select;
      when (upcase(type) =:  "MACRO"    ) do; fileshort2 = cats('`%', fileshort, "()`"); type2='macro';           end;
      when (upcase(type) =:  "FORMAT"   ) do; fileshort2 = cats("`$", fileshort, ".`");  type2='format/informat'; end;
      when (upcase(type) =:  "FUNCTION" ) do; fileshort2 = cats("`",  fileshort, "()`"); type2='function';        end; 
      when (upcase(type) =:  "IMLMODULE") fileshort2 = cats("`", fileshort, "()`");
      when (upcase(type) =:  "PROTO"    ) fileshort2 = cats("`", fileshort, "()`");
      when (upcase(type) =:  "CASLUDF"  ) fileshort2 = cats("`", fileshort, "()`");
      otherwise                           fileshort2 = cats("`", fileshort, "`");
    end;

    contentObs + 1;
    put @1 contentObs +(-1) '. [' fileshort2 type2'](#' link ')';
    output;
  end;

  put "  " / " ";
  contentObs+1;
  put @1 contentObs +(-1) '. [License note](#license)';
  put "  " / "---" / " ";

  putlog "Doc. note with general information ready.";
  stop;
run;

/* loop through content and print info to the MD file */
data _null_; 
  if 0 = NOBS then stop; 
  do until(EOFDS);                                                                                        
   set &filesWithCodes.markdown end = EOFDS nobs = NOBS curobs=CUROBS;                                                               
   length memberX $ 1024;                                                                                 
   memberX = cats("_",folder,".",file);                                                                   
   /* inner data step in call execute to read each embedded file */
   call execute("data _null_;                                                          ");
   call execute("  file &zipReferrence. encoding = &packageEncoding. MOD;              ");
   call execute('  put ''## ' !! catx(" ",fileshort2,type2) !! ' <a name="' !! strip(link) !! '"></a> ######'';');
   call execute('  infile &_PackageFileref_.(' || strip(memberX) || ') end = EOF;      ');
   call execute("    printer = 0;                                                      ");
   call execute("    do until(EOF);                                                    ");
   call execute("      input; length _endhelpline_ _starthelpline_ $ 32767;            ");
   call execute("      _endhelpline_ = upcase(reverse(strip(_infile_)));               ");
   call execute("      if 18 <= lengthn(_endhelpline_) AND _endhelpline_                  
                          =: '/*** DNE PLEH ***/' then printer = 0;                    "); /* ends with HELP END */  
   call execute("      if printer then put _infile_;                                   ");
   call execute("      _starthelpline_ = upcase(strip(_infile_));                      ");
   call execute("      if 20 <= lengthn(_starthelpline_) AND _starthelpline_              
                          =: '/*** HELP START ***/' then printer = 1  ;                "); /* starts with HELP START */  
   call execute("    end;                                                              ");
   call execute('  put "  " / "---" / " ";                                             ');
   call execute('  putlog ''Doc. note ' !! cats(CUROBS) !! ' for ' !! catx(" ",fileshort2,type2) !! ' ready.'';');
   call execute("  stop;                                                               ");
   call execute("run;                                                                  ");

  end;
  stop;
run;

/* license info */
data _null_;
  file &zipReferrence. encoding = &packageEncoding. MOD;
  putlog "Doc. note with license ready.";
  put "  " / "---" / " "
    / '# License <a name="license"></a> ######' / " "
    ;
  do until (EOF_L);                                            
    infile &_PackageFileref_.(license.sas) end = EOF_L;        
    input;                                                   
    put _infile_;                                       
  end;                  
  put "  " / "---" / " ";
  stop;
run;

options &MarkDownOptionsTmp.;
%put NOTE: Markdown file generated.;
filename &zipReferrence. list;
%put NOTE- ;

options NOnotes NOsource msglevel=N;

filename &zipReferrence. clear;
filename &_PackageFileref_. clear;
options &MarkDownOptionsTmp.;
/*= generate MarkDown documentation  END  =================================================================================*/
%NOmarkdownDoc:
%end;

/*=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=*/
%end;
%else
  %do;
    %put INFO: SAS Packages Framework internal macro. Executable only inside the %nrstr(%%)generatePackage() macro.;
  %end;
%mend SPFint_gnPckg_markdown;


/*+SPFint_gnPckg_arch+*/
%macro SPFint_gnPckg_arch()/secure minoperator
des='SAS Packages Framework internal macro. Executable only inside the %generatePackage() macro. The macro encapsulates the archive version generation part of the process. Version 20260126.';
/* macro picks up all macrovariables from external scope, so from the %generatePackage() macro */
%if %sysmexecname(%sysmexecdepth-1) in (GENERATEPACKAGE) %then
%do;
/*=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=*/

/*= generate files with version in the name START =========================================================================*/
/* to make archiving easier a copy of the package zip file
   with the version in the name is created */
%if %superq(easyArch) NE 1 %then %let easyArch=0;

%if %superq(easyArch) = 1 %then
%do;
  %put NOTE-;
  %put NOTE: Creating files with version in the name.;
  %put NOTE- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^;
  %put NOTE-;

  %local notesSourceOptions;
  %let notesSourceOptions = %sysfunc(getoption(notes)) %sysfunc(getoption(source));
  options NOnotes NOsource;

  %if %sysevalf(%superq(archLocation)=,boolean) %then
    %do;
      %let archLocation = &buildLocation.;
    %end;
  %else
    %do;
      %if 0=%sysfunc(FILEEXIST(%superq(archLocation))) %then
        %do;
          %put WARNING: The archLocation=%superq(archLocation) directory does NOT exist!;
          %put WARNING- ;
          %put WARNING- The %superq(buildLocation) directory will be used.;
          %let archLocation = &buildLocation.;
        %end;
    %end;
  %put NOTE: Arch location is: %superq(archLocation).;

  %local archSufixList i archSfx;
  /* by default list is only: "zip" */
  %let archSufixList=zip;
  /* if markdown is generated then "md" is added to the list */
  %if &markdownDoc.=1 %then %let archSufixList = &archSufixList. md;

  /* zip (md) */
  %do i = 1 %to %sysfunc(countw(&archSufixList.));
    %let archSfx=%scan(&archSufixList.,&i.);
    filename &zipReferrence. "&buildLocation./%sysfunc(lowcase(&packageName.)).&archSfx." lrecl=1 recfm=n;
    filename &zipReferrence. list;
    filename &zipReferrenceV. "&archLocation./%sysfunc(lowcase(&packageName.))_&packageVersion._.&archSfx." lrecl=1 recfm=n;
    filename &zipReferrenceV. list;
    data _null_;
      if NOT fexist("&zipReferrence.") then 
        do;
          put "WARNING: No file to archive!";
          stop;
        end;
      fexist = fexist("&zipReferrenceV.");
      rc = fcopy("&zipReferrence.", "&zipReferrenceV.");
      length rctxt $ 32767;
      rctxt = sysmsg();
      if rc then
        do;
          put "ERROR: An error " rc "occurred during creation of %sysfunc(lowcase(&packageName.))_&packageVersion._.&archSfx. file.";
          put rctxt;
        end;
      else
        do;
          if fexist then put "Overwriting " @; 
                    else put "Creating " @; 
          put "%sysfunc(lowcase(&packageName.))_&packageVersion._.&archSfx. file.";
        end;
    run;
    filename &zipReferrence. clear;
    filename &zipReferrenceV. clear;
  %end;
  options &notesSourceOptions.;
%end;
/*= generate files with version in the name  END  =========================================================================*/

/*=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=*/
%end;
%else
  %do;
    %put INFO: SAS Packages Framework internal macro. Executable only inside the %nrstr(%%)generatePackage() macro.;
  %end;
%mend SPFint_gnPckg_arch;

/* END macros extracted outside generatePackage macro */


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

- dodac typ "ds2" [v]

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
des = 'Macro to load multiple SAS packages at one run, version 20260126. Run %loadPackages() for help info.'
parmbuff
;
%if (%superq(packagesNames) = ) OR (%qupcase(&packagesNames.) = HELP) %then
  %do;
    %local options_tmp ;
    %let options_tmp = ls=%sysfunc(getoption(ls)) ps=%sysfunc(getoption(ps))
     %sysfunc(getoption(notes)) %sysfunc(getoption(source))
     msglevel=%sysfunc(getoption(msglevel))
    ;
    options NOnotes NOsource ls=MAX ps=MAX msglevel=N;
    %put ;
    %put #################################################################################;
    %put ###      This is short help information for the `loadPackageS` macro            #;
    %put #-------------------------------------------------------------------------------#;
    %put #                                                                               #;
    %put # Macro wrapper for the loadPackage macro, version `20260126`                   #;
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
    %put # Tutorials available at: `https://github.com/yabwon/HoW-SASPackages`           #;
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
    %put  %nrstr( %%loadPackageS(SQLinDS, DFA)    %%* load packages content into the SAS session; );
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
    %put #################################################################################;
    %put ;
    options &options_tmp.;
    %GOTO ENDofloadPackageS;
  %end;
  
  %local lengthOfsyspbuff numberOfPackagesNames i packageElement packageName packageVersion str;

  %let lengthOfsyspbuff      = %qsysfunc(length(&syspbuff.));
  %let packagesNames         = %qsysfunc(compress(%qsubstr(&syspbuff., 2, %eval(&lengthOfsyspbuff.-2)), {[(. <=>_,)]}, KDA));
  
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
des = 'Macro to verify SAS package with the hash digest, version 20260126. Run %verifyPackage() for help info.'
;
%if (%superq(packageName) = ) OR (%qupcase(&packageName.) = HELP) %then
  %do;
    %local options_tmp ;
    %let options_tmp = ls=%sysfunc(getoption(ls)) ps=%sysfunc(getoption(ps))
     %sysfunc(getoption(notes)) %sysfunc(getoption(source))
     msglevel=%sysfunc(getoption(msglevel))
    ;
    options NOnotes NOsource ls=MAX ps=MAX msglevel=N;
    %put ;
    %put #################################################################################;
    %put ###      This is short help information for the `verifyPackage` macro           #;
    %put #-------------------------------------------------------------------------------#;
    %put #                                                                               #;
    %put # Macro to verify SAS package with it hash digest, version `20260126`           #;
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
    %put # Tutorials available at: `https://github.com/yabwon/HoW-SASPackages`           #;
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
  
  %local ls_tmp ps_tmp notes_tmp source_tmp stimer_tmp fullstimer_tmp msglevel_tmp mautocomploc_tmp;
  %let ls_tmp         = %sysfunc(getoption(ls));
  %let ps_tmp         = %sysfunc(getoption(ps));
  %let notes_tmp      = %sysfunc(getoption(notes));
  %let source_tmp     = %sysfunc(getoption(source));
  %let stimer_tmp     = %sysfunc(getoption(stimer));
  %let fullstimer_tmp = %sysfunc(getoption(fullstimer));
  %let msglevel_tmp   = %sysfunc(getoption(msglevel));
  %let mautocomploc_tmp = %sysfunc(getoption(mautocomploc));
  
  options NOnotes NOsource ls=MAX ps=MAX NOfullstimer NOstimer msglevel=N NOmautocomploc;
  
  %local _PackageFileref_ checkExist;
  data _null_; 
    call symputX("_PackageFileref_", "P" !! put(MD5(lowcase("&packageName.")), hex7. -L), "L"); 
  run;

  /* when the packages reference is multi-directory search for the first one containing the package */
  data _null_;
    exists = 0;
    length packages $ 32767 p $ 4096;
    packages = resolve(symget("path"));
    if char(packages,1) ^= "(" then packages = quote(strip(packages)); /* for paths with spaces */
    do i = 1 to kcountw(packages, "()", "QS");
      p = dequote(kscanx(packages, i, "()", "QS"));
      exists + fileexist(catx("/", p, lowcase("&packageName.") !! ".zip")); /* check on zip files only! */
      if exists then leave;
    end;
    if exists then call symputx("path", p, "L");
              else call symputx("checkExist", '0 AND', "L");
  run;

  filename &_PackageFileref_. 
  /* put location of package myPackageFile.zip here */
    "&path./%sysfunc(lowcase(&packageName.)).zip"
  ;
  %if &checkExist. %sysfunc(fexist(&_PackageFileref_.)) %then
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
            length providedHash $ 128;
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
          msglevel=&msglevel_tmp. &mautocomploc_tmp.;
          
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
des = 'Macro to preview content of a SAS package, version 20260126. Run %previewPackage() for help info.'
;
%if (%superq(packageName) = ) OR (%qupcase(&packageName.) = HELP) %then
  %do;
    %local options_tmp ;
    %let options_tmp = ls=%sysfunc(getoption(ls)) ps=%sysfunc(getoption(ps))
     %sysfunc(getoption(notes)) %sysfunc(getoption(source))
     msglevel=%sysfunc(getoption(msglevel))
    ;
    options NOnotes NOsource ls=MAX ps=MAX msglevel=N;
    %put ;
    %put #################################################################################;
    %put ###    This is short help information for the `previewPackage` macro            #;
    %put #-------------------------------------------------------------------------------#;
    %put #                                                                               #;
    %put # Macro to get preview of a SAS packages, version `20260126`                    #;
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
    %put # Tutorials available at: `https://github.com/yabwon/HoW-SASPackages`           #;
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
  
  %local ls_tmp ps_tmp notes_tmp source_tmp msglevel_tmp mautocomploc_tmp;
  %let ls_tmp       = %sysfunc(getoption(ls));
  %let ps_tmp       = %sysfunc(getoption(ps));
  %let notes_tmp    = %sysfunc(getoption(notes));
  %let source_tmp   = %sysfunc(getoption(source));
  %let msglevel_tmp = %sysfunc(getoption(msglevel));
  %let mautocomploc_tmp = %sysfunc(getoption(mautocomploc));

  options NOnotes NOsource ls=MAX ps=MAX msglevel=N NOmautocomploc;
  
  %local _PackageFileref_;
  data _null_; 
    call symputX("_PackageFileref_", "P" !! put(MD5(lowcase("&packageName.")), hex7. -L), "L"); 
  run;

  /* when the packages reference is multi-directory search for the first one containing the package */
  data _null_;
    exists = 0;
    length packages $ 32767 p $ 4096;
    packages = resolve(symget("path"));
    if char(packages,1) ^= "(" then packages = quote(strip(packages)); /* for paths with spaces */
    do i = 1 to kcountw(packages, "()", "QS");
      p = dequote(kscanx(packages, i, "()", "QS"));
      exists + fileexist(catx("/", p, lowcase("&packageName.") !! ".&zip."));
      if exists then leave;
    end;
    if exists then call symputx("path", p, "L");
  run;

  filename &_PackageFileref_. &ZIP. 
  /* put location of package myPackageFile.zip here */
    "&path./%sysfunc(lowcase(&packageName.)).&zip." %unquote(&options.)
  ;
  %if %sysfunc(fexist(&_PackageFileref_.)) %then
    %do;
      %include &_PackageFileref_.(packagemetadata.sas) / &source2.;
      filename &_PackageFileref_. clear;
      options ls = &ls_tmp. ps = &ps_tmp. &notes_tmp. &source_tmp.;
      filename &_PackageFileref_. &ZIP. 
        "&path./%sysfunc(lowcase(&packageName.)).&zip." %unquote(&options.)
        ENCODING =
          %if %bquote(&packageEncoding.) NE %then &packageEncoding. ;
                                            %else utf8 ;
      ;
      %include &_PackageFileref_.(preview.sas) / &source2.;
    %end;
  %else %put ERROR:[&sysmacroname] File "&path./&packageName..&zip." does not exist!;
  filename &_PackageFileref_. clear;
  
  options ls = &ls_tmp. ps = &ps_tmp. &notes_tmp. &source_tmp. 
          msglevel = &msglevel_tmp. &mautocomploc_tmp.;
  
%ENDofpreviewPackage:
%mend previewPackage;

/*+extendPackagesFileref+*/
/*** HELP START ***/

%macro extendPackagesFileref(
 packages /* A valid fileref name, 
             when empty the "packages" value is used */
)/secure
/*** HELP END ***/
des = 'Macro to list directories pointed by "packages" fileref, version 20260126. Run %extendPackagesFileref(HELP) for help info.'
;

%if %QUPCASE(&packages.) = HELP %then
  %do;
    %local options_tmp ;
    %let options_tmp = ls=%sysfunc(getoption(ls)) ps=%sysfunc(getoption(ps))
     %sysfunc(getoption(notes)) %sysfunc(getoption(source))
     msglevel=%sysfunc(getoption(msglevel))
    ;
    options NOnotes NOsource ls=MAX ps=MAX msglevel=N;
    %put ;
    %put ###########################################################################################;
    %put ###       This is short help information for the `extendPackagesFileref` macro            #;
    %put #-----------------------------------------------------------------------------------------#;;
    %put #                                                                                         #;
    %put # Macro to list directories pointed by 'packages' fileref, version `20260126`             #;
    %put #                                                                                         #;
    %put # A SAS package is a zip file containing a group                                          #;
    %put # of SAS codes (macros, functions, data steps generating                                  #;
    %put # data, etc.) wrapped up together and embedded inside the zip.                            #;
    %put #                                                                                         #;
    %put # The `%nrstr(%%extendPackagesFileref())` macro lists directories pointed by                       #;
    %put # the packages fileref. It allows to add new directories to packages folder list.         #;
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
    %put # Tutorials available at: `https://github.com/yabwon/HoW-SASPackages`                     #;
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
    %put  %nrstr( %%include packages(SPFinit.sas);                %%* enable the framework;                  );
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
des = 'Macro to load additional content for a SAS package, version 20260126. Run %loadPackageAddCnt() for help info.'
minoperator
;
%if (%superq(packageName) = ) OR (%qupcase(&packageName.) = HELP) %then
  %do;
    %local options_tmp ;
    %let options_tmp = ls=%sysfunc(getoption(ls)) ps=%sysfunc(getoption(ps))
     %sysfunc(getoption(notes)) %sysfunc(getoption(source))
     msglevel=%sysfunc(getoption(msglevel))
    ;
    options NOnotes NOsource ls=MAX ps=MAX msglevel=N;
    %put ;
    %put #################################################################################;
    %put ###      This is short help information for the `loadPackageAddCnt` macro       #;
    %put #-------------------------------------------------------------------------------#;
    %put #                                                                               #;
    %put # Macro to *load* additional content for a SAS package, version `20260126`      #;
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
    %put # Tutorials available at: `https://github.com/yabwon/HoW-SASPackages`           #;
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
  %local ls_tmp ps_tmp notes_tmp source_tmp stimer_tmp fullstimer_tmp msglevel_tmp mautocomploc_tmp zip;
  %let ls_tmp         = %sysfunc(getoption(ls));
  %let ps_tmp         = %sysfunc(getoption(ps));
  %let notes_tmp      = %sysfunc(getoption(notes));
  %let source_tmp     = %sysfunc(getoption(source));
  %let stimer_tmp     = %sysfunc(getoption(stimer));
  %let fullstimer_tmp = %sysfunc(getoption(fullstimer));
  %let msglevel_tmp   = %sysfunc(getoption(msglevel));
  %let mautocomploc_tmp = %sysfunc(getoption(mautocomploc));

  %let zip = zip;

  options NOnotes NOsource ls=MAX ps=MAX NOfullstimer NOstimer msglevel=N NOmautocomploc;

  %local _PackageFileref_;
  data _null_; 
    call symputX("_PackageFileref_", "A" !! put(MD5(lowcase("&packageName.")), hex7. -L), "L"); 
    call symputX("_TargetFileref_",  "T" !! put(MD5(lowcase("&packageName.")), hex7. -L), "L"); 
  run;

  /* when the packages reference is multi-directory search for the first one containing the package */
  data _null_;
    exists = 0;
    length packages $ 32767 p $ 4096;
    packages = resolve(symget("path"));
    if char(packages,1) ^= "(" then packages = quote(strip(packages)); /* for paths with spaces */
    do i = 1 to kcountw(packages, "()", "QS");
      p = dequote(kscanx(packages, i, "()", "QS"));
      exists + fileexist(catx("/", p, lowcase("&packageName.") !! ".&zip."));
      if exists then leave;
    end;
    if exists then call symputx("path", p, "L");
  run;
  
  filename &_PackageFileref_. &ZIP. 
  /* put location of package myPackageFile.zip here */
    "&path./%sysfunc(lowcase(&packageName.)).&zip."
  ;
  %if %sysfunc(fexist(&_PackageFileref_.)) %then
    %do;

      filename &_PackageFileref_. &ZIP. 
      /* check existence of addcnt.zip inside package */
        "&path./%sysfunc(lowcase(&packageName.)).&zip."
        member='addcnt.zip'
      ;
      %if %sysfunc(fexist(&_PackageFileref_.)) %then
        %do;

          /* get metadata */
          filename &_PackageFileref_. &ZIP. 
            "&path./%sysfunc(lowcase(&packageName.)).&zip."
          ;
          %include &_PackageFileref_.(packagemetadata.sas) / &source2.;
          filename &_PackageFileref_. clear;


          /* test if required version of package is "good enough" */
          %local rV pV rV0 pV0 rVsign;
          %let pV0 = %sysfunc(compress(&packageVersion.,.,kd));
          %let pV = %sysevalf((%scan(&pV0.,1,.,M)+0)*1e8
                            + (%scan(&pV0.,2,.,M)+0)*1e4
                            + (%scan(&pV0.,3,.,M)+0)*1e0);

          %let rV0 = %sysfunc(compress(&requiredVersion.,.,kd));
          %let rVsign = %sysfunc(compress(&requiredVersion.,<=>,k));
          %if %superq(rVsign)= %then %let rVsign=<=;
          %else %if NOT (%superq(rVsign) IN (%str(=) %str(<=) %str(=<) %str(=>) %str(>=) %str(<) %str(>))) %then 
            %do;
              %put WARNING: Illegal operatopr "%superq(rVsign)"! Default(<=) will be used.;
              %put WARNING- Supported operators are: %str(= <= =< => >= < >);
              %let rVsign=<=;
            %end;
          %let rV = %sysevalf((%scan(&rV0.,1,.,M)+0)*1e8
                            + (%scan(&rV0.,2,.,M)+0)*1e4
                            + (%scan(&rV0.,3,.,M)+0)*1e0);
          
          %if NOT %sysevalf(&rV. &rVsign. &pV.) %then
            %do;
              %put ERROR: Additional content for package &packageName. will not be loaded!;
              %put ERROR- Required version is &rV0.;
              %put ERROR- Provided version is &pV0.;
              %put ERROR- Condition %bquote((&rV0. &rVsign. &pV0.)) evaluates to %sysevalf(&rV. &rVsign. &pV.);
              %put ERROR- Verify installed version of the package.;
              %put ERROR- ;
              %GOTO WrongVersionOFPackageAddCnt; /*%RETURN;*/
            %end;

          /*options ls = &ls_tmp. ps = &ps_tmp. &notes_tmp. &source_tmp.;*/
          filename &_PackageFileref_. &ZIP. 
            "&path./%sysfunc(lowcase(&packageName.)).&zip."
            member='addcnt.zip'
          ;
          /*********************/
          filename &_TargetFileref_. "&target.";
          %if %sysfunc(fexist(&_TargetFileref_.)) %then
            %do;

              %if %sysfunc(fileexist(%sysfunc(pathname(&_TargetFileref_.))/%sysfunc(lowcase(&packageName.))_AdditionalContent)) %then
                %do; /* dir for AC already exists */
                  %put WARNING: Target location:;
                  %put WARNING- %sysfunc(pathname(&_TargetFileref_.))/%sysfunc(lowcase(&packageName.))_AdditionalContent;
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
                  %put %sysfunc(dcreate(%sysfunc(lowcase(&packageName.))_AdditionalContent,%sysfunc(pathname(&_TargetFileref_.))));

                  %if NOT (%sysfunc(fileexist(%sysfunc(pathname(&_TargetFileref_.))/%sysfunc(lowcase(&packageName.))_AdditionalContent))) %then
                    %do; /* dir for AC cannot be generated */
                      %put ERROR: Cannot create target location:;
                      %put ERROR- %sysfunc(pathname(&_TargetFileref_.))/%sysfunc(lowcase(&packageName.))_AdditionalContent;
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
                            rc2=filename("out", pathname("WORK")!!"/%sysfunc(lowcase(&packageName.))addcnt.zip", "disk", "lrecl=1 recfm=n");
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
                          filename f ZIP "%sysfunc(pathname(WORK))/%sysfunc(lowcase(&packageName.))addcnt.zip";
                          options dlCreateDir;
                          libname outData "%sysfunc(pathname(&_TargetFileref_.))/%sysfunc(lowcase(&packageName.))_AdditionalContent";

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
                          
                            put wc= file=;

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

                                length rc1msg $ 8192;
                                rc1 = filename("in", strip(pathname_f), "zip", "member='" !! strip(file) !! "' lrecl=1 recfm=n");
                                rc1msg = sysmsg();

                                length fileNameOutPath $ 8192;
                                fileNameOutPath = catx("/", libText, scan(file, j , "/\"));
                                /* check for Windows */
                                if lengthn(fileNameOutPath)>260 then 
                                  if symget('SYSSCP')='WIN' then 
                                    put "INFO: Pathname plus filename length exceeds 260. Under Windows family OS it may cause problems.";

                                length rc2msg $ 8192;
                                rc2 = filename("out", fileNameOutPath, "disk", "lrecl=1 recfm=n");
                                rc2msg = sysmsg();
                              
                                length rc3msg $ 8192;
                                rc3 = fcopy("in", "out");
                                rc3msg = sysmsg();
                          
                                loadingProblem + (rc3 & 1);

                                if rc3 then
                                  do;
                                    put "ERROR: Cannot extract: " file;
                                    put "ERROR-" (rc1 rc2 rc3) (=); 
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
          msglevel=&msglevel_tmp. &mautocomploc_tmp.;

%ENDofloadPackageAddCnt:
%mend loadPackageAddCnt;

/**/

/*+splitCodeForPackage+*/
/*** HELP START ***/

%macro splitCodeForPackage(
 codeFile          /* a code file to split */
,packagePath=      /* location for results */
,debug=0           /* technical parameter  */
,nobs=0            /* technical parameter  */
)
/*** HELP END ***/
/ des = 'Utility macro to split "one big" code into multiple files for a SAS package, version 20260126. Run %splitCodeForPackage() for help info.'
;
%if (%superq(codeFile) = ) OR (%qupcase(&codeFile.) = HELP) %then
  %do;
    %local options_tmp ;
    %let options_tmp = ls=%sysfunc(getoption(ls)) ps=%sysfunc(getoption(ps))
     %sysfunc(getoption(notes)) %sysfunc(getoption(source))
     msglevel=%sysfunc(getoption(msglevel))
    ;
    options NOnotes NOsource ls=MAX ps=MAX msglevel=N;
    %put ;
    %put #################################################################################;
    %put ###     This is short help information for the `splitCodeForPackage` macro      #;
    %put #-------------------------------------------------------------------------------#;
    %put #                                                                               #;
    %put # Utility macro to *split* single file with SAS package code into multiple      #;
    %put # files with separate snippets, version `20260126`                              #;
    %put #                                                                               #;
    %put # A SAS package is a zip file containing a group                                #;
    %put # of SAS codes (macros, functions, data steps generating                        #;
    %put # data, etc.) wrapped up together and included by                               #;
    %put # a single `load.sas` file (also embedded inside the zip).                      #;
    %put #                                                                               #;
    %put # The `%nrstr(%%splitCodeForPackage())` macro takes a file with SAS code                 #;
    %put # snippets surrounded by `%str(/)*##$##-code-block-start-##$## <tag spec> *%str(/)` and     #;
    %put # `%str(/)*##$##-code-block-end-##$## <tag spec> *%str(/)` tags and split that file into    #;
    %put # multiple files and directories according to a tag specification.              #;
    %put #                                                                               #;
    %put # The `<tag spec>` is a list of pairs of the form: `type(object)` that          #;
    %put # indicates how the file should be split. See example 1 below for details.      #;
    %put #                                                                               #;
    %put #-------------------------------------------------------------------------------#;
    %put #### Parameters:                                                                #;
    %put #                                                                               #;
    %put # 1. `codeFile=`        *Required.* Name of a file containing code              #;
    %put #                        that will be split. Required and not null.             #;
    %put #                        If empty displays this help information.               #;
    %put #                                                                               #;
    %put # - `packagePath=`      *Required.* Location for package files after            #;
    %put #                        splitting into separate files and directories.         #;
    %put #                        If missing or not exist then `WORK` is used.           #;
    %put #                                                                               #;
    %put # - `debug=`            *Optional.* Turns on code printing for debugging.       #;
    %put #                                                                               #;
    %put # - `nobs=`             *Optional.* Technical parameter with value `0`.         #;
    %put #                        Do not change.                                         #;
    %put #                                                                               #;
    %put #-------------------------------------------------------------------------------#;
    %put #                                                                               #;
    %put # Visit: `https://github.com/yabwon/SAS_PACKAGES/tree/main/SPF/Documentation`   #;
    %put # to learn more.                                                                #;
    %put # Tutorials available at: `https://github.com/yabwon/HoW-SASPackages`           #;
    %put #                                                                               #;
    %put ### Example 1 ###################################################################;
    %put #                                                                               #;
    %put #   Assume that the `myPackageCode.sas` file                                    #;
    %put #   is located in the `C:/lazy/` folder and                                     #;
    %put #   contain the following code and tags:                                        #;
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas;
    %put  ;
    %put  %nrstr( /)%nrstr(*##$##-code-block-start-##$## 01_macro(abc) */                );
    %put  %nrstr( %%)%nrstr(macro abc();                                                         );
    %put  %nrstr(   %%put I am "abc".;                                                   );
    %put  %nrstr( %%)%nrstr(mend abc;                                                            );
    %put  %nrstr( /)%nrstr(*##$##-code-block-end-##$## 01_macro(abc) */                  );
    %put  ;
    %put  %nrstr( /)%nrstr(*##$##-code-block-start-##$## 01_macro(efg) */                );
    %put  %nrstr( %%)%nrstr(macro efg();                                                         );
    %put  %nrstr(   %%put I am "efg".;                                                   );
    %put  %nrstr( %%)%nrstr(mend efg;                                                            );
    %put  %nrstr( /)%nrstr(*##$##-code-block-end-##$## 01_macro(efg) */                  );
    %put  ;
    %put  %nrstr( proc FCMP outlib=work.f.p;                                             );
    %put  %nrstr( /)%nrstr(*##$##-code-block-start-##$## 02_functions(xyz) */            );
    %put  %nrstr( function xyz(n);                                                       );
    %put  %nrstr(   return(n**2 + n + 1)                                                 );
    %put  %nrstr( endfunc;                                                               );
    %put  %nrstr( /)%nrstr(*##$##-code-block-end-##$## 02_functions(xyz) */              );
    %put  %nrstr( quit;                                                                  );
    %put  ;
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
    %put #                                                                               #;
    %put # and we want results in `C:/split/` folder, we run the following:              #;
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas;
    %put  %nrstr( filename packages "C:/SAS_PACKAGES"; %%* setup a directory for packages;);
    %put  %nrstr( %%include packages(SPFinit.sas);      %%* enable the framework;         );
    %put  ;
    %put  %nrstr( %%splitCodeForPackage%(                                                 );
    %put  %nrstr(    codeFile=C:/lazy/myPackageCode.sas                                   );
    %put  %nrstr(   ,packagePath=C:/split/ %)                                             );
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
    %put #                                                                               #;
    %put #################################################################################;
    %put ;
    options &options_tmp.;                        
    %GOTO ENDofsplitCodeForPackage;
  %end;

%local options_tmp2 ;
%let options_tmp2 = ls=%sysfunc(getoption(ls)) ps=%sysfunc(getoption(ps))
%sysfunc(getoption(notes)) %sysfunc(getoption(source))
msglevel=%sysfunc(getoption(msglevel))
;
options nomprint nosymbolgen nomlogic notes source ls=MAX ps=MAX msglevel=N ;

%let debug = %sysevalf(NOT(0=%superq(debug)));
%if 1=&debug. %then
  %do;
    options mprint symbolgen mlogic source source2 msglevel=i;
  %end;

%put NOTE- --&SYSMACRONAME.-START--;
%local rc;
%let rc = %sysfunc(doSubL(%nrstr(
  options
  %sysfunc(ifc(1=&debug.
  ,msglevel=I ls=max ps=64 notes mprint symbolgen mlogic source source2
  ,msglevel=N ls=max ps=64 nonotes nomprint nosymbolgen nomlogic nosource nosource2
  ))
  ;;;;

  options DLcreateDir;
  libname w "%sysfunc(pathname(WORK))/_splitCodeForPackage_";
  filename d "%sysfunc(pathname(WORK))/_splitCodeForPackage_/dummy";
  data _null_;
    file d;
    put "dummy";
  run;

  data _null_;
    length codeFile $ 4096;
    codeFile = symget('codeFile');
    codeFile = dequote(codeFile);
   
    if fileexist(codeFile) then 
      do;
        codeFile = quote(strip(codeFile),"'");
        call symputX("codeFile",codeFile,"L");
      end;
    else 
      do;      
        put "ERROR: [splitCodeForPackage] File " codeFile 'does not exist!';
        call symputX("codeFile",quote(strip(pathname('d'))),"L");
      end;
  run;

  options notes;
  filename source &codeFile.;
  filename source LIST;
  options nonotes;

  data _null_;
    length packagePath work $ 4096;
    work = pathname('WORK');
    packagePath = coalescec(symget('packagePath'), work);
    rc = fileexist(packagePath);
    if NOT rc then packagePath = work;
    if rc = 1 then put "INFO: " @;
              else put "WARNING: " @;
    put packagePath=; 
    call symputX('packagePath',packagePath,"L");
  run;

  data w.files;
    stop;
  run;

  data _null_;
    if 1 = _N_ then
      do;
        declare hash H(ordered:"A");
        H.defineKey('token');
        H.defineData('token','start','end','lineNumber');
        H.defineDone();
      end;
    if 1 = _E_ then
      do;
        H.output(dataset:'w.files');  
      end;

    infile source END=_E_;
    lineNumberN+1;
    input;

    length line $ 4096 lineNumber $ 256;
    line = left(lowcase(_infile_));
    block=scan(line,1," ");

    if block in ( 
      '/*##$##-code-block-start-##$##' 
      '/*##$##-code-block-end-##$##'
    ); 

    if substr(block,20,1) = 's' then 
      do; s=1; e=0; end;
    else
      do; s=0; e=1; end;

    i=1;
    token=block;
    do while(i);
      i+1;
      token=scan(line,i," ");
      if token='*/' OR token=' ' then i=0;
      else
        do;
          start=0; end=0;
          if H.find() then
            do;
              start=s;
              end  =e;
              lineNumber = cats(lineNumberN);
            end;
          else
            do;
              start+s;
              end  +e; 
              lineNumber = catx(",",lineNumber,lineNumberN);
            end;
          H.replace();
          /*putlog token= s= e= start= end=;*/
        end;
    end;
  run;

  title;
  title1 "Attention!!! Not Matching Tags!";
  title2 "Verify following tags in file:";
  title3 &codeFile.;
  proc print data=w.files(where=(start NE end));
  run;
  title;

  data w.files;
    set w.files end=_E_ nobs=nobs; 
    where start=end;
    length dir $ 128 code $ 32 path $ 160;
    dir =coalescec(scan(token,1,'()'),'!BAD_DIRECTORY');
    code=coalescec(scan(token,2,'()'),'!BAD_CODE_FILE');
    if dir = '!BAD_DIRECTORY' or code = '!BAD_CODE_FILE' then
      put "WARNING: Bad directory or code file name!" 
        / "WARNING- Check tag: " token ;
    path=cats('/',dir,'/',code,'.sas'); /* .sas */
  run;

  title;
  title1 "List of tags with value _ALL_ for 'dir' or 'code' variable.";
  title2 "Snippets tagged this way will be copied to multiple files.";
  proc print data=w.files(where=(dir = '_all_' OR code = '_all_'));
  run;
  title;

  data w.files;
    if 0=nobs then
      put "WARNING: No tags found in the file";
    
    set w.files end=_E_ nobs=nobs; 
    where dir NE '_all_' AND code NE '_all_';
    n+1;
    if 1 = _E_ then 
      call symputX('nobs',n,"L");
  run;

  title;
  title "List of files";
  proc print data=w.files;
  run;
  title;

  data _null_;
    set w.files;
    rc = libname("_",catx("/",symget('packagePath'),dir));
    rc = libname("_");
  run;

  filename f DUMMY;
  data _null_;
    if 1 =_N_ then
      do;
        array paths[0:&nobs.] $ 128 _temporary_;
        array starts[0:&nobs.] _temporary_;
        array ends[0:&nobs.] _temporary_;
        array write[0:&nobs.] _temporary_;
        array firstLine[0:&nobs.] _temporary_;

        declare hash H();
        H.defineKey('token');
        H.defineData('n');
        H.defineDone();

        do until(_E_);
          set w.files end=_E_;
          paths[n]=path;
          starts[n]=start;
          ends[n]=end;
          write[n]=0;
          rc=H.add();
          firstLine[n]=1;
        end;
        _E_=.;
        length packagePath $ 4096;
        retain packagePath " ";
        packagePath=symget('packagePath');
      end;

    infile source END=_E_;
    input;

    length line /*lineToPrint*/ $ 4096;
    line = left(lowcase(_infile_));
    /*lineToPrint=_infile_;*/
    block=scan(line,1," ");

    if block in (
      '/*##$##-code-block-start-##$##' 
      '/*##$##-code-block-end-##$##'
    ) then 
      do;
        /********************************************************/
        if substr(block,20,1) = 's' then 
          do; s=1; e=0; end;
        else
          do; s=0; e=1; end;

        i=1;
        token=block;
        do while(i);
          i+1;
          token=scan(line,i," ");
          if token='*/' OR token=' ' then i=0; /* if it is the end of list - stop */
          else if token='_all_(_all_)' then /* if this is a snippet for ALL files in a package */
            do k=1 to &nobs.;
              starts[k]+ -s;
              ends[k]  + -e;
              write[k] + (s-e);
            end;
          else if scan(token,2,'()')='_all_' then /* if this is a snippet for ALL files in a type */
            do k=1 to &nobs.;
              if scan(token,1,'()')=scan(paths[k],1,'/\') then 
                do;
                  starts[k]+ -s;
                  ends[k]  + -e;
                  write[k] + (s-e);
                end;
            end;
          else if scan(token,1,'()')='_all_' then /* if this is a snippet for ALL files with the same name */
            do k=1 to &nobs.;
              if (scan(token,2,'()')!!'.sas')=scan(paths[k],2,'/\') then 
                do;
                  starts[k]+ -s;
                  ends[k]  + -e;
                  write[k] + (s-e);
                end;
            end;
          else /* all other "regular" cases */
            do;
              if 0=H.find() then
                do;
                  starts[n]+ -s;
                  ends[n]  + -e;
                  write[n] + (s-e);
                  select;
                    when(write[n]<0)
                      putlog "ERROR: Wrong tags order for " token=;
                    when(write[n]>1) 
                      do;
                        putlog "WARNING: Doubled value for tag" token=;
                        putlog "WARNING- detected in line " _N_;
                        putlog "WARNING- Check also counterpart block.";
                      end;
                    otherwise;
                  end;
                end;
            end;
        end;
        /********************************************************/
      end;
    else
      do j = 1 to hbound(write);
        if write[j]>0 then
          do;
            length fvariable $ 4096;
            fvariable=catx("/",packagePath,paths[j]);
            file f FILEVAR=fvariable MOD;
            /*
            lineToPrintLen=(lengthn(lineToPrint));
            if lineToPrintLen then
              put @1 lineToPrint $varying4096. lineToPrintLen;
            else put;
            */
            if firstLine[j] then
              do;
                put '/* File generated with help of SAS Packages Framework, version 20260126. */';
                firstLine[j]=0;
              end; 
            put _infile_;
          end;    
      end;
  run;

  filename f clear;
  libname w clear;
)));
%put NOTE- --&sysmacroname.-END--;
options &options_tmp2.;
%ENDofsplitCodeForPackage:
%mend splitCodeForPackage;

/*+relocatePackage+*/
/*** HELP START ***/

%macro relocatePackage(
 packageName   /* list of packages (space-separated!) */ 
,source=       /* place to take packages from (local location) */
,target=       /* the "packages" fileref by default */
,sDevice=DISK  /* also: ZIP, FILESRVC (SASFSVAM)*/
,tDevice=DISK  /* also: ZIP, FILESRVC */
,checksum=0    /* if 1, copies data only if the source (from file) checksum is different than the target (to file) */
,move=0        /* packages are copied by default */
,try=3         /* integer between 1 and 9 */
,debug=0       /* debugging indicator */
,ignorePackagesFilerefCheck=0
,psMAX=MAX     /* pageSise in case executed inside DoSubL() */
,ods=          /* a data set for results, e.g., work.relocatePackageReport */
)
/ des = 'Utility macro that locally Copies or Moves Packages, version 20260126. Run %relocatePackage() for help info.'
  secure
  minoperator
;
/*** HELP END ***/
%if (%superq(packageName) = ) OR (%qupcase(&packageName.) = HELP) %then
  %do;
    %local options_tmp ;
    %let options_tmp = ls=%sysfunc(getoption(ls)) ps=%sysfunc(getoption(ps))
     %sysfunc(getoption(notes)) %sysfunc(getoption(source))
     msglevel=%sysfunc(getoption(msglevel))
    ;
    options NOnotes NOsource ls=MAX ps=MAX msglevel=N;
    %put ;
    %put #################################################################################;
    %put ###      This is short help information for the `relocatePackage` macro         #;
    %put #-------------------------------------------------------------------------------#;
    %put #                                                                               #;
    %put # Macro to *locally copy or move* (relocate) SAS packages, version `20260126`   #;
    %put #                                                                               #;
    %put # A SAS package is a zip file containing a group                                #;
    %put # of SAS codes (macros, functions, data steps generating                        #;
    %put # data, etc.) wrapped up together and included by                               #;
    %put # a single `load.sas` file (also embedded inside the zip).                      #;
    %put #                                                                               #;
    %put # The `%nrstr(%%relocatePackage())` is a utility macro for local copying or moving       #;
    %put # SAS packages. The macro transfers packages located in the `PACKAGES`          #;
    %put # fileref to a selected directory (`DISK` device), folderpath (`FILESRVC`       #;
    %put # device), or a zip file (`ZIP` device).                                        #;
    %put #                                                                               #;
    %put # The macro allows for a bidirectional transfer of packages, i.e., from the     #;
    %put # `PACKAGES` fileref to the selected *target*, or from the selected *source*    #;
    %put # to the `PACKAGES` fileref.                                                    #;
    %put #                                                                               #;
    %put #-------------------------------------------------------------------------------#;
    %put #### Parameters:                                                                #;
    %put #                                                                               #;
    %put # 1. `packageName`      *Required.* Name of a package, e.g. myPackage.          #;
    %put #                       A space-separated(!) list of packages to transfer is    #;
    %put #                       also accepted. If empty displays this help information. #;
    %put #                                                                               #;
    %put # - `source=`           *Required/Optional.* Source location for packages.      #;
    %put #                       When used, indicates a directory (`DISK` device),       #;
    %put #                       a folderpath (`FILESRVC` device), or a zip file (`ZIP`  #;
    %put #                       device) *from* where packages will be copied.           #;
    %put #                       In this case `PACKAGES` fileref is target location.     #;
    %put #                       Cannot be used together with `target=` parameter.       #;
    %put #                                                                               #;
    %put # - `target=`           *Required/Optional.* Target location for packages.      #;
    %put #                       When used, indicates a directory (`DISK` device),       #;
    %put #                       a folderpath (`FILESRVC` device), or a zip file (`ZIP`  #;
    %put #                       device) *to* where packages will be copied.             #;
    %put #                       In this case `PACKAGES` fileref is source location.     #;
    %put #                       Cannot be used together with `source=` parameter.       #;
    %put #                                                                               #;
    %put # - `sDevice=`          *Required/Optional.* When `source=` is used this        #;
    %put #                       parameter provides which type of device to be use.      #;
    %put #                       Default value is `DISK`, values `ZIP` and `FILESRVC`    #;
    %put #                       are allowed. For `FILESRVC` the `folderpath=` is used.  #;
    %put #                                                                               #;
    %put # - `tDevice=`          *Required/Optional.* When `target=` is used this        #;
    %put #                       parameter provides which type of device to be use.      #;
    %put #                       Default value is `DISK`, values `ZIP` and `FILESRVC`    #;
    %put #                       are allowed. For `FILESRVC` the `folderpath=` is used.  #;
    %put #                                                                               #;
    %put # - `checksum=`         *Optional.* Indicates if packages should be copied only #;
    %put #                       if the source (from file) checksum is different than    #;
    %put #                       the target (to file). Default value is 0 (always copy). #;
    %put #                                                                               #;
    %put # - `move=`             *Optional.* Indicates if packages should be moved from  #;
    %put #                       source to target, default value is `0`,                 #;
    %put #                       when set to `1`: after *successful* copying packages    #;
    %put #                       in the source are *deleted*. Use carefully!             #;
    %put #                                                                               #;
    %put # - `debug=`            *Optional.* Indicates if debug notes should be printed, #;
    %put #                       default value is `0`, when set to `1`: debug info       #;
    %put #                       is printed.                                             #;
    %put #                                                                               #;
    %put # - `try=`              *Optional.* Number of tries when copy is unsuccessful,  #;
    %put #                       default value is `3`, allowed values are integers       #;
    %put #                       from 1 to 9. Time between tries is quarter of a second. #;
    %put #                                                                               #;
    %put #-------------------------------------------------------------------------------#;
    %put #                                                                               #;
    %put # Visit: `https://github.com/yabwon/SAS_PACKAGES/tree/main/SPF/Documentation`   #;
    %put # to learn more.                                                                #;
    %put # Tutorials available at: `https://github.com/yabwon/HoW-SASPackages`           #;
    %put #                                                                               #;
    %put ### Example 1 ###################################################################;
    %put #                                                                               #;
    %put #   Enabling the SAS Package Framework from the local                           #;
    %put #   directory, copying SQLinDS package from Viya Files                          #;
    %put #   service, and loading the package to the SAS session.                        #;
    %put #                                                                               #;
    %put #   Assume that the `SPFinit.sas` file is located in the "/home/user/PCKG"      #;
    %put #   directory and Viya Files service location is "/files/packages/"             #;
    %put #                                                                               #;
    %put #   Run the following code in your SAS session:                                 #;
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas;
    %put  %nrstr( filename packages "/home/user/PCKG"; %%* setup a directory for packages;     );
    %put  %nrstr( %%include packages(SPFinit.sas);      %%* enable the framework;              );
    %put  ;
    %put  %nrstr( %%relocatePackage%(SQLinDS  %%* copy the package from Viya Files service;    );
    %put  %nrstr(                 ,source=/files/packages/                                     );
    %put  %nrstr(                 ,sDevice=FILESRVC%)                                          );
    %put  %nrstr( %%loadPackage(SQLinDS)   %%* load the package content into the SAS session;  );
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
    %put #                                                                               #;
    %put ### Example 2 ###################################################################;
    %put #                                                                               #;
    %put #   Enabling the SAS Package Framework from the local directory                 #;
    %put #   and creating a "bundle" file by moving 3 packages: the BasePlus,            #;
    %put #   the SQLinDS, and the MacroArray package into the target file.               #;
    %put #                                                                               #;
    %put #   Assume that the `SPFinit.sas` file                                          #;
    %put #   is located in the "C:/SAS_PACKAGES/" folder.                                #;
    %put #                                                                               #;
    %put #   Run the following code in your SAS session:                                 #;
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas;
    %put  %nrstr( filename packages "C:/SAS_PACKAGES"; %%* setup a directory for packages;       );
    %put  %nrstr( %%include packages(SPFinit.sas);      %%* enable the framework;                );
    %put  ;
    %put  %nrstr( %%relocatePackage%(BasePlus SQLinDS MacroArray %%* create a bundle of packages;);
    %put  %nrstr(                 ,target=D:/archive/bundle_2025_12_15.zip                       );
    %put  %nrstr(                 ,tDevice=ZIP, move=1%)                                         );
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
    %put #                                                                               #;
    %put #################################################################################;
    %put ;
    options &options_tmp.;
    %GOTO ENDofrelocatePackage;
  %end;
  /* local variables for options */
  %local ls_tmp ps_tmp notes_tmp source_tmp stimer_tmp fullstimer_tmp msglevel_tmp mautocomploc_tmp;
  %let ls_tmp         = %sysfunc(getoption(ls));
  %let ps_tmp         = %sysfunc(getoption(ps));
  %let notes_tmp      = %sysfunc(getoption(notes));
  %let source_tmp     = %sysfunc(getoption(source));
  %let stimer_tmp     = %sysfunc(getoption(stimer));
  %let fullstimer_tmp = %sysfunc(getoption(fullstimer));
  %let msglevel_tmp   = %sysfunc(getoption(msglevel));
  %let mautocomploc_tmp = %sysfunc(getoption(mautocomploc));

  options NOnotes NOsource ls=128 ps=&psMAX. NOfullstimer NOstimer msglevel=N NOmautocomploc;

  %if NOT(%superq(debug) in (0 1))                      %then %let debug=0;
  %if NOT(%superq(move) in (0 1))                       %then %let move=0;
  %if NOT(%superq(try) in (1 2 3 4 5 6 7 8 9))          %then %let try=3;
  %if NOT(%superq(checksum) in (0 1))                   %then %let checksum=0;
  %if NOT(%superq(ignorePackagesFilerefCheck) in (0 1)) %then %let ignorePackagesFilerefCheck=0;
  
  options nonotes msglevel=N;

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
  %if &checksum. AND NOT &HASHING_FILE_exist. %then
    %do;
      %put WARNING: Checksum verification impossible! Minimum SAS version required for the process is 9.4M6. ;
    %end;

  data _null_ %if %superq(ods) NE %then %do; &ods. %end;
  ;
    putlog 52*"*" 24*"=" 52*"*";
    length packages source target $ 32767 sDevice tDevice $ 32;
    packages = lowcase(compress(symget('packageName'),"_ ","KAD"));

    if " " = packages then 
      do;
        putlog "INFO: No packages to move or copy. Exiting.";
        LINK stopProcessing;
      end;
    else putlog "INFO: List of packages: " packages;

    debug = sum(symgetn('debug'),0);

    /* grab macro variables values */
    array mvar source target sDevice tDevice;
    do over mvar;
      mvar=symget(vname(mvar));
    end;

    if source NE ' ' AND target NE " " then
      do;
        putlog "WARNING: The SOURCE= and the TARGET= parameters cannot be used simultaneously. Exiting!";
        LINK stopProcessing;
      end;

    if source EQ ' ' AND target EQ " " then
      do;
        putlog "INFO: The SOURCE= and the TARGET= parameters were not used, nothing to do. Exiting!";
        LINK stopProcessing;
      end;

    /* verify that PACKAGES is valid location for source or target */
    /*=========================================================================================================*/
    %if 0 = &ignorePackagesFilerefCheck. %then
      %do;
        if NOT (input(resolve('%isPackagesFilerefOK(&debug.)'), best.)=1) then /* if debug=1 the isPackagesFilerefOK in verbose mode */
          do;
            putlog "WARNING: The PACKAGES fileres is not OK! Exiting!";
            LINK stopProcessing;
          end;
      %end;
    /*=========================================================================================================*/

    /* prepare source and target */
    /*=========================================================================================================*/
    %local i ST_list st stDev stFr stH stI stEx stAsg leave;
    %let ST_list=target source; /* repeat the same structure twice with different prefix */
    %do i=1 %to 2;
      %let st=%scan(&ST_list., &i.);
      %let stDev=%substr(&st.,1,1)Device;
      %let stFr =%substr(&st.,1,1)FileRef;
      %let stH  =%substr(&st.,1,1)Hash;
      %let stI  =%substr(&st.,1,1)Iter;
      %let stEx =%substr(&st.,1,1)Exists;
      %let stAsg=%substr(&st.,1,1)Assigned;
      %let stFp =%substr(&st.,1,1)FromPackages;

      retain &stFp. 0 move 0;
      move = sum(symgetn('move'),0);
      /* validate source and target */
      &stDev. = upcase(compress(&stDev.,"_","KAD"));
      if NOT (&stDev. in ("DISK" "BASE" "ZIP" "FILESRVC" "SASFSVAM")) then
        do;
          putlog "WARNING: The &stDev. parameter value: " &stDev. "is not allowed."
               / "WARNING- Only: DISK, ZIP, and FILESRVC devices are supported as &st. device. Exiting!";
          LINK stopProcessing;
        end;

      if &st.=" " then 
        do;
          if 0 then set SASHELP.VEXTFL;
          DECLARE HASH &stH.(dataset:'SASHELP.VEXTFL(where=(fileref="PACKAGES"))', ordered: "A");
          &stH..DefineKey("level");
          &stH..DefineData("xpath","xengine");
          &stH..DefineDone();
          DECLARE HITER &stI.("&stH.");

          if &stH..NUM_ITEMS=0 then
            do;
              putlog "INFO: Packages fileref not found. Using WORK instead.";
              level = 0;
              xpath = pathname("WORK","L");
              xengine = 'DISK';
              &stI..REPLACE();
            end;

          &stI..FIRST();
          &st. = strip(xpath); /* get the first packages path */
          &stDev. = strip(xengine);
          
          /* Just to make it easier to debug since FILESRVC will show up in Google */
          if &stDev. = 'SASFSVAM' then _stDev_ = 'FILESRVC';
                                  else _stDev_ = strip(xengine);
          putlog "INFO: The &st. location is: " / @7 _stDev_ +(-1) ": " &st.;
          %if &st.=source %then 
            %do;
              do while(&stI..next()=0);
                 if xengine = 'SASFSVAM' then _engine_ = 'FILESRVC';
                                         else _engine_ = xengine;
                 putlog @7 _engine_ +(-1) ": " xpath;
              end;
            %end;
          &stFp. = 1;
        end; 
      else
        do;
          length &stFr. $ 8; 

          if " "=getoption("SERVICESBASEURL") AND (&stDev. in ("FILESRVC" "SASFSVAM")) then 
            do;
              putlog "WARNING: The SERVICESBASEURL option must be specified for the FILESRVC device. Exiting!";
              LINK stopProcessing; 
            end;

          length &stAsg.Txt &stEx.Txt $ 256;


          if (&stDev. in ("FILESRVC" "SASFSVAM")) then
            &stAsg. = filename(&stFr., ,strip(&stDev.), "recfm=n lrecl=1 " !! "folderpath=" !! quote(strip(&st.))); /* assign FILESRVC */
          else 
            &stAsg. = filename(&stFr.,strip(&st.), strip(&stDev.), "recfm=n lrecl=1"); /* assign DISK or ZIP*/
          &stAsg.Txt = sysmsg();

          &stEx. = FEXIST(&stFr.);
          &stEx.Txt = sysmsg();

          if debug then putlog (&stFr. &st. &stDev. &stAsg. &stAsg.Txt &stEx. &stEx.Txt) (=/);
          _rc_ = filename(&stFr.); /*clear*/
        end;
    %end;
    /*=========================================================================================================*/

    if source=target and sDevice=tDevice then 
      do;
        putlog / "INFO: Nothing to move or copy. Exiting.";
        LINK stopProcessing;
      end;

    if move then 
      do;
        putlog / "INFO: Files will be moved, i.e., after successful copying to the target location" 
               / "      the source will be deleted.";
      end;

    /* 4096 for host options for Viya FS */
    length sHostoptions tHostOptions $ 4096  tFilename sFilename  $ 2048;

    do i = 1 to countw(packages, " ");
      package = scan(packages, i, " ");

      putlog 52*"*" package $24.-C 52*"*";

      select;
        /* copy from PACKAGES to some location */
        /*=========================================================================================================*/
        when(1=sFromPackages AND 0=tFromPackages AND 0=tAssigned) 
          do;
            select;
              /* disk */
              when (tDevice in ("DISK" "BASE"))
                do;
                  if NOT tExists then GOTO stopForThisPackage1;
                  tAssigned = filename(tFileRef
                                      ,cats(target, "/", package, ".zip")
                                      ,strip(tDevice)
                                      ,"recfm=n lrecl=1");
                end;
              /* zip */
              when (tDevice in ("ZIP"))
                do;
                  if tExists then putlog "INFO: Overwriting member: " package +(-1) ".zip inside: " target;
                  tAssigned = filename(tFileRef
                                      ,cats(target)
                                      ,strip(tDevice)
                                      ,"recfm=n lrecl=1 member=" !! quote(cats(package, ".zip")) );
                end;
              /* filesrvc */
              when (tDevice in ("FILESRVC" "SASFSVAM"))
                do;
                  tAssigned = filename(tFileRef
                                      ,/*blank*/ ,strip(tDevice)
                                      ,"recfm=n lrecl=1" 
                                       !! " folderpath=" !! quote(cats(target))
                                       !! " filename="   !! quote(cats(package, ".zip"))
                                      );
                end;
              /* other */
              otherwise 
                do;
                  putlog "ERROR: Unsupported device: " tDevice +(-1) ". Exiting!";
                  GOTO stopForThisPackage1;
                end;
            end;

            if debug then putlog tAssigned= tFileRef= / tDevice=;

            _rc_ = sIter.first(); 
            _rc_ = sIter.prev();
            do while(sIter.next()=0);

              /* If Viya File Service, we need to use:
                 filename('fileref', ,'FILEFSVAM', "<host options>") */
              if xengine = 'SASFSVAM' then do;
                  sFilename = ' ';
                  sHostOptions = "recfm=n lrecl=1"
                                  !! " folderpath=" !! quote(strip(xpath))
                                  !! " filename="   !! quote(cats(package, ".zip"))
                  ;
              end;
                else do;
                    sFilename = cats(strip(xpath), "/", package, ".zip");
                    sHostOptions = "recfm=n lrecl=1";
                end;

              sAssigned = filename(sFileref
                                  ,sFilename
                                  ,xengine
                                  ,sHostOptions);

              if debug then putlog sAssigned= sFileRef= / xengine=;
              leave=0;
              LINK LoopTryCopyFile; /* LINK 1 */
              if leave then leave;
            end;
            sAssigned = filename(sFileRef);
            tAssigned = filename(tFileRef); 

            stopForThisPackage1:
            if 0=leave then putlog "ERROR: Fail to process " package;
          end;
        /*=========================================================================================================*/

        /* copy from some location to PACKAGES */
        /*=========================================================================================================*/
        when(0=sFromPackages AND 1=tFromPackages AND 0=sAssigned) 
          do;
            select;
              /* disk */
              when (sDevice in ("DISK" "BASE"))
                do;
                  if NOT sExists then GOTO stopForThisPackage2;
                  sAssigned = filename(sFileRef
                                      ,cats(source, "/", package, ".zip")
                                      ,strip(sDevice)
                                      ,"recfm=n lrecl=1");
                end;
              /* zip */
              when (sDevice in ("ZIP"))
                do;
                  sAssigned = filename(sFileRef
                                      ,cats(source)
                                      ,strip(sDevice)
                                      ,"recfm=n lrecl=1 member=" !! quote(cats(package, ".zip")) );
                end;
              /* filesrvc */
              when (sDevice in ("FILESRVC" "SASFSVAM"))
                do;
                  sAssigned = filename(sFileRef
                                      ,/*blank*/ ,strip(sDevice)
                                      ,"recfm=n lrecl=1" 
                                       !! " folderpath=" !! quote(cats(source))
                                       !! " filename="   !! quote(cats(package, ".zip"))
                                      );
                end;
              /* other */
              otherwise 
                do;
                  putlog "ERROR: Unsupported device: " sDevice +(-1) ". Exiting!";
                  GOTO stopForThisPackage2;
                end;
            end;

            if debug then putlog sAssigned= sFileRef= / sDevice=;

            if NOT fexist(sFileRef) then 
              do;
                putlog "WARNING: File: " package +(-1) ".zip does NOT exist inside: " source;
              end;
            else
              do;
                _rc_ = tIter.first(); 
                _rc_ = tIter.prev();
                do while(tIter.next()=0);

                    /* If Viya File Service, we need to use:
                        filename('fileref', ,'FILEFSVAM', "<host options>") */
                    if xengine = 'SASFSVAM' then do;
                        tFilename = ' ';
                        tHostOptions = "recfm=n lrecl=1"
                                        !! " folderpath=" !! quote(strip(xpath))
                                        !! " filename="   !! quote(cats(package, ".zip"))
                        ;
                    end;
                        else do;
                            tFilename = cats(strip(xpath), "/", package, ".zip");
                            tHostOptions = "recfm=n lrecl=1";
                        end;

                    tAssigned = filename(tFileRef
                                        ,tFilename
                                        ,xengine
                                        ,tHostOptions);
                                      
                  if debug then putlog tAssigned= tFileRef= / xengine=;
                  leave=0;
                  LINK LoopTryCopyFile; /* LINK 1 */
                  if leave then leave;
                end;
                tAssigned = filename(tFileRef); 
              end;

            sAssigned = filename(sFileRef);
            stopForThisPackage2:
            if 0=leave then putlog "ERROR: Fail to process " package;
          end;
        /*=========================================================================================================*/
        /**
          when(0) do; put "future cases"; end; 
        **/
        otherwise putlog "WARNING: Unknown combination.";
      end; 
    end;

  LINK stopProcessing;
  /** the end **/
  STOP;

  /* LINK 1 */
  loopTryCopyFile:
    do try = 1 to &try. while(leave=0);

    length s_HASHING t_HASHING $ 128;

    %if &checksum. AND &HASHING_FILE_exist. %then
      %do;
        if try = 1 AND fexist(tFileRef) then /* check SHA256 only for first try */
          do;
            LINK GETSHA256DIGEST; /* LINK 2 */

            if s_HASHING=t_HASHING then 
              do;
                putlog "INFO: The SHA256 hash digest for source and target are identical."
                     / @7 "Checksum: " t_HASHING
                     / @7 "Package will not be copied.";
                _rc_ = 0;
              end;
            else
              do; /* message only for the first time */
                putlog "INFO: The SHA256 hash digest for source and target are different."
                     / @7 "Target checksum: " t_HASHING
                     / @7 "Source checksum: " s_HASHING
                     / @7 "Copying package.";
                _rc_    = fcopy(sFileRef, tFileRef);
                _rcTxt_ = sysmsg();
              end;
          end; 
        else /* keep this ELSE unclosed for... */
      %end;
      
      do; /* ... this DO-END block  */
        _rc_    = fcopy(sFileRef, tFileRef);
        _rcTxt_ = sysmsg();
      end;

      if debug then putlog _rc_= / _rcTxt_=;
      leave + (_rc_=0)*fexist(tFileRef);

      %if &HASHING_FILE_exist. = 1 %then
        %do;
          if leave then /* compare SHA256 after copy */
            do;
              LINK GETSHA256DIGEST; /* LINK 2 */

              if NOT (s_HASHING=t_HASHING) then 
                putlog "WARNING: The SHA256 hash digest is different for source and target!" 
                     / "WARNING- Source is: " s_HASHING 
                     / "WARNING- Target is: " t_HASHING
                     / "WARNING- There could be errors during copying. Check your files.";
              %if %superq(ods) NE %then %do; output %scan(&ods.,1,()) ; %end;
            end;
        %end;

      if (leave AND move) then 
        do;
          _rc_ = fdelete(sFileRef);
          if _rc_ then putlog "WARNING: Target successfully copied, but cannot delete source file while moving.";
        end;
      if not leave then _rc_ = sleep(1,0.25);
    end;
  return;

  /* LINK 2 */
  GETSHA256DIGEST:
    %let ST_list=t s; /* for source(s) and for target(t), repeat the same structure twice with different prefix */
    %do i=1 %to 2;
      %let st=%scan(&ST_list., &i.);
      select;
        when (&st.Device in ("ZIP")) &st._HASHING=HASHING_FILE("SHA256", &st.FileRef, 4);
        when (&st.Device in ("DISK" "BASE")) &st._HASHING=HASHING_FILE("SHA256", pathname(&st.FileRef,'F'), 0);
        otherwise /* for FILESRVC and SASFSVAM*/
          do;
             &st._sha256 = hashing_init("SHA256");  
             &st._FID = fopen(&st.FileRef, "i", 1, "B"); /* read only in binary format */
             if &st._FID then do while(fread(&st._FID)=0);
               length &st.c $ 1;
               _rc_ = fget(&st._FID, &st.c, 1);
               _rc_ = hashing_part(&st._sha256, &st.c);
             end;
             &st._FID = fclose(&st._FID);
             &st._HASHING = hashing_term(&st._sha256);
          end;
      end;
    %end;
  return;

  /* LINK 3 */
  stopProcessing:
    putlog 52*"*" 24*"=" 52*"*";
    stop;
  return;

  run;

  /* restore optionos */
  options ls = &ls_tmp. ps = &ps_tmp. 
          &notes_tmp. &source_tmp. 
          &stimer_tmp. &fullstimer_tmp.
          msglevel=&msglevel_tmp. &mautocomploc_tmp.;

%ENDofrelocatePackage:
%mend relocatePackage;

/* tests on Viya:

filename PACKAGES list; 

%let user= <...>; 

filename backup filesrvc
  folderpath="/Users/&user./My Folder/SASPACKAGES";
filename backup list;

%put %sysfunc(pathname(backup));

data _null_;
  x=getoption("SERVICESBASEURL");
  put x=;
run;

options ls = 90;
%* move from PACKAGES to a FILESRVC location*;
%relocatePackage(baseplus SQLinDS macroarray
,target=/Users/&user./My Folder/SASPACKAGES
,tDevice=FILESRVC
,move=1) 

%* move back to PACKAGES from a FILESRVC location*;
%relocatePackage(baseplus SQLinDS macroarray
,source=/Users/&user./My Folder/SASPACKAGES
,sDevice=FILESRVC
,move=1) 

%* create a ZIP bundle with packages in HOME *;
%relocatePackage(baseplus SQLinDS macroarray
,target=~/SASPACKAGESbundle.zip
,tDevice=ZIP) 
*/
/* SERVICESBASEURL */

/* Tests on SAS:

options mprint msglevel=N;

filename PACKAGES ("R:\" "C:\SAS_WORK\SAS_PACKAGES");

%relocatePackage(myPackage)

options nomprint msglevel=N;
%relocatePackage(baseplus SQLinDS macroarray, target=R:\abc, debug=1)
%relocatePackage(baseplus SQLinDS macroarray, target=R:\noDir)
%relocatePackage(baseplus SQLinDS macroarray, target=R:\bundle.zip, tDevice=zip)
%relocatePackage(baseplus SQLinDS macroarray, target=R:\, tDevice=FILESRVC) 

filename PACKAGES ("R:\testPackages1_NOT_EXIST" "R:\testPackages2_NOT_EXIST");
%relocatePackage(baseplus SQLinDS macroarray abc, source=R:\abc, debug=1, move=1)

filename PACKAGES ("R:\testPackages1" "R:\testPackages2");
%relocatePackage(baseplus SQLinDS macroarray abc, source=R:\abc, debug=1, move=1)
%relocatePackage(baseplus SQLinDS macroarray, source=R:\noDir, debug=1)

filename PACKAGES ("R:\testPackages2" "R:\testPackages1");
%relocatePackage(baseplus SQLinDS macroarray, source=R:\bundle.zip, sDevice=zip, move=1)
%relocatePackage(baseplus SQLinDS macroarray, source=R:\, sDevice=FILESRVC) 
%relocatePackage(baseplus SQLinDS macroarray, source=R:\bundle.zip, sDevice=zip, target=R:\bundle)
*/
/*%macro _();%mend _;*/
/**/

/*+isPackagesFilerefOK+*/
/*** HELP START ***/
%macro isPackagesFilerefOK(
vERRb /* indicates if macro should be verbose and report errors */
)
/ minoperator PARMBUFF
des = 'Macro to check if the PACKAGES fileref is "correct", type %isPackagesFilerefOK(HELP) for help, version 20260126.'
;
/*** HELP END ***/
%if %QUPCASE(&SYSPBUFF.) = %str(%(HELP%)) %then
  %do;
    %local options_tmp ;
    %let options_tmp = ls=%sysfunc(getoption(ls)) ps=%sysfunc(getoption(ps))
     %sysfunc(getoption(notes)) %sysfunc(getoption(source))
     msglevel=%sysfunc(getoption(msglevel))
    ;
    options NOnotes NOsource ls=MAX ps=MAX msglevel=N;
    %put ;
    %put ###########################################################################################;
    %put ###       This is short help information for the `isPackagesFilerefOK` macro              #;
    %put #-----------------------------------------------------------------------------------------#;;
    %put #                                                                                         #;
    %put # Macro to check if the `packages` fileref is "correct", version `20260126`               #;
    %put #                                                                                         #;
    %put # A SAS package is a zip file containing a group                                          #;
    %put # of SAS codes (macros, functions, data steps generating                                  #;
    %put # data, etc.) wrapped up together and embedded inside the zip.                            #;
    %put #                                                                                         #;
    %put # The `%nrstr(%%isPackagesFilerefOK())` macro checks if the `packages` fileref                     #;
    %put # is correct, i.e. all listed directories exist, are accessible (can be open), and        #;
    %put # are assigned with the DISK device.                                                      #;
    %put #                                                                                         #;
    %put # The Macro works as a macro function. It returns `1` wher everything is ok, and          #;
    %put # it returns `0` if at least one issue exists.                                            #;
    %put #                                                                                         #;
    %put #### Parameters:                                                                          #;
    %put #                                                                                         #;
    %put # 1. `vERRb`  - *Optional* Indicates if the macro should return value AND be verbose      #;
    %put #               (e.g., print errors and notes) or just return value.                      #;
    %put #                                                                                         #;
    %put # When used as: `%nrstr(%%isPackagesFilerefOK(HELP))` it displays this help information.           #;
    %put #                                                                                         #;
    %put #-----------------------------------------------------------------------------------------#;
    %put #                                                                                         #;
    %put # Visit: `https://github.com/yabwon/SAS_PACKAGES/tree/main/SPF/Documentation`             #;
    %put # to learn more.                                                                          #;
    %put # Tutorials available at: `https://github.com/yabwon/HoW-SASPackages`                     #;
    %put #                                                                                         #;
    %put #### Example ##############################################################################;
    %put #                                                                                         #;
    %put #   Enabling the SAS Package Framework from the local                                     #;
    %put #   directory, expanding PACKAGES fileref, and checking                                   #;
    %put #   if the new one is still correct for installing new package.                           #;
    %put #                                                                                         #;
    %put #   Assume that the `SPFinit.sas` file                                                    #;
    %put #   is located in the "/sas/PACKAGES/" directory.                                         #;
    %put #                                                                                         #;
    %put #   Run the following code in your SAS session:                                           #;
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas;
    %put  %nrstr( filename packages "/sas/PACKAGES";                        %%* set packages filename;);
    %put  %nrstr( %%include packages(SPFinit.sas);                           %%* enable the framework;);
    %put  ;
    %put  %nrstr( filename packages ("~/myPCKGs" %%extendPackagesFileref()); %%* add new directory;   );
    %put  ;
    %put  %nrstr( %if %%IsPackagesFilerefOK() %%then                          %%* check fileref;      );
    %put  %nrstr(   %%do; %%InstallPackage(SQLinDS) %%end;                     %%* install SQLinDS;   );
    %put  ;
    %put  %nrstr( %%listPackages()                                           %%* list packages;       );
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
    %put ###########################################################################################;
    %put ;
    options &options_tmp.;
    %GOTO ENDofIsPackagesFilerefOK;
  %end;

%if NOT (%superq(vERRb) in (0 1)) %then %let vERRb = 0;

%local isPackagesFilerefOK;
%let isPackagesFilerefOK=1;

%local dsid rc nobs i XENGINE XPATH dirid _F_;
%let dsid = %sysfunc(OPEN(sashelp.vextfl(where=(fileref="PACKAGES"))));
%let nobs = %sysfunc(ATTRN(&dsid., nlobsf));
/*%put &=dsid. &=nobs.;*/

%if &nobs. AND 1=&vERRb. %then %put INFO: PACKAGES fileref is: %sysfunc(pathname(PACKAGES));

%let isPackagesFilerefOK=%sysevalf(&nobs. AND 1, boolean);           

%do i = 1 %to &nobs.;
    %let rc=%sysfunc(FETCHOBS(&dsid., &i.));
    %let XENGINE=%sysfunc(GETVARC(&dsid., %sysfunc(VARNUM(&dsid., XENGINE))));
    %let XPATH=%sysfunc(GETVARC(&dsid., %sysfunc(VARNUM(&dsid., XPATH))));

    %put %superq(XENGINE) %superq(XPATH);
    %if DISK ne %superq(XENGINE) %then 
      %do;
        %let isPackagesFilerefOK=0;
        %if 1=&vERRb. %then
          %do;
            %if %superq(XENGINE) = SASFSVAM %then %let XENGINE= FILESRVC (SASFSVAM);
            %put ERROR: The %superq(XENGINE) is illegal! Only the DISK device is correct.;
          %end;
      %end;
    %else %if 0=%sysfunc(fileexist(%superq(XPATH))) %then 
      %do;
        %let isPackagesFilerefOK=0;
        %if 1=&vERRb. %then
          %do;
            %put ERROR: Path: %superq(XPATH) does NOT exist!;
          %end;
      %end;
    %else
      %do;
        %let rc = %sysfunc(FILENAME(_F_, %superq(XPATH)));
        %let dirid = %sysfunc(DOPEN(&_F_.));
        %let isPackagesFilerefOK=%sysevalf(&dirid. AND 1, boolean);
        %let dirid = %sysfunc(DCLOSE(&dirid.));
        %let rc = %sysfunc(FILENAME(_F_));
        %if 1=&vERRb. AND 0=&isPackagesFilerefOK. %then
          %do;
            %put ERROR: Path: %superq(XPATH) cannot be open!;
            %put ERROR- It may not be a directory or your access rights are insuficient.;
          %end;
      %end;
%end;

%let dsid = %sysfunc(CLOSE(&dsid.));

%if 1=&vERRb. %then
  %do;
    %if &isPackagesFilerefOK.=1 %then
      %do;
        %put %str( );
        %put INFO: The PACKAGES fileref is OK. Enjoy!;
        %put %str( );
      %end;
    %else
      %do;
        %put %str( );
        %put ERROR: The PACKAGES fileref is incorrect!;
        %put %str( );
      %end;
  %end;
/* result */
%do;&isPackagesFilerefOK.%return;%end;
%ENDofIsPackagesFilerefOK:
%mend isPackagesFilerefOK;

/*+SasPackagesFrameworkNotes+*/
%macro SasPackagesFrameworkNotes(
SPFmacroName /* space separated list of names */
)
/
minoperator 
secure
des = 'Macro to provide help notes about SAS Packages Framework macros, version 20260126. Run %SasPackagesFrameworkNotes(HELP) for help info.'
;
%local list N i element;
%let list=
installPackage
listPackages
/**/
verifyPackage
previewPackage
helpPackage
/**/
loadPackage
loadPackageS
loadPackageAddCnt
/**/
unloadPackage
/**/
generatePackage
splitCodeForPackage
/**/
extendPackagesFileref
relocatePackage
isPackagesFilerefOK
bundlePackages
unbundlePackages
/**/
SasPackagesFrameworkNotes
;
%let N = %sysfunc(countw(&list.));

%let SPFmacroName = %sysfunc(compress(%superq(SPFmacroName),_ *,KAD));

%if (%qupcase(&SPFmacroName.) = HELP) %then
  %do;
    %local options_tmp ;
    %let options_tmp = ls=%sysfunc(getoption(ls)) ps=%sysfunc(getoption(ps))
     %sysfunc(getoption(notes)) %sysfunc(getoption(source))
     msglevel=%sysfunc(getoption(msglevel)) 
     %sysfunc(getoption(mprint)) %sysfunc(getoption(mlogic)) %sysfunc(getoption(symbolgen))
    ;
    options NOnotes NOsource ls=MAX ps=MAX msglevel=N NOmprint NOmlogic NOsymbolgen;
    %put ;
    %put #################################################################################;
    %put ###   This is short help information for the `SasPackagesFrameworkNotes` macro  #;
    %put #-------------------------------------------------------------------------------#;
    %put #                                                                               #;
    %put # Macro prints help notes for SAS Packages Framework macros, version `20260126` #;
    %put #                                                                               #;
    %put # A SAS package is a zip file containing a group                                #;
    %put # of SAS codes (macros, functions, data steps generating                        #;
    %put # data, etc.) wrapped up together and included by                               #;
    %put # a single `load.sas` file (also embedded inside the zip).                      #;
    %put #                                                                               #;
    %put # The `%nrstr(%%SasPackagesFrameworkNotes())` macro provides help notes about            #;
    %put # components of the SAS Packages Framework.                                     #;
    %put #                                                                               #;
    %put #-------------------------------------------------------------------------------#;
    %put #### Parameters:                                                                #;
    %put #                                                                               #;
    %put # 1. `SPFmacroName`     *Required.* Names of a SPF components.                  #;
    %put #                       Names should be space separated, asterisk(*) is         #;
    %put #                       allowed too. In such case ALL help notes are printed    #;
    %put #                       If equal `HELP` displays this help information.         #;
    %put #                       If empty displays list of SPF macros.                   #;
    %put #                                                                               #;
    %put #-------------------------------------------------------------------------------#;
    %put #                                                                               #;
    %put # Visit: `https://github.com/yabwon/SAS_PACKAGES/tree/main/SPF/Documentation`   #;
    %put # to learn more.                                                                #;
    %put # Tutorials available at: `https://github.com/yabwon/HoW-SASPackages`           #;
    %put #                                                                               #;
    %put ### Example 1 ###################################################################;
    %put #                                                                               #;
    %put #   Run the following code to print all SPF help notes:                         #;
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas;
    %put  %nrstr( %%SasPackagesFrameworkNotes(*)       %%* print ALL notes;               );
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
    %put #                                                                               #;
    %put ### Example 2 ###################################################################;
    %put #                                                                               #;
    %put #   Run the following code to list all SPF macros:                              #;
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas;
    %put  %nrstr( %%SasPackagesFrameworkNotes()        %%* list all macro names;          );
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
    %put #                                                                               #;
    %put ### Example 3 ###################################################################;
    %put #                                                                               #;
    %put #   Run the following code to print help notes:                                 #;
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas;
    %put  %nrstr( %%SasPackagesFrameworkNotes(generatePackage helpPackage)                );
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
    %put #                                                                               #;
    %put #################################################################################;
    %put ;
    options &options_tmp.;
    %GOTO ENDofSPFNotes;
  %end;

%if %sysevalf(%superq(SPFmacroName)=,boolean) %then
  %do;
    %put ================================================================;
    %put %str( ) SAS Packages Framework provides the following macros:;
    %put ================================================================;
    %do i = 1 %to &N.;
      %let element = %scan(&list., &i.);
      %if &i. IN (3 6 9 10 12) %then %put %str( );
      %if &i. > 9 %then %put %str( )&i.. %NRSTR(%%)&element.();
                  %else %put %str(  )&i.. %NRSTR(%%)&element.();
    %end;
    %put =================================================================;
  %end;
%else %if %str(*) IN (%superq(SPFmacroName)) %then
  %do;
    %do i = 1 %to &N.;
      %let element = %scan(&list., &i.);
      %put %str( );
      %put ======;
      %&element.(HELP)
      %put ======;
    %end;
  %end;
%else
  %do;
    %let N = %sysfunc(countw(%superq(SPFmacroName)));
    %do i = 1 %to &N.;
      %let element = %qupcase(%scan(%superq(SPFmacroName), &i.));
      %if %superq(element) in (%upcase(&LIST.)) %then
        %do;
          %let element = %unquote(&element.);
          %put %str( );
          %put ======;
          %&element.(HELP);
          %put ======;
        %end;
      %else 
        %do;
          %put %str( );
          %put ***!***!***!***!***!***!***!***!***!***!***!***!***!***!***!***!***!***!***!***;
          %put WARNING: Cannot recognise name: %superq(element).;
          %put WARNING- Valid values are: %superq(list);
          %put ***!***!***!***!***!***!***!***!***!***!***!***!***!***!***!***!***!***!***!***;
        %end;
    %end;
  %end;

%ENDofSPFNotes:
%mend SasPackagesFrameworkNotes;

/*
%SasPackagesFrameworkNotes()
%SasPackagesFrameworkNotes(HELP)
options mlogic symbolgen;
%SasPackagesFrameworkNotes(generatePackage)
%SasPackagesFrameworkNotes(generatePackage helpPackage)
%SasPackagesFrameworkNotes(generatePackage helpPackages SasPackagesFrameworkNotes isPackagesFilerefOK)
%SasPackagesFrameworkNotes(*)
*/


/*+bundlePackages+*/
%macro bundlePackages(
 bundleName
,path=
,pathRef=
,packagesList=
,packagesPath=
,packagesRef=packages
,ods= /* data set for report file */
)/
des='Macro to create a bundle of SAS packages, version 20260126. Run %bundlePackages(HELP) for help info.'
secure minoperator
;

%if /*(%superq(bundleName) = ) OR*/ (%qupcase(&bundleName.) = HELP) %then
  %do;
    %local options_tmp ;
    %let options_tmp = ls=%sysfunc(getoption(ls)) ps=%sysfunc(getoption(ps))
     %sysfunc(getoption(notes)) %sysfunc(getoption(source))
     msglevel=%sysfunc(getoption(msglevel))
    ;
    options NOnotes NOsource ls=MAX ps=MAX msglevel=N;
    %put ;
    %put #################################################################################;
    %put ###      This is short help information for the `bundlePackages` macro          #;
    %put #-------------------------------------------------------------------------------#;
    %put #                                                                               #;
    %put # Macro to *create bundles* of SAS packages, version `20260126`                 #;
    %put #                                                                               #;
    %put # A SAS package is a zip file containing a group                                #;
    %put # of SAS codes (macros, functions, data steps generating                        #;
    %put # data, etc.) wrapped up together and included by                               #;
    %put # a single `load.sas` file (also embedded inside the zip).                      #;
    %put #                                                                               #;
    %put # The `%nrstr(%%bundlePackages())` macro allows to bundle a bunch of SAS packages        #;
    %put # into a single file (a SAS packages bundle), just like a snapshot.             #;
    %put #                                                                               #;
    %put #-------------------------------------------------------------------------------#;
    %put #### Parameters:                                                                #;
    %put #                                                                               #;
    %put # 1. `bundleName`       *Required.* Name of a bundle, e.g. myBundle,            #;
    %put #                       if the value is empty a default name is generated:      #;
    %put #                       `saspackagesbundle_createdYYYYMMDDtHHMMSS`, an          #;
    %put #                       extension `.bundle.zip` is automatically added.         #;
    %put #                       For value `HELP` this help information is displayed.    #;
    %put #                                                                               #;
    %put # - `path=`             *Required.* Location of the bundle. Must be a valid     #;
    %put #                       directory. Takes precedence over `pathRef` parameter.   #;
    %put #                       Either `path=` or `pathRef=` must be non-empty.         #;
    %put #                                                                               #;
    %put # - `pathRef=`          *Optional.* Fileref to location of the bundle.          #;
    %put #                       Either `path=` or `pathRef=` must be non-empty.         #;
    %put #                                                                               #;
    %put # - `packagesList=`     *Optional.* A space-separated list of packages          #;
    %put #                       to bundle. If the value is empty all available          #;
    %put #                       packages are used.                                      #;
    %put #                                                                               #;
    %put # - `packagesPath=`     *Optional.* Location of packages for the bundle.        #;
    %put #                       Takes precedence over `packagesRef` parameter.          #;
    %put #                       When non-empty, must be a valid directory.              #;
    %put #                                                                               #;
    %put # - `packagesRef=`      *Optional.* Fileref to location of packages for the     #;
    %put #                       bundle. Default value is `packages`.                    #;
    %put #                                                                               #;
    %put # - `ods=`              *Optional.* Name of SAS data set for the report.        #;
    %put #                                                                               #;
    %put #-------------------------------------------------------------------------------#;
    %put #                                                                               #;
    %put # Visit: `https://github.com/yabwon/SAS_PACKAGES/tree/main/SPF/Documentation`   #;
    %put # to learn more.                                                                #;
    %put # Tutorials available at: `https://github.com/yabwon/HoW-SASPackages`           #;
    %put #                                                                               #;
    %put ### Example 1 ###################################################################;
    %put #                                                                               #;
    %put #   Enabling the SAS Package Framework                                          #;
    %put #   from the local directory and create a bundle of                             #;
    %put #   selected packages in user home directory.                                   #;
    %put #                                                                               #;
    %put #   Assume that the `SPFinit.sas` file                                          #;
    %put #   is located in the "/sas/PACKAGES/" folder.                                  #;
    %put #                                                                               #;
    %put #   Run the following code in your SAS session:                                 #;
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas;
    %put  %nrstr( filename packages "/sas/PACKAGES/";  %%* setup a directory for packages;);
    %put  %nrstr( %%include packages(SPFinit.sas);      %%* enable the framework;         );
    %put  ;
    %put  %nrstr( %%bundlePackages%(myLittleBundle                                        );
    %put  %nrstr(                ,path=/home/user/bundles                                 );
    %put  %nrstr(                ,packagesList=basePlus SQLinDS macroarray                );
    %put  %nrstr(                ,packagesRef=PACKAGES%)                                  );
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
    %put #                                                                               #;
    %put #################################################################################;
    %put ;
    options &options_tmp.;
    %GOTO ENDofbundlePackages;
  %end;
  /* local variables for options */
  %local ls_tmp ps_tmp notes_tmp source_tmp stimer_tmp fullstimer_tmp msglevel_tmp mautocomploc_tmp;
  %let ls_tmp         = %sysfunc(getoption(ls));
  %let ps_tmp         = %sysfunc(getoption(ps));
  %let notes_tmp      = %sysfunc(getoption(notes));
  %let source_tmp     = %sysfunc(getoption(source));
  %let stimer_tmp     = %sysfunc(getoption(stimer));
  %let fullstimer_tmp = %sysfunc(getoption(fullstimer));
  %let msglevel_tmp   = %sysfunc(getoption(msglevel));
  %let mautocomploc_tmp = %sysfunc(getoption(mautocomploc));

  options NOnotes NOsource ls=128 ps=MAX NOfullstimer NOstimer msglevel=N NOmautocomploc;
/*===================================================================================================*/

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

%local reportFile datetime;
%let datetime = %sysfunc(datetime());
%let reportFile = WORK.tmpbundlefile%sysfunc(int(&datetime.), b8601dt15.)_;

data _null_ %if %superq(ods) NE %then %do; &ods. %end;
                                %else %do; &reportFile.1  %end;
;
datetime=symgetn('datetime');

length packagesList $ 32767 bundleName $ 128;
packagesList = lowcase(compress(symget('packagesList'),"_ ","KAD")); /* keep only "proper" packages names */
bundleName = compress(symget('bundleName'),"_","KAD"); /* bundle name is letters, digits, and underscore, up to 128 symbols */

if bundleName NE symget('bundleName') then /* warn about illegal characters */
  do;
    put "WARNING: Bundle name has illegal characters, name will be modified."; 
  end;
if " "=bundleName then bundleName=cats("SASPackagesBundle_created", put(datetime,b8601dt.));

bundleName=lowcase(bundleName); 
put / "INFO: Bundle name is: " bundleName / ;

length packagesPath $ 32767 packagesRef $ 8;
packagesPath = dequote(symget('packagesPath'));
packagesRef = upcase(strip(symget('packagesRef')));

/* organize source path (location of packages) */
if " "=packagesPath then
  do;
    if 0 then set SASHELP.VEXTFL(keep=level xpath xengine fileref exists);
    DECLARE HASH sH(dataset:'SASHELP.VEXTFL(where=(fileref=' !! quote(packagesRef) !! '))', ordered: "A");
    sH.DefineKey("level");
    sH.DefineData("xpath","xengine","exists");
    sH.DefineDone();
    DECLARE HITER sI("sH");

    if sH.NUM_ITEMS=0 then
      do;
        put "ERROR: Fileref in packagesRef= does NOT exist. Exiting!";
        stop;
      end;

    packagesPath=" ";

    if 1=sH.NUM_ITEMS then
      do;
        rc = sH.FIND(key:0);
        if xengine = "DISK" AND exists='yes' then
          packagesPath=quote(strip(xpath)); /* add quotes to the packagesPath */
        else
          put "WARNING: Path: " xpath "in packagesRef= is invalid! Path ignored!";
      end;
    else
      do i = 1 to sum(sH.NUM_ITEMS,0);
        rc = sH.FIND(key:i);
        if exists='no' 
          then put "WARNING: Path: " xpath "in packagesRef= does NOT exist! Path ignored!"; 
        else if xengine NE "DISK" 
          then put "WARNING: Engine in packagesRef= is not DISK! Path ignored!";
        else packagesPath = catx(" ", packagesPath, quote(strip(xpath))); /* add quotes to the packagesPath */
      end;

    if " "=packagesPath then
      do; 
        put "ERROR: Invalid directory in packagesRef=. Exiting!"; 
        stop; 
      end;

     if 1 < sH.NUM_ITEMS then packagesPath = cats("(", packagesPath, ')'); /* add brackets for multi-level path */

  end;
else
  do;
    rcPckPath = fileexist(strip(packagesPath));
    if 0=rcPckPath then
      do;
        put "ERROR: Path in packagesPath= does NOT exist. Exiting!";
        stop;
      end;
    else packagesPath=quote(strip(packagesPath)); /* add quotes to the packagesPath */
  end;

length path $ 32767 pathRef $ 8;
path = dequote(symget('path'));
pathRef = upcase(strip(symget('pathRef')));

if " "=path and " "=pathRef then
  do;
    put "ERROR: Path= and pathRef= are empty! Exiting!";
    stop;
  end;

/* verify target path (location of bundle) */
if " "=path then
  do;
    DECLARE HASH tH(dataset:'SASHELP.VEXTFL(where=(fileref=' !! quote(pathRef) !! '))', ordered: "A");
    tH.DefineKey("level");
    tH.DefineData("xpath","xengine","exists");
    tH.DefineDone();
    DECLARE HITER tI("tH");
  
    if tH.NUM_ITEMS=0 then
      do;
        put "ERROR: Fileref in pathRef= does NOT exist. Exiting!";
        stop;
      end;
    rc = tI.first();
    if exists='no' then
      do;
        put "ERROR: Fileref in pathRef= does NOT exist. Exiting!";
        stop;
      end;

    path = strip(xpath);
  end;
else
  do;
    rcPath = fileexist(strip(path));
    if 0=rcPath then
      do;
        put "ERROR: Path in Path= does NOT exist. Exiting!";
        stop;
      end;
  end;

/* get the list of packages to bundle, don't worry if list is empty */
length pckNm pckVer pckDtm $ 24;
DECLARE HASH P(ordered:"A");
P.defineKey("pckNm");
P.defineDone();
DECLARE HASH Q(ordered:"A");
Q.defineKey("pckNm");
Q.defineData("pckNm",'pckVer','pckDtm');
Q.defineDone();
DECLARE HITER IQ("Q");
if " " NE packagesList then
  do k=1 to countw(packagesList, " ");
    pckNm = strip(scan(packagesList,k, " "));
    rc = P.replace();
  end;
packagesList = " ";

/* select all packages from source and intersect them with the list in packagesList ... */
put "INFO: List of packages available for bundle: ";
do k = 1 to kcountw(packagesPath, "()", "QS");
  length base $ 1024;
  base = dequote(kscanx(packagesPath, k, "()", "QS"));

  length folder $ 64 file $ 1024 folderRef fileRef packageMetadata $ 8;

  rc=filename(folderRef, base);
  folderid=dopen(folderRef);

  do i=1 to dnum(folderId);
    folder = dread(folderId, i);

    rc = filename(fileRef, catx("/", base, folder));
    fileId = dopen(fileRef);

    EOF = 0;
    if fileId = 0 and lowcase(kscanx(folder, -1, ".")) = 'zip' then 
      do;
        file = catx('/',base, folder);
        
        rc1 = filename(packageMetadata, strip(file), 'zip', 'member="packagemetadata.sas"');
        rcE = fexist(packageMetadata); 
        rc2 = filename(packageMetadata);

        if rcE then /* if the packagemetadata.sas exists in the zip then check if package is on the list */
          do;
            pckNm = strip(scan(folder,1,"."));

            if (0 = P.NUM_ITEMS) OR (0=P.find()) then 
              do; 
                pckVer='_._._';
                pckDtm="____-__-__T__:__:__";
                /*--------------------------------------------------*/
                infile _DUMMY_ ZIP FILEVAR=file member="packagemetadata.sas" end=EOF;
                do until(EOF);
                  input;
                  /*putlog ">>" _infile_;*/
                  select( lowcase(kscanx(_INFILE_,2,"(,)")) );
                    when ('"packageversion"'  ) pckVer=dequote(strip(kscanx(_INFILE_,3,"(,)")));
                    when ('"packagegenerated"') pckDtm=dequote(strip(kscanx(_INFILE_,3,"(,)")));
                    otherwise; 
                  end;
                end;
                /*--------------------------------------------------*/
                pckVer=coalescec(pckVer,'_._._');
                pckDtm=coalescec(pckDtm,"____-__-__T__:__:__");

                if (pckVer='_._._' OR pckDtm="____-__-__T__:__:__") then
                  do;
                    put "WARNING: Incomplete metadata for package: " pckNm +(-1) "!";
                    rc = -1; /* ignore incomplete packages */
                  end;
                else rc = Q.ADD();

                if 0=rc then put base pckNm=; 
              end;
          end;
      end;
    
    rc = dclose(fileId);
    rc = filename(fileRef);
  end;

  rc = dclose(folderid);
  rc = filename(folderRef);
end;

if 0=Q.NUM_ITEMS then /* ... if empty then exit */
  do;
    put "WARNING: No packages to bundle. Exiting!";
    stop;
  end;
else
  do while(iQ.next()=0);
    packagesList = catx(" ", packagesList, pckNm);
  end;

if 0 < P.NUM_ITEMS NE Q.NUM_ITEMS then
  do;
    put "WARNING: Not all packages listed for bundling were found.";
  end;

rc = Q.output(dataset:"&reportFile.3");

/* code executed for bundling */
length code1 code2 $ 32767;
code1= 
'options ps=min nofullstimer nostimer msglevel=N; filename PACKAGES ' !! strip(packagesPath) !! ';' !!
'%relocatePackage(' !! strip(packagesList) !! ',target=' !! catx("/", path, bundleName) !! 
'.bundle.zip, tDevice=ZIP,psMAX=MIN,ods=&reportFile.2(keep=package sFilename s_HASHING));'; 
code2=
'options noNotes;' !! 
'filename _ ZIP ' !! quote(cats(path, "/", bundleName, ".bundle.zip")) !! ';' !! 
'data _null_;set &reportFile.2;file _(verification.sas);' !! 
'if 1=_N_ then put "/*" 64*"*" / "bundle created: ' !! put(datetime,e8601dt.) !! '" / 64*"*" "*/" /;' !! 
'put ''%verifyPackage('' package +(-1) ",hash=F*" s_HASHING +(-1)")";run;' !! 
'data &reportFile.4;merge &reportFile.2 &reportFile.3(rename=(pckNm=package));' !!
'by package;file _(bundlecontent.sas) dsd;hash="F*"!!s_HASHING; put package pckVer pckDtm hash;run;' !! 
'title1 "Bundle: ' !! strip(bundleName) !! '";' !!
'title2 "Summary of bundling process";' !!  
'proc print data=&reportFile.4 label;' !!
'var package pckVer pckDtm hash sFilename;' !! 
'label package="Package name" pckVer="Version" pckDtm="Generation timestamp" sFilename="Source file location" hash="SHA256 for the Package";' !! 
'proc delete data=&reportFile.2 &reportFile.3 &reportFile.4;run;title;';

/*put code=;*/

put "INFO: The " bundleName "bundle creation in progress...";

rc = doSubL(code1);
rc = doSubL(code2);

put "INFO: The " bundleName "bundle creation ended.";

%if &HASHING_FILE_exist. = 1 %then
  %do;
    rc = filename(fileRef, cats(path, "/", bundleName, ".bundle.zip"), "DISK", "lrecl=1 recfm=n");
    rctxt=sysmsg();
    if rc=0 then BundleSHA256 = "F*" !! HASHING_FILE("SHA256", pathname(fileRef,'F'), 0);
            else put rctxt=;
    put "INFO: SHA256 for the bundle is: " / @7 BundleSHA256;
    rc = filename(fileRef);
  %end;

  
  keep path bundleName BundleSHA256 datetime;
  label path = "Bundle location"
        bundleName = "Bundle name"
        BundleSHA256 = "SHA256 for the Bundle"
        datetime = "Bundle generation timestamp"
      ;
  format datetime e8601dt.;
  output 
    %if %superq(ods) NE %then %do; %scan(&ods.,1,()) %end;
                        %else %do; &reportFile.1     %end;
  ;
put " ";
rc=sleep(1,1); 
stop;
run;

title2 "Summary of the bundle file";;
proc print
  data= %if %superq(ods) NE %then %do; %scan(&ods.,1,()) %end;
                            %else %do; &reportFile.1     %end;
  noObs label;
  var bundleName datetime BundleSHA256 path;
run;
%if %superq(ods) NE %then %do; %put INFO: Report file: %scan(&ods.,1,()); %end;
                    %else %do; proc delete data=&reportFile.1; run; %end;


/*===================================================================================================*/
    /* restore optionos */
  options ls = &ls_tmp. ps = &ps_tmp. 
          &notes_tmp. &source_tmp. 
          &stimer_tmp. &fullstimer_tmp.
          msglevel=&msglevel_tmp. &mautocomploc_tmp.;

%ENDofbundlePackages:
%mend bundlePackages;

/*
filename packages ("C:\SAS_WORK\SAS_PACKAGES" "C:\SAS_PACKAGES_DEV" "R:\");

options mprint ls=64 ps=max;
%bundlePackages(
bundleNameTest123
,path=R:/
,ods=work.summaryofthebundlefile
)

%bundlePackages(
bundleNameTest124
,path=R:/
,packagesList=basePlus SQLinDS macroarray ABCDEF functionsimissinbase
,ods=work.summaryofthebundlefile1
)

data _null_;
  set work.summaryofthebundlefile1;
  call symputX("hashCheck",BundleSHA256);
run;
%verifyPackage(
 bundlenametest124.bundle 
,hash=&hashCheck.
)

%bundlePackages(
bundleNameTest125
,path=R:/dontexist
,packagesList=basePlus SQLinDS macroarray ABCDEF
)

options mprint ls=64 ps=max;
%bundlePackages(
bundleNameTest125
,pathRef=p
,packagesList=basePlus SQLinDS macroarray ABCDEF
)

 bundleNameTest126
,path=R:\
,packagesList=basePlus SQLinDS macroarray ABCDEF
,packagesPath=R:/dontexist
,packagesRef=packages
)

filename p2 "R:/dontexist";
%bundlePackages(
 bundleNameTest127
,path=R:\
,packagesList=basePlus SQLinDS macroarray ABCDEF
,packagesRef=p2
)

%bundlePackages(
 bundleNameTest128
,path=R:\
,packagesList=basePlus SQLinDS macroarray ABCDEF
,packagesPath=R:/nopackages
)

%bundlePackages(
,path=R:/
,ods=work.summaryofthebundlefile
)

%bundlePackages(HELP)

%bundlePackages()
*/


/*+unbundlePackages+*/
%macro unbundlePackages(
 bundleName
,path=
,pathRef=
,packagesPath=
,packagesRef=packages
,ods= /* data set for report file */
,verify=0
)/
des='Macro to extract a bundle of SAS packages, version 20260126. Run %unbundlePackages(HELP) for help info.'
secure
minoperator
;

%if (%superq(bundleName) = ) OR (%qupcase(&bundleName.) = HELP) %then
  %do;
    %local options_tmp ;
    %let options_tmp = ls=%sysfunc(getoption(ls)) ps=%sysfunc(getoption(ps))
     %sysfunc(getoption(notes)) %sysfunc(getoption(source))
     msglevel=%sysfunc(getoption(msglevel))
    ;
    options NOnotes NOsource ls=MAX ps=MAX msglevel=N;
    %put ;
    %put #################################################################################;
    %put ###     This is short help information for the `unbundlePackages` macro         #;
    %put #-------------------------------------------------------------------------------#;
    %put #                                                                               #;
    %put # Macro to *extract* SAS packages from a bundle, version `20260126`             #;
    %put #                                                                               #;
    %put # A SAS package is a zip file containing a group                                #;
    %put # of SAS codes (macros, functions, data steps generating                        #;
    %put # data, etc.) wrapped up together and included by                               #;
    %put # a single `load.sas` file (also embedded inside the zip).                      #;
    %put #                                                                               #;
    %put # The `%nrstr(%%unbundlePackages())` macro allows to extract SAS packages from           #;
    %put # a bundle into a single directory.                                             #;
    %put #                                                                               #;
    %put #-------------------------------------------------------------------------------#;
    %put #### Parameters:                                                                #;
    %put #                                                                               #;
    %put # 1. `bundleName`       *Required.* Name of a bundle, e.g. myBundle,            #;
    %put #                       extension `.bundle.zip` is automatically added.         #;
    %put #                       For empty value or `HELP` this help information         #;
    %put #                       is displayed.                                           #;
    %put #                                                                               #;
    %put # - `path=`             *Required.* Location of the bundle. Must be a valid     #;
    %put #                       directory. Takes precedence over `pathRef` parameter.   #;
    %put #                       Either `path=` or `pathRef=` must be non-empty.         #;
    %put #                                                                               #;
    %put # - `pathRef=`          *Optional.* Fileref to location of the bundle.          #;
    %put #                       Either `path=` or `pathRef=` must be non-empty.         #;
    %put #                                                                               #;
    %put # - `packagesPath=`     *Optional.* Location for packages extracted from        #;
    %put #                       the bundle. Takes precedence over `packagesRef`.        #;
    %put #                       When non-empty, must be a valid directory.              #;
    %put #                                                                               #;
    %put # - `packagesRef=`      *Optional.* Fileref to location where packages will     #;
    %put #                       be extracted. Default value is `packages`.              #;
    %put #                                                                               #;
    %put # - `ods=`              *Optional.* Name of SAS data set for the report.        #;
    %put #                                                                               #;
    %put # - `verify=`           *Optional.* Indicates if verification code should       #;
    %put #                       be executed after bundle extraction.                    #;
    %put #                       Value `1` means yes, Value `0` means no.                #;
    %put #                                                                               #;
    %put #-------------------------------------------------------------------------------#;
    %put #                                                                               #;
    %put # Visit: `https://github.com/yabwon/SAS_PACKAGES/tree/main/SPF/Documentation`   #;
    %put # to learn more.                                                                #;
    %put # Tutorials available at: `https://github.com/yabwon/HoW-SASPackages`           #;
    %put #                                                                               #;
    %put ### Example 1 ###################################################################;
    %put #                                                                               #;
    %put #   Enabling the SAS Package Framework                                          #;
    %put #   from the local directory and extract a bundle of                            #;
    %put #   packages from user home directory to packages.                              #;
    %put #                                                                               #;
    %put #   Assume that the `SPFinit.sas` file                                          #;
    %put #   is located in the "/sas/PACKAGES/" folder.                                  #;
    %put #                                                                               #;
    %put #   Run the following code in your SAS session:                                 #;
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas;
    %put  %nrstr( filename packages "/sas/PACKAGES/";  %%* setup a directory for packages;);
    %put  %nrstr( %%include packages(SPFinit.sas);      %%* enable the framework;         );
    %put  ;
    %put  %nrstr( %%unbundlePackages%(myLittleBundle                                      );
    %put  %nrstr(                  ,path=/home/user/bundles                               );
    %put  %nrstr(                  ,verify=1                                              );
    %put  %nrstr(                  ,packagesRef=PACKAGES%)                                );
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
    %put #                                                                               #;
    %put #################################################################################;
    %put ;
    options &options_tmp.;
    %GOTO ENDofunbundlePackages;
  %end;
  /* local variables for options */
  %local ls_tmp ps_tmp notes_tmp source_tmp stimer_tmp fullstimer_tmp msglevel_tmp mautocomploc_tmp;
  %let ls_tmp         = %sysfunc(getoption(ls));
  %let ps_tmp         = %sysfunc(getoption(ps));
  %let notes_tmp      = %sysfunc(getoption(notes));
  %let source_tmp     = %sysfunc(getoption(source));
  %let stimer_tmp     = %sysfunc(getoption(stimer));
  %let fullstimer_tmp = %sysfunc(getoption(fullstimer));
  %let msglevel_tmp   = %sysfunc(getoption(msglevel));
  %let mautocomploc_tmp = %sysfunc(getoption(mautocomploc));

  options NOnotes NOsource ls=128 ps=MAX NOfullstimer NOstimer msglevel=N NOmautocomploc;
/*===================================================================================================*/

%if NOT(%superq(verify) in (0 1)) %then %let verify=0;

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

%local reportFile datetime;
%let datetime = %sysfunc(datetime());
%let reportFile = WORK.tmpbundlefile%sysfunc(int(&datetime.), b8601dt15.)_;

data _null_ ;
datetime=symgetn('datetime');

length packagesList $ 32767 bundleName $ 128;

bundleName = compress(symget('bundleName'),"_.","KAD"); /* bundle name is letters, digits, and underscore, up to 128 symbols */

if bundleName NE symget('bundleName') then /* warn about illegal characters */
  do;
    put "ERROR: Bundle name contains illegal characters. Exiting";
    stop; 
  end;

bundleName=lowcase(bundleName); 
/* if there is ".bundle.zip" extension added, remove it */
if substr(strip(reverse(bundleName)),1,11) = 'piz.eldnub.' then bundleName=scan(bundleName,-3,".");
else /* if there is ".bundle" extension added, remove it */
if substr(strip(reverse(bundleName)),1,7)  = 'eldnub.'     then bundleName=scan(bundleName,-2,".");

put / "INFO: Bundle name is: " bundleName / ;

length packagesPath $ 32767 packagesRef $ 8;
packagesPath = dequote(symget('packagesPath'));
packagesRef = upcase(strip(symget('packagesRef')));


/* organize target path (location for packages) */
if " "=packagesPath then
  do;
    if 0 then set SASHELP.VEXTFL(keep=level xpath xengine fileref exists);
    DECLARE HASH sH(dataset:'SASHELP.VEXTFL(where=(fileref=' !! quote(packagesRef) !! '))', ordered: "A");
    sH.DefineKey("level");
    sH.DefineData("xpath","xengine","exists");
    sH.DefineDone();

    if sH.NUM_ITEMS=0 then
      do;
        put "ERROR: Fileref in packagesRef= does NOT exist. Exiting!";
        stop;
      end;

    packagesPath=" ";

    rc = sH.FIND(key:NOT(1=sH.NUM_ITEMS)); /* if only 1 element select level 0, if more than 1 select level 1 */
    if xengine = "DISK" AND exists='yes' then
      packagesPath=quote(strip(xpath)); /* add quotes to the packagesPath */
    else
      do;
        put "ERROR: Path: " xpath "in packagesRef= is invalid! Exiting!";
        stop; 
      end;
  end;
else
  do;
    rcPckPath = fileexist(strip(packagesPath));
    if 0=rcPckPath then
      do;
        put "ERROR: Path in packagesPath= does NOT exist. Exiting!";
        stop;
      end;
    else packagesPath=quote(strip(packagesPath)); /* add quotes to the packagesPath */
  end;

length path $ 32767 pathRef $ 8;
path = dequote(symget('path'));
pathRef = upcase(strip(symget('pathRef')));

if " "=path and " "=pathRef then
  do;
    put "ERROR: Path= and pathRef= are empty! Exiting!";
    stop;
  end;

/* verify source path (location of the bundle) */
if " "=path then
  do;
    DECLARE HASH tH(dataset:'SASHELP.VEXTFL(where=(fileref=' !! quote(pathRef) !! '))', ordered: "A");
    tH.DefineKey("level");
    tH.DefineData("xpath","xengine","exists");
    tH.DefineDone();
    DECLARE HITER tI("tH");

    do while (tI.next()=0);
      put "Checking in: " xpath;
      if fileexist(cats(xpath,"/",bundleName,'.bundle.zip')) then 
        do;
          path=strip(xpath);
          put "INFO: Bundle file " bundleName +(-1) ".bundle.zip found under: " xpath;
          leave;
        end;
    end;

    if " "=path then
      do;
        put "ERROR: Bundle: " bundleName "does NOT exist in any directory in pathRef=. Exiting!";
        stop;
      end;
  end;
else
  do;
    rcPath = fileexist(strip(path));
    if 0=rcPath then
      do;
        put "ERROR: Path in Path= does NOT exist. Exiting!";
        stop;
      end;
  end;

/* get the list of packages to unbundle from bundlecontent.sas */
length bundlecontentFR $ 8;
rc1 = filename(bundlecontentFR, cats(path,"/",bundleName,'.bundle.zip'));
rcE = fexist(bundlecontentFR); 
rc2 = filename(bundlecontentFR);

if 0=rcE then
  do;
    put "ERROR: The " bundleName "file does NOT exist!. Exiting!";
    stop;
  end;

length bundlecontentFR $ 8;
rc1 = filename(bundlecontentFR, cats(path,"/",bundleName,'.bundle.zip'), 'zip', 'member="bundlecontent.sas"');
rcE = fexist(bundlecontentFR); 
rc2 = filename(bundlecontentFR);

if 0=rcE then
  do;
    put "ERROR: The bundlecontent.sas file does NOT exist inside bundle. Exiting!";
    stop;
  end;

length bundlecontentfile $ 1024;
bundlecontentfile = cats(path,"/",bundleName,'.bundle.zip');

infile _DUMMY_ ZIP FILEVAR=bundlecontentfile member="bundlecontent.sas" end=EOF dlm=",";

DECLARE HASH Q(ordered:"A");
Q.defineKey("package");
Q.defineData("package",'pckVer','pckDtm','hash');
Q.defineDone();
DECLARE HITER IQ("Q");

/*--------------------------------------------------*/
do until(EOF);
  input package :$32. pckVer :$16. pckDtm :$16. hash :$128.;
  if " " NE package then rc = Q.ADD();
end;
label package="Package name" 
      pckVer="Version" 
      pckDtm="Generation timestamp" 
      hash="SHA256 for the Package"; 
/*--------------------------------------------------*/


if 0=Q.NUM_ITEMS then /* ... if empty then exit */
  do;
    put "WARNING: No packages to unbundle. Exiting!";
    stop;
  end;
else
  do while(iQ.next()=0);
    packagesList = catx(" ", packagesList, package);
  end;

rc = Q.output(dataset:"&reportFile.1");

/* code executed for unbundling */
length code1 code2 $ 32767;
code1= 
'options ps=min nofullstimer nostimer msglevel=N; filename PACKAGES ' !! strip(packagesPath) !! ';' !!
'%relocatePackage(' !! strip(packagesList) !! ',source=' !! catx("/", path, bundleName) !! 
'.bundle.zip, sDevice=ZIP,psMAX=MIN)'; 

/*put code=;*/

put / "INFO: The " bundleName "bundle extraction in progress...";

rc = doSubL(code1);

put / "INFO: The " bundleName "bundle extraction ended.";

/* code executed for verification */
%if 1=&verify. %then
  %do;  
    put / "INFO: The " bundleName "bundle verification in progress...";
    code2= 
    'options ps=min nofullstimer nostimer msglevel=N; filename PACKAGES ' !! strip(packagesPath) !! ';' !!
    'filename _ ZIP ' !! quote(cats(path, "/", bundleName, ".bundle.zip")) !! ';' !! 
    '%include _(verification.sas);%listPackages()';
    rc = doSubL(code2);
    put / "INFO: The " bundleName "bundle verification ended.";
  %end;

put " ";
rc=sleep(1,1); 

rc = doSubL("title 'Summary of the extracted bundle file';" !! 
"proc print data=" !! 
%if %superq(ods) NE %then 
  %do; "%scan(&ods.,1,())" %end; 
%else 
  %do; "&reportFile.1" %end; !! 
" label; var package pckVer pckDtm hash; run;" !!
%if %superq(ods) NE %then 
  %do; %put INFO: Report file: %scan(&ods.,1,()); %end; 
%else 
  %do; "proc delete data=&reportFile.1; run;" %end; !! 
"title;");

stop;
run;
/*===================================================================================================*/
  /* restore optionos */
  options ls = &ls_tmp. ps = &ps_tmp. 
          &notes_tmp. &source_tmp. 
          &stimer_tmp. &fullstimer_tmp.
          msglevel=&msglevel_tmp. &mautocomploc_tmp.;

%ENDofunbundlePackages:
%mend unbundlePackages;

/*
options mprint;
%unbundlePackages(
 bundlenametest123
,path=R:\
,packagesPath=R:\check
,verify=1
)

%unbundlePackages(
 bundlenametest124
,path=R:\
,packagesPath=R:\check2
,verify=1
)

%unbundlePackages(
 bundlenametest124.bundle.zip
,path=R:\
,packagesPath=R:\check3
)

%unbundlePackages(
 bundlenametest124.bundle.zip
,path=R:\
,packagesPath=R:\check4
)

%unbundlePackages()

%unbundlePackages(
 nobundlenametest123
,path=R:\
,packagesPath=R:\check
,verify=1
)

*/

/* end of SPFinit.sas file */ 
