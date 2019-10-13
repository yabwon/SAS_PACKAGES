/*** HELP START ***/

/* >>> %SQL() macro: <<<
 *
 * Main macro which allows to use 
 * SQL's queries in the data step. 
 * Recomnended for SAS 9.3 and higher. 
 * Based on paper: 
 * "Use the Full Power of SAS in Your Function-Style Macros"
 * by Mike Rhoads, Westat, Rockville, MD
 * https://support.sas.com/resources/papers/proceedings12/004-2012.pdf
 *
 * EXAMPLE 1: simple sql querry

   data class_subset;
     set %SQL(select name, sex, height from sashelp.class where age > 12);
   run;

 * EXAMPLE 2: with dataset options

   data renamed;
     set %SQL(select * from sashelp.class where sex = "F")(rename = (age=age2));
   run;

 * EXAMPLE 3: dictionaries in datastep

   data dictionary;
     set %SQL(select * from dictionary.macros);
   run;

**/

/*** HELP END ***/


/* outer macro */
%MACRO SQL() / PARMBUFF SECURE; 
  %let SYSPBUFF = %superq(SYSPBUFF); /* macroquoting */
  %let SYSPBUFF = %substr(&SYSPBUFF, 2, %LENGTH(&SYSPBUFF) - 2); /* remove brackets */
  %let SYSPBUFF = %superq(SYSPBUFF); /* macroquoting */
  %let SYSPBUFF = %sysfunc(quote(&SYSPBUFF)); /* quotes */
  %put NOTE-***the querry***; /* print out the querry in the log */
  %put NOTE-&SYSPBUFF.;
  %put NOTE-****************;

  %local UNIQUE_INDEX; /* internal variable, a unique index for views */
    %let UNIQUE_INDEX = &SYSINDEX; 
  %sysfunc(dsSQL(&UNIQUE_INDEX, &SYSPBUFF)) /* <-- call dsSQL() function, 
                                                   see the WORK.SQLinDSfcmp dataset */
%MEND SQL;
