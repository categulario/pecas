# Uso de `pc-automata`

Automata automatiza el flujo de trabajo al poder usar todos los scripts para +++EPUB+++ con una sola línea de comandos.

## Dependencias necesarias:

* `zip`
* `unzip`

## Dependencias opcionales:

* `imagemagick`
* `hunspell`
* `linkchecker`

## Uso para inicializar:

```
pc-automata --init
```
  
## Uso para automatizar:

```
pc-automata -f [archivo madre]
```

## Parámetro necesario para la inicialización

* `\--init` = Crea la carpeta del proyecto y el archivo +++YAML+++ necesarios para la automatización.

## Parámetros opcionales para la inicialización

* `-o` = [output] Nombre del proyecto.
* `\--directory` = Directorio donde se creará el proyecto.
  
## Parámetro necesario para la automatización

* `-f` = [file] Archivo madre en MD, +++HTML+++, +++XHTML+++, +++XML+++ o +++HTM+++.
  
## Parámetros opcionales para la autmatización

* `-c` = [cover] Ruta a la imagen de portada que se desea incluir.
* `-d` = [directory] Ruta al proyecto.
* `-i` = [images] Ruta a la carpeta con las imágenes que se desean incluir.
* `-x` = [xhtml] Ruta a la carpeta con los archivos +++XHTML+++ que se desean incluir.
* `-j` = [js] Ruta a la carpeta con los archivos JavaScript que se desean incluir.
* `-n` = [notes] Archivo con las notas en formato MD.
* `-s` = [style sheet] Ruta al archivo +++CSS+++ que se desea incluir.
* `-y` = [yaml] Ruta al archivo con los metadatos para el +++EPUB+++.
* `\--fallbacks` = Ruta a la carpeta con los archivos con fallbacks que se desean incluir.
* `\--index` = Índice con el que ha de comenzar la numeración de los archivos divididos.
* `\--inner` = +++SOLO+++ +++HTML+++, incluye las notas al pie al final del archivo.
* `\--reset` =  Resetea el contador de las notas al pie cada vez que se modifica un archivo.
* `\--depth` = Número entero que indica el nivel de profundidad de la tabla de contenidos.
* `\--section` = Divide el archivo madre cada &lt;section&gt;.
* `\--rotate` = Permite rotación aleatoria de las palabras en la nube de palabras de 30° a 150°.
* `\--with-indexes` = Incluye índices analíticos del `index-data.yaml`.
* `\--two-columns` = Agrega estilo para desplegar dos columnas; en sintaxis tipo +++HTML+++ se despliega a partir de los 768px de ancho.
* `\--resize` = Redimensiona las imágenes con un tamaño predeterminado de 640px para cuadradas u horizontales, y 320px para verticales.
* `\--resize-h` = Redimensiona las imágenes cuadradas u horizontales con el tamaño especificado.
* `\--resize-v` = Redimensiona las imágenes verticales con el tamaño especificado.
* `\--compress` = Comprime las imágenes.
* `\--no-alphabet` = Evita añadir letras del alfabeto en la lista de términos, dejando un espacio en su lugar.
* `\--no-pre` = [preliminary] Evita la creación de contenidos preliminares (portada, portadilla y legal).
* `\--no-legacy` = Evita la conversión de +++EPUB+++ a una versión anterior.
* `\--no-analytics` = Evita la creación de analítica.
* `\--no-epubcheck` = Evita la verificación de EpubCheck.
* `\--no-ace` = Evita la verificación de +++ACE+++.
* `\--no-kindlegen` = Evita la creación del +++MOBI+++ con KindleGen.
* `\--overwrite` = Sobrescribe los archivos sin dar advertencia.

## Parámetros únicos:

* `-v` = [version] Muestra la versión.
* `-h` = [help] Muestra esta ayuda.
  
## Ejemplo sencillo:

```
pc-automata -f archivo-madre.md
```

Crea un proyecto +++EPUB+++, un +++EPUB+++ 3.0.1, un +++EPUB+++ 3.0.0 y un +++MOBI+++ a partir del `archivo-madre.md`.
  
## Ejemplo complejo:

```
pc-automata -f archivo-madre.md -n notas.md -d epub-automata/ -c portada.jpg -i imagenes/ -s styles.css -y epub-automata/meta-data.yaml --section --reset --inner
```

Crea un proyecto +++EPUB+++, un +++EPUB+++ 3.0.1, un +++EPUB+++ 3.0.0 y un +++MOBI+++ a partir del `archivo-madre.md`, las notas al pie de `notas.md` adentro de cada archivo y con reinicio de numeración, la portada `portada.jpg`, las hojas de estilos `styles.css` y los metadatos `epub-automata/meta-data.yaml`, divididos cada etiqueta &lt;section&gt; y en un proyecto de pc-automata llamado `epub-automata`.

--- {.espacio-arriba3}

Nota: el proyecto +++EPUB+++ generará un archivo `meta-data.yaml` que sirve para los metadatos del libro y un `index-data.yaml` para la creación de índices analíticos. Si se desconoce cómo usar el archivo, consúltese la documentación de [+++YAML+++](yaml.html). {.espacio-arriba3}
