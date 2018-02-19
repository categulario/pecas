#!/usr/bin/env ruby
# encoding: UTF-8
# coding: UTF-8

require 'fileutils'

Encoding.default_internal = Encoding::UTF_8

# Funciones y módulos comunes a todas las herramientas
require File.dirname(__FILE__) + "/../../src/common/general.rb"
require File.dirname(__FILE__) + "/../../src/common/lang.rb"
require File.dirname(__FILE__) + "/../../src/common/css-template.rb"
require File.dirname(__FILE__) + "/../../src/common/xhtml-template.rb"

# Argumentos
epub_nombre = if argumento "-e", epub_nombre != nil then argumento "-e", epub_nombre else nil end
epub_version = if argumento "--version", epub_version != nil then argumento "--version", epub_version else nil end
standalone = argumento "--standalone", standalone, 1
argumento "-v", $l_ch_v
argumento "-h", $l_ch_h
version_disponible = ['2.0.0','2.0.1','3.0.0','3.0.1','3.1']

# Ambos argumentos son necesarios
if epub_nombre == nil || epub_version == nil
    puts $l_g_error_arg
    abort
end

# Comprueba si es un EPUB, obtiene su ruta y su directorio padre
epub_nombre = comprobacionArchivo epub_nombre, [".epub"]

# Compruebe que la versión sea una soportada
version_existente = false
version_disponible.each do |v|
    if v == epub_version
       version_existente = true
        break
    end
end
if !version_existente then puts "#{$l_ch_error_version[0] + epub_version + $l_ch_error_version[1]}".red.bold; abort end

# Analiza el EPUB para obtener un hash con el OPF y todos los HTML
epub_objeto = epub_analisis(epub_nombre, standalone)

# Eliminar
	archivo = File.new('borrar.json', 'w:UTF-8')
	archivo.puts JSON.pretty_generate(epub_objeto)
	archivo.close
# Eliminar

abort


















# OJO: FileUtils.rm_rf no elimina la carpeta oculta del EPUB viejo descomprimido

# Obtiene los argumentos necesarios
if ARGF.argv.length <= 1
    puts "\nArgumentos insuficientes.".red.bold
    abort
elsif ARGF.argv.length == 2
    # El primer argumento tiene que ser la ruta al EPUB
    if File.extname(ARGF.argv[0]) != '.epub'
        puts "\nEl primer argumento tiene que ser la ruta al EPUB.".red.bold
        abort
    end
    # El segundo argumento tiene que ser la versión disponible
    if ARGF.argv[1] != '3.0.0' and ARGF.argv[1] != '3.0.1'
        puts "\nLas versiones disponibles son: 3.0.0 o 3.0.1.".red.bold
        abort
    end
else
    puts "\nSolo se permiten dos argumentos: ruta al EPUB y nueva versión deseada.".red.bold
    abort
end

$rutaEpub = ARGF.argv[0]
$version = ARGF.argv[1]

$rutaConEpub = arregloRuta $rutaEpub

# Elementos comunes
$divisor = '/'
$carpeta = ''
$epub = ''
$directorio = '.epub-changer'
$comillas = '\''

if OS.windows?
    $comillas = ''
end

# Obtiene la ruta del EPUB y su nombre
$rutaEpubArray = $rutaConEpub.split($divisor)

$rutaEpubArray.each do |c|

    if c != $rutaEpubArray.last
        # if OS.windows?
        #     $carpeta += c.to_s + '\\'
        # else
            $carpeta += c.to_s + $divisor
        # end
    else
        $epub = c.to_s
        $epub = $epub.split('.epub')[0]
    end
end

# Va a la carpeta
Dir.chdir($carpeta)

# Para Windows es necesaria la ruta a zip.exe
if OS.windows?
	unzip = "#{File.dirname(__FILE__)+ "/../../src/alien/info-zip/unzip.exe"}"
else
	unzip = "unzip"
end

puts "\nDescomprimiendo EPUB...".magenta.bold

system ("#{unzip} -qq #{arregloRutaTerminal $rutaConEpub} -d #{$directorio}")

# Elimina la carpeta temporal
def removerCarpeta
    ruta = $carpeta + $directorio
	FileUtils.rm_rf(ruta)
end

# Para obtener la línea del OPF donde se indica su versión y todas las líneas
$opfRuta = ''
$opfContenido = Array.new

# Busca el archivo OPF
Dir.glob($carpeta + $directorio + $divisor + '**' + $divisor + '*.*') do |archivo|
    if File.extname(archivo).downcase == '.opf'
        $opfRuta = archivo
        break
    end
end

# Abre el archivo OPF, busca la línea donde se indica la versión y agrega todas las líneas al conjunto $opfContenido
opf = File.open($opfRuta, 'r:UTF-8')

opf.each do |linea|
    # Si se está en la etiqueta de apertura del package
    if linea =~ /<(\s*)package/
        # Limpia la línea para solo tener la versión actual
        version = linea.match(/version=[\"\']([^"]*)[\"\']/)
        $versionActual = version[1].to_s

        if $versionActual =~ /version/
            $versionActual = version.to_s.split('"')[-1]
        end

        if linea =~ /rendition/
            $versionActual = '3.0.0'
        else
            $versionActual = '3.0.1'
        end

        # Aborta si se intenta cambiar a la misma versión
        if $versionActual == $version
            puts "\nEste EPUB ya es versión #{$versionActual}.".magenta.bold
            removerCarpeta
            abort
        end
    end

    $opfContenido.push(linea)
end

puts "\nCambiando versión de #{$versionActual} a #{$version}...".magenta.bold

# Cambia las versiones en el OPF
$opfContenido.each do |linea|
    if linea =~ /<(\s*)package/
        # Obtención del viejo prefijo
        prefijo = linea.match(/prefix=[\"\']([^"]*)[\"\']/)
        prefijo = prefijo[1].to_s

        # Cambios según la versión actual
        if $versionActual == '3.0.1'
            prefijo = 'rendition: http://www.idpf.org/vocab/rendition/# schema: http://schema.org/ ' + prefijo
        else
            prefijo = prefijo.gsub(/rendition:(.*?)#/, '').strip
        end

        # Nuevo prefijo
        nuevaLineaPrefijo = linea.to_s.gsub(/prefix=[\"\']([^"]*)[\"\']/, 'prefix="' + prefijo + '"')

        # Localización en el conjunto de la linea donde está el prefijo
        hashPrefijo = Hash[$opfContenido.map.with_index.to_a]

        # Cambio de línea
        $opfContenido[hashPrefijo[linea]] = nuevaLineaPrefijo
    end
end

# Cambia el OPF para meter los cambios
opf = File.open($opfRuta, 'w:UTF-8')

$opfContenido.each do |linea|
    opf.puts linea
end

opf.close

# Obtiene las carpetas del EPUB para preparar la compresión
$primerosArchivos = Array.new

Dir.glob($carpeta + $directorio + $divisor + '**') do |archivo|
    if File.basename(archivo) != "mimetype"
        $primerosArchivos.push(archivo.split($divisor).last)
    end
end

# Se va a la carpeta para hacer el EPUB
Dir.chdir($carpeta + $directorio)

# La ruta para crear el EPUB
$rutaEPUB = "../#{$epub}_#{$version.gsub(".","-")}.epub"

# Para Windows es necesaria la ruta a zip.exe
if OS.windows?
	zip = "#{File.dirname(__FILE__)+ "/../../src/alien/info-zip/zip-x64.exe"}"
else
	zip = "zip"
end

espacio = ' '

# Elimina el EPUB previo
Dir.glob($carpeta + $divisor + '**') do |archivo|
    if File.basename(archivo) == "#{$epub}_#{$version.gsub(".","-")}.epub"
        espacio = ' nuevo '
        puts "\nEliminando EPUB versión #{$version} previo...".magenta.bold
        FileUtils.rm_rf($rutaEPUB)
    end
end

puts "\nCreando#{espacio}EPUB versión #{$version}...".magenta.bold

# Crea el EPUB
system ("#{zip} #{$comillas}#{$rutaEPUB}#{$comillas} -X mimetype")
system ("#{zip} #{$comillas}#{$rutaEPUB}#{$comillas} -r #{$primerosArchivos[-2]} #{$primerosArchivos[-1]} -x \*.DS_Store \*._*")

removerCarpeta

# Finaliza la creación
puts "\n#{$epub}_#{$version.gsub(".","-")}.epub creado en: #{$carpeta}".magenta.bold
puts "\nEl proceso ha terminado.".gray.bold
