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

### CREATOR ###

# Elementos generales
$divisor = '/'
$comillas = '\''
$carpetaPadre = "EPUB-CREATOR"
$carpetaMeta = "META-INF"
$carpetaOPS = "OPS"

if OS.windows?
    $comillas = ''
end

# Obtiene los argumentos necesarios
if ARGF.argv.length < 1
    puts "\nLa ruta de la carpeta destino es necesaria.".red.bold
    abort
elsif ARGF.argv.length == 1
    $carpeta = ARGF.argv[0]
    $carpeta = ArregloRuta $carpeta
else
    puts "\nSolo se permite un argumento, el de la ruta de la carpeta destino.".red.bold
    abort
end

# Se va a la carpeta para crear los archivos
Dir.chdir($carpeta)

# Crea la carpeta del EPUB si no existe previamente
Dir.glob($carpeta + $divisor + '**') do |archivo|
    if File.exists?($carpetaPadre) == true
        puts "\nYa existe una carpeta con el nombre #{$carpetaPadre}.".red.bold
        abort
    else
        puts "\nCreando carpeta del EPUB con el nombre #{$carpetaPadre}...".magenta.bold
        # Crea la carpeta padre
        Dir.mkdir $carpetaPadre

        # Se mete a la carpeta padre
        $carpeta = $carpeta + $divisor + $carpetaPadre
        Dir.chdir($carpeta)

        break
    end
end

# Crea el mimetype
mimetype = File.new("mimetype", "w:UTF-8")
mimetype.puts "application/epub+zip"
mimetype.close

# Crea el META-INF
Dir.mkdir $carpetaMeta
Dir.chdir($carpeta + $divisor + $carpetaMeta)
container = File.new("container.xml", "w:UTF-8")
container.puts "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
container.puts ""
container.puts "<container version=\"1.0\" xmlns=\"urn:oasis:names:tc:opendocument:xmlns:container\">"
container.puts "	<rootfiles>"
container.puts "		<rootfile full-path=\"OPS/content.opf\" media-type=\"application/oebps-package+xml\"/>"
container.puts "	</rootfiles>"
container.puts "</container>"
container.close
Dir.chdir($carpeta)

# Crea el OPS
Dir.mkdir $carpetaOPS
$carpeta = $carpeta + $divisor + $carpetaOPS
Dir.chdir($carpeta)
