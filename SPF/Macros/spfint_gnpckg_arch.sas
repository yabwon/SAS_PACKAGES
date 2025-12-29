/*+SPFint_gnPckg_arch+*/
%macro SPFint_gnPckg_arch()/secure minoperator
des='SAS Packages Framework internal macro. Executable only inside the %generatePackage() macro. The macro encapsulates the archive version generation part of the process. Version 20251228.';
/* macro picks up all macrovariables from external scope, so from the %generatePackage() macro */
%if %sysmexecname(%sysmexecdepth-1) in (GENERATEPACKAGE) %then
%do;
/*=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=*/

/*= generate files with version in the name START =========================================================================*/
/* to make archiving easier a copy of the package zip file
   with the version in the name is created */
%if %superq(easyArch) NE 1 %then %let easyArch=0;

%if %superq(easyArch) = 1 %then
%do;
  %put NOTE-;
  %put NOTE: Creating files with version in the name.;
  %put NOTE- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^;
  %put NOTE-;

  %local notesSourceOptions;
  %let notesSourceOptions = %sysfunc(getoption(notes)) %sysfunc(getoption(source));
  options NOnotes NOsource;

  %if %sysevalf(%superq(archLocation)=,boolean) %then
    %do;
      %let archLocation = &buildLocation.;
    %end;
  %else
    %do;
      %if 0=%sysfunc(FILEEXIST(%superq(archLocation))) %then
        %do;
          %put WARNING: The archLocation=%superq(archLocation) directory does NOT exist!;
          %put WARNING- ;
          %put WARNING- The %superq(buildLocation) directory will be used.;
          %let archLocation = &buildLocation.;
        %end;
    %end;
  %put NOTE: Arch location is: %superq(archLocation).;

  %local archSufixList i archSfx;
  /* by default list is only: "zip" */
  %let archSufixList=zip;
  /* if markdown is generated then "md" is added to the list */
  %if &markdownDoc.=1 %then %let archSufixList = &archSufixList. md;

  /* zip (md) */
  %do i = 1 %to %sysfunc(countw(&archSufixList.));
    %let archSfx=%scan(&archSufixList.,&i.);
    filename &zipReferrence. "&buildLocation./%sysfunc(lowcase(&packageName.)).&archSfx." lrecl=1 recfm=n;
    filename &zipReferrence. list;
    filename &zipReferrenceV. "&archLocation./%sysfunc(lowcase(&packageName.))_&packageVersion._.&archSfx." lrecl=1 recfm=n;
    filename &zipReferrenceV. list;
    data _null_;
      if NOT fexist("&zipReferrence.") then 
        do;
          put "WARNING: No file to archive!";
          stop;
        end;
      fexist = fexist("&zipReferrenceV.");
      rc = fcopy("&zipReferrence.", "&zipReferrenceV.");
      length rctxt $ 32767;
      rctxt = sysmsg();
      if rc then
        do;
          put "ERROR: An error " rc "occurred during creation of %sysfunc(lowcase(&packageName.))_&packageVersion._.&archSfx. file.";
          put rctxt;
        end;
      else
        do;
          if fexist then put "Overwriting " @; 
                    else put "Creating " @; 
          put "%sysfunc(lowcase(&packageName.))_&packageVersion._.&archSfx. file.";
        end;
    run;
    filename &zipReferrence. clear;
    filename &zipReferrenceV. clear;
  %end;
  options &notesSourceOptions.;
%end;
/*= generate files with version in the name  END  =========================================================================*/

/*=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=*/
%end;
%else
  %do;
    %put INFO: SAS Packages Framework internal macro. Executable only inside the %nrstr(%%)generatePackage() macro.;
  %end;
%mend SPFint_gnPckg_arch;

/* END macros extracted outside generatePackage macro */


/*
TODO: (in Polish)

- modyfikacja helpa, sprawdzanie kodu danej funkcji/makra/typu [v]

- opcjonalne sortowanie nazw folderow(<numer>_<typ>) [v]

- wewnetrzna nazwa zmiennej z nazwa pakietu (na potrzeby kompilacji) [v]

- weryfikacja "niepustosci" obowiazkowych argumentow   [v]

- dodac typ "clear" do czyszczenia po plikach 'exec' [v]

- syspackages - makrozmienna z lista zaladowanych pakietow [v] (as SYSloadedPackages)

- dodac typ "iml" [v] (as imlmodule)

- dodac typ "proto" [v]

- lista wymaganych komponentow potrzebnych do dzialania SASa (na bazie proc SETINIT) [v]

- sparwdzanie domknietosci, parzystosci i wystepowania tagow HELP START - HELP END w plikach [v]

- add MD5(&packageName.) value hash instead "package" word in filenames [v]

- infolista o required packahes w unloadPackage [v]

- dodac ICEloadPackage() [v]

- weryfikacja nadpisywania makr [v]

- weryfikacja srodowiska [ ]

- dodac typ "ds2" [v]

- dodac mozliwosc szyfrowania pliku z pakietem (haslo do zip, sprawdzic istnienie funkcjonalnosci) [ ]

- doadc sprawdzanie liczby wywolan procedury fcmp, format i slowa '%macro(' w plikach z kodami [ ]

- dodac generowanie funkcji z helpem np. dla funkcji abc() mamy abc_help(), ktora wyswietla to samo co %heplPackage(package, abc()) [ ]
*/

/*** HELP START ***/  

/* Example 1: Enabling the SAS Package Framework 
    and generating the SQLinDS package from the local directory.

    Assume that the SPFinit.sas file and the SQLinDS 
    folder (containing all package components) are located in 
    the "C:/SAS_PACKAGES/" folder.

    Run the following code in your SAS session:

  filename packages "C:/SAS_PACKAGES"; %* setup a directory for packages; 
  %include packages(SPFinit.sas);      %* enable the framework;

  ods html;
  %generatePackage(filesLocation=C:/SAS_PACKAGES/SQLinDS)

*/

/*** HELP END ***/  

