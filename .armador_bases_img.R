#### Leandro Cara 
#### leandrocara@hotmail.com  
### 26/10/2021
#### este script arma las bases del sistema 


cat("Corriendo el proceso para armar la imagen de base \n")


rm(list = ls())
suppressMessages(library("raster"))
### de acá debería salir la mod y la c.mod nada más!
rutas <- read.table("./.dir.txt",sep = ",",stringsAsFactors = F)
nomb_modis <- read.table("./apoyo/nombres_base_modis.txt",sep = ",",stringsAsFactors = F)
modtap <-  paste0(nomb_modis[5,1],nomb_modis[5,2])

rcl <- function(x,y){reclassify(x, y, include.lowest=FALSE, right=NA)}
apoyo <- paste0(rutas[14,2],"mascara_comp.tif")
NA20 <-as.matrix(data.frame(d1=c(NA,seq(1,255)), d2=0))

#mod   ##############################################################
dir.mbase <- rutas[7,2]#"/home/lean/Dropbox/tesis/servermod/modis/mod10base"
x<- list.files(dir.mbase,full.names = T)
base <- raster(x[1])
ext_error <- vector()
y <- shapefile("/home/lean/CONAE/SirisSnow/apoyo/AOI_wgs84_sur.shp")
for( i in 2:length(x))    base <- extend(base,raster(x[i]))
cat(paste0("Corriendo el proceso de armado de base. N° de iteracicón: ",i,"\n"))
base <- crop (base,y)
base <- rcl(base,NA20)
#### hasta acá tenemos armada la base!!!
writeRaster(base,filename = apoyo,format="GTiff",datatype="INT1U")
### tengo que hacer la base para modtap
writeRaster(base,filename = modtap,format="GTiff",datatype="INT1U")
unlink(x)
print("Proceso de armado de base finalizado!")
