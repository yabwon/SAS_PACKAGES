/*+extendPackagesFileref+*/
/*** HELP START ***/

%macro extendPackagesFileref(
 packages /* A valid fileref name, 
             when empty the "packages" value is used */
)/secure
/*** HELP END ***/
des = 'Macro to list directories pointed by "packages" fileref, version 20240529. Run %extendPackagesFileref(HELP) for help info.'
;

%if %QUPCASE(&packages.) = HELP %then
  %do;
    %local options_tmp ;
    %let options_tmp = ls=%sysfunc(getoption(ls))ps=%sysfunc(getoption(ps))
     %sysfunc(getoption(notes)) %sysfunc(getoption(source))
     msglevel=%sysfunc(getoption(msglevel))
    ;
    options NOnotes NOsource ls=MAX ps=MAX msglevel=N;
    %put ;
    %put ###########################################################################################;
    %put ###       This is short help information for the `extendPackagesFileref` macro            #;
    %put #-----------------------------------------------------------------------------------------#;;
    %put #                                                                                         #;
    %put # Macro to list directories pointed by 'packages' fileref, version `20240529`             #;
    %put #                                                                                         #;
    %put # A SAS package is a zip file containing a group                                          #;
    %put # of SAS codes (macros, functions, data steps generating                                  #;
    %put # data, etc.) wrapped up together and embedded inside the zip.                            #;
    %put #                                                                                         #;
    %put # The `%nrstr(%%extendPackagesFileref())` macro lists directories pointed by                       #;
    %put # the packages fileref. It allows to add new directories to packages folder list.         #;
    %put #                                                                                         #;
    %put #### Parameters:                                                                          #;
    %put #                                                                                         #;
    %put # 1. `packages`      *Optional.* A valid fileref name, when empty the "packages" is used. #;
    %put #                       Use case:                                                         #;
    %put #                        `%nrstr(%%extendPackagesFileref()).`                                      #;
    %put #                                                                                         #;
    %put # When used as: `%nrstr(%%extendPackagesFileref(HELP))` it displays this help information.         #;
    %put #                                                                                         #;
    %put #-----------------------------------------------------------------------------------------#;
    %put #                                                                                         #;
    %put # Visit: `https://github.com/yabwon/SAS_PACKAGES/tree/main/SPF/Documentation`             #;
    %put # to learn more.                                                                          #;
    %put #                                                                                         #;
    %put #### Example ##############################################################################;
    %put #                                                                                         #;
    %put #   Enabling the SAS Package Framework                                                    #;
    %put #   from the local directory and adding                                                   #;
    %put #   new directory.                                                                        #;
    %put #                                                                                         #;
    %put #   Assume that the `SPFinit.sas` file                                                    #;
    %put #   is located in one of "C:/SAS_PK1" or "C:/SAS_PK2" folders.                            #;
    %put #                                                                                         #;
    %put #   Run the following code in your SAS session:                                           #;
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas;
    %put  %nrstr( filename packages ("C:/SAS_PK1" "C:/SAS_PK2"); %%* setup a directory for packages;        );
    %put  %nrstr( %%include packages(SPFinit.sas);               %%* enable the framework;                  );
    %put  ;
    %put  %nrstr( filename packages ("D:/NEW_DIR" %%extendPackagesFileref()); %%* add new directory;        );
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
    %put ###########################################################################################;
    %put ;
    options &options_tmp.;
    %GOTO ENDextendPackagesFileref;
  %end;

  %if %superq(packages) = %then %let packages = packages;
  %if %qsysfunc(pathname(&packages.)) ne %then
    %do;
      %if %qsubstr(%qsysfunc(pathname(&packages.)), 1, 1) = %str(%() %then
        %do;
          %local length;
          %let length = %eval(%length(%qsysfunc(pathname(&packages.)))-2);
          %unquote(%qsubstr(%qsysfunc(pathname(&packages.)), 2, &length.))
        %end;
      %else "%sysfunc(pathname(&packages.))";
  %end;
%ENDextendPackagesFileref:
%mend extendPackagesFileref; 

/* Examples:

filename packages "C:\";
%include packages(SPFinit.sas)

%extendPackagesFileref(HELP)

filename packages (%extendPackagesFileref() "D:\");
filename packages list;

filename packages clear;

filename packages "C:\";
filename packages ("D:\" %extendPackagesFileref());
filename packages list;

%put *%extendPackagesFileref()*;



*/

