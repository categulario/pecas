#!/usr/bin/env ruby
# encoding: UTF-8
# coding: UTF-8

# Es para eliminar tildes y ñ en los nombres de los archivos
require 'active_support/inflector'

# Funciones y módulos comunes a todas las herramientas
require File.dirname(__FILE__) + "/../../otros/secundarios/general.rb"
require File.dirname(__FILE__) + "/../../otros/secundarios/xhtml-template.rb"

# Para detectar que es un número entero; viene de: http://stackoverflow.com/questions/1235863/test-if-a-string-is-basically-an-integer-in-quotes-using-ruby
class String
    def is_i?
       /\A[-+]?\d+\z/ === self
    end
end

# Elementos generales
$divisor = '/'
$comillas = '\''
$lenguaje = "es"
$archivo = ""
$carpeta = ""
$rutaCSS = ""
$archivoCSS = ""
$conteo = ""
$epubType = ""
$epubTypeCreacion = true

if OS.windows?
    $comillas = ''
end

# Obtiene los argumentos necesarios
if ARGF.argv.length < 1
    puts "\nLa ruta al archivo HTML o XHTML es necesaria.".red.bold
    abort
elsif ARGF.argv.length == 1
    $archivo = ARGF.argv[0]
    $archivo = arregloRuta $archivo

    if File.extname($archivo) != '.html' && File.extname($archivo) != '.xhtml'
        puts "\nSolo se permiten archivos HTML o XHTML.".red.bold
        abort
    end
else
    puts "\nSolo se permite un argumento, el de la ruta al archivo HTML o XHTML.".red.bold
    abort
end

# Obtiene la carpeta destino
def carpetaDestino
    puts "\nArrastra la carpeta destino".blue
    $carpeta = arregloRuta $stdin.gets.chomp

    if $carpeta.strip == ""
        carpetaDestino
    end
end

carpetaDestino

# Se va a la carpeta para crear los archivos
Dir.chdir($carpeta)

# Obtiene el archivo CSS
def archivoCSSBusqueda
    puts "\nArrastra el archivo CSS si existe ".blue + "[dejar en blanco para ignorar]:".bold
    $archivoCSS = $stdin.gets.chomp
    $archivoCSS = arregloRuta $archivoCSS
    $archivoCSS = $archivoCSS.strip

    # Si se arrastró un archivo
    if $archivoCSS != ""
        # Si el archivo introducido no es un CSS, vuelve a preguntar
        if $archivoCSS.split(".").last != "css"
            puts "\nEl archivo indicado no tiene extensión .css.".red.bold
            archivoCSSBusqueda
        end

        # Para sacar la ruta relativa al archivo CSS
        archivoConjuntoCSS = $archivoCSS.split($divisor)
        separacionesConjuntoCarpeta = $carpeta.split($divisor)

        # Ayuda a determinar el número de índice donde ambos conjutos difieren
        indice = 0
        archivoConjuntoCSS.each do |parte|
            if parte === separacionesConjuntoCarpeta[indice]
                indice += 1
            else
                break
            end
        end

        # Elimina los elementos similares según el índice obtenido
        archivoConjuntoCSS = archivoConjuntoCSS[indice..archivoConjuntoCSS.length - 1]
        separacionesConjuntoCarpeta = separacionesConjuntoCarpeta[indice..separacionesConjuntoCarpeta.length - 1]

        # Crea la ruta
        $rutaCSS = ("..#{$divisor}" * separacionesConjuntoCarpeta.length) + archivoConjuntoCSS.join($divisor)
    end
end

archivoCSSBusqueda

# Pregunta por el índice a comenzar
def indiceComienzo
    puts "\nIndica el número inicial para la numeración de los archivos ".blue + "[3 por defecto]:".bold
    $conteo = $stdin.gets.chomp.strip

    if $conteo == ""
        $conteo = "3"
    end

    if $conteo.is_i? == false
        puts "\nSolo se permiten números enteros.".red.bold
        indiceComienzo
    else
        $conteo = $conteo.to_i
    end
end

indiceComienzo

# Pregunta si se desean agregar epub:type al body
def epubTypePregunta
    puts "\n¿Deseas introducir un epub:type al <body> de cada uno de los archivos que se crearán?".blue + "[S/n]".bold
    respuesta = $stdin.gets.chomp.strip

    if respuesta.downcase == "s" || respuesta.downcase == ""
        $epubTypeCreacion = true
    elsif respuesta.downcase == "n"
        $epubTypeCreacion = false
    else
        puts "\nRespuesta no válida.".red.bold
        epubTypePregunta
    end
end

epubTypePregunta

# Inicia la división
puts "\nDividiendo archivos...".magenta.bold
if $epubTypeCreacion == true
    puts "\nATENCIÓN: ".bold + "en https://idpf.github.io/epub-vocabs/structure/ se encuentra un listado de los epub:type disponibles."
end

# Para ver el contenido
archivoTodo = File.open($archivo, 'r:UTF-8')

# Variables necesarias para obtener la información
enEncabezado = false
$parteArchivo = 0
$parteArchivoViejo = 1
Objecto = Struct.new(:titulo, :encabezado, :contenido)
$objeto = Objecto.new
$contenidoConjunto = Array.new

# Crea los archivos
def creacion

    # Uniforma la numeración basada en tres dígitos
    def conteoString (numero)
        if numero < 10
            numeroTexto = "00" + numero.to_s
        elsif numero < 100
            numeroTexto = "0" + numero.to_s
        else
            numeroTexto = numero.to_s
        end

        return numeroTexto
    end

    def epubTypeObtencion
        puts "\nCreando el archivo para «#{$objeto.titulo}»".magenta.bold
        puts "Ingresa el epub:type ".brown + "[dejar en blanco para ignorar]".bold
        $epubType = $stdin.gets.chomp.strip
    end

    if $epubTypeCreacion == true
        epubTypeObtencion
    end

    $objeto.contenido = $contenidoConjunto

    # Obtiene el nombre del archivo a partir del título, eliminándose caracteres conflictivos, agregando el conte y el nombre de extensión
    nombreArchivo = ActiveSupport::Inflector.transliterate($objeto.titulo).to_s
    nombreArchivo = conteoString($conteo) + "-" + nombreArchivo.gsub(/[^a-z0-9\s]/i, "").gsub(" ", "-").downcase + ".xhtml"

    # Crea el archivo
    archivo = File.new(nombreArchivo, "w:UTF-8")
    archivo.puts xhtmlTemplateHead $lenguaje, $objeto.titulo, $rutaCSS, $epubType
    archivo.puts "        " + $objeto.encabezado
    $objeto.contenido.each do |linea|
        archivo.puts "        " + linea
    end
    archivo.puts $xhtmlTemplateFoot
    archivo.close

    # Para aumentar la numeración
    $conteo += 1
end

# Divide el archivo
archivoTodo.each do |linea|
    # Si se trata de un encabezado h1
    if linea =~ /<(.*?)h1(.*?)>(.*?)<\/(.*?)h1(.*?)>/i

        # Para no ignorar el contenido posterior aunque no se trate de un encabezado
        enEncabezado = true

        # Aumento del conteo de partes
        $parteArchivo += 1

        # De esta manera se detecta una nueva parte
        if $parteArchivoViejo < $parteArchivo
            creacion
            $parteArchivoViejo = $parteArchivo
        end

        # Obtención del título y el encabezado
        $objeto.titulo = linea.gsub(/<(.*?)>/, "").strip
        $objeto.encabezado = linea.gsub("H1", "h1").strip

        # Se limpia el conjunto con contenido
        $contenidoConjunto = $contenidoConjunto.clear
    # Si se trata de contenido después del primer encabezado
    elsif enEncabezado == true
        # Si es una línea que no tiene </body> o </html>
        if linea !~ /body>/i && linea !~ /html>/i
            $contenidoConjunto.push(linea.strip)

            # Si se trata de la última línea, se crea el archivo; por si el documento no cuenta con etiquetas de body o html
            if archivoTodo.eof? == true
                creacion
            end
        # Si se llega el fin del body o html, se crea el último archivo y se termina el loop
        else
            creacion
            break
        end
    end
end

puts "\nEl proceso ha terminado.".gray.bold
