#!/usr/bin/env ruby
# encoding: UTF-8
# coding: UTF-8

require 'fileutils'

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

### CHANGER ###

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

$rutaConEpub = ArregloRuta $rutaEpub

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
if OS.windows?
    $rutaEpubArray = $rutaConEpub.split('\\')
else
    $rutaEpubArray = $rutaConEpub.split($divisor)
end

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

# Por defecto usa el comando de las terminales UNIX
unzip = 'unzip'

# Reajustes para Windows
if OS.windows?
    $rutaConEpub = $rutaConEpub.gsub('/', '\\')
    puts "\nArrastra el unzip.exe".blue
    unzip = $stdin.gets.chomp
end

puts "\nDescomprimiendo EPUB...".magenta.bold

system ("#{unzip} -qq #{$comillas}#{$rutaConEpub}#{$comillas} -d #{$directorio}")

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
            prefijo = 'rendition: http://www.idpf.org/vocab/rendition/# ' + prefijo
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
$rutaEPUB = "../#{$epub}-#{$version}.epub"

# Por defecto se usa el comando de las terminales UNIX
zip = 'zip'

# Reajustes para Windows
if OS.windows?
    puts "\nArrastra el zip.exe".blue
    zip = $stdin.gets.chomp
end

espacio = ' '

# Elimina el EPUB previo
Dir.glob($carpeta + $divisor + '**') do |archivo|
    if File.basename(archivo) == "#{$epub}-#{$version}.epub"
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
puts "\n#{$epub}-#{$version}.epub creado en: #{$carpeta}".magenta.bold
puts "\nEl proceso ha terminado.".gray.bold
