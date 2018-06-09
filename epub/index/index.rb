#!/usr/bin/env ruby
# encoding: UTF-8
# coding: UTF-8

require 'fileutils'
require 'yaml'

Encoding.default_internal = Encoding::UTF_8

# Funciones y módulos comunes a todas las herramientas
require File.dirname(__FILE__) + "/../../src/common/general.rb"
require File.dirname(__FILE__) + "/../../src/common/lang.rb"
require File.dirname(__FILE__) + "/../../src/common/css-template.rb"
require File.dirname(__FILE__) + "/../../src/common/xhtml-template.rb"
require File.dirname(__FILE__) + "/../../src/common/xhtml-beautifier.rb"

# Argumentos
argumento "-v", $l_in_v
argumento "-h", $l_in_h
init = argumento "--init", init, 1
directory = if argumento "-d", directory != nil then argumento "-d", directory else Dir.pwd end
index_file = if argumento "--index", index_file != nil then argumento "--index", index_file else $l_in_archivo_nombre end
css = if argumento "-s", css != nil then argumento "-s", css end
$no_alphabet = argumento "--no-alphabet", init, 1
$two_columns = argumento "--two-columns", init, 1

# Construye el HTML para los términos
def array_to_html list, index_prefix
        # Ordena alfabéticamente los términos
        list = list.sort_by{|s| transliterar(s['term'], false)}
        actual_term = ''
        actual_letter = ''
        html_term = []
        i = 1

        # Iteración de cada término o su continuación
        list.each_with_index do |hash, j|
            # Cuando ya no es el mismo término, resetea el contador, cierra elementos anteriores y abre el nuevo
            if hash['term'] != actual_term
                actual_term = hash['term']
                i = 1

                if html_term.length > 0
                    html_term.push('.</p>')
                end

                # Si tampoco coincide la inicial, añade una nueva letra
                if actual_letter != hash['term'][0] && $no_alphabet != true
                    actual_letter = hash['term'][0].upcase
                    html_term.push('<h2>' + actual_letter + '</h2>')
                end

                html_term.push('<p class="frances">' + actual_term + ': ')
            end

            # Iteración de cada id del término
            html_tmp = []
            hash['ids'].each do |id|
                html_tmp.push('<a class="' + $l_in_item_a + '" href="' + id.first + '#' + $l_in_item_id + '-' + index_prefix.to_s + '-' + hash['id'].to_s + '-' + id.last.to_s + '">' + i.to_s + '</a>, ')

                i = i + 1
            end
            html_term.push(html_tmp.join(''))

            # Cierre al último elemento
            if j == list.length - 1
                html_term.push('.</p>')
            end
        end

    return html_term.join('').gsub(', .', '.')
end

def create_index index_data, index_prefix, files_content, css
    # Verifica que se tengan los dos campos necesarios de cada índice
    if index_data["name"] == nil || index_data["content"] == nil
        puts $l_in_error_data
        abort
    end

    title = index_data["name"]
    list_raw = index_data["content"]
    list = {"index" => index_prefix, "items" => []}
    list_existent = []
    list_final = []

    # Limpia la lista
    puts "#{$l_in_limpiando[0] + title + $l_in_limpiando[1]}".green
    list_raw.each do |item|
        if item.class == Array
            i1 = item[0].to_s
            i2 = item[1].to_s

            if i1 != '' && i2 != ''
                list["items"].push([i1.strip, i2.gsub(/^\//, '').gsub(/\/$/, '')])
            end
        else
            item = item.to_s

            if item != ''
                list["items"].push([item.strip, item.strip])
            end
        end
    end

    begin
        puts $l_in_buscando

        html = true
        files_content.each do |file|
            # Si es HTML
            if File.basename(file) != '.tex'

                # Convierte el hash a HTML ya con las referencias añadidas
                data = hash_to_html(file_to_hash(file), list)

                list_existent = list_existent + data[0]

                # Crea el archivo
	            archivo = File.new(file, 'w:UTF-8')
	            archivo.puts data[1]
	            archivo.close
            end
        end

        puts $l_in_anadiendo

        # Crea el archivo
        if html
            file_index = $l_in_index_file.gsub('-', index_prefix.to_s + '-') + 'xhtml'

            archivo = File.new(file_index, 'w:UTF-8')
            archivo.puts xhtmlTemplateHead(title, css == nil ? '' : css, 'index')
            if css == nil then archivo.puts "<style>#{$css_template_min}</style>" end
            archivo.puts "<section class=\"#{$l_in_item_section}\">"
            archivo.puts "<h1>#{title}</h1>"
            if $two_columns then archivo.puts "<div class=\"#{$l_in_item_div}\"><style>@media screen and (min-width:768px){.i-item-div{column-count:2;column-gap:2em;column-rule:solid 1px lightgray;}}</style>" end
            archivo.puts array_to_html(list_existent, index_prefix)
            if $two_columns then archivo.puts '</div>' end
            archivo.puts '</section>'
            archivo.puts $xhtmlTemplateFoot
            archivo.close

            beautifier(file_index)
        end

    # Si algo sale mal, elimina todo lo hecho y recupera la información
    rescue
        puts $l_in_error_incorporacion
        files_content.each do |file|
            file_name = file
            puts "#{$l_in_recuperando[0] + file_name + $l_in_recuperando[1]}".green
            FileUtils.rm(file_name)
            FileUtils.mv(file_name + '.bak', file_name)
        end
        abort
    end
end

# Si se inicializa
if init
    # Comprueba que el directorio exista
    comprobacionDirectorio(directory)

    # Limpia el nombre del archivo y comprueba que no exista
    index_file = File.basename(index_file, '.*') + '.yaml'
    Dir.glob(directory + '/*') do |file|
        if File.basename(file) == index_file
            puts $l_in_error_yaml
            abort
        end
    end

    puts "#{$l_in_creando[0] + index_file + $l_in_creando[1] + directory + $l_in_creando[2]}".green

    # Crea el archivo
	archivo = File.new(directory + '/' + index_file, 'w:UTF-8')
	archivo.puts $l_in_archivo_contenido
	archivo.close

# Si es para agregar las entradas
else
    css = comprobacionArchivo(css, [".css"])

    # Comprueba que el archivo exista y obtiene la información
    comprobacionArchivo(index_file, ['.yaml'])
    begin
        yaml = YAML.load_file(index_file)
    rescue
        puts "#{$l_in_error_procesamiento[0] + index_file + $l_in_error_procesamiento[1]}".red.bold
        abort
    end

    # Comprueba que el directorio exista y va ahí si así es
    comprobacionDirectorio(directory)
    Dir.chdir(directory)

    # Obtiene la ruta relativa al CSS
    css = if css != nil then css.gsub(Dir.pwd + '/', '') end

    # Obtiene los archivos a los que se les incluirán los términos
    files = []
    Dir.glob('*') do |e|
        if File.basename(e) !~ /9999\d+-index/ && (File.extname(e) == '.html' || File.extname(e) == '.htm' || File.extname(e) == '.xhtml' || File.extname(e) == '.xml' || File.extname(e) == '.tex')
            files.push(e)
        end
    end

    # Respalda los archivos
    files = files.sort
    files.each do |e| 
        puts "#{$l_in_respaldando[0] + File.basename(e) + $l_in_respaldando[1]}".green
        FileUtils.cp(e, File.basename(e) + '.bak')
    end

    # Llama a la creación del índice
    yaml.each_with_index do |y, i|
        create_index(y, i + 1, files.sort, css)
    end

    # Elimina respaldos
    puts $l_in_eliminando
    files.each do |file|
        FileUtils.rm(file + '.bak')
    end
end

puts $l_g_fin
