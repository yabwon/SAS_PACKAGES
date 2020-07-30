
options dlCreateDir;
libname dsSQL "%sysfunc(pathname(work))/dsSQLtmp";

/* makro zewnetrzne */
%MACRO SQL() / PARMBUFF SECURE; 
  %let SYSPBUFF = %superq(SYSPBUFF); /* maskujemy znaki specjalne */
  %let SYSPBUFF = %substr(&SYSPBUFF,2,%LENGTH(&SYSPBUFF) - 2); /* kasujemy otwierający i zamykający nawias */
  %let SYSPBUFF = %superq(SYSPBUFF); /* maskujemy jeszcze raz */
  %let SYSPBUFF = %sysfunc(quote(&SYSPBUFF)); /* dodajemy cudzyslowy */
  %put ***the querry***;
  %put &SYSPBUFF.;
  %put ****************;

  %local UNIQUE_INDEX; /* dodatkowa zmienna indeksujaca, zeby tworzony widok byl unikalny */
  %let UNIQUE_INDEX = &SYSINDEX; /* przypisujemy jej wartosc */
  %sysfunc(dsSQL(&UNIQUE_INDEX, &SYSPBUFF)) /* <-- wywolulemy funkcje dsSQL */
%MEND SQL;

/* funkcja */
%macro MacroFunctionSandwich_functions();

%local _cmplib_;
options APPEND=(cmplib = WORK.DATASTEPSQLFUNCTIONS) ;
%let _cmplib_ = %sysfunc(getoption(cmplib));
%put NOTE:[&sysmacroname.] *&=_cmplib_*;

options cmplib = _null_;

proc fcmp outlib=work.datastepSQLfunctions.package;
  function dsSQL(unique_index_2, query $) $ 41;

    length query query_arg $ 32000 viewname $ 41; /* query_arg mozna zmienic na dluzszy, np. 32000 :-) */
    query_arg = dequote(query);
    rc = run_macro('dsSQL_Inner', unique_index_2, query_arg, viewname); /* <-- wywolulemy makro wewnetrzne dsSQL_Inner */
    if rc = 0 then return(trim(viewname));
              else do;
                   return(" ");
                   put 'ERROR:[function dsSQL] A problem with the function';
                   end;
  endsub;
run;

options cmplib = &_cmplib_.;
%let _cmplib_ = %sysfunc(getoption(cmplib));
%put NOTE:[&sysmacroname.] *&=_cmplib_*;

%mend MacroFunctionSandwich_functions;
%MacroFunctionSandwich_functions()

/* delete macro MacroFunctionSandwich_functions since it is not needed */
proc sql;
  create table _%sysfunc(datetime(), hex16.)_ as
  select memname, objname
  from dictionary.catalogs
  where 
    objname = upcase('MACROFUNCTIONSANDWICH_FUNCTIONS')
    and objtype = 'MACRO'
    and libname  = 'WORK'
  order by memname, objname
  ;
quit;
data _null_;
  set _last_;
  call execute('proc catalog cat = work.' !! strip(memname) !! ' et = macro force;');
  call execute('delete ' !! strip(objname) !! '; run;');
  call execute('quit;');
run;
proc delete data = _last_;
run;

/* makro wewnetrzne */
%MACRO dsSQL_Inner() / SECURE;
  %local query;
  %let query = %superq(query_arg); 
  %let query = %sysfunc(dequote(&query));

  %let viewname = dsSQL.dsSQLtmpview&UNIQUE_INDEX_2;
  proc sql;
    create view &viewname as &query;
  quit;
%MEND dsSQL_Inner; 
