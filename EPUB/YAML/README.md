# YAML

Al usar `pc-creator` se genera el archivo `meta-data.yaml` que sirve para 
los metadatos del libro. Si no se usará `pc-recreator` para generar el EPUB, 
este archivo **es innecesario y puede eliminarse**.

## Estructura

Sea que se quiera trabajar con el archivo `meta-data.yaml` o crear
uno desde cero, la estructura básica es la siguiente:

```
---
# Generales
title: Sin título
author:
  - Apellido, Nombre
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

# Fallbacks
fallback: 

# Si se quiere EPUB fijo
px-width: 
px-height: 
```

## Descripción de los campos

* Generales:
	* `title`. Título de la obra. Por defecto `Sin título`.
	* `author`. Personas o colectivos que escribieron la obra. Por defecto `Apellido, Nombre`.
	* `publisher`. Institución u organización que editó la obra. Por defecto no tiene valor.
	* `synopsis`. Reseña de la obra. Por defecto no tiene valor.
	* `category`. Categoría de la obra; p. ej., `Ficción, Novela`. Por defecto no tiene valor.
	* `version`. Versión de la obra. Este dato no es visible para el usuario. Por defecto es `1.0.0`.
	* `cover`. Portada de la obra con su extensión de archivo (no introducir la ruta completa); p. ej., `portada.jpg`. Permite que se vea la miniatura de la portada en el lector de EPUB. Por defecto no tiene valor.
	* `navigation`. Archivo XHTML para la tabla de contenidos. Por defecto es `nav.xhtml`.
* Tabla de contenidos:
	* `no-toc`. Conjunto de archivos XHTML, con o sin extensión, que no se desean mostrar en la tabla de contenidos. Por defecto no tiene valor.
	* `no-spine`. Conjunto de archivos XHTML, con o sin extensión, que no se desean mostrar en el orden de lectura; p. ej., anexos, notas al pie o tablas. Por defecto no tiene valor.
	* `custom`. Objetos jerarquizados de los XHTML, con o sin extensión, para elaborar una tabla de contenidos personalizada. Por defecto no tiene valor.
* Fallbacks:
    * `fallback`. Objetos jerarquizados de los recursos externos, con o sin extensión, para poderlos incluir en el EPUB. Por defecto no tiene valor.
* Si se quiere EPUB fijo:
	* `px-width`. Anchura en pixeles para el EPUB. Por defecto no tiene valor.
	* `px-height`. Altura en pixeles para el EPUB. Por defecto no tiene valor.
	
## Consideraciones particulares

### Nombre de los autores

Es posible indicar cero o más autores. Si no se desea autores, solo
déjese en blanco:

```
author:
publisher: 
```

Para uno o más autores se requiere de un conjunto con la forma:

```
author:
  - Apellido1, Nombre1
  - Apellido2, Nombre2
```

O con la forma:

```
author: ["Apellido1, Nombre1", "Apellido2, Nombre2"]
```

> La separación `Apellido, Nombre` no es obligatoria; si no se desea,
> porque el autor no tiene alguno de los elementos, o no se quiere, 
> porque se trata de un colectivo, solo evítese el uso de comas; por 
> ejemplo: `Anónimo` o `Algún colectivo`.

### EPUB fijo

Para elaborar un epub fijo es necesario ingresar el tamaño en pixeles
de la anchura y la altura con `px-width` y `px-height` respectivamente.
	
> Si solo se especifica una medida, `pc-recreator` no creará un EPUB fijo.

> Si las medidas no son convertibles a números enteros, marcará error.

### `no-toc` y `no-spine`

Para especificar el conjuto de archivos a ignorar, pueden usarse dos tipos
de sintaxis:

```
no-toc: 
  - archivo01.xhtml
  - archivo02
no-spine: [archivo03,archivo04]
```

> Es posible usar expresiones regulares en lugar de nombres específicos,
solo es necesario poner la expresión entre barras, p. ej. `/regex/`.

> Si no se crea un conjunto, `pc-creator` ignorará estas especificaciones.

> Puede indicarse la extensión del archivo, aunque no es necesario, ya
que solo considera archivos XHTML.

### `custom`

Por defecto `pc-recreator` crea una tabla de contenidos corrida y ordenada
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

> Si no se crean los objetos similares al ejemplo, `pc-recreator` 
ignorará estas especificaciones.

> Puede indicarse la extensión del archivo, aunque no es necesario, ya
que solo considera archivos XHTML.

### *Fallbacks*

En ciertas ocasiones en el EPUB se querrá incluir un recurso externo
(un tipo de archivo que no es soportado directamente), por ejemplo un
PDF embebido.

Para ello es necesario indicar un *fallback* y así tener un EPUB
válido. La indicación es sencilla:

```
fallback: 
  anexo.pdf: algun_archivo.xhtml
```

En primer elemento antes de los dos puntos es el recurso externo. El 
elemento después de los dos puntos es el archivo XHTML desde donde se 
llama al recurso a partir de un enlace; siguiendo con el ejemplo,
en `algun_archivo.xhtml` se tiene:

```html
...
<p><a href="anexo.pdf">Abrir archivo</a>.</p>
...
```

> Por el momento solo se admiten archivo PDF, si hay otro recurso externo
que quieras agregar, ¡ponte en contacto!

> Para crear una nueva jerarquía se agregan dos espacios adicionales al
inicio.

> Si no se crean los objetos similares al ejemplo, `pc-recreator` 
ignorará estas especificaciones.

> Puede indicarse la extensión del archivo externo o del XHTML, aunque 
no es necesario.

## Validadores

La estructura tiene que ser correcta, para ello la ayuda de validadores
quizá sea pertinente:

* [Validador sencillo](http://codebeautify.org/yaml-validator).
* [Validador y JSON *parser*](https://yaml-online-parser.appspot.com/).
