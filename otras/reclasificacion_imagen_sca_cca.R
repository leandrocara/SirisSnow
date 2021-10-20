
### este script es para reclasificar y testear productos satelitales!

reclas.v6 <-function(verbose=F){ 
  ### variables que va a pasar la func derecho
  
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
  {
  ### lo primero que debo hacer es levantar las imágenes
  ## Variables temporales
  nodata <- c(NA,250)
  suelo <- c(seq(0,39))
  nieve <- c(seq(40,100))
  acc <- vector()
  tabla <- data.frame()

  ### matríz para armar la imágenes de nubes
  capa.nubes <- matrix(ncol=2,c(250,NA,seq(0,100),200,201,211,237,239,254,255,1,rep(0,109)))

  snow.bare.clouds <- as.matrix(data.frame(col1=c(suelo,nieve,nodata),
  col2=c(rep(0,length(suelo)),rep(1,length(nieve)),rep(2,length(nodata)))))

  bool.clouds <- as.matrix(data.frame(col1=c(2,0,1),col2=c(1,0,0)))

  dos20 <- as.matrix(data.frame(col1=c(2),col2=c(0)))

  #Listamos las imágenes  MODIS, TERRA y ACUA .----
  ### antes de hacer un subset vamos a transformar las imágenes, es decir
  ### vamos a transformar todas las imágenes pero cuando lleguemos a una que tiene mod y myd
  ### recién ahí vamos a combinar
  #### vamos a procesar todas las mod primero!!!
  ### si la imagen mod no ha sido reclasificada previamente!
  # i <- 1;j <- 1
  
  cat("iniciando la serie MOD \n\n")
  colector_modtap <- vector()
  
    cat("------------------------------------------------------------------------------------------\n")
  for (i in 1:length(lmod)){
    ## si existe el mod-myd de la imagen i no hago nada, porque se entiende que está todo hecho.
    if(length(list.files(dir.mod.myd,corte(lmod[i]),full.names = T))==0 &
       !grepl("missing",lmod[i])){
    cat("------------------------------------------------------------------------------------------\n")
    cat(lmod[i])
    cat("\n")    
    cat("\n")    
    
    cat("No existe mod-myd de la imagen mod y la imagen mod no es missing \n")
    cat("\n")    
    cat("\n")    
      # guardo el dato de las imágenes que no tienen mod.myd para después
      colector_modtap <- c(colector_modtap,corte(lmod[i]))
            ## llama al raster reclasificado
            mod <- raster(paste(dir.mod,lmod[i],sep="/"))
          # si existe la capa de nubes llama a la capa de nubes siempre existe!
            c.mod <- raster(f.1(lmod[i],dir.mod.c))
          ### busco la correspondencia de la imagen mod en la lista de imágenes myd
        j <- match(corte(lmod[i]),corte(lmyd))
        ## agrego el nro en el indexador p myd que voy a usar en el próximo ciclo
        acc[length(acc)+1] <-j
      
        # Si existe una imagen myd equivalente para esta mod
      
        if(!is.na(j)){
          # si la imagen myd NO es una capa faltante agregada!
          if(!grepl("missing",paste(dir.myd,lmyd[j],sep="/"))){
      
       cat("Existe una imagen myd equivalente para esta mod y tampoco es missing \n")
       cat(lmyd[j])
       cat("\n")    
       cat("\n")    
#########################################################################################################
      myd <- raster(paste(dir.myd,lmyd[j],sep="/")) ## levanta la capa reclasificada myd 
      c.myd<- raster(f.1(lmyd[j],dir.myd.c)) ##levanta la capa de nubes myd.c
#########################################################################################################
  ###  si no se ha creado la img MOD.MYD de nubes correspondiente # falso indica que existe!
          if(is.na(match(corte(lmod[i]),corte(list.files(dir.mod.myd.c.max))))){
         cat("No existen las imágenes MOD.MYD de nubes correspondientes\n")
            cat("\n")    
            # si las imágenes de nubes de mod y de myd existen
       if(length(list.files(dir.mod.c,corte(lmod[i]),full.names = T))>=1 &
               length(list.files(dir.myd.c,corte(lmod[i]),full.names = T))>=1){
              ## graba cloud max y cloud min
       cat(paste("Creando: MOD.MYD.A",corte(lmyd[j]),".clouds.max.tif",sep=""))
       cat("\n")    
       cat("\n")    
       writeRaster(((c.mod+c.myd)-(c.mod*c.myd)),paste(dir.mod.myd.c.max,"/MOD.MYD.A",corte(lmyd[j]),
            ".clouds.max.tif",sep=""),format="GTiff", overwrite=T,datatype="INT1U")
       
       cat(paste("Creando: MOD.MYD.A",corte(lmyd[j]),".clouds.min.tif",sep=""))
       cat("\n")    
       cat("\n")    
       writeRaster(c.mod*c.myd,paste(dir.mod.myd.c.min,"/MOD.MYD.A",corte(lmyd[j]),
            ".clouds.min.tif",sep=""),format="GTiff", overwrite=T,datatype="INT1U")
          }
          }
#########################################################################################################
       ###  si no se ha creado la img MOD.MYD de nieve correspondiente
          if(is.na(match(corte(lmod[i]),corte(list.files(dir.mod.myd))))){
            cat("NO existe la img MOD.MYD de NIEVE correspondiente\n")
            cat("\n")    
            mask.mod <-  reclassify(mod, bool.clouds, include.lowest=FALSE, right=NA) 
            mod.myd <- mask.mod*myd
            mod.myd <- rcl(mod,dos20) + mod.myd
            
       cat(paste("Creando: MOD.MYD.A",corte(lmyd[j]),".snow.cover.area.tif",sep=""))
       cat("\n")    
       cat("\n")    
       writeRaster(mod.myd,paste(dir.mod.myd,"/MOD.MYD.A",corte(lmyd[j]),
       ".snow.cover.area.tif",sep=""),format="GTiff", overwrite=T,datatype='INT1U')
          }
#########################################################################################################
         ### este else responde a si  hay un match con las img myd pero es un missing
        }else{
       cat("IMAGEN DE NIEVE MYD es 'missing'\n")
          cat("\n")    
           cat(lmyd[j])
           cat("\n")
           cat("\n")    
          # si existe la imagen de nubes mod y no existe la de nubes mod.myd
          if(length(list.files(dir.mod.c,corte(lmod[i]),full.names = T))>=1 & 
             length(list.files(dir.mod.myd.c.max,corte(lmod[i]),full.names = T))==0){
            cat("NO existe la img MOD.MYD.max de nubes correspondiente\n")
            ## grabo mod.myd con un MOD! 
            
             cat(" creo la imagen c.mod.myd.max \n")
             cat(paste("Creando: MOD.MYD.A",corte(lmod[i]),".MOD.clouds.max.tif",sep=""))  
             cat("\n")    
             cat("\n")    
            writeRaster(c.mod,paste(dir.mod.myd.c.max,"/MOD.MYD.A",corte(lmod[i]),
                              ".MOD.clouds.max.tif",sep=""),format="GTiff", overwrite=T)}
   
          ### si no existe la imagen de nieve mod.myd la creo
       
          if(length(list.files(dir.mod.myd,corte(lmod[i]),full.names = T))==0){
           cat(" Creo la imagen mod.myd de nieve \n")
            cat("\n")    
       cat(paste("MOD.MYD.A",corte(lmod[i]),".MOD.snow.cover.area.tif\n",sep=""))
       cat("\n")    
       cat("\n")    
       writeRaster(mod,paste(dir.mod.myd,"/MOD.MYD.A",corte(lmod[i]),".MOD.snow.cover.area.tif"
                                  ,sep=""),format="GTiff", overwrite=T, datatype='INT1U')}
        }
#########################################################################################################
         ### este else responde a si  NO hay un match con las img myd
          }else{
       
       cat("IMAGEN DE NIEVE MYD no existe\n")

          # si existe la imagen de nubes mod y no existe la de nubes mod.myd
          if(length(list.files(dir.mod.c,corte(lmod[i]),full.names = T))>=1 & 
             length(list.files(dir.mod.myd.c.max,corte(lmod[i]),full.names = T))==0){
            ## grabo mod.myd con un MOD! 
            cat("creo la imagen\n")
            cat("\n")    
            cat(paste("Creando: MOD.MYD.A",corte(lmod[i]),".MOD.clouds.max.tif",sep=""))
            cat("\n")    
            cat("\n")    
            
            writeRaster(c.mod,paste(dir.mod.myd.c.max,"/MOD.MYD.A",corte(lmod[i]),
                              ".MOD.clouds.max.tif",sep=""),format="GTiff", overwrite=T)}
          
          ### si no existe la imagen de nieve mod.myd la creo
             
          if(length(list.files(dir.mod.myd,corte(lmod[i]),full.names = T))==0){
             cat(" creo la imagen mod.myd \n")
            cat("\n")    
             cat(paste("Creando: MOD.MYD.A",corte(lmod[i]),".MOD.snow.cover.area.tif",sep=""))
             cat("\n")    
             cat("\n")    
              writeRaster(mod,paste(dir.mod.myd,"/MOD.MYD.A",corte(lmod[i]),".MOD.snow.cover.area.tif"
                                  ,sep=""),format="GTiff", overwrite=T, datatype='INT1U')}
        }
      
    }else{
      ### existe la imagen mod.myd que corresponde al ciclo mod[i] o mod[i] es missing!
      ### busco la correspondencia de la imagen mod en la lista de imágenes myd
      # solo si mod[i] no es missing
      if(!grepl("missing",lmod[i])){
        
      j <- match(corte(lmod[i]),corte(lmyd))
      ## agrego el nro en el indexador p myd que voy a usar en el próximo ciclo
      acc[length(acc)+1] <-j
      }
    }
      # txtProgressBar(min=0,max = length(lmod), initial = i,style = 3)

  }
  }
  
 #################################################################################################
 cat("PROCESO MOD finalizado\n")
 cat(paste0("se analizaron ", i, " imágenes\n"))
 #################################################################################################
 
 acc <- as.vector(na.omit(acc))
  
 ### esta estructura de control permite que se puedan ejecutar períodos diferentes 
  ### para mod y myd
  if(length(acc)!=0) lmyd <- lmyd[-c(acc)]
 
 cat(paste0("faltan ",length(lmyd), " imágenes myd sin correspondencia en mod para analizar\n" ))
 cat("\nRealizando la reclasificación para las imágenes MYD: \n\n")
  if(length(lmyd)>0){
    cat("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n")
    cat("\n")    
    cat(paste("Hay: ",length(lmyd)," imágenes  MYD para analizar"))
    cat("\n")    
    for(j in 1:length(lmyd)){
    cat(lmyd[j])    
    cat("\n")
    cat("\n")    
      if(length(list.files(dir.mod.myd,corte(lmyd[j]),full.names = T))==0){ 
        cat("no se ha creado  mod.myd  para esta imagen todavía\n")
        cat("\n")    
        ### si no está 
        if(!grepl("missing",lmyd[j])){
        cat("No es missing\n")
          cat("\n")    
        ## levanto el raster de nieve myd
          myd <- raster(paste(dir.myd,lmyd[j],sep="/"))
          
          ## si existe la capa de nubes la levanto! y si no que hago? :|
          
          if(length(list.files(dir.myd.c,corte(lmyd[j]),full.names = T))>=1){
            c.myd <- raster(f.1(lmyd[j],dir.myd.c))
            }else{
              #### por lógica nunca debería faltar la capa de nubes pero puede pasar!
              # debería crearla una capa completa de ceros! en general para las demás está 
              # creada
            }
          # Si existe la capa de nubes myd.c y no existe su equivalente mod.myd.max
          if(length(list.files(dir.myd.c,corte(lmyd[j]),full.names = T))>=1 &
             length(list.files(dir.mod.myd.c.max,corte(lmyd[j]),full.names = T))==0){
            ### incluyo en colector las imagenes soloMYD generadas!
            colector_modtap <- c(colector_modtap,corte(lmyd[j]))
            ### escribo mod.myd.max.MYD
            cat("creo mod.myd.max.MYD\n")
            cat("\n")    
            cat(paste("MOD.MYD.A",corte(lmyd[j]),".MYD.clouds.max.tif",sep=""))
            cat("\n")    
            cat("\n")    
            
            writeRaster(c.myd, paste(dir.mod.myd.c.max,"/MOD.MYD.A",corte(lmyd[j]),
                              ".MYD.clouds.max.tif",sep=""),format="GTiff", overwrite=T, datatype='INT1U')}
          ## si NO existe mod.myd, lo creo!
          if(length(list.files(dir.mod.myd,corte(lmyd[j]),full.names = T))==0){
            cat("creo mod.myd.MYD\n")
            cat(paste("MOD.MYD.A",corte(lmyd[j]),".MYD.snow.cover.area.tif",sep=""))
            
            writeRaster(myd,paste(dir.mod.myd,"/MOD.MYD.A",corte(lmyd[j]),".MYD.snow.cover.area.tif"
                                  ,sep=""),format="GTiff", overwrite=T, datatype='INT1U')}
        }else{
          cat("ATENCIÓN, IMAGEN MOD FALTANTE E IMAGEN MYD FALTANTE!!!! NO SE CREARÁ
              NINGÚN PRODUCTO PARA ESTA FECHA!")
          ## se supone que si lmyd[j] es missing acá es que lmod tb es missing o no está!
          # entonces tengo que crear el raster de mod.myd, y c.mod.myd.max
          # o simplemente que quede el hueco!
          # colector_modtap <- c(colector_modtap,corte(lmod[i]))
          
        }
      }
    }
    
    cat("\nPROCESO MYD finalizado\n\n")
    
  }
  return(list(colector_modtap))
  
  }

