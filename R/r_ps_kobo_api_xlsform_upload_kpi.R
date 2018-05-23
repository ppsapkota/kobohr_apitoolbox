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

#STEP1--- Uploading the XLSForm ------------
# result<-httr::POST(url=kpi_url,
#                     body=list(
#                       file=upload_file(path=kobo_form_xlsx),
#                       library = 'false'
#                       ),
#                       authenticate(kobo_user,Kobo_pw)
#                   )
# 
# d_content <- rawToChar(result$content)
# #print (d_content)
# d_content <- fromJSON(d_content)
# #--success - status = 'processing'
# status<- d_content$status
# f_url<-d_content$url
# #STEP2---getting the resulting asset UID---
#----Get the asset UID-------------------------
#The asset UID is given by messages.created[0].uid in the JSON response when GETting an import. 
#Multiple GETs may be required until the server indicates "status": "complete" in the response:
#john@scrappy:/tmp/api_demo$ curl --silent --user jnm_api:test-for-punya --header 'Accept: application/json' 
#https://kobo.humanitarianresponse.info/imports/iGYukk6NVEA64zwMsPtgRD/ | python -m json.tool
# the URL is fetched from the output of previous step 
#d_content <- kobohr_kpi_get_asset_uid(import_url,u,pw)
# #supply url
# result<-GET(f_url,authenticate(kobo_user,Kobo_pw),progress())
# d_content <- rawToChar(result$content)
# d_content <- fromJSON(d_content)
# #--success - status = 'complete'
# 
# #STEP3-----Deploying the form------
# #kpi_id <- d_content$uid
# asset_uid <- d_content$messages$created$uid
# url <-paste0("https://kobo.humanitarianresponse.info/assets/",asset_uid,"/deployment/")
# d <- list(owner=paste0("https://kobo.humanitarianresponse.info/users/",kobo_user,"/"),active=TRUE)
# #d<-list(owner=paste0("https://kobo.humanitarianresponse.info/users/",kobo_user,"/"),active=TRUE)
# 
# result<-httr::POST (url,
#                     body=d,
#                     authenticate(kobo_user,Kobo_pw)
#                     )
# 
# d_content <- rawToChar(result$content)
# print(d_content)
# d_content <- fromJSON(d_content)

#------------------------------------
# #STEP1--- Uploading the XLSForm ------------
# query<-list('form[file]'=upload_file(path=kobo_form_xlsx),
#             'form[library]'=FALSE)
# 
# result<-httr::POST(url=kpi_url,
#                    body = query,
#                    authenticate(kobo_user,Kobo_pw)
#                   )
# 
# d_content <- rawToChar(result$content)
# #print (d_content)
# d_content <- fromJSON(d_content)
# #--success - status = 'processing'
# 
# f_url<-d_content$url
# 








