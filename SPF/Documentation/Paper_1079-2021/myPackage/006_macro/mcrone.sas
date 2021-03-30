/*** HELP START ***/
/*
`mcrOne` macro
*/
/*** HELP END ***/

%macro mcrOne();
  %put **Hi! This is macro &sysmacroname.**;
  data _null_;
    set myLib.smallDataset;
    p = f1(n);
    p + f2(n);
    put (n p) (= fmtNum.);
  run;
%mend mcrOne;
