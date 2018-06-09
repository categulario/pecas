# Pandog

Pandog convierte entre archivos MD, HTML, HTM, XHTML, XML, JSON, TeX, EPUB, ODT o DOCX, estos dos últimos tipos a través de Pandoc.

## Uso:

```
pc-pandog -i [nombre del archivo de entrada] -o [nombre del archivo de salida]
```

## Descripción de los parámetros

### Parámetros necesarios:

* `-i` = [input] Nombre del archivo a convertir.
* `-o` = [output] Nombre para el archivo que se creará; si no se indica alguna ruta, el archivo se creará en el mismo directorio del archivo de entrada.

### Parámetros únicos:

* `-v` = [version] Muestra la versión.
* `-h` = [help] Muestra la ayuda, la cual es este contenido.

## Ejemplo

```
pc-pandog -i directorio/al/archivo.md -o archivo.xhtml
```

Crea un archivo XHTML a partir de `archivo.md` presente en `directorio/al`.

---

# Nota

## Markdown

La documentación de Pecas Markdown puede [consultarse aquí](https://nikazhenya.github.io/pecas/html/md.html).

## CSS

Es posible añadir clases ya predefinidas. La hoja de 
estilos CSS incluye varios elementos que mejoran el diseño y estructura 
del EPUB que pueden [consultarse aquí](https://nikazhenya.github.io/pecas/html/css.html).
