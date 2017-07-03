# Notes

Notes agrega de manera automatizada las notas al pie a archivos con sintaxis tipo HTML o documentos TeX.

## Uso:

  ```
  pc-notes -f [archivo con las notas]
  ```

## Descripción de los parámetros

### Parámetro necesario:

* `-f` = [file] Archivo con las notas en formato MD.

### Parámetros opcionales:

* `-d` = [directory] Directorio donde se encuentran los archivos para añadir las notas.
* `-s` = [style sheet] SOLO HTML, Ruta al archivo CSS que se desea incluir.
* `--reset` =  Resetea el contador cada vez que se modifica un archivo.
* `--inner` = SOLO HTML, incluye las notas al pie al final del archivo.

### Parámetros únicos:

* `-v` = [version] Muestra la versión.
* `-h` = [help] Muestra esta ayuda.

## Ejemplos

### Ejemplo sencillo:

```
  pc-recreator -f directorio/a/notas.md
```
  
  Añade las notas presentes en `notas.md` a los archivos que se encuentren en el directorio actual.
 
### Ejemplo con un directorio específico:

```
  pc-recreator -f directorio/a/notas.md -d directorio/html/o/tex
```
  
  Añade las notas presentes en `notas.md` a los archivos que se encuentren en `directorio/html/o/tex`.
  
### Ejemplo con un directorio específico y con una hoja de estilo:

```
  pc-recreator -f directorio/a/notas.md -d directorio/html -s ruta/al/archivo.css
```
  
  Igual que el ejemplo anterior pero se añade una hoja de estilo; ojo: se ignora si hay `--inner`.
  
### Ejemplo con un directorio específico y reseteo de la numeración:

```
  pc-recreator -f directorio/a/notas.md -d directorio/html/o/tex --reset
```
  
  Añade las notas presentes en `notas.md` a los archivos que se encuentren en `directorio/html/o/tex` y el contador inicia en 1 en cada archivo.
  
### Ejemplo con un directorio específico, reseteo de la numeración e incrustado en los archivos:

```
  pc-recreator -f directorio/a/notas.md -d directorio/html --reset --inner
```
  
  Igual que el ejemplo anterior pero el contenido de las notas se añaden al final de cada archivo.

## Notas

### Etiquetas de Pecas para las notas

Este *script* supone dos elementos para su ejecución:

1. Que existe alguna marca en los archivos principales que indican el lugar de la nota.
2. Que existe un archivo secundario con todos los contenidos de las notas.

#### Marcas en los archivos principales

La etiqueta por defecto es `--note--`, la cual indicará dónde irá una nota.
Por ejemplo:

```markdown
# Encabezado 1--note--

Esto es un párrafo con una nota al pie--note--.
```

Esta herramienta sustituirá la nota por defecto por una nota numerada (el usuario
no tiene que preocuparse por la numeración o la referencia).

Hay ocasiones que se requiere una mayor personalización, como agregar una letra, 
un símbolo o texto. Para este caso se puede usar esta sintaxis: `--note(CONTENIDO)--`, 
donde `CONTENIDO` es lo que se desea mostrar en lugar del número. Por ejemplo:

```markdown
# Encabezado 1--note(†)--

Esto es un párrafo con una nota al pie--note(sup)--.
```

Esta herramienta sustituirá la nota personalizada por el contenido y referencia
correspondiente.

#### Archivo con las notas

El archivo con las notas no necesita nada en especial, únicamente considérese
que el orden de aparación es como se define la referencia entre la marca y su contenido. 
Por ejemplo:

```markdown
Esta es la **nota 1**.

Esta es la **nota 2** y así sucesivamente.
```

Esta herramienta considerará que cada párrafo es igual a una nota al pie. Esto
permite utilizar más de una línea para un párrafo. Por ejemplo:

```markdown
Esta es la **nota 1**.

Esta es la **nota 2** y así sucesivamente.

Esta es la **nota 3**
que está mucho
*más larga*, pero no
hay problema.
```

Si una nota contempla más de un párrafo, es necesario añadir un salto de línea 
forzado. Por ejemplo:

```markdown
Esta es la **nota 1**.

Esto es el párrafo 1 de la **nota 2**. \
Pero este es
el párrafo 2. \
Y aquí está el párrafo 3.
  
Esta es la **nota 3**
que está mucho
*más larga*, pero no
hay problema.
```

Esta herramienta reemplazará cada salto de línea forzado por un nuevo párrafo.
