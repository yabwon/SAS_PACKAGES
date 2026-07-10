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

/*+isPackagesFilerefOK+*/
/*** HELP START ***/
%macro isPackagesFilerefOK(
vERRb /* indicates if macro should be verbose and report errors */
)
/ minoperator PARMBUFF
des = 'Macro to check if the PACKAGES fileref is "correct", type %isPackagesFilerefOK(HELP) for help, version 20260710.'
;
/*** HELP END ***/
%if %QUPCASE(&SYSPBUFF.) = %str(%(HELP%)) %then
  %do;
    %local options_tmp ;
    %let options_tmp = ls=%sysfunc(getoption(ls)) ps=%sysfunc(getoption(ps))
     %sysfunc(getoption(notes)) %sysfunc(getoption(source))
     msglevel=%sysfunc(getoption(msglevel))
    ;
    options NOnotes NOsource ls=MAX ps=MAX msglevel=N;
    %put ;
    %put ###########################################################################################;
    %put ###       This is short help information for the `isPackagesFilerefOK` macro              #;
    %put #-----------------------------------------------------------------------------------------#;;
    %put #                                                                                         #;
    %put # Macro to check if the `packages` fileref is "correct", version `20260710`               #;
    %put #                                                                                         #;
    %put # A SAS package is a zip file containing a group                                          #;
    %put # of SAS codes (macros, functions, data steps generating                                  #;
    %put # data, etc.) wrapped up together and embedded inside the zip.                            #;
    %put #                                                                                         #;
    %put # The `%nrstr(%%isPackagesFilerefOK())` macro checks if the `packages` fileref                     #;
    %put # is correct, i.e. all listed directories exist, are accessible (can be open), and        #;
    %put # are assigned with the DISK device.                                                      #;
    %put #                                                                                         #;
    %put # The Macro works as a macro function. It returns `1` wher everything is ok, and          #;
    %put # it returns `0` if at least one issue exists.                                            #;
    %put #                                                                                         #;
    %put #### Parameters:                                                                          #;
    %put #                                                                                         #;
    %put # 1. `vERRb`  - *Optional* Indicates if the macro should return value AND be verbose      #;
    %put #               (e.g., print errors and notes) or just return value.                      #;
    %put #                                                                                         #;
    %put # When used as: `%nrstr(%%isPackagesFilerefOK(HELP))` it displays this help information.           #;
    %put #                                                                                         #;
    %put #-----------------------------------------------------------------------------------------#;
    %put #                                                                                         #;
    %put # Visit: `https://github.com/yabwon/SAS_PACKAGES/tree/main/SPF/Documentation`             #;
    %put # to learn more.                                                                          #;
    %put # Tutorials available at: `https://github.com/yabwon/HoW-SASPackages`                     #;
    %put #                                                                                         #;
    %put #### Example ##############################################################################;
    %put #                                                                                         #;
    %put #   Enabling the SAS Package Framework from the local                                     #;
    %put #   directory, expanding PACKAGES fileref, and checking                                   #;
    %put #   if the new one is still correct for installing new package.                           #;
    %put #                                                                                         #;
    %put #   Assume that the `SPFinit.sas` file                                                    #;
    %put #   is located in the "/sas/PACKAGES/" directory.                                         #;
    %put #                                                                                         #;
    %put #   Run the following code in your SAS session:                                           #;
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas;
    %put  %nrstr( filename packages "/sas/PACKAGES";                        %%* set packages filename;);
    %put  %nrstr( %%include packages(SPFinit.sas);                           %%* enable the framework;);
    %put  ;
    %put  %nrstr( filename packages ("~/myPCKGs" %%extendPackagesFileref()); %%* add new directory;   );
    %put  ;
    %put  %nrstr( %if %%IsPackagesFilerefOK() %%then                          %%* check fileref;      );
    %put  %nrstr(   %%do; %%InstallPackage(SQLinDS) %%end;                     %%* install SQLinDS;   );
    %put  ;
    %put  %nrstr( %%listPackages()                                           %%* list packages;       );
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
    %put ###########################################################################################;
    %put ;
    options &options_tmp.;
    %GOTO ENDofIsPackagesFilerefOK;
  %end;

%if NOT (%superq(vERRb) in (0 1)) %then %let vERRb = 0;

%local isPackagesFilerefOK;
%let isPackagesFilerefOK=1;

%local dsid rc nobs i XENGINE XPATH dirid _F_;
%let dsid = %sysfunc(OPEN(sashelp.vextfl(where=(fileref="PACKAGES"))));
%let nobs = %sysfunc(ATTRN(&dsid., nlobsf));
/*%put &=dsid. &=nobs.;*/

%if &nobs. AND 1=&vERRb. %then %put INFO: PACKAGES fileref is: %sysfunc(pathname(PACKAGES));

%let isPackagesFilerefOK=%sysevalf(&nobs. AND 1, boolean);           

%do i = 1 %to &nobs.;
    %let rc=%sysfunc(FETCHOBS(&dsid., &i.));
    %let XENGINE=%sysfunc(GETVARC(&dsid., %sysfunc(VARNUM(&dsid., XENGINE))));
    %let XPATH=%sysfunc(GETVARC(&dsid., %sysfunc(VARNUM(&dsid., XPATH))));

    %put %superq(XENGINE) %superq(XPATH);
    %if DISK ne %superq(XENGINE) %then 
      %do;
        %let isPackagesFilerefOK=0;
        %if 1=&vERRb. %then
          %do;
            %if %superq(XENGINE) = SASFSVAM %then %let XENGINE= FILESRVC (SASFSVAM);
            %put ERROR: The %superq(XENGINE) is illegal! Only the DISK device is correct.;
          %end;
      %end;
    %else %if 0=%sysfunc(fileexist(%superq(XPATH))) %then 
      %do;
        %let isPackagesFilerefOK=0;
        %if 1=&vERRb. %then
          %do;
            %put ERROR: Path: %superq(XPATH) does NOT exist!;
          %end;
      %end;
    %else
      %do;
        %let rc = %sysfunc(FILENAME(_F_, %superq(XPATH)));
        %let dirid = %sysfunc(DOPEN(&_F_.));
        %let isPackagesFilerefOK=%sysevalf(&dirid. AND 1, boolean);
        %let dirid = %sysfunc(DCLOSE(&dirid.));
        %let rc = %sysfunc(FILENAME(_F_));
        %if 1=&vERRb. AND 0=&isPackagesFilerefOK. %then
          %do;
            %put ERROR: Path: %superq(XPATH) cannot be open!;
            %put ERROR- It may not be a directory or your access rights are insuficient.;
          %end;
      %end;
%end;

%let dsid = %sysfunc(CLOSE(&dsid.));

%if 1=&vERRb. %then
  %do;
    %if &isPackagesFilerefOK.=1 %then
      %do;
        %put %str( );
        %put INFO: The PACKAGES fileref is OK. Enjoy!;
        %put %str( );
      %end;
    %else
      %do;
        %put %str( );
        %put ERROR: The PACKAGES fileref is incorrect!;
        %put %str( );
      %end;
  %end;
/* result */
%do;&isPackagesFilerefOK.%return;%end;
%ENDofIsPackagesFilerefOK:
%mend isPackagesFilerefOK;

