

# Función para rellenar con imágenes de nubes las escenas faltantes.
# Lo único que voy a tomar es el directorio de trabajo donde tengo que revisar especificamente si tengo imágenes faltantes
# el valor por defecto de las nubes es 50
# todos los valores de la imágenes oscilan entre 0 y 255

dataFill <- function(x,pos=10,variante=NULL,lab="tif",verbose=T,relleno=0){
  
  #   # Función que rellena imágnes faltantes, encontradas en una serie por la función faltantes, (función recursiva ojo!!!)
  #       Argumentos:
  #         x= nombre de la subcarpeta donde se encuentran las imágenes
  #         path.out = donde se debe escribir la tabla de log
  #         pos= considerando la lista de imágenes,que todas poseen en una posición de su nombre el año y el día juliano juntos
  #               en que posición contando las letras se encuentra su inicio
  #         verbose= LOGICA, debe dar información de los procesos?
  
  # ############################### Vectores de prueba
  # x =dir.mod
  # verbose = T
  # lab = "missing.tif"
  # relleno=NA
  # djul=F
  # variante=NULL
  # # ############################################################
  d1 <- list()
  if(verbose==T){print("Función dataFill") 
  print(paste("Calculada para",x))}
  setwd(x)
  contador <- ifelse(is.null(variante),1,length(variante))
  
  y<- raster(list.files(x,pattern = ".tif")[1])
  rec <- as.matrix(data.frame(col1=pr(y),col2=rep(relleno,length(pr(y)))))
  y <- rcl(y,rec)
  
  for(VV in 1:contador){
  files.1 <- list.files(pattern=".tif$")
    if(!is.null(variante)){
      files.1 <- files.1[grepl(variante[VV],files.1)]  
    }
    
    # Reviso si hay imágenes faltantes.----
    fal <- faltantes(x=files.1,pos=pos,djul = T,verbose=verbose,lab=lab)
    
    # Una vez verificado que faltan imágenes las genero como una capa uniforme de nubes.----
    if(is.null(fal)){
      if(verbose==T) cat("la serie se enceuntra completa!!! \n")  
      d1[[VV]] <- "serie completa"
    }else if(class(fal)=="Date"){
      if(verbose==T){ cat("la serie ha sido rellenada previamente, los valores rellnados son los siguientes: \n")  
          cat("\n")
           print(fal)}
        d1[[VV]]<- as.character(fal)
      }else{
        
        m.img<- paste(substr(files.1[[1]][1],0,pos-1),
                      fal$comparador,substr(files.1[[1]][1],pos+7,nchar(files.1[[1]][1])-4),".",
                      lab,sep="")
        
        if(verbose==T) print("Completando la información faltante")
       
        for (l in 1:length(m.img)) writeRaster(y,paste(x,"/",filename = m.img[l],sep=""),
                                                format="GTiff",datatype="INT1U", overwrite=T)
         
        if(verbose==T){ cat("Las imágenes faltantes en la serie analizada  son las siguientes: \n")
          print( paste("subset: ",variante[VV]))
        print(fal$fecha)}
      d1[[VV]]<- as.character(fal$fecha)
      }
    rm(fal)
    }
    names(d1) <- variante
  return(d1)
}
