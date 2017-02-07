#!/usr/bin/env ruby
# encoding: UTF-8
# coding: UTF-8

Encoding.default_internal = Encoding::UTF_8

# Funciones y módulos comunes a todas las herramientas
require File.dirname(__FILE__) + "/../../otros/secundarios/general.rb"
require File.dirname(__FILE__) + "/../../otros/secundarios/lang.rb"
require File.dirname(__FILE__) + "/../../otros/secundarios/css-template.rb"
require File.dirname(__FILE__) + "/../../otros/secundarios/xhtml-template.rb"

# Variables
$divisor = '/'
$comillas = '\''
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

$carpeta = arregloRuta $carpeta

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
portadilla.puts xhtmlTemplateHead $portadilla, "../#{$carpetaCss}/styles.css", "titlepage"
portadilla.puts "        <h1 class=\"centrado titulo\">Título</h1>"
portadilla.puts "        <p class=\"centrado\">Autor</p>"
portadilla.puts $xhtmlTemplateFoot
portadilla.close

# Crea la legal
legal = File.new("002-legal.xhtml", "w:UTF-8")
legal.puts xhtmlTemplateHead $legal, "../#{$carpetaCss}/styles.css", "copyright-page"
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
legal.puts $xhtmlTemplateFoot
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
styles.puts $css_template
styles.close

# Regresa a la raíz
Dir.chdir($carpeta)

puts "\nEl proceso ha terminado.".gray.bold
