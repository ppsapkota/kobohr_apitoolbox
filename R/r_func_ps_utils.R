#------------HR.info----KoBo data Access-------
'----------------------------------------------
Developed by: Punya Prasad Sapkota
Last Modified: 11 July 2017
-----------------------------------------------'

#merging multiple files in a a folder
files_merge_csv = function(mypath){
  #mypath <- datawd_csv
  filenames=list.files(path=mypath, full.names=TRUE, pattern = "*.csv")
  all_files <- lapply(filenames, function(x) {read.csv(x,na="n/a",encoding = "UTF-8", colClasses=c("character"), check.names = FALSE)})
  all_files_merged <-Reduce(bind_rows,all_files)
  #returns the merged dataframe
  return(all_files_merged)
}
#---------------------------------------------------------#
files_merge_xlsx = function(mypath){
  #mypath <- datawd_csv
  filenames=list.files(path=mypath, full.names=TRUE, pattern = "*.xlsx")
  all_files <- lapply(filenames, function(x) {read_excel(x,sheet=1,col_types = "text")})
  all_files_merged <-Reduce(bind_rows,all_files)
  #returns the merged dataframe
  return(all_files_merged)
}





#----------Export XLSX2CSV -------------#
readXLSXwriteCSV<-function(fname){
  dbc<-read_excel(fname, sheet = 1,col_types ="text")
  fname_csv = gsub("\\.xlsx","\\.csv",fname)
  #-----create file path in 'CSV' folder-----
  fname_csv = gsub(basename(fname_csv),paste0("CSV/",basename(fname_csv)),fname_csv)
  write.csv(dbc,file=fname_csv, fileEncoding = "UTF-8",row.names = FALSE)
}

#----------Export CSV2XLSX -------------#
readCSVwriteXLSX<-function(fname){
  dbc<-read.csv(fname,na="n/a",encoding = "UTF-8", colClasses=c("character"), check.names = FALSE)
  #dbc<-read_csv(fname, col_types="text")
  fname_xlsx = gsub("\\.csv","\\.xlsx",fname)
  #-----create file path in 'CSV' folder-----
  #fname_xlsx = gsub(basename(fname_xlsx),paste0("XLSX/",basename(fname_xlsx)),fname_xlsx)
  #write.xlsx2(dbc,file=fname_xlsx, row.names = FALSE)
  
  #--open xlsx--
   openxlsx::write.xlsx(x=dbc,file=fname_xlsx,sheetName ="data")
   #
   # wb<-openxlsx::createWorkbook()
   # openxlsx::addWorksheet(wb, "data")
   # openxlsx::writeData(wb, sheet=1, x=dbc, rowNames = FALSE)
   # openxlsx::saveWorkbook(wb, file =fname_xlsx, overwrite = TRUE)
  #Write slow process
  #write_big.xlsx2(dbc,fname_xlsx,"data")
  }

#create roundup function	
round2 = function(x, n) {
  posneg = sign(x)
  z = abs(x)*10^n
  z = z + 0.5   
  z = trunc(z)
  z = z/10^n
  z*posneg
}	

#Another rounding function
round3 <- function(x) {trunc(x+sign(x)*0.5)}

#Always rounding up
round_up<-function(x){ceiling(x)}

#Always rounding up 2.63 -> 2.7
# ceiling_dec <- function(x, level=0) {round(x + 5*10^(-level-1), level)}

#function coerce to numbers
conv_num<-function(x){as.numeric(as.character(x))}

### write big excel
write_big.xlsx2<-function(db,filen,sheetname){
  wb<- createWorkbook(type="xlsx")
  sheet <- createSheet(wb, sheetName=sheetname)
  
  print(paste0("Writing ", nrow(db), " records"))
  
  # Add the first data frame
  addDataFrame(db[1,], sheet, col.names=TRUE,row.names = FALSE, startRow=1, startColumn=1)
  start_row = 3 #including header and first data record 
  for (i in 2:nrow(db)) {
    addDataFrame(db[i,], sheet=sheet, row.names=FALSE, col.names=FALSE, startRow=start_row)
    start_row = start_row + 1
  }
  saveWorkbook(wb, filen)
}



#fields to remove
remove_fields<-function(db, rm_list){
  for (i in 1:nrow(rm_list)){
    i_vname<-rm_list[i,1]
    ind<-which(names(db)==i_vname)
    if (length(ind)>0){
      db<-select_(db,-ind)
    }
  }
  return(db)
}
NULL



# df %>%
#   group_by(group) %>%
#   summarise(text=paste(text,collapse=''))

