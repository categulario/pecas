# YAML

Al usar `pc-creator` se genera el archivo `meta-data.yaml` que sirve para 
los metadatos del libro. Si no se usará `pc-recreator` para generar el EPUB, 
este archivo **es innecesario y puede eliminarse**.

> Al usar `pc-automata` el archivo se llama `automata_meta-data.yaml`.

## Estructura

La estructura básica del archivo creado es la siguiente:

```
---
# Generales
title: Sin título
subtitle: 
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

# Si se quiere EPUB fijo
px-width: 
px-height: 

# Fallbacks
fallback: 

# WCAG:
summary: Este EPUB está optimizado para personas con deficiencias visuales; cualquier observación por favor póngase en contacto.
mode:
  - textual
  - visual
mode-sufficient:
  - textual, visual
  - textual
feature:
  - structuralNavigation
  - alternativeText
  - resizeText
api: ARIA
control:
hazard:
```

## Descripción de los campos

| Llave | Tipo | Valor | Descripción |
|-------|------|-------|-------------|
| Generales | | | |
| `title` | `String` | `"Sin título"` | Título de la obra. |
| `subtitle` | `String` | `nil` | Subtítulo de la obra. |
| `author` | `Array` | `"Apellido, Nombre"` | Personas o colectivos que escribieron la obra. |
| `publisher` | `Array` | `nil` | Institución u organización que editó la obra. |
| `synopsis` | `String` | `nil` | Reseña de la obra. |
| `category` | `Array` | `nil` | Categoría de la obra; p. ej., `Ficción` y `Novela` |
| `version` | `String` | `1.0.0` | Versión de la obra. Este dato no es visible para el usuario. |
| `cover` | `String` | `nil` | Portada de la obra con su extensión de archivo (no introducir la ruta completa); p. ej., `portada.jpg`. Permite que se vea la miniatura de la portada en el lector de EPUB. |
| `navigation` | `String` | `"nav.xhtml"` | Archivo XHTML para la tabla de contenidos. |
| Tabla de contenidos | | | |
| `no-toc` | `Array` | `nil` | Conjunto de archivos XHTML, con o sin extensión, que no se desean mostrar en la tabla de contenidos. |
| `no-spine` | `Array` | `nil` | Conjunto de archivos XHTML, con o sin extensión, que no se desean mostrar en el orden de lectura; p. ej., anexos, notas al pie o tablas. |
| `custom` | `Object` | `nil` | Objetos jerarquizados de los XHTML, con o sin extensión, para elaborar una tabla de contenidos personalizada. |
| EPUB fijo | | | |
| `px-width` | `Array` | `nil` | Anchura en pixeles para el EPUB. |
| `px-height` | `Array` | `nil` | Altura en pixeles para el EPUB. |
| Fallbacks | | | |
| `fallback` | `Object` | `nil` | Objetos jerarquizados de los recursos externos, con o sin extensión, para poderlos incluir en el EPUB. |
| WCAG | | | |
| `summary` | `String` | `"Este EPUB[…]"` | Breve texto donde se indican las características de accesibilidad de la publicación. |
| `mode` | `Array` | `"textual"`<br/>`"visual"` | Modo en como ha de usarse la obra. |
| `mode-sufficient` | `Array` | `"textual, visual"`<br/>`"textual"` | Los diferentes sentidos que pueden combinarse para el uso de la publicación. |
| `feature` | `Array` | `"structuralNavigation"`<br/>`"alternativeText"`<br/>`"resizeText"` | Las características de la publicación. |
| `hazard` | `Array` | `"none"` | Características que pueden ser perjudiciales para algunos usuarios. |
| `control` | `Array` | `nil` | Los métodos como se puede controlar la publicación. |
| `api` | `String` | `"ARIA"` | El tipo de API que se utiliza para la accesibilidad. |

> Todos los campos vacíos son ignorados ya que son `nil`.
	
## Consideraciones particulares

### Conjuntos

Los `Array` pueden escribirse de dos formas. La más clara y sencilla:

```
category:
  - Categoría 1
  - Categoría 2
``` 

La más compacta:

```
category: ["Categoría 1","Categoría 2"]
```

### Nombre de los autores

La separación `Apellido, Nombre` no es obligatoria; si no se desea,
porque el autor no tiene alguno de los elementos, o no se quiere, 
porque se trata de un colectivo, solo evítese el uso de comas; por 
ejemplo: `Anónimo` o `Algún colectivo`.

### EPUB fijo

Para elaborar un epub fijo es necesario ingresar el tamaño en pixeles
de la anchura y la altura con `px-width` y `px-height` respectivamente.
	
> Si solo se especifica una medida, `pc-recreator` no creará un EPUB fijo.

> Si las medidas no son convertibles a números enteros, marcará error.

### `no-toc` y `no-spine`

Es posible usar expresiones regulares en lugar de nombres específicos,
solo es necesario poner la expresión entre diagonales, p. ej. `/regex/`.

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

También es posible incluir encabezados `h2`-`h6` escribiendo 
`--id(identificador)--`, a la vez que es hijo de un archivo, 
por ejemplo:

```
custom:
  007-archivo-padre-2:
    008-archivo-hijo-4:
    009-archivo-hijo-5:
      --id(identificador1)--:
      010-archivo-nieto-1.xhtml:
    012-archivo-hijo-6:
  003-archivo-padre-1.xhtml:
    --id(identificador2)--:
    005-archivo-hijo-2:
    006-archivo-hijo-3:
  013-archivo-padre3:
```

Con esto automáticamente tomará el texto contenido en los encabezados
`h2`-`h6`, siempre y cuando el identificador exista; de lo contrario, el
identificador será ignorado.

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

### WCAG

Las *Web Content Accessibility Guidelines* son para «facilitar el 
acceso de las personas con discapacidad, desarrollando pautas de 
accesibilidad, mejorando las herramientas para la evaluación y 
reparación de accesibilidad Web, llevando a cabo una labor educativa 
y de concienciación en relación a la importancia del diseño accesible 
de páginas Web y abriendo nuevos campos de accesibilidad a través de 
la investigación en esta área».

Véase el [artículo](https://es.wikipedia.org/wiki/WCAG_1.0) de la 
Wikipedia para más información.

Para conocer los tipos de valores que pueden introducirse en el YAML,
consúltese esta [sección](http://kb.daisy.org/publishing/docs/metadata/schema-org.html)
del sitio del [DAISY Consortium](http://www.daisy.org/).

## Validadores

La estructura tiene que ser correcta, para ello la ayuda de validadores
quizá sea pertinente:

* [Validador sencillo](http://codebeautify.org/yaml-validator).
* [Validador y JSON *parser*](https://yaml-online-parser.appspot.com/).
