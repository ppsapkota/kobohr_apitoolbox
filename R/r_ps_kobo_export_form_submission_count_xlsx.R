#----export KoBo form submission count per form-----------
'----
Developed by: Punya Prasad Sapkota
Last modified: 27 July 2017
----'

#load libraries and additional functions from r_ps_kobo_library_init.R

#-----------export formlist in XLSX format----------------
csv_link<-'https://kc.humanitarianresponse.info/api/v1/forms.csv'
save_fname <- paste0("./data/",kobo_user,"_formlist_details.xlsx")
d_formlist<-kobohr_getforms_csv(csv_link,kobo_user,Kobo_pw)
write.xlsx(d_formlist,save_fname,sheetName = "formlist")


