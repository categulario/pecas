# Recreator.rb

## Índice

* [Descripción](#descripción)
* [Dependencias](#dependencias)
* [Uso](#uso)
* [Explicación](#explicación)

## Descripción

Este `script` recrea los archivos OPF, NCX y NAV así como crea o recrea el
archivo EPUB.

## Dependencias

Este `script` requiere:

* Ruby. [Véase aquí para instalar]
(https://www.ruby-lang.org/en/documentation/installation/#rubyinstaller). La
versión mínima de Ruby que se ha probado es la 1.9.3p484.

* Zip 3.0. La mayoría de las distribuciones Linux y Mac OSX ya lo tienen
preinstalado. Para Windows es necesario descargar el `zip.exe` en Info-ZIP
desde ftp://ftp.info-zip.org/pub/infozip/win32/. Para Windows de 64 bits es el
archivo `zip300xn-x64.zip` y para 32 bits, `zip300xn.zip`.

## Uso

###### 1. Desde el *shell* ejecutar el `script` cuyo único parámetro sea la ruta a la carpeta del EPUB.

Para mayor comodidad en el *shell* arrastra el archivo `recreator.rb` y después
haz lo mismo con la carpeta del EPUB.

    Para usuarios de Windows, una vez instalado Ruby han de buscar el programa
    «Start Command Prompt with Ruby» para poder ejecutar esta orden.

###### 2. Indica la carpeta donde están los archivos para el EPUB.

Se tiene que poner la ruta absoluta, para mayor comodidad solo arrastra
la carpeta al *shell*.

###### 3. A continuación responde lo que se te pide.

*Si se crea por primera vez*. Para poder crear ciertos metadatos es necesario
indicar el título, el autor o editor principal, la editorial, la sinopsis, el
lenguaje, la versión, la portada (opcional), las secciones ocultas (opcionales)
o las que no aparecen en la tabla de contenidos (opcionales) así como el NAV
(`nav.xhtml` por defecto) de la obra.

    Se recomienda ampliamente indicar la portada, ya que así puede asignarse
    la miniatura que despliegan las bibliotecas digitales.

    Las secciones que no se ven en la tabla de contenidos están pensadas para
    solo mostrarse en el seguimiento lineal de la obra, útiles para información
    secundaria como portadillas o legales.

    Las secciones ocultas no se muestran en la lectura lineal de la obra ni
    en la tabla de contenidos, útiles para información terciaria como notas al
    pie o tablas.

    Para mayor flexibilidad, cabe la posibilidad de indicar algún nombre
    personalizado para el NAV.

*Si es una creación posterior*. Lo primero que se ha de responder es si se
desean conservar los metadatos existentes. Si se responde que sí, lo único que
se ha de volver a introducir es la versión de la obra. Si se responde que no,
se vuelven a pedir todos los metadatos, como si se crearan por primera vez. Por
defecto la respuesta es sí.

    Los metadatos existentes no excluyen la recreación de los archivos opf,
    ncx y nav. Solo evita el trabajo repetitivo de ingresar los metadatos.

    Siempre se pide la versión de la obra para permitir un control de
    versiones.

###### 4. Para UNIX ¡es todo!, para Windows hay que arrastrar el `zip.exe` cuando lo pida.

  * Desde el *shell* puedes leer cómo se recrean o crean los siguientes
  archivos:

  1. El archivo OPF.
  2. El archivo NCX.
  3. El archivo NAV.
  4. El EPUB.

## Explicación

### Remedio a las tareas repetitivas

La mayoría de los archivos EPUB tienen similitudes en su estructura, lo cual
hace conveniente la utilización de plantillas. Si bien esto evita el problema
de crear la estructura desde cero, persisten las dificultades de rehacer el OPF,
el NCX y el NAV. En la gran mayoría de los casos, solo alguns metadatos
requieren de una intervención directa. Este `script` está pensado para
solventar esta problemática.

Para evitar la recreación en carpetas potencialmente conflictivas, el `script`
solo arranca si se encuentra en la carpeta raíz del futuro EPUB, al localizar
el archivo `mimetype`.

### Recreación del OPF

El OPF comprende tres partes: los metadatos, el manifiesto y la espina. En los
metadatos indicamos la información sobre el archivo (el título de la obra, por
ejemplo). En el manifiesto referimos todos los archivos que contienen el EPUB.
En la espina determinamos el orden de lectura del libro.

La recreación de este archivo involucra tres etapas para cada una de estas
partes. La primera, la recreación de los metadatos, involucra cierta
interveción directa mediante la obtención de información por parte de quien lo
usa (existen ciertos metadatos que no requieren de intervención directa, como
la fecha de creación). El resto de las partes obtienen su información a partir
de los archivos presentes para el EPUB, gracias a esto es posible crear
identificadores, obtener los tipos de medios así como la adición de propiedades
(como la que indica cuál es la portada o cuáles archivos no forman parte de
la lectura lineal).

Mucha de esta información es reutilizada para la recreación del NCX y del NAV.
Además, para evitar volver a introducir la información cada vez que se recreen
los archivos, se guarda un archivo `.recreator-metadata` con esta información
en la raíz de los archivos para el EPUB.

    Si se utiliza una herramienta externa para crear el EPUB,
    se tiene que asegurar que no se incluya el archivo «.recreator-metadata».

    La manipulación directa del «.recreator-metadata» no ocasiona ningún
    conflicto.

### Recreación del NCX

Debido a su similitudes con el NAV, la recreación del NCX se da en paralelo con
el NAV. En un primer momento se excluyen todos los archivos que no sean XHTML,
o que se han escogido para no mostarse. Por último se obtiene una relación
entre el nombre del archivo y el título de ese documento.

    Todos los archivos se organizan alfabéticamente para evitar órdenes
    aleatorios.

    Para un óptimo resultado, todos los archivos XHTML que no sean el NAV han
    de estar en una misma carpeta.

    Los títulos de los archivos se extraen del contenido presente en la
    etiqueta <title>.

### Recreación del NAV

Por su parecido con el NCX, la recreación del NAV es semejante a la del NCX. La
principal diferencia es la extracción de los números de página (si los hay).
Este paso adicional consiste en llevar a cabo una relación entre el nombre del
archivo con sus respectivas páginas, para luego pasar a agregarse al NAV.

    La estructura para los números de página, independientemente de su
    ubicación, ha de ser «epub:type="pagebreak" id="page1" title="1"».

### Creación del EPUB

Para que Ruby tenga la posibilidad de trabajar con archivos comprimidos, como
es el caso de los archivos EPUB, es necesaria la instalación de una gema. Con
el fin de no complicar la instalación, se ha tomado la decisión de prescindir
de ella. Por ello es que la creación del EPUB se hace a partir de un llamado a
Zip 3.0 mediante Ruby.

El EPUB se crea en la carpeta padre de la raíz de los archivos para el EPUB
con el mismo nombre de la raíz. Si ya existe un EPUB con ese nombre, lo elimina
para comprimir.

### Árbol de archivos creados

* `CARPETA-PARA-EPUB`. La carpeta para el EPUB en cuya raíz está presente el
`mimetype`.
  * `.recreator-metadata`. El archivo oculto que se crea o modifica para
  conservar algunos metadatos.
* `CARPETA-PARA-EPUB.epub`. El EPUB que se crea.
