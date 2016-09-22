# Creator.rb

## Índice

* [Descripción](#descripción)
* [Uso](#uso)
* [Explicación](#explicación)

## Descripción

Este *script* crea la estructura del EPUB, con la posibilidad de incluir una hoja de estilos CSS
predeterminada.

## Uso

###### 1. Desde el *shell* ejecutar el *script* cuyo único parámetro sea la ruta de la carpeta donde se creará el proyecto para el EPUB.

Para mayor comodidad en el *shell* arrastra el archivo `creator.rb` y después
haz lo mismo con la carpeta del EPUB.

    Para usuarios de Windows, una vez instalado Ruby han de buscar el programa
    «Start Command Prompt with Ruby» para poder ejecutar esta orden.

###### 1. El *script* creará la carpeta del proyecto con el nombre `EPUB-CREATOR` y ¡listo!

## Explicación

### Creación de un proyecto EPUB

Este *script* crea una carpeta para un proyecto genérico para un libro EPUB el cual una plantilla
para la portadilla y la legal (pueden eliminarse) y estilos CSS predeterminados (también eliminables).

### Estilos

La hoja de estilo cuenta con un reseteador para después agregar los estilos predeterminados, entre los que destacan las siguientes clases:

* `justificado`. Justifica el texto. No existe necesidad de explicitarlo en los párrafos, bloques de cita o listados, ya que sus etiquetas ya cuentan con esta justificación.
* `derecha`. Alinea el texto a la derecha.
* `izquierda`. Alinea el texto a la izquierda.
* `centrado`. Centra el texto.
* `frances`. Alinea el texto a la izquierda como un párrafo francés.
* `sinSangria`. Elimina el `text-indent`.
* `oculto`. Oculta el elemento.
* `versalitas`. Coloca el texto en versalitas.
* `versales`. Coloca el texto en versales.
* `titulo`. Para el título de la obra.
* `subtitulo`. Para el subtítulo de la obra.
* `legal`. Alinea el texto a la izquierda y sin sangría.
* `epigrafe`. Para los epígrafes.
* `espacioArriba`. Agrega un salto de línea.
* `espacioArriba2`. Agrega dos saltos de línea.
* `espacioArriba3`. Agrega tres saltos de línea.

### Árbol de archivos creados

* `EPUB-CREATOR`. La carpeta para el EPUB.
  * `mimetype`
  * `META-INF`
    * `container.xml`
  * `OPS`. Aquí va el contenido del libro.
    * `content.opf`. Para completar este archivo usa [`recreator.rb`](https://github.com/ColectivoPerroTriste/Herramientas/tree/master/EPUB/5%20-%20Recreador)
    * `css`
      * `styles.css`. Se crean estilos predeterminados. Vaciar el archivo si no se desean.
    * `img`. Para colocar las imágenes. Eliminar si el libro no contiene aunque se recomienda al menos colocar una imagen para la portada.
    * `toc`. Carpeta para las tablas de contenidos.
      * `nav.xhtml`. Tabla de contenidos para dispositivos recientes. Para completar este archivo usa [`recreator.rb`](https://github.com/ColectivoPerroTriste/Herramientas/tree/master/EPUB/5%20-%20Recreador)
      * `toc.ncx`. Tabla de contenidos para dispositivos antiguos. Para completar este archivo usa [`recreator.rb`](https://github.com/ColectivoPerroTriste/Herramientas/tree/master/EPUB/5%20-%20Recreador)
    * `xhtml`
      * `001-portadilla.xhtml`. Archivo para la portadilla que solo requiere ingresar el título y autor. Eliminar si no se desea.
      * `002-legal.xhtml`. Archivo para la legal, sustituir los elementos que se muestran. Eliminar si no se desea.
