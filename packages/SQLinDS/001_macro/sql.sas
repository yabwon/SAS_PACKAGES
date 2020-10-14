/*** HELP START ***/
/*
## >>> `%SQL()` macro: <<< <a name="dssql-macro"></a> ###########################

The **main** macro which allows to use 
SQL queries in the data step.
 
Recommended for *SAS 9.3* and higher.
 
Based on the article *"Use the Full Power of SAS in Your Function-Style Macros"*
by *Mike Rhoads* (Westat, Rockville), available at:
[https://support.sas.com/resources/papers/proceedings12/004-2012.pdf](https://support.sas.com/resources/papers/proceedings12/004-2012.pdf)

### SYNTAX: ###################################################################
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
%sql(<nonempty sql querry code>)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The sql query code is limited to *32000* bytes.

### EXAMPLES: #################################################################

**EXAMPLE 1**: simple SQL query
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
data class_subset;
  set %SQL(select name, sex, height from sashelp.class where age > 12);
run;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**EXAMPLE 2**: query with dataset options
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
data renamed;
  set %SQL(select * from sashelp.class where sex = "F")(rename = (age=age2));
run;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**EXAMPLE 3**: dictionaries in the data step
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
data dictionary;
  set %SQL(select * from dictionary.macros);
run;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
---
*/
/*** HELP END ***/


/* Main User macro */
%MACRO SQL() / PARMBUFF SECURE; 
  %let SYSPBUFF = %superq(SYSPBUFF); /* macroquoting */
  %let SYSPBUFF = %substr(&SYSPBUFF, 2, %LENGTH(&SYSPBUFF) - 2); /* remove brackets */
  %let SYSPBUFF = %superq(SYSPBUFF); /* macroquoting */
  %let SYSPBUFF = %sysfunc(quote(&SYSPBUFF)); /* quotes */
  %put NOTE:*** the query ***; /* print out the query in the log */
  %put NOTE-&SYSPBUFF.;
  %put NOTE-*****************;

  %local UNIQUE_INDEX; /* internal variable, a unique index for views */
    %let UNIQUE_INDEX = &SYSINDEX; 
  %sysfunc(dsSQL(&UNIQUE_INDEX, &SYSPBUFF)) /* <-- call dsSQL() function, 
                                                   see the WORK.SQLinDSfcmp dataset */
%MEND SQL;
