/*+loadPackageAddCnt+*/
/*** HELP START ***/

%macro loadPackageAddCnt(
  packageName                         /* name of a package, 
                                         e.g. myPackage, 
                                         required and not null  */
, path = %sysfunc(pathname(packages)) /* location of a package, 
                                         by default it looks for 
                                         location of "packages" fileref */
, target = %sysfunc(pathname(WORK))   /* a path in which the directory with
                                         additional content will be generated,
                                         name of directory created is set to 
                                         `&packageName._AdditionalContent` 
                                         default location is SAS work */
, source2 = /*source2*/               /* option to print out details, 
                                         null by default */
, requiredVersion = .                 /* option to test if loaded package 
                                         is provided in required version */
)/secure 
/*** HELP END ***/
des = 'Macro to load additional content for a SAS package, version 20251017. Run %loadPackageAddCnt() for help info.'
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
    %put ###      This is short help information for the `loadPackageAddCnt` macro       #;
    %put #-------------------------------------------------------------------------------#;
    %put #                                                                               #;
    %put # Macro to *load* additional content for a SAS package, version `20251017`      #;
    %put #                                                                               #;
    %put # A SAS package is a zip file containing a group                                #;
    %put # of SAS codes (macros, functions, data steps generating                        #;
    %put # data, etc.) wrapped up together and included by                               #;
    %put # a single `load.sas` file (also embedded inside the zip).                      #;
    %put #                                                                               #;
    %put # The `%nrstr(%%loadPackageAddCnt())` macro loads additional content                     #;
    %put # for a package (of course only if one is provided).                            #;
    %put #                                                                               #;
    %put #-------------------------------------------------------------------------------#;
    %put #### Parameters:                                                                #;
    %put #                                                                               #;
    %put # 1. `packageName`      *Required.* Name of a package, e.g. myPackage,          #;
    %put #                       Required and not null, default use case:                #;
    %put #                        `%nrstr(%%loadPackageAddCnt(myPackage))`.                       #;
    %put #                       If empty displays this help information.                #;
    %put #                                                                               #;
    %put # - `path=`             *Optional.* Location of a package. By default it        #;
    %put #                       looks for location of the **packages** fileref, i.e.    #;
    %put #                        `%nrstr(%%sysfunc(pathname(packages)))`                         #;
    %put #                                                                               #;
    %put # - `target=`           *Optional.* Location where the directory with           #;
    %put #                       additional content will be generated,                   #;
    %put #                       name of the directory created is set to                 #;
    %put #                       `<packagename>_AdditionalContent`, the default          #;
    %put #                       location is `%nrstr(%%sysfunc(pathname(WORK)))`                  #;
    %put #                                                                               #;
    %put # - `source2=`          *Optional.* Option to print out details about           #;
    %put #                       what is loaded, null by default.                        #;
    %put #                                                                               #;
    %put # - `requiredVersion=`  *Optional.* Option to test if the loaded                #;
    %put #                       package is provided in required version,                #;
    %put #                       default value: `.`                                      #;
    %put #                                                                               #;
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
    %put #   from the local directory and installing & loading additional content        #;
    %put #   for the SQLinDS package.                                                    #;
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
    %put  %nrstr( %%loadPackageAddCnt(SQLinDS) %%* load additional content for the package;       );
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
    %put #                                                                               #;
    %put #################################################################################;
    %put ;
    options &options_tmp.;
    %GOTO ENDofloadPackageAddCnt;
  %end;
  /* local variables for options */
  %local ls_tmp ps_tmp notes_tmp source_tmp stimer_tmp fullstimer_tmp msglevel_tmp mautocomploc_tmp zip;
  %let ls_tmp         = %sysfunc(getoption(ls));
  %let ps_tmp         = %sysfunc(getoption(ps));
  %let notes_tmp      = %sysfunc(getoption(notes));
  %let source_tmp     = %sysfunc(getoption(source));
  %let stimer_tmp     = %sysfunc(getoption(stimer));
  %let fullstimer_tmp = %sysfunc(getoption(fullstimer));
  %let msglevel_tmp   = %sysfunc(getoption(msglevel));
  %let mautocomploc_tmp = %sysfunc(getoption(mautocomploc));

  %let zip = zip;

  options NOnotes NOsource ls=MAX ps=MAX NOfullstimer NOstimer msglevel=N NOmautocomploc;

  %local _PackageFileref_;
  data _null_; 
    call symputX("_PackageFileref_", "A" !! put(MD5(lowcase("&packageName.")), hex7. -L), "L"); 
    call symputX("_TargetFileref_",  "T" !! put(MD5(lowcase("&packageName.")), hex7. -L), "L"); 
  run;

  /* when the packages reference is multi-directory search for the first one containing the package */
  data _null_;
    exists = 0;
    length packages $ 32767 p $ 4096;
    packages = resolve(symget("path"));
    if char(packages,1) ^= "(" then packages = quote(strip(packages)); /* for paths with spaces */
    do i = 1 to kcountw(packages, "()", "QS");
      p = dequote(kscanx(packages, i, "()", "QS"));
      exists + fileexist(catx("/", p, lowcase("&packageName.") !! ".&zip."));
      if exists then leave;
    end;
    if exists then call symputx("path", p, "L");
  run;
  
  filename &_PackageFileref_. &ZIP. 
  /* put location of package myPackageFile.zip here */
    "&path./%sysfunc(lowcase(&packageName.)).&zip."
  ;
  %if %sysfunc(fexist(&_PackageFileref_.)) %then
    %do;

      filename &_PackageFileref_. &ZIP. 
      /* check existence of addcnt.zip inside package */
        "&path./%sysfunc(lowcase(&packageName.)).&zip."
        member='addcnt.zip'
      ;
      %if %sysfunc(fexist(&_PackageFileref_.)) %then
        %do;

          /* get metadata */
          filename &_PackageFileref_. &ZIP. 
            "&path./%sysfunc(lowcase(&packageName.)).&zip."
          ;
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
              %put ERROR: Additional content for package &packageName. will not be loaded!;
              %put ERROR- Required version is &rV0.;
              %put ERROR- Provided version is &pV0.;
              %put ERROR- Condition %bquote((&rV0. &rVsign. &pV0.)) evaluates to %sysevalf(&rV. &rVsign. &pV.);
              %put ERROR- Verify installed version of the package.;
              %put ERROR- ;
              %GOTO WrongVersionOFPackageAddCnt; /*%RETURN;*/
            %end;

          /*options ls = &ls_tmp. ps = &ps_tmp. &notes_tmp. &source_tmp.;*/
          filename &_PackageFileref_. &ZIP. 
            "&path./%sysfunc(lowcase(&packageName.)).&zip."
            member='addcnt.zip'
          ;
          /*********************/
          filename &_TargetFileref_. "&target.";
          %if %sysfunc(fexist(&_TargetFileref_.)) %then
            %do;

              %if %sysfunc(fileexist(%sysfunc(pathname(&_TargetFileref_.))/%sysfunc(lowcase(&packageName.))_AdditionalContent)) %then
                %do; /* dir for AC already exists */
                  %put WARNING: Target location:;
                  %put WARNING- %sysfunc(pathname(&_TargetFileref_.))/%sysfunc(lowcase(&packageName.))_AdditionalContent;
                  %put WARNING- already exist. Please remove it manually to upload additional contents.;
                  %put WARNING- Additional Content will not be loaded.;
                  %put WARNING- ;
                %end;
              %else
                %do;
                  /*-+-+-+-*/
                  /* create target location */
                  %put INFO:;
                  %put Additional content will be located in:;
                  %put %sysfunc(dcreate(%sysfunc(lowcase(&packageName.))_AdditionalContent,%sysfunc(pathname(&_TargetFileref_.))));

                  %if NOT (%sysfunc(fileexist(%sysfunc(pathname(&_TargetFileref_.))/%sysfunc(lowcase(&packageName.))_AdditionalContent))) %then
                    %do; /* dir for AC cannot be generated */
                      %put ERROR: Cannot create target location:;
                      %put ERROR- %sysfunc(pathname(&_TargetFileref_.))/%sysfunc(lowcase(&packageName.))_AdditionalContent;
                      %put ERROR- Additional Content will not be loaded.;
                      %put ERROR- ;
                    %end;
                  %else
                    %do;
                      /* extract addcnt.zip to work and, if successful, load additional content */
                      %put NOTE- **%sysfunc(DoSubL(%nrstr(
                      ;
                      options nonotes nosource ps=min ls=max;
                      data _null_;
                        call symputx("AdditionalContent", 0, "L");

                        rc1=filename("in", pathname("&_PackageFileref_."), "ZIP", "lrecl=1 recfm=n member='addcnt.zip'");
                        length rc1txt $ 8192;
                        rc1txt=sysmsg();

                        if fexist("in") then
                          do;
                            rc2=filename("out", pathname("WORK")!!"/%sysfunc(lowcase(&packageName.))addcnt.zip", "disk", "lrecl=1 recfm=n");
                            length rc2txt $ 8192;
                            rc2txt=sysmsg();

                            rc3=fcopy("in","out");
                            length rc3txt $ 8192;
                            rc3txt=sysmsg();

                            if rc3 then put _N_ @12 (rc:) (=);

                            if fexist("out") then 
                              do;
                                call symputx("AdditionalContent", 1, "L");
                              end;
                            else put "INFO: No additional content for package &packageName..";

                            rc1=filename("in");
                            rc2=filename("out");
                          end;
                        else
                         do;
                           call symputx("AdditionalContent", 0, "L");
                           put "INFO: No additional content for package &packageName..";
                         end;
                      run;

                      %if &AdditionalContent. %then 
                        %do;
                          filename f DUMMY;
                          filename f ZIP "%sysfunc(pathname(WORK))/%sysfunc(lowcase(&packageName.))addcnt.zip";
                          options dlCreateDir;
                          libname outData "%sysfunc(pathname(&_TargetFileref_.))/%sysfunc(lowcase(&packageName.))_AdditionalContent";

                          data WORK.__&_TargetFileref_._zip___;
                            did = dopen("f");
                            if not did then 
                              do;
                                put "ERROR: Can not access Additional Content data.";
                                stop;
                              end;
                            if did then
                             do i=1 to dnum(did);
                              length file $ 8192;
                              file = dread(did, i);
                              output;
                              keep file;
                             end;
                            did = dclose(did);
                          run;

                          data _null_; 
                          	set WORK.__&_TargetFileref_._zip___ end = EOF;
                            wc = countw(file,"/\");
                          
                            put wc= file=;

                            length libText pathname_f $ 8192;
                            libText = pathname("outData", "L");
                         
                            if scan(file, wc , "/\") = "" then
                              do j = 1 to wc-1;
                                libText = catx("/", libText, scan(file, j , "/\"));
                                rc = libname("test", libText);
                                rc = libname("test");
                              end;
                            else
                              do;
                                do j = 1 to wc-1;
                                  libText = catx("/", libText, scan(file, j , "/\"));
                                  rc = libname("test", libText);
                                  rc = libname("test");
                                end;

                                pathname_f = pathname("f");

                                length rc1msg $ 8192;
                                rc1 = filename("in", strip(pathname_f), "zip", "member='" !! strip(file) !! "' lrecl=1 recfm=n");
                                rc1msg = sysmsg();

                                length fileNameOutPath $ 8192;
                                fileNameOutPath = catx("/", libText, scan(file, j , "/\"));
                                /* check for Windows */
                                if lengthn(fileNameOutPath)>260 then 
                                  if symget('SYSSCP')='WIN' then 
                                    put "INFO: Pathname plus filename length exceeds 260. Under Windows family OS it may cause problems.";

                                length rc2msg $ 8192;
                                rc2 = filename("out", fileNameOutPath, "disk", "lrecl=1 recfm=n");
                                rc2msg = sysmsg();
                              
                                length rc3msg $ 8192;
                                rc3 = fcopy("in", "out");
                                rc3msg = sysmsg();
                          
                                loadingProblem + (rc3 & 1);

                                if rc3 then
                                  do;
                                    put "ERROR: Cannot extract: " file;
                                    put "ERROR-" (rc1 rc2 rc3) (=); 
                                    put (rc1msg rc2msg rc3msg) (/);
                                    put "ERROR-"; 
                                  end;
                                crc1=filename("in");
                                crc2=filename("out");
                              end;

                              if EOF and loadingProblem then
                                do;
                                  put "ERROR: Not all files from Additional Content were extracted successfully!";
                                end;
                          run;

                          data _null_;
                            rc = fdelete("f");
                          run;

                          proc delete data = WORK.__&_TargetFileref_._zip___;
                          run;

                          libname outData;
                          filename f DUMMY;
                        %end;
                      )))**;
                    %end; 
                  /*-+-+-+-*/
                %end;
 
            %end;
          %else
            %do;
              %put ERROR: Cannot access target location:;
              %put ERROR- %sysfunc(pathname(&_TargetFileref_.));
              %put ERROR- Additional Content will not be loaded.;
              %put ERROR- ;
            %end;
          filename &_TargetFileref_. clear;
          /*********************/
        %end;
      %else %put INFO: No additional content for &packageName. package.;
    %end;
  %else %put ERROR:[&sysmacroname] File "&path./&packageName..&zip." does not exist!;
  filename &_PackageFileref_. clear;
  
  %WrongVersionOFPackageAddCnt:

  /* restore optionos */
  options ls = &ls_tmp. ps = &ps_tmp. 
          &notes_tmp. &source_tmp. 
          &stimer_tmp. &fullstimer_tmp.
          msglevel=&msglevel_tmp. &mautocomploc_tmp.;

%ENDofloadPackageAddCnt:
%mend loadPackageAddCnt;

/**/

