# Changer.rb

## Índice

* [Descripción](#descripción)
* [Dependencias](#dependencias)
* [Uso](#uso)
* [Explicación](#explicación)

## Descripción

Este *script* cambia versiones de EPUB entre `3.0.0` y `3.0.1`.

## Dependencias

Este *script* requiere, además de Ruby:

* Zip 3.0. La mayoría de las distribuciones Linux y Mac OSX ya lo tienen
preinstalado. Para Windows es necesario descargar el `zip.exe` en Info-ZIP
desde ftp://ftp.info-zip.org/pub/infozip/win32/. Para Windows de 64 bits es el
archivo `zip300xn-x64.zip` y para 32 bits, `zip300xn.zip`.

* UnZip 6.0. La mayoría de las distribuciones Linux y Mac OSX ya lo tienen
preinstalado. Para Windows es necesario descargar el `unz600xn.exe` en Info-ZIP
desde ftp://ftp.info-zip.org/pub/infozip/win32/.

## Uso

**En desarrollo.**

###### 1. Desde el *shell* ejecutar el *script* cuyos parámetros sean la ruta al EPUB y la versión deseada.

Para mayor comodidad en el *shell* arrastra el archivo `changer.rb` y después
haz lo mismo con la carpeta del EPUB.

    Para usuarios de Windows, una vez instalado Ruby han de buscar el programa
    «Start Command Prompt with Ruby» para poder ejecutar esta orden.

###### 2. ¡Listo!

Se creará un nuevo EPUB con el mismo nombre y con la coletilla de la nueva
versión en la misma carpeta del EPUB original.

    Para usuarios de Windows, el proceso también requiere contar con unzip.exe
    y zip.exe que en su momento les pedirá arrastrar.

    OJO: al parecer exite un problema con unzip.exe en Windows.

## Explicación

Los EPUB versión 3.0.0 contienen el atributo `rendition` que ya no es necesario
para las versiones 3.0.1. Este *script* simplemente elimina o agrega este
atributo según las necesidades.
