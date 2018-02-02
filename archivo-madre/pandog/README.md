# Pandog

Pandog utiliza el poder de Pandoc para convertir archivos con elementos adicionales si se convierten de HTML, XHTML, HTM o XML a MD o visceversa.

## Requerimientos

* [Pandoc](http://pandoc.org/) > 1.19

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

------

# Notas

Pandog está pensado a limpiar el texto en vísperas de una publicación, por
lo que elimina, modifica y agrega elementos al trabajo hecho por Pandoc.

## De HTML, XHTML, HTM o XML a MD

Las etiquetas HTML que no pueden ser traducidas a MD **son eliminadas**, 
ya que se consideran como elementos adicionales al archivo madre que podrán
agregarse según la salida de publicación específica.

## De MD a HTML, XHTML, HTM o XML

1. Evita saltos de línea si aparece un elemento `<br />`.
2. Agrega cabeza y pies según la salida específica.
  * Al HTML o HTM se le agrega una declaración HTML con codificación UTF-8 
  y con una plantilla CSS minificada.
  * Al XHTML se le añade una declaración XHTML para EPUB con codificación
  UTF-8 y con una plantilla CSS minificada.
  * Al XML solo se le añade todo el contenido dentro de una etiqueta `<body>`
  para utilizarse como base de un formato impreso.
3. Posibilita que a los párrafos puedan definírseles identificadores o clases, 
de manera análoga a como ya Pandoc permite estas definiciones para los encabezados.
  * Este párrafo en MD:
  
    ```markdown
    Este es un párrafo con identificador 
    y clases. {#id-ejemplo .derecha .versalita}
    ```
    
  * En HTML quedaría como:
  
    ```html
    <p id="id-ejemplo" class="derecha versalita">Este es un párrafo con identificador y clases.</p>
    ```

## CSS

Por estas posibilidades, es posible añadir clases ya predefinidas. La hoja de 
estilos CSS incluye varios elementos que mejoran el diseño y estructura 
del EPUB que pueden [consultarse aquí](https://github.com/NikaZhenya/pecas/tree/master/epub/others/css).
