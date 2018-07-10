# Uso de `pc-tiff2pdf`

Tiff2pdf utiliza el poder de Libtiff y de Tesseract para crear archivos +++PDF+++ con +++OCR+++ o +++TXT+++ a partir de imágenes +++TIFF+++.

## Dependencias necesarias:

* `tesseract`
* `libtiff`

## Uso:

```
pc-tiff2pdf -d [directorio] -l [idioma] -o [nombre del archivo]
```

## Parámetros necesarios:

* `-l` = [language] Acrónimo del lenguaje a detectar. Es necesario instalar el lenguaje. [Lista de acrónimos](https://github.com/tesseract-ocr/tesseract/blob/master/doc/tesseract.1.asc#languages).
* `-o` = [output] Nombre para el o los archivos que se crearán.

## Parámetros opcionales:

* `-d` = [directory] Directorio que contiene las imágenes.
* `\--tif` = Crea un +++TIF+++ que contiene todas las imágenes.
* `\--txt` = Crea un +++TXT+++ adicional al +++PDF+++ creado.

## Parámetros únicos:

* `-v` = [version] Muestra la versión.
* `-h` = [help] Muestra esta ayuda.

## Ejemplo sencillo:

```
pc-tiff2pdf -d directorio/de/las/imágenes -l spa -o prueba
```

Crea un archivo +++PDF+++ con +++OCR+++ en español a partir de las imágenes presentes en `directorio/de/las/imágenes`.

## Ejemplo con archivo de texto:

```
pc-tiff2pdf -d directorio/de/las/imágenes -l spa -o prueba --txt
```

Además del +++PDF+++ con +++OCR+++, se crea un archivo de texto con el contenido de las imágenes.
