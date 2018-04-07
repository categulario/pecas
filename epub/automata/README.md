# Automata

Automata automatiza el flujo de trabajo al poder usar todos los *scripts*
con una sola línea de comandos.

## Uso

### Uso para inicializar:

  ```
  pc-automata --init
  ```
  
### Uso para automatizar:

  ```
  pc-automata -f [archivo madre]
  ```
  
## Descripción de los parámetros

### Parámetro necesario para la inicialización

* `--init` = Crea la carpeta del proyecto y el archivo YAML necesarios para la automatización.

### Parámetros opcionales para la inicialización

* `-o` = [output] Nombre del proyecto.
* `--directory` = Directorio donde se creará el proyecto.
  
### Parámetro necesario para la automatización

* `-f` = [file] Archivo madre en MD, HTML, XHTML, XML o HTM.
  
### Parámetros opcionales para la autmatización

* `-c` = [cover] Ruta a la imagen de portada que se desea incluir.
* `-d` = [directory] Ruta al proyecto.
* `-i` = [images] Ruta a la carpeta con las imágenes que se desean incluir.
* `-x` = [xhtml] Ruta a la carpeta con los archivos XHTML que se desean incluir.
* `-n` = [notes] Archivo con las notas en formato MD.
* `-s` = [style sheet] Ruta al archivo CSS que se desea incluir.
* `-y` = [yaml] Ruta al archivo con los metadatos para el EPUB.
* `-32` = [32 bits] SOLO WINDOWS, indica si la computadora es de 32 bits.
* `--no-pre` = [preliminary] Evita la creación de contenidos preliminares (portada, portadilla y legal).
* `--index` = Índice con el que ha de comenzar la numeración de los archivos divididos.
* `--inner` = SOLO HTML, incluye las notas al pie al final del archivo.
* `--reset` =  Resetea el contador de las notas al pie cada vez que se modifica un archivo.
* `--depth` = Número entero que indica el nivel de profundidad de la tabla de contenidos.
* `--section` = Divide el archivo madre cada `<section>`.
* `--rotate` = Permite rotación aleatoria de las palabras en la nube de palabras de 30° a 150°.
* `--overwrite` = Sobrescribe los archivos sin dar advertencia.
* `--no-analytics` = Evita la creación de analítica.
* `--no-legacy` = Evita la conversión de EPUB a una versión anterior.

### Parámetros únicos:

* `-v` = [version] Muestra la versión.
* `-h` = [help] Muestra esta ayuda.
  
## Ejemplos
  
### Ejemplo sencillo:

```
  pc-automata -f archivo-madre.md
```

  Crea un proyecto EPUB, un EPUB 3.0.1, un EPUB 3.0.0 y un MOBI a partir del `archivo-madre.md`.
  
### Ejemplo complejo:

```
  pc-automata -f archivo-madre.md -n notas.md -d automata/ -c portada.jpg -i imagenes/ -s styles.css -y automata/meta-datos.yaml --section --reset --inner
```
  
  Crea un proyecto EPUB, un EPUB 3.0.1, un EPUB 3.0.0 y un MOBI a partir del `archivo-madre.md`, las notas al pie de `notas.md` adentro de cada archivo y con reinicio de numeración, la portada `portada.jpg`, las hojas de estilos `styles.css` y los metadatos `automata/meta-datos.yaml`, divididos cada etiqueta \<section\> y en un proyecto de pc-automata llamado `automata`.
