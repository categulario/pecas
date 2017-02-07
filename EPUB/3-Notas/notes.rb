#!/usr/bin/env ruby
# encoding: UTF-8
# coding: UTF-8

Encoding.default_internal = Encoding::UTF_8

# Funciones y módulos comunes a todas las herramientas
require File.dirname(__FILE__) + "/../../otros/secundarios/general.rb"
require File.dirname(__FILE__) + "/../../otros/secundarios/lang.rb"
require File.dirname(__FILE__) + "/../../otros/secundarios/xhtml-template.rb"

# Variables
$divisor = '/'
$note = "ººnoteºº"
$noteRegEx = /ººnote(.*?)ºº/
$archivos = Array.new
$rutasRelativas = Array.new
$archivoCreado = "9999-notes.xhtml"
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

    $archivoNotas = arregloRuta $archivoNotas

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

    $carpeta = arregloRuta $carpeta
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

            archivo = arregloRuta File.expand_path(archivo).to_s

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

    # Se reinicia el contador si así se ha indicado
    if $boolReinicio
        $conteo = 1
    end

    archivoAbrir.each do |linea|
        inicio = linea.match(/(^\s+)/)
        linea = linea.split
        palabras = Array.new

        # En cada línea busca palabra por palabra
        linea.each do |palabra|

            # Si la palabra tiene un «ººnoteºº», lo cambia por la nota correspondiente
            if palabra =~ $noteRegEx

                # El superíndice varía según si existe un texto personalizado o no
                if palabra =~ /#{$note}/
                    $sup = $conteo
                else
                    $sup = palabra.gsub(/(.*?)ººnote\[/, "").gsub(/]ºº(.*)/, "")
                end

                # Añade el conteo final
                $conteoFinal.push($sup)

                # Aquí irá el texto de la nota final
                nota = ""

                # La sustitución varía según si es un tex o no
                if File.extname(archivo) == ".tex"
                    notaAdentro = $notasTXT[$conteoId - 1]

                    # Elimina etiquetas de párrafo de HTML por si hay un despiste y da una advertencia
                    if notaAdentro =~ /<("[^"]*"|'[^']*'|[^'">])*>/
                        notaAdentro = notaAdentro.gsub(/<\/p>(.*?)<p(.*?)>/, "\\newline\\indent ").gsub(/<p(.*?)>/, "").gsub("</p>", "")
                        puts "\nADVERTENCIA: se han detectado etiquetas HTML en la nota «#{$sup}» para #{archivo.split($divisor).last}."
                    end

                    # En el caso de ser un superíndice numérico
                    if $sup.is_a? Numeric
                        # Si se reinicia la numeración cada sección, se agrega manualmente el número de nota
                        if $boolReinicio
                            nota = "\\footnote[#{$sup}]{#{notaAdentro}}"
                        else
                            nota = "\\footnote{#{notaAdentro}}"
                        end
                    # En el caso de ser un superíndice personalizado
                    else
                        nota = "\\let\\svthefootnote\\thefootnote\\let\\thefootnote\\relax\\textsuperscript{#{$sup}}\\footnote{\\textsuperscript{#{$sup}} #{notaAdentro}}\\addtocounter{footnote}{-1}\\let\\thefootnote\\svthefootnote"
                    end
                else
                    # Se modifica levemente el id del número de nota según se coloque adentro del mismo archivo o no
                    if $boolColocacion
                        nota = "<sup class=\"n-note-sup\" id=\"c-n#{$conteoId}\"><a href=\"#{rutaArchivoCreado}#n#{$conteoId}\">[#{$sup}]</a></sup>"
                    else
                        nota = "<sup class=\"n-note-sup\" id=\"n#{$conteoId}\"><a href=\"#{rutaArchivoCreado}#n#{$conteoId}\">[#{$sup}]</a></sup>"
                    end
                end

                # Realiza el cambio en la palabra
                palabra = palabra.gsub($noteRegEx, nota)

                # Añade las rutas relativas a cada documento para el $archivoCreado
                $rutasRelativas.push(archivo.split($divisor)[$separacionesCarpeta..(archivo.length - 1)].join($divisor))

                # Solo aumenta cuando el superíndice es numérico
                if $sup.is_a? Numeric
                    $conteo = $conteo + 1
                end

                # Siempre aumenta porque los id siempre son numéricos
                $conteoId = $conteoId + 1
            end

            # Agrega la palabra modificada para crear una nueva línea
            palabras.push(palabra)
        end

        # Crea la nueva línea donde al inicio se respeta el espacio que tenía previamente
        lineas.push(inicio.to_s + palabras.join(" "))
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
        if $boolReinicio && !$boolColocacion && $rutasRelativas[$conteo] != $rutaVieja
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

            # Así evita que se ejecute cuando se trata de la misma sección
            $rutaVieja = $rutasRelativas[$conteo]
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

    # Crea el archivo $archivoCreado
    archivoNotes = File.new("#{$archivoCreado}", "w:UTF-8")
	archivoNotes.puts xhtmlTemplateHead "Notas", $rutaCSS, "footnotes"
    archivoNotes.puts "        <h1>Notas</h1>"

    # Ayuda a detectar si existe un cambio de ruta
    $rutaVieja = $rutasRelativas.first

    # Añade las notas
    adicion archivoNotes

    archivoNotes.puts $xhtmlTemplateFoot

    archivoNotes.close
end

puts $mensajeFinal
