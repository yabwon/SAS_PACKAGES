/*+relocatePackage+*/
/*** HELP START ***/

%macro relocatePackage(
 packageName   /* list of packages (space-separated!) */ 
,source=       /* place to take packages from (local location) */
,target=       /* the "packages" fileref by default */
,sDevice=DISK  /* also: ZIP, FILESRVC (SASFSVAM)*/
,tDevice=DISK  /* also: ZIP, FILESRVC */
,checksum=0    /* if 1, copies data only if the source (from file) checksum is different than the target (to file) */
,move=0        /* packages are copied by default */
,try=3         /* integer between 1 and 9 */
,debug=0       /* debugging indicator */
,ignorePackagesFilerefCheck=0
,psMAX=MAX     /* pageSise in case executed inside DoSubL() */
,ods=          /* a data set for results, e.g., work.relocatePackageReport */
)
/ des = 'Utility macro that locally Copies or Moves Packages, version 20260216. Run %relocatePackage() for help info.'
  secure
  minoperator
;
/*** HELP END ***/
%if (%superq(packageName) = ) OR (%qupcase(&packageName.) = HELP) %then
  %do;
    %local options_tmp ;
    %let options_tmp = ls=%sysfunc(getoption(ls)) ps=%sysfunc(getoption(ps))
     %sysfunc(getoption(notes)) %sysfunc(getoption(source))
     msglevel=%sysfunc(getoption(msglevel))
    ;
    options NOnotes NOsource ls=MAX ps=MAX msglevel=N;
    %put ;
    %put #################################################################################;
    %put ###      This is short help information for the `relocatePackage` macro         #;
    %put #-------------------------------------------------------------------------------#;
    %put #                                                                               #;
    %put # Macro to *locally copy or move* (relocate) SAS packages, version `20260216`   #;
    %put #                                                                               #;
    %put # A SAS package is a zip file containing a group                                #;
    %put # of SAS codes (macros, functions, data steps generating                        #;
    %put # data, etc.) wrapped up together and included by                               #;
    %put # a single `load.sas` file (also embedded inside the zip).                      #;
    %put #                                                                               #;
    %put # The `%nrstr(%%relocatePackage())` is a utility macro for local copying or moving       #;
    %put # SAS packages. The macro transfers packages located in the `PACKAGES`          #;
    %put # fileref to a selected directory (`DISK` device), folderpath (`FILESRVC`       #;
    %put # device), or a zip file (`ZIP` device).                                        #;
    %put #                                                                               #;
    %put # The macro allows for a bidirectional transfer of packages, i.e., from the     #;
    %put # `PACKAGES` fileref to the selected *target*, or from the selected *source*    #;
    %put # to the `PACKAGES` fileref.                                                    #;
    %put #                                                                               #;
    %put #-------------------------------------------------------------------------------#;
    %put #### Parameters:                                                                #;
    %put #                                                                               #;
    %put # 1. `packageName`      *Required.* Name of a package, e.g. myPackage.          #;
    %put #                       A space-separated(!) list of packages to transfer is    #;
    %put #                       also accepted. If empty displays this help information. #;
    %put #                                                                               #;
    %put # - `source=`           *Required/Optional.* Source location for packages.      #;
    %put #                       When used, indicates a directory (`DISK` device),       #;
    %put #                       a folderpath (`FILESRVC` device), or a zip file (`ZIP`  #;
    %put #                       device) *from* where packages will be copied.           #;
    %put #                       In this case `PACKAGES` fileref is target location.     #;
    %put #                       Cannot be used together with `target=` parameter.       #;
    %put #                                                                               #;
    %put # - `target=`           *Required/Optional.* Target location for packages.      #;
    %put #                       When used, indicates a directory (`DISK` device),       #;
    %put #                       a folderpath (`FILESRVC` device), or a zip file (`ZIP`  #;
    %put #                       device) *to* where packages will be copied.             #;
    %put #                       In this case `PACKAGES` fileref is source location.     #;
    %put #                       Cannot be used together with `source=` parameter.       #;
    %put #                                                                               #;
    %put # - `sDevice=`          *Required/Optional.* When `source=` is used this        #;
    %put #                       parameter provides which type of device to be use.      #;
    %put #                       Default value is `DISK`, values `ZIP` and `FILESRVC`    #;
    %put #                       are allowed. For `FILESRVC` the `folderpath=` is used.  #;
    %put #                                                                               #;
    %put # - `tDevice=`          *Required/Optional.* When `target=` is used this        #;
    %put #                       parameter provides which type of device to be use.      #;
    %put #                       Default value is `DISK`, values `ZIP` and `FILESRVC`    #;
    %put #                       are allowed. For `FILESRVC` the `folderpath=` is used.  #;
    %put #                                                                               #;
    %put # - `checksum=`         *Optional.* Indicates if packages should be copied only #;
    %put #                       if the source (from file) checksum is different than    #;
    %put #                       the target (to file). Default value is 0 (always copy). #;
    %put #                                                                               #;
    %put # - `move=`             *Optional.* Indicates if packages should be moved from  #;
    %put #                       source to target, default value is `0`,                 #;
    %put #                       when set to `1`: after *successful* copying packages    #;
    %put #                       in the source are *deleted*. Use carefully!             #;
    %put #                                                                               #;
    %put # - `debug=`            *Optional.* Indicates if debug notes should be printed, #;
    %put #                       default value is `0`, when set to `1`: debug info       #;
    %put #                       is printed.                                             #;
    %put #                                                                               #;
    %put # - `try=`              *Optional.* Number of tries when copy is unsuccessful,  #;
    %put #                       default value is `3`, allowed values are integers       #;
    %put #                       from 1 to 9. Time between tries is quarter of a second. #;
    %put #                                                                               #;
    %put #-------------------------------------------------------------------------------#;
    %put #                                                                               #;
    %put # Visit: `https://github.com/yabwon/SAS_PACKAGES/tree/main/SPF/Documentation`   #;
    %put # to learn more.                                                                #;
    %put # Tutorials available at: `https://github.com/yabwon/HoW-SASPackages`           #;
    %put #                                                                               #;
    %put ### Example 1 ###################################################################;
    %put #                                                                               #;
    %put #   Enabling the SAS Package Framework from the local                           #;
    %put #   directory, copying SQLinDS package from Viya Files                          #;
    %put #   service, and loading the package to the SAS session.                        #;
    %put #                                                                               #;
    %put #   Assume that the `SPFinit.sas` file is located in the "/home/user/PCKG"      #;
    %put #   directory and Viya Files service location is "/files/packages/"             #;
    %put #                                                                               #;
    %put #   Run the following code in your SAS session:                                 #;
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas;
    %put  %nrstr( filename packages "/home/user/PCKG"; %%* setup a directory for packages;     );
    %put  %nrstr( %%include packages(SPFinit.sas);      %%* enable the framework;              );
    %put  ;
    %put  %nrstr( %%relocatePackage%(SQLinDS  %%* copy the package from Viya Files service;    );
    %put  %nrstr(                 ,source=/files/packages/                                     );
    %put  %nrstr(                 ,sDevice=FILESRVC%)                                          );
    %put  %nrstr( %%loadPackage(SQLinDS)   %%* load the package content into the SAS session;  );
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
    %put #                                                                               #;
    %put ### Example 2 ###################################################################;
    %put #                                                                               #;
    %put #   Enabling the SAS Package Framework from the local directory                 #;
    %put #   and creating a "bundle" file by moving 3 packages: the BasePlus,            #;
    %put #   the SQLinDS, and the MacroArray package into the target file.               #;
    %put #                                                                               #;
    %put #   Assume that the `SPFinit.sas` file                                          #;
    %put #   is located in the "C:/SAS_PACKAGES/" folder.                                #;
    %put #                                                                               #;
    %put #   Run the following code in your SAS session:                                 #;
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas;
    %put  %nrstr( filename packages "C:/SAS_PACKAGES"; %%* setup a directory for packages;       );
    %put  %nrstr( %%include packages(SPFinit.sas);      %%* enable the framework;                );
    %put  ;
    %put  %nrstr( %%relocatePackage%(BasePlus SQLinDS MacroArray %%* create a bundle of packages;);
    %put  %nrstr(                 ,target=D:/archive/bundle_2025_12_15.zip                       );
    %put  %nrstr(                 ,tDevice=ZIP, move=1%)                                         );
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
    %put #                                                                               #;
    %put #################################################################################;
    %put ;
    options &options_tmp.;
    %GOTO ENDofrelocatePackage;
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

  options NOnotes NOsource ls=128 ps=&psMAX. NOfullstimer NOstimer msglevel=N NOmautocomploc;

  %if NOT(%superq(debug) in (0 1))                      %then %let debug=0;
  %if NOT(%superq(move) in (0 1))                       %then %let move=0;
  %if NOT(%superq(try) in (1 2 3 4 5 6 7 8 9))          %then %let try=3;
  %if NOT(%superq(checksum) in (0 1))                   %then %let checksum=0;
  %if NOT(%superq(ignorePackagesFilerefCheck) in (0 1)) %then %let ignorePackagesFilerefCheck=0;
  
  options nonotes msglevel=N;

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
  %if &checksum. AND NOT &HASHING_FILE_exist. %then
    %do;
      %put WARNING: Checksum verification impossible! Minimum SAS version required for the process is 9.4M6. ;
    %end;

  data _null_ %if %superq(ods) NE %then %do; &ods. %end;
  ;
    putlog 52*"*" 24*"=" 52*"*";
    length packages source target $ 32767 sDevice tDevice $ 32;
    packages = lowcase(compress(symget('packageName'),"_ ","KAD"));

    if " " = packages then 
      do;
        putlog "INFO: No packages to move or copy. Exiting.";
        LINK stopProcessing;
      end;
    else putlog "INFO: List of packages: " packages;

    debug = sum(symgetn('debug'),0);

    /* grab macro variables values */
    array mvar source target sDevice tDevice;
    do over mvar;
      mvar=symget(vname(mvar));
    end;

    if source NE ' ' AND target NE " " then
      do;
        putlog "WARNING: The SOURCE= and the TARGET= parameters cannot be used simultaneously. Exiting!";
        LINK stopProcessing;
      end;

    if source EQ ' ' AND target EQ " " then
      do;
        putlog "INFO: The SOURCE= and the TARGET= parameters were not used, nothing to do. Exiting!";
        LINK stopProcessing;
      end;

    /* verify that PACKAGES is valid location for source or target */
    /*=========================================================================================================*/
    %if 0 = &ignorePackagesFilerefCheck. %then
      %do;
        if NOT (input(resolve('%isPackagesFilerefOK(&debug.)'), best.)=1) then /* if debug=1 the isPackagesFilerefOK in verbose mode */
          do;
            putlog "WARNING: The PACKAGES fileres is not OK! Exiting!";
            LINK stopProcessing;
          end;
      %end;
    /*=========================================================================================================*/

    /* prepare source and target */
    /*=========================================================================================================*/
    %local i ST_list st stDev stFr stH stI stEx stAsg leave;
    %let ST_list=target source; /* repeat the same structure twice with different prefix */
    %do i=1 %to 2;
      %let st=%scan(&ST_list., &i.);
      %let stDev=%substr(&st.,1,1)Device;
      %let stFr =%substr(&st.,1,1)FileRef;
      %let stH  =%substr(&st.,1,1)Hash;
      %let stI  =%substr(&st.,1,1)Iter;
      %let stEx =%substr(&st.,1,1)Exists;
      %let stAsg=%substr(&st.,1,1)Assigned;
      %let stFp =%substr(&st.,1,1)FromPackages;

      retain &stFp. 0 move 0;
      move = sum(symgetn('move'),0);
      /* validate source and target */
      &stDev. = upcase(compress(&stDev.,"_","KAD"));
      if NOT (&stDev. in ("DISK" "BASE" "ZIP" "FILESRVC" "SASFSVAM")) then
        do;
          putlog "WARNING: The &stDev. parameter value: " &stDev. "is not allowed."
               / "WARNING- Only: DISK, ZIP, and FILESRVC devices are supported as &st. device. Exiting!";
          LINK stopProcessing;
        end;

      if &st.=" " then 
        do;
          if 0 then set SASHELP.VEXTFL;
          DECLARE HASH &stH.(dataset:'SASHELP.VEXTFL(where=(fileref="PACKAGES"))', ordered: "A");
          &stH..DefineKey("level");
          &stH..DefineData("xpath","xengine");
          &stH..DefineDone();
          DECLARE HITER &stI.("&stH.");

          if &stH..NUM_ITEMS=0 then
            do;
              putlog "INFO: Packages fileref not found. Using WORK instead.";
              level = 0;
              xpath = pathname("WORK","L");
              xengine = 'DISK';
              &stI..REPLACE();
            end;

          &stI..FIRST();
          &st. = strip(xpath); /* get the first packages path */
          &stDev. = strip(xengine);
          
          /* Just to make it easier to debug since FILESRVC will show up in Google */
          if &stDev. = 'SASFSVAM' then _stDev_ = 'FILESRVC';
                                  else _stDev_ = strip(xengine);
          putlog "INFO: The &st. location is: " / @7 _stDev_ +(-1) ": " &st.;
          %if &st.=source %then 
            %do;
              do while(&stI..next()=0);
                 if xengine = 'SASFSVAM' then _engine_ = 'FILESRVC';
                                         else _engine_ = xengine;
                 putlog @7 _engine_ +(-1) ": " xpath;
              end;
            %end;
          &stFp. = 1;
        end; 
      else
        do;
          length &stFr. $ 8; 

          if " "=getoption("SERVICESBASEURL") AND (&stDev. in ("FILESRVC" "SASFSVAM")) then 
            do;
              putlog "WARNING: The SERVICESBASEURL option must be specified for the FILESRVC device. Exiting!";
              LINK stopProcessing; 
            end;

          length &stAsg.Txt &stEx.Txt $ 256;


          if (&stDev. in ("FILESRVC" "SASFSVAM")) then
            &stAsg. = filename(&stFr., ,strip(&stDev.), "recfm=n lrecl=1 " !! "folderpath=" !! quote(strip(&st.))); /* assign FILESRVC */
          else 
            &stAsg. = filename(&stFr.,strip(&st.), strip(&stDev.), "recfm=n lrecl=1"); /* assign DISK or ZIP*/
          &stAsg.Txt = sysmsg();

          &stEx. = FEXIST(&stFr.);
          &stEx.Txt = sysmsg();

          if debug then putlog (&stFr. &st. &stDev. &stAsg. &stAsg.Txt &stEx. &stEx.Txt) (=/);
          _rc_ = filename(&stFr.); /*clear*/
        end;
    %end;
    /*=========================================================================================================*/

    if source=target and sDevice=tDevice then 
      do;
        putlog / "INFO: Nothing to move or copy. Exiting.";
        LINK stopProcessing;
      end;

    if move then 
      do;
        putlog / "INFO: Files will be moved, i.e., after successful copying to the target location" 
               / "      the source will be deleted.";
      end;

    /* 4096 for host options for Viya FS */
    length sHostoptions tHostOptions $ 4096  tFilename sFilename  $ 2048;

    do i = 1 to countw(packages, " ");
      package = scan(packages, i, " ");

      putlog 52*"*" package $24.-C 52*"*";

      select;
        /* copy from PACKAGES to some location */
        /*=========================================================================================================*/
        when(1=sFromPackages AND 0=tFromPackages AND 0=tAssigned) 
          do;
            select;
              /* disk */
              when (tDevice in ("DISK" "BASE"))
                do;
                  if NOT tExists then GOTO stopForThisPackage1;
                  tAssigned = filename(tFileRef
                                      ,cats(target, "/", package, ".zip")
                                      ,strip(tDevice)
                                      ,"recfm=n lrecl=1");
                end;
              /* zip */
              when (tDevice in ("ZIP"))
                do;
                  if tExists then putlog "INFO: Overwriting member: " package +(-1) ".zip inside: " target;
                  tAssigned = filename(tFileRef
                                      ,cats(target)
                                      ,strip(tDevice)
                                      ,"recfm=n lrecl=1 member=" !! quote(cats(package, ".zip")) );
                end;
              /* filesrvc */
              when (tDevice in ("FILESRVC" "SASFSVAM"))
                do;
                  tAssigned = filename(tFileRef
                                      ,/*blank*/ ,strip(tDevice)
                                      ,"recfm=n lrecl=1" 
                                       !! " folderpath=" !! quote(cats(target))
                                       !! " filename="   !! quote(cats(package, ".zip"))
                                      );
                end;
              /* other */
              otherwise 
                do;
                  putlog "ERROR: Unsupported device: " tDevice +(-1) ". Exiting!";
                  GOTO stopForThisPackage1;
                end;
            end;

            if debug then putlog tAssigned= tFileRef= / tDevice=;

            _rc_ = sIter.first(); 
            _rc_ = sIter.prev();
            do while(sIter.next()=0);

              /* If Viya File Service, we need to use:
                 filename('fileref', ,'FILEFSVAM', "<host options>") */
              if xengine = 'SASFSVAM' then do;
                  sFilename = ' ';
                  sHostOptions = "recfm=n lrecl=1"
                                  !! " folderpath=" !! quote(strip(xpath))
                                  !! " filename="   !! quote(cats(package, ".zip"))
                  ;
              end;
                else do;
                    sFilename = cats(strip(xpath), "/", package, ".zip");
                    sHostOptions = "recfm=n lrecl=1";
                end;

              sAssigned = filename(sFileref
                                  ,sFilename
                                  ,xengine
                                  ,sHostOptions);

              if debug then putlog sAssigned= sFileRef= / xengine=;
              leave=0;
              LINK LoopTryCopyFile; /* LINK 1 */
              if leave then leave;
            end;
            sAssigned = filename(sFileRef);
            tAssigned = filename(tFileRef); 

            stopForThisPackage1:
            if 0=leave then putlog "ERROR: Fail to process " package;
          end;
        /*=========================================================================================================*/

        /* copy from some location to PACKAGES */
        /*=========================================================================================================*/
        when(0=sFromPackages AND 1=tFromPackages AND 0=sAssigned) 
          do;
            select;
              /* disk */
              when (sDevice in ("DISK" "BASE"))
                do;
                  if NOT sExists then GOTO stopForThisPackage2;
                  sAssigned = filename(sFileRef
                                      ,cats(source, "/", package, ".zip")
                                      ,strip(sDevice)
                                      ,"recfm=n lrecl=1");
                end;
              /* zip */
              when (sDevice in ("ZIP"))
                do;
                  sAssigned = filename(sFileRef
                                      ,cats(source)
                                      ,strip(sDevice)
                                      ,"recfm=n lrecl=1 member=" !! quote(cats(package, ".zip")) );
                end;
              /* filesrvc */
              when (sDevice in ("FILESRVC" "SASFSVAM"))
                do;
                  sAssigned = filename(sFileRef
                                      ,/*blank*/ ,strip(sDevice)
                                      ,"recfm=n lrecl=1" 
                                       !! " folderpath=" !! quote(cats(source))
                                       !! " filename="   !! quote(cats(package, ".zip"))
                                      );
                end;
              /* other */
              otherwise 
                do;
                  putlog "ERROR: Unsupported device: " sDevice +(-1) ". Exiting!";
                  GOTO stopForThisPackage2;
                end;
            end;

            if debug then putlog sAssigned= sFileRef= / sDevice=;

            if NOT fexist(sFileRef) then 
              do;
                putlog "WARNING: File: " package +(-1) ".zip does NOT exist inside: " source;
              end;
            else
              do;
                _rc_ = tIter.first(); 
                _rc_ = tIter.prev();
                do while(tIter.next()=0);

                    /* If Viya File Service, we need to use:
                        filename('fileref', ,'FILEFSVAM', "<host options>") */
                    if xengine = 'SASFSVAM' then do;
                        tFilename = ' ';
                        tHostOptions = "recfm=n lrecl=1"
                                        !! " folderpath=" !! quote(strip(xpath))
                                        !! " filename="   !! quote(cats(package, ".zip"))
                        ;
                    end;
                        else do;
                            tFilename = cats(strip(xpath), "/", package, ".zip");
                            tHostOptions = "recfm=n lrecl=1";
                        end;

                    tAssigned = filename(tFileRef
                                        ,tFilename
                                        ,xengine
                                        ,tHostOptions);
                                      
                  if debug then putlog tAssigned= tFileRef= / xengine=;
                  leave=0;
                  LINK LoopTryCopyFile; /* LINK 1 */
                  if leave then leave;
                end;
                tAssigned = filename(tFileRef); 
              end;

            sAssigned = filename(sFileRef);
            stopForThisPackage2:
            if 0=leave then putlog "ERROR: Fail to process " package;
          end;
        /*=========================================================================================================*/
        /**
          when(0) do; put "future cases"; end; 
        **/
        otherwise putlog "WARNING: Unknown combination.";
      end; 
    end;

  LINK stopProcessing;
  /** the end **/
  STOP;

  /* LINK 1 */
  loopTryCopyFile:
    do try = 1 to &try. while(leave=0);

    length s_HASHING t_HASHING $ 128;

    %if &checksum. AND &HASHING_FILE_exist. %then
      %do;
        if try = 1 AND fexist(tFileRef) then /* check SHA256 only for first try */
          do;
            LINK GETSHA256DIGEST; /* LINK 2 */

            if s_HASHING=t_HASHING then 
              do;
                putlog "INFO: The SHA256 hash digest for source and target are identical."
                     / @7 "Checksum: " t_HASHING
                     / @7 "Package will not be copied.";
                _rc_ = 0;
              end;
            else
              do; /* message only for the first time */
                putlog "INFO: The SHA256 hash digest for source and target are different."
                     / @7 "Target checksum: " t_HASHING
                     / @7 "Source checksum: " s_HASHING
                     / @7 "Copying package.";
                _rc_    = fcopy(sFileRef, tFileRef);
                _rcTxt_ = sysmsg();
              end;
          end; 
        else /* keep this ELSE unclosed for... */
      %end;
      
      do; /* ... this DO-END block  */
        _rc_    = fcopy(sFileRef, tFileRef);
        _rcTxt_ = sysmsg();
      end;

      if debug then putlog _rc_= / _rcTxt_=;
      leave + (_rc_=0)*fexist(tFileRef);

      %if &HASHING_FILE_exist. = 1 %then
        %do;
          if leave then /* compare SHA256 after copy */
            do;
              LINK GETSHA256DIGEST; /* LINK 2 */

              if NOT (s_HASHING=t_HASHING) then 
                putlog "WARNING: The SHA256 hash digest is different for source and target!" 
                     / "WARNING- Source is: " s_HASHING 
                     / "WARNING- Target is: " t_HASHING
                     / "WARNING- There could be errors during copying. Check your files.";
              %if %superq(ods) NE %then %do; output %scan(&ods.,1,()) ; %end;
            end;
        %end;

      if (leave AND move) then 
        do;
          _rc_ = fdelete(sFileRef);
          if _rc_ then putlog "WARNING: Target successfully copied, but cannot delete source file while moving.";
        end;
      if not leave then _rc_ = sleep(1,0.25);
    end;
  return;

  /* LINK 2 */
  GETSHA256DIGEST:
    %let ST_list=t s; /* for source(s) and for target(t), repeat the same structure twice with different prefix */
    %do i=1 %to 2;
      %let st=%scan(&ST_list., &i.);
      select;
        when (&st.Device in ("ZIP")) &st._HASHING=HASHING_FILE("SHA256", &st.FileRef, 4);
        when (&st.Device in ("DISK" "BASE")) &st._HASHING=HASHING_FILE("SHA256", pathname(&st.FileRef,'F'), 0);
        otherwise /* for FILESRVC and SASFSVAM*/
          do;
             &st._sha256 = hashing_init("SHA256");  
             &st._FID = fopen(&st.FileRef, "i", 1, "B"); /* read only in binary format */
             if &st._FID then do while(fread(&st._FID)=0);
               length &st.c $ 1;
               _rc_ = fget(&st._FID, &st.c, 1);
               _rc_ = hashing_part(&st._sha256, &st.c);
             end;
             &st._FID = fclose(&st._FID);
             &st._HASHING = hashing_term(&st._sha256);
          end;
      end;
    %end;
  return;

  /* LINK 3 */
  stopProcessing:
    putlog 52*"*" 24*"=" 52*"*";
    stop;
  return;

  run;

  /* restore optionos */
  options ls = &ls_tmp. ps = &ps_tmp. 
          &notes_tmp. &source_tmp. 
          &stimer_tmp. &fullstimer_tmp.
          msglevel=&msglevel_tmp. &mautocomploc_tmp.;

%ENDofrelocatePackage:
%mend relocatePackage;

/* tests on Viya:

filename PACKAGES list; 

%let user= <...>; 

filename backup filesrvc
  folderpath="/Users/&user./My Folder/SASPACKAGES";
filename backup list;

%put %sysfunc(pathname(backup));

data _null_;
  x=getoption("SERVICESBASEURL");
  put x=;
run;

options ls = 90;
%* move from PACKAGES to a FILESRVC location*;
%relocatePackage(baseplus SQLinDS macroarray
,target=/Users/&user./My Folder/SASPACKAGES
,tDevice=FILESRVC
,move=1) 

%* move back to PACKAGES from a FILESRVC location*;
%relocatePackage(baseplus SQLinDS macroarray
,source=/Users/&user./My Folder/SASPACKAGES
,sDevice=FILESRVC
,move=1) 

%* create a ZIP bundle with packages in HOME *;
%relocatePackage(baseplus SQLinDS macroarray
,target=~/SASPACKAGESbundle.zip
,tDevice=ZIP) 
*/
/* SERVICESBASEURL */

/* Tests on SAS:

options mprint msglevel=N;

filename PACKAGES ("R:\" "C:\SAS_WORK\SAS_PACKAGES");

%relocatePackage(myPackage)

options nomprint msglevel=N;
%relocatePackage(baseplus SQLinDS macroarray, target=R:\abc, debug=1)
%relocatePackage(baseplus SQLinDS macroarray, target=R:\noDir)
%relocatePackage(baseplus SQLinDS macroarray, target=R:\bundle.zip, tDevice=zip)
%relocatePackage(baseplus SQLinDS macroarray, target=R:\, tDevice=FILESRVC) 

filename PACKAGES ("R:\testPackages1_NOT_EXIST" "R:\testPackages2_NOT_EXIST");
%relocatePackage(baseplus SQLinDS macroarray abc, source=R:\abc, debug=1, move=1)

filename PACKAGES ("R:\testPackages1" "R:\testPackages2");
%relocatePackage(baseplus SQLinDS macroarray abc, source=R:\abc, debug=1, move=1)
%relocatePackage(baseplus SQLinDS macroarray, source=R:\noDir, debug=1)

filename PACKAGES ("R:\testPackages2" "R:\testPackages1");
%relocatePackage(baseplus SQLinDS macroarray, source=R:\bundle.zip, sDevice=zip, move=1)
%relocatePackage(baseplus SQLinDS macroarray, source=R:\, sDevice=FILESRVC) 
%relocatePackage(baseplus SQLinDS macroarray, source=R:\bundle.zip, sDevice=zip, target=R:\bundle)
*/
/*%macro _();%mend _;*/
/**/

