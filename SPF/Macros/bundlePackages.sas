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
des='Macro to create a bundle of SAS packages, version 20260216. Run %bundlePackages(HELP) for help info.'
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
    %put # Macro to *create bundles* of SAS packages, version `20260216`                 #;
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


