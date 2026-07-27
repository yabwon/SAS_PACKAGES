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

  SAS Packages Framework, version 20260727.
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

/*+SPFinit_intrnl_forceV7DSname+*/
%macro SPFinit_intrnl_forceV7DSname(
mcParam /* name of a macro parameter holding user provided data set name */
)/secure minoperator
des='SAS Packages Framework internal macro. Executable only inside selected SPF macros. Macro generates 4GL code that forces V7 compatibility for user provided data set names. Version 20260727.';
/* The macro can be called only inside a data step. */
/****************************************************************************
  ### Parameters:

  `mcParam` - name of a macro parameter holding user provided data set name

  ### Behavior:
  
  Description:
    The 4GL code SYMGETs macro variable value, SCANs only first 
    part of the string in case there are parenthesis "()" in it. 
    Then it COMPRESSes the string and keep _only_ digits, letters, 
    underscore, and period. All periods are TRANSLATEd to spaces. 
    If created string is not empty its last chunk is SCANned for 
    data set name, the second to last chunk is SCANned for libname 
    (if empty then "work" is used). First character of LIB and DS 
    variables is checked, if it is a digit, then underscore is added. 
    At the end the LIB and DS are concatenated and upper cased. 
    case letters. 
  
  Examples:

    abc.xyz -> ABC.XYZ
    ABC.XYZ(obs=42) -> ABC.XYZ
    XYZ -> WORK.XYZ
    abc. -> WORK.ABC
    .XYZ -> WORK.XYZ
    123.456 -> _123._456
    A#B.x$y -> AB.XY

  Usecase:
    Inside a macro for value check

    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
    %macro A(ods);
      data _null_;
        %SPFinit_intrnl_forceV7DSname(ods);
        call symputX("ods",ods,"L");
      run;
      
      %if %superq(ods) ne  %then
        %do;
          data &ods.;
            ...
          run;
        %end;
    %mend;

    %A()
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

****************************************************************************/
%local allowedSPFmacrosList;
%let allowedSPFmacrosList=LISTPACKAGES RELOCATEPACKAGE UNBUNDLEPACKAGES BUNDLEPACKAGES;
%if %sysmexecname(%sysmexecdepth-1) in (&allowedSPFmacrosList.) %then
%do;
/*=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=*/
  length &mcParam. $ 41 lib $ 8 ds $ 32;
  /* force only V7 valid symbols */
  &mcParam. = symget("&mcParam.");
  if NOT (&mcParam. = " ") then
    do;
      /* drop every illegal character */ 
      &mcParam. = compress(scan(&mcParam,1,'()'),'_.','kad');
      &mcParam. = cats(translate(&mcParam.," ","."));
      if NOT (&mcParam.=" ") then 
        do;
          /* use 2 last blocks of symbols */
          lib = coalescec(scan(&mcParam.,-2),"work");
          ds  = scan(&mcParam.,-1);
          /* check first symbol, in case leading digit add _ */
          if ("0" <=: lib <=: "9")
            then lib=cats("_",lib); 
          if ("0" <=: ds  <=: "9")
            then ds=cats("_",ds); 

          &mcParam. = upcase(catx(".",lib,ds));
        end;
    end;
/*=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=*/
%end;
%else
  %do;
    %put INFO: SAS Packages Framework internal macro.;
    %put INFO: Executable only inside &allowedSPFmacrosList. macros.;
  %end;
%mend SPFinit_intrnl_forceV7DSname;



