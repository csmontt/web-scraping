# web_scraper_paginas_amarillas.R

# Funciones para Web Scraper de Páginas amarillas

# Cargar librerías ==============
lista_paquetes <- c("rvest","stringr","tidyverse", "DT")
instalar <- lista_paquetes[!(lista_paquetes %in% installed.packages()[,"Package"])]
if(length(instalar)) {install.packages(instalar)}

lista_paquetes <- lista_paquetes
sapply(lista_paquetes, require, character.only = TRUE, quietly = TRUE)


# crea_url() =====================
# crea la url de la primera página de búsqueda para 
# una palabra en especifíco.
# e.g. 
# crea_url("farmacÃ©utica"), crea
# "http://www.amarillas.cl/buscar/q/farmaceutica"
crea_url <- function(consulta){
        url <- paste0("http://www.amarillas.cl/buscar/q/", consulta)
        url
}


# get_last_page() ================
# Obtenemos el número de pÃ¡ginas para una consulta determinada
# El buscador de Las Páginas Amarillas, por defecto, devuelve 
# 35 resultados. En la parte de arriba de la página de resultados,
# aparecen cuantos resultados se encontraron en total para la 
# consulta. Dividimos el total por 35 y redondemaos el número
# hacía arriba, dado que, si el número era fraccional quiere
# decir que los resultados restantes terminaron en la página
# siguiente del entero del número.

get_last_page <- function(html){
      pages_data <- html %>% 
                      # .h1Bread es el tag donde se encuentra 
                      # la información que nos interesa.
                      html_nodes('.h1Bread') %>% 
                      # Extract the raw text as a list
                      html_text() 
      # Borramos carácteres especiales de pages_Data.
      # Al convertir el html a texto, quedan muchos carácteres 
      # ensucian los datos(e.g. \r\n, \t, etc.)
      # para limpiarlos ocupamos la función gsub() y regex.
      # gsub() borra del string el patrón regex que 
      # especifiquemos.
      pages_data <- gsub("\\s+", "", pages_data) 
      # Borramos todos los carácteres hasta |, luego de | se encuentra
      # el número de resultados.
      pages_data <- gsub("^.*\\|", "", pages_data) 
      # Borramos "resultados" del string que nos va quedando,
      # así queda sólo el número de resultados, que transformamos 
      # a numeric y luego aplicamos la función ceiling() para
      # redondear hacia arriba.
      pages_data <- gsub("resultados", "", pages_data) %>% as.numeric()
      ceiling(pages_data/35)
}

# get_nombre() =================
# Obtener nombre de la empresa
get_nombre <- function(html){
      html %>% 
        # Etiqueta que queremos
        html_nodes('.business-name') %>%      
        html_text() %>% 
        # eliminar leading y trailing whitespaces
        str_trim() %>%                       
        # Convertir lista a vector
        unlist()                             
}

# get_categorias() =====================
# La empresa tiene asociada a ella una o más categorías de
# su rubro. Para dejar la base de datos más limpia
# nos quedamos sólo con la primera.

get_categorias <- function(html){
    categorias <- html %>% 
        # Etiqueta de ínteres
        html_nodes('.business-categories') %>%      
        html_text() %>% 
        # eliminar leading y trailing whitespaces
        str_trim() %>%                       
        # Convertir lista a vector
        unlist()   
    # En pocos casos, una empresa tiene más de una categoría asociada,
    # con strsplit separamos en distintos elementos el string de cada empresa
    # donde se encuentran sus categorías.
     categorias_split <- strsplit(categorias, "\t")  
     # Al hacerlo, en el caso de las empresas que tienen varias categorías, 
     # se crea una lista dentro de cada empresa, donde se crea un vector de 
     # carácteres con un largo variable.
     # lo que queremos conocer es, en que índices, tanto de la empresa, como 
     # dentro del vector de carácteres al interior de la empresa, se encuentran
     # las categorías y extraerlas y asociarlas a la empresa correspondiente.
     
     # Con indices obtenemos los índices de los elementos que queremos extraer
     # por empresa.
     indices <- list()
        for(i in 1:length(categorias_split)) { 
           ind_cat <- grep("^[[:alpha:]].*\r\n", 
                           categorias_split[[i]])
           if(length(ind_cat)==0){
           # Si length ind_cat == 0 quiere decir que el resultado del regex
           # de ind_cat fue integer(0). Eso sucede cuando hay un sólo 
           # elemento dentro del vector de carácteres de la empresa.
           # cambiamos su valor a 1, para así extraer el priemr y único 
           # elemento de ese vector.
                   ind_cat <- 1
           } else {
           # De lo contrario, obtenemos todos los índices de los elementos
           # que nos interesan del vector de cáracteres de la empresa (las 
           # categorías), pero borramos el último elemento que no corresponde a 
           # una categoría. Si hubiese hecho un mejor regex, esto no 
           # hubiese sido necesario.
             ind_cat <- ind_cat[-length(ind_cat)]     
           }
           indices[[i]] <- ind_cat
      }
      
     # Categorías, creamos una base de datos con la misma estructura que 
     # categorias_split, para ir llenándola con las categorias.
      categorias <- rep(list(data.frame()), length(categorias_split)) 
        for(i in 1:length(categorias_split)){
             obtener <- indices[[i]] 
                for(j in 1:length(obtener)) {
                  categorias_j <- categorias_split[[i]][[obtener[j]]]
                  categorias_j <- gsub("\r\n", "", categorias_j)
                  categorias[[i]][1,j] <- categorias_j  
          }
     } 
      etiquetas_rubro <- bind_rows(categorias)
      # dejar sólo primera categoría
      etiquetas_rubro$V1
}

# get_direccion() ===========================
# Obtener dirección de la empresa
get_direccion <- function(html){
      dirs <- html %>% 
         # Etiqueta de ínteres
        html_nodes('.business-address') %>%      
        html_text() %>% 
        # eliminar leading y trailing whitespaces
        str_trim() %>%                       
        # Convertir lista a vector
        unlist()  
      gsub("\\s+", " ", dirs) 
}

# get_telefono () =========================
# obtener número de teléfono de la empresa
# en get_telefono() y get_link() tuve que seguir otra 
# estrategia. Algunas compañias tenían un sólo
# número de telefono, otras más. La etiqueta para
# acceder a ambas era distinta. Si utilizaba un método
# me quedaba con los datos de sólo aquellas empresas
# con esa característica. 
# Para enfrentarlo, ocupe el tag ".business" que devuelve
# toda la información de todas las empresas, pero de manera 
# menos estructurada y de ahí conseguí los
# números de teléfono y páginas web. 
# Sólo un número de teléfono por empresa si.

get_telefono <- function(html){
     info <- html %>% 
        # Etiqueta de ínteres
        html_nodes('.business') %>%      
        html_text() %>% 
        # eliminar leading y trailing whitespaces
        str_trim() %>%                       
       # Convertir lista a vector
        unlist()       
     info <- gsub("http://www.amarillas.cl", "", info)
     info <- gsub("\\s+", " ", info)
     links_tel <- rep(NA, length(info))
     ind_tel <- grep("(56)", info)
     for(i in 1:length(ind_tel)){
        ind <- ind_tel[i]
        links_tel[ind] <- info[i]
     }
     businesses_split <- strsplit(links_tel, ",")
     telefonos <- c()
     for(i in 1:length(businesses_split)){
     telefonos <- c(telefonos, businesses_split[[i]][6])
     }
     telefonos <- gsub("\\s+|'", "", telefonos)
     telefonos
}

# get_link()=======================
# Para obtener el link de la página web de la empresa.
get_link <- function(html){
     info <- html %>%
        # The relevant tag
        html_nodes('.business') %>%
        html_text() %>%
        # Trim additional white space
        str_trim() %>%
        # Convert the list into a vector
        unlist()
     info <- gsub("http://www.amarillas.cl", "", info)
     info <- gsub("\\s+", " ", info)
     businesses_split <- strsplit(info, ",")
     links <- c()
     for(i in 1:length(businesses_split)){
     links <- c(links, businesses_split[[i]][12])
     }
     links <- gsub("^.*http://|'", "", links)
     links <- gsub(" .*", "", links)
     links[links == ""] <- NA
     links
}

# scrape_write_table() ==============
# Esta es la función que une todas las funciones que hicimos con anterioridad
# y que definiremos un poco más abajo.

# La explicare paso a paso.

# Recibe como argumentos una consulta, la página sobre la que vamos 
# a hacer scraping

  scrape_write_table <- function(consulta){

      # Leemos la primera página de la consulta
      first_page <- read_html(crea_url(consulta))

      # Extraemos el número de páginas que tiene los resutlados
      # de la consulta
      latest_page_number <- get_last_page(first_page)

      # Creamos una URL para cada página de los resultados
      list_of_pages <- str_c(consulta, "/p-", 1:latest_page_number,"/")

      # Para cada una de las URLs de la lista recién creada, extraemos
      # sus datos y los convertimos en un data frame con la función 
      # get_data_from_url. Luego, agregamos el resultado de cada consulta
      # una abajo de la otra con bind_rows(). 
      # Finalmente, escribimos la base de datos a nuestro working 
      # directory en formato .tsv, podríamos elegir cualquier otro.
      # Elegimos .tsv dado que, como estamos trabajando con texto, 
      # puede ser que existan comas en el texto, y esto signifique
      # que al volver a leer el archivo(si es que lo guardamos como .csv)
      # este no se abra correctamente.
      list_of_pages %>% 
        # Para cada URL aplicamos la función get_data_from_url
        map(get_data_from_url) %>%  
        # Combinamos todos los datos extrapidos en una sola base de datos
        bind_rows() %>%                           
        # Escribimos el archivo en .tsv
        write_tsv(str_c(consulta,".tsv"))     
  }

# get_data_from_url() ========================================
# Convierte la consulta a Páginas Amarillas en una URL
# que luego transforma a un formato leíble por R usando la función read_html()
# Luego llama a la función get_data_table(), que definimos más abajo.
# Podríamos haber incluido 
# html <- read_html(url)
# al inicio de la función get_data_table() y esta función
# no sería necesaria. Pero lo vamos a dejar así para no desviarnos de las
# prácticas recomendada por el tutorial.

 get_data_from_url <- function(consulta){
      html <- read_html(crea_url(consulta))
      get_data_table(html, consulta)
 }


# get_data_table() ==================================
# Recibe dos argumentos, el html a extraer y "consulta", que corresponde 
# a la consulta que se hizo.
# Devuelve los resultados de la página extraída como un tibble.
get_data_table <- function(html, consulta){
      
      consulta <- gsub("/p.*$", "", consulta)        
      # Extraemos la información del html con las funciones que 
        # creamos más arriba
      nombres <- get_nombre(html)
      categorias <- get_categorias(html)
      direcciones <- get_direccion(html)
      paginas_web <- get_link(html)
      telefonos <- get_telefono(html)

      # Combinamos los distintos vectores que obtuvimos
      # en una data frame. Tibbles es un data.frame
      # pero, según sus creadores, mejor.
      combined_data <- tibble(nombre = nombres,
                              categoria = categorias,
                              direccion = direcciones,
                              pagina_web = paginas_web,
                              telefono = telefonos) 

      # Le agregamos la columna consulta al data frame.
      
      combined_data %>%
        mutate(consulta = consulta) %>%
        select(consulta, nombre, categoria, direccion, pagina_web, telefono)
 }
 
