/*** HELP START ***/
/*
`fmtNum` format
*/
/*** HELP END ***/

value fmtNum
  low -< 0         = "negative"
         0         = "zero"
         0 <- high = "positive"
         other     = "missing"
  ;
