#!/usr/bin/env ruby
# encoding: UTF-8
# coding: UTF-8

require 'fileutils'

Encoding.default_internal = Encoding::UTF_8

# Funciones y módulos comunes a todas las herramientas
require File.dirname(__FILE__) + "/../../otros/secundarios/general.rb"
require File.dirname(__FILE__) + "/../../otros/secundarios/lang.rb"

# Argumentos
argumento "-v", $l_au_v
argumento "-h", $l_au_h
init = argumento "--init", init, 1
nombre = if argumento "-o", nombre != nil then argumento "-o", nombre else $l_au_nombre end
padre = if argumento "--directory", padre != nil then argumento "--directory", padre else Dir.pwd end
archivo_madre = if argumento "-f", archivo_madre != nil then argumento "-f", archivo_madre end
portada = if argumento "-c", portada != nil then argumento "-c", portada end
proyecto = if argumento "-d", proyecto != nil then argumento "-d", proyecto else Dir.pwd end
imagenes = if argumento "-i", imagenes != nil then argumento "-i", imagenes end
notas = if argumento "-n", notas != nil then argumento "-n", notas end
css = if argumento "-s", css != nil then argumento "-s", css end
yaml = if argumento "-y", yaml != nil then argumento "-y", yaml else $l_au_prefijo + $l_g_meta_data end
win32 = argumento "-32", win32, 1
indice = if argumento "--index", indice != nil then argumento "--index", indice else "3" end
inner = argumento "--inner", inner, 1
reset = argumento "--reset", reset, 1
seccion = argumento "--section", seccion, 1

# Variables que se usarán
$log = Array.new
xhtml = ""

# Elimina los archivos excepto el YAML
def remover
	Dir.glob("*") do |archivo|
		if File.extname(archivo) != ".yaml" then FileUtils.rm_rf(archivo) end
	end
end

# Crea el log
def reporte
	# Crea el archivo de inicialización
	$l_au_log = File.new($l_au_log, "w:UTF-8")
	$l_au_log.puts $log
	$l_au_log.close
end

# Revierte el proceso si existe algún error
def reversion
	puts $l_au_error_r[0].red.bold
	remover
	puts $l_au_error_r[1].red.bold
	reporte
end

# Obtiene el error para el log
def error texto
	$log.push(texto)
	$log.push($!.message)
	$!.backtrace.each do |e|
		$log.push(e)
	end
end

def ejecutar texto, comando
	begin
		$log.push(texto + "\n" + comando)
		system comando
	rescue
		error texto
		reversion
	end
end

# Verifica los EPUB con EpubCheck
def verificacion epub, version, log
	epubcheck = File.dirname(__FILE__) + "/../EpubCheck/"

	puts "#{$l_au_verificando[0] + epub + $l_au_verificando[1]}".green
	ejecutar "\n" + log, "java -jar #{epubcheck + if version == 4 then "4-0-2/epubcheck.jar" else "3-0-1/epubcheck.jar" end} #{epub}"
	
	# Si mo se encontró EpubCheck 4.0.2
	if $?.exitstatus == 127
		$log.push("\nADVERTENCIA: " + log + "\n" + $l_au_epubcheck)
		puts $l_au_epubcheck.yellow
	end
end

# Sirve para detectar si existe un parámetro o no
def parametro variable, flag
	# Si no hay variable, regresa nada
	if variable == nil
		return ""
	# Si hay variable, regresa la sintaxis correcta
	else
		return "#{flag} #{arregloRutaTerminal variable}"
	end
end

# Pregunta para eliminar o abortar el proceso
def pregunta
	print $l_au_pregunta
	respuesta = STDIN.gets.chomp.downcase
	if respuesta == "y" || respuesta == ""
		puts $l_au_eliminando
		remover
	elsif respuesta == "n"
		puts $l_au_error_a
		abort
	else
		pregunta
	end
end

# Si es inicialización
if init
	
	# Comprueba y adquiere el path absoluto de la carpeta para el EPUB
	padre = comprobacionDirectorio padre
	
	# Va al directorio
	Dir.chdir(padre)
	
	# Verifica que no existan conflictos con el nombre del proyecto
	Dir.glob("*") do |archivo|
		if File.exists?(nombre) == true
			puts $l_g_error_nombre
			abort
		end
	end
	
	# Crea la carpeta del proyecto
	puts "#{$l_au_creando[0] + nombre + $l_au_creando[1]}".green
	Dir.mkdir nombre
	Dir.chdir(nombre)
	
	# Crea el archivo de metadatos
	metadata = $l_g_meta_data
	$l_g_meta_data = File.new($l_au_prefijo + $l_g_meta_data, "w:UTF-8")
	$l_g_meta_data.puts $l_cr_yaml
	$l_g_meta_data.close
	
	# Crea el archivo de inicialización
	inicializacion = $l_au_init_archivo
	$l_au_init_archivo = File.new($l_au_init_archivo, "w:UTF-8")
	$l_au_init_archivo.puts $l_au_init_contenido
	$l_au_init_archivo.close

# Si es automatización
else

	# Comprueba que existan los argumentos necesarios
	comprobacion [archivo_madre]
	
	# Comprueba que el archivo tenga la extensión correcta
	archivo_madre = comprobacionArchivo archivo_madre, [".md",".html",".xhtml",".xml",".htm"]
	portada = comprobacionArchivo portada, [".jpg", ".jpeg", ".gif", ".png", ".svg"]
	css = comprobacionArchivo css, [".css"]
	notas = comprobacionArchivo notas, [".md"]
	yaml = comprobacionArchivo yaml, [".yaml"]

	# Comprueba carpetas
	proyecto = comprobacionDirectorio proyecto
	imagenes = comprobacionDirectorio imagenes
	
	# Va al directorio
	Dir.chdir(proyecto)
	
	# Verifica que el directorio sea un proyecto de Automata
	existe = false
	Dir.glob(".*") do |archivo|
		if File.exists?($l_au_init_archivo) == true then existe = true; break end
	end
	if !existe then puts "#{$l_au_error_e[0] + proyecto + $l_au_error_e[1]}".red.bold; abort end
	
	# Verifica si hay más archivos dentro del proyecto y se eliminan si así se indica
	Dir.glob("*") do |archivo|
		if File.extname(archivo) != ".yaml"
			# Hace la pregunta
			pregunta
			break
		end
	end
	
	xhtml = proyecto.to_s + "/.#{File.basename(archivo_madre).split(".")[0]}.xhtml"
	
	# Conversión si es necesaria
	if File.extname(archivo_madre) == ".md"
		ejecutar "# pc-pandog", "ruby #{File.dirname(__FILE__)+ "/../../Archivo-madre/1-Pandog/pandog.rb"} -i #{arregloRutaTerminal archivo_madre} -o #{arregloRutaTerminal xhtml}"
	end
	
	# Agrega la portada al YAML
	if portada != nil
		cambioContenido yaml, /cover/, "cover: #{File.basename(portada)}"
	end
	
	# Creación del proyecto EPUB
	ejecutar "\n# pc-creator", "ruby #{File.dirname(__FILE__)+ "/../1-Creador/creator.rb"} #{parametro portada, "-c"} #{parametro imagenes, "-i"} #{parametro css, "-s"}"

	# Elimina el YAML creado por pc-creator, ya que ya existe uno
	FileUtils.rm_rf($l_g_meta_data)
	
	# División del archivo XHTML
	ejecutar "\n# pc-divider", "ruby #{File.dirname(__FILE__)+ "/../2-Divisor/divider.rb"} -f #{arregloRutaTerminal xhtml} -d #{$l_cr_epub_nombre}/OPS/xhtml -s #{$l_cr_epub_nombre}/OPS/css/styles.css #{parametro indice, "-i"} #{if seccion then "--section" end}"
	
	# Adición de notas
	if notas
		ejecutar "\n# pc-notes", "ruby #{File.dirname(__FILE__)+ "/../3-Notas/notes.rb"} -f #{arregloRutaTerminal notas} -d #{$l_cr_epub_nombre}/OPS/xhtml -s #{$l_cr_epub_nombre}/OPS/css/styles.css #{parametro indice, "-i"} #{if inner then "--inner" end} #{if reset then "--reset" end}"
	end
	
	# Recreación del EPUB
	ejecutar "\n# pc-recreator", "ruby #{File.dirname(__FILE__)+ "/../6-Recreador/recreator.rb"} #{parametro yaml, "-y"} #{if win32 then "-32" end}"
	
	# Cambio de versión
	ejecutar "\n# pc-changer", "ruby #{File.dirname(__FILE__)+ "/../7-Cambiador/changer.rb"} #{arregloRutaTerminal(Dir.pwd + "/" + $l_cr_epub_nombre + ".epub")} 3.0.0"
	
	# Verificación con EpubCheck del EPUB más reciente
	verificacion $l_cr_epub_nombre + ".epub", 4, "# epubcheck 4.0.2"
	
	# Verificación con EpubCheck del EPUB 3.0.0
	verificacion $l_cr_epub_nombre + $l_ch_sufijo + ".epub", 3, "# epubcheck 3.0.1"
	
	# KindleGen
	ejecutar "\n# kindlegen", "kindlegen #{$l_cr_epub_nombre + ".epub"}"
	
	# Si no se encontró KindleGen
	if $?.exitstatus == 127
		$log.push("\nADVERTENCIA: # kindlegen\n" + $l_au_kindlegen)
		puts $l_au_kindlegen.yellow
	end
	
	# Elimina el archivo XHTML porque ya no es necesario
	FileUtils.rm_rf(xhtml)
	
	reporte
end

puts "\n" + $l_g_fin
