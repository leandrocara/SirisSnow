  ####
#### Genera un archivo tabular con las fechas de las imágenes que deben ser descargadas 
#### Leandro Cara
#### Octubre 2021
#### leandrocara@hotmail.com

############################################
# d1<- read.table("/home/leandro/server/servermod/dir.txt",sep = ",",stringsAsFactors = F)
# setwd("/home/lean/CONICET/REPOS/tesis/Daemons/servermod/")
d1<- read.table("./.dir.txt",sep = ",",stringsAsFactors = F)

funciones<- list.files(path = "./f_apoyo/",pattern = ".R$",full.names = T)
for (i in 1:length(funciones)) 
  source (chdir =T ,file = funciones[i])


#mod   ##############################################################
dir.mod.tap  <-   paste0(d1[5,2],"/mod_tap/")
dir.mod  <-   paste0(d1[5,2],"/mod/")
dir.mod.c  <- paste0(d1[5,2],"/c_mod/")
dir.mbase <-  paste0(d1[5,2],"/mod10base/")

#myd   ##############################################################
dir.myd  <- paste0(d1[5,2],"/myd/")
dir.myd.c  <- paste0(d1[5,2],"/c_myd/")
dir.mybase<- paste0(d1[5,2],"/myd10base/")

#mod myd combinados ##############################################################
dir.mod.myd.max <- paste0(d1[5,2],"/c_mod_myd_max/")  
dir.mod.myd.min <- paste0(d1[5,2],"/c_mod_myd_min/")
dir.mod.myd  <- paste0(d1[5,2],"/mod_myd/")
#   ##############################################################
ficheros <- c(dir.mod,dir.mod.c,dir.myd,dir.myd.c,dir.mod.myd.max,dir.mod.myd.min,dir.mod.myd)
dir.mod.tap

fecha_modtap_last<- tail(corte.x(list.files(dir.mod.tap)),n=1)

#### borra toda la información de modis previamente descargada y no procesada!
for( i in c(dir.mbase,dir.mybase)){
  if(length(list.files(i))>0){
    unlink(paste0(i,"*.*"))
  }
}


for( i in ficheros){
  x <- list.files(pattern = ".tif$",i)
  ### no debería pasar peeeeero
  if(any(grepl("NA",x))){
    cat(x[grepl("NA",x)])
      unlink(paste0(i,x[grepl("NA",x)]))
  }
  x<- x[which(corte.x(x)>fecha_modtap_last)]
  if(length(x)>=1){
  cat(paste("Existen archivos procesados con error previamente para",i," \n"))
  cat(x)
  unlink(x)
  cat("\n")
  }
  cat("\n")
  cat("\n")
  }

fecha1 <- jd2date(fecha_modtap_last) # último día de mod-tap
# seq hasta la actualidad!
fecha1<- seq.Date(as.Date(fecha1)+1,as.Date(format(Sys.Date(),"%Y-%m-%d")),by = "day") 
# seq +1 hasta la actualidad!
fecha2 <- seq.Date(fecha1[2],as.Date(format(Sys.Date(),"%Y-%m-%d")),by = "day")

write.table(as.data.frame(fecha1),d1[2,2],col.names = F,row.names = F,quote = F)
write.table(as.data.frame(fecha2),d1[3,2],col.names = F,row.names = F,quote = F)
