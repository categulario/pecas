#!/usr/bin/env ruby
# encoding: UTF-8
# coding: UTF-8

Encoding.default_internal = Encoding::UTF_8

require 'fileutils'
require 'yaml'
require 'securerandom'

# Funciones y módulos comunes a todas las herramientas
require File.dirname(__FILE__) + "/../../src/common/general.rb"
require File.dirname(__FILE__) + "/../../src/common/lang.rb"
require File.dirname(__FILE__) + "/../../src/common/xhtml-template.rb"

# Determina si en la carpeta hay un EPUB
def carpetaBusqueda carpeta, carpetasPrincipales
    # Se parte del supuesto de que la carpeta no es para un EPUB
    epub = false

    # Si dentro de los directorios hay un mimetype, entonces se supone que hay archivos para un EPUB
    Dir.glob(carpeta + "/*") do |fichero|
        if File.basename(fichero) == "mimetype"
            epub = true
        else
            # Sirve para la creación del EPUB
            carpetasPrincipales.push(File.basename(fichero))
        end
    end

    # Ofrece un resultado
    if epub == false
        puts "#{$l_re_error_e[0] + carpeta + $l_re_error_e[1]}".red.bold
        abort
    end
end

# Comprueba que no quede una variable vacía
def noVacio nombre, archivo
	if archivo == ""
		puts "#{$l_re_error_a[0] + nombre + $l_re_error_a[1]}".red.bold
		abort
	end
end

# Obtiene la fecha de modificación
def fechaModificacion
	# Ajusta el tiempo para que siempre sean dos cifras
	def ajuste (numero)
		cantidad = ''
		if numero < 10
			cantidad = '0' + numero.to_s
		else
			cantidad = numero.to_s
		end
		return cantidad
	end

	# Obtiene el tiempo actual
	fecha = Time.new

	# Ajusta las cifras
	ano = ajuste fecha.year
	mes = ajuste fecha.month
	dia = ajuste fecha.day
	hora = ajuste fecha.hour
	minuto = ajuste fecha.min
	segundo = ajuste fecha.sec

	# Crea la fecha completa
	return  ano + '-' + mes + '-' + dia + 'T' + hora + ':' + minuto + ':' + segundo + 'Z'
end

# Identifica los tipos de recursos existentes en el opf según su tipo de extensión
def tipo (archivo)
	extension = File.extname(archivo)
    if extension == '.gif'
        return 'image/gif'
    elsif extension == '.jpg' or extension == '.jpeg'
        return 'image/jpeg'
    elsif extension == '.png'
        return 'image/png'
    elsif extension == '.svg'
        return 'image/svg+xml'
    elsif extension == '.xhtml' or extension == '.html'
        return 'application/xhtml+xml'
    elsif extension == '.ncx'
        return 'application/x-dtbncx+xml'
    elsif extension == '.ttf' || extension == '.otf'
        return 'application/vnd.ms-opentype'
    elsif extension == '.woff'
        return 'application/font-woff'
    elsif extension == '.smil'
        return 'application/smil+xml'
    elsif extension == '.pls'
        return 'application/pls+xml'
    elsif extension == '.mp3'
        return 'application/mpeg'
    elsif extension == '.mp4'
        return 'application/mp4'
	elsif extension == '.pdf'
        return 'application/pdf'
    elsif extension == '.css'
        return 'text/css'
    elsif extension == '.js'
        return 'text/javascript'
    end
end

# Obtiene el id a partir de la ruta del archivo
def id archivo
	return "id_" + File.basename(archivo).to_s.gsub(" ","").gsub(".","_")
end

# Obtiene el texto de la etiqueta <title>
def extraerTitulo archivo
	archivo_abierto = File.open(archivo, 'r:UTF-8')
	archivo_abierto.each do |linea|
		if linea =~ /\s+<.*?title.*?>/
			if linea.gsub(/<.*?>/, "").strip == ""
				return $l_g_sin_titulo
			else
				return linea.gsub(/<.*?>/, "").strip
			end
		end
	end
	return nil
	archivo_abierto.close
end

# Obtiene los encabezados
def extraerEncabezado depth, yaml

	# Primero obtiene y ordena alfabéticamente todos los documentos XHTML
	archivos = []
	Dir.glob(Dir.pwd + "/**/*.xhtml") do |archivo|
		archivos.push(archivo)
	end
	archivos = archivos.sort
	
	# Proporcionará contenido adicional para el área de custom
	yaml_adicional = []
	
	# Itinera cada uno de los archivos
	archivos.each do |archivo|
	
		# Para elementos primarios
		if File.basename(YAML.load_file(yaml)["navigation"]) != File.basename(archivo)
			yaml_adicional.push("  " + File.basename(archivo) + ":")
		end
		
		# Analiza el archivo
		archivo_abierto = File.open(archivo, 'r:UTF-8')
		archivo_abierto.each do |linea|
		
			# Si se encuentra una línea con encabezado
			if linea =~ /^\s+<\s*?h\d.*?>/
				h_num = linea.gsub(/^\s+/,"")[2..-1].to_i
				h_id = linea =~ /id="/ ? linea.gsub(/^\s+<\s*?h\d.*?id="/,"").gsub(/".*$/,"").gsub(".","@@").strip : ""
				
				# Se empieza a crear el YAML solo si la profundidad es menor o igual a la buscada
				if h_num <= depth
					# Para elementos secundarios
					if h_num > 1 && h_id != ""
						elemento = ("  " * h_num) + "--id(" + h_id + ")--:"
					end
				end
					
				# Se agrega al conjunto de encabezados
				if elemento != nil
					yaml_adicional.push(elemento)
				end
			end
		end
		archivo_abierto.close
	end
	
	# Servirá para controlar los contenidos que tendrá el YAML modificado
	ignorar = false
	yaml_nuevo = []

	# Se empieza a analizar el YAML
	archivo_abierto = File.open(yaml, 'r:UTF-8')
	archivo_abierto.each do |linea|
		# Si no se ignora se imprime la línea tal cual
		if !ignorar
			yaml_nuevo.push(linea)
			
			# Cuando se llega a custom se añade el contenido adicional y se ignora lo que estaba en custom
			if linea =~ /^custom/
				yaml_adicional.each do |l|
					yaml_nuevo.push(l)
				end
				
				ignorar = true
			end
		# Si se está ignorando se revierte hasta que termina todo el área de custom
		else
			if linea.strip == "" || linea =~ /^#/ || linea =~ /^\w/
				yaml_nuevo.push(linea)
				ignorar = false
			end
		end
	end
	archivo_abierto.close
	
	# Abre el archivo para meter los cambios
	archivo_abierto = File.open(yaml, 'w:UTF-8')
	archivo_abierto.puts yaml_nuevo
	archivo_abierto.close
end

# Busca los niveles de diferencia entre los archivos del toc y los XHTML
def niveles? archivo1, archivo2
	archivo1 = File.absolute_path(archivo1).split("/")[0..-2]
	archivo2 = File.absolute_path(archivo2).split("/")[0..-2]
	arriba = "../"
	final = 0
	i = 0
	
	# Iteración donde si no hay coincidencia empieza el conteo final de niveles
	while i < archivo1.length do
		if archivo1[i] != archivo2[i] then final +=1 end
		i += 1
	end
	
	# Regresa el valor multiplicado por la cantidad de niveles
	return arriba * final
end

# Agrega si no fue excluido
def incluir? conjunto, yaml, depth, nombre, lugar, ncx = nil, archivoBase = nil, i = nil

	# Para el orden en el NCX
	i = 1
	
	# Itera el conjunto para analizar cada uno de los archivos
	conjunto.each do |archivo|
		# Solo si es un archivo XHTML
		if File.extname(archivo) == ".xhtml"
			mostrar = true
			
			# Si el nombre del archivo se encuentra en la propiedad de no mostrar
			if yaml[nombre].kind_of?(Array)
				yaml[nombre].each do |p|
					# Si es pretende usar una expresión regular
					if p =~ /\/.*?\//
						# Se crea el elemento regex
						rgx = Regexp.new(p.gsub("/",""))
						
						# Se busca si existe coincidencia
						if rgx =~ File.basename(archivo).split(".")[0]
							mostrar = false
							break
						end
						
					# Si es literal, se busca si existe coincidencia
					elsif p.split(".")[0] == File.basename(archivo).split(".")[0]
						mostrar = false
						break
					end
				end
			end
			
			# Si se trata de la espina
			if nombre == "no-spine"
				# Agrega la propiedad si es que no se va a mostrar
				if mostrar then lineal = "" else lineal = "\" linear=\"no" end
				
				# Agrega la línea al documento
				lugar.puts "        <itemref idref=\"#{id archivo}#{lineal}\"/>"
			# Si se trata de las tablas de contenidos y el archivo es mostrable
			elsif nombre == "no-toc" && mostrar
				titulo = extraerTitulo archivo
				niveles = niveles? archivoBase, archivo
			
				# Si es el NCX
				if ncx
					lugar.puts "        <navPoint id=\"navPoint-#{i}\" playOrder=\"#{i}\"><navLabel><text>#{titulo}</text></navLabel><content src=\"#{niveles + archivo}\"/></navPoint>"
				# Si es el NAV
				else
					lugar.puts "                <li><a href=\"#{niveles + archivo}\">#{titulo}</a></li>"
				end
					
				i += 1
			end
		end
	end
end

# Crea las tablas de contenidos personalizados
def iterarHash yaml, archivoOtros, lista, array, archivoBase, tipo, nivel, espacio
	
	# Examina si los archivos existen
	def aplicar? archivoOtros, archivo, yaml
		
		# Si se trata de un identificador
		if archivo.strip =~ /--id\(/
			# Busca el identificador
			def id_buscar archivoOtros, nombre
				archivoOtros.each do |archivo|
					# Si se trata de un archivo XHTML y tiene el indentificador
					if File.extname(archivo) == ".xhtml"
						archivo_abierto = File.open(File.absolute_path(archivo), 'r:UTF-8')
						archivo_abierto.each do |linea|
							if linea =~ /id="#{nombre.gsub("@@",".")}"/
								ruta = (archivo + "#" + nombre.gsub("@@",".")).strip
								texto = linea.gsub(/<.*?>/,"").strip
								
								# Regresa la ruta del archivo donde se encuentra y el texto del encabezado
								return [ruta, texto]
							end
						end
						archivo_abierto.close
					end
				end
				
				return false
			end
		
			# Llama a la búsqueda del identificador
			return id_buscar archivoOtros, archivo.gsub(/^.*?--id\((.*?)\).*$/,'\1')
		# Si se trata de un archivo
		else
			archivoOtros.each do |a|
				# Primera comprobación: si el archivo existe
				if File.basename(a.split(".")[0]) == archivo
			
					# Segunda comprobación: si el archivo no se quiere en la tabla de contenidos
					if yaml["no-toc"] != nil
						yaml["no-toc"].each do |no_toc|
							if archivo =~ /#{File.basename(no_toc, ".*")}/
								return false
							end
						end
					end
					
					return [a, nil]
				end
			end
		end
		
		# Si no encontró nada, regresa un falso
		return false
	end
	
	# Iteración para crear la estructura
	array.each do |key, value|
		nombre = key.split(".")[0].to_s
		
		# Solo si el archivo existe
		if aplicar? archivoOtros, nombre, yaml
		
			resultado = aplicar? archivoOtros, nombre, yaml
			ruta = resultado[0]
			titulo = resultado[1] == nil ? extraerTitulo(ruta) : resultado[1]
			niveles = niveles? archivoBase, ruta
			
			# Si se trata de un Hash
			if value.kind_of?(Hash)
				# Si es el NCX
				if tipo == "ncx"
					lista.push("#{espacio}<navPoint id=\"navPoint-@\" playOrder=\"@\"><navLabel><text>#{titulo}</text></navLabel><content src=\"#{niveles + ruta}\"/>")
					iterarHash yaml, archivoOtros, lista, value, archivoBase, tipo, nivel + 1, espacio + "    "
					lista.push("#{espacio}</navPoint>")
				# Si es el NAV
				else
					lista.push("#{espacio}<li><a href=\"#{niveles + ruta}\">#{titulo}</a>")
					lista.push("#{espacio}    <ol>")
					iterarHash yaml, archivoOtros, lista, value, archivoBase, tipo, nivel + 1, espacio + "        "
					lista.push("#{espacio}    </ol>")
					lista.push("#{espacio}</li>")
				end
			# Si ya es solo texto
			else	
				# Si es el NCX
				if tipo == "ncx"
					lista.push("#{espacio}<navPoint id=\"navPoint-@\" playOrder=\"@\"><navLabel><text>#{titulo}</text></navLabel><content src=\"#{niveles + ruta}\"/></navPoint>")
				# Si es el NAV
				else
					lista.push("#{espacio}<li><a href=\"#{niveles + ruta}\">#{titulo}</a></li>")
				end
			end
		end
	end
end

# Inserta título, autor o editorial al XHTML
def insertar buscado, texto, archivo
	# Busca el archivo
	Dir.glob(Dir.pwd + "/*/*") do |a|
		# Si se encuentra el archivo
		if File.basename(a) == archivo

			# Conjunto que copiará todas las líneas
			lineas = Array.new

			# Abre el archivo para analizarlo
			archivo_abierto = File.open(a, 'r:UTF-8')
			archivo_abierto.each do |linea|

				# Si se encuentra el id buscado
				if linea =~ /id="#{buscado}"/
					# Obtiene el tag de apertura y la línea hasta donde debe de ir el contenido
					tag = /(\w.*?)\s/.match(linea.strip)
					mi_match = /(.*?)>.*?(.*?>$)/.match(linea)	
	
					# Agrega la línea con el nuevo texto
                    if texto != nil
    					lineas.push("#{mi_match.captures[0]}>#{texto}</#{tag.captures[0]}>")
                    end
				
				# Si no se encuentra el id buscado, simplemente copia la línea
				else
					lineas.push(linea)
				end
			end
			archivo_abierto.close

			# Abre el archivo para meter los cambios
			archivo_abierto = File.open(a, 'w:UTF-8')
			archivo_abierto.puts lineas
			archivo_abierto.close
		end
	end
end

# Agrega los metadatos de los contenidos del YAML
def agregarMeta archivo, elemento, tag, meta = false
    # Comprobación de que no es nulo
    if elemento != nil
        elemento.class == String ? conjunto = [elemento] : conjunto = elemento
        metas = []

        # Iteración para agregar la sintaxis correcta
        conjunto.each do |e|
            meta == true ? metas.push("        <meta property=\"#{tag}\">#{e}</meta>") : metas.push("        <#{tag}>#{e}</#{tag}>")
        end

        archivo.puts metas.join("\n")
    end
end

# Modifica el orden del nombre
def nombre_apellido author
	if author != nil
		autores = []
		
		# Itera cada autor para invertir el orden
		author.each do |autor|
			autor = autor.split(",")
			if autor.length > 1
				autores.push(autor[1].strip + " " + autor[0].strip)
			else
				autores.push(autor[0].strip)
			end
		end
		
		# Regresa como una línea de texto donde cada autor los separa un salto de línea
		return autores.join("<br />")
	else
		return ""
	end
end

def editores ed
    if ed != nil
        return ed.join(" / ")
    else
        return ""
    end
end

# Argumentos
carpeta = if argumento "-d", carpeta != nil then argumento "-d", carpeta else Dir.pwd + "/#{$l_cr_epub_nombre}" end
yaml = if argumento "-y", yaml != nil then argumento "-y", yaml else $l_g_meta_data end
zip = if argumento "-z", zip != nil then argumento "-z", zip else nil end
depth = if argumento "--depth", depth != nil then argumento "--depth", depth else nil end
win32 = argumento "-32", win32, 1
argumento "-v", $l_re_v
argumento "-h", $l_re_h

# Para Windows es necesaria la ruta a zip.exe
if OS.windows?
	if win32
		zip = "#{File.dirname(__FILE__)+ "/../../src/alien/info-zip/zip-x32.exe"}"
	else
		zip = "#{File.dirname(__FILE__)+ "/../../src/alien/info-zip/zip-x64.exe"}"
	end
else
	zip = "zip"
end

# Indaga si creará un menú personalizado a partir de la búsqueda de profundidad
if depth.to_i > 0
	extraerEncabezado depth.to_i, yaml
elsif depth != nil
	puts $l_re_advertencia_depth
end

# Variables que se usarán
carpetasPrincipales = Array.new
archivoOtros = Array.new
carpetaContenido = ""
archivoOpf = ""
archivoNcx = ""
archivoNav = ""
archivoPor = ""
uid = ""
uid_corto = ""

# Comprueba y adquiere el path absoluto de la carpeta para el EPUB
carpeta = comprobacionDirectorio carpeta

# Comprueba, adquiere el path absoluto del archivo YAML y obtiene su información
yaml = comprobacionArchivo yaml, [".yaml"]

begin
	yaml = YAML.load_file(yaml)
rescue
	puts "#{$l_re_error_y[0] + File.basename(yaml) + $l_re_error_y[1]}".red.bold
	abort
end

# Comprueba las medidas del EPUB fijo, si lo hay
if yaml["px-width"] != nil && yaml["px-height"] != nil	
	if yaml["px-width"].to_i == 0 || yaml["px-height"].to_i == 0
		puts $l_re_error_m
		abort
	else
		anchura = yaml["px-width"].to_i
		altura = yaml["px-height"].to_i
	end
# Si solo una medida fue introducida, lanza una advertencia
elsif yaml["px-width"] != nil || yaml["px-height"] != nil
	if yaml["px-width"] == nil
		puts "#{$l_re_advertencia_fijo[0] + "px-width" + $l_re_advertencia_fijo[1]}".yellow.bold
	else
		puts "#{$l_re_advertencia_fijo[0] + "px-height" + $l_re_advertencia_fijo[1]}".yellow.bold
	end
end

# Se va al directorio para el EPUB
Dir.chdir(carpeta)

# Obtiene la carpeta de los archivos del EPUB
carpetaBusqueda carpeta, carpetasPrincipales

# Obtiene los archivos OPF, NVX, NAV y el resto
carpetasPrincipales.each do |carpeta|
	# Si la carpeta tiene más de un archivo, quiere decir que es donde están todos los contenidos
	if Dir[carpeta+"/**/*"].length > 1
		carpetaContenido = carpeta
		
		# Se itera para analizar cada uno de los ficheros y obtiene la ruta de los archivos sin el nombre de la carpeta que los contiene
		Dir.glob(carpeta + "/**/*") do |fichero|
			if File.file?(fichero)
				if File.extname(fichero) == ".opf"
					archivoOpf = fichero.gsub(carpeta+"/","")
				elsif File.extname(fichero) == ".ncx"
					archivoNcx = fichero.gsub(carpeta+"/","")
				elsif File.basename(fichero) == yaml["navigation"]
					archivoNav = fichero.gsub(carpeta+"/","")
				elsif File.basename(fichero) == yaml["cover"]
					archivoPor = fichero.gsub(carpeta+"/","")
				else
					archivoOtros.push(fichero.gsub(carpeta+"/",""))
				end
			end
		end
	end
end

# Comprueba que no quede una variable vacía
noVacio "OPF", archivoOpf
noVacio "NCX", archivoNcx
noVacio "NAV", archivoNav

# Ordena el resto de los archivos
archivoOtros = archivoOtros.sort

# Se va a la carpeta con todos los contenidos
Dir.chdir(carpetaContenido)

# Crea el uid a partir del título
begin
	uid = yaml["version"].to_s.gsub(".","_") + "-" + SecureRandom.uuid.gsub("-","")
	uid_corto = uid.split("-")[1][0..7]
rescue
	puts $l_re_error_t
	abort
end

# Recrea el OPF
puts $l_re_recreando_opf

opf = File.open(archivoOpf, 'w:UTF-8')
opf.puts "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
opf.puts "<package xmlns=\"http://www.idpf.org/2007/opf\" xml:lang=\"#{$lang}\" unique-identifier=\"uid\" prefix=\"ibooks: http://vocabulary.itunes.apple.com/rdf/ibooks/vocabulary-extensions-1.0/\" version=\"3.0\">"
opf.puts "    <metadata xmlns:dc=\"http://purl.org/dc/elements/1.1/\">"
opf.puts "        <dc:language>#{$lang}</dc:language>"

# Se agrega solo si se establecieron	
agregarMeta opf, yaml["title"], "dc:title"
agregarMeta opf, yaml["author"], "dc:creator"
agregarMeta opf, yaml["publisher"], "dc:publisher"
agregarMeta opf, yaml["synopsis"], "dc:description"
agregarMeta opf, yaml["category"], "dc:subject"
opf.puts "        <dc:identifier id=\"uid\">#{uid}</dc:identifier>"
agregarMeta opf, yaml["summary"], "schema:accessibilitySummary", true
agregarMeta opf, yaml["mode"], "schema:accessMode", true
agregarMeta opf, yaml["mode-sufficient"], "schema:accessModeSufficient", true
agregarMeta opf, yaml["feature"], "schema:accessibilityFeature", true
agregarMeta opf, yaml["api"], "schema:accessibilityAPI", true
agregarMeta opf, yaml["control"], "schema:accessibilityControl", true
agregarMeta opf, yaml["hazard"], "schema:accessibilityHazard", true
opf.puts "        <meta property=\"dcterms:modified\">#{fechaModificacion}</meta>"

# Según si es un EPUB fijo o no
if yaml["px-width"] != nil && yaml["px-height"] != nil 
	opf.puts "        <meta property=\"rendition:layout\">pre-paginated</meta>"
	opf.puts "        <meta property=\"rendition:orientation\">portrait</meta>"
	opf.puts "        <meta property=\"rendition:spread\">none</meta>"
else 
	opf.puts "        <meta property=\"rendition:layout\">reflowable</meta>"
end

opf.puts "        <meta property=\"ibooks:specified-fonts\">true</meta>"
opf.puts "    </metadata>"
opf.puts "    <manifest>"
opf.puts "        <item href=\"#{archivoNcx}\" id=\"#{id archivoNcx}\" media-type=\"#{tipo archivoNcx}\" />"
opf.puts "        <item href=\"#{archivoNav}\" id=\"#{id archivoNav}\" media-type=\"#{tipo archivoNav}\" properties=\"nav\" />"	

# Se agrega solo si la portada se indicó y existe en el EPUB
if yaml["cover"] != nil && archivoPor != ""
	opf.puts "        <item href=\"#{archivoPor}\" id=\"#{id archivoPor}\" media-type=\"#{tipo archivoPor}\" properties=\"cover-image\" />"
end

# Para archivos externos, si los hay
externos = Array.new

# Agrega el resto de los archivos encontrados
archivoOtros.each do |archivo|
	propiedadesConjunto = Array.new
	propiedades = ""
	
	# Busca si hay scripts o imágenes svg en el archivo
	archivo_abierto = File.open(archivo, 'r:UTF-8')
	archivo_abierto.each do |linea|
		
		linea = codificacionValida? linea
		
		# Si se encuentra una etiqueta de script andentro del head, entonces se considera que hay un script en el archivo
		if (linea =~ /^\s+<script.*?>/ )
			propiedadesConjunto.push("scripted")
		end

		# Identifica si se encuentra una imagen svg
		if (linea =~ /<.*?img.*?src=".*?\.svg.*?".*?\/>/ )
			propiedadesConjunto.push("svg")
		end
	end
	archivo_abierto.close
	
	# Añade las propiedades si es que fueron encontradas
	if propiedadesConjunto.length > 0
		propiedades = "\" properties=\"" + propiedadesConjunto.to_s.gsub("[","").gsub("]","").gsub("\"","").gsub(",","")
	end
	
	# Para el caso particular de recursos externos; OJO: actualmente solo se han contemplado PDF
	if tipo(archivo) == "application/pdf"
		if yaml["fallback"].kind_of?(Hash)
			yaml["fallback"].each do |key, value|
				key = key.split(".")[0]
				value = value.split(".")[0]
				
				# Si conincide el nombre del archivo con el del YAML se agrega
				if key == File.basename(archivo).split(".")[0]
					externos.push(id archivo)
					opf.puts "        <item href=\"#{archivo}\" id=\"#{id archivo}\" media-type=\"#{tipo archivo}#{propiedades}\" fallback=\"id_#{value.gsub(".","_")}_xhtml\" />"
				end
			end
		end
	else
		opf.puts "        <item href=\"#{archivo}\" id=\"#{id archivo}\" media-type=\"#{tipo archivo}#{propiedades}\" />"
	end
end

opf.puts "    </manifest>"
opf.puts "    <spine toc=\"#{id archivoNcx}\">"

incluir? archivoOtros, yaml, depth, "no-spine", opf

# Agrega los archivos externos de manera oculta, si los hay
if externos.length > 0
	externos.each do |archivo|
		opf.puts "        <itemref idref=\"#{archivo}\" linear=\"no\"/>"
	end
end

opf.puts "    </spine>"
opf.puts "</package>"
opf.close

# Recrea el NCX
puts $l_re_recreando_ncx

ncx = File.open(archivoNcx, 'w:UTF-8')
ncx.puts "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\" ?>"
ncx.puts "<ncx xmlns=\"http://www.daisy.org/z3986/2005/ncx/\" version=\"2005-1\" xml:lang=\"#{$lang}\">"
ncx.puts "    <head>"
ncx.puts "        <meta content=\"#{uid}\" name=\"dtb:uid\"/>"
ncx.puts "        <meta content=\"1\" name=\"dtb:depth\"/>"
ncx.puts "        <meta content=\"0\" name=\"dtb:totalPageCount\"/>"
ncx.puts "        <meta content=\"0\" name=\"dtb:maxPageNumber\"/>"
ncx.puts "    </head>"
ncx.puts "    <docTitle>"
ncx.puts "        <text>#{yaml["title"]}</text>"
ncx.puts "    </docTitle>"
ncx.puts "    <docAuthor>"
if yaml["author"] != nil
	ncx.puts "        <text>#{yaml["author"].join("; ")}</text>"
else
	ncx.puts "        <text></text>"
end
ncx.puts "    </docAuthor>"
ncx.puts "    <navMap>"

# Si es personalizado
if yaml["custom"].kind_of?(Hash)
	lista = Array.new
	indice = 1
	
	# Llama a la creación de la estructura
	iterarHash yaml, archivoOtros, lista, yaml["custom"], archivoNcx, "ncx", 1, "        "
	
	# Iteración para agregar los número de índice e imprimirlo en el documento
	lista.each do |elemento|
		if elemento =~ /\s+<.*?@.*?>/
			elemento = elemento.gsub("@", indice.to_s)
			indice += 1
		end
		
		ncx.puts elemento
	end
# Si es estándar
else
	incluir? archivoOtros, yaml, depth, "no-toc", ncx, true, archivoNcx, 1
end

ncx.puts "    </navMap>"
ncx.puts "</ncx>"
ncx.close

# Recrea el NAV
puts $l_re_recreando_nav

nav = File.open(archivoNav, 'w:UTF-8')
nav.puts "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
nav.puts "<!DOCTYPE html>"
nav.puts "<html xmlns=\"http://www.w3.org/1999/xhtml\" xmlns:epub=\"http://www.idpf.org/2007/ops\" xml:lang=\"#{$lang}\" lang=\"#{$lang}\">"
nav.puts "    <head>"
nav.puts "        <meta charset=\"UTF-8\" />"
nav.puts "        <title>#{yaml["title"]}</title>"
nav.puts "    </head>"
nav.puts "    <body>"
nav.puts "        <nav epub:type=\"toc\">"
nav.puts "            <ol>"

# Si es personalizado
if yaml["custom"].kind_of?(Hash)
	lista = Array.new
	
	# Llama a la creación de la estructura
	iterarHash yaml, archivoOtros, lista, yaml["custom"], archivoNav, "nav", 1, "                "
	
	# Agrega la estructura
	nav.puts lista
# Si es estándar
else
	incluir? archivoOtros, yaml, depth, "no-toc", nav, false, archivoNav, 1
end

nav.puts "            </ol>"
nav.puts "        </nav>"
nav.puts "    </body>"
nav.puts "</html>"
nav.close

# Si es un EPUB fijo, agrega o cambio los metadatos de los archivos XHTML
if anchura && altura
	puts "#{$l_re_recreando_fijo[0] + anchura.to_s + "x" + altura.to_s + $l_re_recreando_fijo[1]}".green
	
	# Itera cada archivo
	archivoOtros.each do |archivo|
		if File.extname(archivo) == ".xhtml"
			archivoFinal = Array.new
			cambio = false
			
			# Abre para leer el archivo y extraer las líneas
			archivo_abierto = File.open(archivo, 'r:UTF-8')
			archivo_abierto.each do |linea|
				# Si encuentra un viewport, le cambia las medidas
				if linea =~ /^\s+<meta.*?viewport.*?>/
					archivoFinal.push(linea.gsub(/width=\d+/, "width=#{anchura}").gsub(/height=\d+/, "height=#{altura}"))
					cambio = true
				# Si no encontró un viewport al final del head, lo agrega
				elsif linea =~ /^\s+<.*?\/.*?head>/ && !cambio
					archivoFinal.push("        <meta name=\"viewport\" content=\"width=#{anchura}, height=#{altura}\" />")
					archivoFinal.push(linea)
				# Para los demás casos agrega la línea sin cambios
				else
					archivoFinal.push(linea)
				end
			end
			archivo_abierto.close
			
			# Abre para meter los cambios al archivo
			archivo_abierto = File.open(archivo, 'w:UTF-8')
			archivo_abierto.puts archivoFinal
			archivo_abierto.close
		end
	end
# Si es un EPUB fluido, elimina viewports que encuentre
else
	primera = true
	
	# Itera cada archivo
	archivoOtros.each do |archivo|
		if File.extname(archivo) == ".xhtml"
			archivoFinal = Array.new
			
			# Abre para leer el archivo y analizar las líneas
			archivo_abierto = File.open(archivo, 'r:UTF-8')
			archivo_abierto.each do |linea|
				# Agrega las líneas, excepto si es un viewport
				if linea !~ /^\s+<meta.*?viewport.*?>/
					archivoFinal.push(linea)
				elsif primera
					puts $l_re_eliminando_viewports
					primera = false
				end
			end
			archivo_abierto.close
			
			# Abre para meter los cambios al archivo
			archivo_abierto = File.open(archivo, 'w:UTF-8')
			archivo_abierto.puts archivoFinal
			archivo_abierto.close
		end
	end
end

# Inserta título y autor en la portadilla si se encuentran los id
insertar $l_g_id_title, yaml["title"], $l_re_recreando_portadilla
insertar $l_g_id_subtitle, yaml["subtitle"], $l_re_recreando_portadilla
insertar $l_g_id_author, nombre_apellido(yaml["author"]), $l_re_recreando_portadilla

# Inserta título, autor y editor en la legal si se encuentran los id
insertar $l_g_id_title, yaml["title"] != nil ? "<i>" + yaml["title"] + "</i>" : nil, $l_re_recreando_legal
insertar $l_g_id_author, yaml["author"] != nil ? $l_re_recreando_autoria + "<br/>" + nombre_apellido(yaml["author"]) : nil, $l_re_recreando_legal
insertar $l_g_id_publisher, editores(yaml["publisher"]), $l_re_recreando_legal

# Para la creación del EPUB
rutaEpub = "#{carpeta + "-" + uid_corto}.epub"
espacio = " "

# Elimina el EPUB previo si lo hay
Dir.glob(directorioPadre(carpeta) + "/*") do |archivo|
    if File.basename(archivo) == File.basename(rutaEpub)
        espacio = $l_re_nuevo
        puts $l_re_eliminando_epub 
        FileUtils.rm_rf("../../" + File.basename(archivo))
    end
end

# Va a la carpeta para iniciar la compresión
Dir.chdir(carpeta)

# Crea el EPUB
puts "#{$l_re_creando_epub[0] + espacio + $l_re_creando_epub[1] + carpeta + $l_re_creando_epub[2] + File.basename(rutaEpub) + $l_re_creando_epub[3]}".green
system ("#{zip} \"#{rutaEpub}\" -X mimetype -q")
system ("#{zip} \"#{rutaEpub}\" -r #{carpetasPrincipales[-2]} #{carpetasPrincipales[-1]} -x .* -q")

puts $l_g_fin
