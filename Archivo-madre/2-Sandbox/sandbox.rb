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

# Para el nombre del directorio y el clon del archivo
directorio = $l_sb_fichero + "_" + File.basename(archivo).gsub(".","-").gsub(/\s/, "-")
archivoNuevo = $l_sb_fichero + "_" + File.basename(archivo).gsub(/\s/, "-")

# Para realizar cambios
if cambio

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
		palabrasLinea = linea.gsub(/<\/.*?sup.*?>/,"]^")
								.gsub(/<.*?sup.*?>/,"^[")
								.gsub(/<\/.*?sub.*?>/,"~")
								.gsub(/<.*?sub.*?>/,"~")
								.gsub(/<.*?>/,"").split(/\s/)
		palabrasLinea.each do |p|
			palabras.push(p)
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
	
	# Crea una lista de palabras con uniones
	archivo_uniones = File.open($l_sb_txt_uniones, "w")
	palabrasU.each do |p|
		if p =~ /\w+?[^A-Za-z0-9_ñÑáéíóúäëïöâêîôûàèìòùÁÉÍÓÚÄËÏÖÜÂÊÎÔÛÀÈÌÒÙ]\w+?/
			archivo_uniones.puts p
		end
	end
	archivo_uniones.close
	
	# Obtiene las palabras limpias
	palabrasLimpias = Array.new
	palabras.each do |p|
		# Elimina caracteres indeseados
		p = p.gsub(/[^\wA-Za-z0-9_ñÑáéíóúäëïöâêîôûàèìòùÁÉÍÓÚÄËÏÖÜÂÊÎÔÛÀÈÌÒÙ]+/, "")
		
		# Obtiene las palabras que empiezan con número y terminan con al menos dos letras
		nYp1 = /^([0-9]+)[A-Za-zñÑáéíóúäëïöâêîôûàèìòùÁÉÍÓÚÄËÏÖÜÂÊÎÔÛÀÈÌÒÙ]{2,}$/.match(p)
		nYp2 = /^[A-Za-zñÑáéíóúäëïöâêîôûàèìòùÁÉÍÓÚÄËÏÖÜÂÊÎÔÛÀÈÌÒÙ]{2,}([0-9]+)$/.match(p)
		
		# Elimina los números del match
		def eliminacionMatch m, p
			if m
				m.captures.each do |c|
					p = p.gsub(c, "")
				end
			end
			
			return p
		end
		
		p = eliminacionMatch nYp1, p
		p = eliminacionMatch nYp2, p
		
		# Manda la palabra
		palabrasLimpias.push(p)
	end
	palabrasLimpias = palabrasLimpias.sort
	
	# Obtiene las palabras limpias únicas
	palabrasLimpiasU = palabrasLimpias.uniq

	# Obtiene las palabras con versal inicial
	archivo_versales = File.open($l_sb_txt_versales, "w")
	palabrasLimpiasU.each do |p|
		if p =~ /^[A-ZÑÁÉÍÓÚÄËÏÖÜÂÊÎÔÛÀÈÌÒÙ]/
			archivo_versales.puts p
		end
	end
	archivo_versales.close
	
	# Crea el archivo de las estadísticas
	archivo_estadisticas = File.open("estadísticas.txt", "w")
	archivo_estadisticas.puts "Cantidad de palabras: " + palabrasLimpias.length.to_s
	archivo_estadisticas.puts "Cantidad de palabras únicas: " + palabrasLimpiasU.length.to_s
	archivo_estadisticas.puts "Índice de diversidad: " + (palabrasLimpiasU.length.to_f / palabrasLimpias.length.to_f).to_s
	archivo_estadisticas.puts ""
	archivo_estadisticas.puts ""
	archivo_estadisticas.puts "Cantidad de etiquetas: " + atributos.length.to_s
	archivo_estadisticas.puts "Cantidad de etiquetas únicas con atributos: " + atributosU.length.to_s
	archivo_estadisticas.puts "Cantidad de etiquetas únicas sin atributos: " + etiquetasU.length.to_s
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
		
		archivo_estadisticas.puts x.to_s + ". Etiqueta <" + e + ">:\n    Total: " + i.to_s + "\n    Únicas: " + j.to_s
	end
	
	# Obtiene las estadísticas de la frecuencia de palabras
	archivo_estadisticas.puts ""
	archivo_estadisticas.puts ""
	archivo_estadisticas.puts "Tabla de palabras y frecuencia de uso"
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
		archivo_estadisticas.puts x.to_s + ". Palabra «" + pf[0] + "»:\n    Frecuencia: " + pf[1].to_s + "\n    Porcentaje: " + ((pf[1].to_f / palabrasLimpias.length.to_f) * 100).to_s
	end
	archivo_estadisticas.close
end

puts $l_g_fin
