#!/usr/bin/env ruby
# encoding: UTF-8
# coding: UTF-8

require 'fileutils'

Encoding.default_internal = Encoding::UTF_8

# Funciones y módulos comunes a todas las herramientas
require File.dirname(__FILE__) + "/../../src/common/general.rb"
require File.dirname(__FILE__) + "/../../src/common/lang.rb"
require File.dirname(__FILE__) + "/../../src/common/css-template.rb"
require File.dirname(__FILE__) + "/../../src/common/xhtml-template.rb"

# Argumentos
epub_ubicacion = if argumento "-d", epub_ubicacion != nil then argumento "-d", epub_ubicacion else Dir.pwd end
epubNombre = if argumento "-o", epubNombre != nil then argumento "-o", epubNombre else $l_cr_epub_nombre end
epubCSS = if argumento "-s", epubCSS != nil then argumento "-s", epubCSS end
epubPortada = if argumento "-c", epubPortada != nil then argumento "-c", epubPortada end
epub_img = if argumento "-i", epub_img != nil then argumento "-i", epub_img end
epub_xhtml = if argumento "-x", epub_xhtml != nil then argumento "-x", epub_xhtml end
epub_js = if argumento "-j", epub_js != nil then argumento "-j", epub_js end
epub_fbk = if argumento "--fallbacks", epub_fbk != nil then argumento "--fallbacks", epub_fbk end
epub_no_preliminares = argumento "--no-pre", epub_no_preliminares, 1
argumento "-v", $l_cr_v
argumento "-h", $l_cr_h

# Variables
font = 'alegreya-ttf'

# Obtiene la ruta absoluta a algunas carpetas
if epub_img then epub_img = File.absolute_path(epub_img) end
if epub_xhtml then epub_xhtml = File.absolute_path(epub_xhtml) end
if epub_js then epub_js = File.absolute_path(epub_js) end
if epub_fbk then epub_fbk = File.absolute_path(epub_fbk) end

# Se va a la carpeta para crear los archivos
epub_ubicacion = comprobacionDirectorio epub_ubicacion
Dir.chdir(epub_ubicacion)

# Comprueba el archivo CSS
epubCSS = comprobacionArchivo epubCSS, [".css"]

# Comprueba el nombre de la portada
epubPortada = comprobacionArchivo epubPortada, [".jpg", ".jpeg", ".gif", ".png", ".svg"]

# Comprueba que exista la carpeta de las imágenes
epub_img = comprobacionDirectorio epub_img

# Verifica que no existan conflictos con el nombre de los archivos a crear
if File.exists?(epubNombre) == true
    puts $l_g_error_nombre
    abort
elsif File.exists?($l_g_meta_data) == true && !File.exists?($l_au_init_archivo)
    puts $l_cr_error_meta
    abort
end

# Crea la carpeta del EPUB 
puts "#{$l_cr_creando[0] + epubNombre + $l_cr_creando[1]}".green
Dir.mkdir epubNombre

# Crea el archivo de metadatos
if !File.exists?($l_au_prefijo + $l_g_meta_data)
    metadata = $l_g_meta_data
    $l_g_meta_data = File.new($l_g_meta_data, "w:UTF-8")
    $l_g_meta_data.puts $l_cr_yaml
    $l_g_meta_data.close
end

# Se añade el nombre de la portada a los metadatos si se especificó uno
if epubPortada != nil
    cambioContenido $l_g_meta_data, /cover/, "cover: #{File.basename(epubPortada)}"
end

# Se mete a la carpeta padre
epub_ubicacion = epub_ubicacion + "/" + epubNombre
Dir.chdir(epub_ubicacion)

# Crea el mimetype sin dejar líneas vacías
File.open("mimetype", "w") do |mimetype|
    mimetype.write("application/epub+zip")
end

# Crea la carpeta META-INF y el archivo container.xml
Dir.mkdir "META-INF"
Dir.chdir(epub_ubicacion + "/META-INF")
container = File.new("container.xml", "w:UTF-8")
container.puts "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
container.puts ""
container.puts "<container version=\"1.0\" xmlns=\"urn:oasis:names:tc:opendocument:xmlns:container\">"
container.puts "    <rootfiles>"
container.puts "        <rootfile full-path=\"OPS/content.opf\" media-type=\"application/oebps-package+xml\"/>"
container.puts "    </rootfiles>"
container.puts "</container>"
container.close
Dir.chdir(epub_ubicacion)

# Crea la carpeta OPS
Dir.mkdir "OPS"
epub_ubicacion = epub_ubicacion + "/OPS"
Dir.chdir(epub_ubicacion)

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
if epubPortada != nil || epub_img != nil
    Dir.mkdir "img"
    
    # Copia las imágenes
    if epub_img != nil
        adicion_archivos(epub_img, epub_ubicacion, "img", ["jpg","jpeg","gif","png","svg"])
    end
end

# Copia la fuente
FileUtils.cp_r(File.dirname(__FILE__) + '/../../src/alien/fonts/' + font, './ttf')

# Crea la carpeta para el CSS
Dir.mkdir "css"
Dir.chdir(epub_ubicacion + "/css")

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
Dir.chdir(epub_ubicacion)

# Crea la carpeta para los xhtml
Dir.mkdir "xhtml"
Dir.chdir(epub_ubicacion + "/xhtml")

# Crea las preliminares si no se excluyeron
if !epub_no_preliminares
    # Crea la portada
    if epubPortada
        FileUtils.cp(epubPortada, epub_ubicacion + "/img/" + File.basename(epubPortada))
        portada = $l_cr_xhtml_portada
        $l_cr_xhtml_portada = File.new("000-#{$l_cr_xhtml_portada.downcase}.xhtml", "w:UTF-8")
        $l_cr_xhtml_portada.puts xhtmlTemplateHeadCover portada
        $l_cr_xhtml_portada.puts "        <section epub:type=\"cover\" role=\"doc-cover\">"
        $l_cr_xhtml_portada.puts "            <img id=\"cover-image\" class=\"forro\" alt=\"#{$l_cr_alt_portada}\" src=\"../img/#{File.basename(epubPortada)}\" />"
        $l_cr_xhtml_portada.puts "        </section>"
        $l_cr_xhtml_portada.puts $xhtmlTemplateFoot
        $l_cr_xhtml_portada.close
    end

    # Crea la portadilla
    portadilla = $l_cr_xhtml_portadilla
    $l_cr_xhtml_portadilla = File.new("001-#{$l_cr_xhtml_portadilla.downcase}.xhtml", "w:UTF-8")
    $l_cr_xhtml_portadilla.puts xhtmlTemplateHead portadilla, "../css/styles.css"
    $l_cr_xhtml_portadilla.puts "        <section  id=\"portadilla\" epub:type=\"titlepage\">"
    $l_cr_xhtml_portadilla.puts "            <h1 id=\"#{$l_g_id_title}\" class=\"centrado titulo\"></h1>"
    $l_cr_xhtml_portadilla.puts "            <h2 id=\"#{$l_g_id_subtitle}\" class=\"centrado subtitulo\"></h2>"
    $l_cr_xhtml_portadilla.puts "            <p id=\"#{$l_g_id_author}\" class=\"centrado\"></p>"
    $l_cr_xhtml_portadilla.puts "        </section>"
    $l_cr_xhtml_portadilla.puts $xhtmlTemplateFoot
    $l_cr_xhtml_portadilla.close

    # Crea la legal
    legal = $l_cr_xhtml_legal
    $l_cr_xhtml_legal = File.new("002-#{$l_cr_xhtml_legal.downcase}.xhtml", "w:UTF-8")
    $l_cr_xhtml_legal.puts xhtmlTemplateHead legal, "../css/styles.css"
    $l_cr_xhtml_legal.puts "        <section  class=\"legal\" epub:type=\"copyright-page\">"
    $l_cr_xhtml_legal.puts "            <p id=\"#{$l_g_id_title}\"></p>"
    $l_cr_xhtml_legal.puts "            <p id=\"#{$l_g_id_publisher}\"></p>"
    $l_cr_xhtml_legal.puts "            <p id=\"#{$l_g_id_author}\" class=\"espacio-arriba2\"></p>"
    $l_cr_xhtml_legal.puts "        </section>"
    $l_cr_xhtml_legal.puts $xhtmlTemplateFoot
    $l_cr_xhtml_legal.close
end

# Agrega archivos XHTML adicionales
if epub_xhtml
    adicion_archivos(epub_xhtml, epub_ubicacion, "xhtml", ["xhtml"])
end

# Agrega archivos JavaScript
if epub_js || epub_fbk
    # La adición de archivos y la creación de su carpeta contenedora depende de la ubicación actual
    if File.basename(Dir.getwd) == 'OPS'
        if epub_js then Dir.mkdir('js') end
        if epub_fbk then Dir.mkdir('fbk') end
    elsif File.basename(Dir.getwd) == 'xhtml'
        if epub_js then Dir.mkdir('../js') end
        if epub_fbk then Dir.mkdir('../fbk') end
    end

    if epub_js then adicion_archivos(epub_js, epub_ubicacion, "js", ["js"]) end
    if epub_fbk then adicion_archivos(epub_fbk, epub_ubicacion, "fbk", ["pdf"]) end # Aquí se tendrían que ir aumentando los tipos de archivos
end

puts $l_g_fin
