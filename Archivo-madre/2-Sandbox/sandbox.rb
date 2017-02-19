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

# Se va a la carpeta para crear los archivos
carpeta = directorioPadre archivo
Dir.chdir carpeta

# Para saber si es un MD
if File.extname(File.basename(archivo)) == ".md"
	md = true
end

# Variables que se necesitarán
contenido = Array.new
etiquetas = Array.new
atributos = Array.new
palabras = Array.new
cifras = Array.new

# Para el nombre del directorio y el clon del archivo
directorio = $l_sb_fichero + "_" + File.basename(archivo).gsub(".","-").gsub(/\s/, "-")
archivoNuevo = $l_sb_fichero + "_" + File.basename(archivo).gsub(/\s/, "-")

# Para realizar cambios
if cambio
	puts directorio, archivoNuevo
# Para iniciar el análisis
else	
	# Si no existe el directorio
	if !File.directory?(directorio)
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
	else
		puts "#{$l_sb_error_carpeta[0] + directorio + $l_sb_error_carpeta[1]}".red.bold
		abort
	end

	# Obtiene todas las etiquetas, atributos y palabras
	contenido.each do |linea|
	
		# Busca todas las etiquetas de apertura
		etiquetasYAtributos = linea.scan(/<[^\/].*?>/)
		etiquetasYAtributos.each do |e|
		
			# Agrega los atributos de manera «sucia»
			atributos.push(e)
			
			# Obtiene las etiquetas de manera «sucia»
			a = /^.(.*?)\s/.match(e).to_s[1..-2].to_s
			
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
						p = p.gsub(x, "")
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
	archivo_estadisticas = File.open("estadísticas.txt", "w")
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
