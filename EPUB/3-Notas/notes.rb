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
$note = "ººnoteºº"
$noteRegEx = /ººnoteºº/
$archivos = Array.new
$rutasRelativas = Array.new
$archivoCreado = "9999-notes.xhtml"
$lenguaje = "es"
$archivoNotas = ""
$archivoCSS = ""
$carpeta = ""
$separacionesCarpeta = 0
$conteo = 1
$conteoId = 1
$mensajeFinal = "\nEl proceso ha terminado.".gray.bold

# Obtiene los argumentos necesarios
if ARGF.argv.length < 1
    puts "\nLa ruta al archivo de texto que contiene las notas al pie es necesaria.".red.bold
    abort
elsif ARGF.argv.length == 1 || ARGF.argv.length == 2
    if ARGF.argv.length == 1
        $carpeta = Dir.pwd
        $archivoNotas = ARGF.argv[0]
    else
        $carpeta = ARGF.argv[0]
        $archivoNotas = ARGF.argv[1]
    end

    $archivoNotas = ArregloRuta $archivoNotas

    if $archivoNotas.split(".").last != "txt"
        puts "\nEl archivo indicado no tiene extensión .txt.".red.bold
        abort
    end
else
    puts "\nNo se permiten más de dos argumentos.".red.bold
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
            if palabra =~ $noteRegEx
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

# Preguntas relativas al modo de crear las notas
def pregunta (texto, booleano)
    puts "\n" + texto.blue + " [s/N]:"
    respuesta = $stdin.gets.chomp.downcase
    if (respuesta == "" || respuesta == "n")
        booleano = false;
        return booleano
    elsif (respuesta == "s")
        booleano = true;
        return booleano
    else
        pregunta texto, booleano
    end
end

# Obtiene el booleano para determinar si se reinicia la numeración
preguntaReinicio = "¿Reiniciar la numeración en cada sección?"
$boolReinicio = pregunta preguntaReinicio, $boolReinicio

# En TeX se agregan las notas en los archivos, pero en HTML o XHTML existe la posibilidad de añadirlos al mismo documento o crear uno nuevo
if $archivosExistentesHTML == true
    # Obtiene el booleano para determinar el lugar de las notas
    preguntaColocacion = "¿Colocar las notas en el documento de cada sección?"
    $boolColocacion = pregunta preguntaColocacion, $boolColocacion
end

puts "\nAñadiendo referencias a los archivos...".magenta.bold

# Un conjunto para utilizarlo al colocar las notas con la numeración correcta
$conteoFinal = Array.new

# Agrega la referencia a los archivos
$archivos.each do |archivo|
    separacionesArchivo = archivo.split($divisor).length - 1
    nivel = "..#{$divisor}"
    rutaDiferencia = separacionesArchivo - $separacionesCarpeta
    rutaArchivoCreado = (nivel * rutaDiferencia) + $archivoCreado
    lineas = Array.new

    # Abre el archivo para sustituir las referencias
    archivoAbrir = File.open(archivo, 'r:UTF-8')

    if $boolReinicio
        $conteo = 1
    end

    archivoAbrir.each do |linea|
        linea = linea.split
        palabras = Array.new

        # En cada línea busca palabra por palabra
        linea.each do |palabra|

            # Si la palabra tiene un «ººnoteºº», lo cambia por la nota correspondiente
            if palabra =~ $noteRegEx

                # Añade el conteo final
                $conteoFinal.push($conteo)

                # La sustitución varía según si es un tex o no
                if File.extname(archivo) == ".tex"
                    palabra = palabra.gsub($note, "\\footnote[#{$conteo}]{#{$notasTXT[$conteoId - 1]}}")
                else
                    # Se modifica levemente el id del número de nota según se coloque adentro del mismo archivo o no
                    if $boolColocacion
                        nota = "<sup class=\"n-note-sup\" id=\"c-n#{$conteoId}\"><a href=\"#{rutaArchivoCreado}#n#{$conteoId}\">[#{$conteo}]</a></sup>"
                    else
                        nota = "<sup class=\"n-note-sup\" id=\"n#{$conteoId}\"><a href=\"#{rutaArchivoCreado}#n#{$conteoId}\">[#{$conteo}]</a></sup>"
                    end

                    palabra = palabra.gsub($note, nota)
                end

                # Añade las rutas relativas a cada documento para el $archivoCreado
                $rutasRelativas.push(archivo.split($divisor)[$separacionesCarpeta..(archivo.length - 1)].join($divisor))

                $conteo = $conteo + 1
                $conteoId = $conteoId + 1
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
    if $boolColocacion
        puts "\nColocando notas en cada uno de los archivos...".magenta.bold
    else
        archivoExistente = $carpeta + $divisor + $archivoCreado
        archivoExistenteBool = File.exist?(archivoExistente)
        if archivoExistenteBool == false
            puts "\nCreando archivo 9999-notes.xhtml...".magenta.bold
        else
            puts "\nRecreando archivo 9999-notes.xhtml...".magenta.bold
        end
    end
end

# Va a la carpeta
Dir.chdir($carpeta)

# Se resetea el contador
$conteo = 0
$conteoId = 1

# Para añadir las notas a los archivos o en un nuevo documento
def adicion (archivoNotes)
    # Añade cada una de las notas
    $notasTXT.each do |linea|
        $palabrasCorregidas = Array.new

        # Si se colocan dentro de cada sección, evita que se ingresen notas de otras secciones
        if $boolColocacion
            # Compara que el archivo donde van sea el mismo a donde se dirige, si no, se termina la colocación
            if $archivoParaNotas != $rutasRelativas[$conteoId - 1]
                break
            end
        end

        # Compone la línea de la nota
        def arreglo lugar
            palabras = lugar.split

            # Si se trata de la primera o última palabra, se elimina la etiqueta de párrafo
            palabras.each do |palabra|
                if palabra == palabras.first
                    palabra = palabra.gsub("<p>", "")
                elsif palabra == palabras.last
                    palabra = palabra.gsub(/<\/p>+$/, "")
                end

                # Se agrega al nuevo conjunto
                $palabrasCorregidas.push(palabra)
            end

            # El conjunto se convierte en una nueva línea para añadirle lo demás requerido para el archivo de las notas
            $lineaCorregida = $palabrasCorregidas.join(" ")
        end

        # Añade el nombre del capítulo si se reinicia la numeración y se está creando un nuevo archivo
        if $boolReinicio && $conteoFinal[$conteo] == 1 && !$boolColocacion
            archivoTitulo = File.open($rutasRelativas[$conteoId - 1], 'r:UTF-8')
            titulo = ""
            h1 = ""
            h2 = ""
            boolH1 = false

            archivoTitulo.each do |linea|
                # Busca por el texto de las etiquetas title o h1
                if linea =~ /<title>/
                    titulo = linea.gsub("<title>", "").gsub("</title>", "")
                elsif linea =~ /<h1(.*?)>/
                    h1 = linea.gsub(/<h1(.*?)>/, "").gsub("</h1>", "")
                    boolH1 = true
                    # Se rompe para solo contemplar la primera etiqueta h1 que aparezca
                    break
                end
            end

            archivoTitulo.close

            # Si se detecto una etiqueta h1, ese es el título por defecto, de lo contrario es el contenido de la etiqueta title
            if boolH1
                h2 = h1
            else
                h2 = titulo
            end

            archivoNotes.puts "        <h2 class=\"n-note-h2\">" + h2.gsub(/\n/, "") + "</h2>"
        end

        # Se modifica levemente el id del número de nota según se coloque adentro del mismo archivo o no
        if $boolColocacion
            arreglo $notasTXT[$conteoId - 1]
            archivoNotes.puts "        <p class=\"n-note-p\" id=\"n#{$conteoId}\"><a class=\"n-note-a\" href=\"#{$rutasRelativas[$conteoId - 1]}#c-n#{$conteoId}\">[#{$conteoFinal[$conteo]}]</a> #{$lineaCorregida}</p>"
        else
            arreglo linea
            archivoNotes.puts "        <p class=\"n-note-p\" id=\"n#{$conteoId}\"><a class=\"n-note-a\" href=\"#{$rutasRelativas[$conteoId - 1]}#n#{$conteoId}\">[#{$conteoFinal[$conteo]}]</a> #{$lineaCorregida}</p>"
        end

        $conteo = $conteo + 1
        $conteoId = $conteoId + 1
    end
end

# Si se quieren en el mismo archivo
if $boolColocacion
    indice = 0
    rutaRelativaVieja = ""

    def colocacion archivo
        lineas = Array.new

        # Ayuda a detectar el archivo donde se incluirán las notas
        $archivoParaNotas = archivo

        # Busca la última línea de cada documento con notas
        archivoNotes = File.open(archivo, "r:UTF-8")
        archivoNotes.each do |linea|
            # Si llega al final del body, se termina la búsqueda
            if linea =~ /<\/body>/
                break
            # Cada línea se va constituyendo como la línea final hasta que se llega a la etiqueta de cierre del body
            else
                lineas.push(linea)
            end
        end
        archivoNotes.close

        # Añade las notas
        archivoNotes = File.open(archivo, "w:UTF-8")

        # Sustituye las antiguas líneas por las nuevas
        lineas.each do |linea|

            # Cambia a la ruta correcta porque por defecto manda al archivo «9999-notes.xhtml» que en este caso es inexistente
            if linea =~ /9999-notes.xhtml/
                linea = linea.gsub("9999-notes.xhtml", archivo)
            end

            archivoNotes.puts linea
        end

        # Se añade una barra horizontal como divisor entre el contenido y las notas
        archivoNotes.puts "        <hr class=\"n-note-hr\" />"

        # Añade las notas al final
        adicion archivoNotes

        # Últimos elementos necesarios para el archivo
        archivoNotes.puts "    </body>"
        archivoNotes.puts "</html>"

        archivoNotes.close
    end

    # Inicia la colocación solo cuando se detecta la primera nota de cada archivo
    $rutasRelativas.each do |linea|
        # En el primer caso siempre es la primera nota
        if indice == 0
            rutaRelativaVieja = linea
            colocacion linea
        else
            # Cuando la ruta al archivo cambia, quiere decir que es la primera nota
            if rutaRelativaVieja != linea
                rutaRelativaVieja = linea
                colocacion linea
            end
        end

        indice = indice + 1
    end
# Si se quiere un nuevo archivo
else
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

    # Añade las notas
    adicion archivoNotes

    archivoNotes.puts "    </body>"
    archivoNotes.puts "</html>"

    archivoNotes.close
end

puts $mensajeFinal
