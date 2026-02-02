/*+listPackages+*/
/*** HELP START ***//* 

  Macro to list SAS packages in packages folder. 

  Version 20260202 

  A SAS package is a zip file containing a group 
  of SAS codes (macros, functions, data steps generating 
  data, etc.) wrapped up together and %INCLUDEed by
  a single load.sas file (also embedded inside the zip).
  

 * Example 1: Set local packages directory, enable the framework,
              and list packages in the local repository.

  filename packages "C:\SAS_PACKAGES";
  %include packages(SPFinit.sas);
  %listPackages()

*//*** HELP END ***/


%macro listPackages(
  listDataSet /* Name of a data set to save results */
, quiet = 0   /* Indicate if results should be printed in log */
)/secure parmbuff
des = 'Macro to list SAS packages from `packages` fileref, type %listPackages(HELP) for help, version 20260202.'
;
%if (%QUPCASE(&listDataSet.) = HELP) %then
  %do;
    %local options_tmp ;
    %let options_tmp = ls=%sysfunc(getoption(ls)) ps=%sysfunc(getoption(ps))
     %sysfunc(getoption(notes)) %sysfunc(getoption(source))
     msglevel=%sysfunc(getoption(msglevel))
    ;
    options NOnotes NOsource ls=MAX ps=MAX msglevel=N;
    %put ;
    %put ###########################################################################################;
    %put ###       This is short help information for the `listPackages` macro                     #;
    %put #-----------------------------------------------------------------------------------------#;;
    %put #                                                                                         #;
    %put # Macro to list available SAS packages, version `20260202`                                #;
    %put #                                                                                         #;
    %put # A SAS package is a zip file containing a group                                          #;
    %put # of SAS codes (macros, functions, data steps generating                                  #;
    %put # data, etc.) wrapped up together and embedded inside the zip.                            #;
    %put #                                                                                         #;
    %put # The `%nrstr(%%listPackages())` macro lists packages available                                    #;
    %put # in the packages folder. List is printed in the SAS Log.                                 #;
    %put #                                                                                         #;
    %put #### Parameters:                                                                          #;
    %put #                                                                                         #;
    %put # 1. `listDataSet`  Name of a SAS data set to store results in.                           #;
    %put #                   No data set options are honored.                                      #;
    %put #                                                                                         #;
    %put # - `quiet=`      *Optional.* Indicates if the LOG printout should be suspended.          #;
    %put #                 Default value of zero (`0`) means "Do printout", other means "No".      #;
    %put #                                                                                         #;
    %put # When used as: `%nrstr(%%listPackages(HELP))` it displays this help information.                  #;
    %put #                                                                                         #;
    %put #-----------------------------------------------------------------------------------------#;
    %put #                                                                                         #;
    %put # Visit: `https://github.com/yabwon/SAS_PACKAGES/tree/main/SPF/Documentation`             #;
    %put # to learn more.                                                                          #;
    %put # Tutorials available at: `https://github.com/yabwon/HoW-SASPackages`                     #;
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
    %put  ;
    %put  %nrstr( %%listPackages(ListDS,quiet=1)        %%* save packages list in ListDS data set;          );
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
    %put ###########################################################################################;
    %put ;
    options &options_tmp.;
    %GOTO ENDoflistPackages;
  %end;

%local ls_tmp ps_tmp notes_tmp source_tmp listDataSetCheck ;

%let ls_tmp     = %sysfunc(getoption(ls));
%let ps_tmp     = %sysfunc(getoption(ps));
%let notes_tmp  = %sysfunc(getoption(notes));
%let source_tmp = %sysfunc(getoption(source));
%let listDataSetCheck=0;

%let quiet = %sysevalf(NOT(0=%superq(quiet)));

options NOnotes NOsource ls=MAX ps=MAX;

data _null_;
  length listDataSet $ 41;
  listDataSet = strip(scan(symget('listDataSet'),1,'( )'));
  call symputX('listDataSet',listDataSet,"L");
  if not (listDataSet = " ") then 
    call symputX('listDataSetCheck',1,"L");
  else call symputX('quiet',0,"L");
run;

data _null_ 
  %if 1=&listDataSetCheck. %then
    %do;
      &listDataSet.(compress=yes keep=k base PackageZIPNumber folder n tag value rename=(folder=PackageZIP k=baseNumber n=tagNumber))
    %end;
;
  length k 8 baseAll $ 32767 base $ 1024 PackageZIPNumber 8;
  baseAll = pathname("packages");

  array TAGSLIST[6] $ 16 _temporary_ ("PACKAGE" "TITLE" "VERSION" "AUTHOR" "MAINTAINER" "LICENSE");

  if baseAll = " " then
    do;
      put "WARNING: The file reference PACKAGES is not assigned.";
      stop;
    end;

  if char(baseAll,1) ^= "(" then baseAll = quote(strip(baseAll)); /* for paths with spaces */
  
  do k = 1 to kcountw(baseAll, "()", "QS"); /*drop k;*/
    base = dequote(kscanx(baseAll, k, "()", "QS"));

    length folder $ 64 file $ 1024 folderRef fileRef $ 8;

    folderRef = "_%sysfunc(datetime(), hex6.)0";

    rc=filename(folderRef, base);
    folderid=dopen(folderRef);

    %if 0=&quiet. %then 
      %do; 
        putlog " ";
        put "/*" 100*"+" ;
      %end;
    do i=1 to dnum(folderId); drop i;

      if i = 1 then
        do;
          %if 0=&quiet. %then 
            %do; 
              put " #";
              put " # Listing packages for: " base;
              put " #";
            %end;
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
              PackageZIPNumber+1;
              length nn $ 96;
              %if 0=&quiet. %then 
                %do; 
                  putlog " *  ";
                  if (96-lengthn(file)) < 1 then
                    put " * " file;  
                  else
                    do;
                      nn = repeat("*", (96-lengthn(file)));   
                      put " * " file nn;
                    end;
                %end;

              infile _DUMMY_ ZIP FILEVAR=file member="description.sas" end=EOF;
              
              n = 0;
              do lineinfile = 1 by 1 until(EOF);
                input;

                length tag $ 16 value $ 4096;

                tag = strip(upcase(kscanx(_INFILE_,1,":")));
                value = kscanx(_INFILE_,2,":");
                n = whichc(tag, of TAGSLIST[*]);

                if (n > 0) then
                  do;
                    %if 0=&quiet. %then 
                      %do; 
                        putlog " *  " tag +(-1) ":" @ 17 value;
                      %end;
                    %if 1=&listDataSetCheck. %then
                      %do;
                        output &listDataSet.;
                      %end;
                    n=0;
                  end;                
                if strip(upcase(strip(_INFILE_))) =: "DESCRIPTION START:" then leave;
              end;
            end;
        end;
      
      rc = dclose(fileId);
      rc = filename(fileRef);
    end;

    %if 0=&quiet. %then 
      %do; 
        putlog " *  ";
        put 100*"+" "*/";
      %end;
    rc = dclose(folderid);
    rc = filename(folderRef);
  end;

  stop;
  label
    k = "Packages path ordering number."
    base = "Packages path."
    PackageZIPNumber = "Packages ZIP file number."
    folder = "Packages ZIP file."
    n = "Tag number"
    tag = "Package Tag Name"
    value = "Value"
    ;
run;

%if 1=&listDataSetCheck. %then
  %do;
    proc sort data=&listDataSet. out=&listDataSet.(compress=yes label='Output from the %listPackages() macro');
      by baseNumber PackageZIPNumber tagNumber;
    run;

    %if 0=&quiet. %then 
      %do; 
        %put %str( );
        %put # Results provided in the &listDataSet. data set. #;
        %put %str( );
      %end;
  %end;

options ls = &ls_tmp. ps = &ps_tmp. &notes_tmp. &source_tmp.;

%ENDoflistPackages:
%mend listPackages;


