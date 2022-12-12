/*+loadPackageS+*/
/*** HELP START ***/

%macro loadPackageS(
  packagesNames /* A comma separated list of packages names, 
                   e.g. myPackage, myPackage1, myPackage2, myPackage3  
                   required and not null.  
                   Package version, in brackets behind a package name, 
                   can be provided, e.g.
                    %loadPackageS(myPackage1(1.7), myPackage2(4.2))
                 */
)/secure 
/*** HELP END ***/
des = 'Macro to load multiple SAS packages at one run, version 20221212. Run %loadPackages() for help info.'
parmbuff
;
%if (%superq(packagesNames) = ) OR (%qupcase(&packagesNames.) = HELP) %then
  %do;
    %local options_tmp ;
    %let options_tmp = ls=%sysfunc(getoption(ls))ps=%sysfunc(getoption(ps))
     %sysfunc(getoption(notes)) %sysfunc(getoption(source))
     msglevel=%sysfunc(getoption(msglevel))
    ;
    options NOnotes NOsource ls=MAX ps=MAX msglevel=N;
    %put ;
    %put #################################################################################;
    %put ###      This is short help information for the `loadPackageS` macro            #;
    %put #-------------------------------------------------------------------------------#;
    %put #                                                                               #;
    %put # Macro wrapper for the loadPackage macro, version `20221212`                   #;
    %put #                                                                               #;
    %put # A SAS package is a zip file containing a group                                #;
    %put # of SAS codes (macros, functions, data steps generating                        #;
    %put # data, etc.) wrapped up together and embedded inside the zip.                  #;
    %put #                                                                               #;
    %put # The `%nrstr(%%loadPackageS())` allows to load multiple packages at one time,           #;
    %put # *ONLY* from the *ZIP* with *DEFAULT OPTIONS*, into the SAS session.           #;
    %put #                                                                               #;
    %put #### Parameters:                                                                #;
    %put #                                                                               #;
    %put # 1. `packagesNames`  A comma separated list of packages names,                 #;
    %put #                     e.g. myPackage, myPackage1, myPackage2, myPackage3        #;
    %put #                     Required and not null, default use case:                  #;
    %put #                      `%nrstr(%%loadPackageS(myPackage1, myPackage2, myPackage3))`.     #;
    %put #                     Package version, in brackets behind a package name, can   #;
    %put #                     be provided, example is the following:                    #;
    %put #                      `%nrstr(%%loadPackageS(myPackage1(1.7), myPackage2(4.2)))`.       #;
    %put #                     If empty displays this help information.                  #;
    %put #                                                                               #;
    %put #                                                                               #;
    %put #-------------------------------------------------------------------------------#;
    %put #                                                                               #;
    %put # Visit: `https://github.com/yabwon/SAS_PACKAGES/tree/main/SPF/Documentation`   #;
    %put # to learn more.                                                                #;
    %put #                                                                               #;
    %put #### Example ####################################################################;
    %put #                                                                               #;
    %put #   Enabling the SAS Package Framework                                          #;
    %put #   from the local directory and installing & loading                           #;
    %put #   the SQLinDS package from the Internet.                                      #;
    %put #                                                                               #;
    %put #   Assume that the `SPFinit.sas` file                                          #;
    %put #   is located in the "C:/SAS_PACKAGES/" folder.                                #;
    %put #                                                                               #;
    %put #   Run the following code in your SAS session:                                 #;
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas;
    %put  %nrstr( filename packages "C:/SAS_PACKAGES"; %%* setup a directory for packages;        );
    %put  %nrstr( %%include packages(SPFinit.sas);      %%* enable the framework;                 );
    %put  ;
    %put  %nrstr( %%installPackage(SQLinDS DFA)  %%* install packages from the Internet;          );
    %put  %nrstr( %%loadPackageS(SQLinDS, DFA)    %%* load packags content into the SAS session;  );
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
    %put #################################################################################;
    %put ;
    options &options_tmp.;
    %GOTO ENDofloadPackageS;
  %end;
  
  %local lengthOfsyspbuff numberOfPackagesNames i packageElement packageName packageVersion str;

  %let lengthOfsyspbuff      = %qsysfunc(length(&syspbuff.));
  %let packagesNames         = %qsysfunc(compress(%qsubstr(&syspbuff., 2, %eval(&lengthOfsyspbuff.-2)), {[(. _,)]}, KDA));
  
  %let str = %qsysfunc(translate(%superq(packagesNames),[[ ]],{(,)}));
  %let str = %qsysfunc(transtrn(%superq(str),],%str(] )));
  %let str = %qsysfunc(compbl(%superq(str)));
  %let str = %qsysfunc(transtrn(%superq(str),%str([ ),[));
  %let str = %qsysfunc(transtrn(%superq(str),%str( [),[));
  %let str = %qsysfunc(transtrn(%superq(str),%str( ]),]));
  %let str = %qsysfunc(translate(%superq(str),(),[]));
  %let packagesNames = %unquote(&str.);
  
  %let numberOfPackagesNames = %qsysfunc(countw(&packagesNames., %str( )));

  %put NOTE: List of packages to be loaded contains &numberOfPackagesNames. element(s).;
  %put NOTE- The list is: &packagesNames..;
  %put NOTE- ;

  %do i = 1 %to &numberOfPackagesNames.;
    %let packageElement = %qscan(&packagesNames., &i., %str( ) );
    %let packageName    = %qscan(&packageElement.,  1, %str(()));
    %let packageVersion = %qscan(&packageElement.,  2, %str(()));
    %if %superq(packageVersion) = %then %let packageVersion = .;

    %loadPackage(%unquote(&packageName.), requiredVersion=%unquote(&packageVersion.))
  %end;
  
%ENDofloadPackageS:
%mend loadPackageS;


