# kobohr_apitoolbox
This toolbox contains R-script functions to perform several tasks using API for https://kobo.humanitarianresponse.info/. It supports the use of both older and newer API versions.

Functions defined in the file  
https://github.com/ppsapkota/kobohr_apitoolbox/blob/master/R/r_func_ps_kobo_utils.R


Locate raw file in the github.

```r
library(devtools)
source_url("https://raw.githubusercontent.com/ppsapkota/kobohr_apitoolbox/master/R/r_func_ps_kobo_utils.R")
```  
After loading the file, all functions will be available for you to use.  

## Download form/project list  
```r
url <-"https://kc.humanitarianresponse.info/api/v1/data.csv"
d_formlist_csv <- kobohr_getforms_csv (url,kobo_user, kobo_pw)
d_formlist_csv <- as.data.frame(d_formlist_csv)
```

**usage:**  
kobo_user <- kobo user account name as string (example "nnkbuser")  
kobo_pw <- password for kobo user account as string (example "nnkbpassword")  

## Download data in CSV format  
```r
url<-"https://kc.humanitarianresponse.info/api/v1/data/form_id.csv"
d_raw <- kobohr_getdata_csv(url,kobo_user,kobo_pw)  
data <- as.data.frame(d_raw)
```
**usage:**   
form_id <- id of the deployed project (for example 112233)  
For the project or form ID, you can download the list of forms available in your account using __kobohr_getforms_csv__ function.  

## Check submission count for the project  
```r
stat_url<- paste0('https://kc.humanitarianresponse.info/api/v1/stats/submissions/',form_id,'?group=a')    
d_count_subm <- kobohr_count_submission (stat_url,kobo_user,Kobo_pw)  
``` 
returns number of records submitted for a project  
**usage:**  
form_id <- id of the deployed project (for example 112233)   
```r
#you can check the number of records submitted before downloading the data
if (d_count_subm>0){
      #Example "https://kc.humanitarianresponse.info/api/v1/data/334455.csv"
      d_raw<-kobohr_getdata_csv(url,kobo_user,Kobo_pw)
      data<-as.data.frame(d_raw)
      #do more here, for example save the data as a xls file.
}
```
## Upload xlsform using new KoBo API (KPI), deploy as a project and share with KoBo user.
### STEP 1: import xlsx form  
```r
  kpi_url <- "https://kobo.humanitarianresponse.info/imports/"
  kobo_form_xlsx <- "abc.xlsx"
  d_content<-kobohr_kpi_upload_xlsform(kpi_url,kobo_form_xlsx,kobo_user,Kobo_pw)
  import_url<-d_content$url
```
### STEP2: get the resulting asset UID  
```r
##Multiple attempts may be required until the server indicates "status": "complete" in the response.
#import_url<-"https://kobo.humanitarianresponse.info/imports/iGYukk6NVEA64zwMsPtgRD/
#the import url is the resulting url from the step 1.
d_content<-kobohr_kpi_get_asset_uid(import_url,kobo_user,Kobo_pw)
asset_uid <- d_content$messages$created$uid
```
### STEP3: Deploy an asset  
```r
  d_content<-kobohr_kpi_deploy_asset(asset_uid, kobo_user, Kobo_pw)
```

### STEP4: Share Asset to other user  
```r
### share and assign multiple permission
### create permission list as required.
# ASSIGNABLE_PERMISSIONS = (
#   'view_asset',
#   'change_asset',
#   'add_submissions',
#   'view_submissions',
#   'change_submissions',
#   'validate_submissions',
# )
permission_list <- c("add_submissions","change_submissions","validate_submissions")
content_object_i <- paste0("/assets/", asset_uid,"/")
user_i <- "external username" #kobo user account to share the asset         
for (permission_i in permission_list){
    d_content<-kobohr_kpi_share_asset(content_object_i, permission_i, user_i, kobo_user, Kobo_pw)
}

```
## KoBo exports
Create KoBo data export and get the export list to pull data using the new KoBoToolbox API (https://github.com/kobotoolbox/kpi/). This is based on the code sample written in Python at https://github.com/tinok/kobo_api

### Create Exports
To download the most updated data, create export, retrieve the latest export and download data
```r
# set kobo server URL
# the kobo server URL is passed as global variable
kobo_server_url<-"https://kobo.humanitarianresponse.info/"
kc_server_url<-"https://kc.humanitarianresponse.info/"

# Reference https://github.com/tinok/kobo_api/blob/master/get_csv.py
# Get asset information
asset_uid<-"aaUR7DuXPLGsVUqMbv7BcB"

# define some variables
# These variables define the default export. Each value can be overwritten when running the `create' command
# e.g. `create xml 'English (en_US)' true'. It's possible to skip some arguments at the end but they need to be passed in the same order.
asset_uid_<-asset_uid
type <- "csv"
lang <- "xml"
fields_from_all_versions <- "true"
hierarchy_in_labels <- "false"
group_sep = "/"


#Examples to call function
d_exports<-kobohr_create_export(type=type,lang=lang,fields_from_all_versions=fields_from_all_versions,hierarchy_in_labels=hierarchy_in_labels,group_sep=group_sep,asset_uid=asset_uid,kobo_user,Kobo_pw)
d_exports<-as.data.frame(d_exports)
```
### Get list of exports
Use this function to retrieve the list of already creaded exports for a project identified by asset_uid
```r
###---list exports----------------###
#https://www.r-bloggers.com/using-the-httr-package-to-retrieve-data-from-apis-in-r/

d_list_export<-kobohr_list_exports(asset_uid,kobo_user,Kobo_pw)
 
```
### Get the latest export URL
To retrieve the latest export created for a project.
```r
###---list exports----------------###
d_list_export<-kobohr_list_exports(asset_uid,kobo_user,Kobo_pw)
 
```






