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
###XLSform upload goes to draft and deploy it---
###-----------ASSETS DEPLOYMENT--WORKING-----------
##create a new asset in KPI which you can then deploy 
#by POSTing to https://kobo.humanitarianresponse.info/assets/[asset ID number]/deployment/

#https://kobo.humanitarianresponse.info/#/forms/a37dnoBZNdXbSUezkpk77v
kpi_id <- "a37dnoBZNdcccccXbSUezkpk77v"
url <-paste0("https://kobo.humanitarianresponse.info/assets/",kpi_id,"/deployment/")
d <- list(owner=paste0("https://kobo.humanitarianresponse.info/users/",kobo_user,"/"))
#d<-list(owner=paste0("https://kobo.humanitarianresponse.info/users/",kobo_user,"/"),active=TRUE)

result<-httr::POST (url,
                    body=d,
                    authenticate(kobo_user,Kobo_pw))

d_content <- rawToChar(result$content)
print(d_content)
d_content <- fromJSON(d_content)
### the project is listed in Archive


##For downloading assets list
#supply url
url<-url <-paste0("https://kobo.humanitarianresponse.info/assets/?limit=500&offset=0")
result<-GET(url,authenticate(u,pw),progress())
d_content <- rawToChar(result$content)
d_content <- fromJSON(d_content)
d_asset<-data.frame(d_content$results$url,
              d_content$results$date_modified,
              d_content$results$owner,
              d_content$results$owner__username,
              d_content$results$uid,
              d_content$results$kind,
              d_content$results$name,
              d_content$results$asset_type,
              d_content$results$deployment__active,
              d_content$results$deployment__identifier,
              d_content$results$deployment__submission_count)

names(d_asset)<-c("url","date_modified","owner","owner__username","uid","kind","name","asset_type","deployment__active","deployment__identifier","deployment__submission_count")

###save to file
openxlsx::write.xlsx(d_asset,paste0("./Data/",kobo_user,"_asset_list.xlsx"), sheetName="asset_list")



# "deployment__data_download_links": {
#   "csv_legacy": "https://kc.humanitarianresponse.info/syriaregional3/exports/au38VsvVzqkwZVFKxRPVAf/csv/",
#   "kml_legacy": "https://kc.humanitarianresponse.info/syriaregional3/exports/au38VsvVzqkwZVFKxRPVAf/kml/",
#   "spss_labels": "https://kc.humanitarianresponse.info/syriaregional3/forms/au38VsvVzqkwZVFKxRPVAf/spss_labels.zip",
#   "xls": "https://kc.humanitarianresponse.info/syriaregional3/reports/au38VsvVzqkwZVFKxRPVAf/export.xlsx",
#   "csv": "https://kc.humanitarianresponse.info/syriaregional3/reports/au38VsvVzqkwZVFKxRPVAf/export.csv",
#   "analyser_legacy": "https://kc.humanitarianresponse.info/syriaregional3/exports/au38VsvVzqkwZVFKxRPVAf/analyser/",
#   "xls_legacy": "https://kc.humanitarianresponse.info/syriaregional3/exports/au38VsvVzqkwZVFKxRPVAf/xls/",
#   "zip_legacy": "https://kc.humanitarianresponse.info/syriaregional3/exports/au38VsvVzqkwZVFKxRPVAf/zip/"
# }

url<-"https://kc.humanitarianresponse.info/syriaregional3/reports/au38VsvVzqkwZVFKxRPVAf/export.csv"

rawdata<-GET(url,authenticate(u,pw),progress())
d_content_csv <-read_csv(content(rawdata$content,"raw",encoding = "UTF-8"))
d_content <- rawToChar(rawdata$content)
d_content <- fromJSON(d_content)





