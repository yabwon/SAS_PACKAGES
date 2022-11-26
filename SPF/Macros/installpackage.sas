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
)
/secure
minoperator 
/*** HELP END ***/
des = 'Macro to install SAS package, version 20221125. Run %%installPackage() for help info.'
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
    %put # Macro to install SAS packages, version `20221125`                                          #;
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
        
      put @2 "Done with return code " rc= "(zero = success)";
    run;
     
    filename &in  clear;
    filename &out clear;
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

  Version 20221125 

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

