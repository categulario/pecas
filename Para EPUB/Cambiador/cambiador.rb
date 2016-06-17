#!/usr/bin/env ruby
# encoding: UTF-8
# coding: UTF-8

Encoding.default_internal = Encoding::UTF_8

# Obtiene los argumentos necesarios
if ARGF.argv.length <= 1
    puts "Argumentos insuficientes."
    abort
elsif ARGF.argv.length == 2
    # El primer argumento tiene que ser la ruta al EPUB
    if File.extname(ARGF.argv[0]) != '.epub'
        puts "El primer argumento tiene que ser la ruta al EPUB."
        abort
    end
    # El segundo argumento tiene que ser la versión disponible
    if ARGF.argv[1] != '2.0.1' and ARGF.argv[1] != '3.0.0' and ARGF.argv[1] != '3.0.1'
        puts "Las versiones disponibles son: 2.0.1, 3.0.0 o 3.0.1."
        abort
    end
else
    puts "Solo se permiten dos argumentos: ruta al EPUB y nueva versión deseada."
    abort
end

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

$rutaEpub = ARGF.argv[0]
$version = ARGF.argv[1]

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

$rutaConEpub = ArregloRuta $rutaEpub

# Elementos comunes
$divisor = '/'
$carpeta = ''
$epub = ''
$directorio = '.epub-cambiador'

# Obtiene la ruta del EPUB y su nombre
$rutaEpubArray = $rutaConEpub.split($divisor)

$rutaEpubArray.each do |c|
    if c != $rutaEpubArray.last
        $carpeta += c.to_s + $divisor
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
    puts "\nArrastra el unzip.exe"
    unzip = $stdin.gets.chomp
end

puts "\nDescomprimiendo EPUB..."

system ("#{unzip} -qq '#{$rutaConEpub}' -d #{$directorio}")

# Elimina la carpeta temporal
def removerCarpeta
    # Por defecto se usa el comando de las terminales UNIX
    rm = "rm -rf #{$carpeta + $directorio}"

    # Reajustes para Windows
    if OS.windows?
        $rutaEPUB = $rutaEPUB.gsub('/', '\\')
        rm = "del #{$rutaEPUB}"
    end

    system (rm)
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

        # Especifica la versión actual
        if $versionActual == '3.0'
            if linea =~ /rendition/
                $versionActual = '3.0.0'
            else
                $versionActual = '3.0.1'
            end
        else
            $versionActual = '2.0.1'
        end

        # Aborta si se intenta cambiar a la misma versión
        if $versionActual == $version
            if $versionActual == '2.0.1'
                puts "\nEste EPUB es versión 2, solo se puede actualizar a versión 3.0.0 o 3.0.1."
            else
                puts "\nEste EPUB ya es versión #{$versionActual}"
            end
            removerCarpeta
            abort
        end
    end

    $opfContenido.push(linea)
end

puts "\nCambiando versión de #{$versionActual} a #{$version}."

# Cambia las versiones en el OPF
$opfContenido.each do |linea|
    if $versionActual != '2.0.1'
        if $version != '2.0.1'
            if linea =~ /<(\s*)package/
                # Obtención del viejo prefijo
                prefijo = linea.match(/prefix=[\"\']([^"]*)[\"\']/)
                prefijo = prefijo[1].to_s

                # Cambios según la versión actual
                if $versionActual == '3.0.1'
                    prefijo = 'rendition: http://www.idpf.org/vocab/rendition/# ' + prefijo
                else
                    prefijo = prefijo.gsub(/rendition:(.*)#/, '').strip
                end

                # Nuevo prefijo
                nuevaLineaPrefijo = linea.to_s.gsub(/prefix=[\"\']([^"]*)[\"\']/, 'prefix="' + prefijo + '"')

                # Localización en el conjunto de la linea donde está el prefijo
                hashPrefijo = Hash[$opfContenido.map.with_index.to_a]

                # Cambio de línea
                $opfContenido[hashPrefijo[linea]] = nuevaLineaPrefijo
            end
        else
            if linea =~ /<(\s*)package/
                # Cambio en la linea
                lineaPackage = linea.to_s.gsub(/prefix=[\"\']([^"]*)[\"\']/, '').gsub(/xml:lang=[\"\']([^"]*)[\"\']/, '').gsub(/version=[\"\']([^"]*)[\"\']/, 'version="2.0"')

                # Localización en el conjunto de la linea donde está el prefijo
                hashPackage = Hash[$opfContenido.map.with_index.to_a]

                # Cambio de línea
                $opfContenido[hashPackage[linea]] = lineaPackage
            end
        end
    else
        puts "Cambio de 2.0.1 a 3"
    end
end

# Cambia el OPF para meter los cambios
opf = File.open($opfRuta, 'w:UTF-8')

$opfContenido.each do |linea|
    opf.puts linea
end

opf.close

# removerCarpeta

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
rm = "rm -rf #{$rutaEPUB}"
zip = 'zip'

# Reajustes para Windows
if OS.windows?
    $rutaEPUB = $rutaEPUB.gsub('/', '\\')
    rm = "del #{$rutaEPUB}"
    puts "\nArrastra el zip.exe"
    zip = $stdin.gets.chomp
end

espacio = ' '

# Elimina el EPUB previo
Dir.glob($carpeta + $divisor + '**') do |archivo|
    if File.basename(archivo) == "#{$epub}-#{$version}.epub"
        espacio = ' nuevo '
        puts "\nEliminando EPUB versión #{$version} previo..."
        system (rm)
    end
end

puts "\nCreando#{espacio}EPUB versión #{$version}..."

# Crea el EPUB
system ("#{zip} '#{$rutaEPUB}' -X mimetype")
system ("#{zip} '#{$rutaEPUB}' -r #{$primerosArchivos[-2]} #{$primerosArchivos[-1]} -x \*.DS_Store \*._*")

removerCarpeta

# Finaliza la creación
puts "\n#{$epub}-#{$version}.epub creado en: #{$carpeta}"
puts = "\nEl proceso ha terminado."
