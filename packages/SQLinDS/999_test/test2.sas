data class_work;
  set sashelp.class;
run;

data test_work;
  set %sql(select * from class_work);
run;

options dlcreatedir;
libname user "%sysfunc(pathname(work))/user";
%put *%sysfunc(pathname(user))*;

data cars_user cars_user2;
  set sashelp.cars;
run;

data test_user;
  set %sql(select * from cars_user);
run;

data test_user2;
  set %sql(select * from user.cars_user2);
run;

libname user clear;
%put *%sysfunc(pathname(user))*;

proc datasets lib = work;
run;
