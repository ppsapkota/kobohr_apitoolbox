'-
***********************************************
Developed by: Punya Prasad Sapkota
Last Modified: 18 July 2017
***********************************************
#---USAGE
#--TWO Sections
#Section 1
#-----KoBo data Access using API v1
#-----https://kc.humanitarianresponse.info/api/v1
#Section 2
#-----new KoBo KPI
-'

###--------SECTION 2---KPI---------
#---Upload form in NEW KoBo toolbox--------
#Import your form first (POST to https://kobo.humanitarianresponse.info/imports/)
#which will create a new asset in KPI which you can then deploy 
#by POSTing to https://kobo.humanitarianresponse.info/assets/[asset ID number]/deployment/
#USAGE: kobo_formxlsx="./xlsform/kobo_1701_NW.xlsx"
#url = "https://kobo.humanitarianresponse.info/imports/"
kobohr_kpi_upload_xlsform <-function(url,kobo_xlsform,u,pw){
  result<-httr::POST (url,
                      body=list(
                        xls_file=upload_file(path=kobo_xlsform)),
                      authenticate(u,pw))
  result<-result
}

###--------SECTION 1---KC---------
#---Upload form in KoBo toolbox--------
#curl -X POST -F xls_file=@/path/to/form.xls https://kobo.humanitarianresponse.info/api/v1/forms
#POST(url, body = upload_file("mypath.txt"))
#USAGE: kobo_formxlsx="./xlsform/kobo_1701_NW.xlsx"
#url = "https://kc.humanitarianresponse.info/api/v1/forms"
kobohr_upload_xlsform <-function(url,kobo_xlsform,u,pw){
  result<-httr::POST (url,
                      body=list(
                        xls_file=upload_file(path=kobo_xlsform)),
                      authenticate(u,pw))
  result<-result
}

#user names and password to be loaded from external authenticate file - this approach to be checked
#returns list of forms as a dataframe
#url <- "https://kc.humanitarianresponse.info/api/v1/data.csv"
kobohr_getforms_csv <-function(url,u,pw){
  #supply url
  rawdata<-GET(url,authenticate(u,pw),progress())
  cat("\n\n")
  d_content_csv <-read_csv(content(rawdata,"raw",encoding = "UTF-8"))
}

#returns the CSV content of the form
#url<-https://kc.humanitarianresponse.info/api/v1/data/145448.csv
kobohr_getdata_csv<-function(url,u,pw){
  #supply url for the data
  rawdata<-GET(url,authenticate(u,pw),progress())
  cat("\n")
  d_content <- read_csv(content(rawdata,"raw",encoding = "UTF-8"))
}

#submission count
#returns number of data submisstion in each form
#url<-'https://kc.humanitarianresponse.info/api/v1/stats/submissions/145533?group=anygroupname'
kobohr_count_submission <-function(url,u,pw){
  #supply url
  rawdata<-GET(url,authenticate(u,pw),progress())
  d_content <- rawToChar(rawdata$content)
  d_content <- fromJSON(d_content)
  d_count_submission <- d_content$count
}

#downlod data in CSV format
#---Parameters
#-----formid <- 145533
#-----savepath <- "./data/data_export_csv/"
#-----u <- "username"
#-----pw <- "password"
kobohr_download_csv<-function(formid,savepath,u,pw){
  #check the submission first
  d_count_subm<-NULL
  stat_url<- paste0('https://kc.humanitarianresponse.info/api/v1/stats/submissions/',formid,'?group=anygroup')
  d_count_subm <- kobohr_count_submission (stat_url,u,pw)
  #download data only if submission
  if (!is.null(d_count_subm)){
    #Example "https://kc.humanitarianresponse.info/api/v1/data/79489.csv"
    kobo_csv_url <- paste0("https://kc.humanitarianresponse.info/api/v1/data/", formid,".csv")
    d_rawi<-kobohr_getdata_csv(kobo_csv_url,u,pw)
    #write to csv
    #save file name
    savefile <- paste0(savepath,formid,"_data.csv")
    write_csv(d_rawi,savefile)
  }
}

#------------------------------------------------------------#
#supply url
#user names and password to be loaded from external authenticate file - this approach to be checked
kobohr_getforms <-function(url,u,pw){
  #supply url
  rawdata<-GET(url,authenticate(u,pw),progress())
  d_content <- rawToChar(rawdata$content)
  d_content <- fromJSON(d_content)
}

kobohr_getdata<-function(url,u,pw){
  #supply url for the data
  rawdata<-GET(url,authenticate(u,pw),progress())
  cat("\n\n")
  d_content <- rawToChar(rawdata$content)
  d_content <- fromJSON(d_content)
}













