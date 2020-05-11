/* This is the description file for the package.         */
/* The colon (:) is a field separator and is restricted */
/* in lines of the header part.                          */

/* **HEADER** */
Type: Package                                    :/*required, not null, constant value*/
Package: SQLinDS                                 :/*required, not null, up to 24 characters, naming restrictions like for a dataset name! */
Title: SQL queries in Data Step                  :/*required, not null*/
Version: 1.0                                     :/*required, not null*/
Author: Mike Rhoads (RhoadsM1@Westat.com)        :/*required, not null*/
Maintainer: Bartosz Jablonski (yabwon@gmail.com) :/*required, not null*/
License: MIT                                     :/*required, not null, values: MIT, GPL2, BSD, etc.*/
Encoding: UTF8                                   :/*required, not null, values: UTF8, WLATIN1, LATIN2, etc. */

Required: "Base SAS Software"                    :/*optional, COMMA separated, QUOTED list, names of required SAS products, values must be like from proc setinit;run; output */

/* **DESCRIPTION** */
/* All the text below will be used in help */
DESCRIPTION START:

The SQLinDS package is an implementation of  
the macro-function-sandwich concept introduced in: 
"Use the Full Power of SAS in Your Function-Style Macros"
the article by Mike Rhoads, Westat, Rockville, MD

Copy of the article is available at:
https://support.sas.com/resources/papers/proceedings12/004-2012.pdf

Package provides ability to "execute" SQL queries inside a datastep, e.g.

  data class;
    set %SQL(select * from sashelp.class);
  run;

SQLinDS package contains the following components:

 1) %SQL() macro - the main package macro available for the User

 2) dsSQL() function (internal)
 3) %dsSQL_inner() macro (internal) 
 4) Library DSSQL (created in a subdirectory of the WORK library)

See help for the %SQL() macro to find more examples. 

DESCRIPTION END:
