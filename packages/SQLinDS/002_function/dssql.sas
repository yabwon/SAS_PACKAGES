/*** HELP START ***//*
 
## >>> `dsSQL()` function: <<< <a name="dssql-function"></a> ####################

**Internal** function called by the `%SQL()` macro.
The function pass a query code from the `%SQL()`
macro to the `%dsSQL_Inner()` internal macro.

Recommended for *SAS 9.3* and higher. 

### SYNTAX: ###################################################################
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
dsSQL(unique_index_2, query)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Arguments description**:

1. `unique_index_2` - *Numeric*, internal variable, a unique index for views.

2. `query` -          *Character*, internal variable, contains query text.

---

*//*** HELP END ***/

proc fcmp 
  /*inlib  = work.&packageName.fcmp*/
  outlib = work.&packageName.fcmp.package
;
  function dsSQL(unique_index_2, query $) $ 41;
    length 
      query query_arg $ 32000 /* max query length */
      viewname $ 41
    ;
    query_arg = dequote(query);
    rc = run_macro('dsSQL_Inner' /* <-- inner macro */
                  ,unique_index_2
                  ,query_arg
                  ,viewname
                  ); 
    if rc = 0 then return(trim(viewname));
    else 
      do;
         put 'ERROR:[function dsSQL] A problem with the dsSQL() function';
         return(" ");
      end;
  endsub;
run;
quit;
