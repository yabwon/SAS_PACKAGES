/*** HELP START ***/
/*
## General Info: ##

The `%mcrTwo()` macro is the main macro of the package. 

It has one key-value parameter `m` with default value `mcrOne`.
*/
/*** HELP END ***/

%macro mcrTwo(m=mcrOne);
  %put **This is macro &sysmacroname.**;
  %put **and I am calling the &m.**;
  %&m.()

  %put The answer is: %sysfunc(inputn("I don't know...", infNum.));
%mend mcrTwo;

/*** HELP START ***/
/*
## Examples: ##

Example 1. Basic use-case:
~~~~~~~~~~~~~~~~~~~~~~~~~~

%mcrTwo(m=mcrOne)

~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
/*** HELP END ***/
