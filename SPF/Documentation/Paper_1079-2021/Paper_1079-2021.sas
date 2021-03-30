/*one library "myLib" created in the (same named) subderectory of the "WORK" directory.*/
data _null_;
  length rc0 $ 32767 rc1 rc2 8;
  lib = "myLib";
  rc0 = DCREATE(lib, "%sysfunc(pathname(work))/");
  put rc0 = ;
  rc1 = LIBNAME(lib, "%sysfunc(pathname(work))/" !! lib, "BASE"); 
  rc2 = LIBREF (lib);
  if rc2 NE 0 then 
    rc1 = LIBNAME(lib, "%sysfunc(pathname(work))", "BASE");
run;

libname myLib LIST;

/*two FCMP functions: "F1" and "F2", */
proc FCMP outlib = work.f.p;
  function F1(n);
    return (n+1);
  endsub;

  function F2(n);
    return (n+2);
  endsub;
run;
options cmplib = work.f; 

/*one numeric format "fmtNum" and informat "infNum", */
proc FORMAT;
  value fmtNum
  low -< 0         = "negative"
         0         = "zero"
         0 <- high = "positive"
         other     = "missing"
  ;
  invalue infNum
    "negative" = -1
    "zero"     =  0
    "positive" =  1
    "missing"  =  .
    other      = 42
  ;
run;

/*one exemplary small dataset "myLib.smallDataset", and*/
data myLib.smallDataset;
  do n = ., -1, 0, 1;
    m = put(n, fmtNum.);
    output;
  end;
run;

/*one exemplary bigger dataset "myLib.biggerDataset".*/
data myLib.biggerDataset;
  do i = ., -1e6 to 1e6;
    j = put(i, fmtNum.);
    k = ranuni(17);
    output;
  end;
run;

/*two macros: "mcrOne" and "mcrTwo" */
%macro mcrOne();
  %put **Hi! This is macro &sysmacroname.**;
  data _null_;
    set myLib.smallDataset;
    p = f1(n);
    p + f2(n);
    put (n p) (= fmtNum.);
  run;
%mend mcrOne;

%macro mcrTwo(m=mcrOne);
  %put **This is macro &sysmacroname.**;
  %put **and I am calling the &m.**;
  %&m.()

  %put The answer is: %sysfunc(inputn("I don't know...", infNum.));
%mend mcrTwo;

/* %mcrTwo() */
