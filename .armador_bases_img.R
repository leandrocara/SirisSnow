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
modtap <- paste0(rutas[3,2],"/mod_tap/",nomb_modis[5,2],".tif" )

rcl <- function(x,y){reclassify(x, y, include.lowest=FALSE, right=NA)}
apoyo <- "./apoyo/mascara_comp.tif" ### este archivo no existe todavía!
NA20 <-as.matrix(data.frame(d1=c(NA,seq(1,255)), d2=0))

#mod   ##############################################################
dir.mbase <- paste0(rutas[3,2],"/mod10base/" )#"/home/lean/Dropbox/tesis/servermod/modis/mod10base"
x<- list.files(dir.mbase,full.names = T)
base <- raster(x[1])
ext_error <- vector()
y <- shapefile(rutas[9,2])

for( i in 2:length(x)){
cat(paste0("Corriendo el proceso de armado de base. N° de iteracicón: ",i,"\n"))

base <- extend(base,raster(x[i]))
base <- crop (base,y)
base <- rcl(base,NA20)
}

#### hasta acá tenemos armada la base!!!
writeRaster(base,filename = apoyo,format="GTiff",datatype="INT1U",overwrite=T)
### tengo que hacer la base para modtap
writeRaster(base,filename = modtap,format="GTiff",datatype="INT1U",overwrite=T)
unlink(x)
print("Proceso de armado de base finalizado!")
