#!/usr/bin/env ruby
# encoding: UTF-8
# coding: UTF-8

# Es para eliminar tildes y ñ en los nombres de los archivos
require 'active_support/inflector'

Encoding.default_internal = Encoding::UTF_8

# Funciones y módulos comunes a todas las herramientas
require File.dirname(__FILE__) + "/../../otros/secundarios/general.rb"
require File.dirname(__FILE__) + "/../../otros/secundarios/lang.rb"
require File.dirname(__FILE__) + "/../../otros/secundarios/xhtml-template.rb"
require File.dirname(__FILE__) + "/../../otros/secundarios/xhtml-beautifier.rb"

# Argumentos
archivo = argumento "-f", archivo
cambio = argumento "-c", cambio, 1
argumento "-v", $l_sb_v
argumento "-h", $l_sb_h

# Comprueba que existan los argumentos necesarios
comprobacion [archivo]

# Comprueba que el archivo tenga la extensión correcta
archivo = comprobacionArchivo archivo, [".html", ".xhtml", ".htm", ".xml"]
archivo = arregloRuta archivo

# Se va a la carpeta para crear los archivos
carpeta = directorioPadre archivo
Dir.chdir carpeta

# Variables que se necesitarán
contenido = Array.new
etiquetas = Array.new
atributos = Array.new
palabras = Array.new
cifras = Array.new
archivos = Array.new
mod = Hash.new { |hash, key| hash[key] = [] }	# Crea un hash cuyas llaves serán conjuntos; hash para modificaciones generales
modM = Hash.new { |hash, key| hash[key] = [] }	# Hash para modificaciones en las marcas principales
modMs = Hash.new { |hash, key| hash[key] = [] }	# Has para las modificaciones en las marcas secundarias

# Para el nombre del directorio y el clon del archivo
directorio = $l_sb_fichero + "_" + File.basename(archivo).gsub(".","-").gsub(/\s/, "-")
archivoNuevo = $l_sb_fichero + "_" + File.basename(archivo).gsub(/\s/, "-")

# Para realizar cambios
if cambio
	# Comprueba que exista un análisis
	if !File.directory?(directorio)
		puts "#{$l_sb_error_carpeta2[0] + directorio + $l_sb_error_carpeta2[1]}".red.bold
		abort
	else
		Dir.chdir directorio
		
		# Comprueba de que exista el archivo
		if !File.exists?(archivoNuevo)
			puts "#{$l_sb_error_archivo[0] + archivoNuevo + $l_sb_error_archivo[1] + directorio + $l_sb_error_archivo[2]}".red.bold
			abort
		end
		
		# Comprueba de que exista el directorio con los análisis
		if !File.directory?($l_sb_fichero_interior)
			puts "#{$l_sb_error_carpeta3[0] + $l_sb_fichero_interior + $l_sb_error_carpeta3[1] + directorio + $l_sb_error_carpeta3[2]}".red.bold
			abort
		else 
			# Obtiene los archivos de análisis, excepto las estadísticas
			Dir.chdir $l_sb_fichero_interior
			Dir.glob("*") do |archivo|
				if File.extname(archivo) == "." + $l_sb_txt_marcado.split(".")[1] && File.basename(archivo) != $l_sb_txt_estadisticas
					archivos.push(archivo)
				end
			end
			
			# Comprueba de que al menos exista un archivo de análisis
			if archivos.length == 0
				puts $l_sb_error_archivo2
				abort
			end
			
			# Regresa a la carpeta padre de los análisis
			Dir.chdir ".."
		end
	end
	
	# Estipula el tipo de modificación
	def modificacionTipo m, linea
		if linea =~ /#{$l_g_delete}/ || linea =~ /#{$l_g_note_content}/
			# Elimina la marca para solo tener el contenido
			lineaLimpia = linea.split($l_g_marca)[0].strip

			# Agrega la marca al hash según su tipo
			if linea =~ /#{$l_g_delete}/
				m["borrar"].push(lineaLimpia)
			elsif linea =~ /#{$l_g_note_content}/
				m["notaContenido"].push(lineaLimpia)
			end
		elsif linea =~ /#{$l_g_change[0]}/ || linea =~ /#{$l_g_note[0]}/
			# Separa el contenido de la marca
			lineaLimpia = linea.split($l_g_marca)
			linea0 = lineaLimpia[0].strip
			linea1 = lineaLimpia[1].split($l_g_marca_interior)[1].to_s[0..-2]
			lineaConjunto = [linea0, linea1]
			
			# Agrega la marca al hash según su tipo
			if linea =~ /#{$l_g_change[0]}/
				m["modificar"].push(lineaConjunto)
			elsif linea =~ /#{$l_g_note[0]}/
				m["nota"].push(lineaConjunto)
			end
		end
	end
	
	# Obtiene los elementos que se habrán de modificar
	def modificaciones mod, modM, modMs, archivoAnalisis
		# Abre el archivo con el análisis
		archivo_abierto = File.open($l_sb_fichero_interior + "/" + archivoAnalisis, "r:UTF-8")
		archivo_abierto.each do |linea|
			linea = linea.strip
			
			# Si se encuentra algún marcado, es que hay una modificación
			if linea =~ /#{$l_g_marca}/
				# Cualquier archivo excepto el que contiene las marcas
				if archivoAnalisis != $l_sb_txt_marcado
					modificacionTipo mod, linea
				# El archivo de marcas
				else
					# Si es una marca principal
					if linea =~ /^\w/
						modificacionTipo modM, linea
					# Si es una marca secundaria
					elsif linea =~ /^</
						modificacionTipo modMs, linea
					end
				end
			end
		end
		archivo_abierto.close
	end
	
	puts $l_sb_analizando
	
	archivos.each do |a|
		modificaciones mod, modM, modMs, a
	end
	
	puts $l_sb_realizando
	
	# Clona el archivo a modificar
	contenidoArchivo = Array.new
	archivo_abierto = File.open(archivoNuevo, "r")
	archivo_abierto.each do |linea|
		contenidoArchivo.push(linea.strip)
	end
	archivo_abierto.close
	contenidoArchivo = contenidoArchivo.join("ººº")
	
	# Realiza los cambios
	def cambios m, contenido, tipo = 0
		def reemplazarOborrar elemento, reemplazo, contenido, tipo
			
			# Indica lo que se está haciendo
			if reemplazo == ""
				puts $l_sb_eliminando[0] + elemento + $l_sb_eliminando[1]
			else
				puts $l_sb_reemplazando[0] + elemento + $l_sb_reemplazando[1] + reemplazo + $l_sb_reemplazando[2]
			end
			
			# Si es literal el cambio se hace directo
			if tipo == 0
				if elemento != nil
					contenido = contenido.gsub!(elemento, reemplazo)
				end
			# Si son expresiones regulares
			else
				elementoViejo = elemento
				
				# Se limpia el elemento
				elemento = elemento.gsub("<","").gsub(">","")
				
				# Según el tipo se establece su cierre
				if tipo == 1
					cierre = elemento
				else
					cierre = elemento.split(" ")[0]
				end
				
				# Si se encuentra que es una etiqueta sin cierre, este se hace nulo
				conjunto = ["area","base","br","col","command","embed","hr","img","input","link","meta","param","source"]
				conjunto.each do |e|
					if e == cierre
						cierre = nil
						break
					end
				end
				
				# Acorde a su cierre hace la captura
				if cierre
					capturas = contenido.scan(/<#{elemento}>.*?<.*?\/#{cierre}.*?>/)
				else
					capturas = contenido.scan(/<#{elemento}.*?>/)
				end
				
				# Obtiene las etiquetas de cierre para el reemplazo
				reemplazoCierre = Array.new
				reemplazoCierreT = reemplazo.gsub(">","").split("<")
				reemplazoCierreT.each do |e|
					if e.strip != ""
						e = e.split(/\s/)[0]
							reemplazoCierre.push("</" + e + ">")
					end
				end
				reemplazoCierre = reemplazoCierre.reverse
				reemplazoCierre = reemplazoCierre.join("")
				
				
				# Hace el reemplazo
				capturas.each do |captura|
					reemplazoFinal = reemplazo.to_s + captura.split("<")[1].split(">")[1].to_s + reemplazoCierre.to_s

					if cierre != nil
						contenido = contenido.gsub(/#{elemento}.*?#{cierre}.*?>/, reemplazoFinal)
					else
						contenido = contenido.gsub(/#{elementoViejo}/, reemplazoFinal)
					end
				end
			end
			
			return contenido
		end
		
		# Itera cada uno de los hash según su llave
		m.each do |llave, valor|
			
			# Itera cada elemento según su valor
			valor.each do |elemento|
				# Llama a las respectivas funciones
				if llave == "borrar"
					contenido = reemplazarOborrar elemento, "", contenido, tipo
				elsif llave == "modificar"
					contenido = reemplazarOborrar elemento[0], elemento[1], contenido, tipo
				elsif llave == "notaContenido"
					# FALTA
				elsif llave == "nota"						# Da un conjunto
					# FALTA
				end
			end
		end
		
		return contenido
	end

	contenidoFinal = cambios mod, contenidoArchivo
	#contenidoFinal = cambios modM, contenidoArchivo, 1		# FALTA
	contenidoFinal = cambios modMs, contenidoArchivo, 2
	
	# Vuelve a añadir los saltos
	contenidoFinal = contenidoFinal.split("ººº")

	# Agrega los cambios en un nuevo archivo oculto
	archivo_final = File.open(".#{archivoNuevo}", "w")
	archivo_final.puts contenidoFinal
	archivo_final.close
	beautifier archivo_final
	
	# Sustituye el archivo
	File.rename(".#{archivoNuevo}", archivoNuevo)
	
# Para iniciar el análisis
else	
	# Comprueba de que no exita un análisis
	if File.directory?(directorio)
		puts "#{$l_sb_error_carpeta[0] + directorio + $l_sb_error_carpeta[1]}".red.bold
		abort
	end
	
	# Creación y movimiento al directorio donde estarán los análisis
	Dir.mkdir directorio
	Dir.chdir directorio
		
	# Extracción del contenido del documento
	archivo_abierto = File.open(archivo, "r:UTF-8")
	archivo_abierto.each do |linea|
		contenido.push(linea.strip)
	end
	archivo_abierto.close
		
	puts "#{$l_sb_advertencia_archivo[0] + archivoNuevo + $l_sb_advertencia_archivo[1] + directorio + $l_sb_advertencia_archivo[2]}".gray
		
	# Crea el archivo clon
	archivo_clon = File.open(archivoNuevo, "w")
	archivo_clon.puts contenido
	archivo_clon.close
	beautifier archivo_clon
		
	# Creación y movimiento del directorio donde se guardará la analítica
	Dir.mkdir $l_sb_fichero_interior
	Dir.chdir $l_sb_fichero_interior

	# Obtiene todas las etiquetas, atributos y palabras
	contenido.each do |linea|
	
		# Busca todas las etiquetas de apertura
		etiquetasYAtributos = linea.scan(/<[^\/].*?>/)
		etiquetasYAtributos.each do |e|
		
			# Agrega los atributos de manera «sucia»
			atributos.push(e)
			
			# Limpia las etiquetas
			if e =~ /<\w+>/
				a = e[1..-2]
			else
				a = /^.(.*?)\s/.match(e).to_s[1..-2].to_s
			end
			
			# Solo se consideran las tienen contenido
			if a.strip != ""
				etiquetas.push(a)
			end
		end
		
		# Obtiene las palabras de manera «sucia»
		palabrasLinea = linea.gsub(/<.*?>/,"").split(/\s/)
								
		palabrasLinea.each do |p|
			c = p
			
			# Elimina los caracteres indeseados
			def limpiar e, p
				e.each do |s|
					s.each do |x|
						p = p.gsub(x, "").gsub(/\Wnote$/, "")
					end
				end
				return p
			end
			
			# Elimina caracteres que no son letras al inicio o al final de una palabra		
			escaneo = p.scan(/(^[^A-Za-zñÑçÇáéíóúäëïöüâêîôûàèìòùãẽĩõũÁÉÍÓÚÄËÏÖÜÂÊÎÔÛÀÈÌÒÙÃẼĨÕŨ]+|[^A-Za-zñÑçÇáéíóúäëïöüâêîôûàèìòùãẽĩõũÁÉÍÓÚÄËÏÖÜÂÊÎÔÛÀÈÌÒÙÃẼĨÕŨ]+$)/)
			p = limpiar escaneo, p

			# Palabras
			if p.strip != ""
				palabras.push(p.strip)
			# Para cifras se toma la palabra original y se limpia de la manera deseada
			else
				escaneo = c.scan(/(^[^A-Za-zñÑçÇáéíóúäëïöüâêîôûàèìòùãẽĩõũÁÉÍÓÚÄËÏÖÜÂÊÎÔÛÀÈÌÒÙÃẼĨÕŨ0-9]+|[^A-Za-zñÑçÇáéíóúäëïöüâêîôûàèìòùãẽĩõũÁÉÍÓÚÄËÏÖÜÂÊÎÔÛÀÈÌÒÙÃẼĨÕŨ0-9]+$)/)
				c = limpiar escaneo, c
				if c.strip != ""
					cifras.push(c.strip)
				end
			end
		end
	end
	
	# Acomoda alfabéticamente
	etiquetas = etiquetas.sort
	atributos = atributos.sort
	palabras = palabras.sort

	# Elimina repeticiones
	etiquetasU = etiquetas.uniq
	atributosU = atributos.uniq
	palabrasU = palabras.uniq
	
	# Crea una lista de etiquetas y sus atributos
	archivo_marcado = File.open($l_sb_txt_marcado, "w")
	etiquetasU.each do |e|
		# Agrega la etiqueta
		archivo_marcado.puts e
		
		# Agrega los atributos que corresponden a la etiqueta
		atributosU.each do |a|
			if a =~ /<#{e}\s/
				archivo_marcado.puts "    " + a
			end
		end
		
		# Agregaun divisor si no es el último elemento
		if e != etiquetasU.last
			archivo_marcado.puts $l_sb_divisor
		end
	end
	archivo_marcado.close
	
	# Crea una lista de cifras
	archivo_cifras = File.open($l_sb_txt_cifras, "w")
	archivo_cifras.puts cifras.uniq
	archivo_cifras.close
	
	# Crea una lista de palabras con uniones
	archivo_uniones = File.open($l_sb_txt_uniones, "w")
	palabrasU.each do |p|
		if p =~ /\w+?[^A-Za-zñÑçÇáéíóúäëïöüâêîôûàèìòùãẽĩõũÁÉÍÓÚÄËÏÖÜÂÊÎÔÛÀÈÌÒÙÃẼĨÕŨ]\w+?/
			archivo_uniones.puts p
		end
	end
	archivo_uniones.close
	
	# Obtiene las palabras limpias
	palabrasLimpias = Array.new
	palabras.each do |p|
		# Elimina caracteres indeseados
		p = p.gsub(/[^A-Za-zñÑçÇáéíóúäëïöüâêîôûàèìòùãẽĩõũÁÉÍÓÚÄËÏÖÜÂÊÎÔÛÀÈÌÒÙÃẼĨÕŨ]+/, "")
		
		# Manda la palabra
		palabrasLimpias.push(p)
	end
	palabrasLimpias = palabrasLimpias.sort
	
	# Obtiene las palabras limpias únicas
	palabrasLimpiasU = palabrasLimpias.uniq

	# Obtiene las palabras con versal inicial
	archivo_versales = File.open($l_sb_txt_versales, "w")
	palabrasLimpiasU.each do |p|
		if p =~ /^[A-ZÑÁÉÍÓÚÄËÏÖÜÂÊÎÔÛÀÈÌÒÙÃẼĨÕŨ]/
			archivo_versales.puts p
		end
	end
	archivo_versales.close
	
	# Crea el archivo de las estadísticas
	archivo_estadisticas = File.open($l_sb_txt_estadisticas, "w")
	archivo_estadisticas.puts $l_sb_e[0] + (palabrasLimpias.length + cifras.length).to_s
	archivo_estadisticas.puts ""
	archivo_estadisticas.puts $l_sb_e[1] + palabrasLimpias.length.to_s
	archivo_estadisticas.puts $l_sb_e[2] + palabrasLimpiasU.length.to_s
	archivo_estadisticas.puts $l_sb_e[3] + (palabrasLimpiasU.length.to_f / palabrasLimpias.length.to_f).to_s
	archivo_estadisticas.puts ""
	archivo_estadisticas.puts $l_sb_e[4] + cifras.length.to_s
	archivo_estadisticas.puts $l_sb_e[5] + cifras.uniq.length.to_s
	archivo_estadisticas.puts ""
	archivo_estadisticas.puts ""
	archivo_estadisticas.puts $l_sb_e[6] + atributos.length.to_s
	archivo_estadisticas.puts $l_sb_e[7] + atributosU.length.to_s
	archivo_estadisticas.puts $l_sb_e[8] + etiquetasU.length.to_s
	archivo_estadisticas.puts ""
	
	# Obtiene las estadísticas del marcado
	x = 0
	etiquetasU.each do |e|
		# Cantidad de etiquetas
		i = 0
		atributos.each do |a|
			if a =~ /<#{e}\s/
				i += 1
			end
		end
		
		# Cantidad de etiquetas únicas
		j = 0
		atributosU.each do |a|
			if a =~ /<#{e}\s/
				j += 1
			end
		end
		
		x += 1
		
		if i == 0
			etiquetas.each do |e2|
				if e == e2
					i += 1
					j = i/i
				end
			end
		end
		
		archivo_estadisticas.puts x.to_s + $l_sb_e[9] + e + $l_sb_e[10] + i.to_s + $l_sb_e[11] + j.to_s
	end
	
	# Obtiene las estadísticas de la frecuencia de palabras
	archivo_estadisticas.puts ""
	archivo_estadisticas.puts ""
	archivo_estadisticas.puts $l_sb_e[12]
	archivo_estadisticas.puts ""
	
	# Obtiene la frecuencia de cada palabra
	palabrasFrecuencia = Hash.new(0)
	palabrasLimpias.each do |i|
		palabrasFrecuencia[i]+=1
	end
	
	# Acomoda por la frecuencia de menor a mayor
	palabrasFrecuencia = palabrasFrecuencia.sort_by{|k,v| v}.reverse
	
	# Imprime la estadística de la frecuencia de las palabras
	x = 0
	palabrasFrecuencia.each do |pf|
		x += 1
		archivo_estadisticas.puts x.to_s + $l_sb_e[13] + pf[0] + $l_sb_e[14] + pf[1].to_s + $l_sb_e[15] + ((pf[1].to_f / palabrasLimpias.length.to_f) * 100).to_s
	end
	archivo_estadisticas.close
end

puts $l_g_fin
