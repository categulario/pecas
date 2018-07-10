# Uso de `pc-recreator`

Recreator recrea los archivos +++OPF+++, +++NCX+++ y +++NAV+++ así como crea o recrea el archivo +++EPUB+++.

## Dependencias necesarias:

* `zip`

## Uso:

```
pc-recreator
```

## Parámetros opcionales:

* `-d` = [directory] Directorio del proyecto +++EPUB+++.
* `-y` = [yaml] Archivo de los metadatos para el +++EPUB+++.
* `\--depth` = Número entero que indica el nivel de profundidad de la tabla de contenidos.
  
## Parámetros únicos:

* `-v` = [version] Muestra la versión.
* `-h` = [help] Muestra esta ayuda. bits.

## Ejemplo sencillo:

```
pc-recreator
```

Crea un archivo +++EPUB+++ buscando dentro del directorio actual los ficheros `epub-creator` y `meta-data.yaml`.
 
## Ejemplo con un proyecto +++EPUB+++ específico:

```
pc-recreator -d directorio/para/epub
```

Crea un archivo +++EPUB+++ de `directorio/para/epub` buscando dentro del directorio actual el fichero `meta-data.yaml`.

## Ejemplo con un proyecto +++EPUB+++ y metadatos específicos:

```
pc-recreator -d directorio/para/epub -y archivo/meta-data.yaml
```

Crea un archivo +++EPUB+++ de `directorio/para/epub` usando el fichero `archivo/meta-data.yaml`.

## Ejemplo con un proyecto +++EPUB+++, metadatos específicos y profundidad:

```
pc-recreator -d directorio/para/epub -y archivo/meta-data.yaml --depth 4
```

Crea un archivo +++EPUB+++ de `directorio/para/epub` usando el fichero `archivo/meta-data.yaml` y con una tabla de contenidos con hasta encabezados `h4`.
  
--- {.espacio-arriba3}

Nota: se requiere un archivo +++YAML+++ con una estructura específica para poder general el +++EPUB+++. Si se desconoce esta información, consúltese la documentación de [+++YAML+++](yaml.html). {.espacio-arriba3}
