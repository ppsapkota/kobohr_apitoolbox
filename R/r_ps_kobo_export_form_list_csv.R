#----export KoBo form list-----------
'----
Developed by: Punya Prasad Sapkota
Last modified: 11 July 2017
----'


#load libraries and additional functions from r_ps_kobo_library_init.R

#-----------export formlist in CSV format----------------
csv_link <- "https://kc.humanitarianresponse.info/api/v1/data.csv"
save_fname <- paste0("./Data/","formlist_csv.csv")
d_formlist_csv<-kobohr_getforms_csv(csv_link,kobo_user,Kobo_pw)
d_formlist_csv<-as.data.frame(d_formlist_csv)
d_formlist_csv$download<-"Yes"
#write_csv(d_formlist_csv,save_fname)
#export filename as XLSX
save_fname_xlsx<-paste0("./Data/",kobo_user,"_formlist.xlsx")
openxlsx::write.xlsx(d_formlist_csv,save_fname_xlsx,sheetName = "formlist",row.names = FALSE)


