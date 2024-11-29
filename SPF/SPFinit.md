
- [SAS PAckages Framework help](#helpinfo)
  * [the `installPackage` macro](#installpackage)
  * [the `helpPackage` macro](#helppackage)
  * [the `loadPackage` macro](#loadpackage)
  * [the `loadPackageS` macro](#loadpackages)
  * [the `unloadPackage` macro](#unloadpackage)
  * [the `listPackages` macro](#listpackages)
  * [the `verifyPackage` macro](#verifypackage)
  * [the `previewPackage` macro](#previewPackage)
  * [the `generatePackage` macro](#generatepackage)
  * [the `extendPackagesFileref` macro](#extendpackagesfileref)
  * [the `loadPackageAddCnt` macro](#loadpackageaddcnt)
  * [the `splitCodeForPackage` macro](#splitcodeforpackage)
  * [Some more examples](#some-more-examples)

---


##      This is short SAS Packages Framework help information <a name="helpinfo"></a>

A **SAS package** is an automatically generated, single, stand alone *zip* file containing organised and ordered code structures, created by the developer and extended with additional automatically generated "driving" files (i.e. description, metadata, load, unload, and help files). 

The *purpose of a package* is to be a simple, and easy to access, code sharing medium, which will allow: on the one hand, to separate the code complex dependencies created by the developer from the user experience with the final product and, on the other hand, reduce developer's and user's unnecessary frustration related to a remote deployment process.

In this repository we are presenting the **SAS Packages Framework** which allows to develop and use SAS packages. The latest version of SPF is **`20241129`**.  

**To get started with SAS Packages** try this [**`Getting Started with SAS Packages`**](https://github.com/yabwon/SAS_PACKAGES/blob/main/SPF/Documentation/Getting_Started_with_SAS_Packages.pdf "Getting Started with SAS Packages") presentation (see the `./SPF/Documentation` directory).

**The documentation and more advance reading** would be the [**`SAS(r) packages - the way to share (a how to)- Paper 4725-2020 - extended.pdf`**](https://github.com/yabwon/SAS_PACKAGES/blob/main/SPF/Documentation/SAS(r)%20packages%20-%20the%20way%20to%20share%20(a%20how%20to)-%20Paper%204725-2020%20-%20extended.pdf "SAS packages - the way to share") article (see the `./SPF/Documentation` directory).


*Note:* Filenames references `packages` and `package` are **reserved keywords.**
The first one should be used to point local folder with packages and the framework.
The second is used internally by macros.
After assigning the directory do not change them when using the SPF since it may affect stability of the framework.

--------------------------------------------------------------------------------------------


##       This is short help information for the `installPackage` macro <a name="installpackage"></a>                     
--------------------------------------------------------------------------------------------
                                                                                            
 Macro to install SAS packages, version `20241129`                                          
                                                                                            
 A SAS package is a zip file containing a group                                             
 of SAS codes (macros, functions, data steps generating                                     
 data, etc.) wrapped up together and embedded inside the zip.                               
                                                                                            
 The `%installPackage()` macro installs the package zip                                     
 in the packages folder. The process of installation is equivalent with                     
 manual downloading the package zip file into the packages folder.                          
                                                                                            
 In case the packages fileref is a multi-directory one the first directory                  
 will be selected as a destination.                                                         
                                                                                            
--------------------------------------------------------------------------------------------
                                                                                            
### Parameters:                                                                             
                                                                                            
 1. `packagesNames` Space separated list of packages names _without_                        
                    the zip extension, e.g. myPackage1 myPackage2,                          
                    Required and not null, default use case:                                
                    `%installPackage(myPackage1 myPackage2)`.                               
                    If empty displays this help information.                                
                    If the package name is *SPFinit* or *SASPackagesFramework*              
                    then the framework itself is downloaded.                                
                                                                                            
 - `sourcePath=`   Location of the package, e.g. "www.some.web.page/" (mind the "/" at the end of the path!)  
                   Current default location for packages is:                                
                   `https://github.com/SASPAC/`                                             
                   Current default location for the framework is:                           
                   `https://raw.githubusercontent.com/yabwon/SAS_PACKAGES/main/SPF/`        
                                                                                            
 - `mirror=`       Indicates which web location for packages installation is used.          
                   Value `0` indicates:                                                     
                   `https://github.com/SASPAC/`                                             
                   Value `1` indicates:                                                     
                   `https://raw.githubusercontent.com/yabwon/SAS_PACKAGES/main`             
                   Value `2` indicates:                                                     
                   `https://pages.mini.pw.edu.pl/~jablonskib/SASpublic/SAS_PACKAGES`        
                   Default value is `0`.                                                    
                                                                                            
 - `version=`      Indicates which historical version of a package to install.              
                   Historical version are available only if `mirror=0` is set.              
                   Default value is null which means "install the latest".                  
                   When there are multiple packages to install version                      
                   is scan sequentially.                                                    
                                                                                            
 - `replace=`      With default value of `1` it causes existing package file                
                   to be replaced by new downloaded file.                                   
                                                                                            
 - `URLuser=`      A user name for the password protected URLs, no quotes needed.           
                                                                                           
 - `URLpass=`      A password for the password protected URLs, no quotes needed.            
                                                                                           
 - `URLoptions=`   Options for the `sourcePath` URLs filename. Consult the SAS              
                   documentation for the further details.                                   
                                                                                            
 - `loadAddCnt=`   *Optional.* A package zip may contain additional                         
                   content. The option indicates if it should be loaded                     
                   Default value of zero (`0`) means "No", one (`1`)                        
                   means "Yes". Content is extracted into the **packages** fileref          
                   directory in `<packageName>_AdditionalContent` folder.                   
                   For other locations use `%loadPackageAddCnt()` macro.                    
                                                                                            
 - `SFRCVN=`      *Optional.* Provides a NAME for a macro variable to store value of the    
                  *success-failure return code* of the installation process. Return value   
                  has the following form: `<number of successes>.<number of failures>`      
                  The macro variable is created as a *global* macro variable.                
                                                                                            
--------------------------------------------------------------------------------------------
                                                                                            
 Visit: `https://github.com/yabwon/SAS_PACKAGES/tree/main/SPF/Documentation` to learn more.
                                                                                            
### Example ################################################################################
                                                                                            
   Enabling the SAS Package Framework                                                       
   from the local directory and installing & loading                                        
   the SQLinDS package from the Internet.                                                   
                                                                                            
   Assume that the `SPFinit.sas` file                                                       
   is located in the "C:/SAS_PACKAGES/" folder.                                             
                                                                                            
   Run the following code in your SAS session:                                              
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
filename packages "C:/SAS_PACKAGES"; %* setup a directory for packages;
%include packages(SPFinit.sas);      %* enable the framework;

%installPackage(SQLinDS)  %* install the package from the Internet;
%helpPackage(SQLinDS)     %* get help about the package;
%loadPackage(SQLinDS)     %* load the package content into the SAS session;
%unloadPackage(SQLinDS)   %* unload the package content from the SAS session;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

### Example ################################################################################
                                                                                            
   Enabling the SAS Package Framework                                                       
   from the local directory and installing & loading                                        
   the multiple packages from the Internet.                                                   
                                                                                            
   Assume that the `SPFinit.sas` file                                                       
   is located in the "C:/SAS_PACKAGES/" folder.                                             
                                                                                            
   Run the following code in your SAS session:                                              
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
filename packages "C:/SAS_PACKAGES"; 
%include packages(SPFinit.sas);      

%installPackage(baseplus(1.17) macroarray(1.0) dfa(0.5) GSM)
%loadPackageS(GSM, baseplus(1.17), macroarray(1.0), dfa(0.5))
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


##       This is short help information for the `helpPackage` macro <a name="helppackage"></a>           
-------------------------------------------------------------------------------
                                                                               
 Macro to get help about SAS packages, version `20241129`                      
                                                                               
 A SAS package is a zip file containing a group                                
 of SAS codes (macros, functions, data steps generating                        
 data, etc.) wrapped up together and provided with                             
 a single `help.sas` file (also embedded inside the zip).                      
                                                                               
 The `%helpPackage()` macro prints in the SAS log help                         
 information about the package provided by the developer.                      
                                                                               
-------------------------------------------------------------------------------
                                                                               
### Parameters:                                                                
                                                                               
 1. `packageName`      *Required.* Name of a package, e.g. myPackage,          
                       Required and not null, default use case:                
                        `%helpPackage(myPackage).`                             
                       If empty displays this help information.                
                                                                               
 2. `helpKeyword`      *Optional.*  A phrase to search in help,                
                       - when empty prints description,                        
                       - "*" means: print all help,                            
                       - "license" prints the license.                         
                                                                               
 - `path=`             *Optional.* Location of a package. By default it        
                       looks for location of the **packages** fileref, i.e.    
                        `%sysfunc(pathname(packages))`                         
                                                                               
 - `options=`          *Optional.* Possible options for ZIP filename,          
                       default value: `LOWCASE_MEMNAME`                        
                                                                               
 - `source2=`          *Optional.* Option to print out details about           
                       what is loaded, null by default.                        
                                                                               
 - `zip=`              Standard package is zip (lowcase),                      
                        e.g. `%helpPackage(PiPackage)`.                        
                       If the zip is not available use a folder.               
                       Unpack data to "pipackage.disk" folder                  
                       and use helpPackage in the following form:              
                        `%helpPackage(PiPackage, , zip=disk, options=)`          
                                                                               
 - `packageContentDS=` *Optional.* Indicates if a data set with package        
                       content should be generated in `WORK`,                  
                       with default value (`0`) the dataset is not produced,   
                       if set to `1` then `WORK.packageName_content`.          
                                                                               
-------------------------------------------------------------------------------
                                                                               
 Visit: `https://github.com/yabwon/SAS_PACKAGES/tree/main/SPF/Documentation` 
 to learn more.                                                                
                                                                               
## Example ####################################################################
                                                                               
   Enabling the SAS Package Framework                                          
   from the local directory and installing & loading                           
   the SQLinDS package from the Internet.                                      
                                                                               
   Assume that the `SPFinit.sas` file                                          
   is located in the "C:/SAS_PACKAGES/" folder.                                
                                                                               
   Run the following code in your SAS session:                                 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
filename packages "C:/SAS_PACKAGES"; %* setup a directory for packages;
%include packages(SPFinit.sas);      %* enable the framework;

%installPackage(SQLinDS)  %* install the package from the Internet;
%helpPackage(SQLinDS)     %* get help about the package;
%loadPackage(SQLinDS)     %* load the package content into the SAS session;
%unloadPackage(SQLinDS)   %* unload the package content from the SAS session;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

---

##      This is short help information for the `loadPackage` macro <a name="loadpackage"></a>            
-------------------------------------------------------------------------------
                                                                               
 Macro to *load* SAS packages, version `20241129`                              
                                                                               
 A SAS package is a zip file containing a group                                
 of SAS codes (macros, functions, data steps generating                        
 data, etc.) wrapped up together and included by                               
 a single `load.sas` file (also embedded inside the zip).                      
                                                                               
 The `%loadPackage()` macro loads package content, i.e. macros,                
 functions, formats, etc., from the zip into the SAS session.                  
                                                                               
-------------------------------------------------------------------------------
### Parameters:                                                                
                                                                               
 1. `packageName`      *Required.* Name of a package, e.g. myPackage,          
                       Required and not null, default use case:                
                        `%loadPackage(myPackage).`                             
                       If empty displays this help information.                
                                                                               
 - `path=`             *Optional.* Location of a package. By default it        
                       looks for location of the **packages** fileref, i.e.    
                        `%sysfunc(pathname(packages))`                         
                                                                               
 - `options=`          *Optional.* Possible options for ZIP filename,          
                       default value: `LOWCASE_MEMNAME`                        
                                                                               
 - `source2=`          *Optional.* Option to print out details about           
                       what is loaded, null by default.                        
                                                                               
 - `requiredVersion=`  *Optional.* Option to test if the loaded                
                       package is provided in required version,                
                       default value: `.`                                      
                                                                               
 - `lazyData=`         *Optional.* A space separated list of names of lazy     
                       datasets to be loaded. If not null datasets from the    
                       list are loaded instead of the package.                 
                       An asterisk (*) means *load all lazy datasets*.         
                                                                               
 - `zip=`              *Optional.* Standard package is zip (lowcase),          
                        e.g. `%loadPackage(PiPackage)`.                        
                       If the zip is not available use a folder.               
                       Unpack data to "pipackage.disk" folder                  
                       and use loadPackage in the following form:              
                        `%loadPackage(PiPackage, zip=disk, options=)`          
                                                                               
 - `cherryPick=`       *Optional.* A space separated list of selected elements 
                       of the package to be loaded into the SAS session.       
                       Default value of an asterisk (*) means:                 
                       "load all elements of the package".                     
                                                                               
 - `loadAddCnt=`       *Optional.* A package zip may contain additional        
                       content. The option indicates if it should be loaded    
                       Default value of zero (`0`) means "No", one (`1`)       
                       means "Yes". Content is extracted into the **Work**     
                       directory in `<packageName>_AdditionalContent` folder.  
                       For other locations use `%loadPackageAddCnt()` macro.   
                                                                               
 - `suppressExec=`     *Optional.* Indicates if loading of `exec` type files   
                       should be suppressed, default value is `0`,             
                       when set to `1` `exec` files are *not* loaded           
                                                                               
 - `DS2force=`         *Optional.* Indicates if loading of `PROC DS2` packages 
                       or threads should overwrite existing SAS data sets.     
                       Default value of `0` means "do not overwrite".          
                                                                               
-------------------------------------------------------------------------------
                                                                               
 Visit: `https://github.com/yabwon/SAS_PACKAGES/tree/main/SPF/Documentation` 
 to learn more.                                                                
                                                                               
## Example 1 ##################################################################
                                                                               
   Enabling the SAS Package Framework                                          
   from the local directory and installing & loading                           
   the SQLinDS package from the Internet.                                      
                                                                               
   Assume that the `SPFinit.sas` file                                          
   is located in the "C:/SAS_PACKAGES/" folder.                                
                                                                               
   Run the following code in your SAS session:                                 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
filename packages "C:/SAS_PACKAGES"; %* setup a directory for packages;
%include packages(SPFinit.sas);      %* enable the framework;

%installPackage(SQLinDS)  %* install the package from the Internet;
%helpPackage(SQLinDS)     %* get help about the package;
%loadPackage(SQLinDS)     %* load the package content into the SAS session;
%unloadPackage(SQLinDS)   %* unload the package content from the SAS session;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

## Example 2 ##################################################################
                                                                               
   Enabling the SAS Package Framework                                          
   from the local directory and installing & cherry picking                    
   elements of the BasePlus package.                                           
                                                                               
   Assume that the `SPFinit.sas` file                                          
   is located in the "C:/SAS_PACKAGES/" folder.                                
                                                                               
   Run the following code in your SAS session:                                 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
filename packages "C:/SAS_PACKAGES"; %* setup a directory for packages;
%include packages(SPFinit.sas);      %* enable the framework;

%installPackage(BasePlus) %* install the package from the Internet;
%loadPackage(BasePlus, cherryPick=getVars) %* cherry pick the content;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

## Utility macros generated during loading a package ###########################

If a package contains IML modules or CASL user defined functions additional 
utility macros for IML Modules and CASL UDFs are generated when package is loaded. 

Macros are generated with the following names: `%<packageName>IML()` and `%<packageName>CASLudf()`. 

Their purpose is to make loading of Modules or UDFs (with potentially multiple 
dependencies) easy in Proc IML and Proc CAS. 

Run them, accordingly, as the first line in the Proc IML or Proc CAS to access the package content. 
For Proc IML the use is as follows:
~~~~~~sas
  proc IML;             
    %<packageName>IML()
   
    <... your code using IML modules from the package ...>
  quit;
~~~~~~
For Proc CAS the use is as follows:
~~~~~~sas
  proc CAS;             
    %<packageName>CASLudf()
   
    <... your code using CASL UDFs from the package ...>
  quit;
~~~~~~

If a utility macro is generated appropriate note and a code snippet 
is printed in the log of the package loading process.

In 99% cases macros are used with default parameters values but, 
in case when deeper insight about macros parameters is needed, 
help info is printed in the log when the following code is run:
~~~~~~sas
  %<packageName>IML(list=HELP)
~~~~~~
or
~~~~~~sas
  %<packageName>CASLudf(list=HELP)
~~~~~~

If created, those macros are automatically deleted when the `%unloadPackage()` macro is run.

---

##      This is short help information for the `loadPackageS` macro <a name="loadpackages"></a>          
-------------------------------------------------------------------------------
                                                                               
 Macro wrapper for the loadPackage macro, version `20241129`                   
                                                                               
 A SAS package is a zip file containing a group                                
 of SAS codes (macros, functions, data steps generating                        
 data, etc.) wrapped up together and embedded inside the zip.                  
                                                                               
 The `%loadPackageS()` allows to load multiple packages at one time,           
 *ONLY* from the *ZIP* with *DEFAULT OPTIONS*, into the SAS session.           
                                                                               
### Parameters:                                                                
                                                                               
 1. `packagesNames`  A comma separated list of packages names,                 
                     e.g. myPackage, myPackage1, myPackage2, myPackage3        
                     Required and not null, default use case:                  
                      `%loadPackageS(myPackage1, myPackage2, myPackage3)`.     
                     Package version, in brackets behind a package name, can   
                     be provided, example is the following:                    
                      `%loadPackageS(myPackage1(1.7), myPackage2(4.2))`.       
                     If empty displays this help information.                  
                                                                               
                                                                               
-------------------------------------------------------------------------------
                                                                               
 Visit: `https://github.com/yabwon/SAS_PACKAGES/tree/main/SPF/Documentation` 
 to learn more.                                                                
                                                                               
### Example ###################################################################
                                                                               
   Enabling the SAS Package Framework                                          
   from the local directory and installing & loading                           
   the SQLinDS package from the Internet.                                      
                                                                               
   Assume that the `SPFinit.sas` file                                          
   is located in the "C:/SAS_PACKAGES/" folder.                                
                                                                               
   Run the following code in your SAS session:                                 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
filename packages "C:/SAS_PACKAGES"; %* setup a directory for packages;
%include packages(SPFinit.sas);      %* enable the framework;

%installPackage(SQLinDS DFA)   %* install packages from the Internet;
%loadPackageS(SQLinDS, DFA)    %* load packags content into the SAS session;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



##      This is short help information for the `unloadPackage` macro <a name="unloadpackage"></a>          
-------------------------------------------------------------------------------
                                                                               
 Macro to unload SAS packages, version `20241129`                              
                                                                               
 A SAS package is a zip file containing a group                                
 of SAS codes (macros, functions, data steps generating                        
 data, etc.) wrapped up together and provided with                             
 a single `unload.sas` file (also embedded inside the zip).                    
                                                                               
 The `%unloadPackage()` macro clears the package content                       
 from the SAS session.                                                         
                                                                               
-------------------------------------------------------------------------------
                                                                               
### Parameters:                                                                
                                                                               
 1. `packageName`      *Required.* Name of a package, e.g. myPackage,          
                       Required and not null, default use case:                
                        `%unloadPackage(myPackage).`                           
                       If empty displays this help information.                
                                                                               
 - `path=`             *Optional.* Location of a package. By default it        
                       looks for location of the **packages** fileref, i.e.    
                        `%sysfunc(pathname(packages))`                         
                                                                               
 - `options=`          *Optional.* Possible options for ZIP filename,          
                       default value: `LOWCASE_MEMNAME`                        
                                                                               
 - `source2=`          *Optional.* Option to print out details about           
                       what is loaded, null by default.                        
                                                                               
 - `zip=`              Standard package is zip (lowcase),                      
                        e.g. `%unloadPackage(PiPackage)`.                      
                       If the zip is not available use a folder.               
                       Unpack data to "pipackage.disk" folder                  
                       and use unloadPackage in the following form:              
                        `%unloadPackage(PiPackage, zip=disk, options=)`        
                                                                               
-------------------------------------------------------------------------------
                                                                               
 Visit: `https://github.com/yabwon/SAS_PACKAGES/tree/main/SPF/Documentation` 
 to learn more.                                                                
                                                                               
### Example ###################################################################
                                                                               
   Enabling the SAS Package Framework                                          
   from the local directory and installing & loading                           
   the SQLinDS package from the Internet.                                      
                                                                               
   Assume that the `SPFinit.sas` file                                          
   is located in the "C:/SAS_PACKAGES/" folder.                                
                                                                               
   Run the following code in your SAS session:                                 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
filename packages "C:/SAS_PACKAGES"; %* setup a directory for packages;
%include packages(SPFinit.sas);      %* enable the framework;

%installPackage(SQLinDS)  %* install the package from the Internet;
%helpPackage(SQLinDS)     %* get help about the package;
%loadPackage(SQLinDS)     %* load the package content into the SAS session;
%unloadPackage(SQLinDS)   %* unload the package content from the SAS session;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


##       This is short help information for the `listPackages` macro <a name="listpackages"></a>                    
-----------------------------------------------------------------------------------------
                                                                                         
 Macro to list available SAS packages, version `20241129`                                
                                                                                         
 A SAS package is a zip file containing a group                                          
 of SAS codes (macros, functions, data steps generating                                  
 data, etc.) wrapped up together and embedded inside the zip.                            
                                                                                         
 The `%listPackages()` macro lists packages available                                    
 in the packages folder. List is printed inthe SAS Log.                                  
                                                                                         
### Parameters:                                                                          
                                                                                         
 NO PARAMETERS                                                                           
                                                                                         
 When used as: `%listPackages(HELP)` it displays this help information.                  
                                                                                         
-----------------------------------------------------------------------------------------
                                                                                         
 Visit: `https://github.com/yabwon/SAS_PACKAGES/tree/main/SPF/Documentation`           
 to learn more.                                                                          
                                                                                         
### Example #############################################################################
                                                                                         
   Enabling the SAS Package Framework                                                    
   from the local directory and listing                                                  
   available packages.                                                                   
                                                                                         
   Assume that the `SPFinit.sas` file                                                    
   is located in the "C:/SAS_PACKAGES/" folder.                                          
                                                                                         
   Run the following code in your SAS session:                                           
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
filename packages "C:/SAS_PACKAGES"; %* setup a directory for packages;
%include packages(SPFinit.sas);      %* enable the framework;

%listPackages()                      %* list available packages;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


##      This is short help information for the `verifyPackage` macro <a name="verifypackage"></a>         
-------------------------------------------------------------------------------
                                                                               
 Macro to verify SAS package with it hash digest, version `20241129`           
                                                                               
 A SAS package is a zip file containing a group                                
 of SAS codes (macros, functions, data steps generating                        
 data, etc.) wrapped up together and embedded inside the zip.                  
                                                                               
 The `%verifyPackage()` macro generate package SHA256 hash                     
 and compares it with the one provided by the user.                            
 Works with `zip` packages only.                                               
                                                                               
                                                                               
 *Minimum SAS version required for the process is 9.4M6.*                      
                                                                               
### Parameters:                                                                
                                                                               
 1. `packageName`      Name of a package, e.g. myPackage,                      
                       Required and not null, default use case:                
                        `%loadPackage(myPackage)`.                             
                       If empty displays this help information.                
                                                                               
 - `hash=`             A value of the package `SHA256` hash.                   
                       Provided by the user.                                   
                                                                               
 - `path=`             Location of a package. By default it looks for          
                       location of the "packages" fileref, i.e.                
                        `%sysfunc(pathname(packages))`                         
                                                                               
-------------------------------------------------------------------------------
                                                                               
 Visit: `https://github.com/yabwon/SAS_PACKAGES/tree/main/SPF/Documentation` 
 to learn more.                                                                
                                                                               
### Example ###################################################################
                                                                               
   Enabling the SAS Package Framework                                          
   from the local directory and installing & loading                           
   the SQLinDS package from the Internet.                                      
                                                                               
   Assume that the `SPFinit.sas` file                                          
   is located in the "C:/SAS_PACKAGES/" folder.                                
                                                                               
   Run the following code in your SAS session:                                 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
filename packages "C:/SAS_PACKAGES"; %* set-up a directory for packages;
%include packages(SPFinit.sas);      %* enable the framework;

%installPackage(SQLinDS)  %* install the package from the Internet;
%verifyPackage(SQLinDS,   %* verify the package with provided hash;
              hash=HDA478ANJ3HKHRY327FGE88HF89VH89HFFFV73GCV98RF390VB4)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

##    This is short help information for the `previewPackage` macro <a name="previewpackage"></a>
-------------------------------------------------------------------------------

 Macro to get preview of a SAS packages, version `20241129`

 A SAS package is a zip file containing a group
 of SAS codes (macros, functions, data steps generating
 data, etc.) wrapped up together and provided with
 a single `preview.sas` file (also embedded inside the zip).

 The `%previewPackage()` macro prints, in the SAS log, content
 of a SAS package. Code of a package is printed out.

-------------------------------------------------------------------------------

### Parameters:

 1. `packageName`      *Required.* Name of a package, e.g. myPackage,
                       Required and not null, default use case:
                        `%previewPackage(myPackage).`
                       If empty displays this help information.

 2. `helpKeyword`      *Optional.*  A phrase to search in preview,
                       - when empty prints description,
                       - "*" means: print all preview,
                       - "license" prints the license.

 - `path=`             *Optional.* Location of a package. By default it
                       looks for location of the **packages** fileref, i.e.
                        `%sysfunc(pathname(packages))`

 - `options=`          *Optional.* Possible options for ZIP filename,
                       default value: `LOWCASE_MEMNAME`

 - `source2=`          *Optional.* Option to print out details about
                       what is loaded, null by default.

 - `zip=`              Standard package is zip (lowcase),
                        e.g. `%previewPackage(PiPackage)`.
                       If the zip is not available use a folder.
                       Unpack data to "pipackage.disk" folder
                       and use previewPackage in the following form:
                        `%previewPackage(PiPackage, , zip=disk, options=)`

-------------------------------------------------------------------------------

 Visit: `https://github.com/yabwon/SAS_PACKAGES/tree/main/SPF/Documentation`
 to learn more.

### Example ###################################################################

   Enabling the SAS Package Framework
   from the local directory and installing & loading
   the SQLinDS package from the Internet.

   Assume that the `SPFinit.sas` file
   is located in the "C:/SAS_PACKAGES/" folder.

   Run the following code in your SAS session:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
filename packages "C:/SAS_PACKAGES"; %* setup a directory for packages;
%include packages(SPFinit.sas);      %* enable the framework;

%installPackage(SQLinDS)  %* install the package from the Internet;
%previewPackage(SQLinDS)  %* get content of the package;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

##      This is short help information for the `generatePackage` macro <a name="generatepackage"></a>        
-------------------------------------------------------------------------------
                                                                               
 Macro to generate SAS packages, version `20241129`                            
                                                                               
 A SAS package is a zip file containing a group                                
 of SAS codes (macros, functions, data steps generating                        
 data, etc.) wrapped up together and embedded inside the zip.                  
                                                                               
 The `%generatePackage()` macro generates SAS packages.                        
 It wraps-up the package content, i.e. macros, functions, formats, etc.,       
 into the zip file and generate all metadata content required by other         
 macros from the SAS Packages Framework.                                       
                                                                               
-------------------------------------------------------------------------------
                                                                               
 Visit: `https://github.com/yabwon/SAS_PACKAGES/tree/main/SPF/Documentation`   
 to read about the details of package generation process.                      
                                                                               
### Parameters:                                                                
                                                                               
 1. `filesLocation=` Location of package files, example value:                 
                      `%sysfunc(pathname(work))/packagename`.                  
                     Default use case:                                         
                      `%generatePackage(filesLocation=/path/to/packagename)`   
                     If empty displays this help information.                  
                                                                               
 Testing parameters:                                                           
                                                                               
 - `testPackage=`    Indicator if tests should be executed.                    
                     Default value: `Y`, means "execute tests"                 
                                                                               
 - `packages=`       Location of other packages for testing                    
                     if there are dependencies in loading the package.         
                     Has to be a single directory, if more than one are        
                     provided than only the first is used.                     
                     If path to location contains spaces it should be quoted!  
                                                                               
 - `testResults=`     Location where tests results should be stored,           
                      if null (the default) then the session WORK is used.     
                                                                               
 - `sasexe=`         Location of a DIRECTORY where the SAS binary is located,  
                     if null (the default) then the `!SASROOT` is used.        
                                                                               
 - `sascfgFile=`     Location of a FILE with testing session configuration     
                     parameters, if null (the default) then no config file     
                     is pointed during the SAS invocation,                     
                     if set to `DEF` then the `!SASROOT/sasv9.cfg` is used.    
                                                                               
 - `delTestWork=`    Indicates if `WORK` directories generated by user tests   
                     should be deleted, i.e. the (NO)WORKTERM option is set.   
                     The default value: `1` means "delete tests work".         
                     Available values are `0` and `1`.                         
                                                                               
 - `markdownDoc=`    Indicates if a markdown file with documentation           
                     be generated from help information blocks.                
                     The default value: `0` means "do not generate the file".  
                     Available values are `0` and `1`.                         
                                                                               
 - `easyArch=`       When creating documentation file (`markdownDoc=1`)        
                     indicates if a copy of the zip and markdown files         
                     with the version number in the file name be created       
                     The default value: `0` means "do not create files".       
                     Available values are `0` and `1`.                         
                                                                               
                                                                               
------------------------------------------------------------------------------- 

Locate all files with code in base folder, i.e. at `filesLocation` directory.
  
Remember to prepare the `description.sas` file for you package. 
The colon (:) is a field separator and is restricted 
in lines of the header part. 
The file should contain the following obligatory information: 

-------------------------------------------------------------------------------------------- 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
/*>> **HEADER** <<*/
Type: Package
Package: PackageName
Title: A title/brief info for log note about your package.
Version: X.Y.Z
Author: Firstname1 Lastname1 (xxxxxx1@yyyyy.com), Firstname2 Lastname2 (xxxxxx2@yyyyy.com)
Maintainer: Firstname Lastname (xxxxxx@yyyyy.com)
License: MIT
Encoding: UTF8

Required: "Base SAS Software"                    :%*optional, COMMA separated, QUOTED list, names of required SAS products, values must be like from proc setinit;run; output *;
ReqPackages: "macroArray (0.1)", "DFA (0.1)"     :%*optional, COMMA separated, QUOTED list, names of required packages *;

/*>> **DESCRIPTION** <<*/
/*>> All the text below will be used in help <<*/
DESCRIPTION START:
  Xxxxxxxxxxx xxxxxxx xxxxxx xxxxxxxx xxxxxxxx. Xxxxxxx
  xxxx xxxxxxxxxxxx xx xxxxxxxxxxx xxxxxx. Xxxxxxx xxx
  xxxx xxxxxx. Xxxxxxxxxxxxx xxxxxxxxxx xxxxxxx.
DESCRIPTION END:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--------------------------------------------------------------------------------------------

Name of the `type` of folder and `files.sas` inside must be in the _low_ case letters.

If order of loading is important, the sequential number
can be used to order multiple types in the way you wish.

If folder name starts with `!` (e.g., `!ignore_me`) or *type* of the folder is "unknown" (e.g., not supported one) 
the content of such folder is ignored during package generation process.

The "tree structure" of the folder could be for example as follows:

All files have to have `.sas` extension. Other files are ignored.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
 <packageName>
  ..
   |
   +-000_libname [one file one libname]
   |           |
   |           +-abc.sas [a file with a code creating libname ABC]
   |
   +-001_macro [one file one macro]
   |         |
   |         +-hij.sas [a file with a code creating macro HIJ]
   |         |
   |         +-klm.sas [a file with a code creating macro KLM]
   |
   +-002_function [one file one function,
   |            |  option OUTLIB= should be: work.&packageName.fcmp.package 
   |            |  option INLIB=  should be: work.&packageName.fcmp
   |            |  (both literally with macrovariable name and "fcmp" sufix)]
   |            |
   |            +-efg.sas [a file with a code creating function EFG, _with_ "Proc FCMP" header]
   |
   +-003_functions [mind the S at the end!, one file one function,
   |             |  only plain code of the function, without "Proc FCMP" header]
   |             |
   |             +-ijk.sas [a file with a code creating function EFG, _without_ "Proc FCMP" header]
   |
   +-004_format [one file one format,
   |          |  option LIB= should be: work.&packageName.format 
   |          |  (literally with macrovariable name and "format" suffix)]
   |          |
   |          +-efg.sas [a file with a code creating format EFG and informat EFG]
   |
   +-005_data [one file one dataset]
   |        |
   |        +-abc.efg.sas [a file with a code creating dataset EFG in library ABC] 
   |
   +-006_exec [so called "free code", content of the files will be printed 
   |        |  to the log before execution]
   |        |
   |        +-<no file, in this case folder may be skipped>
   |
   +-007_format [if your codes depend each other you can order them in folders, 
   |          |  e.g. code from 003_... will be executed before 006_...]
   |          |
   |          +-abc.sas [a file with a code creating format ABC, 
   |                     used in the definition of the format EFG]
   +-008_function
   |            |
   |            +-<no file, in this case folder may be skipped>
   |
   |
   +-009_lazydata [one file one dataset]
   |            |
   |            +-klm.sas [a file with a code creating dataset klm in library work
   |                       it will be created only if user request it by using:
   |                       %loadPackage(packagename, lazyData=klm)
   |                       multiple elements separated by space are allowed
   |                       an asterisk(*) means "load all data"] 
   |
   +-010_imlmodule [one file one IML module,
   |             |  only plain code of the module, without "Proc IML" header]
   |             |
   |             +-abc.sas [a file with a code creating IML module ABC, _without_ "Proc IML" header]
   |
   +-011_casludf [one file one CAS-L user defined function,
   |             |  only plain code of the function, without "Proc CAS" header]
   |             |
   |             +-abc.sas [a file with a code creating CAS-L user defined function ABC, _without_ "Proc CAS" header]
   |
   +-012_kmfsnip [one file one KMF-abbreviation snippet,
   |             |  code snipped proper tagging]
   |             |
   |             +-abc.sas [a file with a KMF-abbreviation snippet ABC, _with_ proper tagging, snippets names are in low-case]
   |
   +-<sequential number>_<type [in lower case]>
   |
   +-0nn_clean [if you need to clean something up after exec file execution,
   |         |  content of the files will be printed to the log before execution]
   |         |
   |         +-<no file, in this case folder may be skipped>
   |
   +-...
   |
   +-998_addcnt [additional content for the package, can be only one!, content of this 
   |          |  directory is copied "as is"]
   |          |
   |          +-arbitrary_file1 [an arbitrary file ]
   |          |
   |          +-subdirectory_with_files [an arbitrary directory with some files inside]
   |          |
   |          +-...
   |
   +-999_test [tests executed during package generation, XCMD options must be turned-on]
   |        |
   |        +-test1.sas [a file with a code for test1]
   |        |
   |        +-test2.sas [a file with a code for test2]
   |
   +-...
   ...
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--------------------------------------------------------------------------------------------

##      This is short help information for the `extendPackagesFileref` macro <a name="extendpackagesfileref"></a>        
-----------------------------------------------------------------------------------------

 Macro to list directories pointed by 'packages' fileref, version `20241129`             
                                                                                         
 A SAS package is a zip file containing a group                                          
 of SAS codes (macros, functions, data steps generating                                  
 data, etc.) wrapped up together and embedded inside the zip.                            
                                                                                         
 The `%extendPackagesFileref()` macro lists directories pointed by              
 the packages fileref. It allows to add new dierctories to packages folder list.         
                                                                                        
### Parameters:                                                                          
                                                                                        
 1. `packages`      *Optional.* A valid fileref name, when empty the "packages" is used
 When used as: `%extendPackagesFileref(HELP)` it displays this help information.

------------------------------------------------------------------------------------------

 Visit: `https://github.com/yabwon/SAS_PACKAGES/tree/main/SPF/Documentation`
 to learn more.

### Example ###################################################################

   Enabling the SAS Package Framework                             
   from the local directory and adding                            
   new directory.                                                 
                                                                  
   Assume that the `SPFinit.sas` file                             
   is located in one of "C:/SAS_PK1" or "C:/SAS_PK2" folders.     
                                                                  
   Run the following code in your SAS session:                    
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
filename packages ("C:/SAS_PK1" "C:/SAS_PK2"); %* setup a directory for packages;
%include packages(SPFinit.sas);               %* enable the framework;          

filename packages ("D:/NEW_DIR" %extendPackagesFileref()); %* add new directory;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----------------------------------------------------------------------------------------

##      This is short help information for the `loadPackageAddCnt` macro <a name="loadpackageaddcnt"></a>       
-------------------------------------------------------------------------------
                                                                               
 Macro to load *additional content* for a SAS package, version `20241129`      
                                                                               
 A SAS package is a zip file containing a group                                
 of SAS codes (macros, functions, data steps generating                        
 data, etc.) wrapped up together and included by                               
 a single `load.sas` file (also embedded inside the zip).                      
                                                                               
 The `%loadPackageAddCnt()` macro loads additional content            
 for a package (of course only if one is provided).                            
                                                                               
-------------------------------------------------------------------------------
### Parameters:                                                                
                                                                               
 1. `packageName`      *Required.* Name of a package, e.g. myPackage,          
                       Required and not null, default use case:                
                        `%loadPackageAddCnt(myPackage)`.              
                       If empty displays this help information.                
                                                                               
 - `path=`             *Optional.* Location of a package. By default it        
                       looks for location of the **packages** fileref, i.e.    
                        `%sysfunc(pathname(packages))`                
                                                                               
 - `target=`           *Optional.* Location where the directory with           
                       additional content will be generated,                   
                       name of the directory created is set to                 
                       `<packagename>_AdditionalContent`, the default          
                       location is `%sysfunc(pathname(WORK))`         
                                                                               
 - `source2=`          *Optional.* Option to print out details about           
                       what is loaded, null by default.                        
                                                                               
 - `requiredVersion=`  *Optional.* Option to test if the loaded                
                       package is provided in required version,                
                       default value: `.`                                      
                                                                               
                                                                               
-------------------------------------------------------------------------------
                                                                               
 Visit: `https://github.com/yabwon/SAS_PACKAGES/tree/main/SPF/Documentation`   
 to learn more.                                                                

-------------------------------------------------------------------------------

 By *default* additional content is not deployed automatically e.g., 
 from security point of view, or production job doesn't need it to run, etc. 
 But if there is a need for it there are three ways to get it:

 - The first one ("by-the-book"), and also the recommended one. The additional 
   content is extracted during the automatic installation process using the 
   `\%installPackage()` macro. For this to work the `loadAddCnt=` parameter 
   has to be set to `1`. The additional content is extracted to the 
   `<packageName>_AdditionalContent` directory into the same location where 
   the package is installed i.e., inside `packages` fileref location.
 - The second one ("by-the-work"), when the additional content is extracted 
   during the loading process with the `\%loadPackage()` macro. For this to 
   work also the `loadAddCnt=` parameter has to be set to `1`. The additional 
   content is extracted to the `<packageName>_AdditionalContent` directory 
   inside the `Work` library location.
 - The third one ("by-the-user"), when the additional content is extracted 
   with dedicated `%loadPackageAddCnt()` macro. By default the additional 
   content is extracted to the `<packageName>_AdditionalContent` directory 
   inside the `Work` library location too, but it can be altered by changing 
   the `target=` parameter, which indicates the location.

 If done "by-the-book", or "by-the-user" with `target=` parameter, the 
 additional content is not automatically deleted when SAS session ends, 
 in this case the "additionals" have to be deleted manually by the User.

                                                                               
### Example 1 ##################################################################
                                                                               
   Enabling the SAS Package Framework                                          
   from the local directory and installing & loading additional content        
   for the SQLinDS package.                                                    
                                                                               
   Assume that the `SPFinit.sas` file                                          
   is located in the "C:/SAS_PACKAGES/" folder.                                
                                                                               
   Run the following code in your SAS session:                                 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
filename packages "C:/SAS_PACKAGES"; %* setup a directory for packages;
%include packages(SPFinit.sas);      %* enable the framework;        

%installPackage(SQLinDS)  %* install the package from the Internet;  
%loadPackageAddCnt(SQLinDS) %* load additional content for the package;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-----------------------------------------------------------------------------------------                                                                               
                                                                               
##     This is short help information for the `splitCodeForPackage` macro <a name="splitcodeforpackage"></a>     
-------------------------------------------------------------------------------
                                                                               
 Utility macro to *split* single file with SAS package code into multiple      
 files with separate snippets, version `20241129`                              
                                                                               
 A SAS package is a zip file containing a group                                
 of SAS codes (macros, functions, data steps generating                        
 data, etc.) wrapped up together and included by                               
 a single `load.sas` file (also embedded inside the zip).                      
                                                                               
 The `%splitCodeForPackage()` macro takes a file with SAS code                 
 snippets surrounded by `/*##$##-code-block-start-##$## <tag spec> */` and     
 `/*##$##-code-block-end-##$## <tag spec> */` tags and split that file into    
 multiple files and directories according to a tag specification.              
                                                                               
 The `<tag spec>` is a list of pairs of the form: `type(object)` that          
 indicates how the file should be split. See example 1 below for details.      
                                                                               
-------------------------------------------------------------------------------
### Parameters:                                                                
                                                                               
 1. `codeFile=`        *Required.* Name of a file containing code              
                        that will be split. Required and not null.             
                        If empty displays this help information.               
                                                                               
 - `packagePath=`      *Required.* Location for package files after            
                        splitting into separate files and directories.         
                        If missing or not exist then `WORK` is uded.           
                                                                               
 - `debug=`            *Optional.* Turns on code printing for debugging.       
                                                                               
 - `nobs=`             *Optional.* Technical parameter with value `0`.         
                        Do not change.                                         
                                                                               
-------------------------------------------------------------------------------
                                                                               
 Visit: `https://github.com/yabwon/SAS_PACKAGES/tree/main/SPF/Documentation`   
 to learn more.                                                                
                                                                               
### Example 1 ##################################################################
                                                                               
   Assume that the `myPackageCode.sas` file                                    
   is located in the `C:/lazy/` folder and                                     
   contain the following code and tags:                                        
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas

/*##$##-code-block-start-##$## 01_macro(abc) */
%macro abc();
  %put I am "abc".;
%mend abc;
/*##$##-code-block-end-##$## 01_macro(abc) */

/*##$##-code-block-start-##$## 01_macro(efg) */
%macro efg();
  %put I am "efg".;
%mend efg;
/*##$##-code-block-end-##$## 01_macro(efg) */

proc FCMP outlib=work.f.p;
/*##$##-code-block-start-##$## 02_functions(xyz) */
function xyz(n);
  return(n**2 + n + 1)
endfunc;
/*##$##-code-block-end-##$## 02_functions(xyz) */
quit;

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                                                                               
 and we want results in `C:/split/` folder, we run the following:              
                                                                               
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
filename packages "C:/SAS_PACKAGES"; %* setup a directory for packages;
%include packages(SPFinit.sas);      %* enable the framework;

%splitCodeForPackage(
   codeFile=C:/lazy/myPackageCode.sas
  ,packagePath=C:/split/ )
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                                                                               
                                                                               
                                                                               
-------------------------------------------------------------------------------
## Some more examples <a name="some-more-examples"></a> #############################################################

### Example 1. ###################################################################
Enabling the SAS Package Framework 
and loading the SQLinDS package from the local directory.

Assume that the `SPFinit.sas` file and the SQLinDS 
package (sqlinds.zip file) are located in 
the "C:/SAS_PACKAGES/" folder.

Run the following code in your SAS session:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  filename packages "C:/SAS_PACKAGES"; %* setup a directory for packages; 
  %include packages(SPFinit.sas);      %* enable the framework;

  %helpPackage(SQLinDS)                %* get help about the package;
  %loadPackage(SQLinDS)                %* load the package content into the SAS session;
  %unloadPackage(SQLinDS)              %* unload the package content from the SAS session;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

### Example 2. ###################################################################
Enabling the SAS Package Framework 
from the local directory and installing & loading
the SQLinDS package from the Internet.

Assume that the `SPFinit.sas` file
is located in the "C:/SAS_PACKAGES/" folder.

Run the following code in your SAS session:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  filename packages "C:/SAS_PACKAGES"; %* setup a directory for packages; 
  %include packages(SPFinit.sas);      %* enable the framework;

  %installPackage(SQLinDS)             %* install the package from the Internet;
  %helpPackage(SQLinDS)                %* get help about the package;
  %loadPackage(SQLinDS)                %* load the package content into the SAS session;
  %unloadPackage(SQLinDS)              %* unload the package content from the SAS session;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

### Example 3. ###################################################################
Enabling the SAS Package Framework 
and installing & loading the SQLinDS package 
from the Internet.

Run the following code in your SAS session:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  filename packages "%sysfunc(pathname(work))"; %* setup WORK as a temporary directory for packages;
   
  filename spfinit url "https://raw.githubusercontent.com/yabwon/SAS_PACKAGES/main/SPFinit.sas";
  %include spfinit;                    %* enable the framework;

  %installPackage(SQLinDS)             %* install the package from the Internet;
  %helpPackage(SQLinDS)                %* get help about the package;
  %loadPackage(SQLinDS)                %* load the package content into the SAS session;
  %unloadPackage(SQLinDS)              %* unload the package content from the SAS session;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

### Example 4. ################################################################### 
Assume that the `SPFinit.sas` file and the SQLinDS package (`sqlinds.zip` file)
are located in the "C:/SAS_PACKAGES/" folder.

In case when user SAS session does not support ZIP fileref
the following solution could be used.

Unzip the `packagename.zip` content into the `packagename.disk` folder
and run macros with the following options:                     ;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %loadPackage(packageName,zip=disk,options=)
  %helpPackage(packageName,,zip=disk,options=) %* mind the double comma!! ;
  %unloadPackage(packageName,zip=disk,options=) 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

### Example 5. ################################################################### 
Enabling the SAS Package Framework from the local directory
and installing the SQLinDS package from the Internet.

Assume that the `SPFinit.sas` file is located in 
the "C:/SAS_PACKAGES/" folder.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  filename packages "C:/SAS_PACKAGES"; %* setup a directory for packages; 
  %include packages(SPFinit.sas);      %* enable the framework;

  %installPackage(SQLinDS);            %* install package;
  %installPackage(SQLinDS);            %* overwrite already installed package;
  %installPackage(SQLinDS,replace=0);  %* prevent overwrite installed package;

  %installPackage(NotExistingPackage); %* handling with not existing package;

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-------------------------------------------------------------------------------

