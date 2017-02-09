#!/usr/bin/env ruby
# encoding: UTF-8
# coding: UTF-8

require 'fileutils'

Encoding.default_internal = Encoding::UTF_8

# Funciones y módulos comunes a todas las herramientas
require File.dirname(__FILE__) + "/../../otros/secundarios/general.rb"
require File.dirname(__FILE__) + "/../../otros/secundarios/lang.rb"

## REQUIERE PANDOC

# Argumentos
entrada = argumento "-i", entrada
salida = argumento "-o", salida
version = argumento "-v", $l_pg_v
ayuda = argumento "-h", $l_pg_h

# Comprueba que existan los argumentos necesarios
comprobacion [entrada, salida]

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
	File.open(s_nombre, "r").each do |linea|
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
	md_nuevo.close

	# Borra el archivo viejo y renombra al nuevo para sustituirlo
	File.delete(s_nombre)
	File.rename(".#{s_nombre}", s_nombre)
end

# El plus a pandoc es en el tratamiento entre el MD y el HTML
if ext_e == ".md" && (ext_s == ".html" || ext_s == ".xhtml" || ext_s == ".htm" || ext_s == ".xml")
	begin
		# Por defecto crea un HTML sin cabeza
		`pandoc #{entrada} -o #{directorioPadre(salida) + "/" + File.basename(salida, ".*") + ".html"}`
		
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
		`pandoc #{entrada} --atx-headers -o #{salida}`
		
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
	`pandoc #{entrada} -o #{salida}`
end

puts $l_g_fin
