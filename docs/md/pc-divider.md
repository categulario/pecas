# Uso de `pc-divider`

Divider separa un documento +++HTML+++ cada &lt;h1&gt; o &lt;section&gt;.

## Uso:

```
pc-divider -f [archivo a dividir]
```

## Parámetro necesario:

* `-f` = [file] Archivo +++HTML+++, +++XHTML+++, +++XML+++ o +++HTM+++ a dividir.

## Parámetros opcionales:

* `-d` = [directory] Directorio donde se pondrán los archivos creados.
* `-s` = [style sheet] Ruta al archivo +++CSS+++ que se desea vincular.
* `-i` = [index] Índice con el que ha de comenzar la numeración del nombre de los archivos creados.
* `\--section` = Divide el documento cada &lt;section&gt;.

## Parámetros únicos:

* `-v` = [version] Muestra la versión.
* `-h` = [help] Muestra esta ayuda.

## Ejemplo sencillo:

```
pc-divider -f archivo/a/dividir.xhtml
```

Dividirá el archivo `dividir.xhtml` cada &lt;h1&gt;, poniendo los archivos creados en el directorio actual y empezando con el índice número 3.

## Ejemplo en un directorio específico:

```
pc-divider -f archivo/a/dividir.xhtml -d directorio/deseado
```

Dividirá como el ejemplo anterior, poniendo los archivos creados en `directorio/deseado`.

## Ejemplo en un directorio e incluyendo una hoja de estilo:

```
pc-divider -f archivo/a/dividir.xhtml -d directorio/deseado -s ruta/al/archivo.css
```

Dividirá como el ejemplo anterior, vinculando la hoja de estilo `archivo.css` en cada archivo creado.

## Ejemplo en un directorio e incluyendo una hoja de estilo y con otro índice:

```
pc-divider -f archivo/a/dividir.xhtml -d directorio/deseado -s ruta/al/archivo.css -i 1
```

Dividirá como el ejemplo anterior, iniciando la numeración de los archivos con el número 1.

## Ejemplo en un directorio, dividido cada &lt;section&gt; e incluyendo una hoja de estilo y con otro índice:

```
pc-divider -f archivo/a/dividir.xhtml -d directorio/deseado -s ruta/al/archivo.css -i 1 --section
```

Semejante al ejemplo anterior, solo que la división es cada &lt;section&gt; en lugar de cada &lt;h1&gt;.
