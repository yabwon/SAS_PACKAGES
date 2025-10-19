/*+splitCodeForPackage+*/
/*** HELP START ***/

%macro splitCodeForPackage(
 codeFile          /* a code file to split */
,packagePath=      /* location for results */
,debug=0           /* technical parameter  */
,nobs=0            /* technical parameter  */
)
/*** HELP START ***/
/ des = 'Utility macro to split "one big" code into multiple files for a SAS package, version 20251017. Run %splitCodeForPackage() for help info.'
;
/*%macro _();%mend _;*/
%if (%superq(codeFile) = ) OR (%qupcase(&codeFile.) = HELP) %then
  %do;
    %local options_tmp ;
    %let options_tmp = ls=%sysfunc(getoption(ls))ps=%sysfunc(getoption(ps))
     %sysfunc(getoption(notes)) %sysfunc(getoption(source))
     msglevel=%sysfunc(getoption(msglevel))
    ;
    options NOnotes NOsource ls=MAX ps=MAX msglevel=N;
    %put ;
    %put #################################################################################;
    %put ###     This is short help information for the `splitCodeForPackage` macro      #;
    %put #-------------------------------------------------------------------------------#;
    %put #                                                                               #;
    %put # Utility macro to *split* single file with SAS package code into multiple      #;
    %put # files with separate snippets, version `20251017`                              #;
    %put #                                                                               #;
    %put # A SAS package is a zip file containing a group                                #;
    %put # of SAS codes (macros, functions, data steps generating                        #;
    %put # data, etc.) wrapped up together and included by                               #;
    %put # a single `load.sas` file (also embedded inside the zip).                      #;
    %put #                                                                               #;
    %put # The `%nrstr(%%splitCodeForPackage())` macro takes a file with SAS code                 #;
    %put # snippets surrounded by `%str(/)*##$##-code-block-start-##$## <tag spec> *%str(/)` and     #;
    %put # `%str(/)*##$##-code-block-end-##$## <tag spec> *%str(/)` tags and split that file into    #;
    %put # multiple files and directories according to a tag specification.              #;
    %put #                                                                               #;
    %put # The `<tag spec>` is a list of pairs of the form: `type(object)` that          #;
    %put # indicates how the file should be split. See example 1 below for details.      #;
    %put #                                                                               #;
    %put #-------------------------------------------------------------------------------#;
    %put #### Parameters:                                                                #;
    %put #                                                                               #;
    %put # 1. `codeFile=`        *Required.* Name of a file containing code              #;
    %put #                        that will be split. Required and not null.             #;
    %put #                        If empty displays this help information.               #;
    %put #                                                                               #;
    %put # - `packagePath=`      *Required.* Location for package files after            #;
    %put #                        splitting into separate files and directories.         #;
    %put #                        If missing or not exist then `WORK` is uded.           #;
    %put #                                                                               #;
    %put # - `debug=`            *Optional.* Turns on code printing for debugging.       #;
    %put #                                                                               #;
    %put # - `nobs=`             *Optional.* Technical parameter with value `0`.         #;
    %put #                        Do not change.                                         #;
    %put #                                                                               #;
    %put #-------------------------------------------------------------------------------#;
    %put #                                                                               #;
    %put # Visit: `https://github.com/yabwon/SAS_PACKAGES/tree/main/SPF/Documentation`   #;
    %put # to learn more.                                                                #;
    %put # Tutorials available at: `https://github.com/yabwon/HoW-SASPackages`           #;
    %put #                                                                               #;
    %put ### Example 1 ###################################################################;
    %put #                                                                               #;
    %put #   Assume that the `myPackageCode.sas` file                                    #;
    %put #   is located in the `C:/lazy/` folder and                                     #;
    %put #   contain the following code and tags:                                        #;
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas;
    %put  ;
    %put  %nrstr( /)%nrstr(*##$##-code-block-start-##$## 01_macro(abc) */                );
    %put  %nrstr( %%macro abc();                                                         );
    %put  %nrstr(   %%put I am "abc".;                                                   );
    %put  %nrstr( %%mend abc;                                                            );
    %put  %nrstr( /)%nrstr(*##$##-code-block-end-##$## 01_macro(abc) */                  );
    %put  ;
    %put  %nrstr( /)%nrstr(*##$##-code-block-start-##$## 01_macro(efg) */                );
    %put  %nrstr( %%macro efg();                                                         );
    %put  %nrstr(   %%put I am "efg".;                                                   );
    %put  %nrstr( %%mend efg;                                                            );
    %put  %nrstr( /)%nrstr(*##$##-code-block-end-##$## 01_macro(efg) */                  );
    %put  ;
    %put  %nrstr( proc FCMP outlib=work.f.p;                                             );
    %put  %nrstr( /)%nrstr(*##$##-code-block-start-##$## 02_functions(xyz) */            );
    %put  %nrstr( function xyz(n);                                                       );
    %put  %nrstr(   return(n**2 + n + 1)                                                 );
    %put  %nrstr( endfunc;                                                               );
    %put  %nrstr( /)%nrstr(*##$##-code-block-end-##$## 02_functions(xyz) */              );
    %put  %nrstr( quit;                                                                  );
    %put  ;
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
    %put #                                                                               #;
    %put # and we want results in `C:/split/` folder, we run the following:              #;
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas;
    %put  %nrstr( filename packages "C:/SAS_PACKAGES"; %%* setup a directory for packages;);
    %put  %nrstr( %%include packages(SPFinit.sas);      %%* enable the framework;         );
    %put  ;
    %put  %nrstr( %%splitCodeForPackage%(                                                 );
    %put  %nrstr(    codeFile=C:/lazy/myPackageCode.sas                                   );
    %put  %nrstr(   ,packagePath=C:/split/ %)                                             );
    %put ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~;
    %put #                                                                               #;
    %put #################################################################################;
    %put ;
    options &options_tmp.;                        
    %GOTO ENDofsplitCodeForPackage;
  %end;

%local options_tmp2 ;
%let options_tmp2 = ls=%sysfunc(getoption(ls)) ps=%sysfunc(getoption(ps))
%sysfunc(getoption(notes)) %sysfunc(getoption(source))
msglevel=%sysfunc(getoption(msglevel))
;
options nomprint nosymbolgen nomlogic notes source ls=MAX ps=MAX msglevel=N ;

%let debug = %sysevalf(NOT(0=%superq(debug)));
%if 1=&debug. %then
  %do;
    options mprint symbolgen mlogic source source2 msglevel=i;
  %end;

%put NOTE- --&SYSMACRONAME.-START--;
%local rc;
%let rc = %sysfunc(doSubL(%nrstr(
  options
  %sysfunc(ifc(1=&debug.
  ,msglevel=I ls=max ps=64 notes mprint symbolgen mlogic source source2
  ,msglevel=N ls=max ps=64 nonotes nomprint nosymbolgen nomlogic nosource nosource2
  ))
  ;;;;

  options DLcreateDir;
  libname w "%sysfunc(pathname(WORK))/_splitCodeForPackage_";
  filename d "%sysfunc(pathname(WORK))/_splitCodeForPackage_/dummy";
  data _null_;
    file d;
    put "dummy";
  run;

  data _null_;
    length codeFile $ 4096;
    codeFile = symget('codeFile');
    codeFile = dequote(codeFile);
   
    if fileexist(codeFile) then 
      do;
        codeFile = quote(strip(codeFile),"'");
        call symputX("codeFile",codeFile,"L");
      end;
    else 
      do;      
        put "ERROR: [splitCodeForPackage] File " codeFile 'does not exist!';
        call symputX("codeFile",quote(strip(pathname('d'))),"L");
      end;
  run;

  options notes;
  filename source &codeFile.;
  filename source LIST;
  options nonotes;

  data _null_;
    length packagePath work $ 4096;
    work = pathname('WORK');
    packagePath = coalescec(symget('packagePath'), work);
    rc = fileexist(packagePath);
    if NOT rc then packagePath = work;
    if rc = 1 then put "INFO: " @;
              else put "WARNING: " @;
    put packagePath=; 
    call symputX('packagePath',packagePath,"L");
  run;

  data w.files;
    stop;
  run;

  data _null_;
    if 1 = _N_ then
      do;
        declare hash H(ordered:"A");
        H.defineKey('token');
        H.defineData('token','start','end','lineNumber');
        H.defineDone();
      end;
    if 1 = _E_ then
      do;
        H.output(dataset:'w.files');  
      end;

    infile source END=_E_;
    lineNumberN+1;
    input;

    length line $ 4096 lineNumber $ 256;
    line = left(lowcase(_infile_));
    block=scan(line,1," ");

    if block in ( 
      '/*##$##-code-block-start-##$##' 
      '/*##$##-code-block-end-##$##'
    ); 

    if substr(block,20,1) = 's' then 
      do; s=1; e=0; end;
    else
      do; s=0; e=1; end;

    i=1;
    token=block;
    do while(i);
      i+1;
      token=scan(line,i," ");
      if token='*/' OR token=' ' then i=0;
      else
        do;
          start=0; end=0;
          if H.find() then
            do;
              start=s;
              end  =e;
              lineNumber = cats(lineNumberN);
            end;
          else
            do;
              start+s;
              end  +e; 
              lineNumber = catx(",",lineNumber,lineNumberN);
            end;
          H.replace();
          /*putlog token= s= e= start= end=;*/
        end;
    end;
  run;

  title;
  title1 "Attention!!! Not Matching Tags!";
  title2 "Verify following tags in file:";
  title3 &codeFile.;
  proc print data=w.files(where=(start NE end));
  run;
  title;

  data w.files;
    set w.files end=_E_ nobs=nobs; 
    where start=end;
    length dir $ 128 code $ 32 path $ 160;
    dir =coalescec(scan(token,1,'()'),'!BAD_DIRECTORY');
    code=coalescec(scan(token,2,'()'),'!BAD_CODE_FILE');
    if dir = '!BAD_DIRECTORY' or code = '!BAD_CODE_FILE' then
      put "WARNING: Bad directory or code file name!" 
        / "WARNING- Check tag: " token ;
    path=cats('/',dir,'/',code,'.sas'); /* .sas */
  run;

  title;
  title1 "List of tags with value _ALL_ for 'dir' or 'code' variable.";
  title2 "Snippets tagged this way will be copied to multiple files.";
  proc print data=w.files(where=(dir = '_all_' OR code = '_all_'));
  run;
  title;

  data w.files;
    if 0=nobs then
      put "WARNING: No tags found in the file";
    
    set w.files end=_E_ nobs=nobs; 
    where dir NE '_all_' AND code NE '_all_';
    n+1;
    if 1 = _E_ then 
      call symputX('nobs',n,"L");
  run;

  title;
  title "List of files";
  proc print data=w.files;
  run;
  title;

  data _null_;
    set w.files;
    rc = libname("_",catx("/",symget('packagePath'),dir));
    rc = libname("_");
  run;

  filename f DUMMY;
  data _null_;
    if 1 =_N_ then
      do;
        array paths[0:&nobs.] $ 128 _temporary_;
        array starts[0:&nobs.] _temporary_;
        array ends[0:&nobs.] _temporary_;
        array write[0:&nobs.] _temporary_;
        array firstLine[0:&nobs.] _temporary_;

        declare hash H();
        H.defineKey('token');
        H.defineData('n');
        H.defineDone();

        do until(_E_);
          set w.files end=_E_;
          paths[n]=path;
          starts[n]=start;
          ends[n]=end;
          write[n]=0;
          rc=H.add();
          firstLine[n]=1;
        end;
        _E_=.;
        length packagePath $ 4096;
        retain packagePath " ";
        packagePath=symget('packagePath');
      end;

    infile source END=_E_;
    input;

    length line /*lineToPrint*/ $ 4096;
    line = left(lowcase(_infile_));
    /*lineToPrint=_infile_;*/
    block=scan(line,1," ");

    if block in (
      '/*##$##-code-block-start-##$##' 
      '/*##$##-code-block-end-##$##'
    ) then 
      do;
        /********************************************************/
        if substr(block,20,1) = 's' then 
          do; s=1; e=0; end;
        else
          do; s=0; e=1; end;

        i=1;
        token=block;
        do while(i);
          i+1;
          token=scan(line,i," ");
          if token='*/' OR token=' ' then i=0; /* if it is the end of list - stop */
          else if token='_all_(_all_)' then /* if this is a snippet for ALL files in a package */
            do k=1 to &nobs.;
              starts[k]+ -s;
              ends[k]  + -e;
              write[k] + (s-e);
            end;
          else if scan(token,2,'()')='_all_' then /* if this is a snippet for ALL files in a type */
            do k=1 to &nobs.;
              if scan(token,1,'()')=scan(paths[k],1,'/\') then 
                do;
                  starts[k]+ -s;
                  ends[k]  + -e;
                  write[k] + (s-e);
                end;
            end;
          else if scan(token,1,'()')='_all_' then /* if this is a snippet for ALL files with the same name */
            do k=1 to &nobs.;
              if (scan(token,2,'()')!!'.sas')=scan(paths[k],2,'/\') then 
                do;
                  starts[k]+ -s;
                  ends[k]  + -e;
                  write[k] + (s-e);
                end;
            end;
          else /* all other "regular" cases */
            do;
              if 0=H.find() then
                do;
                  starts[n]+ -s;
                  ends[n]  + -e;
                  write[n] + (s-e);
                  select;
                    when(write[n]<0)
                      putlog "ERROR: Wrong tags order for " token=;
                    when(write[n]>1) 
                      do;
                        putlog "WARNING: Doubled value for tag" token=;
                        putlog "WARNING- detected in line " _N_;
                        putlog "WARNING- Check also counterpart block.";
                      end;
                    otherwise;
                  end;
                end;
            end;
        end;
        /********************************************************/
      end;
    else
      do j = 1 to hbound(write);
        if write[j]>0 then
          do;
            length fvariable $ 4096;
            fvariable=catx("/",packagePath,paths[j]);
            file f FILEVAR=fvariable MOD;
            /*
            lineToPrintLen=(lengthn(lineToPrint));
            if lineToPrintLen then
              put @1 lineToPrint $varying4096. lineToPrintLen;
            else put;
            */
            if firstLine[j] then
              do;
                put '/* File generated with help of SAS Packages Framework, version 20251017. */';
                firstLine[j]=0;
              end; 
            put _infile_;
          end;    
      end;
  run;

  filename f clear;
  libname w clear;
)));
%put NOTE- --&sysmacroname.-END--;
options &options_tmp2.;
%ENDofsplitCodeForPackage:
%mend splitCodeForPackage;

/**/
