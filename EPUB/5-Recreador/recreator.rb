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

### RECREATOR ###

# Obtiene los argumentos necesarios
if ARGF.argv.length < 1
    $carpeta = Dir.pwd
elsif ARGF.argv.length == 1
    $carpeta = ARGF.argv[0]
else
    puts "\nSolo se permite un argumento, el de la ruta de la carpeta para el EPUB.".red.bold
    abort
end

# Elementos comunes de lo que se imprime
$blanco = ' [dejar en blanco para terminar]:'.bold
$necesario = ' [campo necesario]:'.bold

# Elemento común para crear los archivos
$divisor = '/'
$primerosArchivos = Array.new
$comillas = '\''

if OS.windows?
    $comillas = ''
end

# Ayuda a crear el uid del libro y elementos de los tocs
$titulo = ''
identificadorLibro = ''
$creador = ''
$lenguaje = ''

# Identifica el nav
$nav = ''

# Determina si en la carpeta hay un EPUB
def carpetaBusqueda
    if OS.windows?
        $carpeta = $carpeta.gsub('\\', '/')
    end

    $carpeta = ArregloRuta $carpeta

    # Se parte del supuesto de que la carpeta no es para un EPUB
    epub = false

    # Si dentro de los directorios hay un opf, entonces se supone que hay archivos para un EPUB
    Dir.glob($carpeta + $divisor + '**') do |archivo|
        if File.basename(archivo) == "mimetype"
            epub = true
        else
            # Sirve para la creación del EPUB
            $primerosArchivos.push(File.basename(archivo))
        end
    end

    # Ofrece un resultado
    if epub == false
        puts "\nAl parecer en la carpeta seleccionada no es proyecto para un EPUB.".red.bold
        abort
    else
        puts "\nEste script recrea los archivos opf, ncx y nav.".gray.bold
        puts "Al finalizar también creará o modificará el archivo EPUB.".gray.bold
    end
end

# Obtiene la carpeta de los archivos del EPUB
carpetaBusqueda

# Se obtiene la ruta para el EPUB
ruta = $carpeta.split($divisor)
rutaPadre = ''
ruta.each do |parte|
    if parte != ruta.last
        if parte != ruta.first
            rutaPadre += $divisor + parte
        else
            rutaPadre += parte
        end
    end
end

rutaPadre = ArregloRuta rutaPadre

# Verifica si existe un archivo oculto de metadatos
Dir.chdir($carpeta)

metadatosPreexistentes = false
$metadatoPreexistenteNombre = ".recreator-metadata"

Dir.glob($carpeta + $divisor + '.*') do |archivo|
    if File.basename(archivo) == $metadatoPreexistenteNombre
        metadatosPreexistentes = true
    end
end

# Ayuda para la creación u obtención de los metadatos
$metadatosInicial = Array.new
$archivosNoLineales = Array.new
$archivosNoToc = Array.new
$portada = ''

# Crea un array para definir los archivos metadatos
def Metadatos (texto, dc)
    puts texto.blue + $necesario
    metadato = $stdin.gets.chomp
    coletilla = "@" + dc
    if metadato != ""
        $metadatosInicial.push(metadato + coletilla)
    else
        Metadatos texto, dc
    end
end

# Obtiene todos los metadatos
def metadatosTodo

    # Obtiene los metadatos
    Metadatos "\nTítulo", "dc:title"
    Metadatos "\nNombre del autor o editor principal " + "(ejemplo: Apellido, Nombre)".bold, "dc:creator"
    Metadatos "\nEditorial", "dc:publisher"
    Metadatos "\nSinopsis", "dc:description"
    Metadatos "\nTema " + "(ejemplo: Ficción, Novela)".bold, "dc:subject"
    Metadatos "\nLenguaje " + "(ejemplo: es)".bold, "dc:language"
    Metadatos "\nVersión " + "(ejemplo: 1.0.0)".bold, "dc:identifier"

    # Asigna el nombre de la portada para ponerle su atributo
    puts "\nNombre de la portada ".blue + "(ejemplo: portada.jpg)".blue.bold + $blanco
    $portada = $stdin.gets.chomp.strip

    if $portada == ''
        $portada = ' '
    end

    # Crea un array para definir los archivos XHTML ocultos
    def noMostrar (archivosConjunto)
        puts "\nNombre del archivo XHTML".brown + $blanco
        archivoOculto = $stdin.gets.chomp
        if archivoOculto != ""
            archivoOculto = archivoOculto.split(".")[0].strip
            archivosConjunto.push(archivoOculto)
            noMostrar archivosConjunto
        end
    end

    # Determina si es necesario definir archivos ocultos
    def noMostrarRespuesta (archivosConjunto, texto)
        puts "\n" + texto.blue + " [s/N]:"
        respuesta = $stdin.gets.chomp.downcase
        if (respuesta != "")
            if (respuesta != "n")
                if (respuesta == "s")
                    noMostrar archivosConjunto
                else
                    noMostrarRespuesta archivosConjunto, texto
                end
            end
        end
    end

    # Obtiene los archivos ocultos
    noMostrarRespuesta $archivosNoLineales, "¿Existen archivos XHTML que no se desean mostrar en la tabla de contenidos ni en la espina?"
    noMostrarRespuesta $archivosNoToc, "¿Existen archivos XHTML que no se desean mostrar en la tabla de contenidos?"

    # Obtiene el nombre del nav
    def ElementosNombre (elemento, porDefecto)
        elemento = porDefecto
        elementos = porDefecto.split(".")
        elementoNombre = elementos[0]
        extension = elementos[1]

        puts "\nIndica el nombre del ".blue + elementoNombre.blue + " [".bold + porDefecto.bold + " por defecto]:".bold
        elementoPosible = $stdin.gets.chomp.strip

        if elementoPosible.gsub(' ', '') == ''
            return elemento
        else
            if elementoPosible.split(".")[-1] == extension
                elemento = elementoPosible
                return elemento
            else
                puts "\nNombre no válido.".red.bold
                ElementosNombre elemento, porDefecto
            end
        end
    end

    $nav = ElementosNombre $nav, 'nav.xhtml'

    # Ayuda a la creación u obtención de metadatos
    $archivosNoLineales.push(' ')
    $archivosNoToc.push(' ')

    # Crea el archivo oculto con metadatos
    archivoMetadatos = File.new(".recreator-metadata", "w:UTF-8")

    $metadatosInicial.each do |mI|
        archivoMetadatos.puts "_M_" + mI
    end

    $archivosNoLineales.each do |aNl|
        archivoMetadatos.puts "_O_" + aNl
    end

    $archivosNoToc.each do |aNt|
        archivoMetadatos.puts "_T_" + aNt
    end

    archivoMetadatos.puts "_P_" + $portada.to_s
    archivoMetadatos.puts "_N_" + $nav.to_s

    archivoMetadatos.close
end

# Continúa con la petición de información adicional
puts "\nResponde lo siguiente.".blink

# Si existen metadatos
if metadatosPreexistentes == true
    $respuestaMetadatos = ''

    # Pregunta sobre la pertinencia de reutilizar los metadatos
    def preguntaMetadatos
        puts "\nSe han encontrado metadatos preexistentes, ¿deseas conservarlos? ".magenta.bold + "[S/n]:"
        $respuestaMetadatos = $stdin.gets.chomp.downcase

        if $respuestaMetadatos == '' or $respuestaMetadatos == 's'
            reutilizacionMetadatos
        elsif $respuestaMetadatos == 'n'
            metadatosTodo
        else
            preguntaMetadatos
        end
    end

    # Reutiliza los metadatos
    def reutilizacionMetadatos
        metadatoPreexistente = File.open($metadatoPreexistenteNombre, 'r:UTF-8')
        metadatoPreexistente.each do |linea|
            lineaCortaInicio = linea[0...3]
            lineaCortaFinal = linea[3...-1]

            # Permite separar los metadatos según su tipo
            if lineaCortaInicio == "_M_"
                # Evita copiar la versión
                if linea[-11...-1] != "identifier"
                    $metadatosInicial.push(lineaCortaFinal)
                end
            elsif lineaCortaInicio == "_O_"
                $archivosNoLineales.push(lineaCortaFinal)
            elsif lineaCortaInicio == "_T_"
                $archivosNoToc.push(lineaCortaFinal)
            elsif lineaCortaInicio == "_P_"
                $portada = lineaCortaFinal
            elsif lineaCortaInicio == "_N_"
                $nav = lineaCortaFinal
            end
        end

        # Pregunta de nuevo por la versión
        Metadatos "\nVersión (ejemplo: 1.0.0)", "dc:identifier"
    end

    preguntaMetadatos
# Si no existen metadatos, los pide
else
    metadatosTodo
end

# Sirve para añadir elementos
indice = 0

# Para obtener elementos constantes en el opf, el ncx y el nav
rutaAbsoluta = Array.new
rutaRelativa = Array.new
rutaComun = ''
nombreOpf = ''
identificadorNcx = ''

# Obtiene las rutas absolutas
Dir.glob($carpeta + $divisor + '**' + $divisor + '*.*') do |archivo|
    # Los únicos dos archivos que no se necesitan es el container y el opf
    if File.extname(archivo) != '.xml' and File.extname(archivo) != '.opf'
        rutaAbsoluta.push(archivo)
        if File.extname(archivo) == '.ncx'
            identificadorNcx = File.basename(archivo)
        end
        if File.basename(archivo) == $nav
            $nav = File.basename(archivo)
        end
    elsif File.extname(archivo) == '.opf'
        nombreOpf = File.basename(archivo)
    end
end

# Crea otro conjunto que servirá para las rutas relativas
Dir.glob($carpeta + $divisor + '**' + $divisor + '*.*') do |archivoCorto|
    if File.extname(archivoCorto) != '.xml' and File.extname(archivoCorto) != '.opf'
        rutaRelativa.push(archivoCorto)
    # Obtiene la ruta común de los archivos
    elsif File.extname(archivoCorto) == '.opf'
        rutaComun = archivoCorto
        rutaComun[File.basename(archivoCorto)] = ''
    end
end

# Sustituye la ruta común por nada
rutaRelativa.each do |elemento|
    elemento[rutaComun] = ''
end

# Para recrear el opf
metadatos = Array.new
manifiesto = Array.new
espina = Array.new

# Inicia la creación de los metadatos
metadatos.push('    <metadata xmlns:dc="http://purl.org/dc/elements/1.1/">')

# Añade cada uno de los metadatos
$metadatosInicial.each do |dc|
    conjunto = dc.split('@')
    uid = ''
    if conjunto[0] != 'NA'
        if conjunto[1] == 'dc:title'
            $titulo = conjunto[0]
        elsif conjunto[1] == 'dc:identifier'
            uid = ' id="uid"'
            identificadorLibro = $titulo + '-'+ conjunto[0]
            conjunto[0] = identificadorLibro
        elsif conjunto[1] == 'dc:creator'
            $creador = conjunto[0]
        elsif conjunto[1] == 'dc:language'
            $lenguaje = conjunto[0]
        end
        metadatos.push('        <' + conjunto[1] + uid + '>' + conjunto[0] + '</' + conjunto[1] + '>')
    end
end

# Ajusta el tiempo para que siempre sean dos cifras
def Ajuste (numero)
    cantidad = ''
    if numero < 10
        cantidad = '0' + numero.to_s
    else
        cantidad = numero.to_s
    end
    return cantidad
end

# Obtiene el tiempo actual
fecha = Time.new

# Ajusta las cifras
ano = Ajuste fecha.year
mes = Ajuste fecha.month
dia = Ajuste fecha.day
hora = Ajuste fecha.hour
minuto = Ajuste fecha.min
segundo = Ajuste fecha.sec

# Crea la fecha completa
fechaCompleta =  ano + '-' + mes + '-' + dia + 'T' + hora + ':' + minuto + ':' + segundo + 'Z'

# Termina los metadatos
metadatos.push('        <meta property="dcterms:modified">' + fechaCompleta + '</meta>')
metadatos.push('        <meta property="rendition:layout">reflowable</meta>')
metadatos.push('        <meta property="ibooks:specified-fonts">true</meta>')
metadatos.push('    </metadata>')

# Acomoda el identificador del ncx
identificadorNcx['.'] = '_'
identificadorNcx = 'id_' + identificadorNcx

# Identifica los tipos de recursos existentes en el opf según su tipo de extensión
def Tipo (extension)
    if extension == '.gif'
        return 'image/gif'
    elsif extension == '.jpg' or extension == '.jpeg'
        return 'image/jpeg'
    elsif extension == '.png'
        return 'image/png'
    elsif extension == '.svg'
        return 'image/svg+xml'
    elsif extension == '.xhtml'
        return 'application/xhtml+xml'
    elsif extension == '.ncx'
        return 'application/x-dtbncx+xml'
    elsif extension == '.ttf'
        return 'application/vnd.ms-opentype'
    elsif extension == '.woff'
        return 'application/font-woff'
    elsif extension == '.smil'
        return 'application/smil+xml'
    elsif extension == '.pls'
        return 'application/pls+xml'
    elsif extension == '.mp3'
        return 'application/mpeg'
    elsif extension == '.mp4'
        return 'application/mp4'
    elsif extension == '.css'
        return 'text/css'
    elsif extension == '.js'
        return 'text/javascript'
    end
end

# Determina si se le pone un atributo no lienal al XHTML
def NoLinealCotejo (identificador)
    retorno = ""
    $archivosNoLineales.each do |comparar|
        comparador = "id_" + comparar + "_xhtml"
        if comparador == identificador
            retorno = ' linear="no"'
            break
        end
    end
    return retorno
end

def Propiedad (archivo, comparacion, propiedad)
    propiedadAdicion = ''
    if archivo == comparacion
        propiedadAdicion = ' properties="' + propiedad + '"'
    end
    return propiedadAdicion
end

# Recorre todos los archivos en busca de los recursos para el manifiesto y la espina
Dir.glob($carpeta + $divisor + '**' + $divisor + '*.*') do |archivoManifiesto|
    if File.extname(archivoManifiesto) != '.xml' and File.extname(archivoManifiesto) != '.opf'

        # Conserva los xhtml que tienen scripts
        $scriptXhtml = Array.new

        if File.extname(archivoManifiesto) == '.xhtml'

            # Ayuda a detectar scripts en en header
            etiquetaHeadFin = false

            archivoXhtml = File.open(archivoManifiesto, 'r:UTF-8')
            archivoXhtml.each do |linea|

                # Se indica cuando ya pasó el head
                if (linea =~ /(.*)<\/head>/ )
                    etiquetaHeadFin = true
                end

                # Si se encuentra una etiqueta de script andentro del head, entonces se considera que hay un script en el archivo
                if (linea =~ /<script(.*)/ )
                    if etiquetaHeadFin == false
                        $scriptXhtml.push(File.basename(archivoManifiesto))
                    end
                end
            end
        end

        # Crea el identificador
        identificador = File.basename(archivoManifiesto)
        identificador['.'] = '_'
        identificador = 'id_' + identificador

        # Añade el tipo de recurso
        tipo = Tipo File.extname(archivoManifiesto)

        # Añade propiedades
        propiedad = Propiedad File.basename(archivoManifiesto), $portada, 'cover-image'
        propiedad2 = Propiedad File.basename(archivoManifiesto), $nav, 'nav'

        # Revisa si entre los archivos que tienen javascript, el actual lo tiene
        propiedad3 = ''
        $scriptXhtml.each do |js|
            if File.basename(archivoManifiesto) == js
                propiedad3 = Propiedad File.basename(archivoManifiesto), js, 'scripted'
            end
        end

        # Añade la propiedad no lineal, si la hay
        noLineal = NoLinealCotejo identificador

        # Agrega los elementos al manifiesto
        manifiesto.push('        <item href="' + rutaRelativa[indice] + '" id="' + identificador + '" media-type="' + tipo.to_s + '"' + propiedad.to_s + propiedad2.to_s + propiedad3.to_s + ' />')

        # Agrega los elementos a la espina
        if File.extname(archivoManifiesto) == '.xhtml' and File.basename(archivoManifiesto) != $nav
            espina.push ('        <itemref idref="' + identificador + '"' + noLineal.to_s + '/>')
        end

        # Permite recurrir a la ruta relativa
        indice += 1
    end
end

# Acomoda los elementos alfabéticamente
manifiesto = manifiesto.sort
espina = espina.sort

# Para el inicio del manifiesto y de la espina
manifiesto.insert(0, '    <manifest>')
espina.insert(0, '    <spine toc="' + identificadorNcx + '">')

# Para el fin del manifiesto y de la espina
manifiesto.push('    </manifest>')
espina.push('    </spine>')

Dir.glob($carpeta + $divisor + '**' + $divisor + '*.*') do |archivo|
    if File.extname(archivo) == '.opf'
        # Inicia la recreación del opf
        puts "\nRecreando el ".magenta.bold + File.basename(archivo).magenta.bold + "...".magenta.bold

        # Abre el opf
        opf = File.open(archivo, 'w:UTF-8')

        # Añade los primeros elementos necesarios
        opf.puts '<?xml version="1.0" encoding="UTF-8"?>'
        opf.puts '<package xmlns="http://www.idpf.org/2007/opf" xml:lang="' + $lenguaje + '" unique-identifier="uid" prefix="ibooks: http://vocabulary.itunes.apple.com/rdf/ibooks/vocabulary-extensions-1.0/" version="3.0">'

        # Añade los metadatos
        metadatos.each do |lineaMetadatos|
            opf.puts lineaMetadatos
        end

        # Añade el manifiesto
        manifiesto.each do |lineaManifiesto|
            opf.puts lineaManifiesto
        end

        # Añade la espina
        espina.each do |lineaEspina|
            opf.puts lineaEspina
        end

        # Añade el último elemento necesario
        opf.puts '</package>'

        # Cierra el opf
        opf.close
    end
end

# Para empezar a recrear el ncx y el nav
$archivosTocs = Array.new
$coletillaXhtml = ''
$coletillaNav = ''
$coletillaNcx = ''

# Para sacar el nivel en que se encuentran
rutaRelativa.each do |coletillaObtencion|
    if File.extname(coletillaObtencion) == '.xhtml'
        if File.basename(coletillaObtencion) != $nav
            $coletillaXhtml = coletillaObtencion.split($divisor)
        else
            $coletillaNav = coletillaObtencion.split($divisor)
        end
    else
        if File.extname(coletillaObtencion) == '.ncx'
            $coletillaNcx = coletillaObtencion.split($divisor)
        end
    end
end

# A partir de la cantidad de nieveles contenidos, se recrean las coletillas de los archivos
def CreadorColetillas (coletilla)
    coletillaFinal = ''

    # La coletilla queda vacía suponiendo que solo exista un nivel
    if coletilla.length > 1

        # Se itera si exista más de un nivel
        coletilla.each do |coletillas|

            # Se ignora el último nivel porque es el nombre del archivo
            if coletillas != coletilla[-1]

                # Si se trata de la coletilla de los XHTML se ponen los nombres correspondientes a los niveles superiores
                if coletilla == $coletillaXhtml
                    coletillaFinal += coletillas.to_s + $divisor
                # Si se trata del ncx o el nav cada nivel superior es igual a dos puntos suspensivos
                else
                    coletillaFinal += '..' + $divisor
                end
            end
        end
    end

    # Regresa el valor obtenido
    return coletillaFinal
end

# Saca las coletillas correspondientes
$coletillaNcx = CreadorColetillas $coletillaNcx
$coletillaNav = CreadorColetillas $coletillaNav
$coletillaXhtml = CreadorColetillas $coletillaXhtml

# Para sacar una ruta semejante a la rutaRelativa
$archivosNoLinealesCompleto = Array.new
$archivosNoTocCompleto = Array.new

# Añade los archivos para los tocs
rutaRelativa.each do |rr|
    if File.extname(rr) == '.xhtml' and File.basename(rr) != $nav
        $archivosTocs.push(rr)
    end
end

# Completa las rutas para poder comparar con los archivos que están en los tocs
def Completud (conjuntoIncompleto, conjuntoCompleto)
    conjuntoIncompleto.each do |elementoNM|
        if elementoNM != ' ' and elementoNM != ''
            conjuntoCompleto.push($coletillaXhtml + elementoNM + '.xhtml')
        end
    end
end

Completud $archivosNoLineales, $archivosNoLinealesCompleto
Completud $archivosNoToc, $archivosNoTocCompleto

# Ordena alfabéticamente
$archivosTocs = $archivosTocs.sort
$archivosXhtml = $archivosTocs

# Crea un solo conjunto de lo que no se ha de mostrar ordenado alfabéticamente
archivosNoMostrar = $archivosNoLinealesCompleto + $archivosNoTocCompleto
archivosNoMostrar = archivosNoMostrar.sort

# Elimina los elementos que no se tienen que mostrar
$archivosTocs = $archivosTocs.reject {|w| archivosNoMostrar.include? w}

# Obtiene cada una de las rutas absolutas de los xhtml
$rutaAbsolutaXhtml = Array.new

rutaAbsoluta.each do |elemento|
    if File.extname(elemento) == '.xhtml' and File.basename(elemento) != $nav
        $rutaAbsolutaXhtml.push(elemento)
    end
end

# Crea una relacion entre el nombre del archivo y su título
$nombreYtitulo = Array.new

$rutaAbsolutaXhtml.each do |i|

    archivoXhtml = File.open(i, 'r:UTF-8')
    archivoXhtml.each do |linea|

        # Examina si en alguna línea del texto existe la etiqueta <title>
        if (linea =~ /<title>(.*)/ )

            # Elimina los espacios al inciio y al final
            linea = linea.strip

            # Toma la parte que está adentro de la etiqueta
            linea = linea.split('<title>')[1]
            linea = linea.split('</title>')[0]

            # Crea un nuevo conjunto en donde se añaden el nombre del archivo y el título
            conjunto = Array.new
            conjunto.push(File.basename(i))
            conjunto.push(linea)

            # Añade este conjunto al conjunto que sirve como relación
            $nombreYtitulo.push(conjunto)
        end
    end
end

# Otorga el título de cada documento xhtml
def Titulo (elemento)
    titulo = ''
    $nombreYtitulo.sort
    $nombreYtitulo.each do |i|
        if i[0] == elemento
            titulo = i[1]
            break
        end
    end
    return titulo
end

# Para empezar a crear el ncx y el nav
$archivosNcx = Array.new
$archivosNav = Array.new

# Añade los primeros elementos de los tocs
$archivosNcx.push('<?xml version="1.0" encoding="UTF-8" standalone="no" ?>')
$archivosNcx.push('<ncx xmlns="http://www.daisy.org/z3986/2005/ncx/" version="2005-1" xml:lang="' + $lenguaje + '">')
$archivosNcx.push('    <head>')
$archivosNcx.push('        <meta content="' + identificadorLibro + '" name="dtb:uid"/>')
$archivosNcx.push('        <meta content="1" name="dtb:depth"/>')
$archivosNcx.push('        <meta content="0" name="dtb:totalPageCount"/>')
$archivosNcx.push('        <meta content="0" name="dtb:maxPageNumber"/>')
$archivosNcx.push('    </head>')
$archivosNcx.push('    <docTitle>')
$archivosNcx.push('        <text>' + $titulo + '</text>')
$archivosNcx.push('    </docTitle>')
$archivosNcx.push('    <docAuthor>')
$archivosNcx.push('        <text>' + $creador + '</text>')
$archivosNcx.push('    </docAuthor>')
$archivosNcx.push('    <navMap>')

$archivosNav.push('<?xml version="1.0" encoding="UTF-8"?>')
$archivosNav.push('<!DOCTYPE html>')
$archivosNav.push('<html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops" xml:lang="' + $lenguaje + '" lang="' + $lenguaje + '">')
$archivosNav.push('    <head>')
$archivosNav.push('        <meta charset="UTF-8" />')
$archivosNav.push('        <title>' + $titulo + '</title>')
$archivosNav.push('    </head>')
$archivosNav.push('    <body>')
$archivosNav.push('        <nav epub:type="toc">')
$archivosNav.push('            <ol>')

indice = 1

# Para recrear los tocs
$archivosTocs.each do |at|
    titulo = Titulo File.basename(at)
    $archivosNcx.push('        <navPoint id="navPoint-' + indice.to_s + '" playOrder="' + indice.to_s + '"><navLabel><text>' + titulo.to_s + '</text></navLabel><content src="' + $coletillaNcx + at.to_s + '"/></navPoint>')
    $archivosNav.push('                <li><a href="' + $coletillaNav + at.to_s + '">' + titulo.to_s + '</a></li>')
    indice += 1
end

# Añade los últimos elementos de los tocs y los elementos parciales del nav
$archivosNcx.push('    </navMap>')
$archivosNcx.push('</ncx>')

$archivosNav.push('            </ol>')
$archivosNav.push('        </nav>')

# Para obtener los números de páginas
$nombreYpaginas = Array.new

$rutaAbsolutaXhtml.each do |i|
    # Por defecto no hay páginas
    continuar = false

    # Sirve para poner los identificadores de las páginas
    conjunto = Array.new

    archivoXhtml = File.open(i, 'r:UTF-8')
    archivoXhtml.each do |linea|
        # Examina si en alguna línea del texto existe la etiqueta <title>
        if (linea =~ /epub:type="pagebreak"(.*)/ )

            # Se crea un conjunto que contendrá todas las páginas
            paginas = Array.new

            # Se utuliza un conjunto porque puede darse el caso de más de un elemento encontrado en una misla línea
            paginas = linea.scan(/epub:type="pagebreak"([^.]*?)id="([^.]*?)"/)

            paginas.each do |pagina|
                # cada una de las páginas tiene dos elementos, el id y el title, solo se queda con el title
                conjunto.push(pagina.last)
            end

            # Habilita el llenado de la relación
            continuar = true
        end
    end

    if continuar == true
        # Añade este conjunto al conjunto que sirve como relación
        conjuntoFinal = Array.new
        conjuntoFinal.push(File.basename(i))
        conjuntoFinal.push(conjunto)
        $nombreYpaginas.push(conjuntoFinal)
    end
end

# Pone la lista de cada una de las páginas
def Paginas (at)
    elemento = File.basename(at)
    $nombreYpaginas = $nombreYpaginas.sort
    $nombreYpaginas.each do |i|
        if i[0] == elemento
            i[1].each do |j|
                n = j.downcase.gsub(/[^0-9]/,'')
                $archivosNav.push('                <li><a href="' + $coletillaNav + at.to_s + '#' + j.to_s + '">' + n.to_s + '</a></li>')
            end
            break
        end
    end
end

# Si existen páginas, se agregan más elementos al nav
if $nombreYpaginas.length > 0
    $archivosNav.push('        <nav epub:type="page-list">')
    $archivosNav.push('            <ol epub:type="list">')

    $archivosXhtml.each do |at|
        Paginas at
    end

    $archivosNav.push('            </ol>')
    $archivosNav.push('        </nav>')
end

# Añade los últimos elementos del nav
$archivosNav.push('    </body>')
$archivosNav.push('</html>')

# Mete los cambios a los archivos actuales
def Recreador (comparativo, archivosToc)
    archivoCambio = ''
    archivoEncontrado = ''

    # Localiza el archivo que se pretende recrear
    Dir.glob($carpeta + $divisor + '**' + $divisor + '*.*') do |archivo|
        if comparativo == ".ncx"
            if File.extname(archivo) == comparativo
                archivoEncontrado = archivo
            end
        else
            if File.basename(archivo) == comparativo
                archivoEncontrado = archivo
            end
        end
    end

    # Inicia la recreación
    puts "\nRecreando el ".magenta.bold + File.basename(archivoEncontrado).magenta.bold + "...".magenta.bold

    # Abre el archivo
    archivoCambio = File.open(archivoEncontrado, 'w:UTF-8')

    # Añade los elementos
    archivosToc.each do |linea|
        archivoCambio.puts linea
    end

    # Cierra el archivo
    archivoCambio.close
end

Recreador '.ncx', $archivosNcx
Recreador $nav, $archivosNav

# Fin
mensajeFinal = "\nEl proceso ha terminado.".gray.bold

# Crea la ruta para el EPUB
rutaEPUB = "../#{ruta.last}.epub"

# Por defecto se usa el comando de las terminales UNIX
rm = "rm -rf #{rutaEPUB}"
zip = 'zip'

# Reajustes para Windows
if OS.windows?
    rutaEPUB = rutaEPUB.gsub('/', '\\')
    rutaPadre = rutaPadre.gsub('/', '\\')
    rm = "del #{rutaEPUB}"
    puts "\nArrastra el zip.exe".blue
    zip = $stdin.gets.chomp
end

espacio = ' '

# Elimina el EPUB previo
Dir.glob($carpeta + $divisor + '..' + $divisor + '**') do |archivo|
    if File.basename(archivo) == ruta.last + '.epub'
        espacio = ' nuevo '
        puts "\nEliminando EPUB previo...".magenta.bold
        system (rm)
    end
end

puts "\nCreando#{espacio}EPUB...".magenta.bold

# Crea el EPUB
system ("#{zip} #{$comillas}#{rutaEPUB}#{$comillas} -X mimetype")
system ("#{zip} #{$comillas}#{rutaEPUB}#{$comillas} -r #{$primerosArchivos[-2]} #{$primerosArchivos[-1]} -x \*.DS_Store \*._* #{$metadatoPreexistenteNombre}")

# Finaliza la creación
puts "\n#{ruta.last}.epub creado en: #{rutaPadre}".magenta.bold
puts mensajeFinal
