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
des = 'Macro to verify SAS package with the hash digest, version 20240529. Run %verifyPackage() for help info.'
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
    %put # Macro to verify SAS package with it hash digest, version `20240529`           #;
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

