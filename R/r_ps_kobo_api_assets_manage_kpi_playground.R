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
getOption("encoding")
Sys.getlocale("LC_ALL")

api_url <-paste0(kobo_server_url, "forms/assets/?limit=500&offset=0")
result<-GET(api_url,authenticate(u,pw),progress())
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


####
#call functions
d_exports<-kobohr_create_export(type=type,lang=lang,fields_from_all_versions=fields_from_all_versions,hierarchy_in_labels=hierarchy_in_labels,group_sep=group_sep,asset_uid=asset_uid,kobo_user,Kobo_pw)
d_exports<-as.data.frame(d_exports)

d_latest_export<-kobohr_latest_exports(asset_uid,kobo_user,Kobo_pw)
d_latest_export<-as.data.frame(d_latest_export)
#################-----https://github.com/tinok/kobo_api/blob/master/get_csv.py--------------#########
###Get asset information
asset_uid<-"aaUR7DuXPLGsVUqMbv7BcB"
###define some variables
# These variables define the default export. Each value can be overwritten when running the `create' command
# e.g. `create xml 'English (en_US)' true'. It's possible to skip some arguments at the end but they need to be passed in the same order.
asset_uid_<-asset_uid
type <- "csv"
lang <- "xml"
fields_from_all_versions <- "true"
hierarchy_in_labels <- "false"
group_sep = "/"

###--CREATE EXPORT-----------
kobohr_create_export<-function(type,lang,fields_from_all_versions,hierarchy_in_labels,group_sep,asset_uid,kobo_user,Kobo_pw){
  ##check for missing parameters supplied
  # if (missing(type)){
  #   type="csv"
  # }
  #
  api_url_export<-paste0(kobo_server_url,"exports/")
  api_url_asset<-paste0(kobo_server_url,"assets/",asset_uid,"/")
  api_url_export_asset<-paste0(kobo_server_url,"exports/",asset_uid,"/")
  #
  d<-list(source=api_url_asset,
          type=type,
          lang=lang,
          fields_from_all_versions=fields_from_all_versions,
          hierarchy_in_labels=hierarchy_in_labels,
          group_sep=group_sep)
  #fetch data
  result<-httr::POST (url=api_url_export,
                      body=d,
                      authenticate(kobo_user,Kobo_pw),
                      progress()
  )
  
  print(paste0("status code:",result$status_code))
  d_content <- rawToChar(result$content)
  print(d_content)
  d_content <- fromJSON(d_content)
  return(d_content)
}


###---list exports----
#https://www.r-bloggers.com/using-the-httr-package-to-retrieve-data-from-apis-in-r/
kobohr_list_exports<-function(asset_uid,kobo_user,Kobo_pw){
  api_url_export<-paste0(kobo_server_url,"exports/")
  api_url_asset<-paste0(kobo_server_url,"assets/",asset_uid,"/")
  api_url_export_asset<-paste0(kobo_server_url,"exports/",asset_uid,"/")
  #
  payload<-list(q=paste0('source:',asset_uid))
  #payload<-list(source=asset_uid_)
  #fetch data
  result<-httr::GET (url=api_url_export,
                     query=payload,
                     authenticate(kobo_user,Kobo_pw),
                     progress()
  )
  
  warn_for_status(result)
  stop_for_status(result)
  
  print(paste0("status code:",result$status_code))
  #
  #print(str(content(result)))
  #stringi::stri_enc_detect(content(result, "raw"))
  d_content<-fromJSON(content(result,"text",encoding = "UTF-8"))
  #get both result and data
  d_content_result<-data.frame(d_content$results$result,d_content$results$date_created,d_content$results$last_submission_time)
  #replace texts in the field name
  names(d_content_result)<-str_remove(names(d_content_result),"d_content.results.")
  
  d_content_data<-data.frame(d_content$results$data)
  
  d_content_all<-bind_cols(d_content_result,d_content_data)
  ##rename
  #names(d_content_all)<-c("result",names(d_content_data))
  #filter content by the asset uid
  d_content_list<-d_content_all %>% 
    filter(str_detect(source,asset_uid))
  #d_content_ <-as.data.frame(d_content$results$url,d_content$results$uid)
  return(d_content_list)
}


#Get the latest export URL
kobohr_latest_exports<-function(asset_uid,kobo_user,Kobo_pw){
  d_list_export_urls<-kobohr_list_exports(asset_uid,kobo_user,Kobo_pw)
  d_list_url<-d_list_export_urls[nrow(d_list_export_urls),]
  latest_url<-d_list_url$result
  return(latest_url)
}




#api_url<-"https://kc.humanitarianresponse.info/syriaregional3/reports/au38VsvVzqkwZVFKxRPVAf/export.xlsx"
result<-GET(api_url,authenticate(u,pw),progress())
d_content <- rawToChar(result$content)
d_content <- fromJSON(d_content)

d_downloads<-as.data.frame(d_content$deployment__data_download_links$csv, d_content$deployment__data_download_links$xls)

#https://kc.humanitarianresponse.info/syriaregional3/reports/anBiBMq3f75WWCaJfNs7Eo/export.csv
api_url<- paste0(kc_server_url,kobo_user,"/reports/",asset_uid,"/export.csv")
rawdata<-GET(api_url,authenticate(u,pw),progress())
d_content <- read_csv(content(rawdata,"raw",encoding = "UTF-8"))


d_content <- rawToChar(rawdata$content)
d_content <- fromJSON(d_content)


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

#url<-"https://kc.humanitarianresponse.info/syriaregional3/reports/au38VsvVzqkwZVFKxRPVAf/export.csv"





