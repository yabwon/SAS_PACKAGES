/*** HELP START ***/

/**############################################################################**/
/*                                                                              */
/*  Copyright Bartosz Jablonski, September 2019.                                */
/*                                                                              */
/*  Code is free and open source. If you want - you can use it.                 */
/*  I tested it the best I could                                                */
/*  but it comes with absolutely no warranty whatsoever.                        */
/*  If you cause any damage or something - it will be your own fault.           */
/*  You've been warned! You are using it on your own risk.                      */
/*  However, if you decide to use it don't forget to mention author:            */
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

/* Macros to generte SAS packages */
/* A SAS package is a zip file containing a group 
   of SAS codes (macros, functions, datasteps generating 
   data, etc.) wrapped up together and %INCLUDEed by
   a single load.sas file (also embeaded inside the zip).
*/

/*** HELP END ***/


/*** HELP START ***/
%macro GeneratePackge(
 filesLocation=%sysfunc(pathname(work))/%lowcase(&packageName.) /* place for packages' files */
)/secure;
/*** HELP END ***/
%local zipReferrence filesWithCodes _DESCR_ _LIC_ _RC_;
%let   zipReferrence = _%sysfunc(datetime(), hex6.)_;
%let   filesWithCodes = WORK._%sysfunc(datetime(), hex16.)_;
%let   _DESCR_ = _%sysfunc(datetime(), hex6.)d;
%let   _LIC_   = _%sysfunc(datetime(), hex6.)l;

/* collect package metadata from the description.sas file */
filename &_DESCR_. "&filesLocation./description.sas" lrecl = 256;
/* file contains licence */
filename &_LIC_.   "&filesLocation./license.sas" lrecl = 256;

%if %sysfunc(fexist(&_DESCR_.)) %then 
  %do;
    %put NOTE: Creating package%str(%')s metadata; 

    %local packageName        /* name of the package, required */  
           packageVersion     /* version of the package, required */
           packageTitle       /* title of the package, required*/
           packageAuthor      /* required */
           packageMaintainer  /* required */
           packageEncoding    /* required */
           packageLicense     /* required */
           packageRequired    /* optional */
           packageReqPackages /* optional */
           ;
    data _null_;
      infile &_DESCR_.;
      input;
    
      select;
        when(upcase(scan(_INFILE_, 1, ":")) = "PACKAGE")     call symputX("packageName",        scan(_INFILE_, 2, ":"),"L");
        when(upcase(scan(_INFILE_, 1, ":")) = "VERSION")     call symputX("packageVersion",     scan(_INFILE_, 2, ":"),"L");
        when(upcase(scan(_INFILE_, 1, ":")) = "AUTHOR")      call symputX("packageAuthor",      scan(_INFILE_, 2, ":"),"L");
        when(upcase(scan(_INFILE_, 1, ":")) = "MAINTAINER")  call symputX("packageMaintainer",  scan(_INFILE_, 2, ":"),"L");
        when(upcase(scan(_INFILE_, 1, ":")) = "TITLE")       call symputX("packageTitle",       scan(_INFILE_, 2, ":"),"L");
        when(upcase(scan(_INFILE_, 1, ":")) = "ENCODING")    call symputX("packageEncoding",    scan(_INFILE_, 2, ":"),"L");
        when(upcase(scan(_INFILE_, 1, ":")) = "LICENSE")     call symputX("packageLicense",     scan(_INFILE_, 2, ":"),"L");
        when(upcase(scan(_INFILE_, 1, ":")) = "REQUIRED")    call symputX("packageRequired",    scan(_INFILE_, 2, ":"),"L");
        when(upcase(scan(_INFILE_, 1, ":")) = "REQPACKAGES") call symputX("packageReqPackages", scan(_INFILE_, 2, ":"),"L");

        /* stop at the begining of description */
        when(upcase(scan(_INFILE_, 1, ":")) = "DESCRIPTION START") stop;
        otherwise;
      end;
    run;
 
    /* test for required descriptors */
    %if (%nrbquote(&packageName.) = )
     or (%nrbquote(&packageVersion.) = )
     or (%nrbquote(&packageAuthor.) = )
     or (%nrbquote(&packageMaintainer.) = )
     or (%nrbquote(&packageTitle.) = )
     or (%nrbquote(&packageEncoding.) = )
     or (%nrbquote(&packageLicense.) = )
      %then
        %do;
          %put ERROR: At least one of descriptors is missing!;
          %put ERROR- They are required to create package.;
          %put ERROR- &=packageName.;
          %put ERROR- &=packageTitle.;
          %put ERROR- &=packageVersion.;
          %put ERROR- &=packageAuthor.;
          %put ERROR- &=packageMaintainer.;
          %put ERROR- &=packageEncoding.;
          %put ERROR- &=packageLicense.; 
          %put ERROR- ;
          %abort;
        %end;
    /* test for package name */
    %if %sysfunc(lengthn(&packageName.)) > 24 %then
      %do;
        %put ERROR: Package name is more than 24 characters long.;
        %put ERROR- The name is used for functions%str(%') dataset name;
        %put ERROR- and for formats%str(%') catalog name (with sufix).;
        %put ERROR- The length is %sysfunc(lengthn(&packageName.)). Try something shorter.;
        %abort;
      %end;
    %else %if %sysfunc(lengthn(&packageName.)) < 3 %then
            %do;
              %put WARNING: Package name is less than 3 characters.;
              %put WARNING- Maybe consider some _meaningful_ name?;
            %end;
    /* test characters in package name */
    %if %qsysfunc(lengthn(%qsysfunc(compress(&packageName.,,KDF)))) NE %qsysfunc(lengthn(&packageName.)) %then
      %do;
        %put ERROR: Package name contains illegal symbols.;
        %put ERROR- The name is used for functions%str(%') dataset name;
        %put ERROR- and for formats%str(%') catalog name.;
        %put ERROR- Only English letters, underscore(_), and digits are allowed.;
        %put ERROR- Try something else. Maybe: %qsysfunc(compress(&packageName.,,KDF)) will do?;
        %abort;
      %end;

  %end;
%else
  %do;
    %put ERROR: The description.sas file is missing!;
    %put ERROR- The file is required to create package%str(%')s metadata;
    %abort;
  %end;

/* test if version is a number */
data _null_;
  version = input("&packageVersion.", ?? best32.);
  if not (version > 0) then
    do;
      put 'ERROR: Package version should be a positive NUMBER.';
      put 'ERROR- Current value is: ' "&packageVersion.";
      put 'ERROR- Try something small, e.g. 0.1';
      put;
      abort;
    end;
run;

/* create or replace the ZIP file for package  */
filename &zipReferrence. ZIP "&filesLocation./%lowcase(&packageName.).zip";

%if %sysfunc(fexist(&zipReferrence.)) %then 
  %do;
    %put NOTE: Deleting file "&filesLocation./%lowcase(&packageName.).zip";
    %let _RC_ = %sysfunc(fdelete(&zipReferrence.));
  %end;

/*** HELP START ***/
/* 
  Locate all files with code in base folder (i.e. at filesLocation directory) 
*/
/*
  Remember to prepare the description.sas file for you package.
  The collon (:) is a field separator and is restricted 
  in lines of the header part.                          
  The file should contain the following obligatory information:
--------------------------------------------------------------------------------------------
>> **HEADER** <<
Type: Package
Package: ShortPackageName                                
Title: A title/brief info for log note about your packages                 
Version: X.Y                                    
Author: Firstname1 Lastname1 (xxxxxx1@yyyyy.com), Firstname2 Lastname2 (xxxxxx2@yyyyy.com)     
Maintainer: Firstname Lastname (xxxxxx@yyyyy.com)
License: MIT
Encoding: UTF8                                  

Required: "Base SAS Software"                    :%*optional, COMMA separated, QUOTED list, names of required SAS products, values must be like from proc setinit;run; output *;
ReqPackages: "macroArray (0.1)", "DFA (0.1)"     :%*optional, COMMA separated, QUOTED list, names of required packages *;

>> **DESCRIPTION** <<
>> All the text below will be used in help <<
DESCRIPTION START:
  Xxxxxxxxxxx xxxxxxx xxxxxx xxxxxxxx xxxxxxxx. Xxxxxxx
  xxxx xxxxxxxxxxxx xx xxxxxxxxxxx xxxxxx. Xxxxxxx xxx
  xxxx xxxxxx. Xxxxxxxxxxxxx xxxxxxxxxx xxxxxxx.
DESCRIPTION END:
--------------------------------------------------------------------------------------------

  Name of the 'type' of folder and files.sas inside must be in _low_ case letters.

  If order of loading is important, the 'sequential number'
  can be used to order multiple types in the wey you wish.

  The "tree structure" of the folder could be for example as follows:

--------------------------------------------------------------------------------------------
 <packageName>
  ..
   |
   +-000_libname [one file one libname]
   |           |
   |           +-abc.sas [a file with a code creating libname ABC]
   |
   +-001_macro [one file one macro]
   |         |
   |         +-hij.sas [a file with a code creating macro HIJ]
   |         |
   |         +-klm.sas [a file with a code creating macro KLM]
   |
   +-002_function [one file one function,
   |            |  option OUTLIB= should be: work.&packageName.fcmp.package 
   |            |  option INLIB=  should be: work.&packageName.fcmp
   |            |  (both literally with macrovariable name and "fcmp" sufix)]
   |            |
   |            +-efg.sas [a file with a code creating function EFG]
   |
   +-003_format [one file one format,
   |          |  option LIB= should be: work.&packageName.format 
   |          |  (literally with macrovariable name and "format" sufix)]
   |          |
   |          +-efg.sas [a file with a code creating format EFG and informat EFG]
   |
   +-004_data [one file one dataset]
   |        |
   |        +-abc.efg.sas [a file with a code creating dataset EFG in library ABC] 
   |
   +-005_exec [so called "free code", content of the files will be printed 
   |        |  to the log before execution]
   |        |
   |        +-<no file, in this case folder may be skipped>
   |
   +-006_format [if your codes depend eachother you can order them in folders, 
   |          |  e.g. code from 003_... will be executed before 006_...]
   |          |
   |          +-abc.sas [a file with a code creating format ABC, 
   |                     used in the definition of the format EFG]
   +-007_function
   |            |
   |            +-<no file, in this case folder may be skipped>
   |
   +-<sequential number>_<type [in lower case]>
   |
   +-...
   |
   +-00n_clean [if you need to clean something up after exec file execution,
   |         |  content of the files will be printed to the log before execution]
   |         |
   |         +-<no file, in this case folder may be skipped>
   +-...
   ...
--------------------------------------------------------------------------------------------

*/
/*** HELP END ***/

/* collect the data */
data &filesWithCodes.;
  base = "&filesLocation.";
  length folder file lowcase_name $ 256 folderRef fileRef $ 8; 
  drop lowcase_name;

  folderRef = "_%sysfunc(datetime(), hex6.)0";

  rc=filename(folderRef, base);
  folderid=dopen(folderRef);

  do i=1 to dnum(folderId); drop i;
    folder = dread(folderId, i); 
    if folder NE lowcase(folder) then
      do;
        put 'ERROR: Folder should be named ONLY with low case letters.';
        put 'ERROR- Current value is: ' folder;
        lowcase_name = lowcase(folder);
        put 'ERROR- Try: ' lowcase_name;
        put;
        abort;
      end;
    order = scan(folder, 1, "_");
    type  = scan(folder,-1, "_");

    fileRef = "_%sysfunc(datetime(), hex6.)1";
    rc = filename(fileRef, catx("/", base, folder));
    fileId = dopen(fileRef);

    file = ' ';
    if fileId then 
      do j = 1 to dnum(fileId); drop j;
        file = dread(fileId, j);
            if file NE lowcase(file) then
              do;
                put 'ERROR: File with code should be named ONLY with low case letters.';
                put 'ERROR- Current value is: ' file;
                lowcase_name = lowcase(file);
                put 'ERROR- Try: ' lowcase_name;
                put;
                abort;
              end;
        fileshort = substr(file, 1, length(file) - 4); /* filename.sas -> filename */
        output;
      end;
    rc = dclose(fileId);
    rc = filename(fileRef);
  end;

  rc = dclose(folderid);
  rc = filename(folderRef);
  stop;
run;
proc sort data = &filesWithCodes.;
  by order type file;
run;
/*
proc contents data = &filesWithCodes.;
run;
*/
title1 "Package's location is: &filesLocation.";
title2 "User: &SYSUSERID., datetime: %qsysfunc(datetime(), datetime21.), SAS version: &SYSVLONG4.";
title3 "Package's encoding: '&packageEncoding.', session's encoding: '&SYSENCODING.'.";
title4 " ______________________________ ";
title5 "List of files for package: &packageName. (version &packageVersion.), license: &packageLicense.";
proc print data = &filesWithCodes.(drop=base);
run;
title;

/* packages description */
data _null_;
  infile &_DESCR_.;
  file &zipReferrence.(description.sas);
  input; 
  put _INFILE_;
run;

/* package license */
%if %sysfunc(fexist(&_LIC_.)) %then 
  %do;
    data _null_;
      infile &_LIC_.;
      file &zipReferrence.(license.sas);
      input; 
      put _INFILE_;
    run;
  %end;
%else
  %do;
    %put WARNING:[License] No license.sas file provided, default (MIT) licence file will be generated.;
    %let packageLicense = MIT;
     data _null_;
      file &zipReferrence.(license.sas);
      put " ";
      put "  Copyright (c) %sysfunc(today(),year4.) &packageAuthor.                        ";
      put "                                                                                ";
      put "  Permission is hereby granted, free of charge, to any person obtaining a copy  ";
      put '  of this software and associated documentation files (the "Software"), to deal ';
      put "  in the Software without restriction, including without limitation the rights  ";
      put "  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell     ";
      put "  copies of the Software, and to permit persons to whom the Software is         ";
      put "  furnished to do so, subject to the following conditions:                      ";
      put "                                                                                ";
      put "  The above copyright notice and this permission notice shall be included       ";
      put "  in all copies or substantial portions of the Software.                        ";
      put "                                                                                ";
      put '  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR    ';
      put "  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,      ";
      put "  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE   ";
      put "  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER        ";
      put "  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, ";
      put "  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE ";
      put "  SOFTWARE.                                                                     ";
      put " ";
    run;
  %end;

/* package metadata */
data _null_;
  if 0 then set &filesWithCodes. nobs=NOBS;
  if NOBS = 0 then
    do;
      putlog "WARNING:[&sysmacroname.] No files to create package.";
      stop;
    end;
  file &zipReferrence.(packagemetadata.sas);

  put ' data _null_; '; /* simple "%local" returns error while loading package */
  put ' call symputX("packageName",       " ", "L");';
  put ' call symputX("packageVersion",    " ", "L");';
  put ' call symputX("packageTitle",      " ", "L");';  
  put ' call symputX("packageAuthor",     " ", "L");';
  put ' call symputX("packageMaintainer", " ", "L");';
  put ' call symputX("packageEncoding",   " ", "L");'; 
  put ' call symputX("packageLicense",    " ", "L");';  
  put ' run; ';

  put ' %let packageName       =' "&packageName.;";
  put ' %let packageVersion    =' "&packageVersion.;";
  put ' %let packageTitle      =' "&packageTitle.;";
  put ' %let packageAuthor     =' "&packageAuthor.;";
  put ' %let packageMaintainer =' "&packageMaintainer.;";
  put ' %let packageEncoding   =' "&packageEncoding.;";
  put ' %let packageLicense    =' "&packageLicense.;";
  put ' ; ';

  stop;
run;

/* loading package files */
data _null_;
  if NOBS = 0 then stop;

  file &zipReferrence.(load.sas) lrecl=32767;
 
  put 'filename package list;' /;
  put ' %put NOTE- ;'; 
  put ' %put NOTE: ' @; put "Loading package &packageName., version &packageVersion., license &packageLicense.; ";
  put ' %put NOTE: ' @; put "*** &packageTitle. ***; ";
  put ' %put NOTE- ' @; put "Generated: %sysfunc(datetime(), datetime21.); ";
  put ' %put NOTE- ' @; put "Author(s): &packageAuthor.; ";
  put ' %put NOTE- ' @; put "Maintainer(s): &packageMaintainer.; ";
  put ' %put NOTE- ;';
  put ' %put NOTE- Write %nrstr(%%)helpPackage(' "&packageName." ') for the description;';
  put ' %put NOTE- ;';
  put ' %put NOTE- *** START ***; ' /;

  put '%include package(packagemetadata.sas) / nosource2;' /; /* <- copied also to loadPackage macro */
  isFunction = 0;
  isFormat   = 0;

  %if (%bquote(&packageRequired.) ne ) 
   or (%bquote(&packageReqPackages.) ne )             
  %then
    %do;
      put ' data _null_;                                                     ';
      put '  call symputX("packageRequiredErrors", 0, "L");                  ';
      put ' run;                                                             ';
    %end;

  %if %bquote(&packageRequired.) ne %then
    %do;
      put ' %put NOTE- *Testing required SAS components*%sysfunc(DoSubL(     '; /* DoSubL() */
      put ' options nonotes nosource %str(;)                                 ';
      put ' options ls=max ps=max %str(;)                                    ';
      put ' /* temporary redirect log */                                     ';
      put ' filename _stinit_ TEMP %str(;)                                   ';
      put ' proc printto log = _stinit_ %str(;) run %str(;)                  ';
      put ' /* print out setinit */                                          ';
      put ' proc setinit %str(;) run %str(;)                                 ';
      put ' proc printto %str(;) run %str(;)                                 ';

      put ' data _null_ %str(;)                                              ';
      put '   /* loadup checklist of required SAS components */              ';
      put '   if _n_ = 1 then                                                ';
      put '     do %str(;)                                                   ';
      put '       length req $ 256 %str(;)                                   ';
      put '       declare hash R() %str(;)                                   ';
      put '       _N_ = R.defineKey("req") %str(;)                           ';
      put '       _N_ = R.defineDone() %str(;)                               ';
      put '       declare hiter iR("R") %str(;)                              ';
        length packageRequired $ 32767; 
        packageRequired = upcase(symget('packageRequired'));
      put '         do req = %bquote(' / packageRequired / ') %str(;)        ';
      put '          _N_ = R.add(key:req,data:req) %str(;)   ';
      put '         end %str(;)                                              ';
      put '     end %str(;)                                                  ';
      put '                                                                  ';
      put '   /* read in output from proc setinit */                         ';
      put '   infile _stinit_ end=eof %str(;)                                ';
      put '   input %str(;)                                                  ';
      /*put ' put "*> " _infile_ %str(;)';*/ /* for testing */
      put '                                                                  ';
      put '   /* if component is in setinit remove it from checklist */      ';
      put '   if _infile_ =: "---" then                                      ';
      put '     do %str(;)                                                   ';
      put '       req = upcase(substr(_infile_, 4, 64)) %str(;)              ';
      put '       if R.find(key:req) = 0 then                                ';
      put '         do %str(;)                                               ';
      put '           _N_ = R.remove() %str(;)                               ';
      put '         end %str(;)                                              ';
      put '     end %str(;)                                                  ';
      put '                                                                  ';
      put '   /* if checklist is not null rise error */                      ';
      put '   if eof and R.num_items > 0 then                                ';
      put '     do %str(;)                                                   ';
      put '       put "ERROR- ###########################################" %str(;) ';
      put '       put "ERROR-  The following SAS components are missing! " %str(;) ';
      put '       call symputX("packageRequiredErrors", 1, "L") %str(;)      ';
      put '       do while(iR.next() = 0) %str(;)                            ';
      put '         put "ERROR-   " req %str(;)                              ';
      put '       end %str(;)                                                ';
      put '       put "ERROR- ###########################################" %str(;) ';
      put '       put %str(;)                                                ';
      put '     end %str(;)                                                  ';
      put ' run %str(;)                                                      ';
      put ' filename _stinit_ clear %str(;)                                  ';
      put ' options notes source %str(;)                                     ';
      put ' ))*;                                                             ';
    %end;

  %if %bquote(&packageReqPackages.) ne %then
    %do;
      put ' data _null_ ;                                                                                ';
      put '  length req name $ 64 SYSloadedPackages $ 32767;                                             ';
      length packageReqPackages $ 32767;
      packageReqPackages = lowcase(symget('packageReqPackages'));
      put '  if SYMEXIST("SYSloadedPackages") = 1 and SYMGLOBL("SYSloadedPackages") = 1 then             ';
      put '    do;                                                                                       ';
      put '      do until(EOF);                                                                          ';
      put '        set sashelp.vmacro(where=(scope="GLOBAL" and name="SYSLOADEDPACKAGES")) end=EOF;      ';
      put '        substr(SYSloadedPackages, 1+offset, 200) = value;                                     ';
      put '      end;                                                                                    ';
      put '      SYSloadedPackages = lowcase(SYSloadedPackages);                                         '; 

      put '      declare hash LP();                                                                      ';
      put '      LP.defineKey("name");                                                                   ';
      put '      LP.defineDone();                                                                        ';
      put '      do _N_ = 1 to countw(SYSloadedPackages);                                                ';
      put '        name = scan(SYSloadedPackages, _N_);                                                  ';
      put '        _RC_ = LP.add();                                                                      ';
      put '      end;                                                                                    ';

      put '      missingPackagr = 0;                                                                     ';
      put '      do req = ' / packageReqPackages / ' ;                                                   ';
      put '        name = lowcase(strip(scan(req, 1, " ")));                                             ';
      put '        vers = lowcase(compress(scan(req,-1, " "), ".", "KD"));                               ';
      put '        if LP.check() ne 0 then                                                               ';
      put '         do;                                                                                  ';
      put '          missingPackagr = 1;                                                                 ';
      put '          put "ERROR: SAS package " req "is missing! " ;                                      ';
      put '          put ''ERROR- Try  %loadPackage('' name ", requiredVersion = " vers ") to load it." ;';
      put '         end ;                                                                                ';
      put '      end ;                                                                                   ';
      put '      if missingPackagr then call symputX("packageRequiredErrors", 1, "L");                   ';
      put '    end;                                                                                      ';
      put '  else                                                                                        ';
      put '    do;                                                                                       ';
      put '      put "ERROR: No package loaded!";                                                        ';
      put '      call symputX("packageRequiredErrors", 1, "L");                                          ';
      put '      do req = ' / packageReqPackages / ' ;                                                   ';
      put '        name = lowcase(strip(scan(req, 1, " ")));                                             ';
      put '        vers = lowcase(compress(scan(req,-1, " "), ".", "KD"));                               ';
      put '        put "ERROR: SAS package " req "is missing! " ;                                        ';
      put '        put ''ERROR- Try  %loadPackage('' name ", requiredVersion = " vers ") to load it." ;  ';
      put '      end ;                                                                                   ';
      put '    end;                                                                                      ';
      put '  stop;                                                                                       ';
      put 'run;                                                                                          ';
    %end;

  %if (%bquote(&packageRequired.) ne ) 
     or (%bquote(&packageReqPackages.) ne )             
  %then
    %do;
      put ' data _null_;                                                     ';
      put '  if symget("packageRequiredErrors") = "1" then                   ';
      put '    do;                                                           ';
      put '      put "ERROR: Loading package &packageName. will be aborted!";';
      put '      put "ERROR- Required SAS components are missing.";          ';
      put '      put "ERROR- *** STOP ***";                                  ';
      put '      ABORT;                                                      ';
      put '    end;                                                          ';
      put ' run;                                                             ';
    %end;

  do until(eof);
    set &filesWithCodes. end = EOF nobs=NOBS;
    if (upcase(type)=:'CLEAN') then continue; /* cleaning files are only included in unload.sas */
    put '%put NOTE- ;';
    put '%put NOTE- Element of type ' type 'from the file "' file +(-1) '" will be included;' /;

    if upcase(type)=:'EXEC' then
    do;
      put '%put NOTE- ;';
      put '%put NOTE- Executing the following code: ;';
      put '%put NOTE- *****************************;';
      put 'data _null_;';
      put '  infile package(_' folder +(-1) "." file +(-1) ') lrecl=32767;';
      put '  input;';
      put '  putlog "*> " _infile_;';
      put 'run;' /;
      put '%put NOTE- *****************************;';
      put '%put NOTE- ;';
    end;

    put '%include package(_' folder +(-1) "." file +(-1) ') / nosource2;' /;

    isFunction + (upcase(type)=:'FUNCTION');
    isFormat   + (upcase(type)=:'FORMAT'); 
  
    /* add the link to the functions' dataset, only for the first occurence */
    if 1 = isFunction and (upcase(type)=:'FUNCTION') then
      do;
        put "options APPEND=(cmplib = work.%lowcase(&packageName.fcmp));";
        put '%put NOTE- ;';
        put '%put NOTE:[CMPLIB] %sysfunc(getoption(cmplib));' /;
      end;

    /* add the link to the formats' catalog, only for the first occurence  */
    if 1 = isFormat and (upcase(type)=:'FORMAT') then
      do;
        put "options INSERT=( fmtsearch = work.%lowcase(&packageName.format) );";
        put '%put NOTE- ;';
        put '%put NOTE:[FMTSEARCH] %sysfunc(getoption(fmtsearch));'/;
      end;
  end;

  /* update SYSloadedPackages global macrovariable */
  put ' data _null_ ;                                                                                ';
  put '  length SYSloadedPackages $ 32767;                                             ';
  put '  if SYMEXIST("SYSloadedPackages") = 1 and SYMGLOBL("SYSloadedPackages") = 1 then             ';
  put '    do;                                                                                       ';
  put '      do until(EOF);                                                                          ';
  put '        set sashelp.vmacro(where=(scope="GLOBAL" and name="SYSLOADEDPACKAGES")) end=EOF;      ';
  put '        substr(SYSloadedPackages, 1+offset, 200) = value;                                     ';
  put '      end;                                                                                    ';
  put '      SYSloadedPackages = cats("#", translate(strip(SYSloadedPackages), "#", " "), "#");      ';

  put "      if INDEX(lowcase(SYSloadedPackages), '#%lowcase(&packageName.)#') = 0 then              ";
  put '         do;                                                                                  ';
  put "          SYSloadedPackages = catx('#', SYSloadedPackages, '&packageName.');                  ";
  put '          SYSloadedPackages = compbl(translate(SYSloadedPackages, " ", "#"));                 ';
  put '          call symputX("SYSloadedPackages", SYSloadedPackages, "G");                          ';
  put '          put "NOTE: " SYSloadedPackages = ;                                                  ';
  put '         end ;                                                                                ';
  put '    end;                                                                                      ';
  put '  else                                                                                        ';
  put '    do;                                                                                       ';
  put "      call symputX('SYSloadedPackages', '&packageName.', 'G');                                ";
  put "      put 'NOTE: SYSloadedPackages = &packageName.';                                          ";
  put '    end;                                                                                      ';
  put '  stop;                                                                                       ';
  put 'run;                                                                                          ' / ;

  put '%put NOTE- ;';
  put '%put NOTE: '"Loading package &packageName., version &packageVersion., license &packageLicense.;";
  put '%put NOTE- *** END ***;' /;
  put "/* load.sas end */" /;
  stop;
run;

/* unloading package objects */
data _null_;
  /* break if no data */
  if NOBS = 0 then stop;

  file &zipReferrence.(unload.sas);

  put 'filename package list;' /;
  put '%put NOTE: '"Unloading package &packageName., version &packageVersion., license &packageLicense.;";
  put '%put NOTE- *** START ***;' /;

  /* include "cleaning" files */
  EOF = 0;
  do until(EOF);
    set &filesWithCodes. end = EOF nobs = NOBS;
    if not (upcase(type)=:'CLEAN') then continue;
    put '%put NOTE- Code of type ' type 'generated from the file "' file +(-1) '" will be executed;';
    put '%put NOTE- ;' /;
    put '%put NOTE- Executing the following code: ;';
    put '%put NOTE- *****************************;';
    put 'data _null_;';
    put '  infile package(_' folder +(-1) "." file +(-1) ') lrecl=32767;';
    put '  input;';
    put '  putlog "*> " _infile_;';
    put 'run;' /;
    put '%put NOTE- *****************************;';
    put '%put NOTE- ;' /;

    put '%include package(_' folder +(-1) "." file +(-1) ') / nosource2;' /;
  end;

  /* delete macros and formats */
  put 'proc sql;';
  put '  create table WORK._%sysfunc(datetime(), hex16.)_ as';
  put '  select memname, objname, objtype';
  put '  from dictionary.catalogs';
  put '  where ';
  put '  (';
  put '   objname in ("*"' /;
  /* list of macros */
  EOF = 0;
  do until(EOF);
    set &filesWithCodes. end = EOF nobs = NOBS;
    if not (upcase(type)=:'MACRO') then continue;
    put '%put NOTE- Element of type ' type 'generated from the file "' file +(-1) '" will be deleted;';
    put '%put NOTE- ;' /;
    put ',"' fileshort upcase32. '"';
  end;
  /**/
  put '  )';
  put '  and objtype = "MACRO"';
  put '  and libname  = "WORK"';
  put '  )';
  put '  or';
  put '  (';
  put '   objname in ("*"' /;
  /* list of formats */
  isFormat = 0;
  EOF = 0;
  do until(EOF);
    set &filesWithCodes. end = EOF;
    if not (upcase(type)=:'FORMAT') then continue;
    put '%put NOTE- Element of type ' type 'generated from the file "' file +(-1) '" will be deleted;';
    put '%put NOTE- ;' /;
    put ',"' fileshort upcase32. '"';
    isFormat + 1;
  end;
  put '  )';
  put '  and objtype in ("FORMAT" "FORMATC" "INFMT" "INFMTC")';
  put '  and libname  = "WORK"';
  put "  and memname = '%upcase(&packageName.format)'";
  put '  )';

  put '  order by objtype, memname, objname';
  put '  ;';
  put 'quit;';

  put 'data _null_;';
  put '  do until(last.memname);';
  put '    set WORK._last_;';
  put '    by objtype memname;';
  put '    if first.memname then call execute("proc catalog cat = work." !! strip(memname) !! " force;");';
  put '    call execute("delete " !! strip(objname) !! " /  et =" !! objtype !! "; run;");';
  put '  end;';
  put '  call execute("quit;");';
  put 'run;';
  put 'proc delete data = WORK._last_;';
  put 'run;';

  /* delete the link to the formats catalog */
  if isFormat then
    do;
      put "proc delete data = work.%lowcase(&packageName.format)(mtype = catalog);";
      put 'run;';
      put 'options fmtsearch = (%unquote(%sysfunc(tranwrd(' /
          '%lowcase(%sysfunc(getoption(fmtsearch)))' /
          ',%str(' "work.%lowcase(&packageName.)format" '), %str() ))));';
      put 'options fmtsearch = (%unquote(%sysfunc(compress(' /
          '%sysfunc(getoption(fmtsearch))' /
          ', %str(()) ))));';
      put '%put NOTE:[FMTSEARCH] %sysfunc(getoption(fmtsearch));' /;
    end;

  /* delete functions */
  put "proc fcmp outlib = work.%lowcase(&packageName.fcmp).package;";
  isFunction = 0;
  EOF = 0;
  do until(EOF);
    set &filesWithCodes. end = EOF;
    if not (upcase(type)=:'FUNCTION') then continue;
    put '%put NOTE- Element of type ' type 'generated from the file "' file +(-1) '" will be deleted;';
    put '%put NOTE- ;' /;
    put 'deletefunc ' fileshort ';';
    isFunction + 1;
  end;
  put "run;" /;

  /* delete the link to the functions dataset */
  if isFunction then
    do;
      put 'options cmplib = (%unquote(%sysfunc(tranwrd(' /
          '%lowcase(%sysfunc(getoption(cmplib)))' /
          ',%str(' "work.%lowcase(&packageName.fcmp)" '), %str() ))));';
      put 'options cmplib = (%unquote(%sysfunc(compress(' /
          '%sysfunc(getoption(cmplib))' /
          ',%str(()) ))));';
      put '%put; %put NOTE:[CMPLIB] %sysfunc(getoption(cmplib));' /;
    end;
   
  /* delete datasets */
  put "proc sql noprint;";
  EOF = 0;
  do until(EOF);
    set &filesWithCodes. end = EOF;
    if not (upcase(type)=:'DATA') then continue;
    put '%put NOTE- Element of type ' type 'generated from the file "' file +(-1) '" will be deleted;';
    put '%put NOTE- ;' /;
    put 'drop table ' fileshort ';';
  end;
  put "quit;" /;

  /* delete libraries */
  EOF = 0;
  do until(EOF);
    set &filesWithCodes. end = EOF;
    if not (upcase(type)=:'LIBNAME') then continue;
    put '%put NOTE- Element of type ' type 'generated from the file "' file +(-1) '" will be cleared;';
    put '%put NOTE- ;' /;
    put 'libname ' fileshort ' clear;';
  end;
  put "run;" /;

  /* update SYSloadedPackages global macrovariable */
  put ' data _null_ ;                                                                                ';
  put '  length SYSloadedPackages $ 32767;                                             ';
  put '  if SYMEXIST("SYSloadedPackages") = 1 and SYMGLOBL("SYSloadedPackages") = 1 then             ';
  put '    do;                                                                                       ';
  put '      do until(EOF);                                                                          ';
  put '        set sashelp.vmacro(where=(scope="GLOBAL" and name="SYSLOADEDPACKAGES")) end=EOF;      ';
  put '        substr(SYSloadedPackages, 1+offset, 200) = value;                                     ';
  put '      end;                                                                                    ';
  put '      SYSloadedPackages = cats("#", translate(strip(SYSloadedPackages), "#", " "), "#");      ';

  put "      if INDEX(lowcase(SYSloadedPackages), '#%lowcase(&packageName.)#') > 0 then              ";
  put '         do;                                                                                  ';
  put "          SYSloadedPackages = tranwrd(SYSloadedPackages, '#&packageName.#', '##');            ";
  put '          SYSloadedPackages = compbl(translate(SYSloadedPackages, " ", "#"));                 ';
  put '          call symputX("SYSloadedPackages", SYSloadedPackages, "G");                          ';
  put '          put "NOTE: " SYSloadedPackages = ;                                                  ';
  put '         end ;                                                                                ';
  put '    end;                                                                                      ';
  put '  stop;                                                                                       ';
  put 'run;                                                                                          ' / ;

 
  put '%put NOTE: '"Unloading package &packageName., version &packageVersion., license &packageLicense.;";
  put '%put NOTE- *** END ***;';
  put '%put NOTE- ;';
 
  put "/* unload.sas end */";
  stop;
run;

/* package help */
data _null_;
  /* break if no data */
  if NOBS = 0 then stop;

  file &zipReferrence.(help.sas);
  length strX $ 32767;

  put 'filename package list;' /;
  put ' %put NOTE- ;';
  put ' %put NOTE: '"Help for package &packageName., version &packageVersion., license &packageLicense.;";
  put ' %put NOTE: ' @; put "*** &packageTitle. ***; ";
  put ' %put NOTE- ' @; put "Generated: %sysfunc(datetime(), datetime21.); ";
  put ' %put NOTE- ' @; put "Author(s): &packageAuthor.; ";
  put ' %put NOTE- ' @; put "Maintainer(s): &packageMaintainer.; ";
  put ' %put NOTE- ;';
  put ' %put NOTE- *** START ***;' /;
  
  /* Use helpKeyword macrovariable to search for content (filename and type) */
  /* put '%local ls_tmp ps_tmp notes_tmp source_tmp;                       ';*/
  put '%let ls_tmp     = %sysfunc(getoption(ls));         ';
  put '%let ps_tmp     = %sysfunc(getoption(ps));         ';
  put '%let notes_tmp  = %sysfunc(getoption(notes));      ';
  put '%let source_tmp = %sysfunc(getoption(source));     ';
  put 'options ls = MAX ps = MAX nonotes nosource;        ';
  put '%include package(packagemetadata.sas) / nosource2; ' /;

  put 'data _null_;                                                              ';
  put '  if strip(symget("helpKeyword")) = " " then                              ';
  put '    do until (EOF);                                                       ';
  put '      infile package(description.sas) end = EOF;                          ';
  put '      input;                                                              ';
  put '      if upcase(strip(_infile_)) = "DESCRIPTION END:" then printer = 0;   ';
  put '      if printer then put "*> " _infile_;                                 ';
  put '      if upcase(strip(_infile_)) = "DESCRIPTION START:" then printer = 1; ';
  put '    end;                                                                  ';
  put '  else stop;                                                              ';
  put 'run;                                                                      ' /;

  /* license info */
  put 'data _null_;                                                   ';
  put '  if upcase(strip(symget("helpKeyword"))) = "LICENSE" then     ';
  put '    do until (EOF);                                            ';
  put '      infile package(license.sas) end = EOF;                   ';
  put '      input;                                                   ';
  put '      put "*> " _infile_;                                      ';
  put '    end;                                                       ';
  put '  else stop;                                                   ';
  put 'run;                                                           ' /;

  put 'data WORK._%sysfunc(datetime(), hex16.)_;                      ';
  put 'infile cards4 dlm = "/";                                       ';
  put 'input @;                                                       ';
  put 'if 0 then output;                                              ';
  put 'length helpKeyword $ 64;                                       ';
  put 'retain helpKeyword "*";                                        ';
  put 'drop helpKeyword;                                              ';
  put 'if _N_ = 1 then helpKeyword = strip(symget("helpKeyword"));    ';
  put 'if FIND(_INFILE_, helpKeyword, "it") or helpKeyword = "*" then '; 
  put ' do;                                                           ';
  put '   input (folder order type file fileshort) (: $ 256.);        ';
  put '   output;                                                     ';
  put ' end;                                                          ';
  put 'cards4;                                                        ';

  EOFDS = 0;
  do until(EOFDS);
    /* content is created during package creation */
    set &filesWithCodes. end = EOFDS nobs = NOBS;
    select;
      when (upcase(type) = "DATA")     fileshort2 = fileshort;
      when (upcase(type) = "MACRO")    fileshort2 = cats('%',fileshort,'()');
      when (upcase(type) = "FUNCTION") fileshort2 = cats(fileshort,'()');
      when (upcase(type) = "FORMAT")   fileshort2 = cats('$',fileshort);
      otherwise fileshort2 = fileshort;
    end;
    strX = catx('/', folder, order, type, file, fileshort, fileshort2);
    put strX;
  end;

  put ";;;;";
  put "run;" /;
/*
  put 'proc print;';
  put 'run;';
*/
  /* loop through content found and print info to the log */
  put 'data _null_;                                                                                                        ';
  put 'if upcase(strip(symget("helpKeyword"))) in (" " "LICENSE") then do; stop; end;                                      ';
  put 'if NOBS = 0 then do; ' /
        'put; put '' *> No help info found. Try %helpPackage(packageName,*) to display all.''; put; stop; ' / 
      'end; ';
  put '  do until(EOFDS);                                                                                                  ';
  put '    set WORK._last_ end = EOFDS nobs = NOBS;                                                                        ';
  put '    length memberX $ 1024;                                                                                          ';
  put '    memberX = cats("_",folder,".",file);                                                                            ';
  /* inner datastep in call execute to read each embedaded file */
  put '    call execute("data _null_;                                                                                   ");';
  put '    call execute("infile package(" || strip(memberX) || ") end = EOF;                                            ");';
  put '    call execute("    printer = 0;                                                                               ");';
  put '    call execute("    do until(EOF);                                                                             ");';
  put '    call execute("      input;                                                                                   ");';
  put '    call execute("      if strip(_infile_) = cat(""/"",""*** "",""HELP END"","" ***"",""/"") then printer = 0;   ");';   /* it looks like that because of comments */
  put '    call execute("      if printer then put ""*> "" _infile_;                                                    ");';
  put '    call execute("      if strip(_infile_) = cat(""/"",""*** "",""HELP START"","" ***"",""/"") then printer = 1; ");';   /* it looks like that because of comments */
  put '    call execute("    end;                                                                                       ");';
  put '    call execute("  put ""*> "" / ""*> "";                                                                       ");';
  put '    call execute("  stop;                                                                                        ");';
  put '    call execute("run;                                                                                           ");';
  put '    if lowcase(type) =: "data" then                                                                                 ';
  put '      do;                                                                                                           ';
  put '        call execute("title ""Dataset " || strip(fileshort) || " from package &packageName. "";                  ");';
  put '        call execute("proc contents data = " || strip(fileshort) || "; run; title;                               ");';
  put '      end;                                                                                                          ';
  /**/
  put "  end; ";
  put "  stop; ";
  put "run; ";
  
  /* cleanup */
  put "proc delete data = WORK._last_; ";
  put "run; ";
  put 'options ls = &ls_tmp. ps = &ps_tmp. &notes_tmp. &source_tmp.; ' /;
 
  put '%put NOTE: '"Help for package &packageName., version &packageVersion., license &packageLicense.;";
  put '%put NOTE- *** END ***;' /; 
  put "/* help.sas end */";

  stop;
run;

/* create package's content */
data _null_;
  /* break if no data */
  if NOBS = 0 then stop;

  set &filesWithCodes. nobs = NOBS;

  call execute(cat ('filename _IN_ "', catx('/', base, folder, file), '";'));
  call execute(cats("filename _OUT_ ZIP '", base, "/%lowcase(&packageName.).zip' member='_", folder, ".", file, "';") );
  call execute('data _null_;');
  call execute('  rc = fcopy("_IN_", "_OUT_");');
  call execute('run;');
  call execute('filename _IN_  clear;');
  call execute('filename _OUT_ clear;');
run;

proc sql;
  drop table &filesWithCodes.;
quit;
filename &zipReferrence. clear;
%mend GeneratePackge;


/*

options mprint;
ods html;
%GeneratePackge(
 testowyPackageName
,0.01
,author
,contact
,filesLocation=E:\SAS_WORK_5400\testyGeneratePackage
)

*/

/*
TODO:
- modyfikacja helpa, sprawdzanie kodu danje funkcji/makra/typu [v]

- opcjonalne sortowanie nazw folderow(<numer>_<typ>) [v]

- wewnętrzna nazwaz zmiennej z nazwa pakietu (na potrzeby kompilacji) [v]

- weryfikacja srodaowiska

- weryfikacja "niepustosci" obowiazkowych argumentow   [v]

- dodac typ "clear" do czyszczenia po plikach 'exec' [v]

- doadc sprawdzanie liczby wywołan procedury fcmp, format i slowa '%macro(' w plikach z kodami

- syspackages - makrozmienna z lista zaladowanych pakietow

- dodac typ "imp", "ds2", "proto"

-lista wymaganych komponentow potrzebnych do działania SASa (na bazie proc SETINIT)
*/

/*

%include "C:\SAS_PACKAGES\generatePackage.sas";

ods html;
%generatePackge(filesLocation=C:\SAS_PACKAGES\SQLinDS)
*/

/*
*"C:\SAS_PACKAGES\testyGeneratoraPakietow";

libname  packages "E:\SAS_WORK_5400\testyGeneratePackage";
filename packages "E:\SAS_WORK_5400\testyGeneratePackage";

%include packages(loadpackage.sas);

dm 'log;clear';
%loadpackage(testowypackagename)


*/
/*

%let helpKeyword=*;
%helpPackage(testowypackagename)
%unloadPackage(testowypackagename)

                     
filename package ZIP "E:\SAS_WORK_5400\testyGeneratePackage\testowypackagename.zip";

%put %sysfunc(pathname(package));

%include package(load.sas);
%help()???
%include package(unload.sas);

filename package ZIP "C:\SAS_PACKAGES\testowypackagename.zip";
%include package(load.sas);
%include package(unload.sas);

filename package ZIP "C:\SAS_PACKAGES\macroarray.zip";
%include package(load.sas);
%include package(unload.sas);
*/
