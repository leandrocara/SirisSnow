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
dir.mod <- d1[5,2]#"/home/servermod/modis/mod/"
dir.mod.c <- d1[6,2]#"/home/servermod/modis/c_mod/"
dir.mbase <- d1[7,2]#"/home/servermod/modis/mod10base"
#myd   ##############################################################
dir.myd <- d1[8,2]#"/home/servermod/modis/myd/"
dir.myd.c <- d1[9,2]#"/home/Dropbox/tesis/servermod/modis/c_myd/"
dir.mybase <- d1[10,2]#"/home/Dropbox/tesis/servermod/modis/myd10base"
#   ##############################################################
dir.mod.myd.max  <- d1[15,2]#"/home/lean/Dropbox/tesis/servermod/modis/mod10base"
dir.mod.myd.min  <- d1[16,2]#"/home/lean/Dropbox/tesis/servermod/modis/mod10base"
dir.mod.myd  <- d1[13,2]#"/home/lean/Dropbox/tesis/servermod/modis/mod10base"
#   ##############################################################
ficheros <- c(dir.mod,dir.mod.c,dir.myd,dir.myd.c,dir.mod.myd.max,dir.mod.myd.min,dir.mod.myd)
fecha1<- d1[12,2] # sale de mod-tap

e1<- tail(corte.x(list.files(fecha1)),n=1)

#### borra toda la información de modis previamente descargada y no procesada!

for( i in c(dir.mbase,dir.mybase)){
  if(length(list.files(i))>0){
    unlink(paste0(i,"*.*"))
  }
}

# i <- dir.mod.c
for( i in ficheros){
  x <- list.files(pattern = ".tif$",i)
  cat(paste0("Imágenes leídas para ", i, ":\n"))
  print(length(x))
  ### deja la última imagen!
  x<- x[c((length(x)-1):length(x))]
  
  ### acá habría que corregir para que no haga esto por mas de un mes!
  ### busca en cada fichero que exista información más nueva que la 
  ### que tiene mod_tap
  
  if(length(x[which(corte.x(x)>e1)])>=1){
  cat("\n")
  cat(paste("archivos procesados con error previamente para",i," \n"))
  cat(x[which(corte.x(x)>e1)])
  unlink(paste0(i,x[which(corte.x(x)>e1)]))
  if(any(grepl("NA",x))){
    cat(x[grepl("NA",x)])
      unlink(paste0(i,x[grepl("NA",x)]))
  }
  cat("\n")
  }
  cat("\n")
  cat("\n")
  }

fecha1 <- jd2date(corte.x(tail(list.files(fecha1),n=1))) # último día de mod-tap
# seq hasta la actualidad!
fecha1<- seq.Date(as.Date(fecha1)+1,as.Date(format(Sys.Date(),"%Y-%m-%d")),by = "day") 
# seq +1 hasta la actualidad!
fecha2 <- seq.Date(fecha1[2],as.Date(format(Sys.Date(),"%Y-%m-%d")),by = "day")

write.table(as.data.frame(fecha1),d1[2,2],col.names = F,row.names = F,quote = F)
write.table(as.data.frame(fecha2),d1[3,2],col.names = F,row.names = F,quote = F)
