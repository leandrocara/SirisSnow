    
rm(list = ls())
suppressMessages(library(raster))
suppressMessages(library(rgdal))
suppressMessages(library(sp))



rutas <- read.table("./.dir.txt",sep = ",",stringsAsFactors = F)
apoyo <- paste0(rutas[5,2],"mascara_comp.tif")
#mod   ##############################################################
dir.mod  <- paste0(rutas[3,2],"/mod") 
dir.mod.c <- paste0(rutas[3,2],"/c_mod")
#myd   ##############################################################
dir.myd <- paste0(rutas[3,2],"/myd")
dir.myd.c <- paste0(rutas[3,2],"/c_myd")
# combinadas ##############################################################
dir.mod.myd <- paste0(rutas[3,2],"/mod_myd")
dir.mod.myd.c.max <-  paste0(rutas[3,2],"/c_mod_myd_max")
dir.mod.myd.c.min <-paste0(rutas[3,2],"/c_mod_myd_min")
dir.mod.tap  <- paste0(rutas[3,2],"/mod_tap")
#   ##############################################################
fun.dir <- rutas[4,2]
pos <- 10
#######################################################################
### matrices para armar las imágenes de nubes y nieve rellenadas
bool.clouds <- as.matrix(data.frame(col1=c(2,0,1),col2=c(1,0,0)))
dos20 <- as.matrix(data.frame(col1=c(2),col2=c(0)))
bNA <- as.matrix(data.frame(col1=c(2,NA,0,1),col2=c(1,1,0,0)))
na20 <- as.matrix(data.frame(col1=c(2,NA),col2=c(0,0)))

#######################################################################
funciones<- list.files(path = fun.dir,pattern = ".R$",full.names = T)
for (i in 1:length(funciones)) source (chdir =T ,file = funciones[i])
#######################################################################
cat("\n Comenzando el prrocesamiento de los mosaicos TIF\n\n")

#################################################### 
cat("\nProcesamiento de SCA y CCA Para MOD10A1 y MYD10A1:\n")

##
lmod <- list.files(path=dir.mod,pattern = ".tif$")
lmyd <- list.files(path=dir.myd,pattern = ".tif$")
##############
# acá vamos a poner una cláusula para achicar los lmxd..

##############

##############
#### última fecha lmod_tap procesada!
lmod_tap <- list.files(path = dir.mod.tap,pattern = ".tif$")

### el día siguiente a la última fecha mod-tap procesada
mod_tap <- lmod_tap[length(lmod_tap)]
lmod_tap <- jd2date(corte(lmod_tap[length(lmod_tap)]))
## watch dog (if the next image to procces is less than 4 days to actual date)
wd <-(as.Date(format(Sys.time(), "%Y-%m-%d"))-lmod_tap<=4)
lmod_tap <- date2jd(lmod_tap+1)

##
lmod <- lmod[which(grepl(lmod_tap,lmod))]
lmyd <- lmyd[which(grepl(lmod_tap,lmyd))]

#### genero mod-myd para esta imagen

if(length(lmod)>0 & length(lmyd)>0){
# existen mod y myd
  cat(paste0("Creando: MOD.MYD.A",lmod_tap,".clouds.min/max.tif","\n","\n"))    
  #### Traigo  mxd / mxd.c
  mod <- raster(paste0(dir.mod,"/",lmod))
  c.mod <- raster(list.files(path =dir.mod.c, pattern = lmod_tap,full.names = T))
  myd <- raster(paste0(dir.myd,"/",lmyd))
  c.myd <- raster(list.files(path =dir.myd.c, pattern = lmod_tap,full.names = T))
  
  ##### clouds cover generation
  writeRaster(((c.mod+c.myd)-(c.mod*c.myd)),paste0(dir.mod.myd.c.max,"/MOD_MYD.A",lmod_tap,
  "_clouds_max.tif"),format="GTiff", overwrite=T,datatype="INT1U")
  writeRaster(c.mod*c.myd,paste(dir.mod.myd.c.min,"/MOD_MYD.A",lmod_tap,"_clouds_min.tif",sep=""),
              format="GTiff", overwrite=T,datatype="INT1U")
  ##### snow cover generation
    cat(paste0("Creando: MOD_MYD.A",lmod_tap,"_snow_cover_area.tif","\n","\n"))
    #
    mask.mod <-  rcl(mod, bool.clouds)
    mod.myd <- mask.mod*myd
    mod.myd <- rcl(mod,dos20) + mod.myd
    writeRaster(mod.myd,paste(dir.mod.myd,"/MOD_MYD.A",lmod_tap,
    "_snow_cover_area.tif",sep=""),format="GTiff", overwrite=T,datatype='INT1U')

}else if(length(lmod)>0){
  ## solo existe MOD
  ### CCA 
  mod <- raster(paste0(dir.mod,"/",lmod))
  c.mod <- raster(list.files(path =dir.mod.c, pattern = lmod_tap,full.names = T))
  cat(paste0("Creando: MOD.MYD.A",lmod_tap,".MOD.clouds.max.tif","\n","\n"))  
  
  writeRaster(c.mod,paste0(dir.mod.myd.c.max,"/MOD_MYD.A",lmod_tap,
                          "_MOD_clouds_max.tif"),format="GTiff", overwrite=T)
##### SCA 
    cat(paste0("MOD.MYD.A",lmod_tap,".MOD.snow.cover.area.tif\n\n"))
    writeRaster(mod,paste0(dir.mod.myd,"/MOD_MYD.A",lmod_tap,"_MOD_snow_cover_area.tif"),
                format="GTiff", overwrite=T, datatype='INT1U')
    
}else if(length(lmyd)>0){
# solo existe myd  
  ### CCA 
  myd <- raster(paste0(dir.myd,"/",lmyd))
  c.myd <- raster(list.files(path =dir.myd.c, pattern = lmod_tap,full.names = T))
  cat(paste0("Creando: MOD.MYD.A",lmod_tap,".MYD.clouds.max.tif","\n","\n"))  
  
  writeRaster(c.myd,paste0(dir.mod.myd.c.max,"/MOD_MYD.A",lmod_tap,
                          "_MYD_clouds_max.tif"),format="GTiff", overwrite=T)
##### SCA 
    cat(paste0("MOD.MYD.A",lmod_tap,".MYD.snow.cover.area.tif\n\n"))
    writeRaster(myd,paste0(dir.mod.myd,"/MOD_MYD.A",lmod_tap,"_MYD_snow_cover_area.tif"),
                format="GTiff", overwrite=T, datatype='INT1U')
    
}else{
### si no existe ninguna de las imágenes no se genera nada!
  if(wd){
    cat("no hay imágenes nuevas para esta fecha!")
    quit(save = "no",status = 1)
    }
}


base<- raster(paste0(dir.mod.tap,"/",mod_tap))
mod.myd_base <- list.files(dir.mod.myd)
### tomo la última información de mod.myd.base que se haya generado!!!
mod.myd_base <- mod.myd_base[length(mod.myd_base)]

x <- raster(paste0(dir.mod.myd,"/",mod.myd_base))
y <- rcl(x,bNA)
base <- ((base*y)+rcl(x,na20))

if(as.numeric(corte(mod.myd_base))<=as.numeric(corte(mod_tap))){
  cat("No se ha generado información nueva para crear MOD TAP\n
      Pero hay más de 4 días de información faltante")
cat(paste0("imagen de base utilizada:",mod_tap,"\n
          imagen a procesar:",mod.myd_base[length(mod.myd_base)],"\n
          imagen a generar:","/MOD_TAP.A",lmod_tap,"_MISSING_mod_myd_snow"))

  writeRaster(base,paste0(dir.mod.tap,"/MOD_TAP.A",lmod_tap,"_MISSING_mod_myd_snow.tif"),
              format="GTiff", overwrite=T,datatype="INT1U")
  
}else{
cat(paste0("\n Imagen a procesar: ",mod.myd_base,"\n"))
cat(paste0("\n Imagen de base a ser utilizada: ", mod_tap))

  writeRaster(base,paste(dir.mod.tap,"/MOD_TAP.A",lmod_tap,"_snow.tif"
                       ,sep=""),format="GTiff", overwrite=T,datatype="INT1U")
  
}

cat("Proceso MOD-TAP Finalizado\n")


