# Uso de `pc-add`

Add añade plantillas +++CSS+++ o archivos JavaScript al proyecto.

## Uso:

```
pc-add --add [tipo]
```

## Parámetro necesario:

* `\--add` = Elige qué tipo de archivo añadir al proyecto

## Parámetro opcional:

* `-d` = [directory] Directorio donde se desea añadir el archivo.

## Parámetros únicos:

* `-v` = [version] Muestra la versión.
* `-h` = [help] Muestra esta ayuda.

## Tipos de archivos:

* `css` = Hoja de estilo actual de Pecas.
* `css-legacy` = Hoja de estilo antigua de Pecas.
* `js-poetry` = Script que posibilita un control ortotipográfico cuando el verso excede el tamaño de la caja.
* `js-zoom` = Script que posibilita el aumento o disminución del tamaño de la tipografía en +++EPUB+++ de diseño fijo.

## Ejemplo sencillo:

```
pc-add --add css
```

Agregará la hoja de estilo actual de Pecas en el directorio actual.

## Ejemplo con directorio específico:

```
pc-add --add css -d directorio/especifico
```

Semejante al ejemplo anterior pero añadirá el archivo en `directorio/especifico`.

--- {.espacio-arriba3}

Nota: ¿cómo implementar los archivos JavaScript?, consúltese la documentación de [JavaScript](js.html). {.espacio-arriba3}
