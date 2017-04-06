# YAML

Al usar `pt-creator` se genera el archivo `meta-data.yaml` que sirve para 
los metadatos del libro. Si no se usará `pt-recreator` para generar el EPUB, 
este archivo **es innecesario y puede eliminarse**.

## Estructura

```
---
# Generales
title: Sin título
author: Anónimo
publisher: 
synopsis: 
category: 
version: 1.0.0
cover: 
navigation: nav.xhtml

# Tabla de contenidos
no-toc: 
no-spine: 
custom: 

# Si se quiere EPUB fijo
px-width: 
px-height: 
```

## Descripción de los campos

* Generales:
	* `title`. Título de la obra. Por defecto `Sin título`.
	* `author`. Persona o colectivo que escribió la obra. Por defecto `Anónimo`.
	* `publisher`. Institución u organización que editó la obra. Por defecto no tiene valor.
	* `synopsis`. Reseña de la obra. Por defecto no tiene valor.
	* `category`. Categoría de la obra; p. ej., `Ficción, Novela`. Por defecto no tiene valor.
	* `version`. Versión de la obra. Este dato no es visible al usuario. Por defecto es `1.0.0`.
	* `cover`. Portada de la obra con su extensión de archivo (no introducir la ruta completa); p. ej., `portada.jpg`. Permite que se vea la miniatura de la portada en el lector de EPUB. Por defecto no tiene valor.
	* `navigation`. Archivo XHTML para la tabla de contenidos. Por defecto es `nav.xhtml`.
* Tabla de contenidos:
	* `no-toc`. Conjunto de los archivos XHTML, con o sin extensión, que no se desean mostrar en la tabla de contenidos. Por defecto no tiene valor.
	* `no-spine`. Conjunto de los archivos XHTML, con o sin extensión, que no se desean mostrar en el orden de lectura; p. ej., anexos, notas al pie o tablas. Por defecto no tiene valor.
	* `custom`. Objetos jerarquizados de los XHTML, con o sin extensión, para elaborar una tabla de contenidos personalizada. Por defecto no tiene valor.
* Si se quiere EPUB fijo:
	* `px-width`. Anchura en pixeles para el EPUB. Por defecto no tiene valor.
	* `px-height`. Altura en pixeles para el EPUB. Por defecto no tiene valor.
	
## Consideraciones particulares

### EPUB fijo

Para elaborar un epub fijo es necesario ingresar el tamaño en pixeles
de la anchura y la altura con `px-width` y `px-height` respectivamente.
	
> Si solo se especifica una medida, `pt-recreator` no creará un EPUB fijo.

> Si las medidas no son convertibles a números enteros, marcará error.

### `no-toc` y `no-spine`

Para especificar el conjuto de archivo a ignorar, pueden usarse dos tipos
de sintaxis:

```
no-toc: 
  - archivo01.xhtml
  - archivo02
no-spine: [archivo03,archivo04]
```

> Si no se crea un conjunto, `pt-creator` ignorará estas especificaciones.

> Puede indicarse la extensión del archivo, aunque no es necesario, ya
que solo considera archivos XHTML.

### `custom`

Por defecto `pt-recreator` crea una tabla de contenidos corrida y ordenada
alfabéticamente. Si no se desea este comportamiento, es posible crear
una tabla de contenidos personalizada, con el orden y jerarquías deseadas,
por ejemplo:

```
custom:
  007-archivo-padre-2:
    008-archivo-hijo-4:
    009-archivo-hijo-5:
      011-archivo-nieto-2:
      010-archivo-nieto-1.xhtml:
    012-archivo-hijo-6:
  003-archivo-padre-1.xhtml:
    004-archivo-hijo-1:
    005-archivo-hijo-2:
    006-archivo-hijo-3:
  013-archivo-padre3:
```

Esto generaría esté índice:

1. `007-archivo-padre-2`
    1. `008-archivo-hijo-4`
    2. `009-archivo-hijo-5`
        1. `011-archivo-nieto-2`
        2. `010-archivo-nieto-1.xhtml`
    3. `012-archivo-hijo-6`
2. `003-archivo-padre-1.xhtml`
    1. `004-archivo-hijo-1`
    2. `005-archivo-hijo-2`
    3. `06-archivo-hijo-3`
3. `013-archivo-padre3`

> Para crear una nueva jerarquía se agregan dos espacios adicionales al
inicio.

> Si no se crean los objetos similares al ejemplo, `pt-creator` ignorará 
estas especificaciones.

> Puede indicarse la extensión del archivo, aunque no es necesario, ya
que solo considera archivos XHTML.

## Validadores

La estructura tiene que ser correcta, para ello la ayuda de validadores
quizá sea pertinente:

* [Validador sencillo](http://codebeautify.org/yaml-validator).
* [Validador y JSON *parser*](https://yaml-online-parser.appspot.com/).
