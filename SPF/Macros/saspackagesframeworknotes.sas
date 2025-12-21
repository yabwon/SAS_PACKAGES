/*+SasPackagesFrameworkNotes+*/
%macro SasPackagesFrameworkNotes(
SPFmacroName /* space separated list of names */
)
/
minoperator 
secure
des = 'Macro to provide help notes about SAS Packages Framework macros, version 20251221. Run %SasPackagesFrameworkNotes(HELP) for help info.'
;
%local list N i element;
%let list=
installPackage
listPackages
/**/
verifyPackage
previewPackage
helpPackage
/**/
loadPackage
loadPackageS
loadPackageAddCnt
/**/
unloadPackage
/**/
generatePackage
splitCodeForPackage
/**/
extendPackagesFileref
relocatePackage
isPackagesFilerefOK
/**/
SasPackagesFrameworkNotes
;
%let N = %sysfunc(countw(&list.));

%let SPFmacroName = %sysfunc(compress(%superq(SPFmacroName),_ *,KAD));

%if (%qupcase(&SPFmacroName.) = HELP) %then
  %do;
    %local options_tmp ;
    %let options_tmp = ls=%sysfunc(getoption(ls))ps=%sysfunc(getoption(ps))
     %sysfunc(getoption(notes)) %sysfunc(getoption(source))
     msglevel=%sysfunc(getoption(msglevel)) 
     %sysfunc(getoption(mprint)) %sysfunc(getoption(mlogic)) %sysfunc(getoption(symbolgen))
    ;
    options NOnotes NOsource ls=MAX ps=MAX msglevel=N NOmprint NOmlogic NOsymbolgen;
    %put ;
    %put #################################################################################;
    %put ###   This is short help information for the `SasPackagesFrameworkNotes` macro  #;
    %put #-------------------------------------------------------------------------------#;
    %put #                                                                               #;
    %put # Macro prints help notes for SAS Packages Framework macros, version `20251221` #;
    %put #                                                                               #;
    %put # A SAS package is a zip file containing a group                                #;
    %put # of SAS codes (macros, functions, data steps generating                        #;
    %put # data, etc.) wrapped up together and included by                               #;
    %put # a single `load.sas` file (also embedded inside the zip).                      #;
    %put #                                                                               #;
    %put # The `%nrstr(%%SasPackagesFrameworkNotes())` macro provides help notes about          #;
    %put # components of the SAS Packages Framework.                                     #;
    %put #                                                                               #;
    %put #-------------------------------------------------------------------------------#;
    %put #### Parameters:                                                                #;
    %put #                                                                               #;
    %put # 1. `SPFmacroName`     *Required.* Names of a SPF components.                  #;
    %put #                       Names should be space separated, asterisk(*) is         #;
    %put #                       allowed too. In such case ALL help notes are printed    #;
    %put #                       If equal `HELP` displays this help information.         #;
    %put #                       If empty displays list of SPF macros.                   #;
    %put #                                                                               #;
    %put #-------------------------------------------------------------------------------#;
    %put #                                                                               #;
    %put # Visit: `https://github.com/yabwon/SAS_PACKAGES/tree/main/SPF/Documentation`   #;
    %put # to learn more.                                                                #;
    %put # Tutorials available at: `https://github.com/yabwon/HoW-SASPackages`           #;
    %put #                                                                               #;
    %put ### Example 1 ###################################################################;
    %put #                                                                               #;
    %put #   Run the following code to print all SPF help notes:                         #;
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas;
    %put  %nrstr( %%SasPackagesFrameworkNotes(*)       %%* print ALL notes;               );
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
    %put #                                                                               #;
    %put ### Example 2 ###################################################################;
    %put #                                                                               #;
    %put #   Run the following code to list all SPF macros:                              #;
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas;
    %put  %nrstr( %%SasPackagesFrameworkNotes()        %%* list all macro names;          );
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
    %put #                                                                               #;
    %put ### Example 3 ###################################################################;
    %put #                                                                               #;
    %put #   Run the following code to print help notes:                                 #;
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas;
    %put  %nrstr( %%SasPackagesFrameworkNotes(generatePackage helpPackage)                );
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
    %put #                                                                               #;
    %put #################################################################################;
    %put ;
    options &options_tmp.;
    %GOTO ENDofSPFNotes;
  %end;

%if %sysevalf(%superq(SPFmacroName)=,boolean) %then
  %do;
    %put ================================================================;
    %put %str( ) SAS Packages Framework provides the following macros:;
    %put ================================================================;
    %do i = 1 %to &N.;
      %let element = %scan(&list., &i.);
      %if &i. IN (3 6 9 10 12) %then %put %str( );
      %if &i. > 9 %then %put %str( )&i.. %NRSTR(%%)&element.();
                  %else %put %str(  )&i.. %NRSTR(%%)&element.();
    %end;
    %put =================================================================;
  %end;
%else %if %str(*) IN (%superq(SPFmacroName)) %then
  %do;
    %do i = 1 %to &N.;
      %let element = %scan(&list., &i.);
      %put %str( );
      %put ======;
      %&element.(HELP)
      %put ======;
    %end;
  %end;
%else
  %do;
    %let N = %sysfunc(countw(%superq(SPFmacroName)));
    %do i = 1 %to &N.;
      %let element = %qupcase(%scan(%superq(SPFmacroName), &i.));
      %if %superq(element) in (%upcase(&LIST.)) %then
        %do;
          %let element = %unquote(&element.);
          %put %str( );
          %put ======;
          %&element.(HELP);
          %put ======;
        %end;
      %else 
        %do;
          %put %str( );
          %put ***!***!***!***!***!***!***!***!***!***!***!***!***!***!***!***!***!***!***!***;
          %put WARNING: Cannot recognise name: %superq(element).;
          %put WARNING- Valid values are: %superq(list);
          %put ***!***!***!***!***!***!***!***!***!***!***!***!***!***!***!***!***!***!***!***;
        %end;
    %end;
  %end;

%ENDofSPFNotes:
%mend SasPackagesFrameworkNotes;

/*
%SasPackagesFrameworkNotes()
%SasPackagesFrameworkNotes(HELP)
options mlogic symbolgen;
%SasPackagesFrameworkNotes(generatePackage)
%SasPackagesFrameworkNotes(generatePackage helpPackage)
%SasPackagesFrameworkNotes(generatePackage helpPackages SasPackagesFrameworkNotes isPackagesFilerefOK)
%SasPackagesFrameworkNotes(*)
*/


/* end of SPFinit.sas file */ 
