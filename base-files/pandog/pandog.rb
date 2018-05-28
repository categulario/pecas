#!/usr/bin/env ruby
# encoding: UTF-8
# coding: UTF-8

require 'fileutils'
require 'json'

Encoding.default_internal = Encoding::UTF_8

# Funciones y módulos comunes a todas las herramientas
require File.dirname(__FILE__) + "/../../src/common/general.rb"
require File.dirname(__FILE__) + "/../../src/common/lang.rb"
require File.dirname(__FILE__) + "/../../src/common/css-template.rb"
require File.dirname(__FILE__) + "/../../src/common/xhtml-template.rb"
require File.dirname(__FILE__) + "/../../src/common/xhtml-beautifier.rb"

# Argumentos
$pandog_in = argumento "-i", $pandog_in
$pandog_out = argumento "-o", $pandog_out
argumento "-v", $l_pg_v
argumento "-h", $l_pg_h

# Comprueba que existan los argumentos necesarios
comprobacion [$pandog_in, $pandog_out]

# Arregla rutas
$valid_exts = ['.md', '.html', '.htm', '.xhtml', '.xml', '.json', '.tex', '.pdf', '.epub', '.odt', '.docx']
$pandog_i = arregloRuta(comprobacionArchivo $pandog_in, $valid_exts)
$pandog_o = arregloRuta $pandog_out
$pandog_i_sis = arregloRutaTerminal $pandog_in
$pandog_o_sis = arregloRutaTerminal $pandog_out
$ext_i = File.extname($pandog_in)
$ext_o = File.extname($pandog_out)

# Verifica que el archivo de salida tenga una extensión válida
def valid_ext_o
    valid = false

    $valid_exts.each do |ext|
        if ext == $ext_o then valid = true end
    end

    if valid != true
        puts $l_pg_error_ext
        abort
    end
end

# Determina si es el archivo de salida va en la misma carpeta del de entrada
def define_path string = ''

    # Si la ruta es igual a solo el nombre del archivo, el directorio destino es el mismo al del directorio de entrada
    if File.basename(string) == string
        string = directorioPadre($pandog_i) + '/' + string
    end

    return string
end

# Intérprete MD => HTML
def standalone_html html
    # Crea el nuevo archivo oculto donde se pondrán las modificaciones
    html_nuevo = File.open(define_path($pandog_o), 'w:UTF-8')

    # Agrega cabezas
    if $ext_o == '.xml'
        html_nuevo.puts $xmlTemplateHead
    else
        if $ext_o == '.xhtml'
            html_nuevo.puts xhtmlTemplateHead
        else
            html_nuevo.puts htmlTemplateHead
        end

        # Agrega la hoja de estilos minificada
        html_nuevo.puts '<style>' + $css_template_min + '</style>'
    end

    # Agrega contenido
    html_nuevo.puts html

    # Agrega pies
    if $ext_o == '.xml'
        html_nuevo.puts '</body>'
    else
        html_nuevo.puts $xhtmlTemplateFoot
    end
	    
    # Cierra el archivo con las modificaciones
    html_nuevo.close
	    
    # Acomoda los elementos con los espacios correctos
    beautifier html_nuevo
end

# Intérprete JSON => HTML || MD
def json_to_html_md
    begin
        puts $l_pg_extrayendo

	    # Obtiene los contenidos del JSON
        json_crudo = []
	    json_archivo = File.open($pandog_i, 'r:UTF-8')
	    json_archivo.each do |linea|
            json_crudo.push(linea)
	    end
	    json_archivo.close
        hash = JSON.parse(json_crudo.join(''))
        
        # Se analiza si se cuenta con la estructura requerida
        if hash['file'] != nil
            # Recreación de la estructura, se cambia el nombre porque si es extensión .md o .json no sería válida
            nombre = File.extname($pandog_o) == '.md' ? $pandog_o.gsub(/\..*$/, '.html') : $pandog_o
            hash['file'] = nombre
            html = hash_to_html(hash)

            # Crea el archivo HTML
        	archivo = File.new(define_path(nombre), 'w:UTF-8')
        	archivo.puts html
        	archivo.close

            if File.extname($pandog_o) == '.md'
                puts $l_pg_iniciando_pandoc
                `pandoc #{arregloRutaTerminal(define_path(nombre))} --atx-headers -o #{arregloRutaTerminal(define_path($pandog_o))}`
                File.delete(define_path(nombre))
            end
        else
            puts $l_pg_error_json
            abort
        end
    rescue
		puts $l_pg_error_m
		abort
    end
end

# Intérprete HTML => MD
# OJO: pendiente de hacer nativo
def html_to_md
    html_name = '.' + File.basename($pandog_i, File.extname($pandog_i)) + '.html'

    # Copia el archivo a un archivo oculto con extensión HTML que servirá para Pandoc
    FileUtils.cp($pandog_i, define_path(html_name))

    `pandoc #{define_path(html_name)} --atx-headers -o #{arregloRutaTerminal(define_path($pandog_o))}`

    # Elimina el archivo oculto
    FileUtils.rm(define_path(html_name))
end

# Intérprete MD => JSON
def md_to_json
    html_name = md_to_html($pandog_i)
    $pandog_o_old = $pandog_o
    $ext_o_old = $ext_o
    $pandog_o = '.' + File.basename($pandog_i, '.md') + '.html'
    $ext_o = File.extname($pandog_o)
    html_path = arregloRuta(define_path($pandog_o))

    # Crea un archivo HTML oculto a partir del MD para sacar el hash
    standalone_html(html_name)
    hash = file_to_hash(html_path)

    # Regreso a antiguas variables para producir el JSON
    $pandog_o = $pandog_o_old
    $ext_o = $ext_o_old

    # Crea el JSON
    create_json hash

    # Elimina el archivo HTML oculto
    FileUtils.rm(html_path)
end

# Crea el archivo JSON
def create_json hash
	archivo = File.new(define_path($pandog_o), 'w:UTF-8')
	archivo.puts JSON.pretty_generate(hash)
	archivo.close
end

# Verifica que la extensión del archivo de salida sea la correcta
valid_ext_o

# MD => HTML / HTM / XHTML / XML
if $ext_i == '.md' && ($ext_o == '.html' || $ext_o == '.htm' || $ext_o == '.xhtml' || $ext_o == '.xml')
    puts $l_pg_iniciando
    html = md_to_html($pandog_i)
    standalone_html(html)
# HTML / HTM / XHTML / XML => MD
elsif ($ext_i == '.html' || $ext_i == '.htm' || $ext_i == '.xhtml' || $ext_i == '.xml') && $ext_o == '.md'
    puts $l_pg_iniciando_pandoc
    html_to_md
# EPUB => JSON
elsif $ext_i == '.epub' && $ext_o == '.json'
    puts $l_pg_iniciando
    hash = epub_analisis(arregloRuta(File.absolute_path($pandog_i)))
    create_json hash
    FileUtils.rm_rf(directorioPadre($pandog_i) + '/' + $l_g_epub_analisis)
# HTML => JSON
elsif ($ext_i == '.html' || $ext_i == '.htm' || $ext_i == '.xhtml' || $ext_i == '.xml') && $ext_o == '.json'
    puts $l_pg_iniciando
    hash = file_to_hash(arregloRuta(File.absolute_path($pandog_i)))
    create_json hash
# MD > JSON
elsif $ext_i == '.md' && $ext_o == '.json'
    puts $l_pg_iniciando
    md_to_json
# JSON => MD / HTML / HTM / XHTML / XML
elsif $ext_i == ".json" && ($ext_o == ".md" || $ext_o == '.html' || $ext_o == '.htm' || $ext_o == '.xhtml' || $ext_o == '.xml')
    puts $l_pg_iniciando
    json_to_html_md
# Resto
else
    puts $l_pg_iniciando_pandoc
  	`pandoc #{arregloRutaTerminal(define_path($pandog_i))} -o #{arregloRutaTerminal(define_path($pandog_o))}`
end

puts $l_g_fin
