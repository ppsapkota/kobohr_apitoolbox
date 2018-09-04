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
