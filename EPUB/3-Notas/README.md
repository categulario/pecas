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

### Delimitación de las notas en el Markdown

El archivo **no** necesita nada en especial, solo considérese que cada 
párrafo es igual a una nota al pie. Según los archivos de salida, es como
se hará la conversión a través de Pandoc.

### Notas con múltiples párrafos en archivos tipo HTML

Para tener una nota con múltiples párrafos solo es necesario añadir un
salto de línea forzado. Por ejemplo:

```
  Esta es la **nota 1**.

  Esto es el párrafo 1 de la **nota 2**. \
  Pero este es
  el párrafo 2. \
  Y aquí está el párrafo 3.
  
  Esta es la **nota 3**
  que está *más larga*.
```

Este `script` reemplazará cada salto de línea forzado por un nuevo párrafo.
