/*** HELP START ***/
/*
## >>> `%dsSQL_Inner()` macro: <<< <a name="dssql-inner-macro"></a> #############

**Internal** macro called by `dsSQL()` function.
The macro generates a uniquely named SQL view on the fly
which is then stored in the `dsSQL` library.
 
Recommended for *SAS 9.3* and higher. 

---
*/
/*** HELP END ***/

/* inner macro */
%MACRO dsSQL_Inner() / secure;
  %local query tempfile1 tempfile2 ps_tmp;
  %let query = %superq(query_arg); 
  %let query = %sysfunc(dequote(&query));

  %let viewname = dsSQL.dsSQLtmpview&UNIQUE_INDEX_2.;

  %let tempfile1 = A%sysfunc(datetime(), hex7.);
  %let tempfile2 = B%sysfunc(datetime(), hex7.);

  filename &tempfile1. temp;
  filename &tempfile2. temp;

  %let ps_tmp = %sysfunc(getoption(ps));
  options ps = MAX;
  proc printto log = &tempfile1.;
  run;
  /* get the query shape i.e. the executed one */
  proc sql feedback noexec;
    &query
    ;
  quit;
  proc printto;
  run;
  options ps = &ps_tmp.;

  %put *** executed as ***;
  data _null_;
    infile &tempfile1. FIRSTOBS = 2; /* <- 2 to ignore header */
    file &tempfile2.;
    /* create the view name */
    if _N_ = 1 then 
      put " create view &viewname. as ";
    input;
    put _infile_;
    putlog ">" _infile_;
  run;
  %put *****************;
  
  proc sql;
       %include &tempfile2.; /* the &query */
       ;
  quit;
  filename &tempfile1. clear;
  filename &tempfile2. clear;
%MEND dsSQL_Inner;
