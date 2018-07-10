# Uso de `pc-pandog`

Pandog convierte entre archivos MD, +++HTML+++, +++HTM+++, +++XHTML+++, +++XML+++, +++JSON+++, TeX, +++EPUB+++, +++ODT+++ o +++DOCX+++, estos tres últimos tipos a través de Pandoc.

## Dependencias opcionales:

* `pandoc`

## Uso:

```
pc-pandog -i [nombre del archivo de entrada] -o [nombre del archivo de salida]
```

## Parámetros necesarios:

* `-i` = [input] Nombre del archivo a convertir.
* `-o` = [output] Nombre para el archivo que se creará; si no se indica alguna ruta, el archivo se creará en el mismo directorio del archivo de entrada.

## Parámetros únicos:

* `-v` = [version] Muestra la versión.
* `-h` = [help] Muestra esta ayuda.

## Ejemplo:

```
pc-pandog -i directorio/al/archivo.md -o archivo.xhtml
```

Crea un archivo +++XHTML+++ a partir de `archivo.md` presente en `directorio/al`.
