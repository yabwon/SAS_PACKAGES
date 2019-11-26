/*** HELP START ***/

/* >>> dsSQL library: <<< 
 *
 * The dsSQL library stores temporary views 
 * generated during %SQL() macro's execution.
 * If possible, created as a subdirectory of WORK: 

   LIBNAME dsSQL BASE "%sysfunc(pathname(WORK))/dsSQLtmp";

 * if not then redirected to WORK

   LIBNAME dsSQL BASE "%sysfunc(pathname(WORK))"; 

**/

/*** HELP END ***/

data _null_;
  length rc0 $ 32767 rc1 rc2 8;
  rc0 = DCREATE("dsSQLtmp", "%sysfunc(pathname(work))/"                );
  rc1 = LIBNAME("dsSQL",    "%sysfunc(pathname(work))/dsSQLtmp", "BASE"); 
  rc2 = LIBREF ("dsSQL"                                                );
  if rc2 NE 0 then 
    rc1 = LIBNAME("dsSQL", "%sysfunc(pathname(work))", "BASE"); 
run;

libname dsSQL LIST;
;

