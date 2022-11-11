
## The "Hello World" Package

---

This is a "Hello World" example on how to build your first package with help of the SAS Packages Framework.

We will generate a `HelloWorld` package.

Follow the step by step instruction below.

---

`Step 1.` Create a folder for the framework e.g.,
          `/home/<myUserName>/SASpackages` or `C:/SASpackages`

`Step 2.` Run the following code to install The SAS Packages Framework
          in the folder you created in the `Step 1.`

```sas
filename packages "<put/folder/from/the/step/one/here>";
filename SPFinit url "https://raw.githubusercontent.com/yabwon/SAS_PACKAGES/main/SPF/SPFinit.sas";
%include SPFinit;
%installPackage(SPFinit)
```
 
Check out the *log* to verify if the `Step 2.` was successful.
If it was - then continue.


`Step 3.` Create a folder for the content of the package we will generate e.g.,
          `/home/<myUserName>/HelloWorldPackage` or `C:/HelloWorldPackage`

`Step 4.` Inside the directory from the `Step 3.` create two sub-folders: `01_formats`
          and `02_macros`. Remember to use *lower case letters* only!     

`Step 5.` Inside the `01_formats` folder create a `helloworldformat.sas` file.
          Remember to use lower case letters in the file name. Copy-paste below code
          into that file:

```sas
/*** HELP START ***//*
 This is a help info for the HelloWorldFormat. format
*//*** HELP END ***/

value HelloWorldFormat
  1 = " Hello"
  2 = " SAS"
  3 = " Packages"
  4 = " World"
  other = "!"
;
```

`Step 6.` Inside the `02_macros` folder create a `helloworldmacro.sas` file.
          Remember to use lower case letters in the file name. Copy-paste below code
          into that file:
```sas
/*** HELP START ***//*
 This is a help info for the helloWorldMacro() macro
*//*** HELP END ***/

%macro HelloWorldMacro(n);
  data _null_;
    do i = 1 to &n.;
      put i HelloWorldFormat. @; 
    end;
  run;
%mend HelloWorldMacro;
```


`Step 7.` Inside the directory from the `Step 3.` create a `description.sas` file. 
          Remember to use lower case letters in the file name. Copy-paste below text
          into that file, adjust lines 5 and 6:    
```txt
Type: Package
Package: helloWorld
Title: My Hello World SAS package.
Version: 1.0
Author: <myFirstname> <myLastname> (my@mail.com)
Maintainer: <myFirstname> <myLastname> (my@mail.com)
License: MIT
Encoding: UTF8

Required: "Base SAS Software"

DESCRIPTION START:
## My "Hello World" SAS package ##

The "Hello World" is my first SAS package and 
for sure it will not be the last package one!
DESCRIPTION END:
```

`Step 8.` Execute the following code and check the log 
          to read the `%generatePackage()` macro help info.

```sas
%generatePackage()
```

`Step 9.` Execute the following code using the folder 
          from the `Step 3.` and check the log to see how 
          the process of package generation went.

```sas
%generatePackage(
  filesLocation=<put/folder/from/the/step/three/here>
)
```

`Step 10.` See the information in the output window and in the log.
           The `WARNING:[License] No license.sas file provided, default (MIT) licence file will be generated.` can be ignored.

`Step 11.` Check the directory from the `Step 3.` and look for the `helloworld.zip` package file.

---

`Step 12.` Start a new SAS session, run the following code, and investigate the log:

```sas
filename packages ("<put/folder/from/the/step/one/here>" "<put/folder/from/the/step/three/here>");
%include packages(SPFinit.sas);

%loadPackage(HelloWorld)

%HelloWorldMacro(7)
```

### Congratulations!! You created your first HelloWorld package.
