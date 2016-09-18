# Tesseractall.rb

## Índice

* [Descripción](#descripción)
* [Dependencias](#dependencias)
* [Uso](#uso)
* [Explicación](#explicación)

## Descripción

Este pequeño script ayuda a utilizar Tesseract en todas las imágenes PNG o TIF
de la carpeta seleccionada.

##Dependencias

Este `script` requiere:

* Ruby. [Véase aquí para instalar]
(https://www.ruby-lang.org/en/documentation/installation/#rubyinstaller). La
versión mínima de Ruby que se ha probado es la 1.9.3p484.

* Tesseract. [Véase aquí para instalar]
(https://github.com/tesseract-ocr/tesseract).

## Uso

###### 1. Desde el *shell* ejecutar el `script`

Para mayor comodidad en el *shell* arrastra el archivo `tesseractall.rb`.

    Para usuarios de Windows, una vez instalado Ruby han de buscar el programa
    «Start Command Prompt with Ruby» para poder ejecutar esta orden.

###### 2. Escribe el prefijo del lenguaje a detectar

El listado de los prefijos puede encontrarse
[aquí](http://manpages.ubuntu.com/manpages/precise/man1/tesseract.1.html#contenttoc4).

###### 4. Indica la carpeta que contiene las imágenes

Para mayor comodidad en el *shell* arrastra la carpeta con las imágenes.

###### 5. ¡Es todo!

El *script* utilizará Tesseract para extrer el texto de cada página en formato
`txt` y `pdf`.

## Explicación

El *script* simplemente genera un *loop* que recorre todos los archivos PNG o
TIF de la carpeta indicada, mientras ejecuta dos comandos de Tesseract para generar
archivos `txt` y `pdf`. Este *script* es prescindible si se lleva a cabo
[un *loop* desde la terminal](http://www.cyberciti.biz/faq/bash-for-loop/).

Los archivos se generarán según donde se esté situado en la terminal.
