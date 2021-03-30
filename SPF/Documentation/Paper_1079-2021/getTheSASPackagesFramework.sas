filename packages "~/saspackages";

filename SPFinit url 
  "https://raw.githubusercontent.com/yabwon/SAS_PACKAGES/main/SPF/SPFinit.sas";
%include SPFinit; 

%installPackage(SPFinit)
