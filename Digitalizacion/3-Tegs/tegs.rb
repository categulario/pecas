#!/usr/bin/env ruby
# encoding: UTF-8
# coding: UTF-8

Encoding.default_internal = Encoding::UTF_8

# Funciones y módulos comunes a todas las herramientas
require File.dirname(__FILE__) + "/../../otros/secundarios/general.rb"

## REQUIERE TESSERACT y GHOSTSCRIPT

# Variables
$directorio
$lenguaje
$nombre
$comprimido_texto = "comprimido"
$txt = false
$comprimido = false
$gswin = "64"

# Obtiene los argumentos
ARGF.argv.each_with_index do |p, i|
	if p == "-d"
		$directorio = ARGF.argv[i+1]
	elsif p == "-l"
		$lenguaje = ARGF.argv[i+1]
	elsif p == "-o"
		$nombre = ARGF.argv[i+1]
	elsif p == "-t"
		$txt = true
	elsif p == "-c"
		$comprimido = true
	elsif p == "-32"
		$gswin = "32"
	elsif p == "-v"
		puts "tegs 0.1.0"
		abort
	elsif p == "-h"
		puts "\nTegs utiliza el poder de Tesseract y de Ghostscript para crear archivos PDF con OCR o TXT a partir de imágenes TIFF, PNG o BMP."
		puts "\nUso:"
		puts "  pt-tegs -d [directorio] -l [idioma] -o [nombre del archivo]"
		puts "\nParámetros necesarios:"
		puts "  -d = [directory] Directorio que contiene las imágenes."
		puts "  -l = [language] Acrónimo del lenguaje a detectar. Es necesario instalar el lenguaje. Lista de acrónimos: https://github.com/tesseract-ocr/tesseract/blob/master/doc/tesseract.1.asc#languages"
		puts "  -o = [output] Nombre para el o los archivos que se crearán."
		puts "\nParámetros opcionales:"
		puts "  -t = [text] Crea un TXT adicional al PDF creado."
		puts "  -c = [compressed] Crea un PDF comprimido adcional al PDF creado."
		puts "  -32 = [32 bits] SOLO WINDOWS, indica si la computadora es de 32 bits."
		puts "\nParámetros únicos:"
		puts "  -v = [version] Muestra la versión."
		puts "  -h = [help] Muestra esta ayuda."
		puts "\nEjemplo sencillo:"
		puts "  pt-tegs -d directorio/de/las/imágenes -l spa -o prueba"
		puts "  Crea un archivo PDF con OCR en español y sin compresión a partir de las imágenes presentes en «directorio/de/las/imágenes»."
		puts "\nEjemplo con PDF comprimido:"
		puts "  pt-tegs -d directorio/de/las/imágenes -l spa -o prueba -c"
		puts "  Además del PDF con OCR, se crea otro PDF con compresión."
		puts "\nEjemplo con archivo de texto:"
		puts "  pt-tegs -d directorio/de/las/imágenes -l spa -o prueba -t"
		puts "  Además del PDF con OCR, se crea un archivo de texto con el contenido de las imágenes."
		puts "\nEjemplo con PDF comprimido y archivo de texto:"
		puts "  pt-tegs -d directorio/de/las/imágenes -l spa -o prueba -c -t"
		puts "  Además del PDF con OCR, se crea otro PDF con compresión y un archivo de texto."
		abort
	end
end

# Comprueba que existan los argumentos necesarios
def comprobacion conjunto
	conjunto.each do |e|
		if e == nil
			puts "\nArgumentos insuficientes.".red.bold
			abort
		end
	end
end

comprobacion [$directorio, $lenguaje, $nombre]

# Arregla los contenidos de la variable para evitar conflictos
$directorio = arregloRuta $directorio
$nombre = $nombre.split(".").first

# Va al directorio donde están las imágenes
Dir.chdir $directorio

# Conjunto para los archivos de texto
$txts = Array.new
$pdfs = Array.new	# Solo para Windows

# Inicia Tesseract
Dir.foreach($directorio) do |archivo|
	if File.extname(archivo) == '.bmp' or File.extname(archivo) == '.png' or File.extname(archivo) == '.tiff' or File.extname(archivo) == '.tif'
  
		archivo_sin_extension = archivo.split(".").first
		
		begin		
			puts "\nReconociendo #{archivo}..."
			
			if OS.windows?
				$pdfs.push(".#{archivo_sin_extension}.pdf")
			end
			
			# Crea un PDF con OCR
			`tesseract -l #{$lenguaje} #{archivo} .#{archivo_sin_extension} pdf`
			
			if $txt
				puts "\nExtrayendo texto de #{archivo}..."
				
				# Crea un TXT con OCR
				`tesseract -l #{$lenguaje} #{archivo} .#{archivo_sin_extension}`
				
				$txts.push(".#{archivo_sin_extension}.txt")
			end
		rescue
			puts "\nAl parecer tu sistema no tiene instalado Tesseract...".red.bold
			abort
		end
	end
end

# Inicia Ghostscript
begin
	puts "\nUniendo archivos pdf, esta operación puede durar varios minutos..."
	
	# PDFS a PDF
	if OS.windows?
		$pdfs = $pdfs.sort
		`gswin#{$gswin}c -sDEVICE=pdfwrite -dNOPAUSE -dBATCH -sOutputFile=#{$nombre}.pdf #{$pdfs.join(" ")}`
	else
		`gs -sDEVICE=pdfwrite -dNOPAUSE -dBATCH -sOutputFile=#{$nombre}.pdf .*.pdf`
	end
	
	if $comprimido
		puts "\nComprimiendo #{$nombre}.pdf, esta operación puede durar varios minutos..."
		
		# PDF a PDF comprimido
		if OS.windows?
			`gswin#{$gswin}c -sDEVICE=pdfwrite -dPDFSETTINGS=/ebook -dNOPAUSE -dBATCH -sOutputFile=#{$nombre}-#{$comprimido_texto}.pdf #{$nombre}.pdf`
		else
			`gs -sDEVICE=pdfwrite -dPDFSETTINGS=/ebook -dNOPAUSE -dBATCH -sOutputFile=#{$nombre}-#{$comprimido_texto}.pdf #{$nombre}.pdf`
		end
	end
rescue
	puts "\nAl parecer tu sistema no tiene instalado Ghostscript...".red.bold
	abort
end

# Extrae el texto
if $txt
	puts "\nUniendo archivos txt..."
	
	# Ordena el conjunto
	$txts = $txts.sort
	
	# Crea el archivo de texto
	txt = File.open($nombre + ".txt", "w")
	
	# Agrega cada una de las líneas de los archivos de texto
	$txts.each do |t|
		File.readlines(t).each do |l|
			txt.puts l
		end
	end
	
	# Finaliza el archivo de texto
	txt.close
end

# Elimina los archivos innecesarios
puts "\nLimpiando directorio..."
Dir.foreach($directorio) do |archivo|
	if File.extname(archivo) == '.pdf' or File.extname(archivo) == '.txt'
		if archivo[0] == "."
			# Solo elimina los archivos PDF o TXT ocultos
			File.delete(archivo)
		end
	end
end

puts "\n¡Operación finalizada exitosamente!".green.bold
