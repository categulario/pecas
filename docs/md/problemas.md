# Solución de problemas / +++FAQ+++

Hay ocasiones donde el uso o instalación de Pecas es un poco conflictivo.
Aquí están los problemas más comunes y sus soluciones.

* [En todos los sistemas operativos](#en-todos-los-sistemas-operativos)
  * [¿Cómo actualizo Pecas](#como-actualizo-pecas)
  * [No cuento con internet, ¿cómo puedo leer la documentación?](#no-cuento-con-internet-como-puedo-leer-la-documentacion)
  * [Pecas no puede instalarse: `El fichero ya existe`](#pecas-no-puede-instalarse-el-fichero-ya-existe)
  * [Uso de EpubCheck para verificar +++EPUB+++](#uso-de-epubcheck-para-verificar-epub)
  * [Uso de Ace para verificar +++EPUB+++](#uso-de-ace-para-verificar-epub)
  * [¿Cuál fuente usa Pecas por defecto?](#cual-fuente-usa-pecas-por-defecto)
* [En Linux](#en-linux)
  * [Error con `pc-tiff2pdf`: `tiffcp: no se encontró la orden`](#error-con-pctiff2pdf-tiffcp-no-se-encontro-la-orden)
* [En Mac](#en-mac)
  * [Pecas no puede descargarse: +++SSL_ERROR_SYSCALL+++](#pecas-no-puede-descargarse-ssl-error-syscall)
* [En Windows](#en-windows)
  * [¿Cómo uso Pecas en Windows?](#como-uso-pecas-en-windows)

## En todos los sistemas operativos {.espacio-arriba3}

### ¿Cómo actualizo Pecas?

Pecas se actualiza constantemente, se arreglan errores o se implementan
nuevos elementos. ¡No te quedes fuera!, de vez en cuando ejecuta:

```
pc-doctor --update
```

### No cuento con internet, ¿cómo puedo leer la documentación?

Todas las herramientas de Pecas cuentan con el comando `-h` que permite
leer su documentación. _Por ejemplo_:

```
pc-automata -h
```

### Pecas no puede instalarse: `El fichero ya existe`

Esto quiere decir que falló la primera pretensión de instalar Pecas. 
En posteriores intentos se ha querido crear una carpeta llamada `.pecas`, 
pero esta ya existe. Para solucionar este problema, hay que eliminar 
ese fichero ejecutando lo siguiente:

```bash
rm -rf ~/.pecas
```

Para terminar, repite de nuevo [la instalación](../index.html#instalacion).

### Uso de EpubCheck para verificar +++EPUB+++

[EpubCheck](https://github.com/IDPF/epubcheck) es la herramienta oficial 
para verificar que la estructura del +++EPUB+++ sea la correcta.

Es necesario tener instalado Java SE Development Kit (+++JDK+++),
sin importar tu sistema operativo, [descárgalo aquí](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html).
{.espacio-arriba1 .sin-sangria}

> Nota: no es necesario instalarlo, puedes verificar archivos +++EPUB+++
> con EpubCheck en línea desde [este enlace](http://validator.idpf.org/).

### Uso de Ace para verificar +++EPUB+++

[Ace](https://daisy.github.io/ace/) es una herramienta que permite
verificar el grado de accesibilidad del +++EPUB+++ para personas con
deficiencia visual.

Para instalarlo visita [este enlace](https://daisy.github.io/ace/getting-started/installation/).
{.espacio-arriba1 .sin-sangria}

Para cualquier problema relacionado a su instalación, revisa [esta enlace](https://daisy.github.io/ace/help/troubleshooting/).
{.espacio-arriba1 .sin-sangria}

> Nota: su instalación solo es recomendable. Pecas puede usarse sin su
> presencia.

### ¿Cuál fuente usa Pecas por defecto?

Pecas apoya al movimiento de [tipografías abiertas](https://es.wikipedia.org/wiki/SIL_Open_Font_License).
La serifa utilizada es [Bitter ht](https://www.huertatipografica.com/es/fonts/bitter-ht) de [Sol Matas](https://twitter.com/tullida).

## En Linux {.espacio-arriba3}

### Error con `pc-tiff2pdf`: `tiffcp: no se encontró la orden`

En algunas distribuciones de Linux `libtiff` no incluye las herramientas
tiff. Para solucionarlo, se tiene que instalar el paquete `libtiff-tools`
que en algunas distribuciones se encuentra en el paquete `tiff`.

## En Mac {.espacio-arriba3}

### Pecas no puede descargarse: +++SSL_ERROR_SYSCALL+++

Esto quiere decir que es necesario actualizar [`git`](https://git-scm.com/). 
Para esto hay que descargarlo [aquí](https://sourceforge.net/projects/git-osx-installer/files/git-2.18.0-intel-universal-mavericks.dmg/download?use_mirror=autoselect)
y reinstalarlo.

Ahora solo hay eliminar el fechero existente, descrito en «[Pecas no puede instalarse: `El fichero ya existe`](#pecas-no-puede-instalarse-el-fichero-ya-existe)».
{.espacio-arriba1 .sin-sangria}

## En Windows {.espacio-arriba3}

### ¿Cómo uso Pecas en Windows?

Según la versión de Windows, tenemos las siguientes alternativas.

#### Windows 10

Se necesita instalar Ubuntu como 
[Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/install-win10).

Si no te agrada la idea o quieres tener algo más liviano, es posible
utilizar [Cygwin](https://www.cygwin.com/), descrito en la siguiente
sección. {.espacio-arriba1 .sin-sangria}

#### Windows 7, 8 y 10

Se necesita instalar [Cygwin](https://www.cygwin.com/) con los 
siguientes paquetes:

* `git`. Controlador de versiones que permite descargar el repositorio de Pecas.
* `ruby`. El lenguaje de programación con el que está escrito Pecas.
* `zip`. Sirve para crear el +++EPUB+++.
* `unzip`. Se usa en los procesos para cambiar versiones de +++EPUB+++ o para crear analíticas.
* `tesseract-ocr`. Es el motor +++OCR+++ que permite la detección de caracteres de imágenes exportadas a +++PDF+++.
* `tesseract-ocr-spa`. Es el diccionario en español para `tesseract-ocr`.
* `libtiff6`. Biblioteca para poder utilizar diversas herramientas para imágenes +++TIFF+++
* `tiff`. Conjunto de herramientas para imágenes +++TIFF+++ que utiliza `libtiff6`.
* `make`. Solo si se desea instalar [sexy-bash-prompt](https://github.com/NikaZhenya/sexy-bash-prompt).

Una vez instalado, desde Cygwin instala una gema de Ruby ejecutando: 

```
gem install json_pure
```
