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

------

# Notas

## YAML

Se requiere un archivo YAML con una estructura específica para poder general el EPUB. 
Si se desconoce esta información, [consúltese aquí](https://github.com/ColectivoPerroTriste/Herramientas/tree/master/EPUB/YAML) para mayor información.

## Portadilla y legal

Por defecto el título, el autor y el nombre de la editorial son incrustados
según lo especificado en el archivo YAML. Si no se desea este comportamiento
solo elimínese los `id` que inician con `pc-` en alguno de estos dos archivos.
