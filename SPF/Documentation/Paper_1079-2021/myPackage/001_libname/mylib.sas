/*** HELP START ***/
/*
`myLib` library
*/
/*** HELP END ***/

data _null_;
  length rc0 $ 32767 rc1 rc2 8;
  lib = "myLib";
  rc0 = DCREATE(lib, "%sysfunc(pathname(work))/");
  put rc0 = ;
  rc1 = LIBNAME(lib, "%sysfunc(pathname(work))/" !! lib, "BASE"); 
  rc2 = LIBREF (lib);
  if rc2 NE 0 then 
    rc1 = LIBNAME(lib, "%sysfunc(pathname(work))", "BASE");
run;

libname myLib LIST;
