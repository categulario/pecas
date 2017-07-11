#!/usr/bin/env ruby
# encoding: UTF-8
# coding: UTF-8

Encoding.default_internal = Encoding::UTF_8

# Funciones y módulos comunes a todas las herramientas
require File.dirname(__FILE__) + "/../../otros/secundarios/general.rb"
require File.dirname(__FILE__) + "/../../otros/secundarios/lang.rb"
require File.dirname(__FILE__) + "/../../otros/secundarios/xhtml-template.rb"
require File.dirname(__FILE__) + "/../../otros/secundarios/xhtml-beautifier.rb"

# Argumentos
txt = if argumento "-f", txt != nil then argumento "-f", txt end
carpeta = if argumento "-d", carpeta != nil then argumento "-d", carpeta else Dir.pwd end
css = if argumento "-s", css != nil then argumento "-s", css end
reset = argumento "--reset", reset, 1
inner = argumento "--inner", inner, 1
argumento "-v", $l_no_v
argumento "-h", $l_no_h

# Comprueba que existan los argumentos necesarios
comprobacion [txt]

# Comprueba y adquiere el path absoluto de la carpeta para el EPUB
carpeta = comprobacionDirectorio carpeta

# Comprueba que el archivo tenga la extensión correcta
txt = comprobacionArchivo txt, [".md"]
css = comprobacionArchivo css, [".css"]

# Obtiene la ruta al archivo CSS
css = archivoCSSBusqueda css, carpeta

# Variables que se usarán
txtEsMD = if File.extname(txt) == ".md" then txtEsMD = true else txtEsMD = false end
texHay = false
htmlHay = false
archivos = Array.new
txtNotas = Array.new
txtConteo = 0
arcConteo = 0
md = nil

# Se va a la carpeta y busca los archivos para insertar las notas
Dir.chdir carpeta
Dir.glob(carpeta + '/*.*') do |archivo|
	if File.extname(archivo) == ".xhtml" || File.extname(archivo) == ".html" || File.extname(archivo) == ".htm" || File.extname(archivo) == ".xml" || File.extname(archivo) == ".tex"
		if File.extname(archivo) == ".tex"
			texHay = true
		else
			htmlHay = true
		end
		archivos.push(archivo)
	end
end
archivos = archivos.sort

# Si hay archivos mezclados
if texHay == true && htmlHay == true
	puts $l_no_error_f
	abort
end

# Convierte archivo MD
if txtEsMD
	# Se determina la ruta y nombre del archivo convertido
	txt_oculto = $l_no_oculto + if texHay then ".tex" else ".html" end

	# Se usa Pandog, que a su vez usa Pandoc
	system "ruby #{File.dirname(__FILE__)+ "/../../Archivo-madre/1-Pandog/pandog.rb"} -i #{arregloRutaTerminal txt} -o #{txt_oculto}"
	
	# Crea la ruta absoluta
	txt_oculto = directorioPadre(txt) + "/" + txt_oculto
		
	# Cuenta la cantidad de notas al pie en el archivo de texto y va preparando las notas
	archivo = File.open(txt_oculto, 'r:UTF-8')
	linea_tmp = Array.new
	archivo.each do |linea|
		linea = linea.strip
		if texHay
			if linea != ""
				linea_tmp.push(linea)
			else
				txtNotas.push(linea_tmp.join(" "))
				txtConteo = txtConteo + 1
				linea_tmp = []
			end
		else
			if linea =~ /^<p/
				# Cambia los br por el fin e inicio de un nuevo p
				if linea =~ /<\s*?br\s*/
					linea = linea.gsub(/<\s*?br.*?>/,"</p><p class=\"#{$l_no_nota_p2}\">")
				end
				txtNotas.push(linea)
				txtConteo = txtConteo + 1
			end
		end
	end
	archivo.close
	
	# Si es TeX, se tiene que añadir una línea más y un conteo más, sino nunca se añadirá la última nota
	if texHay
		txtNotas.push(linea_tmp.join(" "))
		txtConteo = txtConteo + 1
	end
	
	# Modifica los elementos innecesarios
	archivo = File.open(txt_oculto, 'w:UTF-8')
	archivo.puts txtNotas
	archivo.close
end

puts $l_no_comparando

# Cuenta la cantidad de notas al pie en los archivos
archivos.each do |archivo|
    archivo = File.open(archivo, 'r:UTF-8')
    archivo.each do |linea|
        palabras = linea.split
        palabras.each do |palabra|
            if palabra =~ /#{$l_g_note[0]}.*?#{$l_g_note[1]}/
                arcConteo = arcConteo + 1
            end
        end
    end
    archivo.close
end

# Aborta si no hay coincidencia en el conteo
if txtConteo != arcConteo
	puts $l_no_error_c[0].red.bold
	puts "  #{txtConteo.to_s + $l_no_error_c[1] + File.basename(txt) + $l_no_error_c[2]}".red.bold
	puts "  #{arcConteo.to_s + $l_no_error_c[3]}".red.bold
    abort
end

puts $l_no_anadiendo

# Añade las notas a los archivos
notaNum = 1
notaReal = 0
archivo_tmp_footer = Array.new
titulo = nil
archivos.each do |archivo|
	
	# Reinicia la numeración en cada archivo si así se deseo
	if reset
		notaNum = 1
	end
	
	# Determina la ruta según si estará en un archivo externo o no
	if inner
		href = "#c-"
		id_pre = "c-"
	else
		href = $l_no_archivo_notas + "#"
		id_pre = ""
	end
	
	# Para reconstruir el archivo
	archivo_tmp = Array.new
	primera_nota = true
	if inner
		archivo_tmp_footer = []
	end

	# Analiza por palabra para cambiar la nota
	notaHay = false
    archivo = File.open(archivo, 'r:UTF-8')
    archivo.each_with_index do |linea, i|
		if linea !~ /<\s*?\/\s*?body/ && linea !~ /<\s*?\/\s*?html/
			espacio = /(^\s*)/.match(linea).captures.first
		
			# Coloca un encabezado si se encuentra un h1, se resetea y va en un archivo externo
			if linea =~ /<\s*?h1/ && reset && !inner
				titulo = /<\s*?h1.*?>(.*?)<\s*?\/\s*?h1\s*?>/.match(linea).captures.first
			end
			
			# Pone la referencia a la nota si es necesario
			palabras_tmp = Array.new
			palabras = linea.split
			palabras.each do |palabra|    
				# Añade el título si es pertinente
				def adicion_titulo primera_nota, titulo, archivo_tmp_footer
					# Identifica si es la primera nota del archivo
					if primera_nota
						if titulo != nil then archivo_tmp_footer.push("<h2>#{titulo}</h2>") end
						return false
					end
				end
				
				# Si es una nota sencilla
				if palabra =~ /#{$l_g_note[0] + $l_g_note[1]}/
					# Indica que hay nota
					notaHay = true
					
					# Identifica si es la primera nota del archivo
					primera_nota = adicion_titulo primera_nota, titulo, archivo_tmp_footer
				
					if texHay
						if reset
							nota = "\\footnote[#{notaNum}]{#{txtNotas[notaReal]}}"
						else
							nota = "\\footnote{#{txtNotas[notaReal]}}"
						end
					else					
						nota = "<sup class=\"#{$l_no_nota_sup}\" id=\"n-#{notaReal + 1}\"><a href=\"#{href}n-#{notaReal + 1}\">[#{notaNum}]</a></sup>"
						nota_contenido = txtNotas[notaReal].gsub("<p>","")
						archivo_tmp_footer.push("<p class=\"#{$l_no_nota_p}\" id=\"#{id_pre}n-#{notaReal + 1}\"><a class=\"#{$l_no_nota_a}\" href=\"#{if !inner then File.basename(archivo) end}#n-#{notaReal + 1}\">[#{notaNum}]</a> #{nota_contenido}")
					end
					
					# Hace los cambios a la palabra
					palabra = palabra.gsub(/#{$l_g_note[0] + $l_g_note[1]}/, nota)
					
					# Suma un elemento
					notaNum = notaNum + 1
					notaReal = notaReal + 1
				# Si es una nota personalizada
				elsif palabra =~ /#{$l_g_note[0]}(.*?)#{$l_g_note[1]}/
					# Indica que hay nota
					notaHay = true
					
					# Identifica si es la primera nota del archivo
					primera_nota = adicion_titulo primera_nota, titulo, archivo_tmp_footer
					
					# Obtiene el contenido mediante un match que obtiene capturas de las cuales solo se usa la primera, quitándole los elementos innecesarios
					contenido = /#{$l_g_note[0]}(.*?)#{$l_g_note[1]}/.match(palabra).captures.first.gsub($l_g_marca_in_1,"").gsub($l_g_marca_in_2,"")
					
					if texHay
						nota = "\\let\\svthefootnote\\thefootnote\\let\\thefootnote\\relax\\textsuperscript{#{contenido}}\\footnote{\\textsuperscript{#{contenido}} #{txtNotas[notaReal]}}\\addtocounter{footnote}{-1}\\let\\thefootnote\\svthefootnote"
					else
						nota = "<sup class=\"#{$l_no_nota_sup}\" id=\"n-#{notaReal + 1}\"><a href=\"#{href}n-#{notaReal + 1}\">[#{contenido}]</a></sup>"
						nota_contenido = txtNotas[notaReal].gsub("<p>","")
						archivo_tmp_footer.push("<p class=\"#{$l_no_nota_p}\" id=\"#{id_pre}n-#{notaReal + 1}\"><a class=\"#{$l_no_nota_a}\" href=\"#{if !inner then File.basename(archivo) end}#n-#{notaReal + 1}\">[#{contenido}]</a> #{nota_contenido}")
					end
					
					# Hace los cambios a la palabra
					palabra = palabra.gsub(/#{$l_g_note[0]}.*?#{$l_g_note[1]}/, nota)
					
					# Suma un elemento
					notaReal = notaReal + 1
				end
				
				palabras_tmp.push(palabra)
			end
			
			# Añade la información al archivo temporal
			archivo_tmp.push(espacio + palabras_tmp.join(" "))
		end
    end
	archivo.close
    
    # Modifica los elementos innecesarios
	archivo = File.open(archivo, 'w:UTF-8')
	archivo.puts archivo_tmp
	if htmlHay && inner && notaHay
		archivo.puts "<hr class=\"#{$l_no_nota_hr}\" />"
		archivo.puts "<section epub:type=\"footnotes\">"
		archivo.puts archivo_tmp_footer
		archivo.puts "</section>"
	end
	archivo.puts "</body>"
	archivo.puts "</html>"
	archivo.close
	
	if htmlHay
		beautifier archivo
	end
end

# Si es sintaxis tipo HTML, se añade el contenido si va en un nuevo archivo
if htmlHay && !inner
	archivo = File.open($l_no_archivo_notas, 'w:UTF-8')
	archivo.puts xhtmlTemplateHead $l_no_archivo_notas_titulo, css
	archivo.puts "<section epub:type=\"footnotes\">"
	archivo.puts "<h1>#{$l_no_archivo_notas_titulo}</h1>"
	archivo.puts archivo_tmp_footer
	archivo.puts "</section>"
	archivo.puts $xhtmlTemplateFoot
	archivo.close
	
	beautifier archivo
end

# Elimina el archivo oculto que sirvió para las notas
File.delete(txt_oculto)

puts $l_g_fin
