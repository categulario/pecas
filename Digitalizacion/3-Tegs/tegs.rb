#!/usr/bin/env ruby
# encoding: UTF-8
# coding: UTF-8

Encoding.default_internal = Encoding::UTF_8

# Funciones y módulos comunes a todas las herramientas
require File.dirname(__FILE__) + "/../../otros/secundarios/general.rb"
require File.dirname(__FILE__) + "/../../otros/secundarios/lang.rb"

## REQUIERE TESSERACT y GHOSTSCRIPT

# Argumentos
directorio = argumento "-d", directorio
lenguaje = argumento "-l", lenguaje
nombre = argumento "-o", nombre
txt = argumento "-t", txt, 1
comprimido = argumento "-c", comprimido, 1
gswin32 = argumento "-32", gswin32, 1
argumento "-v", $l_tg_v
argumento "-h", $l_tg_h

# Comprueba que existan los argumentos necesarios
comprobacion [directorio, lenguaje, nombre]

# Arregla los contenidos de la variable para evitar conflictos
directorio = comprobacionDirectorio directorio
nombre = nombre.split(".").first

# Va al directorio donde están las imágenes
Dir.chdir(directorio)

# Conjunto para los archivos de texto
txts = Array.new
pdfs = Array.new	# Solo para Windows

# Cuenta la cantidad de archivos a reconocer
total = 0
Dir.foreach(directorio) do |archivo|
	if File.extname(archivo) == '.bmp' or File.extname(archivo) == '.png' or File.extname(archivo) == '.tiff' or File.extname(archivo) == '.tif'
		total = total + 1
	end
end

# Inicia Tesseract
actual = 0
Dir.foreach(directorio) do |archivo|
	if File.extname(archivo) == '.bmp' or File.extname(archivo) == '.png' or File.extname(archivo) == '.tiff' or File.extname(archivo) == '.tif'
  
		archivo_sin_extension = archivo.split(".").first
		
		actual = actual + 1

		begin
			puts "#{$l_tg_procesando[0] + actual.to_s + $l_tg_procesando[1] + total.to_s + $l_tg_procesando[2]}".green.bold
			puts "#{$l_tg_reconociendo[0] + archivo + $l_tg_reconociendo[1]}".green

			if OS.windows?
				pdfs.push(".#{archivo_sin_extension}.pdf")
			end
			
			# Crea un PDF con OCR
			`tesseract -l #{lenguaje} #{archivo} .#{archivo_sin_extension} pdf`
			
			if txt
				puts "#{$l_tg_extrayendo[0] + archivo + $l_tg_extrayendo[1]}".green
				
				# Crea un TXT con OCR
				`tesseract -l #{lenguaje} #{archivo} .#{archivo_sin_extension}`
				
				txts.push(".#{archivo_sin_extension}.txt")
			end
		rescue
			puts $l_tg_error_te
			abort
		end
	end
end

# Inicia Ghostscript
begin
	puts $l_tg_uniendo_pdf

	# PDFS a PDF
	if OS.windows?
		pdfs = pdfs.sort
		`gswin#{gswin32 == nil ? "64" : "32"}c -sDEVICE=pdfwrite -dNOPAUSE -dBATCH -sOutputFile=#{nombre}.pdf #{pdfs.join(" ")}`
	else
		`gs -sDEVICE=pdfwrite -dNOPAUSE -dBATCH -sOutputFile=#{nombre}.pdf .*.pdf`
	end
	
	if comprimido
		puts "#{$l_tg_comprimiendo[0] + nombre + $l_tg_comprimiendo[1]}".green
		
		# PDF a PDF comprimido
		if OS.windows?
			`gswin#{gswin32 == nil ? "64" : "32"}c -sDEVICE=pdfwrite -dPDFSETTINGS=/ebook -dNOPAUSE -dBATCH -sOutputFile=#{nombre}-#{$l_tg_comprimido}.pdf #{nombre}.pdf`
		else
			`gs -sDEVICE=pdfwrite -dPDFSETTINGS=/ebook -dNOPAUSE -dBATCH -sOutputFile=#{nombre}-#{$l_tg_comprimido}.pdf #{nombre}.pdf`
		end
	end
rescue
	puts $l_tg_error_gs
	abort
end

# Extrae el texto
if txt
	puts $l_tg_uniendo_txt
	
	# Ordena el conjunto
	txts = txts.sort
	
	# Crea el archivo de texto
	txt_todo = File.open(nombre + ".txt", "w")
	
	# Agrega cada una de las líneas de los archivos de texto
	txts.each do |t|
		File.readlines(t).each do |l|
			txt_todo.puts l
		end
	end
	
	# Finaliza el archivo de texto
	txt_todo.close
end

# Elimina los archivos innecesarios
puts $l_tg_limpiando
Dir.foreach(directorio) do |archivo|
	if File.extname(archivo) == '.pdf' or File.extname(archivo) == '.txt'
		if archivo[0] == "."
			# Solo elimina los archivos PDF o TXT ocultos
			File.delete(archivo)
		end
	end
end

puts $l_g_fin
