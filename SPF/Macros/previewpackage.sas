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
des = 'Macro to preview content of a SAS package, version 20241129. Run %previewPackage() for help info.'
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
    %put # Macro to get preview of a SAS packages, version `20241129`                    #;
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
  
  %local ls_tmp ps_tmp notes_tmp source_tmp msglevel_tmp mautocomploc_tmp;
  %let ls_tmp       = %sysfunc(getoption(ls));
  %let ps_tmp       = %sysfunc(getoption(ps));
  %let notes_tmp    = %sysfunc(getoption(notes));
  %let source_tmp   = %sysfunc(getoption(source));
  %let msglevel_tmp = %sysfunc(getoption(msglevel));
  %let mautocomploc_tmp = %sysfunc(getoption(mautocomploc));

  options NOnotes NOsource ls=MAX ps=MAX msglevel=N NOmautocomploc;
  
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
  
  options ls = &ls_tmp. ps = &ps_tmp. &notes_tmp. &source_tmp. 
          msglevel = &msglevel_tmp. &mautocomploc_tmp.;
  
%ENDofpreviewPackage:
%mend previewPackage;

