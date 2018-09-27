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
kobo_form_list_xlsx<-"./data/xlsform/syriaregional3_formlist.xlsx"

d_kobo_form_list<-read_excel(kobo_form_list_xlsx)
url_main<-"https://kc.humanitarianresponse.info/api/v1/forms/"
asset_url<-paste0("https://kobo.humanitarianresponse.info/assets/")
#get data for deleting form
d_kobo_form_list<-d_kobo_form_list %>% 
                  mutate(delete=str_to_upper(delete)) %>% 
                  filter(delete=="YES")


for (i in 1:nrow(d_kobo_form_list)){
  form_url_i<- paste0(url_main,d_kobo_form_list$id[i])
  asset_uid_i<-d_kobo_form_list$id_string[i]
  asset_url_uid_i<-paste0(asset_url,asset_uid_i,"/")
  #
  asset_url_uid_i<-"https://kobo.humanitarianresponse.info/assets/ao26Uyk3MxxxxiwfguGEwU4dJ3/"
  a<-"https://kobo.humanitarianresponse.info/api/v1/forms/252817/"
  d <- list(asset_type="survey", content_object="/assets/ao26Uyk3MiwfxxxguGEwU4dJ3/")
  result<-httr::DELETE (url=asset_url_uid_i,
                        body=d,
                        authenticate(u,pw)
                        )
  d_content <- rawToChar(result$content)
  d_content <- fromJSON(d_content)
  print (paste0("Delete Success - ", d_content$identifier))
}

# 
# #---DELETE FROM-----WORKING---
# #curl -X DELETE https://kobo.humanitarianresponse.info/api/v1/forms/28058
# url<-"https://kc.humanitarianresponse.info/api/v1/forms/225262"
# result<-httr::DELETE (form_url,authenticate(kobo_user,Kobo_pw))
# 
# #DELETE FORMS
