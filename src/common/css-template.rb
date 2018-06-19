#!/usr/bin/env ruby
# encoding: UTF-8
# coding: UTF-8

Encoding.default_internal = Encoding::UTF_8

# Funciones y módulos comunes a todas las herramientas
require File.dirname(__FILE__) + "/../common/lang.rb"

$css_template = "/**************************************************/
/******************* RESETEADOR *******************/
/**************************************************/

/* http://meyerweb.com/eric/tools/css/reset/ v2.0 */

html, body, div, span, applet, object, iframe,
h1, h2, h3, h4, h5, h6, p, blockquote, pre,
a, abbr, acronym, address, big, cite, code,
del, dfn, em, img, ins, kbd, q, s, samp,
small, strike, strong, sub, sup, tt, var,
b, u, i, center,
dl, dt, dd, ol, ul, li,
fieldset, form, label, legend,
table, caption, tbody, tfoot, thead, tr, th, td,
article, aside, canvas, details, embed,
figure, figcaption, footer, header, hgroup,
menu, nav, output, ruby, section, summary,
time, mark, audio, video {
    margin: 0;
    padding: 0;
    border: 0;
    font-size: 100%;
    font: inherit;
    vertical-align: baseline;
}

/* Old browsers / Para viejos exploradores */

article, aside, details, figcaption, figure,
footer, header, hgroup, menu, nav, section {
    display: block;
}

body {
    line-height: 1;
}

ol, ul {
    list-style: none;
}

blockquote, q {
    quotes: none;
}

blockquote:before, blockquote:after,
q:before, q:after {
    content: '';
    content: none;
}

table {
    border-collapse: collapse;
    border-spacing: 0;
}

/**************************************************/

/* Body / Cuerpo */

body {
    margin: 4em;
}

.no-margin, .sin-margen {
	margin: -4em;
}

@media amzn-mobi {    /* For Mobi, Kindle Fire generates a lot of margin / Para Mobi ya que Kindle Fire genera mucho margen */
	body {
		margin: 0;
	}

	.no-margin, .sin-margen {
		margin: 0;
	}
}

@media screen and (min-width: 1025px) {
    body {
        margin: 5em;
    }
    
    .no-margin, .sin-margen {
		margin: -5em;
	}

	@media amzn-mobi {    /* For Mobi, Kindle Fire generates a lot of margin / Para Mobi ya que Kindle Fire genera mucho margen */
		body {
			margin: 0;
		}

		.no-margin, .sin-margen {
			margin: 0;
		}
	}
}

/* Sections / Secciones */

section + section {
	margin-top: 10em;
}

/* Headers / Encabezados */

h1, h2, h3, h4, h5, h6 {
    font-family: Georgia, \"Palatino Linotype\", \"Book Antiqua\", Palatino, serif;
    margin-bottom: 1em;
    text-align: left;
    -moz-hyphens: none;
    -webkit-hyphens: none;
    -o-hyphens: none;
    -ms-hyphens: none;
    hyphens: none;
}

* + h1 {
    margin-top:5em;
}

* + h2, h3, h4, h5, h6 {
    margin-top: 1em;
}

h1 {
    margin-top: 3em;
    font-size: 1.75em;
}

h2 {
    font-size: 1.25em;
}

h3 {
    font-size: 1.125em;
}

h4 {
    font-style: italic;
    font-weight: bold;
}

h5 {
    font-weight: bold;
}

h6 {
    font-style: italic;
}

/* Paragraphs / Párrafos */

h1:not(.title) + p, h1:not(.titulo) + p {
    margin-top: 4em;
}

p, blockquote, li, figcaption, details, aside {
    font-family: Georgia, \"Palatino Linotype\", \"Book Antiqua\", Palatino, serif;
    font-size: 1em;
    text-align: justify;
    line-height: 1.25em;
    -moz-hyphens: auto;
    -webkit-hyphens: auto;
    -o-hyphens: auto;
    -ms-hyphens: auto;
    hyphens: auto;
}

p + p {
    text-indent: 1.5em;
}

blockquote {
    font-size: .9em;
    margin: 1em 1.5em;
}

blockquote + blockquote {
    text-indent: 1.5em;
    margin-top: -1em;
}

.justified, .justificado {
    text-align: justify !important;
}

.right, .derecha {
    text-indent: 0;
    text-align: right !important;
}

.left, .izquierda {
    text-align: left !important;
}

.centered, .centrado {
    text-indent: 0;
    text-align: center !important;
}

.hanging, .frances {
    margin-left: 1.5em;
    text-indent: -1.5em;
    text-align: left !important;
}

* + .hanging, * + .frances {
    margin-top: 1em;
}

.hanging + .hanging, .frances + .frances {
    margin-top: 0;
    text-indent: -1.5em;
}

.indent, .sangria {
    text-indent: 1.5em;
}

.no-indent, .sin-sangria {
    text-indent: 0;
}

.no-hyphens, .sin-separacion {
    -moz-hyphens: none;
    -webkit-hyphens: none;
    -o-hyphens: none;
    -ms-hyphens: none;
    hyphens: none;
}

.invisible {
    visibility: hidden;
}

.hidden, .oculto {
    display: none;
}

.block, .bloque {
    display: block;
}

/* Font effects / Efectos en las fuentes */

i, em {
    font-style: italic;
}

b, strong {
    font-weight: bold;
}

.initial, .capitular {
    float: left;
    font-size: 3em;
    margin-top: .15em;
    padding-right: .1em;
}

.uppercase, .versal {
    text-transform: uppercase;
}

.normal, .redonda {
	 font-variant: none;
}

.smallcap-light, .versalita-ligera { /* In Kindle the small-caps won't work because it doesn't support “font-variant” property / En Kindle no funcionarán las versalitas porque no soporta la propiedad «font-variant» */
    font-variant: small-caps;
    -moz-hyphens: auto;
    -webkit-hyphens: auto;
    -o-hyphens: auto;
    -ms-hyphens: auto;
    hyphens: auto;
}

@media not amzn-mobi {    /* For any device except Kindle / Para cualquier dispositivo excepto Kindle: <span class=\"versalita\">ACRÓNIMO</span> */
    .smallcap, .versalita {
        text-transform: lowercase;
        font-variant: small-caps;
        -moz-hyphens: auto;
        -webkit-hyphens: auto;
        -o-hyphens: auto;
        -ms-hyphens: auto;
        hyphens: auto;
    }
}

@media amzn-mobi {    /* For Kindle because the “font-variant” property isn't supported / Para Kindle ya que no soporta la propiedad «font-variant»: <span class=\"versalita\">ACRÓNIMO</span> */
    .smallcap, .versalita {
        text-transform: uppercase;
        font-size: .8em;
        -moz-hyphens: auto;
        -webkit-hyphens: auto;
        -o-hyphens: auto;
        -ms-hyphens: auto;
        hyphens: auto;
    }
}

.underline, .subrayado {
    text-decoration: underline black;
}

.auto-width, .anchura-auto {
    display: block;
    width: auto;
    margin-left: auto;
    margin-right: auto;
}

@media not amzn-mobi {    /* For any device except Kindle / Para cualquier dispositivo excepto Kindle */
    .auto-width, .anchura-auto {
        max-width: 100%;
    }
}

/* Links / Enlaces */

a, a:link, a:visited {
    text-decoration: none;
}

/* Lists / Listas */

ol, ul {
    margin: 1em 1.5em;
    padding: 0;
}

ol {
    list-style-type: decimal;
}

ul {
    list-style-type: disc;
}

ol ol, ol ul,
ul ol, ul ul {
    margin: 0 1.5em;
}

ul.dash, ul.en-dash, ul.em-dash {
    list-style-type: none;
}

ul.dash > li:before, ul.en-dash > li:before, ul.em-dash > li:before {
    display: block;
    width: 1.5em;
    text-align: right;
    padding: 0 .5em 0 0;
    margin: 0 0 -1.25em -2em;
}

ul.dash > li:before {
    content: \"-\";
}

ul.en-dash > li:before {
    content: \"–\";
}

ul.em-dash > li:before {
    content: \"—\";
}

li.no-count {
    list-style-type: none;
}

li.no-count:before {
    content: none !important;
}

/* Images / Imágenes */

img {    /* It helps if the source doesn't exist / Ayuda a detectarlos si no existe el recurso */
    color: #0000EE;
    width: 100%;
}

figure {
	margin: 2em auto;
}

figcaption {
	font-family: Georgia, \"Palatino Linotype\", \"Book Antiqua\", Palatino, serif;
	margin-top: .5em;
	font-size: .9em;
}

figure + figure {
	margin-top: 0;
}

p + img {
	margin-left: -1.5em;
	margin-top: 2em;
	margin-bottom: 2em;
}

.caption, .leyenda {
	font-size: .9em;
	margin-top: -1.5em;
	margin-bottom: 2em;
}

.caption + img, .leyenda + img {
	margin-top: 0;
}

img + .caption, img + .leyenda {
	margin-top: .5em;
}

.caption + p, .leyenda + p {
	text-indent: 0;
}

p > img {
    display: inline;
    height: 1.5em;
    width: auto;
}

/* Superscript and subscripts / Superíndices y subíndices */

sup, sub {
    font-size: .75em;
    vertical-align: super;
}

sub {
    vertical-align: sub;
}

/* Code / Código (inspirados en https://codepen.io/elomatreb/pen/hbgxp)*/

code {
	font-family: monospace;
	background-color: #fff;
	padding: .125em .5em;
	border: 1px solid #ddd;
	border-radius: .25em;
}

pre {
	width: 90%;
	font-family: monospace;
	background-color: #fff;
	margin: 2em auto;
	padding: .5em;
	line-height: 1.25;
	border-radius: .25em;
	box-shadow: .1em .1em .5em rgba(0,0,0,.45);
    white-space: unset;
}

pre * {
	color: #555;
}

pre code {
    display: block;
	margin: 0;
	padding: 0;
	background-color: inherit;
	border: none;
	border-radius: 0;
}

pre code:before {
	width: 1.5em;
	display: inline-block;
	padding: 0 .5em;
	margin-right: .5em;
	color: #888;
}

@media not amzn-mobi {    /* For any device except Kindle / Para cualquier dispositivo excepto Kindle */
    pre {
	    counter-reset: line;
	    overflow: scroll;
    }

    pre code:before {
	    counter-increment: line;
	    content: counter(line);
    }

    pre code {
        white-space: pre;
    }
}

@media amzn-mobi {    /* For any device except Kindle / Para cualquier dispositivo excepto Kindle */
    pre code:before {
	    content: \"•\";
    }
}

/* Glosses / Glosas */

section.gloss, body.gloss, section.glosa, body.glosa {   /* El estilo ha de ponerse en el contenedor de los párrafos y en el span de la glosa */
    margin-right: 7em;
}

span.gloss, span.glosa {
    width: 6em;         /* No son 7 porque se resta uno del margen añadido a continuación */ 
    margin-right: -8em; /* No son -7 porque se añade 1 de margen */
    float: right;
    text-indent: 0;
    text-align: left;
    font-size: .75em;
}

/* Poetry / Poesía: <p class=\"poetry\">Verse 1<br />verse 2<br />verse 3.</p>*/

.poetry, .poesia {
    margin: 1em 1.5em;
    text-indent: 0;
	-moz-hyphens: none;
    -webkit-hyphens: none;
    -o-hyphens: none;
    -ms-hyphens: none;
    hyphens: none;
}

/* Special contents / Contenidos especiales */

.title, .titulo {
    margin-top: 3em;
    margin-left: 0;
    font-size: 2em;
}

.subtitle, .subtitulo {
    margin-top: -1.25em;
    margin-bottom: 3em;
    margin-left: 0;
}

.author, .autor {
	width: 250px; /* Avoids 100% width in author image / Se añade a la imagen del autor para que no abarque el 100% */
}

.contributor + p, .contribuidor + p {
	text-indent: 0;
}

h1 + .contributor, h1 + .contribuidor {
	margin-top: 0em !important;
	margin-bottom: 4em;
}

.copyright, .legal * {
    text-indent: 0;
}

.epigraph, .epigrafe {
    font-size: .9em;
    text-align: right;
    line-height: 1.25em;
    margin-left: 40%;
}

body > .epigraph:first-child, body > .epigrafe:first-child {
    margin-top: 3em;
}

.epigraph + p, .epigrafe + p {
    margin-top: 2em;
    text-indent: 0;
}

.epigraph + .epigraph, .epigrafe + .epigrafe {
    margin-top: .5em;
}

.vertical-space1, .espacio-arriba1 {
    margin-top: 1em !important;
}

.vertical-space2, .espacio-arriba2 {
    margin-top: 2em !important;
}

.vertical-space3, .espacio-arriba3 {
    margin-top: 3em !important;
}

.space, .espacio {
    white-space: pre-wrap;
}

/* Footnotes / Notas al pie */

.#{$l_no_nota_sup} {
    font-style: normal;
    font-weight: normal;
}

.#{$l_no_nota_hr} {
    margin-top: 2em;
    width: 25%;
    margin-left: 0;
    border: 1px solid blue;
    background-color: blue;
}

.#{$l_no_nota_a} {
    display: block;
    margin-left: -3em;
    margin-bottom: -1.25em;
}

.#{$l_no_nota_sup}:before, .#{$l_no_nota_a}:before {
	content: \"[\";
	color: #0000EE;
}

.#{$l_no_nota_sup}:after, .#{$l_no_nota_a}:after {
	content: \"]\";
	color: #0000EE;
}

.#{$l_no_nota_p}, .#{$l_no_nota_p2} {
    margin-left: 3em;
    font-size: .9em;
    text-indent: 0;
}

* + .#{$l_no_nota_p} {
    margin-top: 1em;
    text-indent: 0;
}

.#{$l_no_nota_p2} {
    margin-top: 0;
    text-indent: 1.5em;
}

/* Indexes / Índices analíticos */

.#{$l_in_item_section} p {
    margin-top: .5em !important;
}

@media screen and (min-width:768px) {
    @media not amzn-mobi {
        .#{$l_in_item_div} {
            column-count: 2;
            column-gap: 2em;
            column-rule: solid 1px lightgray;
        }
    }
}

.#{$l_in_item_a}:before {
	content: \"[\";
	color: #0000EE;
}

.#{$l_in_item_a}:after {
	content: \"]\";
	color: #0000EE;
}

/* For print / Para impresión */

@media print {
    section {
        page-break-before: always;
    }

    section:first-of-type {
        page-break-before: avoid;
    }

    section > h1:first-child {
        padding-top: 5em !important;
    }
}

/* Styles for this edition / Estilos de esta edición */

/* ADD HERE CUSTOM STYLES / AGREGAR ESTILOS PERSONALIZADOS */
"

# Plantilla minificada
$css_template_min = $css_template
						.gsub(/\/\*.*?\*\//,"")                 # Elimina los comentarios
						.gsub(/^\s+/, "")						# Elimina espacios al inicio de la línea
                        .gsub(/,\s+/,",").gsub(/\s+,\s+/,",")	# Elimina los espacios entre comas
                        .gsub(/:\s+/,":").gsub(/\s+:\s+/,":")   # Elimina los espacios entre dos puntos
                        .gsub(/\s+{\s+/,"{").gsub(/{\s+/,"{")   # Elimina los espacios entre corchetes
                        .gsub(/}\s+/,"}").gsub(/\s+}\s+/,"}")   # Elimina los espacios entre corchetes
                        .gsub(/;\s+/,";").gsub(/\s+;\s+/,";")   # Elimina los espacios entre puntos y coma
                        .gsub(/\s+\+\s+/, "+")					# Elimina espacios entre el operador «+»
                        .gsub(/\s+>\s+/, ">")					# Elimina espacios entre el operador «>»
                        .gsub(/\s+~\s+/, "~")					# Elimina espacios entre el operador «~»
                        .gsub(/\s+/," ")                        # Elimina los dobles espacios como precaución
                        .gsub(/\n/,"")                    		# Elimina los saltos de línea como precaución
