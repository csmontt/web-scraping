#' Obtener código postal de una dirección específica
#'
#' Utilizamos rvest para hacer web scraping de la página de 
#' correos de Chile, con el fin de obtener el código postal
#' de cualquier dirección. La función sólo funciona con 
#' direcciones que esten escritas correctamente. 
#' @param calle nombre de la calle que queremos consultar (character)
#' @param numero numero de la calle consultamos (character)
#' @param comuna nombre de la comuna donde se encuentra la dirección
#' que queremos consultar (character)
#' @return Un vector de largo 1 correspondiente al código postal 
#' obtenido
#' @export

get_codpostal <- function(calle = "rosario norte", numero = "532", comuna = "las condes"){
        url_base <- "http://codigopostal.correos.cl:5004/?calle="
        calle_gsub <- gsub(" ", "%20", calle)
        comuna_gsub <- gsub(" ", "%20", comuna)
        url_codigo <- paste0(url_base, calle_gsub, "%20&numero=", numero, "&comuna=", comuna_gsub)
        html_cp <- read_html(url_codigo) %>% 
                             html_nodes('.tu_codigo span') %>%
                             html_text() 
        cp <-   gsub("\\s+", "", html_cp)
        return(cp)
}


# Ejemplo
get_codpostal(calle = "av. libertador bdo", 
              numero = "3363", 
              comuna = "estacion central")
