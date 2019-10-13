/*** HELP START ***/

/* >>> dsSQL library: <<<
 *
 * The dsSQL library stores temporary views 
 * generated during %SQL() macro's execution.
 * If possible, created as a subdirectory of WORK: 

   options dlCreateDir;
   LIBNAME dsSQL BASE "%sysfunc(pathname(WORK))/dsSQLtmp";

 * if not then redirected to WORK

   LIBNAME dsSQL BASE "%sysfunc(pathname(WORK))"; 

**/

/*** HELP END ***/

data WORK._%sysfunc(datetime(), hex16.)_;
  length option $ 64;
  option = getoption("dlCreateDir");
run;

options dlCreateDir;

data _null_;
  set _LAST_;
  rc1 = LIBNAME("dsSQL", "%sysfunc(pathname(work))/dsSQLtmp", "BASE"); 
  rc2 = LIBREF("dsSQL");
  if rc2 NE 0 then 
    rc1 = LIBNAME("dsSQL", "%sysfunc(pathname(work))", "BASE"); 
  call execute ("options " || strip(option) || ";");
run;

proc delete data = _last_;
run;

libname dsSQL LIST;
;

