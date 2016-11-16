#!/usr/bin/env ruby
# encoding: UTF-8
# coding: UTF-8

Encoding.default_internal = Encoding::UTF_8

### GENERALES ###

# Obtiene el tipo de sistema operativo; viene de: http://stackoverflow.com/questions/170956/how-can-i-find-which-operating-system-my-ruby-program-is-running-on
module OS
    def OS.windows?
        (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
    end
    def OS.mac?
        (/darwin/ =~ RUBY_PLATFORM) != nil
    end
    def OS.unix?
        !OS.windows?
    end
    def OS.linux?
        OS.unix? and not OS.mac?
    end
end

# Para colorear el texto; viene de: http://stackoverflow.com/questions/1489183/colorized-ruby-output
class String
    def black;          "\e[30m#{self}\e[0m" end
    def red;            "\e[31m#{self}\e[0m" end
    def green;          "\e[32m#{self}\e[0m" end
    def brown;          "\e[33m#{self}\e[0m" end
    def blue;           "\e[34m#{self}\e[0m" end
    def magenta;        "\e[35m#{self}\e[0m" end
    def cyan;           "\e[36m#{self}\e[0m" end
    def gray;           "\e[37m#{self}\e[0m" end

    def bg_black;       "\e[40m#{self}\e[0m" end
    def bg_red;         "\e[41m#{self}\e[0m" end
    def bg_green;       "\e[42m#{self}\e[0m" end
    def bg_brown;       "\e[43m#{self}\e[0m" end
    def bg_blue;        "\e[44m#{self}\e[0m" end
    def bg_magenta;     "\e[45m#{self}\e[0m" end
    def bg_cyan;        "\e[46m#{self}\e[0m" end
    def bg_gray;        "\e[47m#{self}\e[0m" end

    def bold;           "\e[1m#{self}\e[22m" end
    def italic;         "\e[3m#{self}\e[23m" end
    def underline;      "\e[4m#{self}\e[24m" end
    def blink;          "\e[5m#{self}\e[25m" end
    def reverse_color;  "\e[7m#{self}\e[27m" end
end

# Enmienda ciertos problemas con la línea de texto
def ArregloRuta (elemento)
    if elemento[-1] == ' '
        elemento = elemento[0...-1]
    end

    # Elimina caracteres conficlitos
    elementoFinal = elemento.gsub('\ ', ' ').gsub('\'', '')

    if OS.windows?
        # En Windows cuando hay rutas con espacios se agregan comillas dobles que se tiene que eliminar
        elementoFinal = elementoFinal.gsub('"', '')
    else
        # En UNIX pueden quedar diagonales de espace que también se ha de eliminar
        elementoFinal =  elementoFinal.gsub('\\', '')
    end

    # Se codifica para que no exista problemas con las tildes
    elementoFinal = elementoFinal.encode!(Encoding::UTF_8)

    return elementoFinal
end

### CREATOR ###

# Elementos generales
$divisor = '/'
$comillas = '\''
$lenguaje = "es"
$carpetaPadre = "EPUB-CREATOR"
$carpetaMeta = "META-INF"
$carpetaOPS = "OPS"
$carpetaToc = "toc"
$carpetaXhtml = "xhtml"
$carpetaCss = "css"
$carpetaImg = "img"
$aviso = "Use recreator.rb to fill this file."
$portadilla = "Portadilla"
$legal = "Legal"

if OS.windows?
    $comillas = ''
end

# Obtiene los argumentos necesarios
if ARGF.argv.length < 1
    $carpeta = Dir.pwd
elsif ARGF.argv.length == 1
    $carpeta = ARGF.argv[0]
else
    puts "\nSolo se permite un argumento, el de la ruta de la carpeta destino.".red.bold
    abort
end

$carpeta = ArregloRuta $carpeta

# Se va a la carpeta para crear los archivos
Dir.chdir($carpeta)

# Para crear la carpeta del EPUB
def creacion
    puts "\nCreando carpeta del EPUB con el nombre #{$carpetaPadre}...".magenta.bold
    # Crea la carpeta padre
    Dir.mkdir $carpetaPadre

    # Se mete a la carpeta padre
    $carpeta = $carpeta + $divisor + $carpetaPadre
    Dir.chdir($carpeta)
end

# Según si la carpeta padre está vacía o no, crea o no la carpeta para el EPUB
if Dir["#{$carpeta}/*"].empty? == true
    creacion
else
    # Crea la carpeta del EPUB si no existe previamente
    Dir.glob($carpeta + $divisor + '**') do |archivo|
        if File.exists?($carpetaPadre) == true
            puts "\nYa existe una carpeta con el nombre #{$carpetaPadre}.".red.bold
            abort
        else
            creacion

            break
        end
    end
end

# Crea el mimetype sin dejar líneas vacías
File.open("mimetype", "w") do |mimetype|
    mimetype.write("application/epub+zip")
end

# Crea la carpeta META-INF y el archivo container.xml
Dir.mkdir $carpetaMeta
Dir.chdir($carpeta + $divisor + $carpetaMeta)
container = File.new("container.xml", "w:UTF-8")
container.puts "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
container.puts ""
container.puts "<container version=\"1.0\" xmlns=\"urn:oasis:names:tc:opendocument:xmlns:container\">"
container.puts "	<rootfiles>"
container.puts "		<rootfile full-path=\"OPS/content.opf\" media-type=\"application/oebps-package+xml\"/>"
container.puts "	</rootfiles>"
container.puts "</container>"
container.close
Dir.chdir($carpeta)

# Crea la carpeta OPS
Dir.mkdir $carpetaOPS
$carpeta = $carpeta + $divisor + $carpetaOPS
Dir.chdir($carpeta)

# Crea el archivo content.opf
opf = File.new("content.opf", "w:UTF-8")
opf.puts $aviso
opf.close

# Crea la carpeta para las tablas de contenidos
Dir.mkdir $carpetaToc
Dir.chdir($carpeta + $divisor + $carpetaToc)

# Crea el NCX
ncx = File.new("toc.ncx", "w:UTF-8")
ncx.puts $aviso
ncx.close

# Crea el nav
nav = File.new("nav.xhtml", "w:UTF-8")
nav.puts $aviso
nav.close

# Regresa a la raíz
Dir.chdir($carpeta)

# Crea la carpeta para los xhtml
Dir.mkdir $carpetaXhtml
Dir.chdir($carpeta + $divisor + $carpetaXhtml)

# Crea la portadilla
portadilla = File.new("001-portadilla.xhtml", "w:UTF-8")
portadilla.puts "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
portadilla.puts "<!DOCTYPE html>"
portadilla.puts "<html xmlns=\"http://www.w3.org/1999/xhtml\""
portadilla.puts "      xmlns:epub=\"http://www.idpf.org/2007/ops\""
portadilla.puts "      xml:lang=\"#{$lenguaje}\" lang=\"#{$lenguaje}\">"
portadilla.puts "    <head>"
portadilla.puts "        <meta charset=\"UTF-8\" />"
portadilla.puts "        <link href=\"../#{$carpetaCss}/styles.css\" rel=\"stylesheet\" type=\"text/css\" />"
portadilla.puts "        <title>#{$portadilla}</title>"
portadilla.puts "    </head>"
portadilla.puts "    <body epub:type=\"titlepage\">"
portadilla.puts "        <h1 class=\"centrado titulo\">Título</h1>"
portadilla.puts "        <p class=\"centrado\">Autor</p>"
portadilla.puts "    </body>"
portadilla.puts "</html>"
portadilla.close

# Crea la portadilla
legal = File.new("002-legal.xhtml", "w:UTF-8")
legal.puts "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
legal.puts "<!DOCTYPE html>"
legal.puts "<html xmlns=\"http://www.w3.org/1999/xhtml\""
legal.puts "      xmlns:epub=\"http://www.idpf.org/2007/ops\""
legal.puts "      xml:lang=\"#{$lenguaje}\" lang=\"#{$lenguaje}\">"
legal.puts "    <head>"
legal.puts "        <meta charset=\"UTF-8\" />"
legal.puts "        <link href=\"../#{$carpetaCss}/styles.css\" rel=\"stylesheet\" type=\"text/css\" />"
legal.puts "        <title>#{$legal}</title>"
legal.puts "    </head>"
legal.puts "    <body epub:type=\"copyright-page\">"
legal.puts "	    <p class=\"legal\"><i>Título</i></p>"
legal.puts "	    <p class=\"legal\">Editorial</p>"
legal.puts "	    <br /><br />"
legal.puts "	    <p class=\"legal\">Autoría</p>"
legal.puts "	    <p class=\"legal\">Nombre</p>"
legal.puts "	    <br /><br />"
legal.puts "	    <p class=\"legal\">Edición</p>"
legal.puts "	    <p class=\"legal\">Nombre</p>"
legal.puts "	    <br /><br />"
legal.puts "	    <p class=\"legal\">ISBN: XXX</p>"
legal.puts "    </body>"
legal.puts "</html>"
legal.close

# Regresa a la raíz
Dir.chdir($carpeta)

# Crea la carpeta para las imágenes
Dir.mkdir $carpetaImg
Dir.chdir($carpeta + $divisor + $carpetaImg)

# Regresa a la raíz
Dir.chdir($carpeta)

# Crea la carpeta para el css
Dir.mkdir $carpetaCss
Dir.chdir($carpeta + $divisor + $carpetaCss)

# Crea el archivo css
styles = File.new("styles.css", "w:UTF-8")
styles.puts "
/**************************************************/
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

@media screen and (min-width: 1025px) {
    body {
        margin: 5em;
    }
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
	text-align: justify;
}

.derecha {
    text-indent: 0;
	text-align: right;
}

.izquierda {
	text-align: left;
}

.centrado {
    text-indent: 0;
	text-align: center;
}

.frances {
    margin-left: 1.5em;
    text-indent: -1.5em;
    text-align: left;
}

* + .frances {
    margin-top: 1em;
}

.frances + .frances {
    margin-top: 0.5em;
    text-indent: -1.5em;
}

.sangria {
    text-indent: 1.5em;
}

.sinSangria {
    text-indent: 0;
}

.oculto {
	visibility: hidden;
}

/* Efectos en las fuentes */

i, em {
    font-style: italic;
	font-family: Georgia, \"Times New Roman\", serif;
}

b, strong {
	font-weight: bold;
    font-family: Georgia, \"Times New Roman\", serif;
}

.versalitas {
    font-variant: small-caps;
}

.versales {
	text-transform: uppercase;
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

.legal {
	font-family: Georgia, \"Times New Roman\", serif;
	font-size: 1em;
	text-align: left;
	line-height: 1.25em;
	margin: 0;
}

.legal + .legal {
	text-indent: 0;
}

.epigrafe {
    font-family: Georgia, \"Times New Roman\", serif;
	font-size: .9em;
	text-align: right;
	line-height: 1.25em;
    margin-left: 40%;
}

.epigrafe + p {
    margin-top: 2em;
    text-indent: 0;
}

.epigrafe + .epigrafe {
    margin-top: .5em;
}

.espacioArriba {
	margin-top: 1em;
}

.espacioArriba2 {
	margin-top: 2em;
}

.espacioArriba3 {
	margin-top: 3em;
}

/* Estilos adicionales */

.n-note-sup {
	font-style: normal;
	font-weight: normal;
}

.n-note-hr {
	margin-top: 2em;
	width: 25%;
	margin-left: 0;
	border: 1px solid gray;
}

* + .n-note-p {
    margin-top: 1em;
}

.n-note-p + .n-note-p {
    margin-top: 0.5em;
    text-indent: 0;
}

.n-note-p {
	margin-left: 3em;
}

.n-note-a {
	display: block;
	margin-left: -3em;
	margin-bottom: -1.25em;
}

/* Estilos de esta edición */

/* AGREGAR ESTILOS PERSONALIZADOS */
"
styles.close

# Regresa a la raíz
Dir.chdir($carpeta)

puts "\nEl proceso ha terminado.".gray.bold
