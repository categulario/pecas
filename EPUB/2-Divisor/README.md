# Divider.rb

## Índice

* [Descripción](#descripción)
* [Uso](#uso)
* [Explicación](#explicación)

---

## Descripción

Este *script* divide un solo documento HTML o XHTML en varios documentos XHTML
cada vez que detecta encabezados `h1`. Principalmente está pensado como un proceso más dentro de la metodología del *single source publishing*.

## Uso

###### 1. Desde el *shell* ejecutar el *script* cuyo único parámetro sea la ruta al archivo HTML o XHTML a dividir.

Para mayor comodidad en el *shell* arrastra el archivo `recreator.rb` y después
haz lo mismo con el archivo HTML o XHTML a dividir.

    Para usuarios de Windows, una vez instalado Ruby han de buscar el programa
    «Start Command Prompt with Ruby» para poder ejecutar esta orden.

###### 2. Arrastra la carpeta donde deseas que se coloquen los archivos que contienen las partes del documento dividido.

###### 3. Arrastra el archivo CSS que desees vincular.

###### 4. Indica el número con el cual iniciar la numeración de los documentos.

    Este número se agrega al inicio del nombre de cada uno de los archivos para
    que queden ordenados alfabéticamente.

###### 5. Contesta si deseas agregan un `epub:type` al `<body>` de cada archivo generado.

    Por defecto la respuesta es afirmativa.

###### 6. El archivo se empezará a dividir para generar archivos XHTML con cada una de las partes.

    Si se optó por introducir un epub:type, en la creación de cada archivo se te
    pedirá introducir el valor para este atributo.

###### 7. ¡Listo! Ya tendrás una serie de archivos XHTML para continuar con el desarrollo del EPUB.

## Explicación

### De un archivo de origen a los archivos para el EPUB

Este *script* facilita la división de un archivo HTML o XHTML, que al menos
engloba el contenido principal de una obra, a una serie de archivos XHTML por
cada parte del libro.

La idea detrás de esto es la metodología del *single source publishing*, por el
cual desde un archivo «madre» se crean diferentes formatos para publicaciones
digitales o impresas. En particular, la serie de procesos que se están empleando
son:

1. Translado de un enfoque WYSIWYG, por lo regular de un archivo de procesador
de texto o del texto extraído de un PDF, a uno de etiquetado ligero con
Markdown, consiguiéndose así un archivo «madre».

2. Este archivo «madre» se convierte al formato deseado mediante
[`pandoc`](http://pandoc.org/). Por ejemplo, a `.tex` para TeX, `.xml` para
InDesign, o `.html` para Scribus o EPUB.

3. Para el caso del EPUB, con este *script* se particiona el documento para
crear un archivo XHTML con cada una de las partes de la obra.

4. Se continúa con el desarrollo del EPUB, mediante el auxilio de las otras
herramientas presentes en este repositorio. (:

### Índice a los archivos

La necesidad de un índice para la numeración de los archivos es para evitar que
estos queden alfabéticamente desordenados una vez divididos, algo que podría
acarrear resultados indeseados al utilizar
[`recreator.rb`](https://github.com/ColectivoPerroTriste/Herramientas/tree/master/EPUB/5%20-%20Recreador).

El índice por defecto es tres ya que el proyecto para EPUB generado por
[`creator.rb`](https://github.com/ColectivoPerroTriste/Herramientas/tree/master/EPUB/1%20-%20Creador) produce dos archivos, uno para la portadilla y otro para la legal
(`001-portadilla.xhtml` y `002-legal.xhtml` respectivamente).

La numeración automáticamente se genera en tres dígitos. Por ejemplo, si el
número de índice elegido es el «1», este se transformará en «001». También es
posible ingresar directamente «001», aunque no es necesario.

### El atributo `epub:type`

Como se especifica en
[este documento](https://idpf.github.io/epub-vocabs/structure) del IDPF, el
`epub:type` define un conjunto de propiedades relativas a la descripción de la
estructura semántica de un trabajo escrito. Es decir, mediante este atributo,
el cual puede insertarse en cualquier etiqueta HTML, se hace mención sobre qué
tipo de texto se trata. Por ejemplo, si un párrafo es una nota al pie, entonces
a su etiqueta de apertura puede añadírsele un valor semántico mediante un
`epub:type` semejante a `<p epub:type="footnote">`.

Con este *script* existe la posibilidad de añadir esta estructura semántica al
`<body>`, manifestándose así que todo el archivo es de un tipo de texto. Con
esto se evita la molestia de añadir previamente atributos `epub:type` al
documento HTML o XHTML a dividir. Si se desea una estructuración más detenida o
no se desea esta estructura semántica, solo indíquese que no se quiere agregar
un `epub:type` al `<body>` de cada archivo creado.
