#!/usr/bin/env ruby
# encoding: UTF-8
# coding: UTF-8

require 'fileutils'

Encoding.default_internal = Encoding::UTF_8

# Funciones y módulos comunes a todas las herramientas
require File.dirname(__FILE__) + "/../../otros/secundarios/general.rb"
require File.dirname(__FILE__) + "/../../otros/secundarios/lang.rb"
require File.dirname(__FILE__) + "/../../otros/secundarios/css-template.rb"
require File.dirname(__FILE__) + "/../../otros/secundarios/xhtml-template.rb"
require File.dirname(__FILE__) + "/../../otros/secundarios/xhtml-beautifier.rb"

## REQUIERE PANDOC

# Argumentos
entrada = argumento "-i", entrada
salida = argumento "-o", salida
argumento "-v", $l_pg_v
argumento "-h", $l_pg_h

# Comprueba que existan los argumentos necesarios
comprobacion [entrada, salida]

# Arregla rutas
entrada = comprobacionArchivo entrada, [".md", ".html", ".xhtml", ".htm", ".xml", ".odt", ".docx", ".tex"]
salida = arregloRuta salida
entrada_sis = arregloRutaTerminal entrada
salida_sis = arregloRutaTerminal salida

# Sirve para evitar borrara archivos incorrectos
$pandog_coletilla = "-pandog"

# Obtiene las extensiones de los archivos
ext_e = File.extname(entrada)
ext_s = File.extname(salida)

# Obliga a poner un nombre de extensión al archivo de salida
if ext_s == ""
	puts $l_pg_error_ext
	abort
end

# Permitirá la creación en un path especificado
if salida.split("/").length > 1
	salida = arregloRuta File.absolute_path(salida)
end

# Va al directorio donde se encuentra el documento a transformar
directorio = directorioPadre entrada
Dir.chdir(directorio)

# Inicia Pandoc
puts $l_pg_iniciando

# Cambios de MD a HTML
def mdAhtml s_path, s_nombre
	
	puts $l_pg_modificando
	
	s_nombre_final = s_nombre
	s_nombre_actual = File.basename(s_nombre, ".*") + $pandog_coletilla + ".html"
	
	# Va al directorio donde está el archivo de salida
	Dir.chdir(s_path)
	
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
		
		# Elimina todas las etiquetas HTML que quedaron y espacios de más
		linea = linea.gsub(/<[^>]*?div.*?>/, "").gsub(/^\s+$/, "").strip
		
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
end

# Cambios de HTML a MD
def htmlAmd s_path, s_nombre

	puts $l_pg_modificando

	# Va al directorio donde está el archivo de salida
	Dir.chdir(s_path)
	
	# Crea el nuevo archivo oculto donde se pondrán las modificaciones
	md_nuevo = File.open(".#{s_nombre}", "w")
	
	# Ayudará a detectar líneas vacías para evitar que haya de más
	linea_pasada = nil
	
	# Empiezaa leer línea por línea del archivo de salida
	archivo_abierto = File.open(s_nombre, "r")
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
	File.delete(s_nombre)
	File.rename(".#{s_nombre}", s_nombre)
end

# El plus a pandoc es en el tratamiento entre el MD y el HTML
if ext_e == ".md" && (ext_s == ".html" || ext_s == ".xhtml" || ext_s == ".htm" || ext_s == ".xml")
	begin
		# Por defecto crea un HTML sin cabeza
		`pandoc #{entrada_sis} -o #{directorioPadreTerminal salida_sis}/#{File.basename(salida_sis,'.*') + $pandog_coletilla + '.html'}`
		
		# Llama a las modificaciones
		mdAhtml directorioPadre(salida), File.basename(salida)
	rescue
		puts $l_pg_error_m
		abort
	end
elsif (ext_e == ".html" || ext_e == ".xhtml" || ext_e == ".htm" || ext_e == ".xml") && ext_s == ".md"
	begin
		entrada_html = nil
		
		# Si se trata de un XML, copia el archivo en un HTML oculto que se usará para Pandoc
		if ext_e == ".xml"
			entrada_html = "." + File.basename(entrada, ".*") + ".html"
			FileUtils.cp(entrada, entrada_html)
			entrada = directorioPadre(entrada) + "/" + entrada_html
		end

		# Hace que los encabezados estén con gatos
		`pandoc #{entrada_sis} --atx-headers -o #{salida_sis}`
		
		# Se elimina el HTML oculto de existir
		if entrada_html != nil
			File.delete(entrada_html)
		end
		
		# Llama a las modificaciones
		htmlAmd directorioPadre(salida), File.basename(salida)
	rescue
		puts $l_pg_error_m
		abort
	end
else
	`pandoc #{entrada_sis} -o #{salida_sis}`
end

puts $l_g_fin
