# Creator

Creator crea un proyecto para EPUB con distintas opciones.

## Uso:

  ```
  pt-creator
  ```

## Descripción de los parámetros

### Parámetros opcionales:

* `-d` = [directory] Directorio donde se creará el proyecto.
* `-o` = [output] Nombre del proyecto.
* `-s` = [style sheet] Ruta al archivo CSS que se desea incluir.
* `-c` = [cover] Ruta a la imagen de portada que se desea incluir.
* `-i` = [images] Ruta a la carpeta con las imágenes que se desean incluir.

### Parámetros únicos:

* `-v` = [version] Muestra la versión.
* `-h` = [help] Muestra la ayuda, la cual es este contenido.

## Ejemplos

### Ejemplo sencillo:

```
  pt-creator
```

Crea un proyecto EPUB en el directorio actual y con el nombre `epub-creator`.

### Ejemplo en un directorio específico:

```
  pt-creator -d directorio/deseado
```

Crea un proyecto EPUB en `directorio/deseado` y con el nombre `epub-creator`.

### Ejemplo en un directorio y nombre específicos:

```
  pt-creator -d directorio/deseado -o proyecto_epub
```

Crea un proyecto EPUB en `directorio/deseado` y con el nombre `proyecto_epub`.

### Ejemplo en un directorio y nombre específicos, e incluyendo una hoja de estilo:

```
  pt-creator -d directorio/deseado -o proyecto_epub -s ruta/al/archivo.css
```

Crea un proyecto EPUB como el ejemplo anterior, incluyendo la hoja de estilo `archivo.css` en lugar del CSS defecto.

### Ejemplo en un directorio y nombre específicos, e incluyendo una hoja de estilo y una portada:

```
  pt-creator -d directorio/deseado -o proyecto_epub -s ruta/al/archivo.css -c ruta/a/la/portada.jpg
```

Crea un proyecto EPUB como el ejemplo anterior, incluyendo un XHTML que muestra la imagen de `portada.jpg`.

### Ejemplo en un directorio y nombre específicos, e incluyendo una hoja de estilo, una portada y varias imágenes:

```
  pt-creator -d directorio/deseado -o proyecto_epub -s ruta/al/archivo.css -c ruta/a/la/portada.jpg -i ruta/al/directorio/con/imagenes
```

Crea un proyecto EPUB como el ejemplo anterior, incluyendo una copia de las imágenes presentes en `ruta/al/directorio/con/imagenes`.

## YAML

El `script` también generará `meta-data.yaml`, que sirve para los metadatos
del libro. Si no se usará `pt-recreator` para generar el EPUB, este archivo
es innecesario y puede eliminarse.

La estructura del archivo es:

```
---
# Generales
title: Sin título
author: Anónimo
publisher: 
synopsis: 
category: 
version: 1.0.0
cover: portada.jpg
navigation: nav.xhtml

# Tabla de contenidos
no-toc: 
no-spine: 

# Si se quiere EPUB fijo
px-width: 
px-height: 
```

Solo basta señalar la información deseada después de los dos puntos. Estos
son los significados de cada uno de los campos:

* Generales:
	* `title`. Título de la obra. Por defecto `Sin título`.
	* `author`. Persona o colectivo que escribió la obra. Por defecto `Anónimo`.
	* `publisher`. Institución u organización que editó la obra. Por defecto no tiene valor.
	* `synopsis`. Reseña de la obra. Por defecto no tiene valor.
	* `category`. Categoría de la obra; p. ej., `Ficción, Novela`. Por defecto no tiene valor.
	* `version`. Versión de la obra. Este dato no es visible al usuario. Por defecto es `1.0.0`.
	* `cover`. Portada de la obra con su extensión de archivo (no introducir la ruta completa). Permite que se vea la miniatura de la portada en el lector de EPUB. Por defecto es `portada.jpg`.
	* `navigation`. Archivo XHTML para la tabla de contenidos. Por defecto es `nav.xhtml`.
* Tabla de contenidos:
	* `no-toc`. Nombre de los archivos XHTML, con o sin extensión, que no se desean mostrar en la tabla de contenidos. Por defecto no tiene valor.
	* `no-spine`. Nombre de los archivos XHTML, con o sin extensión, que no se desean mostrar en la tabla de contenidos ni en el orden de lectura; p. ej., anexos, notas al pie o tablas. Por defecto no tiene valor.
* Si se quiere EPUB fijo:
	* `px-width`. Anchura en pixeles para el EPUB.
	* `px-height`. Altura en pixeles para el EPUB.
	
> Si se creará un EPUB fijo, ambas medidas son necesarias. Si solo se 
especifica una, será ignorada por `pt-recreator`.

En el caso de que en `no-toc` o `no-spine` se deseé indicar más de un 
archivo, estos campos se han de escribir para generar un conjunto, por ejemplo:

```
no-toc: 
  - archivo01
  - archivo02
no-spine: [archivo03,archivo04]
```

Cualquiera de las dos sintaxis es correcta.

Para evitar errores en la sintaxis, se recomienda validar el archivo antes
de usar en `pt-recreator`:

* [Validador sencillo](http://codebeautify.org/yaml-validator).
* [Validador y JSON *parser*](https://yaml-online-parser.appspot.com/).
