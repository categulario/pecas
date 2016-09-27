#!/usr/bin/env ruby
# encoding: UTF-8
# coding: UTF-8

Encoding.default_internal = Encoding::UTF_8

### GENERALES ###

# Obtiene el tipo de sistema operativo; viene de: http://stackoverflow.com/questions/170956/how-can-i-find-which-operating-system-my-ruby-program-is-running-on
module OS
    def OS.windows?
        (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
    end
    def OS.mac?
        (/darwin/ =~ RUBY_PLATFORM) != nil
    end
    def OS.unix?
        !OS.windows?
    end
    def OS.linux?
        OS.unix? and not OS.mac?
    end
end

# Para colorear el texto; viene de: http://stackoverflow.com/questions/1489183/colorized-ruby-output
class String
    def black;          "\e[30m#{self}\e[0m" end
    def red;            "\e[31m#{self}\e[0m" end
    def green;          "\e[32m#{self}\e[0m" end
    def brown;          "\e[33m#{self}\e[0m" end
    def blue;           "\e[34m#{self}\e[0m" end
    def magenta;        "\e[35m#{self}\e[0m" end
    def cyan;           "\e[36m#{self}\e[0m" end
    def gray;           "\e[37m#{self}\e[0m" end

    def bg_black;       "\e[40m#{self}\e[0m" end
    def bg_red;         "\e[41m#{self}\e[0m" end
    def bg_green;       "\e[42m#{self}\e[0m" end
    def bg_brown;       "\e[43m#{self}\e[0m" end
    def bg_blue;        "\e[44m#{self}\e[0m" end
    def bg_magenta;     "\e[45m#{self}\e[0m" end
    def bg_cyan;        "\e[46m#{self}\e[0m" end
    def bg_gray;        "\e[47m#{self}\e[0m" end

    def bold;           "\e[1m#{self}\e[22m" end
    def italic;         "\e[3m#{self}\e[23m" end
    def underline;      "\e[4m#{self}\e[24m" end
    def blink;          "\e[5m#{self}\e[25m" end
    def reverse_color;  "\e[7m#{self}\e[27m" end
end

# Enmienda ciertos problemas con la línea de texto
def ArregloRuta (elemento)
    if elemento[-1] == ' '
        elemento = elemento[0...-1]
    end

    # Elimina caracteres conficlitos
    elementoFinal = elemento.gsub('\ ', ' ').gsub('\'', '')

    if OS.windows?
        # En Windows cuando hay rutas con espacios se agregan comillas dobles que se tiene que eliminar
        elementoFinal = elementoFinal.gsub('"', '')
    else
        # En UNIX pueden quedar diagonales de espace que también se ha de eliminar
        elementoFinal =  elementoFinal.gsub('\\', '')
    end

    # Se codifica para que no exista problemas con las tildes
    elementoFinal = elementoFinal.encode!(Encoding::UTF_8)

    return elementoFinal
end

### NOTES ###

# Elementos comunes
$divisor = '/'
$archivos = Array.new
$rutasRelativas = Array.new
$archivoCreado = "9999-notes.xhtml"
$lenguaje = "es"
$archivoNotas = ""
$archivoCSS = ""
$carpeta = ""
$separacionesCarpeta = 0
$conteo = 1
$mensajeFinal = "\nEl proceso ha terminado.".gray.bold

# Obtiene los argumentos necesarios
if ARGF.argv.length < 1
    puts "\nLa ruta de la carpeta con los archivos a referenciar es necesaria.".red.bold
    abort
elsif ARGF.argv.length == 1
    $carpeta = ARGF.argv[0]
else
    puts "\nSolo se permite un argumento, el de la ruta de la carpeta con los archivos a referenciar.".red.bold
    abort
end

# Busca la existencia de archivos xhtml, html o tex
def carpetaBusqueda
    if OS.windows?
        $carpeta = $carpeta.gsub('\\', '/')
    end

    $carpeta = ArregloRuta $carpeta
    $separacionesCarpeta = $carpeta.split($divisor).length

    # Se parte del supuesto de que no hay archivos xhtml, html o tex
    archivosExistentes = false
    $archivosExistentesHTML = false

    # Si dentro de los directorios hay un opf, entonces se supone que hay archivos para un EPUB
    Dir.glob($carpeta + $divisor + '**' + $divisor + '*.*') do |archivo|
        if File.extname(archivo) == ".xhtml" || File.extname(archivo) == ".html" || File.extname(archivo) == ".tex"

            # Se indica que si existen algún archivo xhtml, html o tex
            archivosExistentes = true

            # Se indica si existen algún archivo xhtml o html
            if File.extname(archivo) == ".xhtml" || File.extname(archivo) == ".html"
                $archivosExistentesHTML = true
            end

            archivo = ArregloRuta File.expand_path(archivo).to_s

            # Se agregan los archivos a un conjunto que servirá para verificar la cantidad de notas y para agregarlas
            $archivos.push(archivo)
        end
    end

    # Ofrece un resultado
    if archivosExistentes == false
        puts "\nAl parecer en la carpeta seleccionada no existen archivos xhtml, html o tex.".red.bold
        abort
    else
        puts "\nEste script añade las notas al pie a los archivos xhtml, html o tex.".gray.bold
    end
end

# Obtiene los archivos xhtml, html o tex
carpetaBusqueda

# Obtiene el archivo que contiene las notas al pie
def archivoNotasBusqueda
    puts "\nArrastra el archivo de texto que contiene las notas al pie.".blue
    $archivoNotas = $stdin.gets.chomp
    $archivoNotas = ArregloRuta $archivoNotas

    if $archivoNotas.split(".").last != "txt"
        puts "\nEl archivo indicado no tiene extensión .txt.".red.bold
        archivoNotasBusqueda
    end
end

archivoNotasBusqueda

puts "\nComparando cantidad de notas...".magenta.bold

# Cuenta la cantidad de notas al pie en el archivo de texto y va preparando las notas
$conteoTXT = 0
$notasTXT = Array.new
archivoTXT = File.open($archivoNotas, 'r:UTF-8')

archivoTXT.each do |linea|
    linea = linea.strip
    if linea != ""
        $conteoTXT = $conteoTXT + 1
        $notasTXT.push(linea)
    end
end

# Cuenta la cantidad de notas al pie en los archivos
$conteoArchivos = 0

$archivos.each do |archivo|
    archivo = File.open(archivo, 'r:UTF-8')

    archivo.each do |linea|
        palabras = linea.split

        palabras.each do |palabra|
            if palabra =~ /\(\(note\)\)/
                $conteoArchivos = $conteoArchivos + 1
            end
        end
    end
end

# Aborta si no hay coincidencia en el conteo
if $conteoTXT != $conteoArchivos
    puts "\nLa cantidad de notas al pie no coinciden.".red.bold
    puts "#{$conteoTXT} notas en el archivo de texto.".red
    puts "#{$conteoArchivos} notas en los archivos.".red
    abort
end

puts "\nAñadiendo referencias a los archivos...".magenta.bold

# Agrega la referencia a los archivos
$archivos.each do |archivo|
    separacionesArchivo = archivo.split($divisor).length - 1
    nivel = "..#{$divisor}"
    rutaDiferencia = separacionesArchivo - $separacionesCarpeta
    rutaArchivoCreado = (nivel * rutaDiferencia) + $archivoCreado
    lineas = Array.new

    # Abre el archivo para sustituir las referencias
    archivoAbrir = File.open(archivo, 'r:UTF-8')

    archivoAbrir.each do |linea|
        linea = linea.split
        palabras = Array.new

        # En cada línea busca palabra por palabra
        linea.each do |palabra|

            # Si la palabra tiene un «((note))», lo cambia por la nota correspondiente
            if palabra =~ /((note))/

                # La sustitución varía según si es un tex o no
                if File.extname(archivo) == ".tex"
                    palabra = palabra.gsub('((note))', "\\footnote{#{$notasTXT[$conteo - 1]}}")
                else
                    nota = "<sup class=\"n-note-sup\" id=\"n#{$conteo}\"><a href=\"#{rutaArchivoCreado}#n#{$conteo}\">[#{$conteo}]</a></sup>"
                    palabra = palabra.gsub('((note))', nota)
                end

                # Añade las rutas relativas a cada documento para el $archivoCreado
                $rutasRelativas.push(archivo.split($divisor)[$separacionesCarpeta..(archivo.length - 1)].join($divisor))

                $conteo = $conteo + 1
            end

            # Agrega la palabra modificada para crear una nueva línea
            palabras.push(palabra)
        end

        # Crea la nueva línea
        lineas.push(palabras.join(" "))
    end

    # Abre el archivo para guardar los cambios
    archivoModificar = File.open(archivo, 'w:UTF-8')

    # Sustituye las antiguas líneas por las nuevas que ya tienen la nota
    lineas.each do |linea|
        archivoModificar.puts linea
    end

    # Cierra el archivo
    archivoModificar.close
end

# Finaliza si solo se trata de archivos tex
if $archivosExistentesHTML != true
    puts $mensajeFinal
    abort
else
    archivoExistente = $carpeta + $divisor + $archivoCreado
    archivoExistenteBool = File.exist?(archivoExistente)
    if archivoExistenteBool == false
        puts "\nCreando archivo 9999-notes.xhtml...".magenta.bold
    else
        puts "\nRecreando archivo 9999-notes.xhtml...".magenta.bold
    end
end

# Se resetea el contador
$conteo = 1

# Va a la carpeta
Dir.chdir($carpeta)

# Obtiene el archivo CSS
$rutaCSS = ""

def archivoCSSBusqueda
    puts "\nArrastra el archivo CSS si existe ".blue + "[dejar en blanco para ignorar]:".bold
    $archivoCSS = $stdin.gets.chomp
    $archivoCSS = ArregloRuta $archivoCSS
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

# Crea el archivo $archivoCreado
archivoNotes = File.new("#{$archivoCreado}", "w:UTF-8")

archivoNotes.puts "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
archivoNotes.puts "<!DOCTYPE html>"
archivoNotes.puts "<html xmlns=\"http://www.w3.org/1999/xhtml\" xmlns:epub=\"http://www.idpf.org/2007/ops\" xml:lang=\"#{$lenguaje}\" lang=\"#{$lenguaje}\">"
archivoNotes.puts "    <head>"
archivoNotes.puts "        <meta charset=\"UTF-8\" />"
archivoNotes.puts "        <title>Notas</title>"

# Añade la ruta al CSS si se indicó el archivo
if $rutaCSS != ""
    archivoNotes.puts "        <link rel=\"stylesheet\" href=\"#{$rutaCSS}\" />"
end

archivoNotes.puts "    </head>"
archivoNotes.puts "    <body epub:type=\"footnotes\">"
archivoNotes.puts "        <h1>Notas al pie</h1>"

# Añade cada una de las notas
$notasTXT.each do |linea|
    archivoNotes.puts "        <p class=\"n-note-p\" id=\"n#{$conteo}\"><a class=\"n-note-a\" href=\"#{$rutasRelativas[$conteo - 1]}#n#{$conteo}\">[#{$conteo}]</a> #{linea}</p>"

    $conteo = $conteo + 1;
end

archivoNotes.puts "    </body>"
archivoNotes.puts "</html>"

archivoNotes.close

puts $mensajeFinal
