# Recreator

Recrea los archivos OPF, NCX y NAV así como crea o recrea el archivo EPUB.

## Uso:

  ```
  pt-recreator
  ```

## Descripción de los parámetros

### Parámetros necesarios

* `-z` = [zip] SOLO WINDOWS, indica la ruta al archivo zip.exe.

### Parámetros opcionales:

* `-d` = [directory] Directorio del proyecto EPUB.
* `-y` = [yaml] Archivo de los metadatos para el EPUB.

### Parámetros únicos:

* `-v` = [version] Muestra la versión.
* `-h` = [help] Muestra la ayuda, la cual es este contenido.

## Ejemplos

### Ejemplo sencillo:

```
  pt-recreator
```

Crea un archivo EPUB buscando dentro del directorio actual los ficheros `epub-creator` y `meta-data.yaml`.

### Ejemplo con un proyecto EPUB específico:

```
  pt-recreator -d directorio/para/epub
```

Crea un archivo EPUB de `directorio/para/epub` buscando dentro del directorio actual el fichero `meta-data.yaml`.

### Ejemplo con un proyecto EPUB y metadatos específicos:

```
  pt-recreator -d directorio/para/epub -y archivo/meta-datos.yaml
```

Crea un archivo EPUB de `directorio/para/epub` usando el fichero `archivo/meta-datos.yaml`.

## YAML

Se requiere un archivo YAML con una estructura específica para poder general el EPUB. 
Si se desconoce esta información, [consúltese aquí](https://github.com/ColectivoPerroTriste/Herramientas/tree/master/EPUB/YAML) para mayor información.
