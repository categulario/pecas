#!/usr/bin/env ruby
# encoding: UTF-8
# coding: UTF-8

Encoding.default_internal = Encoding::UTF_8

require 'fileutils'

# Funciones y módulos comunes a todas las herramientas
require File.dirname(__FILE__) + "/../../src/common/general.rb"
require File.dirname(__FILE__) + "/../../src/common/lang.rb"

# Argumentos
directorio = if argumento "-d", directorio != nil then argumento "-d", directorio else Dir.pwd end
lenguaje = argumento "-l", lenguaje
nombre = argumento "-o", nombre
tif = argumento "--tif", tif, 1
txt = argumento "--txt", txt, 1
argumento "-v", $l_tg_v
argumento "-h", $l_tg_h

# Comprueba que existan los argumentos necesarios
comprobacion [lenguaje, nombre]

# Arregla los contenidos de la variable para evitar conflictos
directorio = comprobacionDirectorio directorio
nombre = nombre.split(".").first

# Va al directorio donde están las imágenes
Dir.chdir(directorio)

# Conjunto para los archivos de texto
files = Array.new
ext = ''

# Obtiene cada archivo TIF
Dir.foreach(directorio) do |archivo|
	if File.extname(archivo) == '.tiff' or File.extname(archivo) == '.tif'
        ext = File.extname(archivo)
        files.push(archivo)
	end
end

# Ordena los archivos
files = files.sort

# Elimina el TIF multipágina si ya existe uno con el mismo nombre
if File.file?(nombre + ext) then FileUtils.rm(nombre + ext) end

begin
    # Crea un tif multipágina
    puts "#{$l_tg_uniendo[0] + files.length.to_s +  $l_tg_uniendo[1]}".green
    system("tiffcp *.tif #{nombre + ext}")
rescue
    puts $l_tg_error_ti
    abort
end

begin
    if !txt
        # Extrae el texto y lo guarda como PDF
        puts $l_tg_extranendo
        system("tesseract -l #{lenguaje} #{nombre + ext} #{nombre} pdf")
    else
        # Extrae el texto y lo guarda como PDF y TXT
        puts $l_tg_extranendo2
        system("tesseract -l #{lenguaje} #{nombre + ext} #{nombre} #{File.dirname(__FILE__) + '/pdf_txt'}")
    end
rescue
    puts $l_tg_error_te
    abort
end

# Elimina el archivo TIF multipágina
if !tif
    puts $l_tg_eliminando
    FileUtils.rm(nombre + ext)
end

puts $l_g_fin
