/*** HELP START ***/      

/**############################################################################**/
/*                                                                              */
/*  Copyright Bartosz Jablonski, July 2019.                                     */
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
  Copyright (c) 2019 Bartosz Jablonski (yabwon@gmail.com)

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
/**#############################################################################**/

/* Macros to install SAS packages, version 20200603  */
/* A SAS package is a zip file containing a group of files
   with SAS code (macros, functions, datasteps generating 
   data, etc.) wrapped up together and %INCLUDEed by
   a single load.sas file (also embedded inside the zip).
*/

/*** HELP END ***/

/*** HELP START ***/
%macro installPackage(
  packageName  /* package name, without the zip extension */
, sourcePath = /* location of the package, e.g. "www.some.page/", mind the "/" at the end */
, replace = 1  /* 1 = replace if the package already exist, 0 = otherwise */
)
/*** HELP END ***/
/
secure; 
  %local ls_tmp ps_tmp notes_tmp source_tmp fullstimer_tmp stimer_tmp msglevel_tmp;
  %let ls_tmp     = %sysfunc(getoption(ls));      
  %let ps_tmp     = %sysfunc(getoption(ps));      
  %let notes_tmp  = %sysfunc(getoption(notes));   
  %let source_tmp = %sysfunc(getoption(source));
  %let stimer_tmp = %sysfunc(getoption(stimer));
  %let fullstimer_tmp = %sysfunc(getoption(fullstimer)); 
  %let msglevel_tmp = %sysfunc(getoption(msglevel));  
  options NOnotes NOsource ls=MAX ps=MAX NOfullstimer NOstimer msglevel=N;

  %local in out;
  %let  in = i%sysfunc(md5(&packageName.),hex7.);
  %let out = o%sysfunc(md5(&packageName.),hex7.);

  /*options MSGLEVEL=i;*/
                           
  /*
  Reference:
  https://blogs.sas.com/content/sasdummy/2011/06/17/how-to-use-sas-data-step-to-copy-a-file-from-anywhere/
  */

  %if %superq(sourcePath)= %then
    %do;
      %let sourcePath = https://raw.githubusercontent.com/yabwon/SAS_PACKAGES/master/;
    %end;
  filename &in URL "&sourcePath.%lowcase(&packageName.).zip" recfm=N lrecl=1;
  filename &out    "%sysfunc(pathname(packages))/%lowcase(&packageName.).zip" recfm=N lrecl=1;
  /*
  filename in  list;
  filename out list;
  */ 
  /* copy the file byte-by-byte  */
  data _null_;
    length filein 8 out_path in_path $ 4096;
    out_path = pathname ("&out");
     in_path = pathname ("&in" );


    filein = fopen( "&in", 'S', 1, 'B');
    if filein = 0 then
      put "ERROR: Source file:" / 
          "ERROR- " in_path /
          "ERROR- is unavaliable!";    
    if filein > 0; 

    put @2 "Source information:";  
    infonum = FOPTNUM(filein);
    length infoname $ 32 infoval $ 128;
    do i=1 to coalesce(infonum, -1);
      infoname = FOPTNAME(filein, i);
      infoval  = FINFO(filein, infoname);
      put @4 infoname ":" 
        / @6 infoval
        ;
    end;
    rc = FCLOSE(filein);
    put;

    

    if FEXIST("&out") = 0 then 
      do;
        put @2 "Installing the &packageName. package.";
        rc = FCOPY("&in", "&out");
      end;
    else if FEXIST("&out") = 1 then 
      do;
        if symget("replace")="1" then
          do;
            put @2 "The following file will be replaced during "
              / @2 "instalation of the &packageName. package: " 
              / @5 out_path;
            rc = FDELETE("&out");
            rc = FCOPY("&in", "&out");
          end;
        else
          do;
            put @2 "The following file will NOT be replaced: " 
              / @5 out_path;
            rc = 1;
          end;
      end;
      
    put @2 "Done with return code " rc=;
  run;
   
  filename &in  clear;
  filename &out clear;
  options ls = &ls_tmp. ps = &ps_tmp. 
          &notes_tmp. &source_tmp. 
          &stimer_tmp. &fullstimer_tmp.
          msglevel=&msglevel_tmp.;
%mend installPackage;

/*** HELP START ***/
/* Example 1:

filename packages "C:/Users/&sysuserid/Desktop/download_test/";

%installPackage(SQLinDS);
%installPackage(SQLinDS);
%installPackage(SQLinDS,replace=0);


%installPackage(NotExistingPackage);

*/
/*** HELP END ***/
