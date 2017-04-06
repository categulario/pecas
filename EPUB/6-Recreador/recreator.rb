#!/usr/bin/env ruby
# encoding: UTF-8
# coding: UTF-8

Encoding.default_internal = Encoding::UTF_8

require 'fileutils'
require 'yaml'
require 'active_support/inflector'
require 'securerandom'

# Funciones y módulos comunes a todas las herramientas
require File.dirname(__FILE__) + "/../../otros/secundarios/general.rb"
require File.dirname(__FILE__) + "/../../otros/secundarios/lang.rb"
require File.dirname(__FILE__) + "/../../otros/secundarios/xhtml-template.rb"

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
			return linea.gsub(/<.*?>/, "").strip
		end
	end
	return nil
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
def incluir? conjunto, yaml, nombre, lugar, ncx = nil, archivoBase = nil, i = nil
	# Itera el conjunto para analizar cada uno de los archivos
	conjunto.each do |archivo|
		# Solo si es un archivo XHTML
		if File.extname(archivo) == ".xhtml"
			mostrar = true
			
			# Si el nombre del archivo se encuentra en la propiedad de no mostrar
			if yaml[nombre].kind_of?(Array)
				yaml[nombre].each do |p|
					if p.split(".")[0] == File.basename(archivo).split(".")[0]
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
				
				# Aumenta el índice si existe
				if i != nil
					i += 1
				end
			end
		end
	end
end

# Crea las tablas de contenidos personalizados
def iterarHash yaml, archivoOtros, lista, array, archivoBase, tipo, nivel, espacio
	
	# Examina si los archivos existen
	def aplicar? archivoOtros, archivo
		# Si existe regresa un verdadero
		archivoOtros.each do |a|
			if File.basename(a.split(".")[0]) == archivo
				return a
			end
		end
		
		# Si no encontró nada, regresa un falso
		return false
	end
	
	# Iteración para crear la estructura
	array.each do |key, value|
		nombre = key.split(".")[0].to_s
		
		# Solo si el archivo existe
		if aplicar? archivoOtros, nombre
		
			# Obtiene ruta y título
			ruta = aplicar? archivoOtros, nombre
			titulo = extraerTitulo ruta
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

# Argumentos
carpeta = if argumento "-d", carpeta != nil then argumento "-d", carpeta else Dir.pwd + "/#{$l_cr_epub_nombre}" end
yaml = if argumento "-y", yaml != nil then argumento "-y", yaml else $l_g_meta_data end
argumento "-v", $l_re_v
argumento "-h", $l_re_h

# Variables que se usarán
carpetasPrincipales = Array.new
archivoOtros = Array.new
carpetaContenido = ""
archivoOpf = ""
archivoNcx = ""
archivoNav = ""
archivoPor = ""
uuid = ""

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
	if yaml["px-width"] != nil
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

# Crea el uuid
uuid = ActiveSupport::Inflector.transliterate(yaml["title"]).to_s.gsub(" ",".").downcase + "-v" + yaml["version"].to_s + "-" + SecureRandom.uuid

# Recrea el OPF
puts $l_re_recreando_opf

opf = File.open(archivoOpf, 'w:UTF-8')
opf.puts "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
opf.puts "<package xmlns=\"http://www.idpf.org/2007/opf\" xml:lang=\"#{$lang}\" unique-identifier=\"uuid\" prefix=\"ibooks: http://vocabulary.itunes.apple.com/rdf/ibooks/vocabulary-extensions-1.0/\" version=\"3.0\">"
opf.puts "    <metadata xmlns:dc=\"http://purl.org/dc/elements/1.1/\">"
opf.puts "        <dc:language>#{$lang}</dc:language>"

# Se agrega solo si se establecieron	
if yaml["title"] != nil
	opf.puts "        <dc:title>#{yaml["title"]}</dc:title>"
end
if yaml["author"] != nil
	opf.puts "        <dc:creator>#{yaml["author"]}</dc:creator>"
end
if yaml["publisher"] != nil
	opf.puts "        <dc:publisher>#{yaml["publisher"]}</dc:publisher>"
end
if yaml["synopsis"] != nil
	opf.puts "        <dc:description>#{yaml["synopsis"]}</dc:description>"
end
if yaml["category"] != nil
	opf.puts "        <dc:subject>#{yaml["category"]}</dc:subject>"
end

opf.puts "        <dc:identifier id=\"uuid\">#{uuid}</dc:identifier>"
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

# Agrega el resto de los archivos encontrados
archivoOtros.each do |archivo|
	propiedadesConjunto = Array.new
	propiedades = ""
	
	# Busca si hay scripts o imágenes svg en el archivo
	archivo_abierto = File.open(archivo, 'r:UTF-8')
	archivo_abierto.each do |linea|
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
	
	opf.puts "        <item href=\"#{archivo}\" id=\"#{id archivo}\" media-type=\"#{tipo archivo}#{propiedades}\" />"
end

opf.puts "    </manifest>"
opf.puts "    <spine toc=\"#{id archivoNcx}\">"

incluir? archivoOtros, yaml, "no-spine", opf

opf.puts "    </spine>"
opf.puts "</package>"
opf.close

# Recrea el NCX
puts $l_re_recreando_ncx

ncx = File.open(archivoNcx, 'w:UTF-8')
ncx.puts "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\" ?>"
ncx.puts "<ncx xmlns=\"http://www.daisy.org/z3986/2005/ncx/\" version=\"2005-1\" xml:lang=\"#{$lang}\">"
ncx.puts "    <head>"
ncx.puts "        <meta content=\"#{uuid}\" name=\"dtb:uuid\"/>"
ncx.puts "        <meta content=\"1\" name=\"dtb:depth\"/>"
ncx.puts "        <meta content=\"0\" name=\"dtb:totalPageCount\"/>"
ncx.puts "        <meta content=\"0\" name=\"dtb:maxPageNumber\"/>"
ncx.puts "    </head>"
ncx.puts "    <docTitle>"
ncx.puts "        <text>#{yaml["title"]}</text>"
ncx.puts "    </docTitle>"
ncx.puts "    <docAuthor>"
ncx.puts "        <text>#{yaml["author"]}</text>"
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
	incluir? archivoOtros, yaml, "no-toc", ncx, true, archivoNcx, 1
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
	incluir? archivoOtros, yaml, "no-toc", nav, false, archivoNav, 1
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
					puts $l_re_recreando_fluido
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

# Creación del EPUB
puts Dir.pwd

# Opción necesaria para Windows que es el zip.exe

#QUITAR
abort


















# Si es EPUB fijo, se agregan esas propiedades, se lo contrario solo se agrega el «reflowable»
if $fijo.first != " "
    $fijo.each do |r|
        a = r.split("@").first
        z = r.split("@").last

        # No agrega como metadato la anchura y la altura
        if z != "w" && z != "h"
            metadatos.push('        <meta property="' + z + '">' + a + '</meta>')
        else
            # Si es la anchura, guarda la variable para utilizarse más adelante
            if z == "w"
                $width = a
            # Mismo caso pero para la altura
            else
                $height = a
            end
        end
    end
else
    metadatos.push('        <meta property="rendition:layout">reflowable</meta>')
end

metadatos.push('        <meta property="ibooks:specified-fonts">true</meta>')
metadatos.push('    </metadata>')

# Acomoda el identificador del ncx
identificadorNcx['.'] = '_'
identificadorNcx = 'id_' + identificadorNcx

# Recorre todos los archivos en busca de los recursos para el manifiesto y la espina
Dir.glob(carpeta + $divisor + '**' + $divisor + '*.*') do |archivoManifiesto|
    if File.extname(archivoManifiesto) != '.xml' and File.extname(archivoManifiesto) != '.opf'

        $archivoNombre = File.basename(archivoManifiesto)

        # Conserva los xhtml que tienen scripts o archivos svg
        $scriptXhtml = Array.new
        $svgXhtml = Array.new

        if File.extname(archivoManifiesto) == '.xhtml'

            # Ayuda a detectar scripts en en header
            etiquetaHeadFin = false

            archivoXhtml = File.open(archivoManifiesto, 'r:UTF-8')
            archivoXhtml.each do |linea|

                # Se indica cuando ya pasó el head
                if (linea =~ /(.*)<\/head>/ )
                    etiquetaHeadFin = true
                end

                # Si se encuentra una etiqueta de script andentro del head, entonces se considera que hay un script en el archivo
                if (linea =~ /<script(.*)/ )
                    if etiquetaHeadFin == false
                        $scriptXhtml.push($archivoNombre)
                    end
                end

                # Identifica si se encuentra una imagen svg
                if (linea =~ /<(.*?)img(.*?)src="(.*?).svg(.*?)"(.*?)\/>/ )
                    $svgXhtml.push($archivoNombre)
                end
            end
        end

        # Crea el identificador
        identificador = $archivoNombre
        identificador['.'] = '_'
        identificador = 'id_' + identificador

        # Añade el tipo de recurso
        tipo = Tipo File.extname(archivoManifiesto)

        # Inscruta propiedades
        def Propiedad (archivo, comparacion, propiedad)
            propiedadAdicion = ''

            if archivo == comparacion
                propiedadAdicion = ' properties="' + propiedad + '"'
            end

            return propiedadAdicion
        end

        # Añade propiedades
        propiedad = Propiedad $archivoNombre, $portada.gsub(".", "_"), 'cover-image'
        propiedad2 = Propiedad $archivoNombre, $nav.gsub(".", "_"), 'nav'

        # Si encuentra una propiedad, se cambia el valor a verdadero; de lo contrario es falso
        def propiedadBuscar conjunto
            conjunto.each do |a|
                if $archivoNombre == a
                    return true
                    break
                end
            end

            return false
        end

        # Revisa si entre los archivos que tienen javascript o svg, el actual lo tiene
        script = propiedadBuscar $scriptXhtml
        svg = propiedadBuscar $svgXhtml

        # Si tiene ambas propiedades
        if script && svg
            propiedad3 = Propiedad $archivoNombre, $archivoNombre, 'scripted svg'
        # Si tiene alguna de las propiedades
        elsif script || svg
            if script
                propiedad3 = Propiedad $archivoNombre, $archivoNombre, 'scripted'
            else
                propiedad3 = Propiedad $archivoNombre, $archivoNombre, 'svg'
            end
        end

        # Determina si se le pone un atributo no lienal al XHTML
        def NoLinealCotejo (identificador)
            retorno = ""
            $archivosNoLineales.each do |comparar|
                comparador = "id_" + comparar + "_xhtml"
                if comparador == identificador
                    retorno = ' linear="no"'
                    break
                end
            end
            return retorno
        end

        # Añade la propiedad no lineal, si la hay
        noLineal = NoLinealCotejo identificador

        # Agrega los elementos al manifiesto
        manifiesto.push('        <item href="' + rutaRelativa[indice] + '" id="' + identificador + '" media-type="' + tipo.to_s + '"' + propiedad.to_s + propiedad2.to_s + propiedad3.to_s + ' />')

        # Agrega los elementos a la espina
        if (File.extname(archivoManifiesto) == '.xhtml' || File.extname(archivoManifiesto) == '.html') and $archivoNombre != $nav.gsub(".", "_")
            espina.push ('        <itemref idref="' + identificador + '"' + noLineal.to_s + '/>')
        end

        # Permite recurrir a la ruta relativa
        indice += 1
    end
end

# Acomoda los elementos alfabéticamente
manifiesto = manifiesto.sort
espina = espina.sort

# Para el inicio del manifiesto y de la espina
manifiesto.insert(0, '    <manifest>')
espina.insert(0, '    <spine toc="' + identificadorNcx + '">')

# Para el fin del manifiesto y de la espina
manifiesto.push('    </manifest>')
espina.push('    </spine>')

Dir.glob(carpeta + $divisor + '**' + $divisor + '*.*') do |archivo|
    if File.extname(archivo) == '.opf'
        # Inicia la recreación del opf
        puts "\nRecreando el ".magenta.bold + File.basename(archivo).magenta.bold + "...".magenta.bold

        # Abre el opf
        opf = File.open(archivo, 'w:UTF-8')

        # Añade los primeros elementos necesarios
        opf.puts '<?xml version="1.0" encoding="UTF-8"?>'
        opf.puts '<package xmlns="http://www.idpf.org/2007/opf" xml:lang="' + $lang + '" unique-identifier="uuid" prefix="ibooks: http://vocabulary.itunes.apple.com/rdf/ibooks/vocabulary-extensions-1.0/" version="3.0">'

        # Añade los metadatos
        metadatos.each do |lineaMetadatos|
            opf.puts lineaMetadatos
        end

        # Añade el manifiesto
        manifiesto.each do |lineaManifiesto|
            opf.puts lineaManifiesto
        end

        # Añade la espina
        espina.each do |lineaEspina|
            opf.puts lineaEspina
        end

        # Añade el último elemento necesario
        opf.puts '</package>'

        # Cierra el opf
        opf.close
    end
end

# Para empezar a recrear el ncx y el nav
$archivosTocs = Array.new
$coletillaXhtml = ''
$coletillaNav = ''
$coletillaNcx = ''

# Para sacar el nivel en que se encuentran
rutaRelativa.each do |coletillaObtencion|
    if File.extname(coletillaObtencion) == '.xhtml'
        if File.basename(coletillaObtencion) != $nav
            $coletillaXhtml = coletillaObtencion.split($divisor)
        else
            $coletillaNav = coletillaObtencion.split($divisor)
        end
    else
        if File.extname(coletillaObtencion) == '.ncx'
            $coletillaNcx = coletillaObtencion.split($divisor)
        end
    end
end

# A partir de la cantidad de nieveles contenidos, se recrean las coletillas de los archivos
def CreadorColetillas (coletilla)
    coletillaFinal = ''

    # La coletilla queda vacía suponiendo que solo exista un nivel
    if coletilla.length > 1

        # Se itera si exista más de un nivel
        coletilla.each do |coletillas|

            # Se ignora el último nivel porque es el nombre del archivo
            if coletillas != coletilla[-1]

                # Si se trata de la coletilla de los XHTML se ponen los nombres correspondientes a los niveles superiores
                if coletilla == $coletillaXhtml
                    coletillaFinal += coletillas.to_s + $divisor
                # Si se trata del ncx o el nav cada nivel superior es igual a dos puntos suspensivos
                else
                    coletillaFinal += '..' + $divisor
                end
            end
        end
    end

    # Regresa el valor obtenido
    return coletillaFinal
end

# Saca las coletillas correspondientes
$coletillaNcx = CreadorColetillas $coletillaNcx
$coletillaNav = CreadorColetillas $coletillaNav
$coletillaXhtml = CreadorColetillas $coletillaXhtml

# Para sacar una ruta semejante a la rutaRelativa
$archivosNoLinealesCompleto = Array.new
$archivosNoTocCompleto = Array.new

# Añade los archivos para los tocs
rutaRelativa.each do |rr|
    if File.extname(rr) == '.xhtml' and File.basename(rr) != $nav
        $archivosTocs.push(rr)
    end
end

# Completa las rutas para poder comparar con los archivos que están en los tocs
def Completud (conjuntoIncompleto, conjuntoCompleto)
    conjuntoIncompleto.each do |elementoNM|
        if elementoNM != ' ' and elementoNM != ''
            conjuntoCompleto.push($coletillaXhtml + elementoNM + '.xhtml')
        end
    end
end

Completud $archivosNoLineales, $archivosNoLinealesCompleto
Completud $archivosNoToc, $archivosNoTocCompleto

# Ordena alfabéticamente
$archivosTocs = $archivosTocs.sort
$archivosXhtml = $archivosTocs

# Crea un solo conjunto de lo que no se ha de mostrar ordenado alfabéticamente
archivosNoMostrar = $archivosNoLinealesCompleto + $archivosNoTocCompleto
archivosNoMostrar = archivosNoMostrar.sort

# Elimina los elementos que no se tienen que mostrar
$archivosTocs = $archivosTocs.reject {|w| archivosNoMostrar.include? w}

# Obtiene cada una de las rutas absolutas de los xhtml
$rutaAbsolutaXhtml = Array.new

rutaAbsoluta.each do |elemento|
    if File.extname(elemento) == '.xhtml' and File.basename(elemento) != $nav
        $rutaAbsolutaXhtml.push(elemento)
    end
end

# Crea una relacion entre el nombre del archivo y su título
$nombreYtitulo = Array.new

# Para mostrar el anuncio solo una vez
viewportsAnuncio = true
viewportsAnuncio2 = true

$rutaAbsolutaXhtml.each do |i|

    # Si es diseño fijo, se añade el viewport
    if $fijo.first != " "
        enHead = true
        sinViewport = true
        lineas = Array.new

        # Guarda las líneas con la modificación
        a = File.open(i, 'r:UTF-8')
        a.each do |linea|
            # Si está en el head, y se encuentra un viewport, se indica
            if enHead
                if linea =~ /viewport/
                    # Hasta este punto se está seguro si se modificarán viewports o no, por ello se anuncia
                    if viewportsAnuncio2
                        puts "\nModificando viewports...".magenta.bold
                    end

                    # Evita la repetición del anuncio
                    viewportsAnuncio2 = false

                    linea = linea.gsub(/content=\"(.*?)\"/, 'content="width=' + $width + ', height=' + $height + '"')
                    sinViewport = false
                end
            end

            # Cuando se llega al fin y no hay viewport, se añade; también se señala el fin del head
            if (linea =~ /(.*)<\/head>/ )
                if sinViewport && $width != nil
                    # Hasta este punto se está seguro si se agregarán viewports o no, por ello se anuncia
                    if viewportsAnuncio
                        puts "\nAñadiendo viewports...".magenta.bold
                    end

                    # Evita la repetición del anuncio
                    viewportsAnuncio = false

                    lineas.push('        <meta name="viewport" content="width=' + $width + ', height=' + $height + '" />')
                end
                enHead = false
            end

            # Añade las líneas ya existentes del archivo
            lineas.push(linea)
        end

        # Rescribe el archivo con las lineas encontradas o añadidas del análisis anterior
        b = File.open(i, 'w:UTF-8')
        lineas.each do |l|
            b.puts l
        end
        b.close
    end

    archivoXhtml = File.open(i, 'r:UTF-8')
    archivoXhtml.each do |linea|

        # Examina si en alguna línea del texto existe la etiqueta <title>
        if (linea =~ /<title>(.*)/ )

            # Elimina los espacios al inciio y al final
            linea = linea.strip

            # Toma la parte que está adentro de la etiqueta
            linea = linea.split('<title>')[1]
            linea = linea.split('</title>')[0]

            # Crea un nuevo conjunto en donde se añaden el nombre del archivo y el título
            conjunto = Array.new
            conjunto.push(File.basename(i))
            conjunto.push(linea)

            # Añade este conjunto al conjunto que sirve como relación
            $nombreYtitulo.push(conjunto)
        end
    end
end

# Otorga el título de cada documento xhtml
def Titulo (elemento)
    titulo = ''
    $nombreYtitulo.sort
    $nombreYtitulo.each do |i|
        if i[0] == elemento
            titulo = i[1]
            break
        end
    end
    return titulo
end

# Para empezar a crear el ncx y el nav
$archivosNcx = Array.new
$archivosNav = Array.new

# Añade los primeros elementos de los tocs
$archivosNcx.push('<?xml version="1.0" encoding="UTF-8" standalone="no" ?>')
$archivosNcx.push('<ncx xmlns="http://www.daisy.org/z3986/2005/ncx/" version="2005-1" xml:lang="' + $lang + '">')
$archivosNcx.push('    <head>')
$archivosNcx.push('        <meta content="' + identificadorLibro + '" name="dtb:uuid"/>')
$archivosNcx.push('        <meta content="1" name="dtb:depth"/>')
$archivosNcx.push('        <meta content="0" name="dtb:totalPageCount"/>')
$archivosNcx.push('        <meta content="0" name="dtb:maxPageNumber"/>')
$archivosNcx.push('    </head>')
$archivosNcx.push('    <docTitle>')
$archivosNcx.push('        <text>' + $titulo + '</text>')
$archivosNcx.push('    </docTitle>')
$archivosNcx.push('    <docAuthor>')
$archivosNcx.push('        <text>' + $creador + '</text>')
$archivosNcx.push('    </docAuthor>')
$archivosNcx.push('    <navMap>')

$archivosNav.push(xhtmlTemplateHead $titulo)
$archivosNav.push('        <nav epub:type="toc">')
$archivosNav.push('            <ol>')

indice = 1

# Para recrear los tocs
$archivosTocs.each do |at|
    titulo = Titulo File.basename(at)
    $archivosNcx.push('        <navPoint id="navPoint-' + indice.to_s + '" playOrder="' + indice.to_s + '"><navLabel><text>' + titulo.to_s + '</text></navLabel><content src="' + $coletillaNcx + at.to_s + '"/></navPoint>')
    $archivosNav.push('                <li><a href="' + $coletillaNav + at.to_s + '">' + titulo.to_s + '</a></li>')
    indice += 1
end

# Añade los últimos elementos de los tocs y los elementos parciales del nav
$archivosNcx.push('    </navMap>')
$archivosNcx.push('</ncx>')

$archivosNav.push('            </ol>')
$archivosNav.push('        </nav>')

# Para obtener los números de páginas
$nombreYpaginas = Array.new

$rutaAbsolutaXhtml.each do |i|
    # Por defecto no hay páginas
    continuar = false

    # Sirve para poner los identificadores de las páginas
    conjunto = Array.new

    archivoXhtml = File.open(i, 'r:UTF-8')
    archivoXhtml.each do |linea|
        # Examina si en alguna línea del texto existe la etiqueta <title>
        if (linea =~ /epub:type="pagebreak"(.*)/ )

            # Se crea un conjunto que contendrá todas las páginas
            paginas = Array.new

            # Se utuliza un conjunto porque puede darse el caso de más de un elemento encontrado en una misla línea
            paginas = linea.scan(/epub:type="pagebreak"([^.]*?)id="([^.]*?)"/)

            paginas.each do |pagina|
                # cada una de las páginas tiene dos elementos, el id y el title, solo se queda con el title
                conjunto.push(pagina.last)
            end

            # Habilita el llenado de la relación
            continuar = true
        end
    end

    if continuar == true
        # Añade este conjunto al conjunto que sirve como relación
        conjuntoFinal = Array.new
        conjuntoFinal.push(File.basename(i))
        conjuntoFinal.push(conjunto)
        $nombreYpaginas.push(conjuntoFinal)
    end
end

# Pone la lista de cada una de las páginas
def Paginas (at)
    elemento = File.basename(at)
    $nombreYpaginas = $nombreYpaginas.sort
    $nombreYpaginas.each do |i|
        if i[0] == elemento
            i[1].each do |j|
                n = j.downcase.gsub(/[^0-9]/,'')
                $archivosNav.push('                <li><a href="' + $coletillaNav + at.to_s + '#' + j.to_s + '">' + n.to_s + '</a></li>')
            end
            break
        end
    end
end

# Si existen páginas, se agregan más elementos al nav
if $nombreYpaginas.length > 0
    $archivosNav.push('        <nav epub:type="page-list">')
    $archivosNav.push('            <ol epub:type="list">')

    $archivosXhtml.each do |at|
        Paginas at
    end

    $archivosNav.push('            </ol>')
    $archivosNav.push('        </nav>')
end

# Añade los últimos elementos del nav
$archivosNav.push($xhtmlTemplateFoot)

# Mete los cambios a los archivos actuales
def Recreador (comparativo, archivosToc)
    archivoCambio = ''
    archivoEncontrado = ''

    # Localiza el archivo que se pretende recrear
    Dir.glob(carpeta + $divisor + '**' + $divisor + '*.*') do |archivo|
        if comparativo == ".ncx"
            if File.extname(archivo) == comparativo
                archivoEncontrado = archivo
            end
        else
            if File.basename(archivo) == comparativo
                archivoEncontrado = archivo
            end
        end
    end

    # Inicia la recreación
    puts "\nRecreando el ".magenta.bold + File.basename(archivoEncontrado).magenta.bold + "...".magenta.bold

    # Abre el archivo
    archivoCambio = File.open(archivoEncontrado, 'w:UTF-8')

    # Añade los elementos
    archivosToc.each do |linea|
        archivoCambio.puts linea
    end

    # Cierra el archivo
    archivoCambio.close
end

Recreador '.ncx', $archivosNcx
Recreador $nav, $archivosNav

# Fin
mensajeFinal = "\nEl proceso ha terminado.".gray.bold

# Crea la ruta para el EPUB
rutaEPUB = "../#{ruta.last}.epub"

# Por defecto se usa el comando de las terminales UNIX
rm = rutaEPUB
zip = 'zip'

# Reajustes para Windows
if OS.windows?
    rutaEPUB = rutaEPUB.gsub('/', '\\')
    rutaPadre = rutaPadre.gsub('/', '\\')
    puts "\nArrastra el zip.exe".blue
    zip = $stdin.gets.chomp
end

espacio = ' '

# Elimina el EPUB previo
Dir.glob(carpeta + $divisor + '..' + $divisor + '**') do |archivo|
    if File.basename(archivo) == ruta.last + '.epub'
        espacio = ' nuevo '
        puts "\nEliminando EPUB previo...".magenta.bold
        FileUtils.rm_rf(rm)
    end
end

puts "\nCreando#{espacio}EPUB...".magenta.bold

# Crea el EPUB
system ("#{zip} #{$comillas}#{rutaEPUB}#{$comillas} -X mimetype")
system ("#{zip} #{$comillas}#{rutaEPUB}#{$comillas} -r #{carpetasPrincipales[-2]} #{carpetasPrincipales[-1]} -x \*.DS_Store \*._* #{$metadatoPreexistenteNombre}")

# Finaliza la creación
puts "\n#{ruta.last}.epub creado en: #{rutaPadre}".magenta.bold
puts mensajeFinal
