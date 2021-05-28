/*** HELP START ***//*
 
## >>> library `dsSQL`: <<< <a name="library-dssql"></a> ########################

The `dsSQL` library stores temporary views 
generated during the `%SQL()` macro execution.

If possible a subdirectory of the `WORK` location is created, like: 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
LIBNAME dsSQL BASE "%sysfunc(pathname(WORK))/dsSQLtmp";
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if not possible, then redirects to the `WORK` location, like:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
LIBNAME dsSQL BASE "%sysfunc(pathname(WORK))"; 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
---

*//*** HELP END ***/

data _null_;
  length rc0 $ 32767 rc1 rc2 8;
  rc0 = DCREATE("dsSQLtmp", "%sysfunc(pathname(work))/"                );
  rc1 = LIBNAME("dsSQL",    "%sysfunc(pathname(work))/dsSQLtmp", "BASE"); 
  rc2 = LIBREF ("dsSQL"                                                );
  if rc2 NE 0 then 
    rc1 = LIBNAME("dsSQL", "%sysfunc(pathname(work))", "BASE"); 
run;

/* list the details about the library in the log */
libname dsSQL LIST;
