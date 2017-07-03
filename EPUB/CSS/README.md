# CSS

Al usar `pc-creator` se genera una hoja de estilos CSS por defecto si no se
usa la opción `-s`. Esta plantilla incluye varios elementos que ayudar a
mejorar el diseño y estructura del EPUB.

## Etiquetas

En diseño, los cambios más relevantes en las etiquetas son:

* `body`. Tiene márgenes alrededor de 4-5 em.
* `h1` a `h3`. Tienen un tamaño mayor de fuente, alineados a la izquierda, sin división silábica y en serifa.
* `h4`. En itálica y negrita.
* `h5`. En negrita.
* `h6`. En itálica.
* `p`. Si al párrafo le sigue otro párrafo, el segundo tendrá una sangría de 1.5em.
* `a`. Sin decoración y en color gris.
* `img`. Tiene un tamaño al 100% de la caja.

## Clases

Lo más destacado de la hoja de estilos por defecto es la posibilidad de usar
diversas clases comunes a un libro:

* `justificado`. Justifica el texto; por defecto el texto es justificado, excepto en los encabezados.
* `derecha`. Alinea el texto a la derecha.
* `izquierda`. Alinea el texto a la izquierda.
* `centrado`. Centra el texto.
* `frances`. Genera un párrafo con sangría francesa.
* `sangria`. Fuerza una sangría.
* `sin-sangria`. Evita una sangría.
* `sin-separacion`. Evita la separación silábica; por defecto el texto tiene separación silábica, excepto en los encabezados.
* `invisible`. Invisibiliza un contenido, aunque respeta su espacio en el contenido.
* `oculto`. Oculta un contenido, no abarca espacio en el contenido.
* `bloque`. Despliega una etiqueta como bloque.
* `capitular`. Añade una letra capitular.
* `versal`. Muestra el texto en mayúsculas.
* `redonda`. Fuerza texto en redondas.
* `versalita`. Muestra el texto en versalitas.
* `li-manual`. Permite un listado con elementos manuales.
* `epigrafe`. Muestra un texto como epígrafe.
* `espacio-arriba1`. Añade una línea de separación.
* `espacio-arriba2`. Añade dos líneas de separación.
* `espacio-arriba3`. Añade tres líneas de separación.

Para el resto de las clases, consúltese el archivo CSS.

## Uso previo en Markdown

Con [`pc-pandog`](https://github.com/ColectivoPerroTriste/Herramientas/tree/master/Archivo-madre/1-Pandog)
es posible agregar estilos de párrafo al colocar al final de cada párrafo unas
llaves con los estilos o identificadores deseados. Por ejemplo, este Markdown:

```markdown
Esto es un párrafo que continúa 
aquí y se quiere a la derecha. {.derecha}

Este es otro párrafo al que se le
añaden dos clases, *un espacio arriba*
y **centrado**. {.espacio-arriba1 .centrado}

Pero también es posible añadir
identificadores y clases, como
*una sangría francesa* que se
identifique como `p01`. {.frances #p01}
```

Generará este HTML si se usa `pc-pandog`:

```html
<p class="derecha">Esto es un párrafo que continúa aquí y se quiere a la derecha.</p>
<p class="centrado espacio-arriba1">Este es otro párrafo al que se le añaden dos clases, <em>un espacio arriba</em> y <bold>centrado</bold>.</p>
<p id="p01" class="frances">Pero también es posible añadir identificadores y clases, como <em>una sangría francesa</em> que se identifique como <code>p01</code>.</p>
```