/*+SPFint_gnPckg_tests+*/
%macro SPFint_gnPckg_tests()/secure minoperator
des='SAS Packages Framework internal macro. Executable only inside the %generatePackage() macro. The macro encapsulates the test part of the process. Version 20260216.';
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

      /* verify */
      put @n '%verifyPackage'"(&packageName.,";
      put @n " path=&buildLocation.)" /;

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

  /* verify */
  put '%verifyPackage'"(&packageName.,";
  put " path=&buildLocation.)" /;

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



