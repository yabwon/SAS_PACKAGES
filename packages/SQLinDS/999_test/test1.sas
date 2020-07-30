proc sort data=sashelp.class out=test1;
  by age name;
run;

data class;
  set %SQL(select * from sashelp.class order by age, name);
run;

proc compare base = test1 compare = class;
run;
