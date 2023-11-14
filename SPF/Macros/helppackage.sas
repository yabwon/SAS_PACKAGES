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
des = 'Macro to get help about SAS package, version 20231111. Run %helpPackage() for help info.'
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
    %put # Macro to get help about SAS packages, version `20231111`                      #;
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

/* Macros to install SAS packages, version 20231111  */
/* A SAS package is a zip file containing a group of files
   with SAS code (macros, functions, data steps generating 
   data, etc.) wrapped up together and %INCLUDEed by
   a single load.sas file (also embedded inside the zip).
*/

