mod.tap.series.full <- function(){
  cat("\nGenerando cada una de las imágenes MOD-TAP\n")
  bNA<- as.matrix(data.frame(col1=c(2,NA,0,1),col2=c(1,1,0,0)))
  b0<- as.matrix(data.frame(col1=c(0,2,NA,1),col2=c(1,0,0,0)))
  b1<- as.matrix(data.frame(col1=c(1,2,NA,0),col2=c(1,0,0,0)))
  na20 <- as.matrix(data.frame(col1=c(2,NA),col2=c(0,0)))
  cero2na <- as.matrix(data.frame(col1=c(0,NA),col2=c(2,2)))
  na2na <- as.matrix(data.frame(col1=c(NA),col2=c(2)))
  l1 <- list(bNA,b0,b1)
  
  base <-  list.files(dir.mod.tap,pattern = ".tif$",full.names = T)
  base<- raster(base[length(base)])
  
  cat(paste0("\n Imagen de base a ser utilizada: ", names(base)))
   
  cat(paste0("\n Imagen a procesar: ",lmodmyd[1],"\n"))
  
for( i in 1:length(lmodmyd)){
  x <- raster(f.1(lmodmyd[i],dir.mod.myd))
  y <- rcl(x,l1[[1]])
  base <- ((base*y)+rcl(x,na20))
  writeRaster(base,paste(dir.mod.tap,"/MOD_TAP.A",corte(lmodmyd[i]),".snow.tif"
                         ,sep=""),format="GTiff", overwrite=T,datatype="INT1U")
  
}
  cat("Proceso MOD-TAP Finalizazo\n")
}
