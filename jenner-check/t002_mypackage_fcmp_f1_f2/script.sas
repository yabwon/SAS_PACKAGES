/* myPackage's F1 and F2 FCMP functions, verbatim from
   SPF/Documentation/Paper_1079-2021/myPackage/002_functions/f1.sas
   and f2.sas, wrapped in PROC FCMP the same way the SAS Packages
   Framework compiles them at %loadPackage() time. The caller data
   step feeds them the same values (n = ., -1, 0, 1) that
   myPackage's smallDataset is built from. */

proc fcmp outlib = work.myPackagefcmp.package;

/* f1.sas */
function F1(n);
  return (n+1);
endsub;

/* f2.sas */
function F2(n);
  return (n+2);
endsub;

run;
quit;

options cmplib = work.myPackagefcmp;

data f_check;
  do n = ., -1, 0, 1;
    p = F1(n);
    q = F2(n);
    output;
  end;
run;

proc print data=f_check;
run;
