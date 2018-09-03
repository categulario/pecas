# Uso de `pc-creator`

Creator crea un proyecto para +++EPUB+++ con distintas opciones.

## Uso:

```
pc-creator
```

## Parámetros opcionales:

* `-d` = [directory] Directorio donde se creará el proyecto.
* `-o` = [output] Nombre del proyecto.
* `-s` = [style sheet] Ruta al archivo +++CSS+++ que se desea incluir.
* `-c` = [cover] Ruta a la imagen de portada que se desea incluir.
* `-i` = [images] Ruta a la carpeta con las imágenes que se desean incluir.
* `-x` = [xhtml] Ruta a la carpeta con los archivos +++XHTML+++ que se desean incluir.
* `-j` = [js] Ruta a la carpeta con los archivos JavaScript que se desean incluir.
* `\--fallbacks` = Ruta a la carpeta con los archivos con fallbacks que se desean incluir.

## Parámetros únicos:

* `-v` = [version] Muestra la versión.
* `-h` = [help] Muestra esta ayuda.
* `\--no-pre` = [preliminary] Evita la creación de contenidos preliminares (portada, portadilla y legal).

## Ejemplo sencillo:

```
pc-creator
```

Crea un proyecto +++EPUB+++ en el directorio actual y con el nombre `epub-creator`.

## Ejemplo en un directorio específico:

```
pc-creator -d directorio/deseado
```

Crea un proyecto +++EPUB+++ en `directorio/deseado` y con el nombre `epub-creator`.

## Ejemplo en un directorio y nombre específicos:

```
pc-creator -d directorio/deseado -o proyecto_epub
```

Crea un proyecto +++EPUB+++ en `directorio/deseado` y con el nombre `proyecto_epub`.

## Ejemplo en un directorio y nombre específicos, e incluyendo una hoja de estilo:

```
pc-creator -d directorio/deseado -o proyecto_epub -s ruta/al/archivo.css
```

Crea un proyecto +++EPUB+++ como el ejemplo anterior, incluyendo la hoja de estilo `archivo.css` en lugar del +++CSS+++ por defecto.

## Ejemplo en un directorio y nombre específicos, e incluyendo una hoja de estilo y una portada:

```
pc-creator -d directorio/deseado -o proyecto_epub -s ruta/al/archivo.css -c ruta/a/la/portada.jpg
```

Crea un proyecto +++EPUB+++ como el ejemplo anterior, incluyendo un +++XHTML+++ que muestra la imagen de `portada.jpg`.

## Ejemplo en un directorio y nombre específicos, e incluyendo una hoja de estilo, una portada y varias imágenes:

```
pc-creator -d directorio/deseado -o proyecto_epub -s ruta/al/archivo.css -c ruta/a/la/portada.jpg -i ruta/al/directorio/con/imagenes
```

Crea un proyecto +++EPUB+++ como el ejemplo anterior, incluyendo una copia de las imágenes presentes en `ruta/al/directorio/con/imagenes`.

## Ejemplo para solo crear un archivo +++CSS+++:

```
pc-creator --only-css
```

Crea solo un archivo +++CSS+++ con los estilos por defecto.

## Ejemplo para solo crear un archivo +++CSS+++ en una ubicación específica:

```
pc-creator -d directorio/deseado --only-css
```

Igual que le ejemplo anterior pero la hoja se crea en `directorio/deseado`.

--- {.espacio-arriba3}

Nota: el proyecto +++EPUB+++ generará un archivo `meta-data.yaml` que sirve para los metadatos del libro. Si se desconoce cómo usar el archivo, consúltese la documentación de [+++YAML+++](yaml.html). Si no se usará pc-recreator para generar el +++EPUB+++, este archivo es innecesario y puede eliminarse. {.espacio-arriba3}
