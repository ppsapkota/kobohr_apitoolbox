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
#---NOT WORKING---ONCE sorted out change to function------------
result<-httr::POST(url=kpi_url,
                    body=list(
                      file=upload_file(path=kobo_form_xlsx)
                      ),
                      authenticate(kobo_user,Kobo_pw)
                  )
d_content <- rawToChar(result$content)
print (d_content)
d_content <- fromJSON(d_content)

# postForm(uri="https://xxx.YYYY/upload",
#          file = fileUpload(
#                 filename =  outfilename, contentType = 'text/txt'),
#                 add_headers(Authorization=paste0("Bearer ",btoken$access_token)
#                             )
#          )


# httpheader <- c(Authorization=paste0("Bearer ",btoken$access_token))
# status<-postForm(uri=paste0(server,"upload"),
#                  file = fileUpload(filename =  outfilename),
#                  .opts=list(httpheader=httpheader)
#                  )

# result<-  postForm(uri=kpi_url,
#                    file=fileUpload(filename=kobo_form_xlsx),
#                    .opts=list(authenticate(kobo_user,Kobo_pw))
#                   )
# d_content <- rawToChar(result$content)
# print (d_content)
