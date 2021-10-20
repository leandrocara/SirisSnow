

### pregunta año biciesto
faltantes <- function(x=c(),pos=c(),djul=F,verbose=T,lab="missing.tif"){

  #    FECHA DE CREACIÓN: 19 de Noviembre de 2014
  #    AUTOR: Leandro Cara
  #    DESCRIPCIÓN  : En una tirada de datos de MODIS para bajar de eos, obtiene los años de las imágenes a descargar, cuantas 
  #    imágenes por año se tienen, cual es la primera y cual es la última imágen para descargar, y QUE IMÁGENES NO SE ENCUENTRAN EN
  #    LA SECUENCIA.
  #    ARGUMENTOS: 
  # x    = El objeto a analizar, este puede ser una matriz en la cual se va a analizar solo la primera columna, o un vector
  # pos  = es la posición dentro de la cadena de texto en la cual se debe comenzar a leer la fecha estructurada como año yyyy, 
  # día juliano ddd. La cadena será analizada como yyyyddd
  # djul = si el resultado de imagenes faltantes debe ser entregado como fecha gregoriana o día juliano anual.
  
  
  library(chron)
# #   ############################# Variables de prueba
# 
#   x <- list.files(path=paste(startdir,"MOD10A1", sep="/"),pattern=".tif")  
#   pos=10
#   djul <- T
#   verbose=T
# ##########################################
x <- as.data.frame(x)
  x[,1] <- as.character(x[,1])  
nombres <- as.vector(x[,1])
  
  if(length(pos)==1){
    
    ### Armo una tabla con la pirmer columna de año y la segunda dia juliano, parto de los nombres
    img1 <- data.frame(year=as.numeric(substr(x[,1],pos,pos+3)),d_jul= as.numeric(substr(x[,1],pos+4,pos+6)))
    # saco la primera y última imagen de la serie
    img<- rbind(img1[1,],img1[length(img1[,1]),])
    # separo la primer tabla por año y los pongo separados en una lista
    img1<- split(img1,as.factor(img1$year))
    # obtengo un vector con los años  
    year <- seq(img[1,1],img[2,1])
    pr.1 <- data.frame()
  # para cada año
  for (i in 1:length(year)){
    # calculo si es año juliano
    if((year[i]/4==round(year[i]/4))&
       ((year[i]/100!=round(year[i]/100))|(year[i]/400==round(year[i]/400)))){
      y <- 366
    }else{
      y <- 365
    }
    # armo una tabla donde pongo para cada año el inicio y el fin
    # teniendo en cuenta si es el primer/último dato de la serie
    pr.1[i,1] <- year[i]
    ### dia inicio
    if(i==1){ 
      pr.1[i,2] <- img[1,2]
    }else{
      pr.1[i,2] <- 1
    }
    ### dia fin
    if(i==length(year)){ 
      pr.1[i,3] <- img[2,2]
    }else{
      pr.1[i,3] <- y
    }
  }
    # termina la tabla
    
    y <- data.frame()
    # para cada año 
    for (i in 1:length(pr.1[,1])){
      # armo una secuencia del primer al último día del año sacados de la tabla anterior 
      x <- seq(pr.1[i,2],pr.1[i,3])
      ## genero una nueva tabla con dos campos | año | día juliano -> este sale de la secuencia ant.
      y<-rbind(y,merge(year[i],x))
    }
    
    # serie completa
    # split a y
    a<- split(y,as.factor(y$x))
    
    ## completa con NA los días en que tengo escenas faltantes!!!!
    for (i in 1:length(a)){
      a[[i]][(match(img1[[i]][,2],a[[i]][,2])),3] <-img1[[i]][,2] 
    }
    # transforma la lista a tabla
    tabla <- data.frame()
    for(z in 1:length(a)) tabla <- rbind(tabla,a[[z]])
    
    # saca de la tabla una nueva tabla con los valores faltantes
      faltantes<- tabla[is.na(tabla[,3]),c(1,2)]
    # verifico si no hay valores faltantes: puede ser por dos motivos 
    # que esté completa la serie o que haya sido rellenada. buscaremos entonces 
    # la etiqueta "lab"
    
      if(length(faltantes$x)==0 & !any(grepl(lab,nombres))){
        if(verbose)  print("serie completa")
        faltantes <- NULL
      }else if (length(faltantes$x)==0 & any(grepl(lab,nombres))){
        if(verbose)  print("serie rellenada")
        faltantes <- jd2date(substr(nombres[grepl(lab,nombres)],pos,pos+6))
      }else{
        if(verbose)   print("serie incompleta")
        faltantes$comparador<- paste(faltantes[,1],sprintf("%03d",faltantes[,2]),sep = "")
        faltantes$fecha<- jd2date(paste(faltantes[,1],sprintf("%03d",faltantes[,2]),sep = ""))
      }
  
    return(faltantes)
    }else{  print("Falta posicición de inicio de fecha"); print("Se define con el argumento pos")}
}
