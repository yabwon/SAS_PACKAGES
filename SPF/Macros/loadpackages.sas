/*+headerPackage+*/
/**############################################################################**/
/*                                                                              */
/*  Copyright Bartosz Jablonski, since July 2019 onward.                        */
/*                                                                              */
/*  Code is free and open source. If you want - you can use it.                 */
/*  I tested it the best I could                                                */
/*  but it comes with absolutely no warranty whatsoever.                        */
/*  If you cause any damage or something - it will be your own fault.           */
/*  You have been warned! You are using it on your own risk.                    */
/*  However, if you decide to use it do not forget to mention author:           */
/*  Bartosz Jablonski (yabwon@gmail.com)                                        */
/*                                                                              */
/*  Here is the official version:                                               */
/*
  Copyright (c) 2019 - 2026 Bartosz Jablonski (yabwon@gmail.com)

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included 
  in all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.
                                                                                */
/**############################################################################**/

/*** HELP START ***/
/* SPF (SAS Packages Framework) is a set of macros: 
   - to install, 
   - to load, 
   - to get help, 
   - to unload, or 
   - to generate SAS packages.

  SAS Packages Framework, version 20260710.
  See examples below.

  A SAS package is a zip file containing a group of files
  with SAS code (macros, functions, data steps generating 
  data, etc.) wrapped up together and %INCLUDEed by
  a single load.sas file (also embedded inside the zip).

Contributors: 
- Stu Sztukowski 
    LinkedIn: https://www.linkedin.com/in/statsguy/ 
    GitHub: https://github.com/stu-code
- Ken Nakamatsu 
    LinkedIn: https://www.linkedin.com/in/k-nkmt 
    GitHub: https://github.com/k-nkmt

*/
/*** HELP END ***/

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
des = 'Macro to load multiple SAS packages at one run, version 20260710. Run %loadPackages(HELP) for help info.'
parmbuff
;
%if (%superq(packagesNames) = ) OR (%qupcase(&packagesNames.) = HELP) %then
  %do;
    %local options_tmp ;
    %let options_tmp = ls=%sysfunc(getoption(ls)) ps=%sysfunc(getoption(ps))
     %sysfunc(getoption(notes)) %sysfunc(getoption(source))
     msglevel=%sysfunc(getoption(msglevel))
    ;
    options NOnotes NOsource ls=MAX ps=MAX msglevel=N;
    %put ;
    %put #################################################################################;
    %put ###      This is short help information for the `loadPackageS` macro            #;
    %put #-------------------------------------------------------------------------------#;
    %put #                                                                               #;
    %put # Macro wrapper for the loadPackage macro, version `20260710`                   #;
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
    %put # Tutorials available at: `https://github.com/yabwon/HoW-SASPackages`           #;
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
    %put  %nrstr( %%loadPackageS(SQLinDS, DFA)    %%* load packages content into the SAS session; );
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
    %put #################################################################################;
    %put ;
    options &options_tmp.;
    %GOTO ENDofloadPackageS;
  %end;
  
  %local lengthOfsyspbuff numberOfPackagesNames i packageElement packageName packageVersion str;

  %let lengthOfsyspbuff      = %qsysfunc(length(&syspbuff.));
  %let packagesNames         = %qsysfunc(compress(%qsubstr(&syspbuff., 2, %eval(&lengthOfsyspbuff.-2)), {[(. <=>_,)]}, KDA));
  
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


