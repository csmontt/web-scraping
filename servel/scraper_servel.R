# Por lo menos hasta el 22-03-2018, los resultados de la primera y segunda vuelta
# presidencial del año 2017, así como los resultados de la elección de Senadores, 
# Diputados y CORES, se encuentran disponibles en el SERVEL. Para acceder a los
# resultados de la primera vuelta presidencial, más los resultados de las otras 
# elecciones que se desarrollaron en ese momento, podemos ingresar a la 
# dirección http://pv.servelelecciones.cl/. Si queremos acceder a los
# resultados de la segunda vuelta, debemos acceder a http://www.servelelecciones.cl/. 
# En ambas páginas podemos explorar los resultados interactivamente, no obstante,
# nosotros deseamos bajar los datos de manera programáticamente, para ello, podemos 
# crear una función que nos permita hacer exactamente eso:

# Primero debemos instalar y cargar los paquetes necesarios
lista_paquetes <- c("RCurl","dplyr","jsonlite", "stringr", "downloader")
instalar <- lista_paquetes[!(lista_paquetes %in% installed.packages()[,"Package"])]
if(length(instalar)) {install.packages(instalar)}

# cargar paquetes
sapply(lista_paquetes, require, character.only = TRUE, quietly = TRUE)

# Y luego creamos la función mesas
mesas <- function(eleccion = "elecciones_presidente",
        codigo = "3190019"){
        url = paste0("http://servelelecciones.cl/data/",
                eleccion, "/computomesas/",
                codigo,".json")
        resultado = jsonlite::fromJSON(getURL(url,
        httpheader = c("User-Agent"="Mozilla/5.0 (Windows NT 6.1; WOW64)"),
                        .encoding = "UTF-8"))
        resultado
}

# La función se llama mesas y recibe dos argumentos como input, elección y codigo. 
# En la primera vuelta, era posible elegir entre elecciones Presidenciales, 
# Parlamentarias o CORES, mientras que en la segunda vuelta, sólo está la 
# opción elecciones_presidente. El segundo argumento, codigo, se refiere al 
# código único de la mesa utilizado por el SERVEL

# Ejemplo
mesas("elecciones_presidente", "1030010")

## $title
## $title$a
## [1] "Nombre de los Candidatos"
## 
## $title$b
## [1] "Partido"
## 
## $title$c
## [1] "Votos"
## 
## $title$d
## [1] "Porcentaje"
## 
## $title$e
## [1] "Candidatos"
## 
## $title$f
## [1] "Electo"
## 
## $title$sd
## NULL
## 
## 
## $isVisible
## $isVisible$a
## [1] "true"
## 
## $isVisible$b
## [1] "false"
## 
## $isVisible$c
## [1] "true"
## 
## $isVisible$d
## [1] "true"
## 
## $isVisible$e
## [1] "false"
## 
## $isVisible$f
## [1] "true"
## 
## $isVisible$sd
## NULL
## 
## 
## $dataType
## $dataType$a
## [1] "String"
## 
## $dataType$b
## [1] "String"
## 
## $dataType$c
## [1] "Integer"
## 
## $dataType$d
## [1] "Integer"
## 
## $dataType$e
## [1] "Integer"
## 
## $dataType$f
## [1] "Integer"
## 
## $dataType$sd
## NULL
## 
## 
## $data
##                                a        b  c      d  e f sd
## 1  3. SEBASTIAN PIÑERA ECHENIQUE EnBlanco 81 57,86% NA * NA
## 2 4. ALEJANDRO  GUILLIER ALVAREZ EnBlanco 59 42,14% NA   NA
## 
## $resumen
##                      a  b   c       d  e  f sd
## 1 Válidamente Emitidos NA 140  98,59% NA NA NA
## 2          Votos Nulos NA   2   1,41% NA NA NA
## 3      Votos en Blanco NA   0   0,00% NA NA NA
## 4       Total Votación NA 142 100,00% NA NA NA
## 
## $colegioEscrutador
## $colegioEscrutador$c
## [1] TRUE
## 
## $colegioEscrutador$cc
## [1] 514
## 
## $colegioEscrutador$dv
## [1] FALSE
## 
## $colegioEscrutador$d
## [1] FALSE
## 
## $colegioEscrutador$r
## [1] TRUE
## 
## $colegioEscrutador$cm
## [1] 1030010
## 
## $colegioEscrutador$nm
## [1] "10M"
## 
## $colegioEscrutador$nr
## [1] FALSE
## 
## $colegioEscrutador$nev
## [1] FALSE
## 
## 
## $labels
## NULL
## 
## $mesasEscrutadas
## NULL
## 
## $totalMesas
## NULL
## 
## $totalMesasPorcent
## NULL
## 
## $tipoGlosaComputo
## NULL
## 
## $mostrarGlosaNominados
## [1] TRUE
## 
## $tipoGlosaNominados
## [1] "1"

# El objeto que obtenemos es una lista con varios elementos, acá los más relevantes 
# son los elementos data y resumen. El primero da el número de votos y porcentaje 
# para cada candidato, mientras que el segundo nos da información sobre la cantidad 
# de votos (emitidos, nulos, blancos y totales). Podemos acceder a estos elementos
# utilizando el operador $. Por si existen dudas de como acceder a elementos de 
# distintos tipos de objectos en R, revisar http://adv-r.had.co.nz/Subsetting.html. 
# Así, si queremos obtener la información de los votos de cada candidato debemos 
# hacer lo siguiente:

mesas("elecciones_presidente", "1030010")$data

##                                a        b  c      d  e f sd
## 1  3. SEBASTIAN PIÑERA ECHENIQUE EnBlanco 81 57,86% NA * NA
## 2 4. ALEJANDRO  GUILLIER ALVAREZ EnBlanco 59 42,14% NA   NA
