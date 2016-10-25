# *Scripts* para el desarrollo de EPUB

![Flujo de trabajo](flujo-de-trabajo.jpg)

Aquí están presentes una serie de *scripts*
pensados para agilizar o automatizar el desarrollo
de libros EPUB. Se trata de seis *scripts* que
ayudan en la creación de obras con diseño fluido de
cualquier índole.

1. `creator.rb`. Crea la estructura del EPUB, con
la posibilidad de incluir una hoja de estilos CSS
predeterminada.

2. `divider.rb`. Divide un solo documento HTML o
XHTML en varios documentos XHTML cada vez que
detecta encabezados `h1`. Principalmente está
pensado como un proceso más dentro de la
metodología del *single source publishing*.

3. `footnotes.rb`. Agrega de manera automatizada
las notas al pie a un libro EPUB o documentos
TeX.

4. `cites.rb`. Agrega de manera automatizada la
bibliografía en formato `.bib`
([BibTeX](http://www.bibtex.org/)) a un libro
EPUB.

5. `recreator.rb`. Recrea los archivos OPF, NCX y
NAV así como crea o recrea el archivo EPUB.

6. `changer.rb`. Cambia versiones de EPUB entre
`3.0.0` y `3.0.1`.
