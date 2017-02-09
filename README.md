# Herramientas

Perro triste está creando un conjunto de *scripts* pensados para agilizar
o automatizar varios de los procesos del quehacer editorial con el fin
de que las posibilidades tecnológicas no se presenten como un reto o un
inconveniente para quien edita o diseña una publicación.

Las herramientas siguen un modelo de [desarrollo continuo](https://es.wikipedia.org/wiki/Liberaci%C3%B3n_continua)
según el modelo del *single source and online publishing*.

## Índice

* [SSOP](#single-source-and-online-publishing-ssop)
* [Requisitos](#requisitos)
* [Utilización](#utilización)
* [Binarios](#binarios)
* [Pendientes](#pendientes)
* [Licencia](#licencia)

---

# *Single source and online publishing* (SSOP)

Esta metodología de trabajo implica la idea de que a partir de un archivo
madre en marcado ligero sea posible crear de manera ramificada distintas 
salidas según el formato de la publicación deseada.

El archivo madre se diferencia del archivo de origen en que, aún siendo
ambos digitales, el primero ya ha sido tratado para ajustarse a las posibilidades 
y lineamientos de la metodología del SSOP.

El modelo ramificado de publicación se diferencia del modelo cíclico, común
en la tradición editorial, en que no es necesario esperar a que un formato
se dé por concluido con el fin de empezar la creación de otro.

Las ventajas de esta metodología son:

1. un mayor control semántico y estructural del contenido,
2. el fin al dilema donde «el tiempo de publicación es proporcional a la 
cantidad de formatos deseados»,
3. la practicidad de prescindir de la creación de respaldos por el control
de versiones del repositorio de la publicación,
4. la ventaja de actualizar la obra continuamente y sin dificultades,
5. la posibilidad de agregar excepciones según cada formato de salida, y
6. el fin a la transmisión de errores entre formatos que acontece al pasar
de un formato de salida a otro.

![Flujo de trabajo](flujo-de-trabajo.jpg)

# Requisitos

## Todos

* [Ruby](https://www.ruby-lang.org/es/) > 1.9.3
  * Gema `activesupport` => `gem install activesupport`
  
## Digitalización

* [Tesseract](https://github.com/tesseract-ocr/tesseract)
* [Ghostscript](https://www.ghostscript.com/)

## Archivo Madre

* [Pandoc](http://pandoc.org/)

# Utilización

Las herramientas pueden utilizarse de tres maneras:

1. Escribiendo `ruby` en la terminal y arrastrando el *script* correspondiente.
2. Arrastrando el *script* deseado a la terminal.
3. Instalando los binarios para utilizar los *script* directamente.

# Binarios

**Solo para sistemas UNIX (Linux y Mac OS X).**

Los binarios permiten acceder a las herramientas desde la terminal sin necesidad
de indicar la ruta del `script` ni de arrastrarlo. Su instalación es muy sencilla:

###### 1. Ingresa a esta carpeta (`Herramientas`) en la terminal.
###### 2. Llama al instalador con `./instalar.sh` o `sh instalar.sh`.
###### 3. ¡Listo!

## Utilización de los binarios

Solo es necesario escribir el nombre del binario para llamar al script:

* `pt-pandog` llama a `pandog.rb`, cuya documentación se encuentra en [`Archivo-madre/1-Pandog`](https://github.com/ColectivoPerroTriste/Herramientas/tree/master/Archivo-madre/1-Pandog).
* `pt-tegs` llama a `tegs.rb`, cuya documentación se encuentra en [`Digitalizacion/3-Tegs`](https://github.com/ColectivoPerroTriste/Herramientas/tree/master/Digitalizacion/3-Tegs).
* `pt-creator` llama a `creator.rb`, cuya documentación se encuentra en [`EPUB/1-Creador`](https://github.com/ColectivoPerroTriste/Herramientas/tree/master/EPUB/1-Creador).
* `pt-divider` llama a `divider.rb`, cuya documentación se encuentra en [`EPUB/2-Divisor`](https://github.com/ColectivoPerroTriste/Herramientas/tree/master/EPUB/2-Divisor).
* `pt-notes` llama a `notes.rb`, cuya documentación se encuentra en [`EPUB/3-Notas`](https://github.com/ColectivoPerroTriste/Herramientas/tree/master/EPUB/3-Notas).
* `pt-cites` llama a `cites.rb`, cuya documentación se encuentra en [`EPUB/4-Bibliografia`](https://github.com/ColectivoPerroTriste/Herramientas/tree/master/EPUB/4-Bibliografia).
* `pt-index` llama a `index.rb`, cuya documentación se encuentra en [`EPUB/5-Indice`](https://github.com/ColectivoPerroTriste/Herramientas/tree/master/EPUB/5-Indice).
* `pt-recreator` llama a `recreator.rb`, cuya documentación se encuentra en [`EPUB/6-Recreador`](https://github.com/ColectivoPerroTriste/Herramientas/tree/master/EPUB/6-Recreador).
* `pt-changer` llama a `changer.rb`, cuya documentación se encuentra en [`EPUB/7-Cambiador`](https://github.com/ColectivoPerroTriste/Herramientas/tree/master/EPUB/7-Cambiador).

    **Nota**: si ningún binario se encuentra, es necesario refrescar el archivo de
    inicialización de usuario que `./instalar.sh` nos menciona. Para hacer esto
    solo tiene que cerrar y volver a abrir la terminal. Si no se desea cerrarla,
    se ha de escribir `source [archivo de inicialización de usuario]`. Este
    procedimiento solo se hace una vez, cuando se termina la instalación.

# Pendientes

* EPUB
  * Todos.
    * Terminar de resolver el problema de las rutas relativas en los parámetros de cada `script`.
  * `divider.rb`.
    * Evitar que se copien las etiquetas con `ºº` al título.
  * `notes.rb`.
    * No se añade el primer encabezado cuando se reinicia la numeración y se crea el `9999-notes.xhtml`.
    * Los encabezados que se añaden a `9999-notes.xhtml` heredan espacios al principio y al final.
    * Evitar que los encabeazados añadidos a `9999-notes.xhtml` hereden etiquetas HTML indeseadas.
    * Se detectó que no se elimina la etiqueta de cierre de párrafo en la nota
    cuando está viene en el archivo de texto; el caso particular es que en el
    archivo de texto hay una nota como esta `<p><em>Algo</em>.</p>`.
    * Se están creando espacios antes del `body` sin importar que las notas se creen en `9999-notes.xhtml`.
    * Agregar la clase `n-note-p` a los subsiguientes párrafos de una nota cuando está tiene más de un párrafo.
    * En Linux no se ordenan correctamente las notas cuando se crea `9999-notes.xhtml` con división por sección.
  * `cites.rb`.
    * Terminar el desarrollo.
  * `recreator.rb`.
    * No guarda la nueva versión cuando obtiene los datos de `recreator-metadata`.
    * Agregar posibilidad de anidar TOC, al menos donde `part` es padre de `chapter`.
    * Tabla de contenidos jerarquizado.
    * En Windows `FileUtils.rm_rf` no elimina el EPUB previo, si lo hay; el uso de `FileUtils.remove_dir` genera errores de permisos; **se debe a que no se cierran los archivos**.
  * `changer.rb`.
    * En Windows `FileUtils.rm_rf` no elimina el EPUB previo, si lo hay, ni los archivos temporales; el uso de `FileUtils.remove_dir` genera errores de permisos; **se debe a que no se cierran los archivos**.
    * ¿Compatibilidad para versión EPUB 2.0.1?

# Licencia

Las herramientas están bajo licencia GPL v3.
