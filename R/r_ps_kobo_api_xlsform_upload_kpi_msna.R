###---A KOBO NEW API (KPI) METHODS----
##- this script is to provide following solution--
#1) upload Xlsform to KPI
#2) deploy form/asset
#3) share the deployed form to other user
#4) copy/clone form and change properties such as form name etc

rm(list=ls())

## SET KoBO user name and password
kobo_user<- ""
Kobo_pw<-""

source ("./R/r_ps_kobo_library_init.R")
source ("./R/r_ps_kobo_authenticate.R")
###################---KPI--------#########################################
kpi_url <- "https://kobo.humanitarianresponse.info/imports/"
#----------------------------------#
#kobo_form_xlsx<-"./xlsform/kobo_1701_NW.xlsx"
kobo_form_xlsx_folder<-"./Data/xlsform/nes/"
kobo_users_file<-"./Data/kobo_users/MSNA2018_NES_coverage_summary_govpcode.xlsx"
asset_uid_savename<-"./Data/kobo_users/asset_uid_nes_20180718_reach.xlsx"
## get list of files
f_list<-list.files(path=kobo_form_xlsx_folder,full.names=TRUE, ignore.case = TRUE,pattern = "xlsx|XLSX")
#read KoBo users list
d_kobo_users<-read_excel(path=kobo_users_file,sheet="data")

######STEP1----import xlsx form-------------
#create empty data frame
#to contain information about asset id generate
#by api
d_import_url<- data.frame(import_url=character(), 
                           user=character(),
                           f_name=character(),
                           stringsAsFactors=FALSE) 
#IMPORT xlsx form
for (kobo_form_xlsx in f_list){
  #kobo_form_xlsx<-f_list[1]
  #get base name
  kobo_form_xlsx_bn<-basename(kobo_form_xlsx)
  #STEP1 ----import xlsx form
  d_content<-kobohr_kpi_upload_xlsform(kpi_url,kobo_form_xlsx,kobo_user,Kobo_pw)
  import_url<-d_content$url
  #add to datafrme
  d_import_url<-bind_rows(d_import_url,data.frame(import_url=import_url,f_name=kobo_form_xlsx_bn))
}

######STEP2---getting the resulting asset UID------------
#get ASSET UID
d_asset_uid<- data.frame(asset_uid=character(), 
                          user=character(),
                          f_name=character(),
                          stringsAsFactors=FALSE) 
#repeat through each import url to get asset uid
for (i_row in 1:nrow(d_import_url)){
  import_url<-d_import_url$import_url[i_row]
  #STEP2---getting the resulting asset UID---
  d_content<-kobohr_kpi_get_asset_uid(import_url,kobo_user,Kobo_pw)
  asset_uid <- d_content$messages$created$uid
  print (paste0("Asset UID - ", asset_uid))
  #
  d_asset_uid<-bind_rows(d_asset_uid,data.frame(asset_uid=asset_uid,f_name=d_import_url$f_name[i_row]))
}

##-------from the form name - identify partner ID and pull user name
d_asset_uid$organization_code<-str_replace_all(d_asset_uid$f_name,"kobo_msna2018_","") %>% 
                     str_sub(1,4)
#bring kobo users
d_kobo_users<-select(d_kobo_users,organization_code,kobo_user) %>% 
              mutate(organization_code=as.character(organization_code))

d_asset_uid_kobo_users<-d_asset_uid %>%
                        left_join(d_kobo_users,by=c("organization_code"="organization_code"))

##--------exort asset uid
openxlsx::write.xlsx(d_asset_uid_kobo_users,asset_uid_savename, sheetName="data")


######STEP3 ---- DEPLOY ASSET-------------
for (i_row in 1:nrow(d_asset_uid_kobo_users)){
  asset_uid<-d_asset_uid_kobo_users$asset_uid[i_row]
  #STEP3 ----Deploy asset
  d_content<-kobohr_kpi_deploy_asset(asset_uid, kobo_user, Kobo_pw)
}

#SHARE AssET
# Assignable permissions that are stored in the database
# ASSIGNABLE_PERMISSIONS = (
#   'view_asset',
#   'change_asset',
#   'add_submissions',
#   'view_submissions',
#   'change_submissions',
#   'validate_submissions',
# )
#####STEP4--------SHARE ASSET--------------
for (i_row in 1:nrow(d_asset_uid_kobo_users)){
  asset_uid<-d_asset_uid_kobo_users$asset_uid[i_row]
  share_kobo_users<-d_asset_uid_kobo_users$kobo_user[i_row]
  #STEP3 ----Deploy asset
  content_object_i<-paste0("/assets/", asset_uid,"/")
  
  ##---------prepare KoBo user list
  d_share_kobo_users<-as.data.frame(unlist(strsplit(share_kobo_users,",")))
  names(d_share_kobo_users)[1]<-"kobo_users"
  #remove spaces
  d_share_kobo_users$kobo_users<-str_replace_all(d_share_kobo_users$kobo_users," ","")
  
  #loop through all users
  for (i_row_user in 1:nrow(d_share_kobo_users)){
        user_i<-paste0("/users/", d_share_kobo_users$kobo_users[i_row_user],"/")
        permission_list<-c("add_submissions","change_submissions","validate_submissions")
        
        for (permission_i in permission_list){
          #permission_i<-"add_submissions"
          d_content<-kobohr_kpi_share_asset(content_object_i, permission_i, user_i, kobo_user, Kobo_pw)
          print (paste0(d_asset_uid_kobo_users$f_name[i_row],"--", asset_uid,"--",d_content$user, "--",user_i,"--", permission_i))
        }
  }
}

#TEMPORARY SOLUTION--RUN for individuals-----
asset_uid_list<-c("aYuG9f5juoyxxxQCparYphihf","aiHRkNJrJBxxxxFoXMbnJNUCSa","adNPSX6XhxxxxFGSHsbRKLbRjw")
share_user_list<-c("sarahalmuhsen","ahmad88sy","sharba","hasanyousef ")
permission_list<-c("add_submissions","change_submissions","validate_submissions")
for (asset_uid in asset_uid_list){
  content_object_i<-paste0("/assets/", asset_uid,"/")
  for (share_user in share_user_list){
    user_i<-paste0("/users/", share_user,"/")
    for (permission_i in permission_list){
      #permission_i<-"add_submissions"
      d_content<-kobohr_kpi_share_asset(content_object_i, permission_i, user_i, kobo_user, Kobo_pw)
      print (paste0(user_i,"--", asset_uid,"--",permission_i))
    } 
  }
}

#---------------






