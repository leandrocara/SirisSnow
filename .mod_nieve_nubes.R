rm(list = ls())
suppressMessages(library("raster"))
### de acá debería salir la mod y la c.mod nada más!
rutas <- read.table("./.dir.txt",sep = ",",stringsAsFactors = F)

### solo resume reclassify
rcl <- function(x,y){reclassify(x, y, include.lowest=FALSE, right=NA)}

apoyo <- paste0(rutas[5,2],"mascara_comp.tif")
#mod   ##############################################################
dir.mbase <- paste0(rutas[3,2],"/mod10base")#"/home/lean/Dropbox/tesis/servermod/modis/mod10base"
dir.mod  <- paste0(rutas[3,2],"/mod") #"/home/lean/Dropbox/tesis/servermod/modis/mod/"
dir.mod.c <- paste0(rutas[3,2],"/c_mod")#"/home/lean/Dropbox/tesis/servermod/modis/c_mod/"
dir.mod.fsc <-  paste0(rutas[3,2],"/mod_fsc")#"/home/lean/Dropbox/tesis/servermod/modis/mod_fsc/"

#myd   ##############################################################
dir.mybase <- paste0(rutas[3,2],"/myd10base")#"/home/lean/Dropbox/tesis/servermod/modis/myd10base"
dir.myd <- paste0(rutas[3,2],"/myd")#"/home/lean/Dropbox/tesis/servermod/modis/myd/"
dir.myd.c <- paste0(rutas[3,2],"/c_myd")#"/home/lean/Dropbox/tesis/servermod/modis/c_myd/"
dir.myd.fsc <- paste0(rutas[3,2],"/myd_fsc")#"/home/lean/Dropbox/tesis/servermod/modis/myd_fsc/"
#   ##############################################################

### levanto la fecha del producto a armar
## supone que si no está en mod está en myd
### chequeo la info que se encuentra en mbase
if(length(list.files(dir.mbase))>=1){ 
  p1 <- regexec("A[0-9]{6}",list.files(dir.mbase)[1])
  pp1 <- dir.mbase
}else{ 
  p1 <- regexec("A[0-9]{6}",list.files(dir.mybase)[1])
  pp1 <- dir.mybase
}
### levanta la fecha de las imágenes
p1 <- substr(list.files(pp1)[1],p1[[1]][1],p1[[1]][1]+7)
#   ##############################################################
# 0-40: Soil
# 40-100: snow cover
# 200: missing data
# 201: no decision
# 211: night
# 237: inland water
# 239: ocean
# 250: cloud
# 254: detector saturated
# 255: fill
#   ##############################################################

### lo primero que debo hacer es levantar las imágenes
## Variables temporales
### matríz para armar la imágenes de nubes
fsc.mosaic <- matrix(ncol=2,c(237,200,201,211,239,254,255,250,0,rep(NA,6),101))
FSC<- matrix(ncol = 2,data = c(-1,NA))
SCA <-as.matrix(data.frame(d1=c(-1,seq(1,101)), d2=c(2,rep(0,39),rep(1,61),2)))
CCA <-as.matrix(data.frame(d1=c(seq(-1,101)), d2=c(rep(0,102),1)))
# capa de apoyo!
cat("\n")
cat(" Comenzando el proceso de reclasificación de las imágenes \n Y armado del producto combinado MOD.MYD \n")
cat(" En este proceso se calculan además todos los productos de nubes \n")
cat("iniciando la serie MOD \n")
cat("\n")

### directorio de descarga de las imágenes mod!!!
# lmyd <- list.files(path = dir.mybase,pattern = "*.tif",full.names = T)
# lmod <- list.files(path = dir.mbase,pattern = "*.tif",full.names = T)
dir1<- c(dir.mbase,dir.mybase)
dir2<- c(dir.mod.c,dir.myd.c)
dir3<- c(dir.mod,dir.myd)
dir4<- c(dir.mod.fsc,dir.myd.fsc)
dir<- c(dir.mod,dir.myd)
mcd <- list()
mcdtipo <- c("MOD10A1","MYD10A1")
cat("Ingresando al procesamiento \n")

 for(m in 1:2){# m= mod y myd
cat(paste0("Comenzando a procesar ",mcdtipo[m],"\n"))
  lmod <- list.files(path = dir1[m],pattern = "*.tif$",full.names = T)
cat(paste0("Número de imágenes ",mcdtipo[m], ": ",length(lmod),"\n"))

  if(length(lmod)>=1){
  bse <- (raster(apoyo)*0)-1
  modfsc <- bse

  for(i in 1:length(lmod)){
    mod <- raster(lmod[i])
    xmod <- rcl(mod,fsc.mosaic)
    modfsc <- mosaic(resample(xmod,bse,method="ngb"),modfsc,fun=max)
    cat(paste0("paso ",i," completo\n"))
        }
   
### CCA
   writeRaster(rcl(modfsc,CCA),paste0(dir2[m],"/",mcdtipo[m],".",p1,"_Clouds_Cover_Area.tif"),
            format="GTiff", overwrite=T,datatype="INT1U")
### SCA 
writeRaster(rcl(modfsc,SCA),paste0(dir3[m],"/",mcdtipo[m],".",p1,"_Snow_Cover_Area.tif"),
            format="GTiff", overwrite=T,datatype="INT1U")
### FSC

writeRaster(rcl(modfsc,FSC),paste0(dir4[m],"/",mcdtipo[m],".",p1,"_Fractional_Snow_Cover_.tif"),
            format="GTiff", overwrite=T,datatype="INT1U")

# elimino los originales por ahora!!!
file.remove(lmod) 
}
  }

cat("\n")
# cat(paste0("Imagen ",p1," guardada para nieve y nubes\n"))}
cat("script mod_nieve_nubes.R finalizado correctamente\n")
cat("######################\n")


