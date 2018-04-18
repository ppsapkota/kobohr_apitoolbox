'----
***********************************
Developed by: Punya Prasad Sapkota
Last modified: 8 August 2017
***********************************
#---USAGE
#-----Exporting data to external CSV file
#-----Exports data from the multiple forms in the account
----'

#----------
##loop through each form and fetch data for individual form and export to CSV
#read list of forms in the KoBo account - list of forms created with 'kobohr_getforms_csv' function
#--EXPORT data to individual csv files
d_formlist_csv <-read_excel("./Data/syriaregional3_formlist.xlsx",sheet=1) #TUR
#d_formlist_csv <-read_excel("./Data/syriaregional1_formlist.xlsx",sheet=1) #JOR
#d_formlist_csv <-read_excel("./Data/syriaregional2_formlist.xlsx",sheet=1) #DAM
#download only marked as downloadable
d_formlist_csv<-filter(d_formlist_csv,download=="Yes")

for (i in 1:nrow(d_formlist_csv)){
  #i=39
  print(d_formlist_csv$url[i])
  #URL format
  #check the submission first
  d_count_subm<-0
  stat_url<- paste0('https://kc.humanitarianresponse.info/api/v1/stats/submissions/',d_formlist_csv$id[i],'?group=a')
  d_count_subm <- kobohr_count_submission (stat_url,kobo_user,Kobo_pw)
  #download data only if submission
  if (!is.null(d_count_subm)){
      d_rawi<-NULL
      #Example "https://kc.humanitarianresponse.info/api/v1/data/79489.csv"
      d_rawi<-kobohr_getdata_csv(d_formlist_csv$url[i],kobo_user,Kobo_pw)
      d_rawi<-as.data.frame(d_rawi)
      d_rawi<-lapply(d_rawi,as.character)
      d_rawi<-as.data.frame(d_rawi,stringsAsFactors=FALSE,check.names=FALSE)
      
      #Recode 'n/a' to 'NA'
       for (kl in 1:ncol(d_rawi)){
         d_rawi[,kl]<-ifelse(d_rawi[,kl]=="n/a",NA,d_rawi[,kl])
       }
      #write to csv
      #save file name
      savefile <- paste0("./Data/01_Download_CSV/",d_formlist_csv$id_string[i],"_", d_formlist_csv$id[i],"_data.csv")
      write_csv(d_rawi,savefile)
      #save as xlsx
      d_rawi[is.na(d_rawi)] <- 'NA'
      savefile_xlsx <- paste0("./Data/01_Download_CSV/",d_formlist_csv$id_string[i],"_", d_formlist_csv$id[i],"_data.xlsx")
      #write.xlsx2(as.data.frame(d_rawi),savefile_xlsx,sheetName = "data",row.names = FALSE)
      openxlsx::write.xlsx(d_rawi,savefile_xlsx,sheetName="data",row.names=FALSE)
  }
}




