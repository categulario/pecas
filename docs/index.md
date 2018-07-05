# Pecas: herramientas editoriales

Pecas es un conjunto de _scripts_ que agilizan varios de los procesos 
del quehacer editorial. Las herramientas están en [desarrollo continuo](https://es.wikipedia.org/wiki/Liberaci%C3%B3n_continua)
y siguen el modelo del [_single source and online publishing_](https://github.com/NikaZhenya/pecas#single-source-and-online-publishing-ssop).

## > Instalación

Copia y pega en la terminal:

```bash
(cd ~ && mkdir .pecas && cd .pecas && git clone --depth 1 https://github.com/NikaZhenya/pecas.git . && bash install.sh) && source ~/.bash_profile
```

## > Requisitos

* Todas las herramientas de Pecas requieren [Ruby](https://www.ruby-lang.org/).
* Algunas herramientas requieren otras dependencias, para más información usa:

```
pc-doctor
```

## > Utilización

Usa el comando `-h` de cada herramienta para leer su documentación.

---

## > Particularidades para todos los sistemas operativos

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

## > Particularidades para Mac

### Pecas no puede instalarse: SSL_ERROR_SYSCALL

Esto quiere decir que es necesario actualizar [`git`](https://git-scm.com/). 
Para estoy hay que descargarlo [aquí](https://sourceforge.net/projects/git-osx-installer/files/git-2.18.0-intel-universal-mavericks.dmg/download?use_mirror=autoselect)
y reinstalarlo.

Una vez instalado, copia y pega en la terminal:

```bash
rm -rf ~/.pecas
```

Para terminar, repite de nuevo [la instalación](#-instalacion).

## > Particularidades para Windows

### Windows 10

Se necesita instalar Ubuntu como 
[Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/install-win10).

### Windows 7 y 8

Se necesita instalar [Cygwin](https://www.cygwin.com/) con los 
siguientes paquetes:

* `git`.
* `zip`.
* `unzip`.
* `make`. (Solo si se desea instalar [sexy-bash-prompt](https://github.com/NikaZhenya/sexy-bash-prompt)).

Además se tiene que instalar una gema de ruby con: `gem install json_pure`.
