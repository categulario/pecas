#!/usr/bin/env ruby
# encoding: UTF-8
# coding: UTF-8

Encoding.default_internal = Encoding::UTF_8

# Funciones y módulos comunes a todas las herramientas
require File.dirname(__FILE__) + "/../secundarios/lang.rb"

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

/* Para viejos exploradores */

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

/* Cuerpo */

body {
    margin: 4em;
}

.sin-margen {
	margin: -4em;
}

@media screen and (min-width: 1025px) {
    body {
        margin: 5em;
    }
    
    .sin-margen {
		margin: -5em;
	}
}

/* Secciones */

section + section {
	margin-top: 10em;
}

/* Encabezados */

h1, h2, h3, h4, h5, h6 {
    font-family: Georgia, \"Times New Roman\", serif;
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
    font-size: 2em;
}

h2 {
    margin-top: 2em;
    font-size: 1.5em;
}

h3 {
    font-size: 1.25em;
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

/* Párrafos */

h1 + p {
    margin-top: 4em;
}

p, blockquote, li {
    font-family: Georgia, \"Times New Roman\", serif;
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

.justificado {
    text-align: justify !important;
}

.derecha {
    text-indent: 0;
    text-align: right !important;
}

.izquierda {
    text-align: left !important;
}

.centrado {
    text-indent: 0;
    text-align: center !important;
}

.frances {
    margin-left: 1.5em;
    text-indent: -1.5em;
    text-align: left !important;
}

* + .frances {
    margin-top: 1em;
}

h1 + .frances {
    margin-top: 10em;
}

.frances + .frances {
    margin-top: 0.5em;
    text-indent: -1.5em;
}

.sangria {
    text-indent: 1.5em;
}

.sin-sangria {
    text-indent: 0;
}

.sin-separacion {
    -moz-hyphens: none;
    -webkit-hyphens: none;
    -o-hyphens: none;
    -ms-hyphens: none;
    hyphens: none;
}

.invisible {
    visibility: hidden;
}

.oculto {
    display: none;
}

.bloque {
    display: block;
}

/* Efectos en las fuentes */

i, em {
    font-style: italic;
}

b, strong {
    font-weight: bold;
}

.capitular {
    font-size: 2em;
    padding-right: 1px;
}

.versal {
    text-transform: uppercase;
}

.redonda {
	 font-variant: none;
}

@media not amzn-mobi {    /* Para cualquier dispositivo excepto Mobi */
    .versalita {
        font-variant: small-caps;
        -moz-hyphens: auto;
        -webkit-hyphens: auto;
        -o-hyphens: auto;
        -ms-hyphens: auto;
        hyphens: auto;
    }
}

@media amzn-mobi {    /* Para Mobi ya que no soporta el atributo «font-variant» */
    .versalita {
        text-transform: uppercase;
        font-size: .8em;
        -moz-hyphens: auto;
        -webkit-hyphens: auto;
        -o-hyphens: auto;
        -ms-hyphens: auto;
        hyphens: auto;
    }
}

/* Enlaces */

a, a:link, a:visited {
    text-decoration: none;
    color: gray;
}

/* Listas */

ol, ul {
    margin: 1em 0 1em 1.5em;
    padding: 0;
}

ol {
    list-style-type: decimal;
}

ul {
    list-style-type:disc;
}

.li-manual {    /* Colocar en el ol o ul */
    list-style-type: none;
}

.li-manual > li > p:first-child > span:first-of-type {    /* Colocar en el li: <li><p><span>[viñeta o numeración deseada]</span>... */
	display: block;
	margin-left: -1.5em;
	margin-bottom: -1.25em;
}

/* Imágenes */

img {    /* Ayuda a detectarlos si no existe el recurso */
    color: gray;
    width: 100%;
}

/* Superíndices y subíndices */

sup, sub {
    font-size: .75em;
    vertical-align: super;
}

sub {
    vertical-align: sub;
}

/* Contenidos especiales */

.titulo {
    margin-top: 3em;
    margin-left: 0;
    font-size: 3em;
}

.subtitulo {
    margin-top: -1.5em;
    margin-bottom: 3em;
    margin-left: 0;
}

.autor {
	width: 250px; /* Se añade a la imagen del autor para que no abarque el 100% */
}

.contribuidor + p {
	text-indent: 0;
}

h1 + .contribuidor {
	margin-top: -1em;
	margin-bottom: 10em;
}

.legal * {
    text-indent: 0;
}

.epigrafe {
    font-size: .9em;
    text-align: right;
    line-height: 1.25em;
    margin-left: 40%;
}

body > .epigrafe:first-child {
    margin-top: 3em;
}

.epigrafe + p {
    margin-top: 2em;
    text-indent: 0;
}

.epigrafe + .epigrafe {
    margin-top: .5em;
}

.espacio-arriba1 {
    margin-top: 1em !important;
}

.espacio-arriba2 {
    margin-top: 2em !important;
}

.espacio-arriba3 {
    margin-top: 3em !important;
}

.espacio {
    white-space: pre-wrap;
}

/* Notas al pie */

.#{$l_no_nota_sup} {
    font-style: normal;
    font-weight: normal;
}

.#{$l_no_nota_hr} {
    margin-top: 2em;
    width: 25%;
    margin-left: 0;
    border: 1px solid gray;
}

.#{$l_no_nota_a} {
    display: block;
    margin-left: -3em;
    margin-bottom: -1.25em;
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

/* Estilos de esta edición */

/* AGREGAR ESTILOS PERSONALIZADOS */
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
