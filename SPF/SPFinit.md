##      This is short SAS PAckages Framework help information 

A **SAS package** is an automatically generated, single, stand alone *zip* file containing organised and ordered code structures, created by the developer and extended with additional automatically generated "driving" files (i.e. description, metadata, load, unload, and help files). 

The *purpose of a package* is to be a simple, and easy to access, code sharing medium, which will allow: on the one hand, to separate the code complex dependencies created by the developer from the user experience with the final product and, on the other hand, reduce developer's and user's unnecessary frustration related to a remote deployment process.

In this repository we are presenting the **SAS Packages Framework** which allows to develop and use SAS packages. The latest version of SPF is **`20201014`**.  

To get started with SAS Packages try this [**`Getting Started with SAS Packages`**](https://github.com/yabwon/SAS_PACKAGES/blob/master/SPF/Documentation/Getting_Started_with_SAS_Packages.pdf "Getting Started with SAS Packages") presentation (see the `./SPF/Documentation` directory).

The documentation and more advance reading would be the [**`SAS(r) packages - the way to share (a how to)- Paper 4725-2020 - extended.pdf`**](https://github.com/yabwon/SAS_PACKAGES/blob/master/SPF/Documentation/SAS(r)%20packages%20-%20the%20way%20to%20share%20(a%20how%20to)-%20Paper%204725-2020%20-%20extended.pdf "SAS packages - the way to share") article (see the `./SPF/Documentation` directory).


*Note:* Filenames references `packages` and `package` are reserved keywords.
The first one should be used to point local folder with packages.
The second is used internally by macros.
Do not use them otherwise than, e.g.

`filename packages "C:/SAS_PACKAGES";`

since it may affect stability of the framework.

--------------------------------------------------------------------------------------------


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
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


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
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


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
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


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
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


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
Version: X.Y
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

The "tree structure" of the folder could be for example as follows:

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
   |          |  (literally with macrovariable name and "format" sufix)]
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
   +-<sequential number>_<type [in lower case]>
   |
   +-...
   |
   +-00n_clean [if you need to clean something up after exec file execution,
   |         |  content of the files will be printed to the log before execution]
   |         |
   |         +-<no file, in this case folder may be skipped>
   +-...
   ...
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--------------------------------------------------------------------------------------------



-------------------------------------------------------------------------------
## Some more examples #############################################################

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
   
  filename spfinit url "https://raw.githubusercontent.com/yabwon/SAS_PACKAGES/master/SPFinit.sas";
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

