#!/usr/bin/env ruby
# encoding: UTF-8
# coding: UTF-8

require 'fileutils'

Encoding.default_internal = Encoding::UTF_8

# Funciones y módulos comunes a todas las herramientas
require File.dirname(__FILE__) + "/../../src/common/general.rb"
require File.dirname(__FILE__) + "/../../src/common/lang.rb"

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
archivos_xhtml = if argumento "-x", archivos_xhtml != nil then argumento "-x", archivos_xhtml end
archivos_js = if argumento "-j", archivos_js != nil then argumento "-j", archivos_js end
archivos_fbk = if argumento "--fallbacks", archivos_fbk != nil then argumento "--fallbacks", archivos_fbk end
notas = if argumento "-n", notas != nil then argumento "-n", notas end
css = if argumento "-s", css != nil then argumento "-s", css end
yaml = if argumento "-y", yaml != nil then argumento "-y", yaml else $l_au_prefijo + $l_g_meta_data end
no_preliminares = argumento "--no-pre", no_preliminares, 1
depth = if argumento "--depth", depth != nil then argumento "--depth", depth else nil end
indice = if argumento "--index", indice != nil then argumento "--index", indice else "3" end
inner = argumento "--inner", inner, 1
reset = argumento "--reset", reset, 1
seccion = argumento "--section", seccion, 1
rotacion = argumento "--rotate", rotacion, 1
with_indexes = argumento "--with-indexes", init, 1
two_columns = argumento "--two-columns", init, 1
resize = argumento "--resize", resize, 1
resize_h = if argumento "--resize-h", resize_h != nil then argumento "--resize-h", resize_h else nil end
resize_v = if argumento "--resize-v", resize_v != nil then argumento "--resize-v", resize_v else nil end
compress = argumento "--compress", compress, 1
overwrite = argumento "--overwrite", overwrite, 1
no_legacy = argumento "--no-legacy", no_legacy, 1
no_analytics = argumento "--no-analytics", no_analytics, 1
no_epubcheck = argumento "--no-epubcheck", no_epubcheck, 1
no_ace = argumento "--no-ace", no_ace, 1
no_kindlegen = argumento "--no-kindlegen", no_kindlegen, 1
no_alphabet = argumento "--no-alphabet", init, 1

# Variables que se usarán
$log = Array.new
xhtml = ""
epub_final = ""

# Elimina los archivos excepto el YAML
def remover
	Dir.glob("*") do |archivo|
		if File.extname(archivo) != ".yaml" && File.extname(archivo) != ".rb" && File.extname(archivo) != ".sh" && File.extname(archivo) != ".py" then FileUtils.rm_rf(archivo) end
	end
end

# Crea el log
def reporte
    nombre = $l_au_log.to_s
	$l_au_log = File.new($l_au_logs + '/' + nombre, "w:UTF-8")
    $l_au_log.puts $l_au_v + "\n\n------------------------------------------------------------------\n\n"
	$l_au_log.puts $log
	$l_au_log.close
end

# Revierte el proceso si existe algún error
def reversion
	puts $l_au_error_r[0].red.bold
	remover
    Dir.mkdir($l_au_logs)
	puts $l_au_error_r[1].red.bold
	reporte
end

# Obtiene el error para el log
def error texto
	$log.push(texto)
    if $! != nil
	    $log.push($!.message)
	    $!.backtrace.each do |e|
		    $log.push(e)
	    end
    end
end

def ejecutar texto, comando
	begin
		$log.push(texto + "\n$ " + comando)

		# Para KindleGen y EpubCheck se guarda la salida
		if comando !~ /kindlegen/ && comando !~ /epubcheck/ && comando !~ /ace\s/
			system comando
		else
            begin
			    m = `#{comando}`
			    puts m
			    $log.push(m.gsub(/\n/,"\n  ").gsub("  Info(prcgen):I1037","=>Info(prcgen):I1037").gsub("  Info(prcgen):I1038","=>Info(prcgen):I1038").gsub("[32m","  ").gsub("[39m","").gsub(/^  info:/,"\n  info:"))
            rescue
                if comando =~ /ace\s/
                    # Cuando ace no se encuentra, marca un error aquí…
                    siFallo $l_au_ace
                end
            end
		end
	rescue
		error texto, true
		reversion
	end
end

# Si hay un error al ejecutar un comando
def siFallo texto, rescate = false
    if $?.exitstatus == 127 || rescate
        $log.push("=> " + texto)
        puts texto.yellow
    end
end

# Verifica los EPUB con EpubCheck
def verificacion epub, version, log
	epubcheck = File.dirname(__FILE__) + "/../../src/alien/epubcheck/"

    begin
        puts "\nEpubcheck #{version}: #{$l_au_verificando[0] + epub + $l_au_verificando[1]}".green
	    ejecutar "\n" + log, "java -jar #{epubcheck + if version == 4 then "4-0-2/epubcheck.jar" else "3-0-1/epubcheck.jar" end} #{epub} -out log.xml -q"

	    # Guarda el log de EpubCheck
	    log_abierto = File.open("log.xml", "r:UTF-8")
	    log_abierto.each do |linea|
		    if linea =~ /FATAL/ || linea =~ /ERROR/ || linea =~ /WARNING/
			    $log.push("=>" + linea)
		    else
			    $log.push("  " + linea)
		    end
	    end
	    log_abierto.close

	    # Renombra el log de EpubCheck
	    File.rename("log.xml", "epubcheck-#{version}.xml")
        FileUtils.mv("epubcheck-#{version}.xml", $l_au_logs + '/epubcheck')
    rescue
	    siFallo $l_au_epubcheck.join(" #{version} "), true
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
def pregunta overwrite
    if overwrite != true
	    print $l_au_pregunta.blue.bold
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
    else
        remover
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

	# Crea el archivo para índices
	index = $l_in_archivo_nombre
	$l_in_archivo_nombre = File.new($l_au_prefijo + $l_in_archivo_nombre, "w:UTF-8")
	$l_in_archivo_nombre.puts $l_in_archivo_contenido
	$l_in_archivo_nombre.close
	
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
	archivos_xhtml = comprobacionDirectorio archivos_xhtml
	archivos_js = comprobacionDirectorio archivos_js
	archivos_fbk = comprobacionDirectorio archivos_fbk
	
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
			pregunta(overwrite)
			break
		end
	end
	
	xhtml = proyecto.to_s + "/.#{File.basename(archivo_madre).split(".")[0]}.xhtml"

	# Conversión si es necesaria
	if File.extname(archivo_madre) == ".md"
		ejecutar "# pc-pandog", "ruby #{File.dirname(__FILE__)+ "/../../base-files/pandog/pandog.rb"} -i #{arregloRutaTerminal archivo_madre} -o #{arregloRutaTerminal xhtml}"
	# De lo contrario copia el archivo y lo renombra
	else
		FileUtils.cp(archivo_madre, Dir.pwd)
		File.rename(File.basename(archivo_madre), "." + File.basename(archivo_madre, '.*') + '.xhtml')
	end

	# Agrega la portada al YAML
	if portada != nil
		cambioContenido yaml, /cover/, "cover: #{File.basename(portada)}"
	end
	
	# Creación del proyecto EPUB
	ejecutar "\n# pc-creator", "ruby #{File.dirname(__FILE__)+ "/../creator/creator.rb"} -o #{$l_au_epub_nombre} #{parametro portada, "-c"} #{parametro imagenes, "-i"} #{parametro archivos_xhtml, "-x"} #{parametro archivos_js, "-j"} #{parametro archivos_fbk, "--fallbacks"} #{parametro css, "-s"} #{if no_preliminares then "--no-pre" end}"

	# Redimensión de las imágenes
    if resize != nil || compress != nil || resize_h != nil || resize_v != nil
    	ejecutar "\n# pc-images", "ruby #{File.dirname(__FILE__)+ "/../../base-files/images/images.rb"} -i '#{Dir.pwd + '/epub/OPS/img'}' #{compress ? '--compress' : ''} #{resize ? '--resize' : ''} #{parametro resize_h, "--resize-h"} #{parametro resize_v, "--resize-v"}"
    end
	
	# División del archivo XHTML
	ejecutar "\n# pc-divider", "ruby #{File.dirname(__FILE__)+ "/../divider/divider.rb"} -f #{arregloRutaTerminal xhtml} -d #{$l_au_epub_nombre}/OPS/xhtml -s #{$l_au_epub_nombre}/OPS/css/styles.css #{parametro indice, "-i"} #{if seccion then "--section" end}"
	
	# Adición de notas
	if notas
		ejecutar "\n# pc-notes", "ruby #{File.dirname(__FILE__)+ "/../notes/notes.rb"} -n #{arregloRutaTerminal notas} -d #{$l_au_epub_nombre}/OPS/xhtml -s #{$l_au_epub_nombre}/OPS/css/styles.css #{parametro indice, "-i"} #{if inner then "--inner" end} #{if reset then "--reset" end}"
	end

    if with_indexes
        ejecutar "\n# pc-index", "ruby #{File.dirname(__FILE__)+ "/../index/index.rb"} -d #{$l_au_epub_nombre}/OPS/xhtml -s #{$l_au_epub_nombre}/OPS/css/styles.css #{if no_alphabet then "--no-alphabet" end} #{if two_columns then "--two-columns" end}"
    end

	# Recreación del EPUB
	ejecutar "\n# pc-recreator", "ruby #{File.dirname(__FILE__)+ "/../recreator/recreator.rb"} -d #{$l_au_epub_nombre} #{parametro yaml, "-y"} #{parametro depth, "--depth"}"
	
	# Localiza el nombre del EPUB
	Dir.glob("*.epub") do |e|
		epub_final = e.split(".")[0]
	end

	# Cambio de versión
    if no_legacy != true
    	ejecutar "\n# pc-changer", "ruby #{File.dirname(__FILE__)+ "/../changer/changer.rb"} -e #{arregloRutaTerminal(Dir.pwd + "/" + epub_final + ".epub")} --version 3.0.0"
    end
	
    # Carpeta donde se guardarán los logs
    Dir.mkdir($l_au_logs)
    Dir.mkdir($l_au_logs + '/epubcheck')
    Dir.mkdir($l_au_logs + '/ace')
    if no_analytics != true
        Dir.mkdir($l_au_logs + '/pc-analytics')
    end

	# Análisis del EPUB
    if no_analytics != true
    	ejecutar "\n# pc-analytics", "ruby #{File.dirname(__FILE__)+ "/../../base-files/analytics/analytics.rb"} -f #{arregloRutaTerminal(Dir.pwd + "/" + epub_final + ".epub")} --json #{rotacion ? '--rotate' : ''}"
        FileUtils.mv("#{$l_an_archivo_nombre}html", $l_au_logs + '/pc-analytics')
        FileUtils.mv("#{$l_an_archivo_nombre}json", $l_au_logs + '/pc-analytics')
    end

    if no_epubcheck != true
	    # Verificación con EpubCheck del EPUB más reciente
	    verificacion epub_final + ".epub", 4, "# epubcheck 4.0.2"
	    
	    # Verificación con EpubCheck del EPUB 3.0.0
        if no_legacy != true
        	verificacion epub_final + "_3-0-0.epub", 3, "# epubcheck 3.0.1"
        end
    end
	
    # Ace
    if no_ace != true
    	puts "\nAce: #{$l_au_verificando[0] + epub_final + ".epub" + $l_au_verificando[1]}".green
        ejecutar "\n# ace", "ace -o #{$l_au_logs + '/ace'} #{epub_final + '.epub'}"
    end

	# KindleGen
    if no_kindlegen != true
        begin
	        puts "\nkindlegen: #{$l_au_convirtiendo[0] + epub_final + '.epub' + $l_au_convirtiendo[1]}".green
	        ejecutar "\n# kindlegen", "kindlegen #{epub_final + ".epub"}"
            FileUtils.mv(epub_final + '.mobi', epub_final.gsub('epub-', 'mobi-') + '.mobi')
            siFallo $l_au_kindlegen
        rescue
            puts $l_au_kindlegen.yellow
        end
    end
	
	# Elimina el archivo XHTML porque ya no es necesario
	FileUtils.rm_rf(xhtml)
	
	reporte
end

if no_kindlegen != true
    puts "\n" + $l_g_fin
end
