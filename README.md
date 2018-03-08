# Pecas: herramientas editoriales

Pecas es un conjunto de *scripts* que agilizan varios de los procesos 
del quehacer editorial. Las herramientas están en [desarrollo continuo](https://es.wikipedia.org/wiki/Liberaci%C3%B3n_continua)
y siguen el modelo del [*single source and online publishing*](#single-source-and-online-publishing-ssop).

---

# Instalación

Copia y pega en la terminal:

```bash
(cd ~ && mkdir .pecas && cd .pecas && git clone --depth 1 https://github.com/NikaZhenya/pecas.git . && bash install.sh) && source ~/.bash_profile
```

# Requisitos

Todas las herramientas de Pecas requieren [Ruby](https://www.ruby-lang.org/).

Algunas herramientas requieren otras dependencias, para más información usa:

```
pc-doctor
```

# Utilización

Usa el comando `-h` de cada herramienta para leer su documentación o lee en línea:

| Herramienta    | Ubicación                                                                                      |
|----------------|------------------------------------------------------------------------------------------------|
| `pc-automata`  | [`epub/automata`](https://github.com/NikaZhenya/pecas/tree/master/epub/automata)               |
| `pc-changer`   | [`epub/changer`](https://github.com/NikaZhenya/pecas/tree/master/epub/changer)                 |
| `pc-cites`     | [`epub/cites`](https://github.com/NikaZhenya/pecas/tree/master/epub/cites)                     |
| `pc-creator`   | [`epub/creator`](https://github.com/NikaZhenya/pecas/tree/master/epub/creator)                 |
| `pc-divider`   | [`epub/divider`](https://github.com/NikaZhenya/pecas/tree/master/epub/divider)                 |
| `pc-doctor`    | [`src/doctor`](https://github.com/NikaZhenya/pecas/tree/master/src/doctor)                     |
| `pc-index`     | [`epub/index`](https://github.com/NikaZhenya/pecas/tree/master/epub/index)                     |
| `pc-notes`     | [`epub/notes`](https://github.com/NikaZhenya/pecas/tree/master/epub/notes)                     |
| `pc-pandog`    | [`base-files/pandog`](https://github.com/NikaZhenya/pecas/tree/master/base-files/pandog)       |
| `pc-recreator` | [`epub/recreator`](https://github.com/NikaZhenya/pecas/tree/master/epub/recreator)             |
| `pc-tegs`      | [`digitization/tegs`](https://github.com/NikaZhenya/pecas/tree/master/digitization/tegs)       

# *Single source and online publishing* (SSOP)

Esta metodología parte de un archivo madre en marcado ligero para crear
distintos formatos de una publicación de manera ramificada.

Las ventajas de esta metodología son:

1. Un mayor control semántico y estructural del contenido.
2. El fin al dilema donde «el tiempo de publicación es proporcional a la 
cantidad de formatos deseados».
3. La practicidad de prescindir de respaldos de los formatos finales.
4. La ventaja de actualizar la obra continuamente y sin dificultades.
5. La posibilidad de agregar excepciones según cada formato de salida.
6. El fin a la transmisión de errores entre formatos.

> En la actualidad Pecas está enfocado en la creación de EPUB (y MOBI), 
> pero está planificado la creación de PDF digital, PDF para impresión 
> y versión *web*.

![Flujo de trabajo](flujo-de-trabajo.jpg)

# Para aprender más

* *Edición digital como metodología para una edición global*, en formato [EPUB 3.0.1](https://github.com/NikaZhenya/entradas-eguaras/raw/master/ebooks/edicion_digital_como_metodologia_para_una_edicion_global.epub), [EPUB 3.0.0](https://github.com/NikaZhenya/entradas-eguaras/raw/master/ebooks/edicion_digital_como_metodologia_para_una_edicion_global_3-0-0.epub) y [MOBI](https://github.com/NikaZhenya/entradas-eguaras/raw/master/ebooks/edicion_digital_como_metodologia_para_una_edicion_global.mobi)
    * Libro donde se explica la edición ramificada y otros temas. Esta publicación fue hecha con Pecas.
* [Taller de Edición Digital](http://ted.cliteratu.re/)
    * Sitio donde se documentan aspectos relacionados a esta metodología de trabajo.

# Pendientes

* EPUB
  * Todos.
    * Terminar de resolver el problema de las rutas relativas en los parámetros de cada `script`.
  * `recreator.rb`.
    * Posibilidad de crear sumario.
  * `cites.rb`.
    * Terminar el desarrollo.
  * `index.rb`.
    * Terminar el desarrollo.
  * `joiner.rb`.
    * Desarrollar script periférico que una todos los XHTML en uno solo y con sus estilos dentro del documento (sin referencia externa).
    * Podría ser el mismo que se plantea como idea para *web*, con opción de adición del TOC.

# ¿Pecas?

Pecas fue un feo y maltratado perro chihuahueño que nunca conoció el mundo exterior, ¡larga vida a Pecas!

# Licencia

Software bajo [licencia GPLv3+](https://gnu.org/licenses/gpl.html).
