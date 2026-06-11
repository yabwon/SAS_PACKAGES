/* "Le petit SAS package" workshop pieces, verbatim from
   SPF/Documentation/LePetitSASpackage/le_petit_SAS_package.sas:
   the %fox macro, the rose format, and the prince() FCMP function.
   The surrounding workshop narration and the SPF-loading preamble
   (local paths) are omitted so the code runs standalone. */

/*
## A Macro

This macro prints the fox's quotes to the log.
*/

%macro fox(quote);
  %local n e w;
  %let n = NOTE;
  %let e = ERROR;
  %let w = WARNING;
  %if 1=%superq(quote) %then
    %do;
      %put &n.- And now here is my secret, a very simple secret:;
      %put &n.- It is only with the heart that one can see rightly%str(;);
      %put &n.- what is essential is invisible to the eye.;
    %end;
  %else
  %if 2=%superq(quote) %then
    %do;
      %put &w.- It is the time you have wasted for your rose;
      %put &w.- that makes your rose so important.;
      %put &w.- Men have forgotten this truth. But you must not forget it.;
      %put &w.- You become responsible, forever, for what you have tamed.;
      %put &w.- You are responsible for your rose...;
    %end;
  %else
    %do;
      %put &e.- One only understands the things that one tames.;
      %put &e.- Men have no more time to understand anything.;
      %put &e.- They buy things all ready made at the shops.;
      %put &e.- But there is no shop anywhere where one can buy friendship,;
      %put &e.- and so men have no friends any more. If you want a friend, tame me...;
    %end;
%mend fox;

%fox(1)
%fox(2)
%fox()

/*
## A Format

This format displays values from 1 to 4 as rose's quotes.
*/

PROC FORMAT;
  value rose
  1="Ah! I am scarcely awake. I beg that you will excuse me. My petals are still all disarranged..."
  2="Of course I love you. It is my fault that you have not known it all the while. [...] Try to be happy..."
  3="My cold is not so bad as all that... The cool night air will do me good. I am a flower."
  4="Well, I must endure the presence of two or three caterpillars if I wish to become acquainted with the butterflies."
  other="ERROR: QUOTE OUT OF RANGE!"
  ;
RUN;

data _null_;
  do i = 1 to 5;
    put "NOTE- " i rose. /;
  end;
run;

/*
## A Function

This FCMP function returns the prince's quote:
"*If you please--draw me a sheep!*"
*/

PROC FCMP outlib=work.little.prince;
  function prince() $ 42;
    file log;

    length i $ 256;
    r=rand('integer',1,4);
    i = put(r, rose.);
    put @1 "RANDOM NOTE:" i /;

    return("If you please--draw me a sheep!");
  endfunc;
QUIT;

options append=(cmplib=work.little);

proc options option=cmplib;
run;

data _null_;
  do i = 1 to 5;
    prince=prince();
    rc=sleep(1,0.2);
  end;
  put prince=;
run;
