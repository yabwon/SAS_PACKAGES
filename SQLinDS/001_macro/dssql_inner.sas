/*** HELP START ***/

/* >>> %dsSQL_Inner() macro: <<<
 *
 * Internal macro called by dsSQL() function. 
 *  
 * Recomnended for SAS 9.3 and higher. 
 * Based on paper: 
 * "Use the Full Power of SAS in Your Function-Style Macros"
 * by Mike Rhoads, Westat, Rockville, MD
 * https://support.sas.com/resources/papers/proceedings12/004-2012.pdf
 *
**/

/*** HELP END ***/

/* inner macro */
%MACRO dsSQL_Inner() / SECURE;
  %local query;
  %let query = %superq(query_arg); 
  %let query = %sysfunc(dequote(&query));

  %let viewname = dsSQL.dsSQLtmpview&UNIQUE_INDEX_2.;
  proc sql;
    create view &viewname as 
      &query
    ;
  quit;
%MEND dsSQL_Inner;
