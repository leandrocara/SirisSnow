rm(list = ls())
suppressMessages(library(raster))
args = commandArgs(trailingOnly=TRUE)
  ##

########################### testing ##########################################
 setwd("/home/lean/CONICET/REPOS/tesis/Daemons/servermod//")
 args[1]<- "./MOD10A1.A2019261.tif"
 args[2] <- "/home/lean/CONICET/REPOS/Image_procesing/setup/support/aoi/aoi.shp"
 args[3]  <- "/home/lean/DATASETS/modis/"
####################################################################

img   <- args[1]
polig <- args[2]
fsc   <- args[3]

### Acá es la primera vez que voy a usar el directorio datasets. 
options(warn = -1)

corte.x <- function(x,inic=10,fin=16,corte=T,pattern="/"){
  while(grepl(pattern,x[1])){
  x<- substr(x,grep(pattern,x[1])+1,nchar(x))}
  if(corte)x <- substr(x,inic,fin)
  return(x)
}
#### en esta función voy a comparar el número de tiles en los que tengo información de 


if(grepl("MOD",img)){
fsc <- paste0(fsc,"modfsc/",corte.x(img,corte = F))
} else if (grepl("MYD",img)){
fsc <- paste0(fsc,"mydfsc/",corte.x(img,corte = F))
}else{
  print("Error en el nombre del mosaico")
  break()
}

##### acá usa una base que ya se ha creado! 
#### lo primero que debería hacer es crear esta base
#### como ya voy a haber arrancado, voy a crear la base como si se hubiera creado
#### primero tengo que cortar la imagen en función de si es un tif o un shape
#### si acá tengo info anterior, debería tener en cuenta eso y no el shape!

nuevo <- F
tmp <- nrow(read.table("../support/.tiles.txt"))-(length(list.files(pattern = ".tif$"))-1)
if (length(list.files(paste0(args[3],"mod_myd/"),pattern = "*.tif"))>0){
nuevo <- T
base <- raster(list.files(paste0(args[3],"mod_myd/"),pattern = "*.tif",full.names = T)[1])*0
img <- crop(raster(img),base)
}else{
img <- crop(raster(img),shapefile(polig))
}

if(tmp>=1){
  cat("\n Less images downloaded than tile size\n")
  cat(paste("\n Number of images for this day: ",length(list.files(pattern = ".tif$"))-1,"\n" ))
  cat("\n Filling gaps with no data \n")
    mtap_base <- raster("../support/modtap_base.tif")+255
    img <- resample(img,mtap_base)
    fsc <- paste0(gsub(".tif","",fsc),".N",sprintf("%02d",length(list.files(pattern = ".tif$"))-1),".tif")
  }

if (nuevo){
  cat("\n Updating MxD Fractional Snow Cover\n\n")
  # ##### solo por ahora
  # if(extent(base)!=extent(base)){ 
  #   img<- resample(img,base,method="ngb")
  # }
  img <- img+base
}else{
  cat("\n Building MCD Fractional Snow Cover\n\n")
  img <- mask(img,shapefile(polig))
}

writeRaster(img,fsc,format="GTiff", overwrite=TRUE, datatype='INT1U')
  


