#!/usr/bin/env ruby
# encoding: UTF-8
# coding: UTF-8

require 'fileutils'

Encoding.default_internal = Encoding::UTF_8

# Funciones y módulos comunes a todas las herramientas
require File.dirname(__FILE__) + "/../../otros/secundarios/general.rb"
require File.dirname(__FILE__) + "/../../otros/secundarios/lang.rb"
require File.dirname(__FILE__) + "/../../otros/secundarios/css-template.rb"
require File.dirname(__FILE__) + "/../../otros/secundarios/xhtml-template.rb"

# Argumentos
epubUbicacion = if argumento "-d", epubUbicacion != nil then argumento "-d", epubUbicacion else Dir.pwd end
epubNombre = if argumento "-o", epubNombre != nil then argumento "-o", epubNombre else $l_cr_epub_nombre end
epubCSS = argumento "-s", epubCSS
epubPortada = argumento "-c", epubPortada
epubImagenes = argumento "-i", epubImagenes
epubTitulo = argumento "--title", epubTitulo
epubAutor = argumento "--creator", epubAutor
epubEditorial = argumento "--publisher", epubEditorial
argumento "-v", $l_cr_v
argumento "-h", $l_cr_h

# Comprueba que existan los argumentos necesarios
comprobacion [epubTitulo, epubAutor, epubEditorial]

# Comprueba el archivo CSS
epubCSS = comprobacionArchivo epubCSS, [".css"]

# Adquiere el path absoluto del archivo CSS
if epubCSS != nil
	epubCSS = File.absolute_path(epubCSS)
end

# Comprueba el nombre de la portada
epubPortada = comprobacionArchivo epubPortada, [".jpg", ".jpeg", ".gif", ".png", ".svg"]

# Comprueba que exista la carpeta de las imágenes
epubImagenes = comprobacionDirectorio epubImagenes

# Se va a la carpeta para crear los archivos
epubUbicacion = comprobacionDirectorio epubUbicacion
Dir.chdir(epubUbicacion)

# Crea la carpeta del EPUB si no existe previamente
Dir.glob("*") do |archivo|
	if File.exists?(epubNombre) == true
		puts $l_cr_error_nombre
		abort
	else
		puts "#{$l_cr_creando[0] + epubNombre + $l_cr_creando[1]}".green
		Dir.mkdir epubNombre
		break
	end
end

# Se mete a la carpeta padre
epubUbicacion = epubUbicacion + "/" + epubNombre
Dir.chdir(epubUbicacion)

# Crea el mimetype sin dejar líneas vacías
File.open("mimetype", "w") do |mimetype|
    mimetype.write("application/epub+zip")
end

# Crea la carpeta META-INF y el archivo container.xml
Dir.mkdir "META-INF"
Dir.chdir(epubUbicacion + "/META-INF")
container = File.new("container.xml", "w:UTF-8")
container.puts "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
container.puts ""
container.puts "<container version=\"1.0\" xmlns=\"urn:oasis:names:tc:opendocument:xmlns:container\">"
container.puts "	<rootfiles>"
container.puts "		<rootfile full-path=\"OPS/content.opf\" media-type=\"application/oebps-package+xml\"/>"
container.puts "	</rootfiles>"
container.puts "</container>"
container.close
Dir.chdir(epubUbicacion)

# Crea la carpeta OPS
Dir.mkdir "OPS"
epubUbicacion = epubUbicacion + "/OPS"
Dir.chdir(epubUbicacion)

# Crea el archivo content.opf
opf = File.new("content.opf", "w:UTF-8")
opf.puts $l_cr_aviso
opf.close

# Crea el NCX
ncx = File.new("toc.ncx", "w:UTF-8")
ncx.puts $l_cr_aviso
ncx.close

# Crea el nav
nav = File.new("nav.xhtml", "w:UTF-8")
nav.puts $l_cr_aviso
nav.close

# Crea la carpeta para las imágenes
if epubPortada != nil || epubImagenes != nil
	Dir.mkdir "img"
	
	# Copia las imágenes
	if epubImagenes != nil
		# Va a la carpeta que contiene las imágenes
		Dir.chdir(epubImagenes)
		
		# Se itera para obtener cada imagen y copiarla
		Dir.glob("*") do |archivo|
			if File.extname(archivo) == ".jpg" || File.extname(archivo) == ".jpeg" || File.extname(archivo) == ".gif" || File.extname(archivo) == ".png" || File.extname(archivo) == ".svg"
				FileUtils.cp(archivo, epubUbicacion + "/img")
			end
		end
		
		# Regresa a la ubicación del proyecto
		Dir.chdir(epubUbicacion)
	end
end

# Crea la carpeta para el CSS
Dir.mkdir "css"
Dir.chdir(epubUbicacion + "/css")

# Crea el archivo CSS
styles = File.new("styles.css", "w:UTF-8")

# Si no se indicó ninguna hoja, se añade una por defecto
if epubCSS == nil
	styles.puts $css_template
else
	archivo_abierto = File.open(File.absolute_path(epubCSS), "r:UTF-8")
	archivo_abierto.each do |linea|
		styles.puts linea
	end
	archivo_abierto.close
end
styles.close

# Regresa a la raíz
Dir.chdir(epubUbicacion)

# Crea la carpeta para los xhtml
Dir.mkdir "xhtml"
Dir.chdir(epubUbicacion + "/xhtml")

# Crea la portada
if epubPortada
	FileUtils.cp(epubPortada, epubUbicacion + "/img/" + File.basename(epubPortada))
	portada = $l_cr_xhtml_portada
	$l_cr_xhtml_portada = File.new("000-#{$l_cr_xhtml_portada.downcase}.xhtml", "w:UTF-8")
	$l_cr_xhtml_portada.puts xhtmlTemplateHead portada, "../css/styles.css", "cover"
	$l_cr_xhtml_portada.puts "        <img id=\"cover-image\" class=\"forro\" src=\"../img/#{File.basename(epubPortada)}\" />"
	$l_cr_xhtml_portada.puts $xhtmlTemplateFoot
	$l_cr_xhtml_portada.close
end

# Crea la portadilla
portadilla = $l_cr_xhtml_portadilla
$l_cr_xhtml_portadilla = File.new("001-#{$l_cr_xhtml_portadilla.downcase}.xhtml", "w:UTF-8")
$l_cr_xhtml_portadilla.puts xhtmlTemplateHead portadilla, "../css/styles.css", "titlepage"
$l_cr_xhtml_portadilla.puts "        <h1 class=\"centrado titulo\">#{epubTitulo}</h1>"
$l_cr_xhtml_portadilla.puts "        <p class=\"centrado\">#{epubAutor}</p>"
$l_cr_xhtml_portadilla.puts $xhtmlTemplateFoot
$l_cr_xhtml_portadilla.close

# Crea la legal
legal = $l_cr_xhtml_legal
$l_cr_xhtml_legal = File.new("002-#{$l_cr_xhtml_legal.downcase}.xhtml", "w:UTF-8")
$l_cr_xhtml_legal.puts xhtmlTemplateHead legal, "../css/styles.css", "copyright-page"
$l_cr_xhtml_legal.puts "	    <p id=\"title\" class=\"legal\"><i>#{epubTitulo}</i></p>"
$l_cr_xhtml_legal.puts "	    <p id=\"publisher\" class=\"legal\">#{epubEditorial}</p>"
$l_cr_xhtml_legal.puts "	    <br /><br />"
$l_cr_xhtml_legal.puts "	    <p class=\"legal\">#{$l_cr_xhtml_autoria}</p>"
$l_cr_xhtml_legal.puts "	    <p id=\"creator\" class=\"legal\">#{epubAutor}</p>"
$l_cr_xhtml_legal.puts $xhtmlTemplateFoot
$l_cr_xhtml_legal.close

puts $l_g_fin
