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

## > Particularidades para Windows

Es posible usar Pecas tal como si se estuviera en sistemas UNIX,
pero considerando lo siguiente.

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
