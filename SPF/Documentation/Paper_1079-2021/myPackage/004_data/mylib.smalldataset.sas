/*** HELP START ***/
/*
`myLib.smallDataset` data
*/
/*** HELP END ***/

data myLib.smallDataset;
  do n = ., -1, 0, 1;
    m = put(n, fmtNum.);
    output;
  end;
run;
