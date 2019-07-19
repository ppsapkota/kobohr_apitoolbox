
'----
***********************************
Developed by: Punya Prasad Sapkota
Last modified: 15 July 2019
***********************************
#---USAGE
#-----Exporting CSV data to external XLSX file
#-----Exports data from the multiple forms in the account
----'

source("./R/r_ps_kobo_library_init.R")
kobo_server_url<-"https://kobo.humanitarianresponse.info/"
save_path<-paste0("./Data/")
#----------
##loop through each form and fetch data for individual form and export to CSV
#read list of forms in the KoBo account - list of forms created with 'kobohr_getforms_csv' function
#--EXPORT data to individual csv files
#d_formlist_csv <-read_excel("./Data/ochaturkey1_formlist.xlsx",sheet=1) #TUR
#d_formlist_csv <-read_excel("./Data/syriaregional1_formlist.xlsx",sheet=1) #JOR
#d_formlist_csv <-read_excel("./Data/syriaregional2_formlist.xlsx",sheet=1) #DAM
d_formlist <-read_excel("./Data/syriaregional3_assetlist.xlsx",sheet=1) #TurkeyXB MSNA2018
####---download only marked as download=YES
d_formlist<-filter(d_formlist,str_to_lower(download)=="yes")

###define some variables
# These variables define the default export. Each value can be overwritten when running the `create' command
# e.g. `create xml 'English (en_US)' true'. It's possible to skip some arguments at the end but they need to be passed in the same order.
##asset_uid_<-asset_uid
type <- "xls"#"csv"
lang <- "English (en)" #"xml"
fields_from_all_versions <- "false"
hierarchy_in_labels <- "false"
group_sep = "/"


#STEP 1 - Create Export
print (paste0("STEP 1 - Create Export"))
for (i in 1:nrow(d_formlist)){
  #i=4
  print(d_formlist$url[i])
  asset_uid<-d_formlist$uid[i]
  #URL format
  #check the submission first
  d_count_subm<-d_formlist$deployment__submission_count[i]
  #stat_url<- paste0("https://kc.humanitarianresponse.info/api/v1/stats/submissions/",d_formlist$id[i],"?group=a")
  #stat_url<- paste0(kc_server_url,"api/v1/stats/submissions/",d_formlist$id[i],"?group=a")
  #d_count_subm <- kobohr_count_submission (stat_url,kobo_user,Kobo_pw)
  #download data only if submission
  #if (!is.null(d_count_subm)){
  if (d_count_subm>0){
    #
    d_exports<-kobohr_create_export(type=type,lang=lang,fields_from_all_versions=fields_from_all_versions,hierarchy_in_labels=hierarchy_in_labels,group_sep=group_sep,asset_uid=asset_uid,kobo_user,Kobo_pw)
    d_exports<-as.data.frame(d_exports)
  }
}

##STEP 2 - Get Last export
print (paste0("STEP 2 - Get last export"))
for (i in 1:nrow(d_formlist)){
  #i=1
  print(d_formlist$url[i])
  asset_uid<-d_formlist$uid[i]
  #URL format
  #check the submission first
  d_count_subm<-d_formlist$deployment__submission_count[i]
  print (paste0("Number of submissions -> ",d_count_subm))
  
  if (d_count_subm>0){
    #once export is created
    # get the list of exports
    d_latest_export<-kobohr_latest_exports(asset_uid,kobo_user,Kobo_pw)
    d_latest_export<-as.data.frame(d_latest_export)
    #download file if there is an export created.
    if (nrow(d_latest_export)>0){
      export_filename<-d_latest_export$result[1]
      #get the file
      userpw<-paste(kobo_user,Kobo_pw,sep=":")
      # form_tmp <- file(paste0("form_","a",".xls"), open = "wb")
      # #
      # bin <- getBinaryURL(url=export_filename, userpwd=userpw , httpauth = 1L, ssl.verifypeer=FALSE)
      # #
      # writeBin(bin, form_tmp)
      # close(form_tmp)
      
      ##with xlsx
      #URL2 <- sprintf(fmt = '%sforms/%s/form.xlsx', api, formid)
      form_tmp <- file(paste0("form_","a",".xlsx"), open = "wb")
      bin <- getBinaryURL(url=export_filename, userpwd=userpw , httpauth = 1L, ssl.verifypeer=FALSE  )
      writeBin(bin, form_tmp)
      close(form_tmp)
      
      
      
      downloadFile(export_filename,"c.xls",username = kobo_user,password = Kobo_pw, binary = TRUE)
      
      
    f1<-"https://www.dropbox.com/s/czc2algplf6feg1/syr_admin_20180701.xlsx?dl=0"
    downloadFile(f1,"c.xls", binary = TRUE)
      
    }
    
  }
}
  
  
  
  
  
  
    #Example "https://kc.humanitarianresponse.info/api/v1/data/79489.csv"
    d_rawi<-kobohr_getdata_csv(d_formlist$url[i],kobo_user,Kobo_pw)
    d_rawi<-as.data.frame(d_rawi)
    d_rawi<-lapply(d_rawi,as.character)
    d_rawi<-as.data.frame(d_rawi,stringsAsFactors=FALSE,check.names=FALSE)
    
    #Recode 'n/a' to 'NA'
    for (kl in 1:ncol(d_rawi)){
      d_rawi[,kl]<-ifelse(d_rawi[,kl]=="n/a",NA,d_rawi[,kl])
    }
    #write to csv
    #save file name
    #savefile <- paste0("./Data/01_Download_CSV/",d_formlist_csv$id_string[i],"_", d_formlist_csv$id[i],"_data.csv")
    #write_csv(d_rawi,savefile)
    #save as xlsx
    d_rawi[is.na(d_rawi)] <- 'NA'
    #make filename that can be recognised - remove arabic texts
    title<-d_formlist$title[i]
    title<-str_replace_all(title," ","_")
    title<-iconv(title,"UTF-8","ASCII",sub="")
    title<-str_replace_all(title,"__","")
    #
    savefile_xlsx <- paste0("./Data/01_Download_CSV/",title,"_",d_formlist$id_string[i],"_", d_formlist$id[i],"_data.xlsx")
    #write.xlsx2(as.data.frame(d_rawi),savefile_xlsx,sheetName = "data",row.names = FALSE)
    openxlsx::write.xlsx(d_rawi,savefile_xlsx,sheetName="data",row.names=FALSE)
  }
}




