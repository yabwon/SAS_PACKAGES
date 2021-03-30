/*** HELP START ***/
/*
`myLib.biggerDataset` data
*/
/*** HELP END ***/

data myLib.biggerDataset;
  do i = ., -1e6 to 1e6;
    j = put(i, fmtNum.);
    k = ranuni(17);
    output;
  end;
run;
