/*+headerPackage+*/
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

  SAS Packages Framework, version 20260615.
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

/*+requestPackage+*/
%macro requestPackage(
 packageName
,requiredVersion=
/* technical parameters passed to installPackage macro */
, sourcePath =  /* location of the package, e.g. "www.some.page/", mind the "/" at the end */
, mirror = 0    /* indicates which location for package source should be used */
, replace = 1   /* 1 = replace if the package already exist, 0 = otherwise */
, backup = 0    /* 1 = before replacing make a copy if the package already exist, 0 = do nothing */
, URLuser =     /* user name for the password protected URLs */
, URLpass =     /* password for the password protected URLs */
, URLoptions =  /* options for the `sourcePath` URLs */
, loadAddCnt=0  /* should the additional content be loaded?
                   default is 0 - means No, 1 means Yes */
, instDoc=0     /* should the markdown file with documentation be installed?
                   default is 0 - means No, 1 means Yes */

, github =      /* name of a user or an organization in GitHub, all characters except [A-z0-9_.-] are compressed */
, githubRepo =  /* repo name to be used, by default it is the package name, but can be altered */
, githubToken = /* user's github fine-grained personal access token */
, githubTokenDebug = 0 /* debug values: 0,1,2,3 */

, loadPackage=1 /* should the packages be loaded after installing */
, force=0       /* force reloading even if already loaded */
, ignoreDepVer=0 /* should dependencies version be ignore so that only the latest could be installed */
, successDS=    /* technical */
)
/secure
des = 'Macro to request SAS package installation and loading, version 20260615. Run %requestPackage(HELP) for help info.'
;

%if (%superq(packageName) = ) OR (%qupcase(&packageName.) = HELP) %then
  %do;
    %local options_tmp ;
    %let options_tmp = ls=%sysfunc(getoption(ls)) ps=%sysfunc(getoption(ps))
     %sysfunc(getoption(notes)) %sysfunc(getoption(source)) %sysfunc(getoption(source2))
     msglevel=%sysfunc(getoption(msglevel))
    ;
    options NOnotes NOsource NOsource2 ls=MAX ps=MAX msglevel=N;
    %put ;
    %put ##############################################################################################;
    %put ###       This is short help information for the `requestPackage` macro                      #;
    %put #--------------------------------------------------------------------------------------------#;;
    %put #                                                                                            #;
    %put # Macro to request (install and load) SAS packages, version `20260615`                       #;
    %put #                                                                                            #;
    %put # A SAS package is a zip file containing a group                                             #;
    %put # of SAS codes (macros, functions, data steps generating                                     #;
    %put # data, etc.) wrapped up together and embedded inside the zip.                               #;
    %put #                                                                                            #;
    %put # The `%nrstr(%%requestPackage())` macro installs and loads the package zip                           #;
    %put # in the packages folder. The process takes care of installing or loading                    #;
    %put # dependencies too.                                                                          #;
    %put #                                                                                            #;
    %put # In case the packages fileref is a multi-directory one the first directory                  #;
    %put # will be selected as a destination.                                                         #;
    %put #                                                                                            #;
    %put #--------------------------------------------------------------------------------------------#;
    %put #                                                                                            #;
    %put #### Parameters:                                                                             #;
    %put #                                                                                            #;
    %put # 1. `packageName `  Name of a package _without_ the zip extension, e.g., myPackage1.        #;
    %put #                    Required and not null, default use case:                                #;
    %put #                    `%nrstr(%%requestPackage(myPackage1))`.                                          #;
    %put #                    If empty displays this help information.                                #;
    %put #                                                                                            #;
    %put #  **Installation options:**                                                                 #;
    %put #                                                                                            #;
    %put # - `requiredVersion=`  *Optional.* Indicates which (at least) package version we want       #;
    %put #                       to be requested, empty value by default means "the latest".          #;
    %put #                       When loaded/installed package version is greater or equal            #;
    %put #                       from requested, lower requested version is not loaded/installed.     #;
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
    %put # - `replace=`      When set to `1` and a package file exists, it forces the package         #;
    %put #                   file replacement by the new downloaded file.                             #;
    %put #                   It is a binary indicator ('0' or '1'). Default value is `1`.             #;
    %put #                                                                                            #;
    %put # - `backup=`       When set to `1` and a package file exists, it creates a backup copy      #;
    %put #                   of the package file. The backup copy is created with a suffix of the     #;
    %put #                   following format: `_BCKP_yyyymmddJJMMSS`.                                #;
    %put #                   If `replace=0` then `backup` is set to `0`.                              #;
    %put #                   It is a binary indicator ('0' or '1'). Default value is `0`.             #;
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
    %put #  - `github=`      *Optional.* A name of a user or an organization in GitHub.               #;
    %put #                   Allows an easy set of the search path for packages available on GitHub:  #;
    %put #                    `https://github.com/<github>/<githubRepo>/raw/.../`                     #;
    %put #                   All characters except `[A-z0-9_.-]` are compressed.                      #;
    %put #                                                                                            #;
    %put #  - `githubRepo=`  *Optional.* A name of a repository in GitHub.                            #;
    %put #                   Allows an easy set of the search path for packages available on GitHub:  #;
    %put #                    `https://github.com/<github>/<githubRepo>/raw/.../`                     #;
    %put #                   By default lowercase name of installed package is used.                  #;
    %put #                                                                                            #;
    %put #  - `githubToken=` *Optional.* A fine-grained personal access token for GitHub.             #;
    %put #                   When the value is non-missing it triggers GitHub API access to           #;
    %put #                   private repositories. Of course the token used has to be configured      #;
    %put #                   properly for the access.                                                 #;
    %put #                   Read GitHub documentation to learn how to create and setup your token:   #;
    %put #                   `https://docs.github.com/en/authentication/                              #;
    %put #                     keeping-your-account-and-data-secure/                                  #;
    %put #                      managing-your-personal-access-tokens                                  #;
    %put #                       #creating-a-fine-grained-personal-access-token`                      #;
    %put #                   (lines break added for easier reading)                                   #;
    %put #                   Public repos do not need authentication.                                 #;
    %put #                   [NOTE!] This feature is experimental in this release.                    #;
    %put #                                                                                            #;
    %put #  **Loading options:**                                                                      #;
    %put #                                                                                            #;
    %put # - `loadPackage=`  *Optional.* Indicates if requested package should be loaded too          #;
    %put #                   or only installed. Dependencies are only installed.                      #;
    %put #                   Default value of zero (`0`) means "No", one (`1`) means "Yes".           #;
    %put #                                                                                            #;
    %put # - `force=`        *Optional.* Indicates if requested package should be reloaded            #;
    %put #                   even if it was already loaded to the session.                            #;
    %put #                   Default value of zero (`0`) means "No", one (`1`) means "Yes".           #;
    %put #                                                                                            #;
    %put # - `ignoreDepVer=` *Optional.* Indicates if packages versions in dependencies list          #;
    %put #                   should be ignored and the latest available version be used.              #;
    %put #                   Default value of zero (`0`) means "No", one (`1`) means "Yes".           #;
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
    %put #   from the local directory and requesting (installing & loading)                           #;
    %put #   the bpUTiL package from the Internet.                                                    #;
    %put #                                                                                            #;
    %put #   Assume that the `SPFinit.sas` file                                                       #;
    %put #   is located in the "C:/SAS_PACKAGES/" folder.                                             #;
    %put #                                                                                            #;
    %put #   Run the following code in your SAS session:                                              #;
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas;
    %put  %nrstr( filename packages "C:/SAS_PACKAGES"; %%* setup a directory for packages;             );
    %put  %nrstr( %%include packages(SPFinit.sas);      %%* enable the framework;                      );
    %put  ;
    %put  %nrstr( %%requestPackage(bpUTiL)   %%* install and load the package from the Internet;       );
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
    %put #### Example #################################################################################;
    %put #                                                                                            #;
    %put #   Enabling the SAS Package Framework                                                       #;
    %put #   from the local directory and installing & loading                                        #;
    %put #   a package with a particular version from the Internet.                                   #; 
    %put #                                                                                            #;
    %put #   Assume that the `SPFinit.sas` file                                                       #;
    %put #   is located in the "C:/SAS_PACKAGES/" folder.                                             #;
    %put #                                                                                            #;
    %put #   Run the following code in your SAS session:                                              #;
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas;
    %put  %nrstr( filename packages "C:/SAS_PACKAGES";                                                );
    %put  %nrstr( %%include packages(SPFinit.sas);                                                    );
    %put ;
    %put  %nrstr( %%requestPackage(LibnameZIP, requiredVersion=0.1.0)                                 );
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
    %put ##############################################################################################;
    %put ;
    options &options_tmp.;
    %GOTO ENDofrequestPackage;
  %end;

%local _rname_ _alreadyLoaded_ options_tmp ;
%let   _rname_ = _requestPckg_%sysfunc(sleep(1,0.042),best1.)%sysfunc(datetime(),hex16.)_;

%let options_tmp = ls=%sysfunc(getoption(ls)) ps=%sysfunc(getoption(ps))
%sysfunc(getoption(notes)) %sysfunc(getoption(source)) %sysfunc(getoption(source2))
msglevel=%sysfunc(getoption(msglevel))
;
options NOnotes NOsource NOsource2 ls=MAX ps=MAX msglevel=N;
/*options source source2;*/
%let loadPackage = %sysevalf((1=%superq(loadPackage)),boolean);
%let replace     = %sysevalf(1=%superq(replace),boolean);

%let loadAddCnt   = %sysevalf(NOT(0=%superq(loadAddCnt)),boolean);
%let instDoc      = %sysevalf(NOT(0=%superq(instDoc)),boolean);
%let backup       = %sysevalf(NOT(0=%superq(backup)),boolean);
%let force        = %sysevalf(NOT(0=%superq(force)),boolean);

%let ignoreDepVer = %sysevalf(NOT(0=%superq(ignoreDepVer)),boolean);

data _null_;
  /* standardize input data */
  length packageName $ 24 requiredVersion $ 24 sysloadedpackages $ 32767 vers verR $ 24 versN verRN 8;
  packageName = scan(lowcase(symget('packageName')),1, " ");
  sysloadedpackages = lowcase(symget('sysloadedpackages'));
  requiredVersion = compress(symget('requiredVersion'),".","kd");

  put "INFO: Requesting package " packageName @;
  if requiredVersion NE " " then put "version " requiredVersion @;
  put;
  
  /* check if required version is already installed */
  f = FIND(sysloadedpackages, cats(packageName,"("), "t");  
  if f then
    do;
      vers = scan(substr(sysloadedpackages,f),2,"()");
      verR = requiredVersion;

      array V verR vers ;                                                                       
      array VN verRN versN;                                                                     
      do over V;                                                                                
        VN = coalesce(input(scan(V,1,".","M"),?? best.),0)*1e8
           + coalesce(input(scan(V,2,".","M"),?? best.),0)*1e4
           + coalesce(input(scan(V,3,".","M"),?? best.),0)*1e0;
      end;

      /*put (_ALL_) (=/);*/
      if (. <= verRN <= versN) then 
        do;
          put / "INFO: It looks like the " packageName "package is already loaded. Enjoy!"
              / @7 "The loaded version is: " vers;
          call symputX('_alreadyLoaded_', 1, "L");
        end;
      else
        put / "INFO: Searching for package file with requested version.";
    end;

  call symputX('packageName', packageName, "L");
  call symputX('requiredVersion', requiredVersion, "L");
  _error_=0;
stop;
run;


%if NOT &_alreadyLoaded_.0 %then 
%do;
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/* get list of packages */
%listPackages(work.&_rname_.,quiet=1)

/* check if minimum required version is available */
data work.&_rname_.;
  set work.&_rname_.;
  where tagNumber=3 
    and PackageZIP=lowcase("&packageName..zip") 
  ;

  length vers verR $ 24 versN verRN 8;
  vers = value;
  verR = symget("requiredVersion");
  array V verR vers ;                                                                       
  array VN verRN versN;                                                                     
  do over V;                                                                                
    VN = coalesce(input(scan(V,1,".","M"),?? best.),0)*1e8
       + coalesce(input(scan(V,2,".","M"),?? best.),0)*1e4
       + coalesce(input(scan(V,3,".","M"),?? best.),0)*1e0;
  end; 

  /*put (_ALL_) (=/);*/
  if (.<= verRN <= versN) then output; /* output data only if proper version does not exist */
  stop;
  keep base PackageZIP;
run;

/* set global macro variable for installPackage macro*/
%global &_rname_.;
%let &_rname_.=1.0;

/* if package file does not exist or does not have required version then install package */
data _null_;
  /*put nobs=;*/
  length callValue $ 32767;
  callValue=
      '%nrstr(%installPackage(&packageName.'
    !!',SFRCVN=&_rname_.'
    !!',version=&requiredVersion.'
    /* installPackages macro parameters*/
    !!',sourcePath = &sourcePath.'
    !!',mirror = &mirror.'
    !!',replace = &replace.'
    !!',backup = &backup.'
    !!',URLuser = &URLuser.'
    !!',URLpass = &URLpass.'
    !!',URLoptions = &URLoptions.'
    !!',loadAddCnt = &loadAddCnt.'
    !!',instDoc = &instDoc.'
    !!',github = &github.'
    !!',githubRepo = &githubRepo.'
    !!',githubToken = &githubToken.'
    !!',githubTokenDebug = &githubTokenDebug.'
    !!"))"
    ;
  if NOT nobs then
    do;
      /*put "1) " callValue=;*/
      call execute(callValue);
    end;
  stop;
  set work.&_rname_. nobs=nobs;
run;

/* collect package installation status for upcoming checks */
%if %sysevalf(%superq(successDS)=,boolean) %then
  %do;
    %let successDS=work.&_rname_.; /* the name can be reused now */
    data &successDS.;
      length packageName $ 24 status 8;
      packageName = symget('packageName');
      status = &&&_rname_.;
    run;
  %end;
%else
  %do;
    data work.&_rname_.; /* this one is used in the recursive call so it is different name */
      length packageName $ 24 status 8;
      packageName = symget('packageName');
      status = &&&_rname_.;
    proc append base=&successDS. data=work.&_rname_.;
    run;
  %end;

/* after successful installation search for dependencies */
data _null_;
_E_=&&&_rname_.;
if NOT (1.0=_E_) then stop;

set sashelp.vextfl;
where fileref = "PACKAGES";

filevar=cats(xpath,"/&packageName..zip");

if fileexist(filevar); /* find the first package file, since it can be on lower level location */
_END_=0;
_cut_=1;
infile _dummy_ ZIP filevar=filevar member="description.sas";

do while(_E_);
  /*  run requestPackage(packageName,requiredVersion=) recursively for dependencies */
  input;    
  if upcase(_infile_) =: "REQPACKAGES:" then
    do;
      putlog "INFO: Requesting dependencies...";
      do until(NOT _cut_);
        _cut_+1;
        length rv $ 64 r v $ 24; 
        rv = dequote(strip(scan(_infile_,_cut_,":,")));
        if rv =" " then _cut_=0;
        else 
          do;
            r = scan(rv,1,"()");
            v = scan(rv,2,"()");
            if 1=&ignoreDepVer. then v=""; /* ignore requested version and get the lates */
            length callValue $ 32767;
            callValue = 
              '%nrstr(%requestPackage(' !! strip(r) 
            !!',requiredVersion=' !! strip(v) 
            !!',loadPackage=0' 
            !!',successDS=&successDS.'
            !!',ignoreDepVer=&ignoreDepVer.'
            /* installPackages macro parameters*/
            !!',sourcePath = &sourcePath.'
            !!',mirror = &mirror.'
            !!',replace = &replace.'
            !!',backup = &backup.'
            !!',URLuser = &URLuser.'
            !!',URLpass = &URLpass.'
            !!',URLoptions = &URLoptions.'
            !!',loadAddCnt = &loadAddCnt.'
            !!',instDoc = &instDoc.'
            !!',github = &github.'
            !!',githubRepo = &githubRepo.'
            !!',githubToken = &githubToken.'
            !!',githubTokenDebug = &githubTokenDebug.'
            !!'))'
            ;
            /*put "2) " callValue=;*/
            call execute(strip(callValue));
          end;
      end;
    end;

  if upcase(_infile_) in: ("REQPACKAGES:", "DESCRIPTION START:", "DESCRIPTION END:") then _E_=0;
end;
/*put _ALL_;*/
/*stop;*/
run;

/* execute loading if requested */
%if &loadPackage. %then
  %do;
    /*
    proc print data=&successDS.;
    run;
    */

    /* check for installation errors */
    data _null_;
      set &successDS.;
      where status < 1;
      call symputX('loadPackage',0,"L");
      put "ERROR: Installation of " &packageName. "package failed!";
    run;
    /*************/
    %if ((1.0=&&&_rname_.) AND &loadPackage.) %then
      %do;
        options notes;
        %loadPackage(&packageName.,requiredVersion=&requiredVersion.,force=&force.)
        options nonotes;
      %end;
    /**************/
  %end;

/* clean up */
%symdel &_rname_. / nowarn;
proc delete data=work.&_rname_.;
run;
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
%end;
options &options_tmp.;
%ENDofrequestPackage:
%mend requestPackage; 

/* end of SPFinit.sas file */ 
