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
url<-https://kc.humanitarianresponse.info/api/v1/data/form_id.csv
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
## Upload xlsform using new KoBo API (KPI) and deploy as a project  
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
d_content<-kobohr_kpi_get_asset_uid(import_url,kobo_user,Kobo_pw)
asset_uid <- d_content$messages$created$uid
```
### STEP3: Deploy an asset  
```r
  d_content<-kobohr_kpi_deploy_asset(asset_uid, kobo_user, Kobo_pw)
```

## Share Asset to other user  
```r
### share and assign multiple permission
permission_list <- c("add_submissions","change_submissions","validate_submissions")
content_object_i <- paste0("/assets/", asset_uid,"/")
user_i <- "externalusername" #kobo user account to share the asset         
for (permission_i in permission_list){
    d_content<-kobohr_kpi_share_asset(content_object_i, permission_i, user_i, kobo_user, Kobo_pw)
}
# ASSIGNABLE_PERMISSIONS = (
#   'view_asset',
#   'change_asset',
#   'add_submissions',
#   'view_submissions',
#   'change_submissions',
#   'validate_submissions',
# )
```
