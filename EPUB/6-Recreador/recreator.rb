#!/usr/bin/env ruby
# encoding: UTF-8
# coding: UTF-8

Encoding.default_internal = Encoding::UTF_8

require 'fileutils'

# Funciones y módulos comunes a todas las herramientas
require File.dirname(__FILE__) + "/../../otros/secundarios/general.rb"
require File.dirname(__FILE__) + "/../../otros/secundarios/lang.rb"
require File.dirname(__FILE__) + "/../../otros/secundarios/xhtml-template.rb"

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

# Identifica el nav
$nav = ''

# Determina si en la carpeta hay un EPUB
def carpetaBusqueda
    if OS.windows?
        $carpeta = $carpeta.gsub('\\', '/')
    end

    $carpeta = arregloRuta $carpeta

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

rutaPadre = arregloRuta rutaPadre

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
$fijo = Array.new

# Define si se trata de un EPUB fijo
def fijo
    puts "\n" + "¿Se trata de un EPUB con diseño fijo?".blue + " [s/N]:"
    respuesta = $stdin.gets.chomp.downcase

    # La respuesta por defecto es no, por lo que solo deja un texto vacío
    if respuesta == '' or respuesta == 'n'
        $fijo.push(" ")
    elsif respuesta == 's'
        puts "\nATENCIÓN: ".bold + "en http://www.idpf.org/epub/fxl/#property-orientation viene la explicación de los datos que se piden a continuación."
        $fijo = Array.new
        $fijo.push("pre-paginated@rendition:layout")

        # Obtiene los renditions necesarios
        def fijoData opciones, rendition
            puts "\nElige una de las siguientes opciones para #{rendition} ".brown + "[#{opciones}]:".bold
            r = $stdin.gets.chomp.downcase
            o = opciones.split(",")
            v = false

            # Busca si la opción ingresada es una de las disponibles
            o.each do |opcion|
                if r == opcion.strip.downcase
                    v = true
                    break
                end
            end

            # Si es una opción válida, se escribe; si no, vuelve a preguntar
            if v
                $fijo.push(r + "@" + rendition)
            else
                puts "\nOpción no válida.".red.bold
                fijoData opciones, rendition
            end
        end

        # Obtiene el tamaño por defecto
        def fijoSize opcion
            # Determina si será la anchura o la altura
            if opcion == "w"
                lado = "anchura"
            else
                lado = "altura"
            end

            puts "\nElige el tamaño de la #{lado} en pixeles:".brown
            r = $stdin.gets.chomp.downcase

            # Se busca que la respuesta convertida a número íntegro sea la misma
            if r.to_i.to_s == r
                $fijo.push(r + "@" + opcion)
            # Si no lo es, vuelve a preguntar
            else
                puts "\nOpción no válida. Un número entero es necesario.".red.bold
                fijoSize opcion
            end

        end

        fijoData "landscape, portrait, auto", "rendition:orientation"
        fijoData "none, landscape, portrait, both, auto", "rendition:spread"
        fijoSize "w"
        fijoSize "h"

    # Se repite si no se indica un «s» o un «n»
    else
        fijo
    end
end

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

    # Pregunta si se desea un EPUB fijo
    fijo

    # Obtiene los metadatos
    Metadatos "\nTítulo", "dc:title"
    Metadatos "\nNombre del autor o editor principal " + "(ejemplo: Apellido, Nombre)".bold, "dc:creator"
    Metadatos "\nEditorial", "dc:publisher"
    Metadatos "\nSinopsis", "dc:description"
    Metadatos "\nTema " + "(ejemplo: Ficción, Novela)".bold, "dc:subject"
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

    $fijo.each do |f|
        archivoMetadatos.puts "_R_" + f
    end

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
            if lineaCortaInicio == "_R_"
                $fijo.push(lineaCortaFinal)
            elsif lineaCortaInicio == "_M_"
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
metadatos.push('        <dc:language>' + $lang + '</dc:language>')

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

# Si es EPUB fijo, se agregan esas propiedades, se lo contrario solo se agrega el «reflowable»
if $fijo.first != " "
    $fijo.each do |r|
        a = r.split("@").first
        z = r.split("@").last

        # No agrega como metadato la anchura y la altura
        if z != "w" && z != "h"
            metadatos.push('        <meta property="' + z + '">' + a + '</meta>')
        else
            # Si es la anchura, guarda la variable para utilizarse más adelante
            if z == "w"
                $width = a
            # Mismo caso pero para la altura
            else
                $height = a
            end
        end
    end
else
    metadatos.push('        <meta property="rendition:layout">reflowable</meta>')
end

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
    elsif extension == '.xhtml' or extension == '.html'
        return 'application/xhtml+xml'
    elsif extension == '.ncx'
        return 'application/x-dtbncx+xml'
    elsif extension == '.ttf' || extension == '.otf'
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

# Recorre todos los archivos en busca de los recursos para el manifiesto y la espina
Dir.glob($carpeta + $divisor + '**' + $divisor + '*.*') do |archivoManifiesto|
    if File.extname(archivoManifiesto) != '.xml' and File.extname(archivoManifiesto) != '.opf'

        $archivoNombre = File.basename(archivoManifiesto)

        # Conserva los xhtml que tienen scripts o archivos svg
        $scriptXhtml = Array.new
        $svgXhtml = Array.new

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
                        $scriptXhtml.push($archivoNombre)
                    end
                end

                # Identifica si se encuentra una imagen svg
                if (linea =~ /<(.*?)img(.*?)src="(.*?).svg(.*?)"(.*?)\/>/ )
                    $svgXhtml.push($archivoNombre)
                end
            end
        end

        # Crea el identificador
        identificador = $archivoNombre
        identificador['.'] = '_'
        identificador = 'id_' + identificador

        # Añade el tipo de recurso
        tipo = Tipo File.extname(archivoManifiesto)

        # Inscruta propiedades
        def Propiedad (archivo, comparacion, propiedad)
            propiedadAdicion = ''

            if archivo == comparacion
                propiedadAdicion = ' properties="' + propiedad + '"'
            end

            return propiedadAdicion
        end

        # Añade propiedades
        propiedad = Propiedad $archivoNombre, $portada.gsub(".", "_"), 'cover-image'
        propiedad2 = Propiedad $archivoNombre, $nav.gsub(".", "_"), 'nav'

        # Si encuentra una propiedad, se cambia el valor a verdadero; de lo contrario es falso
        def propiedadBuscar conjunto
            conjunto.each do |a|
                if $archivoNombre == a
                    return true
                    break
                end
            end

            return false
        end

        # Revisa si entre los archivos que tienen javascript o svg, el actual lo tiene
        script = propiedadBuscar $scriptXhtml
        svg = propiedadBuscar $svgXhtml

        # Si tiene ambas propiedades
        if script && svg
            propiedad3 = Propiedad $archivoNombre, $archivoNombre, 'scripted svg'
        # Si tiene alguna de las propiedades
        elsif script || svg
            if script
                propiedad3 = Propiedad $archivoNombre, $archivoNombre, 'scripted'
            else
                propiedad3 = Propiedad $archivoNombre, $archivoNombre, 'svg'
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

        # Añade la propiedad no lineal, si la hay
        noLineal = NoLinealCotejo identificador

        # Agrega los elementos al manifiesto
        manifiesto.push('        <item href="' + rutaRelativa[indice] + '" id="' + identificador + '" media-type="' + tipo.to_s + '"' + propiedad.to_s + propiedad2.to_s + propiedad3.to_s + ' />')

        # Agrega los elementos a la espina
        if (File.extname(archivoManifiesto) == '.xhtml' || File.extname(archivoManifiesto) == '.html') and $archivoNombre != $nav.gsub(".", "_")
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
        opf.puts '<package xmlns="http://www.idpf.org/2007/opf" xml:lang="' + $lang + '" unique-identifier="uid" prefix="ibooks: http://vocabulary.itunes.apple.com/rdf/ibooks/vocabulary-extensions-1.0/" version="3.0">'

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

# Para mostrar el anuncio solo una vez
viewportsAnuncio = true
viewportsAnuncio2 = true

$rutaAbsolutaXhtml.each do |i|

    # Si es diseño fijo, se añade el viewport
    if $fijo.first != " "
        enHead = true
        sinViewport = true
        lineas = Array.new

        # Guarda las líneas con la modificación
        a = File.open(i, 'r:UTF-8')
        a.each do |linea|
            # Si está en el head, y se encuentra un viewport, se indica
            if enHead
                if linea =~ /viewport/
                    # Hasta este punto se está seguro si se modificarán viewports o no, por ello se anuncia
                    if viewportsAnuncio2
                        puts "\nModificando viewports...".magenta.bold
                    end

                    # Evita la repetición del anuncio
                    viewportsAnuncio2 = false

                    linea = linea.gsub(/content=\"(.*?)\"/, 'content="width=' + $width + ', height=' + $height + '"')
                    sinViewport = false
                end
            end

            # Cuando se llega al fin y no hay viewport, se añade; también se señala el fin del head
            if (linea =~ /(.*)<\/head>/ )
                if sinViewport && $width != nil
                    # Hasta este punto se está seguro si se agregarán viewports o no, por ello se anuncia
                    if viewportsAnuncio
                        puts "\nAñadiendo viewports...".magenta.bold
                    end

                    # Evita la repetición del anuncio
                    viewportsAnuncio = false

                    lineas.push('        <meta name="viewport" content="width=' + $width + ', height=' + $height + '" />')
                end
                enHead = false
            end

            # Añade las líneas ya existentes del archivo
            lineas.push(linea)
        end

        # Rescribe el archivo con las lineas encontradas o añadidas del análisis anterior
        b = File.open(i, 'w:UTF-8')
        lineas.each do |l|
            b.puts l
        end
        b.close
    end

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
$archivosNcx.push('<ncx xmlns="http://www.daisy.org/z3986/2005/ncx/" version="2005-1" xml:lang="' + $lang + '">')
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

$archivosNav.push(xhtmlTemplateHead $titulo)
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
$archivosNav.push($xhtmlTemplateFoot)

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
rm = rutaEPUB
zip = 'zip'

# Reajustes para Windows
if OS.windows?
    rutaEPUB = rutaEPUB.gsub('/', '\\')
    rutaPadre = rutaPadre.gsub('/', '\\')
    puts "\nArrastra el zip.exe".blue
    zip = $stdin.gets.chomp
end

espacio = ' '

# Elimina el EPUB previo
Dir.glob($carpeta + $divisor + '..' + $divisor + '**') do |archivo|
    if File.basename(archivo) == ruta.last + '.epub'
        espacio = ' nuevo '
        puts "\nEliminando EPUB previo...".magenta.bold
        FileUtils.rm_rf(rm)
    end
end

puts "\nCreando#{espacio}EPUB...".magenta.bold

# Crea el EPUB
system ("#{zip} #{$comillas}#{rutaEPUB}#{$comillas} -X mimetype")
system ("#{zip} #{$comillas}#{rutaEPUB}#{$comillas} -r #{$primerosArchivos[-2]} #{$primerosArchivos[-1]} -x \*.DS_Store \*._* #{$metadatoPreexistenteNombre}")

# Finaliza la creación
puts "\n#{ruta.last}.epub creado en: #{rutaPadre}".magenta.bold
puts mensajeFinal
