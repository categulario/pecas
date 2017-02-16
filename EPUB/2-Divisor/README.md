# Divider

Divider separa un documento HTML cada `<h1>`.

## Uso:

  ```
  pt-divider -f [archivo a dividir]
  ```

## Descripción de los parámetros

### Parámetro necesario:

* `-f` = [file] Archivo HTML, XHTML o HTM a dividir.

### Parámetros opcionales:

* `-d` = [directory] Directorio donde se pondrán los archivos creados.
* `-s` = [style sheet] Ruta al archivo CSS que se desea vincular.
* `-i` = [index] Índice con el que ha de comenzar la numeración del nombre de los archivos creados.

### Parámetros únicos:

* `-v` = [version] Muestra la versión.
* `-h` = [help] Muestra la ayuda, la cual es este contenido.
  
## Ejemplos

### Ejemplo sencillo:

```
  pt-divider -f archivo/a/dividir.xhtml
```

  Dividirá el archivo `dividir.xhtml`, poniendo los archivos creados en el directorio actual y empezando con el índice número 3.

### Ejemplo en un directorio específico:

```
  pt-divider -f archivo/a/dividir.xhtml -d directorio/deseado
```

  Dividirá como el ejemplo anterior, poniendo los archivos creados en `directorio/deseado`.

### Ejemplo en un directorio e incluyendo una hoja de estilo:

```
  pt-divider -f archivo/a/dividir.xhtml -d directorio/deseado -s ruta/al/archivo.css
```

  Dividirá como el ejemplo anterior, vinculando la hoja de estilo `archivo.css` en cada archivo creado.

### Ejemplo en un directorio e incluyendo una hoja de estilo y con otro índice:

```
  pt-divider -f archivo/a/dividir.xhtml -d directorio/deseado -s ruta/al/archivo.css -i 1
```

  Dividirá como el ejemplo anterior, iniciando la numeración de los archivos con el número 1.

## Notas

### Exclusión de etiquetas \<h1> de los archivos creados

Existen ocasiones en que se desea dividir el documento, pero no se quiere 
incluir la etiqueta `<h1>` al archivo creado. Para esto basta con agregar 
la marca `ººignoreºº` (Alt + Shift + M para obtener el símbolo `º`).

Por ejemplo, en el archivo a dividir se tiene:

```
	...
	<h1>Epígrafeººignoreºº</h1>
	<p class="epigrafe">Esto es un epígrafe.</p>
	...
```

Esto creará un nuevo archivo sin incluir el `<h1>`:

```
	...
	<p class="epigrafe">Esto es un epígrafe.</p>
	...
```

### Vinculación de la hoja de estilo

En los archivos creados al que se les vinculan la hoja de estilo, la ruta
es relativa a la ubicación del archivo CSS y la carpeta destino de estos
archivos. Por ello, si la hoja de estilo o los archivos son cambiados de
ubicación, habrá de arreglarse la ruta de manera manual.

### Índice por defecto

El índice por defecto es 3 ya que [pt-creator](https://github.com/ColectivoPerroTriste/Herramientas/tree/master/EPUB/1-Creador)
por defecto crea archivos hasta el número 2.
