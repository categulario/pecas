#!/usr/bin/env ruby
# encoding: UTF-8
# coding: UTF-8

require 'json'
require 'yaml'

Encoding.default_internal = Encoding::UTF_8

# Funciones y módulos comunes a todas las herramientas
require File.dirname(__FILE__) + "/../common/lang.rb"
require File.dirname(__FILE__) + "/../common/xhtml-beautifier.rb"

## MÓDULOS

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

## CLASES

# Para detectar que es un número entero; viene de: http://stackoverflow.com/questions/1235863/test-if-a-string-is-basically-an-integer-in-quotes-using-ruby
class String
    def is_i?
		/\A[-+]?\d+\z/ === self
    end
end

# Obtiene el tamaño de un archivo; viene de: https://stackoverflow.com/questions/16026048/pretty-file-size-in-ruby
class Integer
    def to_filesize
        {
            'B'  => 1024,
            'KB' => 1024 * 1024,
            'MB' => 1024 * 1024 * 1024,
            'GB' => 1024 * 1024 * 1024 * 1024,
            'TB' => 1024 * 1024 * 1024 * 1024 * 1024
        }.each_pair { |e, s| return "#{(self.to_f / (s / 1024)).round(2)}#{e}" if self < s }
    end
end

# Obtiene el mimetype y la codificación de un archivo; inspirado en: https://stackoverflow.com/questions/24897465/determining-encoding-for-a-file-in-ruby
class String
    def detect_mimetype_charset
        begin
            if OS.mac?
                output = `file -I #{arregloRutaTerminal self}`.strip.split(': ')[1].split('; ')
            else
                output = `file -i #{arregloRutaTerminal self}`.strip.split(': ')[1].split('; ')
            end

            return [output[0], output[1].split('=')[1]]
        rescue
            $l_g_error_no_identificado
        end
    end
end

## FUNCIONES

# Obtiene el hash según un valor buscado como expresión regular; modificación de: https://stackoverflow.com/questions/8301566/find-key-value-pairs-deep-inside-a-hash-containing-an-arbitrary-number-of-nested
def nested_hash_value obj, key, value
    if obj.respond_to?(:key?) && obj.key?(key) && obj[key] =~ /#{value}/
        obj
    elsif obj.respond_to?(:each)
        r = nil
        obj.find{ |*a| r = nested_hash_value(a.last, key, value) }
        r
    end
end

# Obtiene los argumentos
def argumento condicion, resultado, tipo = 0
	# 0 ==> quiere texto
	# 1 ==> quiere booleano
	
	# Iteración hasta encontrar la condición buscada
	ARGF.argv.each_with_index do |p, i|
		if p == condicion
			# Si se introdujo un texto, se imprime y aborta el scrip; se usa para -v o -h, por ejemplo
			if resultado.is_a? String
				puts resultado
				abort
			# Si se trata de un parámetro nulo, se le da un valor
			else
				# Para cuando se quiere un booleano
				if tipo == 1
					resultado = true
				# Para cuando se quiere una línea de texto; toma el valor inmediato, p. ej. de -d tomará la ruta del directorio
				else
					# Si sí hay un elemento siguiente, se avanza, marca error y aborta si no
					begin
						# Si el siguiente argumento no empieza con «-» se registra el valor, marca error y aborta si no
						if ARGF.argv[i+1][0] != "-"
							resultado = ARGF.argv[i+1]
						else
							puts $l_g_error_arg2
							abort
						end
					rescue
						puts $l_g_error_arg
						abort
					end
				end
			end
		end
	end
	
	# Regresa el valor
	return resultado
end

# Comprueba que existan los argumentos necesarios
def comprobacion conjunto
	conjunto.each do |e|
		# Si al menos una de las variables es nulo, se muestra el error y aborta
		if e == nil
			puts $l_g_error_arg
			abort
		end
	end
end

# Comprueba que la carpeta sea válida
def comprobacionDirectorio carpeta
	if carpeta != nil
		c = carpeta
		carpeta = arregloRuta(File.absolute_path(carpeta))

		if !File.directory?(carpeta)
			puts "#{$l_g_error_directorio[0] + c + $l_g_error_directorio[1]}".red.bold
			abort
		else
			return carpeta
		end
	end
end

# Comprueba que el archivo sea válido
def comprobacionArchivo archivo, extension
	if archivo != nil
		a = archivo
		archivo = arregloRuta(File.absolute_path(archivo))
		valido = false
		
		# Comprueba de que exista
		if !File.exists?(archivo)
			puts "#{$l_g_error_archivo[0] + a + $l_g_error_archivo[1]}".red.bold
			abort
		end
		
		# Itera hasta dar con una extensión válida
		extension.each do |e|
			if File.extname(archivo) == e
				valido = true
				break
			end
		end
		
		#Comprueba que sea una extensión válida
		if !valido
			puts puts "#{$l_g_error_archivo2[0] + a + $l_g_error_archivo2[1]}".red.bold
			abort
		end
		
		return archivo
	end
end

# Enmienda ciertos problemas con la línea de texto
def arregloRuta elemento
	# Elimina espacios al inicio y al final
    elemento = elemento.strip

    # Elimina caracteres confictivos
    elementoFinal = elemento.gsub("file:","").gsub("%20"," ").gsub('\\', '')

    # Se codifica para que no exista problemas con las tildes
    elementoFinal = elementoFinal.encode!(Encoding::UTF_8)

    return elementoFinal
end

# Enmienda ciertos problemas con la línea de texto pasa su uso directo en el sistema
def arregloRutaTerminal elemento
	ruta = elemento.gsub(/\s/, "\\ ")
	
	return ruta.gsub(",", "\\,")
end

# Obtiene el directorio donde se encuentra el archivo
def directorioPadre archivo
	directorio = ((arregloRuta File.absolute_path(archivo)).split("/"))[0..-2].join("/")
end

# Obtiene el directorio donde se encuentra el archivo para uso directo en el sistema
def directorioPadreTerminal archivo
    directorio = ((arregloRuta File.absolute_path(archivo)).split("/"))[0..-2].join("/").gsub(/\s/, "\\ ")
	
	return directorio
end

def cambioContenido archivo_cambio, regex, contenido
	archivo_actualizado = Array.new
	
	# Analiza el archivo viejo y sustituye la línea deseada
	archivo = File.open(archivo_cambio, 'r:UTF-8')
	archivo.each do |linea|
		if linea =~ regex
			archivo_actualizado.push(contenido)
		else
			archivo_actualizado.push(linea)
		end
	end
	archivo.close
	
	# Se actualiza la información
	archivo = File.new(archivo_cambio, 'w:UTF-8')
	archivo.puts archivo_actualizado
	archivo.close
end

# Verifica que la codificación sea UTF-8, de lo contrario, la corrige
def codificacionValida? elemento
	if ! elemento.valid_encoding?
		elemento = elemento.encode("UTF-16be", :invalid=>:replace, :replace=>"?").encode('UTF-8')
		elemento.gsub(/dr/i,'med')
	end
	
	return elemento
end

# Translitera el nombre de los archivos para evitar errores
def transliterar texto, oracion = true, cortar = false
	# Elementos particulares a cambiar
	elementos1 = "ñáàâäéèêëíìîïóòôöúùûü"
	elementos2 = "naaaaeeeeiiiioooouuuu"
	
	# Pone el texto en bajas
	texto = texto.downcase
	
	# Limita el nombre a cinco palabras
    if oracion
	    texto = texto.split(/\s+/)
        if cortar == false
    	    texto = texto[0..4].join("_")
        else
    	    texto = texto.join("_")
        end
    end
	
	# Cambia los elementos particulares
    texto = texto.tr(elementos1, elementos2)
	
	# Todo lo que son etiquetas viejas o nuevas de Pecas o caracteres no alfanuméricos se eliminan
	return texto.gsub(/ºº\w+?ºº/,"").gsub(/--\w+?--/,"").gsub(/\W/,"")
end

# Agrega archivos a una carpeta determinada
def adicion_archivos ruta, ubicacion, carpeta, extensiones
	# Va a la carpeta que contiene las imágenes
	Dir.chdir(ruta)
	
	# Se itera para obtener cada imagen y copiarla
	Dir.glob("*") do |archivo|
		extensiones.each do |ext|
			if File.extname(archivo) == "." + ext
				FileUtils.cp(archivo, ubicacion + "/" + carpeta)
			end
		end
	end 
	
	# Regresa a la ubicación del proyecto
	Dir.chdir(ubicacion)
end

# Obtiene las rutas de archivos con una ubicación y extensión definida
def obtener_rutas_archivos conjunto, ubicacion, extension
    if conjunto == nil then conjunto = [] end

    Dir.glob(ubicacion.gsub(/\/\s*?$/, '') + '/*.*') do |archivo|
        if File.extname(archivo) == extension
            conjunto.push(archivo)
        end
    end

    return conjunto.sort
end

def obtener_contenido_archivo rutas, conjunto, espacio_inicial = '', archivo_especifico = nil
    if conjunto == nil then conjunto = [] end

    def iteracion r, c, e
        archivo_abierto = File.open(r, 'r:UTF-8')
        archivo_abierto.each do |linea|
            c.push(e + codificacionValida?(linea))
        end
        archivo_abierto.close

        return c
    end

    rutas.each do |ruta|
        if archivo_especifico != nil
            if File.basename(ruta) == archivo_especifico
                conjunto = iteracion(ruta, conjunto, espacio_inicial)
            end
        else
            conjunto = iteracion(ruta, conjunto, espacio_inicial)
        end
    end

    return conjunto
end

# Analiza el EPUB para obtener un hash convertible a JSON
def epub_analisis epub

    epub_directorio = directorioPadre epub
    todo = {}
    archivo_opf = nil
    pwd_old = Dir.pwd

    # Obtiene las rutas absolutas a cada archivo HTML dentro del EPUB
    def html_urls urls, opf, path
        opf.each do |k,v|
            # Si ya se localizó el manifiesto
            if k =~ /manifest/
                # Iteración del contenido del manifiesto
                v['content'].each do |i|
                    if i['$item'] != nil
                        # Obtiene la ruta relativa del archivo
                        archivo = i['$item']['attributes']['_href']

                        # Se añade la ruta absoluta si se trata de un documento tipo HTML
                        if File.extname(archivo)[1..-1] == 'xhtml' || File.extname(archivo)[1..-1] == 'html' || File.extname(archivo)[1..-1] == 'htm'
                            # Se excluye el HTMl de navegación
                            if i['$item']['attributes']['_properties'] != 'nav'
                                urls.push(path + '/' + archivo)
                            end
                        end
                    end
                end
            # Si el manifiesto aún no es localizado
            else
                # Busca un hash para poder localizar la llave `$manifiest`
                if v.kind_of?(Array)
                    v.each do |e|
                        if e.kind_of?(Hash)
                            html_urls(urls, e, path)
                        end
                    end
                elsif v.kind_of?(Hash)
                    html_urls(urls, v, path)
                end
            end
        end
    end

    # Se va adonde está el EPUB
    Dir.chdir(epub_directorio)

    # Descomprime para iniciar el análisis
    puts $l_g_descomprimiendo
    system ("unzip -qq #{arregloRutaTerminal epub} -d #{arregloRutaTerminal epub_directorio}/#{$l_g_epub_analisis}")

    # Busca el archivo OPF
    Dir.glob($l_g_epub_analisis + "/**/*") do |archivo|
        if File.extname(archivo) == ".opf"
            archivo_opf = archivo
            break
        end
    end
    if archivo_opf == nil then puts $l_g_error_opf; abort end

    # Se extrae la infomación del OPF
    archivo_opf = file_to_hash(archivo_opf)

    # Añade el OPF al objeto general
    todo['opf'] = archivo_opf

    # Se obtienen las rutas absolutas de los HTML adentro del EPUB
    html = []; html_urls(html, archivo_opf, directorioPadre(archivo_opf['path']))

    # Se crea el elemento para poner todos los HTML
    todo['htmls'] = []

    # Añade la infomación de cada HTML al todo
    html.each_with_index do |h,i|
        todo['htmls'].push(file_to_hash(h))
    end

    # Regresa al directorio inicial
    Dir.chdir(pwd_old)

    return todo
end

# Convierte el archivo tipo HTML en un hash
def file_to_hash ruta
    puts "#{$l_g_analizando[0] + File.basename(ruta) + $l_g_analizando[1]}".green

    # Va de un conjunto con espacios como jerarquías a un hash
    def array_to_yaml conjunto, nivel
        $conjunto_yaml = Array.new(conjunto.length)

        # Va a iterar desde los niveles más altos a los más bajos
        def por_nivel conjunto, nivel
            numero = nivel == 0 ? numero = nivel : numero = (((nivel * 2) + ((nivel -1) * 4) + 2) / 2)
            $espacio_yaml = '  ' * numero

            # Obtiene los atributos de los tags
            def atributos etiquetas, nivel
                texto_limpio = etiquetas.gsub(/<\s*\w+\s+(.*?)>/,'\1')          # Elimina el tag y deja los puros atributos
                llaves = texto_limpio.scan(/\S*?="/).to_a                       # Obtiene el atributo
                valores = texto_limpio.scan(/".*?"/).to_a                       # Obtiene el valor del atributo

                # Sintaxis inicial del objeto para los atributos
                if nivel == 0
                    atributos_yaml = "\n" + $espacio_yaml + "  attributes:"
                else
                    atributos_yaml = "\n" + $espacio_yaml + "    attributes:"
                end

                # A cada atributo se la agrega su valor
                llaves.each_with_index do |l,i|
                    if nivel == 0
                        atributos_yaml += "\n" + $espacio_yaml + "    _#{l.gsub('="','')}: \"#{valores[i].gsub('"','')}\""
                    else
                        atributos_yaml += "\n" + $espacio_yaml + "      _#{l.gsub('="','')}: \"#{valores[i].gsub('"','')}\""
                    end
                end

                # Solo regresa si hubo atributos, de lo contrario es vacío
                return atributos_yaml.strip != "attributes:"  ? atributos_yaml : ''
            end

            conjunto.each_with_index do |l, i|
                # Si es un tag único o inicial
                if l =~ /<[^\s*\/]/ && l.gsub(/(\t*?)\S.*$/, '\1').length == nivel
                    tag = l.strip.gsub(/(<|>|\/\s*>)/,'').split(/\s+/)[0]
                    atributos = atributos(l, nivel)

                    if nivel == 0
                        contenido_inicio = "\n" + $espacio_yaml + "  content:"
                        texto = $espacio_yaml + "$" + tag + ':' + atributos + (l =~ /\/\s*>/ ? '' : contenido_inicio)
                    else
                        contenido_inicio = "\n" + $espacio_yaml + "    content:"
                        texto = $espacio_yaml + "- $" + tag + ':' + atributos + (l =~ /\/\s*>/ ? '' : contenido_inicio)
                    end

                    # Si se da el caso de etiquetas únicas sin nada (como <br />) se le agrega un objeto vacío
                    if texto.split("\n").length == 1
                        texto = texto + ' {}'
                    end
                    # Sustituye el contenido por el valor de «texto»
                    $conjunto_yaml = $conjunto_yaml.map.with_index { |e, j| i == j ? texto : e }
                # Si no es tag
                elsif l.strip !~ /^</ && l.gsub(' ', '').gsub(/(\t*?)\S.*$/, '\1').length == nivel + 1
                    contenido = $espacio_yaml + "      - \"" + l.gsub(/^\t*/,'').gsub('"', '\"') + "\""

                    # Sustituye el contenido por el valor de «contenido»
                    $conjunto_yaml = $conjunto_yaml.map.with_index { |e, j| i == j ? contenido : e }
                # Si es tag final
                elsif l.gsub(/(\t*?)\S.*$/, '\1').length == nivel
                    espacio = l.gsub(/^\t*?<.*?>/,'')
                    contenido = espacio != '' ? contenido = $espacio_yaml + "    end_space : true" : contenido = ''

                    # Sustituye el contenido por vacío
                    $conjunto_yaml = $conjunto_yaml.map.with_index { |e, j| i == j ? contenido : e }
                end
            end

            # Sube de nivel si todavía no se llega a 0
            if nivel - 1 >= 0 then por_nivel(conjunto, nivel -1) end
        end

        por_nivel(conjunto, nivel)

        # Se agregan el content para saber dónde empieza el contenido y la profundidad -1, porque se eliminará un nivel
        return $conjunto_yaml.unshift("  deep: #{nivel - 1}\n  content:").compact.reject{|l| l.empty?}
    end

    # Va de una línea de texto a un conjunto con espacios que jerarquizan el contenido
    def text_to_array_to_yaml texto
        conjunto_inicial = texto.gsub(/(<.*?>)/, "\n" + '\1' + "\n").split("\n").compact.reject{|l| l.empty?} # Produce un conjunto sin jerarquías
        conjunto_final = []
        espacio = ''
        aumento = "\t"
        niveles = 0

        # Iteración para empezar a dar jerarquías
        conjunto_inicial.each_with_index do |l,i|
            # Si es un tag
            if l =~ /^</
                if l =~ /^<[^\s*\/]/
                    # Si es un tag único (<…/>)
                    if l =~ /\/\s*>/
                        # El espacio en general no es afectado
                        l = espacio + aumento + l
                        # Obtiene el mayor número de nivel
                        niveles = (espacio + aumento).length > niveles ? niveles = (espacio + aumento).length : niveles = niveles
                    # Si es un tag inicial (<…>)
                    else
                        # El espacio aumenta a uno
                        espacio = espacio + aumento
                        l = espacio + l

                        # Obtiene el mayor número de nivel
                        niveles = espacio.length > niveles ? niveles = espacio.length : niveles = niveles
                    end
                # Si es un tag final (</…>)
                else
                    l = espacio + l
                    espacio = espacio.gsub(/#{aumento}$/, '')
                end
            # si es contenido
            else
                # El espacio en general no es afectado
                l = espacio + aumento + l.gsub("\\","&#92;")
                # Ojo: el carácter `\` salió conflictivo, por lo que fue reemplazado por su entidad html
                #   quizá más elementos necesiten esto; véase: https://www.freeformatter.com/html-entities.html
            end
            
            conjunto_final.push(l)
        end

        return array_to_yaml(conjunto_final, niveles)
    end
    
    # Iteración para obtener el contenido
    lineas = []
    cierre_cabeza = false
    archivo_abierto = File.open(ruta, 'r:UTF-8')
    archivo_abierto.each_with_index do |linea, i|
        # Evasión de <?xml… o <!DOCTYPE…
        if i < 10
            if linea !~ /(^\s*?<\s*?\?|^\s*?<\s*?\!DOCTYPE)/
                if !cierre_cabeza
                    lineas.push(linea.strip)
                else
                    cierre_cabeza = false
                end
            else
                # Ignora la siguiente línea si el cierre de <?xml o <!DOCTYPE está en otra línea
                if linea !~ />\s*$/ then cierre_cabeza = true end
            end
        else 
            lineas.push(linea.strip)
        end
    end
    archivo_abierto.close

    # Une las líneas en una sola línea de texto para empezar su conversión a hash
    yaml = text_to_array_to_yaml(codificacionValida? lineas.join('')).map{|l| l.gsub(/^  /,'')}

    # Añade el nombre del archivo, su ruta, tamaño, mimetype, codificación y lo preliminar para identificar el contenido
    yaml = yaml.unshift("file: \"#{File.basename(ruta)}\"\npath: \"#{ruta}\"\nsize: \"#{File.size(ruta).to_filesize}\"\nmimetype: \"#{ruta.detect_mimetype_charset[0]}\"\ncharset: \"#{ruta.detect_mimetype_charset[1]}\"")

    # El YAML pasa a ser un hash
    begin
        hash = YAML.load(yaml.join("\n"))
    rescue
        puts "#{$l_ch_error_archivo[0] + File.basename(ruta) + $l_ch_error_archivo[1]}".red.bold
        FileUtils.rm_rf($l_g_epub_analisis)
        abort
    end

    return hash
end

# Convierte el hash a un conjunto con sintaxis HTML
def hash_to_html hash, list = nil
    tipo = if File.extname(hash['file'])[1..-1] == 'opf' || File.extname(hash['file'])[1..-1] == 'xml' || File.extname(hash['file'])[1..-1] == 'xhtml' || File.extname(hash['file'])[1..-1] == 'html' || File.extname(hash['file'])[1..-1] == 'htm' then tipo = File.extname(hash['file'])[1..-1] else tipo = nil end
    html = []
    $i_item = 1
    $ids_items = []
    $file_item = hash['file']

    # Comprobación porque la extensión y el nivel son necesarios
    if tipo == nil then puts $l_g_error_hash; abort end
    
    # Pasa el contenido del hash a HTML
    def contenido_a_html a, html, list, on_body, on_style

        # Añade atributos si los hay
        def atributos elemento
            if elemento['attributes'] != nil
                att = []
                # Iteración de todos los atributos
                elemento['attributes'].each do |k,v|
                    att.push(' ' + k[1..-1] + '="' + v + '"')
                end
                # Regresa los atributos en una sola línea
                return att.join('')
            end
            return ''
        end

        # Añade espacio al final de la etiqueta si lo hay
        def espacio elemento, final = nil
            if final != '>'
                return elemento['end_space'] != nil ?  espacio = ' ' : espacio = ''
            end
            return ''
        end

        # Cierra el tag
        def cierre elemento
            if elemento != nil
                final = elemento['content'] != nil ? final = '>' : final = '/>'
                return atributos(elemento) + final + espacio(elemento, final)
            else
                return ''
            end
        end

        # Iteración de cada contenido
        a.each_with_index do |e|
            # Si es tag
            if e.kind_of?(Hash)
                e.each do |k,v|

                    # Ayuda a determinar cuando el contenido ya es de las etiquetas body o style
                    if k =~ /body/
                        on_body = true
                    elsif k =~ /style/
                        on_style = true
                    else
                        on_style = false
                    end

                    # Inicio del tag, sea único o de apertura
                    html.push("<#{k[1..-1]}" + cierre(v))

                    # Si no es tag único
                    if v != nil && v['content'] != nil
                        # Nueva iteración para seguir yendo al fondo
                        contenido_a_html(v['content'], html, list, on_body, on_style)

                        # Añade el tag de cierre
                        html.push("</#{k[1..-1]}>" + espacio(v))
                    end

                end
            # Si es texto
            else
                # Cuando no se trata de pc-index
                if list == nil
                    html.push(e)
                # Uso exclusivo para la adición de entradas de los índices con pc-index
                else
                    if on_body == true && on_style == false
                        i_index = list["index"]

                        # Iteración de cada elemento del índice
                        list["items"].each_with_index do |item, i|
                            regex = /\b(#{item.last})\b/

                            # Añade las referencias pero sin el identificador único de cada coincidencia, así es posible tener términos que tengan más de una palabra
                            e = e.gsub(regex, '<span class="' + $l_in_item_span + '" id="' + $l_in_item_id + '-' + i_index.to_s + '-' + i.to_s + '-@@@">' + '\1' + '</span>')

                            # La división por palabra ayuda a analizar cada una para agregarle el identificador único a cada coincidencia
                            words = e.split(' ')
                            e_new = []

                            # Iteración de cada palabra del contenido
                            words.each do |w|
                                # Si la palabra contiene el elemento del índice, se agrega la referencia
                                if w =~ /-@@@">/
                                    e_new.push(w.gsub('-@@@">', '-' + $i_item.to_s + '">'))

                                    # Añade el identificador y el archivo donde se encuentra
                                    $ids_items.push({'term' => item.first, 'id' => i_index.to_s + '-' + i.to_s + '-' + $i_item.to_s, 'file' => $file_item})

                                    # Aumenta uno los números para el índice
                                    $i_item = $i_item + 1
                                else
                                    e_new.push(w)
                                end
                            end

                            # Se recrea la línea de texto completo, incluyendo los espacios al inicio o al finales, si los tiene
                            e = (e[0] == ' ' ? e[0] : '') + e_new.join(' ') + (e[-1] == ' ' ? e[-1] : '')

                        end
                    end

                    html.push(e)
                end
            end
        end
    end

    contenido_a_html(hash['content'], html, list, false, false)

    # Jerarquiza
    html = beautifier_html(html)

    # Se añade el tipo de documento si es XHTML, HTML y HTM
    if tipo == 'xhtml' || tipo == 'html' || tipo == 'htm'
        html.unshift("<!DOCTYPE html>")
    end

    # Se añade la versión XML si es OPF, XML o XHTML
    if tipo == 'opf' || tipo == 'xml' || tipo == 'xhtml'
        html.unshift("<?xml version=\"1.0\" encoding=\"utf-8\"?>")
    end

    if list == nil
        return html
    else
        return [$ids_items, html]
    end
end

# Traduce de un MD al contenido del body de un html
def md_to_html ruta
    md = []
    $headers_ids = []

    def translate_blocks md
        translated_md = []

        # Traduce los saltos de línea forzados
        def line_break array
            new_array = []

            array.each do |e|
                new_array.push(e.gsub(/\\$/, '<br/>'))
            end

            return new_array
        end

        # Traduce atributos HTML para clases y encabezados
        def attributes class_id, header = false
            attributes = ''
            classes = ''
            id = ''

            # Evita ids repetidos
            $i = 2
            def verification_id id
                $headers_ids.each do |h|
                    # Si se encuentra un id repetido, se agrega una coletilla con «_» más el número correspondiente según su orden de aparición
                    if h == id && id.length > 0
                        id = id.gsub(/_\d+/, '') + '_' + $i.to_s
                        $i += 1
                    end
                end

                # Elimina dígitos al inicio del id para evitar que sea inválido
                id = id.gsub(/^\d+-/, '')

                # Colecciona para comparar
                $headers_ids.push(id)

                return id
            end

            # Obtiene el id como texto
            if class_id != nil && class_id['id'] != nil
                id = class_id['id']
            else
                if header != false
                    id = transliterar(header.gsub(/<.*?>/,''), true, true).gsub('_', '-').gsub('--', '-')
                end
            end

            id = verification_id(id)

            # Obtiene las clases como texto
            if class_id != nil && class_id['class'] != nil
                classes = class_id['class'].join(' ')
            end

            # Añade id y clases como texto
            attributes = (id.length > 0 ? ' id="' + id + '"' : '') + (classes.length > 0 ? ' class="' + classes + '"' : '')
        end

        # Traduce los encabezados
        def translate_h array
            text = line_break(array)
            text = translate_inline(text.join(' ').gsub(/^#*\s*/,'').gsub(/\s*{[^{]*?}\s*$/,''))
            header = array.first.gsub(/^(#*).*$/, '\1').length.to_s
            attribute = attributes(get_classes_ids(array), text)

            # Regresa la traducción, es necesario que existe algo de texto
            if text.length > 0
                return '<h' + header + attribute + '>' + text + '</h' + header + '>'
            else
                return ''
            end
        end

        # Traduce los bloques de cita
        def translate_blockquote array
            attribute = attributes(get_classes_ids(array))

            # Un nuevo conjunto que elimina sintaxis de Markdown para los bloques de cita
            new_array = []
            array.each do |l|
                new_array.push(l.gsub(/^>\s*/, '').gsub(/\s*{[^{]*?}\s*$/,''))
            end

            text = translate_inline(line_break(new_array).join(' '))

            # Regresa la traducción, es necesario que existe algo de texto
            if text.length > 0
                return '<blockquote' + attribute + '><p>' + text + '</p></blockquote>'
            else
                return ''
            end
        end

        # Traduce las listas
        def translate_li array
            new_array = []

            # Crea un hash donde se indica el nivel de jerarquía de cada ítem
            def hierarchy control_level, array
                tmp_array = []
                new_array = []
                level = 0
                control_level = 0

                # De cada elemento crea un objeto que indica el nivel, tipo y contenido (incluyendo atributos) del ítem
                def create_obj e, level
                    attribute = attributes(get_classes_ids([e.strip]))
                    type = e.strip.split(/\s+/)[0][0] =~ /\d/ ? 'ol' : 'ul'

                    # Si el objeto es un tipo de lista
                    if e =~ /^\s*(@type|{.*?})/
                        raw_style = e.strip.gsub(/^\s*@type\[(.*?)\].*$/, '\1').gsub(/\s*{[^{]*?}\s*/,'')
                        style = raw_style != '' ? ' style="list-style-type: ' + raw_style + ' !important"' : ''

                        # Si se trata de un estilo dash, en-dash o em-dash, desplaza el estilo a los atributos
                        if style =~ /dash/
                            style = ''
                            attr_split = attribute.split(' class="')

                            # Cuando en el atributo contiene clases
                            if attr_split.length == 2
                                attribute = attr_split[0] + ' class="' + raw_style + ' ' + attr_split[1]
                            # Cuando en el atributo solo hay id
                            elsif attr_split.length == 1
                                attribute = attr_split[0] + ' class="' + raw_style + '"'
                            # Cuando no hay ningún atributo
                            elsif attr_split.length == 0
                                attribute = ' class="' + raw_style + '"'
                            end
                        end

                        obj = {'style' => style, 'attribute' => attribute}
                    # Si el objeto es un ítem de lista
                    else
                        text = translate_inline(e.strip.gsub(/^.+?\s+/, '').gsub(/\s*{[^{]*?}\s*$/,''))
                        obj = {'level' => level, 'type' => type, 'item' => '<li' + attribute + '><p>' + text + '</p></li>'}
                    end

                    return obj
                end

                # Obtiene el nivel actual del ítem
                def obtain_level e, level
                    if e !~ /^\s*(@type|{.*?})/
                        spaces = e.gsub(/^(\s*)?[^\s].*$/, '\1').length

                        # Evita aumentar niveles más allá de la diferencia de uno por aquello de una mala redacción de la sintaxis
                        if spaces / 2 > level
                            level = level + 1
                        elsif spaces / 2 < level
                            level = (spaces / 2).to_i
                        end

                        return level
                    end

                    return level
                end

                # Guarda temporalmente un conjunto con cada uno de los ítems como objetos
                array.each do |e|
                    level = obtain_level(e, level)
                    obj = create_obj(e, level)

                    tmp_array.push(obj)
                end

                # Inicia la creación de la lista
                if tmp_array.first['type'] != nil
                    new_array.push('<' + tmp_array.first['type'] + '>')
                else
                    new_array.push('<' + tmp_array[1]['type'] + tmp_array.first['attribute'] + tmp_array.first['style'] + '>')
                end

                # Añade los contenidos de la lista
                opens = []
                counter = false
                tmp_array.each_with_index do |e, i|

                    # Esto implica que es un ítem, no un tipo de lista
                    if e['level'] != nil
                        # Si se trata de un nivel distinto
                        if control_level != e['level']

                            # Siel nuevo nivel es mayor
                            if control_level < e['level']

                                # Añade el tipo de lista a un conjunto para tener control en su cierre
                                if counter == false
                                    new_array.push('<li class="no-count"><' + e['type'] + '>')
                                    opens.push(e['type'])
                                else
                                    counter = false
                                end

                            # Si el nuevo nivel es menor
                            else

                                # Añade la etiqueta final
                                def add_end a, o
                                    a.push('</' + o.last + '></li>')

                                    # Elimina el último tipo, porque ya fue utilizado
                                    return o[0..-2]
                                end

                                ends = (control_level - e['level']).abs
                                for j in 1..ends
                                    opens = add_end(new_array, opens)
                                end
                            end

                            # Añade el contenido del ítem
                            new_array.push(e['item'])

                            # Actualiza el controlador de nivel
                            control_level = e['level']
                        # Si es el mismo nivel
                        else
                            # Añade el contenido del ítem
                            new_array.push(e['item'])
                        end
                    # Si es un tipo de lista que no es para la primera jerarquía
                    else
                        if i > 0
                            new_array.push('<li class="no-count"><' + tmp_array[i + 1]['type'] + e['attribute'] + e['style'] + '>')
                            opens.push(tmp_array[i + 1]['type'])
                            counter = true
                        end
                    end
                end

                if opens.length > 0
                    opens.each do |o|
                        new_array.push('</' + o+ '></li>')
                    end
                end

                # Finaliza la creación de lista
                if tmp_array.first['type'] != nil
                    new_array.push('</' + tmp_array.first['type'] + '>')
                else
                    new_array.push('</' + tmp_array[1]['type'] + '>')
                end

                return new_array
            end

            # Mete las líneas de texto que forman parte de un ítem
            array = array.join("\n").gsub(/\n\s*((?!(\s*\d+\.\s+|\s*\*\s+|\s*\+\s+|\s*-\s+|\s*@type|\s*{.*?})).*)/, ' \1').split("\n")

            # Obtiene la jerarquía
            new_array = hierarchy(0, array)
        end

        # Traduce las imágenes
        def translate_img array
            attribute = attributes(get_classes_ids(array))
            url = array.join('').gsub(/.*\((.*?)\).*$/,'\1')
            text = translate_inline(array.join('').gsub(/.*\[(.*?)\].*$/,'\1'))
            src = url.length > 0 ? ' src="' + url + '"' : ''
            alt = text.length > 0 ? ' alt="' + text.gsub(/<[^<]+?>/, '') + '"' : ''

            # Elimina sintaxis de Pecas como @note
            alt = alt.gsub(/@\w+/, '')

            # Según si hay pie de foto o no, es la estructura de la imagen
            if text.length > 0
                return '<figure><img' + attribute + src + alt + '/><figcaption>' + text + '</figcaption></figure>'
            else
                return '<img' + attribute + src + alt + '/>'
            end
        end

        # Traduce los bloques de código
        def translate_pre array
            attribute = attributes(get_classes_ids(array))
            new_class = array.first.gsub(/```/, '').strip
            text = ''

            # Acomoda el atributo para añadir una nueva clase si es que se especificó el tipo de bloque de código
            if attribute.length > 0
                attribute = attribute.split('class="')[0] + 'class="' + new_class + ' ' + attribute.split('class="')[1]
            else
                attribute = ' class="' + new_class + '"'
            end

            # Todo se anida en un <pre> y sus hijos empiezan con <code> donde cada uno tiene la clase «code-line-x», siendo x el número de línea
            array.each_with_index do |e, i|
                if i == 0
                    text = '<pre' + attribute + '>'
                elsif i == array.length - 1
                    text += '</pre>'
                else
                    text += '<code class="code-line-' + i.to_s + '">' + e.gsub('&', '&#38;').gsub('<', '&lt;').gsub('>', '&gt;') + '</code>'
                end
            end

            return text
        end

        # Traduce las barras horizontales
        def translate_hr array
            attribute = attributes(get_classes_ids(array))

            return '<hr' + attribute + '/>'
        end

        # Traduce los párrafos
        def translate_p array
            attribute = attributes(get_classes_ids(array, true))
            new_array = []

            # Elimina todo espacio al inicio y al final
            array.each do |e|
                new_array.push(e.strip)
            end

            text = translate_inline(line_break(new_array).join(' ')).gsub(/\s*{[^{]*?}\s*$/,'')

            # Según si hay pie de foto o no, es la estructura de la imagen
            if text.length > 0
                return '', '<p' + attribute + '>' + text + '</p>'
            else
                return ''
            end
        end

        md.each do |block|
            # Si es encabezado
            if detect_block_type(block.first) == 'header'
                text = translate_h(block)
            # Si es bloque de cita
            elsif detect_block_type(block.first) == 'quote'
                text = translate_blockquote(block)
            # Si es lista
            elsif detect_block_type(block.first) == 'list'
                text = translate_li(block)
            # Si es imagen
            elsif detect_block_type(block.first) == 'image'
                text = translate_img(block)
            # Si es bloque de código
            elsif detect_block_type(block.first) == 'code'
                text = translate_pre(block)
            # Si es barra horizontal
            elsif detect_block_type(block.first) == 'bar'
                text = translate_hr(block)
            # Si es HTML
            elsif detect_block_type(block.first) == 'html'
                text = block.join('')
            # Si es párrafo
            elsif detect_block_type(block.first) == 'paragraph'
                text = translate_p(block)
            end

            # Solo se añade si hay texto
            if text != nil && text.length > 0
                translated_md.push(text)
            end
        end

        return translated_md
    end

    md = get_blocks(ruta, md)
    md = translate_blocks(md)

    return md
end

# Detecta eltipo de block de Pecas Markdown
def detect_block_type line
    # Si es encabezado
    if line =~ /^#/
        return 'header'
    # Si es bloque de cita
    elsif line =~  /^>/
        return 'quote'
    # Si es lista
    elsif line =~ /^(\*\s+|\+\s+|-\s+|\d+\.\s+|@type|{.*?}\s*)/
        return 'list'
    # Si es imagen
    elsif line =~ /^\!\[/
        return 'image'
    # Si es bloque de código
    elsif line =~ /^```/
        return 'code'
    # Si es barra horizontal
    elsif line =~ /^---(\s*{[^{]*?}\s*|\s*)$/
        return 'bar'
    # Si es HTML
    elsif line =~ /^\s*<.*?>\s*$/
        return 'html'
    # Si es párrafo
    else
        return 'paragraph'
    end
end

# Traduce todos los estilos en línea de Pecas Markdown
def translate_inline text, html = true

    # Empajera el regex detectado con lo que trabajará para sustitución
    def pair_regex r1, r2
        r = []
        r1.each_with_index do |e, i|
            r.push([e, r2[i]])
        end
        return r
    end

    regex_raw = [
        /&/,                                                                                # Símbolo «&»
        /(.?)(\!\[)(([^({.*?})|(\].*?\[)]|\.|\?|\*|\(|\))+?)(\]\()([^\s]*)(\))(\W|\s|$)/,   # Imagen
        /(.?)(\[)(([^({.*?})|(\].*?\[)]|\.|\?|\*|\(|\))+?)(\]\()([^\s]*)(\))(\W|\s|$)/,     # Enlace
        /(.?)(\*{2})(({|}|\d|(\*.*?\*)|[^\*{2}])+?)(\*{2})/,                                # Negritas semántica
        /(.?)(_{2})(({|}|\d|(_.*?_)|[^_{2}])+?)(_{2})/,                                     # Negritas
        /(.?)(\*)(([^\*])+?)(\*)/,                                                          # Itálicas semántica
        /([^(http:\S)]|\W|^)(.?)(_)(([^_])+?)(_)/,                                          # Itálicas
        /(.?)(~{2})(({|}|\d|(~.*?~)|[^~{2}])+?)(~{2})/,                                     # Tachado
        /(.?)(~)(([^~])+?)(~)/,                                                             # Subíndice
        /(.?)(\^)(([^\^])+?)(\^)/,                                                          # Superíndice
        /(.?)(\+{3})(({|}|\d|(\+.*?\+)|[^+{3}])+?)(\+{3})/,                                 # Versalitas
        /(.?)(\+{2})(({|}|\d|(\+.*?\+)|[^+{2}])+?)(\+{2})/,                                 # Versalitas ligera
        /(.?)(`)(([^`])+?)(`)/,                                                             # Código
        /(.?)(\[)([^\[]+?)(\])({.*?})/,                                                     # Span personalizado
        /(.?)(----)/,                                                                       # Barra
        /(.?)(---)/,                                                                        # Raya
        /(.?)(--)/,                                                                         # Signo de menos
        /(.?)(\/,)/,                                                                        # Espacio fino
        /(.?)(\/\+)/                                                                        # Espacio de no separación
    ]

    if html == true
        regex_html = [
            '&#38;',    # Símbolo «&»
            'img',      # Imagen
            'a',        # Enlace
            'strong',   # Negritas semántica
            'b',        # Negritas
            'em',       # Itálicas semántica
            'i',        # Itálicas
            's',        # Tachado
            'sub',      # Subíndice
            'sup',      # Superíndice
            'force_sc', # Versalitas
            'sc',       # Versalitas ligera
            'code',     # Código
            'span',     # Span personalizado
            '―',        # Barra
            '—',        # Raya
            '–',        # Signo de menos
            '&#8201;',  # Espacio fino
            '&#160;'    # Espacio de no separación
        ]

        regex = pair_regex(regex_raw, regex_html)

        # Añade un atributo a <img>, <a> o <span> si así fue especificado
        def add_attr text, min_rx, rx

            # Arregla el problema de los paréntesis dentro de URL que en unos casos van ahí y en otros afuera.
            text.scan(/(<.*?href="|<.*?src=")(.*?)(".*?>)(.*?)(<\/.*?>)/).each do |scan|
                if scan[1] =~ /^[^\(]+?\)/
                    text = text.gsub(scan.join(''), scan[0] + scan[1].gsub(/\).*/, '').gsub('`','%60').gsub('~','%7E').gsub('^','%5E').gsub('*','%2A').gsub('_','%5f').gsub('(','%28').gsub(')','%29') + scan[2] + scan[3] + scan[4] + scan[1].gsub(/^.*?(\).*)/, '\1'))
                else
                    text = text.gsub(scan.join(''), scan[0] + scan[1].gsub('`','%60').gsub('~','%7E').gsub('^','%5E').gsub('*','%2A').gsub('_','%5f').gsub('(','%28').gsub(')','%29') + scan[2] + scan[3] + scan[4])
                end
            end

            if text =~ rx
                text.scan(rx).each do |scan|
                    # Si es <img> o <a>
                    if min_rx != 'span'
                        attributes = attributes(get_classes_ids([scan[1]]))
                        tag = scan[0].split('<' + min_rx)[0] + '<' + min_rx + attributes + scan[0].split('<' + min_rx)[1]
                    else
                        attributes = attributes(get_classes_ids([scan[1].gsub(/>.*$/, '')]))
                        tag = scan[0] + attributes + scan[1].gsub(/{.*?}/, '')
                    end

                    text = text.gsub(scan.join(''), tag)
                end
            end

            return text
        end

        # Inicio de solución del conflicto entre notas personalizadas con asterisco y las itálicas: «ejemplo@note[*] *una itálica*»
        text.scan(/@note\[(\*+?)\]/).each do |scan|
            text = text.gsub('@note[' + scan[0] + ']', '@note[' + ('@@@' * scan[0].length) + ']')
        end

        regex.each do |rx|
            if text.scan(rx[0]).length > 0
                # Si no se está escapando la sintaxis
                if text.scan(rx[0])[0][0] != '\\'
                    # Empiezan las sustituciones según el tipo de sintaxis
                    if rx[1] == 'img'
                        text = add_attr(text.gsub(rx[0], '\1' + '<img src="' + '\6' + '" alt="' + '\3' + '"/>' + '\8'), rx[1], /(<img[^<]+?\/>)({.*?})/)
                        text = text.gsub(/(alt=".*?)@\w+(.*?")/, '\1\2')
                    elsif rx[1] == 'a'
                        text = add_attr(text.gsub(rx[0], '\1' + '<a href="' + '\6' + '">' + '\3' + '</a>' + '\8'), rx[1], /(<a[^<]+?>[^<]+?<\/a>)({.*?})/)
                    elsif rx[1] == 'i'
                        text = text.gsub(rx[0], '\1' + '\2' + '<' + rx[1] + '>' + '\4' + '</' + rx[1] + '>')
                    elsif rx[1] == 'code'
                        text = text.gsub(rx[0], '\1' + '<code>' + '\3' + '</code>')

                        # El contenido del código requiere muchas modificaciones para evitar conflicto con otros estilos en línea e incluso con la misma estructura HTML
                        text.scan(/<code>(.+?)<\/code>/).each do |scan|
                            text = text.gsub('<code>' + scan.join('') + '</code>', '<code>' + scan.map{ |s| s.gsub(/<.?strong>/, '*').gsub(/<.?b>/, '__').gsub(/<.?em>/, '*').gsub(/<.?i>/, '_').gsub(/<span class="smallcap">(.*?)<\/span>/, '+++' + '\1' + '+++').gsub(/<span class="smallcap-light">(.*?)<\/span>/, '++' + '\1' + '++').gsub('<', '&lt;').gsub('>', '&gt;').gsub('----', '&#45;&#45;&#45;&#45;').gsub('---', '&#45;&#45;&#45;').gsub('--', '&#45;&#45;') }.join('') + '</code>')
                        end
                    elsif rx[1] == 'force_sc'
                        text = text.gsub(rx[0], '\1' + '<span class="smallcap">' + '\3' + '</span>')
                    elsif rx[1] == 'sc'
                        text = text.gsub(rx[0], '\1' + '<span class="smallcap-light">' + '\3' + '</span>')
                    elsif rx[1] == 'span'
                        text = add_attr(text.gsub(rx[0], '\1' + '<span' + '\5' + '>' + '\3' + '</span>'), rx[1], /(<span)({[^<]*?<\/span>)/)
                    # Sustituciones directas
                    elsif rx[1] == '―' || rx[1] == '—' || rx[1] == '–' || rx[1] == '&#8201;' || rx[1] == '&#160;' || rx[1] == '&#38;'
                        if rx[1] == '–'
                            text.scan(/(--)([\w|\s]+)/).each do |s|
                                if s[1] != 'note' && s[1] != 'ignore'
                                    text = text.gsub(s[0] + s[1], rx[1] + s[1])
                                end
                            end
                        elsif rx[1] == '&#38;'
                            text.scan(/&\S*\s*/).each do |s|
                                if s !~ /&\S+;/
                                    if s !~ /&$/
                                        text = text.gsub(s, s.gsub('&', '&#38;'))
                                    else
                                        text = text.gsub(/&$/, '&#38;') 
                                    end
                                end
                            end
                        else
                            text = text.gsub(rx[0], '\1' + rx[1])
                        end
                    # Todo lo demás es sustitución «plana» a los tags HTML
                    else
                        text = text.gsub(rx[0], '\1' + '<' + rx[1] + '>' + '\3' + '</' + rx[1] + '>')
                    end
                # Quita la diagonal inversa del escape
                else
                    new_rx = rx[0].to_s.gsub('(?-mix:(.?)', '').gsub('\\(', '#').gsub('\\)', '%').gsub('(', '').gsub(')', '').gsub('#', '\\(').gsub('%', '\\)')
                    text = text.gsub(/\\(#{new_rx})/, '\1')
                end
            end
        end

        text = text.gsub('%60','`').gsub('%7E','~').gsub('%5E','^').gsub('%2A','*').gsub('%28','(').gsub('%29',')').gsub('%5f','_').gsub('%2B','+').gsub('%5C','\\').gsub('%7C','|').gsub('%5B','[').gsub('%5D',']').gsub('%7B','{').gsub('%7D','}')

        # Fin de solución del conflicto entre notas personalizadas con asterisco y las itálicas: «ejemplo@note[*] *una itálica*»
        text.scan(/@note\[(@{3}+?)\]/).each do |scan|
            text = text.gsub('@note[' + scan[0] + ']', '@note[' + ('*' * (scan[0].length / 3)) + ']')
        end

        # Regresa con la simplificación de \\ por \
        return text.gsub('\\\\', '\\')
    end
end

# Obtiene los bloques de un Markdown
def get_blocks ruta, md
    raw = []
    list = false

    # Obtiene la información cruda
	archivo = File.open(ruta, 'r:UTF-8')
	archivo.each do |linea|
        raw.push(linea.gsub(/\s+$/, ''))
	end
	archivo.close

    # Obtiene los bloques
    tmp = []
    pre = false
    raw.each_with_index do |linea, i|
        if linea.strip == '' && tmp.length > 0 && pre == false
            md.push(tmp)
            tmp = []
        else
            if linea.strip.length > 0
                if linea =~ /```/
                    pre = !pre
                end
                tmp.push(linea)
            else
                if pre == true
                    tmp.push(linea)
                end
            end
        end

        if i == raw.length - 1 && linea.strip != ''
            md.push(tmp)
        end
    end

    return md
end

# Obtiene las clases o identificadores de un bloque de Markdown
def get_classes_ids array, space = false
    # Solo si encuentra las llaves al final del bloque
    if array.last =~ /\s*{[^{]*?}\s*$/
        elements = array.last.gsub(/.*{(.*?)}\s*/, '\1').split(/\s+/)
        classes = []
        ids = []

        # Separa entre classes e identificadores y les quita el punto o el gato
        elements.each do |e|
            if e[0] == '.'
                classes.push(e[1..-1])
            elsif e[0] == '#'
                ids.push(e[1..-1])
            end
        end

        # Regresa nulo si no se encontraron classes o ids
        if classes.length == 0 && ids.length == 0
            return nil
        end

        # Si todo salió bien, regresa un objeto con las llaves «class» e «id».
        return {'class' => classes, 'id' => ids[0]}
    end

    return nil
end

# Obtiene el caracter desde unicode; viene de: https://gist.github.com/O-I/6758583
def obtener_caracter hexnum
    char = ''
    char << hexnum.to_i(16)
end

# Obtiene el unicode de un caracter; viene de: https://gist.github.com/O-I/6758583
def obtener_unicode char
    (0..55295).each do |pos|
        chr = ""
        chr << pos
        if chr == char
            puts "This is the unicode of #{char}: #{pos.to_s(16)}"
        end
    end
end

# Obtiene la ruta relativo a un archivo
def get_relative_path pwd, file_location

    if file_location == nil
       return '' 
    end

    file_location_array = file_location.split('/')
    pwd_array = pwd.split('/')
    relative_path = []

    # Inicia una comparación de fichero por fichero
    file_location_array.each_with_index do |e, i|
        if File.file?(e)
            relative_path.push(e)
        else
            # Cuando ya no hay coincidencia empieza la ruta
            if e != pwd_array[i]
                # Si aún quedan ficheros desde la ubicación actual, son reemplazados por «..»
                if pwd_array[i] != nil
                    pwd_array[i..-1].each {|j| relative_path.push('..')}
                    pwd_array = []
                end

                relative_path.push(e)
            end
        end
    end

    # Regresa la ruta relativa
    return relative_path.join('/')
end
