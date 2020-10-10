
##       This is short help information for the `installPackage` macro                      
--------------------------------------------------------------------------------------------
                                                                                            
 Macro to install SAS packages, version `20201010`                                          
                                                                                            
 A SAS package is a zip file containing a group                                             
 of SAS codes (macros, functions, data steps generating                                     
 data, etc.) wrapped up together and embedded inside the zip.                               
                                                                                            
 The `%installPackage()` macro installs the package zip                                     
 in the packages folder. The process of installation is equivalent with                     
 manual downloading the package zip file into the packages folder.                          
                                                                                            
--------------------------------------------------------------------------------------------
                                                                                            
### Parameters:                                                                             
                                                                                            
 1. `packagesNames` Space separated list of packages names _without_                        
                    the zip extension, e.g. myPackage1 myPackage2,                          
                    Required and not null, default use case:                                
                    `%installPackage(myPackage1 myPackage2)`.                               
                    If empty displays this help information.                                
                    If the package name is *SPFinit* or *SASPackagesFramework*              
                    then the framework itself is downloaded.                                
                                                                                            
 - `sourcePath=`   Location of the package, e.g. "www.some.web.page/"                       
                   Mind the "/" at the end of the path!                                     
                   Current default location for packages is:                                
                   `https://raw.githubusercontent.com/yabwon/SAS_PACKAGES/master/packages/` 
                   Current default location for the framework is:                           
                   `https://raw.githubusercontent.com/yabwon/SAS_PACKAGES/master/SPF/`      
                                                                                            
 - `replace=`      With default value of `1` it causes existing package file                
                   to be replaceed by new downloaded file.                                  
                                                                                            
--------------------------------------------------------------------------------------------
                                                                                            
 Visit: `https://github.com/yabwon/SAS_PACKAGES/tree/master/SPF/Documentation` to learn more.
                                                                                            
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
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


##       This is short help information for the `helpPackage` macro            
-------------------------------------------------------------------------------
                                                                               
 Macro to get help about SAS packages, version `20201010`                      
                                                                               
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
                        `%loadPackage(myPackage).`                             
                       If empty displays this help information.                
                                                                               
 2. `helpKeyword`      *Optional.*  A phrase to search in help,                
                       - when empty prints description,                        
                       - "*"  means prints all help,                           
                       - "license"  prints the license.                        
                                                                               
 - `path=`             *Optional.* Location of a package. By default it        
                       looks for location of the **packages** fileref, i.e.    
                        `%sysfunc(pathname(packages))`                         
                                                                               
 - `options=`          *Optional.* Possible options for ZIP filename,          
                       default value: `LOWCASE_MEMNAME`                        
                                                                               
 - `source2=`          *Optional.* Option to print out details about           
                       what is loaded, null by default.                        
                                                                               
 - `zip=`              Standard package is zip (lowcase),                      
                        e.g. `%loadPackage(PiPackage)`.                        
                       If the zip is not available use a folder.               
                       Unpack data to "pipackage.disk" folder                  
                       and use loadPackage in the following form:              
                        `%loadPackage(PiPackage, zip=disk, options=)`          
                                                                               
-------------------------------------------------------------------------------
                                                                               
 Visit: `https://github.com/yabwon/SAS_PACKAGES/tree/master/SPF/Documentation` 
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


##      This is short help information for the `loadPackage` macro             
-------------------------------------------------------------------------------
                                                                               
 Macro to *load* SAS packages, version `20201010`                              
                                                                               
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
                                                                               
 - `lazyData=`         *Optional.* A list of names of lazy datasets to be      
                       loaded. If not null datasets from the list are loaded   
                       instead of the package.                                 
                       An asterisk (*) means *load all lazy datasets*.         
                                                                               
 - `zip=`              Standard package is zip (lowcase),                      
                        e.g. `%loadPackage(PiPackage)`.                        
                       If the zip is not available use a folder.               
                       Unpack data to "pipackage.disk" folder                  
                       and use loadPackage in the following form:              
                        `%loadPackage(PiPackage, zip=disk, options=)`          
                                                                               
-------------------------------------------------------------------------------
                                                                               
 Visit: `https://github.com/yabwon/SAS_PACKAGES/tree/master/SPF/Documentation` 
 to learn more.                                                                
                                                                               
## Example ####################################################################
                                                                               
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
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


##      This is short help information for the `loadPackageS` macro            
-------------------------------------------------------------------------------
                                                                               
 Macro wrapper for the loadPackage macro, version `20201010`                   
                                                                               
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
                                                                               
 Visit: `https://github.com/yabwon/SAS_PACKAGES/tree/master/SPF/Documentation` 
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

%installPackage(SQLinDS DFA)  %* install packages from the Internet;
%loadPackageS(SQLinDS, DFA)    %* load packags content into the SAS session;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



##      This is short help information for the `unloadPackage` macro           
-------------------------------------------------------------------------------
                                                                               
 Macro to unload SAS packages, version `20201010`                              
                                                                               
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
                        `%loadPackage(myPackage).`                             
                       If empty displays this help information.                
                                                                               
 - `path=`             *Optional.* Location of a package. By default it        
                       looks for location of the **packages** fileref, i.e.    
                        `%sysfunc(pathname(packages))`                         
                                                                               
 - `options=`          *Optional.* Possible options for ZIP filename,          
                       default value: `LOWCASE_MEMNAME`                        
                                                                               
 - `source2=`          *Optional.* Option to print out details about           
                       what is loaded, null by default.                        
                                                                               
 - `zip=`              Standard package is zip (lowcase),                      
                        e.g. `%loadPackage(PiPackage)`.                        
                       If the zip is not available use a folder.               
                       Unpack data to "pipackage.disk" folder                  
                       and use loadPackage in the following form:              
                        `%loadPackage(PiPackage, zip=disk, options=)`          
                                                                               
-------------------------------------------------------------------------------
                                                                               
 Visit: `https://github.com/yabwon/SAS_PACKAGES/tree/master/SPF/Documentation` 
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
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


##       This is short help information for the `listPackages` macro                     
-----------------------------------------------------------------------------------------
                                                                                         
 Macro to list available SAS packages, version `20201010`                                
                                                                                         
 A SAS package is a zip file containing a group                                          
 of SAS codes (macros, functions, data steps generating                                  
 data, etc.) wrapped up together and embedded inside the zip.                            
                                                                                         
 The `%listPackages()` macro lists packages available                                    
 in the packages folder. List is printed inthe SAS Log.                                  
                                                                                         
### Parameters:                                                                          
                                                                                         
 NO PARAMETERS                                                                           
                                                                                         
 When used as: `%listPackages(HELP)` it displays this help information.                  
                                                                                         
-----------------------------------------------------------------------------------------
                                                                                         
 Visit: `https://github.com/yabwon/SAS_PACKAGES/tree/master/SPF/Documentation`           
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
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


###      This is short help information for the `verifyPackage` macro          
-------------------------------------------------------------------------------
                                                                               
 Macro to verify SAS package with it hash digest, version `20201010`           
                                                                               
 A SAS package is a zip file containing a group                                
 of SAS codes (macros, functions, data steps generating                        
 data, etc.) wrapped up together and embedded inside the zip.                  
                                                                               
 The `%verifyPackage()` macro generate package SHA256 hash                     
 and compares it with the one provided by the user.                            
                                                                               
                                                                               
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
                                                                               
 Visit: `https://github.com/yabwon/SAS_PACKAGES/tree/master/SPF/Documentation` 
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
%verifPackage(SQLinDS,    %* verify the package with provided hash;
              hash=HDA478ANJ3HKHRY327FGE88HF89VH89HFFFV73GCV98RF390VB4)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

##      This is short help information for the `generatePackage` macro         
-------------------------------------------------------------------------------
                                                                               
 Macro to generate SAS packages, version `20201010`                            
                                                                               
 A SAS package is a zip file containing a group                                
 of SAS codes (macros, functions, data steps generating                        
 data, etc.) wrapped up together and embedded inside the zip.                  
                                                                               
 The `%generatePackage()` macro generates SAS packages.                        
 It wraps-up the package content, i.e. macros, functions, formats, etc.,       
 into the zip file and generate all metadata content required by other         
 macros from the SAS Packages Framework.                                       
                                                                               
-------------------------------------------------------------------------------
                                                                               
 Visit: `https://github.com/yabwon/SAS_PACKAGES/tree/master/SPF/Documentation` 
 to read about the details of package generation process.                      
                                                                               
### Parameters:                                                                
                                                                               
 1. `filesLocation=` Location of package files, example value:                 
                      `%sysfunc(pathname(work))/packagename`.                  
                     Default use case:                                         
                      `%generatePackage(filesLocation=/path/to/packagename)`   
                     If empty displays this help information.                  
                                                                               
 - `testPackage=`    Indicator if tests should be executed.                    
                     Default value: `Y`, means "execute tests"                 
                                                                               
 - `packages=`       Location of other packages for testing                    
                     if there are dependencies in loading the package.         
                                                                               
-------------------------------------------------------------------------------
