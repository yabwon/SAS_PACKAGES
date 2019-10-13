/*** HELP START ***/

/**############################################################################**/
/*                                                                              */
/*  Copyright Bartosz Jablonski, Jully 2019.                                    */
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

/* Macros to list SAS packages in packsges' folder */
/* A SAS package is a zip file containing a group 
   of SAS codes (macros, functions, datasteps generating 
   data, etc.) wrapped up together and %INCLUDEed by
   a single load.sas file (also embeaded inside the zip).
*/
/*
 * Example 1:
  
  filename packages "C:\SAS_PACKAGES";
  %listPackages()

*/
/*** HELP END ***/


%macro listPackages();

%local ls_tmp ps_tmp notes_tmp source_tmp;
%let   filesWithCodes = WORK._%sysfunc(datetime(), hex16.)_;

%local ls_tmp ps_tmp notes_tmp source_tmp;
%let ls_tmp     = %sysfunc(getoption(ls));      
%let ps_tmp     = %sysfunc(getoption(ps));      
%let notes_tmp  = %sysfunc(getoption(notes));   
%let source_tmp = %sysfunc(getoption(source));  
options NOnotes NOsource ls=MAX ps=MAX;

data _null_;
  base = "%sysfunc(pathname(packages))";

  if base = " " then
    do;
      put "NOTE: The filereference PACKAGES is not assigned.";
      stop;
    end;

  length folder file $ 256 folderRef fileRef $ 8;

  folderRef = "_%sysfunc(datetime(), hex6.)0";

  rc=filename(folderRef, base);
  folderid=dopen(folderRef);

  put;
  put "/*" 100*"+" ;
  do i=1 to dnum(folderId); drop i;
    folder = dread(folderId, i);

    fileRef = "_%sysfunc(datetime(), hex6.)1";
    rc = filename(fileRef, catx("/", base, folder));
    fileId = dopen(fileRef);

    EOF = 0;
    if fileId = 0 and lowcase(scan(folder, -1, ".")) = 'zip' then 
      do;
          file = catx('/',base, folder);
          length nn $ 96;
          nn = repeat("*", (96-lengthn(file)));   
          
          putlog " ";
          put " * " file @; put nn /;
           
          infile package ZIP FILEVAR=file member="description.sas" end=EOF; 
           
            do until(EOF);
                input;
                if lowcase(scan(_INFILE_,1,":")) in ("package" "title" "version" "author" "maintainer" "license") then
                  do;
                    _INFILE_ = scan(_INFILE_,1,":") !! ":" !! scan(_INFILE_,2,":");
                    putlog " *  " _INFILE_;
                  end;
                if strip(_INFILE_) = "DESCRIPTION START:" then leave;
            end; 
      end;
    
    rc = dclose(fileId);
    rc = filename(fileRef);
  end;

  putlog " ";
  put 100*"+" "*/";
  rc = dclose(folderid);
  rc = filename(folderRef);
  stop;
run;

options ls = &ls_tmp. ps = &ps_tmp. &notes_tmp. &source_tmp.;
%mend listPackages;

