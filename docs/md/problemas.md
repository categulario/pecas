# Solución de problemas

Hay ocasiones donde el uso o instalación de Pecas es un poco conflictivo.
Aquí están los problemas más comunes y sus soluciones.

* [En todos los sistemas operativos](#en-todos-los-sistemas-operativos)
  * [Pecas no puede instalarse: El fichero ya existe](#pecas-no-puede-instalarse-el-fichero-ya-existe)
  * [Uso de EpubCheck para verificar +++EPUB+++](#uso-de-epubcheck-para-verificar-epub)
  * [Uso de Ace para verificar +++EPUB+++](#uso-de-ace-para-verificar-epub)
* [En Linux](#en-linux)
  * [Error con `pc-tiff2pdf`: `tiffcp: no se encontró la orden`](#error-con-pctiff2pdf-tiffcp-no-se-encontro-la-orden)
* [En Mac](#en-mac)
  * [Pecas no puede descargarse: +++SSL_ERROR_SYSCALL+++](#pecas-no-puede-descargarse-ssl-error-syscall)
* [En Windows](#en-windows)
  * [¿Cómo uso Pecas en Windows?](#como-uso-pecas-en-windows)

## En todos los sistemas operativos {.espacio-arriba3}

### Pecas no puede instalarse: El fichero ya existe

Esto quiere decir que el primer intento de instalación de Pecas fue
fallido. Esto sucede porque en tu directorio de usuario se creo una
carpeta oculta llamada `.pecas`. Para volver a instalar Pecas hay
que eliminarla ejecutando lo siguiente:

```bash
rm -rf ~/.pecas
```

Para terminar, repite de nuevo [la instalación](../index.html#instalacion).

### Uso de EpubCheck para verificar +++EPUB+++

[EpubCheck](https://github.com/IDPF/epubcheck) es la herramienta oficial 
para verificar que la estructura del +++EPUB+++ sea la correcta.

Es necesario tener instalado Java SE Development Kit (+++JDK+++),
sin importar tu sistema operativo, [descárgalo aquí](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html).

> Nota: no es necesario instalarlo, puedes verificar archivos +++EPUB+++
> con EpubCheck en línea desde [este enlace](http://validator.idpf.org/).

### Uso de Ace para verificar +++EPUB+++

[Ace](https://daisy.github.io/ace/) es una herramienta que permite
verificar el grado de accesibilidad del +++EPUB+++ para personas con
deficiencia visual.

Para instalarlo visita [este enlace](https://daisy.github.io/ace/getting-started/installation/).

Para cualquier problema relacionado a su instalación, revisa [esta enlace](https://daisy.github.io/ace/help/troubleshooting/).

> Nota: su instalación solo es recomendable. Pecas puede usarse sin su
> presencia.

## En Linux {.espacio-arriba3}

### Error con `pc-tiff2pdf`: `tiffcp: no se encontró la orden`

En algunas distribuciones de Linux `libtiff` no incluye las herramientas
tiff. Para solucionarlo, se tienen que instalar el paquete `libtiff-tools`
que en algunas distribuciones se encuentra en el paquete `tiff`.

## En Mac {.espacio-arriba3}

### Pecas no puede descargarse: +++SSL_ERROR_SYSCALL+++

Esto quiere decir que es necesario actualizar [`git`](https://git-scm.com/). 
Para esto hay que descargarlo [aquí](https://sourceforge.net/projects/git-osx-installer/files/git-2.18.0-intel-universal-mavericks.dmg/download?use_mirror=autoselect)
y reinstalarlo.

Ahora solo hay eliminar el fechero existente, descrito en «[Pecas no puede instalarse: El fichero ya existe](#pecas-no-puede-instalarse-el-fichero-ya-existe)».

## En Windows {.espacio-arriba3}

### ¿Cómo uso Pecas en Windows?

Según la versión de Windows, tenemos las siguientes alternativas.

#### Windows 10

Se necesita instalar Ubuntu como 
[Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/install-win10).

Si no te agrada la idea o quieres tener algo más compacto, es posible
utilicar [Cygwin](https://www.cygwin.com/), descrito en la siguiente
sección.

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
* `tiff`. Conjunto de herramientas para imágenes +++TIFF+++ que utilizan `libtiff6`.
* `make`. Solo si se desea instalar [sexy-bash-prompt](https://github.com/NikaZhenya/sexy-bash-prompt).

Una vez instalado, desde Cygwin se tiene que instalar una gema de ruby 
con: `gem install json_pure`.
