/* myPackage's infNum informat, verbatim from
   SPF/Documentation/Paper_1079-2021/myPackage/003_formats/infnum.sas,
   wrapped in PROC FORMAT the same way the SAS Packages Framework
   compiles it at %loadPackage() time. The caller data step reads the
   words infNum understands, plus the phrase myPackage's %mcrTwo()
   macro famously feeds it ("I don't know..." => 42). */

proc format;

/* infnum.sas */
invalue infNum
    "negative" = -1
    "zero"     =  0
    "positive" =  1
    "missing"  =  .
    other      = 42
  ;

run;

data answers;
  input word $char16.;
  value = inputn(word, "infNum.");
  datalines;
negative
zero
positive
missing
I don't know...
;
run;

proc print data=answers;
run;
