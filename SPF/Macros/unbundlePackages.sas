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
