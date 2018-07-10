# Uso de `pc-changer`

Changer cambia versiones de +++EPUB+++ entre 2.0.0, 2.0.1, 3.0.0 y 3.0.1.

## Dependencias necesarias:

* `zip`
* `unzip`

## Uso:

```
pc-changer
```

## Parámetros necesarios:

* `-e` = [epub] Archivo +++EPUB+++.
* `\--version` = Versión a convertir.

## Parámetro opcional:

* `\--standalone` = No elimina el proyecto +++EPUB+++; ideal para hacer cambios manuales.
  
## Parámetros únicos:

* `-v` = [version] Muestra la versión.
* `-h` = [help] Muestra esta ayuda.

## Ejemplo sencillo:

```
pc-changer -e archivo.epub --version 3.0.0
```

Convierte el `archivo.epub` a versión 3.0.0.
 
## Ejemplo sin eliminar el proyecto +++EPUB+++:

```
pc-changer -e archivo.epub --version 3.0.0 --standalone
```

Convertirá como el ejemplo anterior, pero sin eliminar la carpeta de proyecto que sirvió para la conversión.

--- {.espacio-arriba3}

Nota: no se permite la conversión de versiones 3 a 2. {.espacio-arriba3}

Nota: cuando se pasa de versiones 2 a 3 es muy recomendado utilizar la opción `\--standalone` por si es necesario hacer cambios manuales para evitar errores en la verificación. {.espacio-arriba1 .sin-sangria}
