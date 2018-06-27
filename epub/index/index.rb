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

def create_index index_data, index_prefix, files_content, css

    # Construye el HTML para los términos
    def array_to_html list, index_prefix
        # Ordena alfabéticamente los términos
        list = list.sort_by{|s| transliterar(s['term'], false)}
        list_index_ordered_tmp = []
        list_index_ordered = []
        actual_letter = ''
        html_term = []

        # Ordena la lista correctamente
        list.each do |e|
            if list_index_ordered_tmp.length == 0 || e['term'] == list_index_ordered_tmp.last['term']
                list_index_ordered_tmp.push(e)
            else
                list_index_ordered.push(list_index_ordered_tmp.sort_by!{|s| s[/\d+/].to_i})
                list_index_ordered_tmp = []
                list_index_ordered_tmp.push(e)

                if e === list.last
                    list_index_ordered.push(list_index_ordered_tmp)
                end
            end
        end

        # Iteración de cada término o su continuación
        list_index_ordered.each_with_index do |array, j|

            # Si no coincide la inicial, añade una nueva letra
            if actual_letter.downcase != transliterar(translate_inline(array.first['term']).downcase.gsub(/<[^>]*?>/,'')[0])
                first_letter = actual_letter == '' ? true : false
                actual_letter = transliterar(translate_inline(array.first['term']).gsub(/<[^>]*?>/,'')[0]).upcase

                # Define cómo será la estructura de cada letra capital según si se quiere mostrar o no
                if $no_alphabet != true
                    h2 = '<h2>'
                else
                    if first_letter
                        h2 = '<h2 class="hidden">'
                    else
                        h2 = '<h2 class="invisible">'
                    end
                end

                html_term.push(h2 + actual_letter + '</h2>')
            end

            # Crea cada uno de los elementos
            i = 1
            array.each do |e|
                html_a = '<a class="' + $l_in_item_a + '" href="' + e['file'] + '#' + $l_in_item_id + '-' + e['id'] + '">' + i.to_s + '</a>'

                # En el primer elemento se abre el párrafo
                if e === array.first
                    html_term.push('<p class="frances">' + translate_inline(e['term']) + ': ')
                end

                # En el último elemento (que también puede ser el primero) se cierra el párrafo
                if e === array.last
                    html_term.push(html_a + '.</p>')
                # En los elementos intermedios (que también uno puede ser el primero) se coloca una coma
                else
                    html_term.push(html_a + ', ')
                end

                # Aumento del índice visible
                i = i + 1 
            end
        end

        return html_term.join('')
    end

    # Verifica que se tengan los dos campos necesarios de cada índice
    if index_data["name"] == nil || index_data["content"] == nil
        puts $l_in_error_data
        abort
    end

    # Solo si el contenido es un conjunto con más de un elemento que no sea vacío
    if index_data['content'].class == Array && index_data['content'].compact.length > 0

        title = index_data['name']
        list_raw = index_data['content']
        list = {'index' => index_prefix, 'items' => [], 'ignore' => index_data['ignore']}
        list_existent = []

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

                # Indaga si el archivo no tiene que ser ignorado
                accepted = true
                if list['ignore'] != nil && list['ignore'].class == Array && list['ignore'].length > 0
                    list['ignore'].each do |rx|
                        if file =~ /#{rx}/
                            accepted = false
                            break
                        end
                    end
                end

                if accepted
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
            end

            puts $l_in_anadiendo

            # Crea el archivo
            if html
                file_index = $l_in_index_file.gsub('-', index_prefix.to_s + '-') + 'xhtml'

                archivo = File.new(file_index, 'w:UTF-8')
                archivo.puts xhtmlTemplateHead(title, css == nil ? '' : css)
                if css == nil then archivo.puts "<style>#{$css_template_min}</style>" end
                archivo.puts "<section class=\"#{$l_in_item_section}\" epub:type=\"index\" role=\"doc-index\">"
                archivo.puts "<h1>#{title}</h1>"
                if $two_columns then archivo.puts "<div class=\"#{$l_in_item_div}\">" else archivo.puts "<div class=\"#{$l_in_item_div2}\">" end
                archivo.puts array_to_html(list_existent, index_prefix)
                archivo.puts '</div>'
                archivo.puts '</section>'
                archivo.puts $xhtmlTemplateFoot
                archivo.close

                beautifier(file_index)

                # A continuación se extraen los términos que no fueron encontrados
                list_items_all = []
                list_items_existent = []
                list_items_inexistent = []

                # Depura la lista de todos los términos
                list['items'].each do |e|
                    list_items_all.push(e[0])
                end
                list_items_all = list_items_all.sort_by{|s| transliterar(s, false)}.uniq

                # Depura la lista de los términos existentes
                list_existent.each do |e|
                    list_items_existent.push(e['term'])
                end
                list_items_existent = list_items_existent.sort_by{|s| transliterar(s, false)}.uniq

                # Depura la lista de términos no existentes
                list_items_all.each do |e|
                    existant = false

                    # Si existe, va a ser ignorado
                    list_items_existent.each do |ee|
                        if e == ee
                            existant = true
                            break
                        end
                    end

                    if !existant
                        list_items_inexistent.push(e)
                    end
                end

                # Imprime la lista de términos no existentes si es que hay alguno
                if list_items_inexistent.length > 0
                    puts $l_g_linea
                    puts $l_in_advertencia
                    list_items_inexistent.each{|e| puts '- ' + e}
                    puts $l_g_linea
                end
            end
        # Si algo sale mal, elimina todo lo hecho y recupera la información
        rescue
            puts $l_in_error_incorporacion
            puts $l_in_restaurando
            files_content.each do |file|
                file_name = file
                FileUtils.rm(file_name)
                FileUtils.mv(file_name + '.bak', file_name)
            end
            abort
        end
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
    if css != nil
        css = get_relative_path(Dir.pwd, css)
    end

    # Obtiene los archivos a los que se les incluirán los términos
    files = []
    Dir.glob('*') do |e|
        if File.basename(e) !~ /9999\d+-index/ && (File.extname(e) == '.html' || File.extname(e) == '.htm' || File.extname(e) == '.xhtml' || File.extname(e) == '.xml' || File.extname(e) == '.tex')
            files.push(e)
        end
    end

    # Respalda los archivos
    files = files.sort
    puts $l_in_respaldando
    files.each do |e| 
        FileUtils.cp(e, File.basename(e) + '.bak')
    end

    # Llama a la creación del índice
    yaml.each_with_index do |y, i|
        create_index(y, i + 1, files, css)
    end

    # Elimina respaldos
    puts $l_in_eliminando
    files.each do |file|
        FileUtils.rm(file + '.bak')
    end
end

puts $l_g_fin
