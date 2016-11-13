# Notes.rb

## Índice

* [Descripción](#descripción)
* [Uso](#uso)
* [Explicación](#explicación)

---

## Descripción

Este *script* agrega de manera automatizada las notas al pie a un libro EPUB
o documentos TeX.

## Uso

### Preparación de los archivos

Para la ejecución del *script* es necesario un archivo de texto que contenga
todas las notas al pie y un marcador para ubicar la nota adentro de cada uno
de los archivos HTML, XHTML o TeX.

#### Archivo de texto

El archivo tiene que ser un `.txt`. Cada línea ha de contener la nota ordenada
de manera secuencial. No es necesario agregar alguna clase de contador o
referencia cruzada, el *script* se encarga de ello. El texto de la nota no ha
de empezar y acabar con una etiqueta de párrafo, esta automáticamente se
incrustará. Solo es menester que cada nota esté en formato HTML o TeX.
Las líneas con solo saltos de línea vacíos o con puros espacios en blanco serán ignoradas.

##### Ejemplo para HTML o XHTML

```
Nota 1 con <i>itálicas<as/i>.
Nota 2 con <b>negritas</b>.

Nota 3 con <span style="font-variant: small-caps;">versalitas</span>.

Nota 4 con <sup>superíndice</sup> y <sub>subíndice</sub>.
```

##### Ejemplo para TeX

```
Nota 1 con \textit{itálicas}.
Nota 2 con \textbf{negritas}.

Nota 3 con \textsc{versalitas}.

Nota 4 con \textsuperscript{superíndice} y \textsubscriptsubíndice}.
```

#### Marcadores

Para ubicar cada una de las notas, solo en necesario colocar un `ººnoteºº`
en el lugar donde se desea colocar la nota.

##### Ejemplo para HTML o XHTML

```
<p>Este es un párrafo de alguna obra.ººnoteºº No hay necesidad de agregar
otros elementos.ººnoteºº El <b><i>script</i> automáticamente creará la
secuencia</b>.ººnoteºº ¡Así de sencillo!ººnoteºº</p>
```

##### Ejemplo para TeX

```
Este es un párrafo de alguna obra.ººnoteºº No hay necesidad de agregar
otros elementos.ººnoteºº El \textbf\textit{script} automáticamente creará la
secuencia}.ººnoteºº ¡Así de sencillo!ººnoteºº
```

### Ejecución del *script*

###### 1. Desde el *shell* ejecutar el *script* cuyos parámetros sean la ruta a la carpeta que contiene los archivos y el archivo de texto que contiene todas las notas al pie.

Para mayor comodidad en el *shell* arrastra el archivo `notes.rb` y después
haz lo mismo con la carpeta.

    Para usuarios de Windows, una vez instalado Ruby han de buscar el programa
    «Start Command Prompt with Ruby» para poder ejecutar esta orden.

    Es posible ingresar únicamente como parámetro el archivo de texto que
    contiene todas las notas al pie y de esta forma el directorio actual será
    tratado como la carpeta que contiene los archivos.

###### 2. El *script* verificará que coincidan la cantidad de notas en el archivo de texto y en los archivos HTML, XHTML o TeX.

    Si la cantidad no coincide el script se detendrá, mencionando la cantidad
    de notas detectadas en el archivo de texto y en el conjunto de los archivos
    HTML, XHTML o TeX.

###### 3. Se pregunta si se desea reiniciar la numeración en cada sección

    Por defecto la numeración es continúa a través de todos los archivos, pero
    es posible reiniciar la numeración en cada uno de los archivos.

###### 4. Se pregunta si se desea colocar las notas en cada uno de los archivos

    Por defecto en la misma carpeta que contiene los archivos se crea un
    documento llamado 9999-notes.xhtml el cual contiene las notas. Cabe la
    posibilidad de que las notas se coloquen al final de cada uno de los
    archivos que contienen las notas, evitándose la creación del archivo
    9999-notes.xhtml.

    Para TeX esta pregunta no aplica, ya que siempre se colocan las notas
    adentro de cada uno de los archivos.

###### 5. Se añadirán las referencias a los archivos HTML, XHTML o TeX

    Si el script fue utilizado para archivos TeX, ¡es todo! Las etiquetas
    ººnoteºº se habrán remplazado con etiquetas \footnote{} cuyo contenido será la nota correspondiente.

###### 6. Se creará o recreará el archivo con todas las notas

    El archivo se localizará en la raíz de la carpeta de los archivos con el
    nombre 9999-notes.xhtml.

    Durante el proceso el script preguntará si se cuenta con alguna hoja de
    estilos CSS para vincularla a este nuevo archivo XHTML. Solo es necesario
    arrastar el .css cuando se indique.

###### 7. ¡Es todo!

    Ahora los documentos contendrán las referencias. En el caso de los
    documentos HTML o XHTML, se crearán referencias cruzadas y numeradas
    entre estos archivos y el 9999-notes.xhtml.

## Explicación

### Automatización de una tarea monótona y confusa

Por lo regular, cuando se empieza a desarrollar un libro, quien lo escribió o
quienes lo editaron tienden a dar el cuerpo del texto de manera independiente
a sus notas al pie. En el peor de los casos se entregará un documento de texto
procesado con las notas ya incrustadas y que de poco o nada sirve al momento de
vertir ese contenido a un lenguaje de etiquetas como Markdown, HTML o TeX.

Esto provoca que la adición de las notas tenga que ser manual, generando no solo
mayores tiempos de producción, sino posibles errores en la vinculación o en el
etiquetado que en muchos de los casos requiere de una verificación por cada
nota. Esto genera que el tiempo invertido aumente proporcionalmente a la
cantidad de notas que contiene la obra. ¿Qué pasa cuando son más de cincuenta,
cien o trecientes notas? ¡Más vale que te prepares varios días a hacer lo mismo
una y otra vez!

Para que este perro tenga más tiempo para dormir o ladrar, este *script* está
pensado para que esta tarea se realice de manera automatizada en cuestión de
¡segundos!

### Análisis secuencial

El *script* organiza los archivos según dos criterios: 1) por orden alfabético
y 2) secuencial. Por ejemplo:

```
/archivos
    /a.html
    /foo
        /bar
            /y.tex
        /i.html
        /j.xhtml
    /b.xhtml
    /c.tex
```
El orden final de los archivos en este caso sería:

1. `a.html`
2. `y.tex`
3. `i.html`
4. `j.xhtml`
5. `b.xhtml`
6. `c.tex`

Por este motivo **hay que tener mucha precaución** sobre la estructura de los
archivos, ya que pueden producirse resultados indeseados. Como recomendación
es mejor tener todos los archivos en una misma carpeta, ordenados según el
orden de lectura de la obra. Por ejemplo:

```
/archivos
    /0-introdccion.html
    /1-capitulo01.xhtml
    /2-capitulo02.tex
    /3-capitulo03.xhtml
    /4-capitulo04.tex
    /5-conclusion.html
```
El orden final, como puede anticiparse, sería:

1. `0-introdccion.html`
2. `1-capitulo01.xhtml`
3. `2-capitulo02.tex`
4. `3-capitulo03.xhtml`
5. `4-capitulo04.tex`
6. `5-conclusion.html`

Por último, el script puede añadir las notas indistintamente de que se traten
de archivos HTML, XHTML o TeX. Sin embargo, **no se recomienda** mezclar
archivos para un EPUB (HTML o XHTML) con archivos para TeX.

### Verificación

Un orden adecuado para la adición de notas no es lo único importante. Una
coincidencia entre la cantidad de marcadores y la cantidad de notas presentes en
`.txt` es fundamental. La falta de coincidencia ocasionaría un tremendo dolor
de cabeza ya que las notas no se añadirían en el lugar correcto, ¡cuánto
aullaría este perro si eso pasara!

Por este motivo, el *script* se detiene si no existe una coincidencia. El
*script* es de gran utilidad y nos ahorrará mucho tiempo, pero no puede hacer
nada si no colocamos la cantidad correcta de marcadores `ººnoteºº` o si los
ponemos en el lugar incorrecto. (:

### Archivo `9999-notes.xhtml`

El archivo tiene ese nombre simplemente para asegurar que se colocará hasta el
final del directorio. Algo muy útil si a partir de
[`recreator.rb`](https://github.com/ColectivoPerroTriste/Herramientas/tree/master/EPUB/5%20-%20Recreador)
se generá
el EPUB y se desea colocar las notas hasta el final del libro.

### Estilos CSS a las notas

Existen cinco clases por las cuales es posible dar estilo a las notas sin
necesidad de modificar las etiquetas HTML generadas.

Las referencias adentro de los archivos HTML o XHTML son como el siguiente
ejemplo:

```
<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque sit amet
fermentum felis. Suspendisse potenti. Sed sodales est porta ex venenatis, eget
ultrices orci convallis.<sup class="n-note-sup" id="n1"><a href="9999-notes.xhtml#n1">[1]</a></sup></p>
```

La nota está adentro de una etiqueta `<sup>` que contiene la clase `n-note-sup`.
Nótese que las referecias están entre corchetes para así aumentar el área de
cliceo, ideal para *ereaders* o dispositivos móviles, donde la fuente tiende a
tener un tamaño disminuido, más si se toma en cuenta que está en superíndice.

Adentro del archivo `9999-notes.xhtml` las clases son como en el siguiente
ejemplo:

```
...
<body epub:type="footnotes">
    <h1>Notas al pie</h1>
    <p class="n-note-p" id="n1"><a class="n-note-a" href="0-introduccion.xhtml#n1">[1]</a> Maecenas convallis <i>lacus vel turpis</i> facilisis semper. Vestibulum at arcu ut erat imperdiet auctor.</p>
    ...
</body>

</html>
```

Toda la nota está adentro de una etiqueta `<p>` que contiene la clase `n-note-p`;
además, el número de nota está dentro de un `<a>` con la clase `n-note-a`.
Nótese que el *script* siempre agrega un especio entre el número de nota y la
nota, no debes de preocuparte por ello, solo concéntrate en darle formato a tus
notas. P:

Por último, las notas pueden comprenden varios párrafos, solo basta que dejes
marcadas las etiquetas correspondientes.

Ejemplo de las notas en el `.text`:

```
Esto es una nota que tiene <b>varios párrafos</b>.</p><p>Este es un segundo párrafo.</p><p>Uno más <i>siempre omitiendo la primera etiqueta de apertura y la última de cierre</i>.
```

Esto se reflejaría en `9999-notes.xhtml` como:

```
...
<body epub:type="footnotes">
    <h1>Notas al pie</h1>
    <p class="n-note-p" id="n1"><a class="n-note-a" href="0-introduccion.xhtml#n1">[1]</a> Esto es una nota que tiene <b>varios párrafos</b>.</p><p>Este es un segundo párrafo.</p><p>Uno más <i>siempre omitiendo la primera etiqueta de apertura y la última de cierre</i>.</p>
    ...
</body>

</html>
```

Ahora sí, ¡a seguir editando libros!
