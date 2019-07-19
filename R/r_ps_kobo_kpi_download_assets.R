getOption("encoding")
Sys.getlocale("LC_ALL")

kobo_server_url<-"https://kobo.humanitarianresponse.info/"

save_path<-paste0("./Data/",kobo_user,"_assetlist.xlsx")

asset_list<-kobohr_kpi_get_asset_list(kobo_server_url, kobo_user,Kobo_pw)

#FILTER Active project only
asset_list<-filter(asset_list, deployment__active==TRUE | deployment__active==1)
asset_list$download<-"YES"


openxlsx::write.xlsx(asset_list,save_path,sheetName="data",row.names=FALSE)
