# Recreator

Recrea los archivos OPF, NCX y NAV así como crea o recrea el archivo EPUB.

## Uso:

```
pc-recreator
```

## Descripción de los parámetros

### Parámetros opcionales:

* `-d` = [directory] Directorio del proyecto EPUB.
* `-y` = [yaml] Archivo de los metadatos para el EPUB.
* `--depth` = Número entero que indica el nivel de profundidad de la tabla de contenidos.

### Parámetros únicos:

* `-v` = [version] Muestra la versión.
* `-h` = [help] Muestra la ayuda, la cual es este contenido.
* `-32` = [32 bits] SOLO WINDOWS, indica si la computadora es de 32 bits.

## Ejemplos

### Ejemplo sencillo:

```
pc-recreator
```

Crea un archivo EPUB buscando dentro del directorio actual los ficheros `epub-creator` y `meta-data.yaml`.

### Ejemplo con un proyecto EPUB específico:

```
pc-recreator -d directorio/para/epub
```

Crea un archivo EPUB de `directorio/para/epub` buscando dentro del directorio actual el fichero `meta-data.yaml`.

### Ejemplo con un proyecto EPUB y metadatos específicos:

```
pc-recreator -d directorio/para/epub -y archivo/meta-datos.yaml
```

Crea un archivo EPUB de `directorio/para/epub` usando el fichero `archivo/meta-datos.yaml`.

### Ejemplo con un proyecto EPUB, metadatos específicos y profundidad:

```
pc-recreator -d directorio/para/epub -y archivo/meta-datos.yaml --depth 4
```

Crea un archivo EPUB de `directorio/para/epub` usando el fichero `archivo/meta-datos.yaml` y con una tabla de contenidos con hasta encabezados `h4`.

---

# Notas

## YAML

Se requiere un archivo YAML con una estructura específica para poder general el EPUB. 
Si se desconoce esta información, [consúltese aquí](https://nikazhenya.github.io/pecas/html/yaml.html) para mayor información.

## Portadilla y legal

Por defecto el título, el autor y el nombre de la editorial son incrustados
según lo especificado en el archivo YAML. Si no se desea este comportamiento
solo elimínese los `id` que inician con `pc-` en alguno de estos dos archivos.

## `--depth`

Hay tres cuestiones a considerar al usar la opción `--depth`:

1. La profundidad implica el máximo número de encabezado a analizar.
   Por ejemplo, si se escribe `--depth 3` se analizarán encabezados
   `h2` y `h3`.
2. Solo se colocarán en las tablas de contenidos los encabezados que
   cuenten con identificadores, ya que es necesario para crear el enlace.
3. No se analizan los encabezados `h1` ya que Pecas supone que a cada
   sección le corresponde solo un encabezado `h1`.
