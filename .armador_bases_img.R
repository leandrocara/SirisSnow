rm(list = ls())
suppressMessages(library("raster"))
### de acá debería salir la mod y la c.mod nada más!
rutas <- read.table("./.dir.txt",sep = ",",stringsAsFactors = F)
args = commandArgs(trailingOnly=TRUE)

rcl <- function(x,y){reclassify(x, y, include.lowest=FALSE, right=NA)}
apoyo <- rutas[14,2]#"/home/lean/Dropbox/tesis/servermod/modis/apoyo/mascara_comp.tif"
apoyo <- paste0(apoyo,"mascara_comp.tif")

getwd()
#mod   ##############################################################
dir.mbase <- rutas[7,2]#"/home/lean/Dropbox/tesis/servermod/modis/mod10base"
x<- list.files(dir.mbase,full.names = T)
base <- raster(x[1])
library(raster)
for( i in 2:length(x)){
  base <- mosaic(base,raster(x[2]),fun=max)
}
y <- shapefile("/home/lean/CONAE/SirisSnow/apoyo/AOI_wgs84_sur.shp")
z <- mask(base,y)

plot(z)

dir.mod <- rutas[5,2]#"/home/lean/Dropbox/tesis/servermod/modis/mod/"
dir.mod.c <- rutas[6,2]#"/home/lean/Dropbox/tesis/servermod/modis/c_mod/"
dir.mod.fsc <- rutas[20,2]#"/home/lean/Dropbox/tesis/servermod/modis/mod_fsc/"
#myd   ##############################################################
dir.mybase <- rutas[10,2]#"/home/lean/Dropbox/tesis/servermod/modis/myd10base"
dir.myd <- rutas[8,2]#"/home/lean/Dropbox/tesis/servermod/modis/myd/"
dir.myd.c <- rutas[9,2]#"/home/lean/Dropbox/tesis/servermod/modis/c_myd/"
dir.myd.fsc <- rutas[21,2]#"/home/lean/Dropbox/tesis/servermod/modis/myd_fsc/"
#   ##############################################################
### chequeo la info que se encuentra en mbase
#### tengo que mergear base

bse <- (raster(apoyo)*0)-1

cat("\n")
cat(" Comenzando el proceso de reclasificación de las imágenes \n Y armado del producto combinado MOD.MYD \n")
cat(" En este proceso se calculan además todos los productos de nubes \n")
cat("iniciando la serie MOD \n")
cat("\n")


mcdtipo <- c("MOD10A1","MYD10A1")
cat("Ingresando al procesamiento \n")
 for(m in 1:2){# m= mod y myd
cat(paste0("Comenzando a procesar ",mcdtipo[m],"\n"))
  modfsc <- bse
  lmod <- list.files(path = dir1[m],pattern = "*.tif$",full.names = T)
cat(paste0("Número de imágenes ",mcdtipo[m], ": ",length(lmod),"\n"))

  if(length(lmod)>=1){

  for(i in 1:length(lmod)){
    ## llamo al raster
   
    
    modfsc <- mosaic(resample(xmod,bse,method="ngb"),modfsc,fun=max)
    cat(paste0("paso ",i," completo\n"))}
  }
   
### CCA
   writeRaster(rcl(modfsc,CCA),paste0(dir2[m],"/",mcdtipo[m],"_",p1,"_Clouds_Cover_Area.tif"),
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

cat("\n")
# cat(paste0("Imagen ",p1," guardada para nieve y nubes\n"))}
cat("script mod_nieve_nubes.R terminado\n")
cat("######################\n")
suppressMessages(file.remove(paste0(args[1],"/wdimg.txt")))

