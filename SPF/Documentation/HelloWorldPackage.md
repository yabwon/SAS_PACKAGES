  
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
 This is a help info for the `HelloWorldFormat.` format.
 
 Category *other* is marked with exclamation mark (`!`).
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
 This is a help info for the `%helloWorldMacro()` macro.
 
 Macro has the following parameter(s):
 - `n` - *Required*, provides number of loop iterations.
 
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
### My "Hello World" SAS package ###

The "Hello World" is my first SAS package and 
for sure it will not be the last package one!

Using packages is a good idea!
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
 ,markdownDoc=1
)
```

`Step 10.` See the information in the output window and in the log.
           The `WARNING:[License] No license.sas file provided, default (MIT) licence file will be generated.` can be ignored.

`Step 11.` Check the directory from the `Step 3.` and look for the `helloworld.zip` package file and `helloworld.md` documentation file.

---

`Step 12.` Start a new SAS session, run the following code, and investigate the log:

```sas
filename packages ("<put/folder/from/the/step/one/here>" "<put/folder/from/the/step/three/here>");
%include packages(SPFinit.sas);

%loadPackage(HelloWorld)

%HelloWorldMacro(7)
```

---

### Congratulations!! You've just created your first HelloWorld package.

Now you are ready to do smome more advanced work.

- Read the **`My First SAS Package: A How-To - Paper 1079-2021`** article, available at communities.sas.com [**`here`**](https://communities.sas.com/t5/SAS-Global-Forum-Proceedings/My-First-SAS-Package-A-How-To/ta-p/726319 "My First SAS Package: A How-To + Video") (video included) or locally [**`here`**](https://github.com/yabwon/SAS_PACKAGES/blob/main/SPF/Documentation/Paper_1079-2021/My%20First%20SAS%20Package%20-%20a%20How%20To.pdf "My First SAS Package: A How-To"), describing the proces of a package creation with more advanced example and technical details.

- Go to "bare metal" and read the [**`SAS Packages - The Way to Share (a How-To) - Paper 4725-2020 - extended version`**](https://github.com/yabwon/SAS_PACKAGES/blob/main/SPF/Documentation/SAS(r)%20packages%20-%20the%20way%20to%20share%20(a%20how%20to)-%20Paper%204725-2020%20-%20extended.pdf "SAS packages - the way to share") - an article which contains all technical details on how the SAS Packages Framework works and how to use it (both as a develope and as a user).

---

The SAS Packages Framework [(short) documetation](https://github.com/yabwon/SAS_PACKAGES/blob/main/SPF/SPFinit.md) to quickly see macros options and parametera.

---


