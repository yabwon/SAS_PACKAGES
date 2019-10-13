/*** HELP START ***/

/* >>> dsSQL() function: <<<
 *
 * Internal function called by %SQL() macro.
 *
 * Recomnended for SAS 9.3 and higher. 
 * Based on paper: 
 * "Use the Full Power of SAS in Your Function-Style Macros"
 * by Mike Rhoads, Westat, Rockville, MD
 * https://support.sas.com/resources/papers/proceedings12/004-2012.pdf
 *
**/

/*** HELP END ***/

proc fcmp 
  inlib  = work.&packageName.fcmp
  outlib = work.&packageName.fcmp.package
;
  function dsSQL(unique_index_2, query $) $ 41;
    length 
      query query_arg $ 32000 /* max querry length */
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
