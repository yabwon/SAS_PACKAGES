/*+installPackage+*/
/* Macros to install SAS packages, version 20251122  */
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
des = 'Macro to install SAS package, version 20251122. Run %%installPackage() for help info.'
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
    %put # Macro to install SAS packages, version `20251122`                                          #;
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


