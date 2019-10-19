# SAS_PACKAGES

SAS Packages Repository

### The User:

- Create a folder for your packages, e.g. under Windows OS family `C:/SAS_PACKAGES` or under Linux/UNIX OS family `/home/<username>/SAS_PACKAGES`.
- Copy the `loadpackage.sas` file into the packages' folder.
- Copy the `<packageName>.zip` file into the packages' folder.
- Execute:
```
filename packages "<directory/containing/packages/>";
%include packages(loadpackage.sas);
%loadPackage(packageName)
```
### The Developer:

Read the `SAS(r) packages - the way to share (a how to)- Paper 4725-2020.pdf` to learn more.

### Avaliable packages:

- *SQLinDS*, allows to write SQL queries in the datastep
- *DFA* (Dynamic Function Arrays), contains FCMP implementation of dynamic array, stac, fifo, ordered stack, and priority queue
- *dynMacroArray*, set of macros (wrappers for a hash table) emulating dynamic array in the datastep
- *macroArray*, implementation of an array concept in macrolanguage (e.g. `%array(ABC[17] (1:17), macarray=Y); %do i = 1 %to 17; %put %ABC(&i.); %end;`)