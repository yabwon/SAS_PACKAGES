/*** HELP START ***/

/* >>> dsSQL library: <<< 
 *
 * The dsSQL library stores temporary views 
 * generated during the %SQL() macro execution.
 * If possible a subdirectory of WORK is created as: 

   LIBNAME dsSQL BASE "%sysfunc(pathname(WORK))/dsSQLtmp";

 * if not possible then redirects to WORK as:

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

/* list details about the library in the log */
libname dsSQL LIST;
