/*+listPackages+*/

%macro listPackages()/secure PARMBUFF
des = 'Macro to list SAS packages from `packages` fileref, type %listPackages(HELP) for help, version 20221215.'
;
%if %QUPCASE(&SYSPBUFF.) = %str(%(HELP%)) %then
  %do;
    %local options_tmp ;
    %let options_tmp = ls=%sysfunc(getoption(ls))ps=%sysfunc(getoption(ps))
     %sysfunc(getoption(notes)) %sysfunc(getoption(source))
     msglevel=%sysfunc(getoption(msglevel))
    ;
    options NOnotes NOsource ls=MAX ps=MAX msglevel=N;
    %put ;
    %put ###########################################################################################;
    %put ###       This is short help information for the `listPackages` macro                     #;
    %put #-----------------------------------------------------------------------------------------#;;
    %put #                                                                                         #;
    %put # Macro to list available SAS packages, version `20221215`                                #;
    %put #                                                                                         #;
    %put # A SAS package is a zip file containing a group                                          #;
    %put # of SAS codes (macros, functions, data steps generating                                  #;
    %put # data, etc.) wrapped up together and embedded inside the zip.                            #;
    %put #                                                                                         #;
    %put # The `%nrstr(%%listPackages())` macro lists packages available                                    #;
    %put # in the packages folder. List is printed inthe SAS Log.                                  #;
    %put #                                                                                         #;
    %put #### Parameters:                                                                          #;
    %put #                                                                                         #;
    %put # NO PARAMETERS                                                                           #;
    %put #                                                                                         #;
    %put # When used as: `%nrstr(%%listPackages(HELP))` it displays this help information.                  #;
    %put #                                                                                         #;
    %put #-----------------------------------------------------------------------------------------#;
    %put #                                                                                         #;
    %put # Visit: `https://github.com/yabwon/SAS_PACKAGES/tree/main/SPF/Documentation`             #;
    %put # to learn more.                                                                          #;
    %put #                                                                                         #;
    %put #### Example ##############################################################################;
    %put #                                                                                         #;
    %put #   Enabling the SAS Package Framework                                                    #;
    %put #   from the local directory and listing                                                  #;
    %put #   available packages.                                                                   #;
    %put #                                                                                         #;
    %put #   Assume that the `SPFinit.sas` file                                                    #;
    %put #   is located in the "C:/SAS_PACKAGES/" folder.                                          #;
    %put #                                                                                         #;
    %put #   Run the following code in your SAS session:                                           #;
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas;
    %put  %nrstr( filename packages "C:/SAS_PACKAGES"; %%* setup a directory for packages;                  );
    %put  %nrstr( %%include packages(SPFinit.sas);      %%* enable the framework;                           );
    %put  ;
    %put  %nrstr( %%listPackages()                      %%* list available packages;                        );
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
    %put ###########################################################################################;
    %put ;
    options &options_tmp.;
    %GOTO ENDoflistPackages;
  %end;

%local ls_tmp ps_tmp notes_tmp source_tmp filesWithCodes;

%let filesWithCodes = WORK._%sysfunc(datetime(), hex16.)_;

%let ls_tmp     = %sysfunc(getoption(ls));
%let ps_tmp     = %sysfunc(getoption(ps));
%let notes_tmp  = %sysfunc(getoption(notes));
%let source_tmp = %sysfunc(getoption(source));

options NOnotes NOsource ls=MAX ps=MAX;

data _null_;
  length baseAll $ 32767;
  baseAll = pathname("packages");

  if baseAll = " " then
    do;
      put "NOTE: The file reference PACKAGES is not assigned.";
      stop;
    end;

  if char(baseAll,1) ^= "(" then baseAll = quote(strip(baseAll)); /* for paths with spaces */
  
  do k = 1 to kcountw(baseAll, "()", "QS"); drop k;
    base = dequote(kscanx(baseAll, k, "()", "QS"));

    length folder $ 64 file $ 1024 folderRef fileRef $ 8;

    folderRef = "_%sysfunc(datetime(), hex6.)0";

    rc=filename(folderRef, base);
    folderid=dopen(folderRef);

    putlog " ";
    put "/*" 100*"+" ;
    do i=1 to dnum(folderId); drop i;

      if i = 1 then
        do;
              put " #";
              put " # Listing packages for: " base;
              put " #";
        end;

      folder = dread(folderId, i);

      fileRef = "_%sysfunc(datetime(), hex6.)1";
      rc = filename(fileRef, catx("/", base, folder));
      fileId = dopen(fileRef);

      EOF = 0;
      if fileId = 0 and lowcase(kscanx(folder, -1, ".")) = 'zip' then 
        do;
          file = catx('/',base, folder);
          
          rc1 = filename("package", strip(file), 'zip', 'member="description.sas"');
          rcE = fexist("package"); 
          rc2 = filename("package", " ");

          if rcE then /* if the description.sas exists in the zip then read it */
            do;
              putlog " *  ";
              length nn $ 96;
              if (96-lengthn(file)) < 1 then
                put " * " file;  
              else
                do;
                  nn = repeat("*", (96-lengthn(file)));   
                  put " * " file nn;
                end;
              
              infile _DUMMY_ ZIP FILEVAR=file member="description.sas" end=EOF;
              
              do until(EOF);
                input;
                if strip(upcase(kscanx(_INFILE_,1,":"))) in ("PACKAGE" "TITLE" "VERSION" "AUTHOR" "MAINTAINER" "LICENSE") then
                  do;
                    _INFILE_ = kscanx(_INFILE_,1,":") !! ":" !! kscanx(_INFILE_,2,":");
                    putlog " *  " _INFILE_;
                  end;                
                if strip(upcase(strip(_INFILE_))) =: "DESCRIPTION START:" then leave;
              end;
            end;
        end;
      
      rc = dclose(fileId);
      rc = filename(fileRef);
    end;

    putlog " *  ";
    put 100*"+" "*/";
    rc = dclose(folderid);
    rc = filename(folderRef);
  end;

  stop;
run;

options ls = &ls_tmp. ps = &ps_tmp. &notes_tmp. &source_tmp.;

%ENDoflistPackages:
%mend listPackages;


/*** HELP START ***/

/* Macro to generate SAS packages.

   Version 20221215

   A SAS package is a zip file containing a group 
   of SAS codes (macros, functions, data steps generating 
   data, etc.) wrapped up together and %INCLUDEed by
   a single load.sas file (also embedded inside the zip).

   See examples below.
*/

/*** HELP END ***/

