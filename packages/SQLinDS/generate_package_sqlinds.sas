resetline;

filename packages "C:\SAS_PACKAGES\SPF";
%include packages(SPFinit.sas);

ods html;
%generatePackage(filesLocation=C:\SAS_PACKAGES_DEV\SQLinDS)


/*
 * filename reference "packages" and "package" are keywords;
 * the first one should be used to point folder with packages;
 * the second is used internally by macros;
 
filename packages "C:\SAS_PACKAGES";
%include packages(SPFinit.sas);

dm 'log;clear';
%loadpackage(SQLinDS)

%helpPackage(SQLinDS)
%helpPackage(SQLinDS,*)

%unloadPackage(SQLinDS)
*/
