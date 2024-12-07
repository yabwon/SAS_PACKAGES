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
des = 'Macro to load SAS package, version 20241207. Run %loadPackage() for help info.'
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
    %put # Macro to *load* SAS packages, version `20241207`                              #;
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

  %if %superq(DS2force) NE 1 %then
    %do;
      %let DS2force = 0;
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
        "&path./%lowcase(&packageName.).&zip." %unquote(&options.)
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

