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
        if OS.linux? || OS.mac?
            if OS.linux?
                output = `file -i #{self}`.strip.split(': ')[1].split('; ')
            else
                output = `file -I #{self}`.strip.split(': ')[1].split('; ')
            end
            return [output[0], output[1].split('=')[1]]
        else
            $l_g_error_no_identificado
        end
    end
end

## FUNCIONES

# Obtiene el hash según un valor buscado como expresión regular; modificación de: https://stackoverflow.com/questions/8301566/find-key-value-pairs-deep-inside-a-hash-containing-an-arbitrary-number-of-nested
def nested_hash_value(obj, key, value)
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
    elementoFinal = elemento.gsub("file:","").gsub("%20"," ")

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

# Enmienda ciertos problemas con la línea de texto pasa su uso directo en el sistema
def arregloRutaTerminal elemento
	ruta = elemento
	
	if OS.windows?
		ruta = '"' + ruta + '"'
	else
		ruta = ruta.gsub(/\s/, "\\ ")
	end
	
	return ruta
end

# Obtiene el directorio donde se encuentra el archivo
def directorioPadre archivo
	directorio = ((arregloRuta File.absolute_path(archivo)).split("/"))[0..-2].join("/")
end

# Obtiene el directorio donde se encuentra el archivo para uso directo en el sistema
def directorioPadreTerminal archivo

	if OS.windows?
		directorio = (arregloRuta(archivo).split("/"))[0..-2].join("/")
		directorio = '"' + directorio + '"'
	else
		directorio = ((arregloRuta File.absolute_path(archivo)).split("/"))[0..-2].join("/")
		directorio = directorio.gsub(/\s/, "\\ ")
	end
	
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

# Obtiene la ruta al archivo CSS
def archivoCSSBusqueda archivoCSS, carpeta
	if archivoCSS != nil
		# Para sacar la ruta relativa al archivo CSS
		archivoConjuntoCSS = archivoCSS.split('/')
		separacionesConjuntoCarpeta = carpeta.split('/')

		# Ayuda a determinar el número de índice donde ambos conjutos difieren
		indice = 0
		archivoConjuntoCSS.each do |parte|
			if parte === separacionesConjuntoCarpeta[indice]
				indice += 1
			else
				break
			end
		end

		# Elimina los elementos similares según el índice obtenido
		archivoConjuntoCSS = archivoConjuntoCSS[indice..archivoConjuntoCSS.length - 1]
		separacionesConjuntoCarpeta = separacionesConjuntoCarpeta[indice..separacionesConjuntoCarpeta.length - 1]

		# Crea la ruta
		rutaCSS = ("..#{'/'}" * separacionesConjuntoCarpeta.length) + archivoConjuntoCSS.join('/')
	end
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
def transliterar texto
	
	# Elementos particulares a cambiar
	elementos1 = ["ñ","á","é","í","ó","ú","ü"]
	elementos2 = ["n","a","e","i","o","u","u"]
	
	# Pone el texto en bajas
	texto = texto.downcase
	
	# Limita el nombre a cinco palabras
	texto = texto.split(/\s+/)
	texto = texto[0..4].join("_")
	
	# Cambia los elementos particulares
	elementos1.each_with_index do |e,i|
		texto = texto.gsub(e,elementos2[i])
	end
	
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

# Analiza el EPUB para obtener un hash convertible a JSON
def epub_analisis epub

    epub_directorio = directorioPadre epub
    unzip = if OS.windows? then unzip = "#{File.dirname(__FILE__)+ '/../../src/alien/info-zip/unzip.exe'}" else unzip = "unzip" end
    todo = {}
    archivo_opf = nil

    # Obtiene las rutas absolutas a cada archivo HTML dentro del EPUB
    def html_urls urls, opf, path
        opf.each do |k,v|
            # Si ya se localizó el manifiesto
            if k =~ /manifest/
                # Iteración del contenido del manifiesto
                v['content'].each do |i|
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
    system ("#{unzip} -qq #{arregloRutaTerminal epub} -d #{epub_directorio}/#{$l_g_epub_analisis}")

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

    return todo
end

# Convierte el archivo en un hash
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

                    # Sustituye el contenido por el valor de «texto»
                    $conjunto_yaml = $conjunto_yaml.map.with_index { |e, j| i == j ? texto : e }
                # Si no es tag
                elsif l.strip !~ /^</ && l.gsub(/(\t*?)\S.*$/, '\1').length == nivel + 1
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
        return $conjunto_yaml.unshift("  deep: #{nivel - 1}\n  content:").reject{|l| l.empty?}
    end

    # Va de una línea de texto a un conjunto con espacios que jerarquizan el contenido
    def text_to_array_to_yaml texto
        conjunto_inicial = texto.gsub(/(<.*?>\s*)/, '\n\1\n').split('\n').reject{|l| l.empty?} # Produce un conjunto sin jerarquías
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
def hash_to_html hash
    tipo = if File.extname(hash['file'])[1..-1] == 'opf' || File.extname(hash['file'])[1..-1] == 'xml' || File.extname(hash['file'])[1..-1] == 'xhtml' || File.extname(hash['file'])[1..-1] == 'html' || File.extname(hash['file'])[1..-1] == 'htm' then tipo = File.extname(hash['file'])[1..-1] else tipo = nil end
    html = []

    # Comprobación porque la extensión y el nivel son necesarios
    if tipo == nil then puts $l_g_error_hash; abort end
    
    # Pasa el contenido del hash a HTML
    def contenido_a_html a, html

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
        a.each do |e|
            # Si es tag
            if e.kind_of?(Hash)
                e.each do |k,v|

                    # Inicio del tag, sea único o de apertura
                    html.push("<#{k[1..-1]}" + cierre(v))

                    # Si no es tag único
                    if v != nil && v['content'] != nil
                        # Nueva iteración para seguir yendo al fondo
                        contenido_a_html(v['content'], html)

                        # Añade el tag de cierre
                        html.push("</#{k[1..-1]}>" + espacio(v))
                    end

                end
            # Si es texto
            else
                html.push(e)
            end
        end
    end

    contenido_a_html(hash['content'], html)

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
end
