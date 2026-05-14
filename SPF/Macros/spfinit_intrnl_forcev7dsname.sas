/*+SPFinit_intrnl_forceV7DSname+*/
%macro SPFinit_intrnl_forceV7DSname(
mcParam /* name of a macro parameter holding user provided data set name */
)/secure minoperator
des='SAS Packages Framework internal macro. Executable only inside selected SPF macros. Macro generates 4GL code that forces V7 compatybility for user provided data set names. Version 20260514.';
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
    At the end the LIB and DS are concatenated and casted to upper 
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
        %SPDinit_intrnl_forceV7DSname(ods);
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

/* end of SPFinit.sas file */ 
