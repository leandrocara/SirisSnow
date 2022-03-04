    
rm(list = ls())
suppressMessages(library(raster))
suppressMessages(library(rgdal))
suppressMessages(library(sp))

rutas <- read.table("./.dir.txt",sep = ",",stringsAsFactors = F)
apoyo <- paste0(rutas[5,2],"mascara_comp.tif")
#mod   ##############################################################
dir.mbase <- paste0(rutas[3,2],"/mod10base")
dir.mod  <- paste0(rutas[3,2],"/mod") 
dir.mod.c <- paste0(rutas[3,2],"/c_mod")
#myd   ##############################################################
dir.mybase <- paste0(rutas[3,2],"/myd10base")
dir.myd <- paste0(rutas[3,2],"/myd")
dir.myd.c <- paste0(rutas[3,2],"/c_myd")
#   ##############################################################
fun.dir <- rutas[4,2]
dir.mod.tap  <- paste0(rutas[3,2],"/mod_tap")
dir.mod.myd <- paste0(rutas[3,2],"/mod_myd")
dir.otros <- rutas[5,2]#"/home/lean/Dropbox/tesis/servermod/modis/apoyo/"

dir.mod.myd.c.max <-  paste0(rutas[3,2],"/c_mod_myd_max")
dir.mod.myd.c.min <-paste0(rutas[3,2],"/c_mod_myd_min")
pos <- 10


#######################################################################
funciones<- list.files(path = fun.dir,pattern = ".R$",full.names = T)
for (i in 1:length(funciones)) source (chdir =T ,file = funciones[i])
#######################################################################
cat("\n Comenzando el prrocesamiento de los mosaicos TIF\n")

cat("\n")
cat("#########\n")
cat("\n")

#################################################### 
cat("\nProcesamiento de SCA y CCA Para MOD10A1 y MYD10A1:\n")

lmod <- list.files(path=dir.mod,pattern = ".tif$")
# lmod <- lmod[(length(lmod)-30):length(lmod)]
lmyd <- list.files(path=dir.myd,pattern = ".tif$")
# lmyd <- lmyd[(length(lmyd)-30):length(lmyd)]
tpo1 <- reclas.v6(verbose = T)
### si no procesa ninguna imagen en mod.myd no pasa a mod.tap
if(length(tpo1[[1]])>0){
cat(paste0("\nprimera imágen MOD.MYD procesada: ",jd2date(min(as.numeric(tpo1[[1]]))),"\n"))
}else{ 
  cat("no se tienen imágenes para procesar a MOD-MYD hoy \n")
}

# ################################################### 
### LISTO TODAS LAS IMÁGENES MOD-TAP
lmodmyd <- list.files(path=dir.mod.myd,pattern = ".tif$")
### SI HE CREADO ALGUNA MOD.MYD ENTONCES PASO A PROCESAR MOD-TAP
if(length(tpo1[[1]])>0){
lmodmyd <- subset(lmodmyd,as.numeric(corte(lmodmyd))>=min(as.numeric(tpo1[[1]])))
tpo2 <- mod.tap.series.full()
}else{ 
  cat("no se tienen imágenes para procesar a MOD-TAP hoy \n")
}
cat("script mosaic_to_mxd_SCA_CCA.R terminado\n")
cat("######################################\n")
