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

### FOOTNOTE ###

# Obtiene los argumentos necesarios
if ARGF.argv.length < 1
    puts "La ruta de la carpeta con los archivos a referenciar es necesaria.".red.bold
    abort
elsif ARGF.argv.length == 1
    $carpeta = ARGF.argv[0]
else
    puts "Solo se permite un argumento, el de la ruta de la carpeta con los archivos a referenciar.".red.bold
    abort
end

# Elementos comunes
$divisor = '/'
$archivos = Array.new
$archivoNotas = ""

# Busca la existencia de archivos xhtml, html o tex
def carpetaBusqueda
    if OS.windows?
        $carpeta = $carpeta.gsub('\\', '/')
    end

    $carpeta = ArregloRuta $carpeta

    # Se parte del supuesto de que no hay archivos xhtml, html o tex
    archivosExistentes = false

    # Si dentro de los directorios hay un opf, entonces se supone que hay archivos para un EPUB
    Dir.glob($carpeta + $divisor + '**' + $divisor + '*.*') do |archivo|
        if File.extname(archivo) == ".xhtml" || File.extname(archivo) == ".html" || File.extname(archivo) == ".tex"

            # Se indica que sí existen algún archivo xhtml, html o tex
            archivosExistentes = true

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

# Cuenta la cantidad de notas al pie en el archivo de texto y va preparando las notas
$conteoTXT = 0
$notasTXT = Array.new
archivoTXT = File.open($archivoNotas, 'r:UTF-8')

archivoTXT.each do |linea|
    linea = linea.strip
    if linea != ""
        $conteoTXT = $conteoTXT + 1
        $notasTXT.push(linea + "</p>")
    end
end

# Cuenta la cantidad de notas al pie en los archivos
$conteoArchivos = 0

$archivos.each do |archivo|
    archivo = File.open(archivo, 'r:UTF-8')

    archivo.each do |linea|
        palabras = linea.split

        palabras.each do |palabra|
            if palabra =~ /\\footnote{}/
                $conteoArchivos = $conteoArchivos + 1
            end
        end
    end
end

if $conteoTXT != $conteoArchivos
    puts "\nLa ruta de la carpeta con los archivos a referenciar es necesaria.".red.bold
    abort
end
