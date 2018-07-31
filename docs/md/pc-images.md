# Uso de `pc-images`

Images redimensiona o comprime distintos tipos de imágenes.

## Dependencia necesaria:

* `imagemagick`

## Uso:

```
pc-images
```

## Parámetros opcionales:

* `-i` = [images] Ruta a la carpeta con las imágenes.
* `\--resize` = Redimensiona las imágenes con un tamaño predeterminado de 640px para cuadradas u horizontales, y 320px para verticales.
* `\--resize-h` = Redimensiona las imágenes cuadradas u horizontales con el tamaño especificado.
* `\--resize-v` = Redimensiona las imágenes verticales con el tamaño especificado.
* `\--compress` = Comprime las imágenes.

## Parámetros únicos:

* `-v` = [version] Muestra la versión.
* `-h` = [help] Muestra esta ayuda.

## Ejemplo sencillo:

```
pc-images --resize
```

Redimensiona todas las imágenes en el directorio actual a los tamaños por defecto.

## Ejemplo con compresión:

```
pc-images --resize --compress
```

Semejante al ejemplo anterior pero además comprime las imágenes.

## Ejemplo con solo un tipo de redimensión:

```
pc-images --resize-h 768
```

Redimensiona solo las imágenes cuadradas u horizontales en el directorio actual a 768px de ancho.

--- {.espacio-arriba3}

Nota: la altura de las imágenes siempre es relativa a su anchura. {.espacio-arriba3}
