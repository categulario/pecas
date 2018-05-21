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

def standalone_html html
    # Crea el nuevo archivo oculto donde se pondrán las modificaciones
    html_nuevo = File.open("#{$pandog_o}", "w:UTF-8")

    # Agrega cabezas
    if File.extname($ext_o) == ".xml"
        html_nuevo.puts $xmlTemplateHead
    else
        if File.extname($ext_o) == ".xhtml"
            html_nuevo.puts xhtmlTemplateHead
        else
            html_nuevo.puts htmlTemplateHead
        end

        # Agrega la hoja de estilos minificada
        html_nuevo.puts "<style>" + $css_template_min + "</style>"
    end

    # Agrega contenido
    html_nuevo.puts html

    # Agrega pies
    if File.extname($ext_o) == ".xml"
        html_nuevo.puts "</body>"
    else
        html_nuevo.puts $xhtmlTemplateFoot
    end
	    
    # Cierra el archivo con las modificaciones
    html_nuevo.close
	    
    # Acomoda los elementos con los espacios correctos
    beautifier html_nuevo
end

# Cambios JSON > HTML || MD
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
        	archivo = File.new(nombre, 'w:UTF-8')
        	archivo.puts html
        	archivo.close

            if File.extname($pandog_o) == '.md'
                puts $l_pg_iniciando
                `pandoc #{arregloRutaTerminal(nombre)} --atx-headers -o #{$pandog_o_sis}`
                File.delete(nombre)
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

# Verifica que la extensión del archivo de salida sea la correcta
valid_ext_o

# Indaga si se hará conversión nativa o a través de Pandoc
# MD => HTML / HTM / XHTML / XML
if $ext_i == '.md' && ($ext_o == '.html' || $ext_o == '.htm' || $ext_o == '.xhtml' || $ext_o == '.xml')
    puts $l_pg_iniciando
    html = md_to_html($pandog_i)
    standalone_html(html)
# JSON => MD / HTML / HTM / XHTML / XML
elsif $ext_i == ".json" && ($ext_o == ".md" || $ext_o == '.html' || $ext_o == '.htm' || $ext_o == '.xhtml' || $ext_o == '.xml')
    puts $l_pg_iniciando
    json_to_html_md
# Resto
else
    puts $l_pg_iniciando_pandoc

    if $ext_o == ".md"
    	`pandoc #{$pandog_i_sis} --atx-headers -o #{$pandog_o_sis}`
    else
    	`pandoc #{$pandog_i_sis} -o #{$pandog_o_sis}`
    end
end

puts $l_g_fin
abort
















# Cambios MD > HTML
def md_to_html
    begin
        puts $l_pg_iniciando
        # Por defecto crea un HTML sin cabeza
        `pandoc #{$pandog_i_sis} -o #{directorioPadreTerminal $pandog_o_sis}/#{File.basename($pandog_o_sis,'.*') + $pandog_coletilla + '.html'}`
	    
	    puts $l_pg_modificando
	    
	    s_nombre_final = File.basename($pandog_o)
	    s_nombre_actual = File.basename(File.basename($pandog_o), ".*") + $pandog_coletilla + ".html"
	    
	    # Va al directorio donde está el archivo de salida
	    Dir.chdir(directorioPadre($pandog_o))
	    
	    # Crea el nuevo archivo oculto donde se pondrán las modificaciones
	    html_nuevo = File.open(".#{s_nombre_actual}", "w:UTF-8")
	    
	    # Ayudará a forzar a poner todo el contenido de una etiqueta en una sola línea
	    linea_pasada = ""
	    
	    # Para que se vea mejor
	    espacio = ""
	    
	    # Agrega cabezas
	    if File.extname(s_nombre_final) == ".xml"
		    html_nuevo.puts $xmlTemplateHead
		    espacio = "    "
	    else
		    if File.extname(s_nombre_final) == ".xhtml"
			    html_nuevo.puts xhtmlTemplateHead
		    else
			    html_nuevo.puts htmlTemplateHead
		    end
		    espacio = "        "
		    
		    # Agrega la hoja de estilos minificada
		    html_nuevo.puts espacio + "<style>" + $css_template_min + "</style>"
	    end
	    
	    # Empiezaa leer línea por línea del archivo de salida
	    archivo_abierto = File.open(s_nombre_actual, "r:UTF-8")
	    archivo_abierto.each do |linea|
		    # En XML se elimina el espacio de nombres
		    if linea =~ /epub:type/ && File.extname(s_nombre_final) == ".xml"
			    linea = linea.split(/\s/)[0] + ">"
		    end
		    
		    # Sustituye de nuevo los guiones de la sintaxis de Pecas
		    pecas = [$l_g_note_content, $l_g_ignore, $l_g_delete, $l_g_change, $l_g_note]

		    pecas.each do |s|
			    if s.class == Array
				    linea = linea.gsub(/–#{s[0].gsub("--","")}(.*?)–/, s[0] + '\1' + s[1])
			    else
				    linea = linea.gsub("–" + s.gsub("--","") + "–", s)
			    end
		    end
		    
		    # Evita que los identificadores de los encabezados hereden sintaxis de Pecas
		    if linea =~ /(id=".*?)#{$l_g_marca}.*?#{$l_g_marca}(.*?")/
			    linea = linea.gsub(/(".*?)#{$l_g_marca}.*?#{$l_g_marca}(.*?")/, /(".*?)#{$l_g_marca}.*?#{$l_g_marca}(.*?")/.match(linea).captures.join)
		    end
		    
		    # Servirá para agregar atributos si los hay
		    atributos_final = Array.new
		    
		    # Si la línea no quedo vacía se agrega
		    if linea != ""
			    
			    # Si se localizan párrafos que se desean con identificadores o clases
			    p = /\s?+{.*?}<\/p>$/
			    if linea =~ p
				    # Obtiene los atributos en un conjunto ordenado
				    atributos = p.match(linea).to_s.gsub("{","").gsub("}","").gsub("</p>","").strip.split(" ").sort

				    # Extrae los identificadores y las clases en distintos grupos
				    atributos_id = Array.new
				    atributos_clase = Array.new
				    atributos.each do |a|
					    if a[0] == "#"
						    atributos_id.push(a[1..-1])
					    elsif a[0] == "."
						    atributos_clase.push(a[1..-1])
					    end
				    end
				    
				    # Crea la sintaxis correcta para los atributos
				    def atributoConstruccion conjunto, atributo
					    if conjunto.length > 0
						    resultado = atributo + "=\"" + conjunto.join(" ") + "\""
						    return resultado
					    else
						    return nil
					    end
				    end
				    
				    p_id = atributoConstruccion atributos_id, "id"
				    p_clase = atributoConstruccion atributos_clase, "class"
				    
				    # Agrega los atributos para usarlos más abajo, por el conflicto que puede acarrear el <br />
				    def adicionAtributoFinal conjunto, variable
					    if variable != nil
						    conjunto.push(variable)
					    end
				    end
				    
				    adicionAtributoFinal atributos_final, p_id
				    adicionAtributoFinal atributos_final, p_clase
				    
				    # Elimina las llaves y su contenido
				    linea = linea.gsub(p,"</p>")
			    end
			    
			    # Agrega identificadores o clases al párrafo si los hay
			    def atributosAdicion c, l, a, e
				    # Si el conjunto tiene algún elemento, entonces hay atributos
				    if c.length > 0
					    # Sustituye la etiqueta de párrafo para incluir los atributos
					    a.puts l.gsub(/^\s+<p>/, e + "<p " + c.join(" ") + ">")
				    else
					    a.puts l
				    end
			    end
		    
			    # Si se detecta un <br /> al final de la línea se guarda en lugar de agregarla
			    if linea =~ /<\s*?br.*?\/.*?>$/
				    linea_pasada += linea
			    # Si no se detecta un <br />
			    else
				    # Si existen líneas guardadas, se agregan junto con la línea actual
				    if linea_pasada != ""
					    linea = espacio + linea_pasada + linea
					    atributosAdicion atributos_final, linea, html_nuevo, espacio
					    
					    # Reseteo
					    linea_pasada = ""
				    # Si no existen líneas guardadas, únicamente se agrega la línea actual
				    else
					    linea = espacio + linea
					    atributosAdicion atributos_final, linea, html_nuevo, espacio
				    end
			    end
		    end
	    end
	    
	    # Agrega pies
	    if File.extname(s_nombre_final) == ".xml"
		    html_nuevo.puts "</body>"
	    else
		    html_nuevo.puts $xhtmlTemplateFoot
	    end
	    
	    # Cierra el archivo con las modificaciones
	    archivo_abierto.close
	    html_nuevo.close
	    
	    # Acomoda los elementos con los espacios correctos
	    beautifier html_nuevo
	    
	    # Borra el archivo viejo y renombra al nuevo para sustituirlo
	    File.delete(s_nombre_actual)
	    File.rename(".#{s_nombre_actual}", s_nombre_final)
	rescue
		puts $l_pg_error_m
		abort
	end
end

# Cambios HTML > MD
def html_to_md
    begin
        puts $l_pg_iniciando
		entrada_html = nil
		
		# Si se trata de un XML, copia el archivo en un HTML que se usará para Pandoc
		if File.extname($pandog_i) == ".xml"
			entrada_html = File.basename($pandog_i, ".*") + ".html"
			FileUtils.cp($pandog_i, entrada_html)
			$pandog_i = directorioPadre($pandog_i) + "/" + entrada_html
		end

		# Hace que los encabezados estén con gatos
		`pandoc #{$pandog_i_sis} --atx-headers -o #{$pandog_o_sis}`
		
		# Se elimina el HTML oculto de existir
		if entrada_html != nil
			File.delete(entrada_html)
		end

	    puts $l_pg_modificando

	    # Va al directorio donde está el archivo de salida
	    Dir.chdir(directorioPadre($pandog_o))
	    
	    # Crea el nuevo archivo donde se pondrán las modificaciones
	    md_nuevo = File.open("#{File.basename(File.basename($pandog_o), ".*") + $pandog_coletilla + ".md"}", "w")
	    
	    # Ayudará a detectar líneas vacías para evitar que haya de más
	    linea_pasada = nil
	    
	    # Empiezaa leer línea por línea del archivo de salida
	    archivo_abierto = File.open(File.basename($pandog_o), "r")
	    archivo_abierto.each do |linea|
		    # Elimina todas las etiquetas HTML que quedaron y espacios de más
		    linea = linea.gsub(/<[^>]*>/, "").gsub(/^\s+$/, "").strip
		    
		    # Si la línea no quedo vacía se agrega
		    if linea != ""
			    md_nuevo.puts linea
		    # Si la línea quedó vacía, solo se coloca si la línea pasada no estaba vacía
		    else
			    if linea_pasada != ""
				    md_nuevo.puts linea
			    end
		    end
		    
		    # La línea actual para a ser la pasada para la siguiente iteración
		    linea_pasada = linea
	    end
	    
	    # Cierra el archivo con las modificaciones
	    archivo_abierto.close
	    md_nuevo.close

	    # Borra el archivo viejo y renombra al nuevo para sustituirlo
	    File.delete(File.basename($pandog_o))
	    File.rename("#{File.basename(File.basename($pandog_o), ".*") + $pandog_coletilla + ".md"}", File.basename($pandog_o))
	rescue
		puts $l_pg_error_m
		abort
	end
end

def generacion_json hash
	archivo = File.new($pandog_o, 'w:UTF-8')
	archivo.puts JSON.pretty_generate(hash)
	archivo.close
end

# Comprueba que existan los argumentos necesarios
comprobacion [$pandog_i, $pandog_o]

# Arregla rutas
$pandog_i = comprobacionArchivo $pandog_i, [".md", ".html", ".xhtml", ".htm", ".xml", ".epub", ".json", ".tex", ".odt", ".docx"]
$pandog_o = arregloRuta $pandog_o

# Sirve para evitar borrara archivos incorrectos
$pandog_coletilla = "-pandog"

# Obtiene las extensiones de los archivos
ext_e = File.extname($pandog_i)
ext_s = File.extname($pandog_o)
ext_html_e = (ext_e == ".html" || ext_e == ".xhtml" || ext_e == ".htm" || ext_e == ".xml")
ext_html_s = (ext_s == ".html" || ext_s == ".xhtml" || ext_s == ".htm" || ext_s == ".xml")

# Arregla las rutas para la terminal
$pandog_i_sis = arregloRutaTerminal $pandog_i
$pandog_o_sis = arregloRutaTerminal $pandog_o

# Obliga a poner un nombre de extensión al archivo de salida
if ext_s == ""
	puts $l_pg_error_ext
	abort
end

# Permitirá la creación en un path especificado
if $pandog_o.split("/").length > 1
	$pandog_o = arregloRuta File.absolute_path($pandog_o)
end

# Va al directorio donde se encuentra el documento a transformar
Dir.chdir(directorioPadre($pandog_i))

# MD > HTML
if ext_e == ".md" && ext_html_s
    md_to_html
# HTML > MD
elsif ext_html_e && ext_s == ".md"
    html_to_md
# EPUB > JSON
elsif ext_e == ".epub" && ext_s == ".json"
    hash = epub_analisis(arregloRuta(File.absolute_path($pandog_i)))
    generacion_json hash
    FileUtils.rm_rf($l_g_epub_analisis)
# MD > JSON
elsif ext_e == ".md" && ext_s == ".json"
    md_to_html
    hash = file_to_hash(arregloRuta(File.absolute_path($pandog_o)))
    generacion_json hash
# HTML > JSON
elsif ext_html_e && ext_s == ".json"
    hash = file_to_hash(arregloRuta(File.absolute_path($pandog_i)))
    generacion_json hash
# JSON > HTML || MD
elsif ext_e == ".json" && (ext_s == ".md" || ext_html_s)
    json_to_html_md
# Lo demás
else
    if ext_s == ".md"
    	`pandoc #{$pandog_i_sis} --atx-headers -o #{$pandog_o_sis}`
    else
    	`pandoc #{$pandog_i_sis} -o #{$pandog_o_sis}`
    end
end
