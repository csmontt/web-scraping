## Web Scraper Páginas Amarillas

* web_scraper_paginas_amarillas.R contiene el código para hacer web-scraping desde páginas amarillas.
* ws_amarillas.Rmd creas ws_amarillas.md donde se explica paso a paso como se creo el web-scraper.
* Los archivos .tsv muestran resultados de consultas, el nombre del archivo corresponde a la consulta.

### Uso
Si web_scraper_paginas_amarillas.R se encuentra en Working Directory, se puede cargar así:

source("web_scraper_paginas_amarillas.R

Hacer una consulta:

scrape_write_table('carniceria')

Abrir la base de datos en R:

df_carniceria <- read_tsv('carniceria.tsv')
