###---A PLAY GROUND FOR TESTING KOBO API METHODS----
##- this script is to provide following solution--
#1) upload Xlsform to KPI
#2) deploy form/asset
#3) share the deployed form to other user
#4) copy/clone form and change properties such as form name etc

## SET KoBO user name and password
kobo_user<- ""
Kobo_pw<-""

source ("./R/r_ps_kobo_library_init.R")
#source ("./R/r_ps_kobo_authenticate.R") ###--not uploaded in Github - instead set Kobo_user and kobo_pw variables
source ("./R/r_func_ps_kobo_utils.R")

###################---KPI--------#########################################
kobo_form_xlsx<-"./xlsform/kobo_1701_NW.xlsx"
kpi_url <- "https://kobo.humanitarianresponse.info/imports/"
####------------------ASSETS IMPORT------------
#https://stackoverflow.com/questions/35583134/r-post-postform-upload-issue
# POST(url="https://xxx.YYYY/upload",
#      body = list(file=upload_file(
#        path =  outfilename,
#        type = 'text/txt')
#      ),
#      verbose(),
#      add_headers(Authorization=paste0("Bearer XXXX-XXXX-XXXX-XXXX"))
# )
##POST("http://example.org/upload", body=list(name="test.csv", filedata=upload_file(filename, "text/csv")))
#<input type="file" accept=".xls,.xlsx,application/xls,application/vnd.ms-excel,
#application/octet-stream,application/vnd.openxmlformats,application/vnd.openxmlformats-officedocument.spreadsheetml.sheet,
#"autocomplete="off" style="display: none;">

#STEP1 ----import xlsx form
d_content<-kobohr_kpi_upload_xlsform(kpi_url,kobo_form_xlsx,kobo_user,Kobo_pw)
import_url<-d_content$url

#STEP2---getting the resulting asset UID---
d_content<-kobohr_kpi_get_asset_uid(import_url,kobo_user,Kobo_pw)
asset_uid <- d_content$messages$created$uid

#STEP3 ----Deploy asset
d_content<-kobohr_kpi_deploy_asset(asset_uid, kobo_user, Kobo_pw)

#STEP4 ----Share asset
content_object_i<-paste0("/assets/", asset_uid,"/")
user_i<-paste0("/users/punya/")
permission_list<-c("add_submissions","change_submissions","validate_submissions")

for (permission_i in permission_list){
  #permission_i<-"add_submissions"
  d_content<-kobohr_kpi_share_asset(content_object_i, permission_i, user_i, kobo_user, Kobo_pw)
  print (paste0(asset_uid,"--",d_content$user, "--",user_i,"--", permission_i))
}







