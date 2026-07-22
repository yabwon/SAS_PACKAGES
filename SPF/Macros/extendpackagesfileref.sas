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

  SAS Packages Framework, version 20260721.
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

/*+extendPackagesFileref+*/
/*** HELP START ***/

%macro extendPackagesFileref(
 packages /* A valid fileref name, 
             when empty the "packages" value is used */
)/secure
/*** HELP END ***/
des = 'Macro to list directories pointed by "packages" fileref, version 20260721. Run %extendPackagesFileref(HELP) for help info.'
;

%if %QUPCASE(&packages.) = HELP %then
  %do;
    %local options_tmp ;
    %let options_tmp = ls=%sysfunc(getoption(ls)) ps=%sysfunc(getoption(ps))
     %sysfunc(getoption(notes)) %sysfunc(getoption(source))
     msglevel=%sysfunc(getoption(msglevel))
    ;
    options NOnotes NOsource ls=MAX ps=MAX msglevel=N;
    %put ;
    %put ###########################################################################################;
    %put ###       This is short help information for the `extendPackagesFileref` macro            #;
    %put #-----------------------------------------------------------------------------------------#;;
    %put #                                                                                         #;
    %put # Macro to list directories pointed by 'packages' fileref, version `20260721`             #;
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
    %put # Tutorials available at: `https://github.com/yabwon/HoW-SASPackages`                     #;
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
    %put  %nrstr( %%include packages(SPFinit.sas);                %%* enable the framework;                  );
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

