###### crea la lista de tiles que vamos a descargar para armar luego la serie de imágenes
### se ejecuta desde el directorio de base de los scripts
### depende de un archivo de entrada, que lo toma desde .dir
### Leandro Cara 
## leandrocara@hotmail.com  
### 20 de Octubre de 2021
library(raster)
##############################################################
direcciones<- read.table("./.dir.txt",sep = ",",stringsAsFactors = F)
x <- shapefile(direcciones[7,2])#"~/Grilla modis sudamérica"
tabla <- read.csv(direcciones[8,2],header = F)#"~/corners_sudam.csv",header = F)

y <- shapefile(direcciones[9,2])#"~/AOI_wgs84_sur.shp")

z<- intersect(x,y)
tabla <- tabla[grepl(paste(z@data$name,collapse = "|"),tabla[,1]),]
write.table(tabla[,2:5],"./.tiles.txt",sep=",",col.names = F,row.names = F)
