#!/usr/bin/env ruby
# encoding: UTF-8
# coding: UTF-8

Encoding.default_internal = Encoding::UTF_8

# Funciones y módulos comunes a todas las herramientas
require File.dirname(__FILE__) + "/../../otros/secundarios/general.rb"
require File.dirname(__FILE__) + "/../../otros/secundarios/lang.rb"
require File.dirname(__FILE__) + "/../../otros/secundarios/xhtml-template.rb"
require File.dirname(__FILE__) + "/../../otros/secundarios/xhtml-beautifier.rb"

# Argumentos
txt = if argumento "-f", txt != nil then argumento "-f", txt end
carpeta = if argumento "-d", carpeta != nil then argumento "-d", carpeta else Dir.pwd end
css = if argumento "-s", css != nil then argumento "-s", css end
reset = argumento "--reset", reset, 1
inner = argumento "--inner", inner, 1
argumento "-v", $l_no_v
argumento "-h", $l_no_h

# Comprueba que existan los argumentos necesarios
comprobacion [txt]

# Comprueba y adquiere el path absoluto de la carpeta para el EPUB
carpeta = comprobacionDirectorio carpeta

# Comprueba que el archivo tenga la extensión correcta
txt = comprobacionArchivo txt, [".md"]
css = comprobacionArchivo css, [".css"]

# Variables que se usarán
txtEsMD = if File.extname(txt) == ".md" then txtEsMD = true else txtEsMD = false end
texHay = false
htmlHay = false
archivos = Array.new
txtNotas = Array.new
txtConteo = 0
arcConteo = 0
md = nil

# Se va a la carpeta y busca los archivos para insertar las notas
Dir.chdir carpeta
Dir.glob(carpeta + '/*.*') do |archivo|
	if File.extname(archivo) == ".xhtml" || File.extname(archivo) == ".html" || File.extname(archivo) == ".htm" || File.extname(archivo) == ".xml" || File.extname(archivo) == ".tex"
		if File.extname(archivo) == ".tex"
			texHay = true
		else
			htmlHay = true
		end
		archivos.push(archivo)
	end
end
archivos = archivos.sort

# Si hay archivos mezclados
if texHay == true && htmlHay == true
	puts $l_no_error_f
	abort
end

# Convierte archivo MD
if txtEsMD
	# Se determina la ruta y nombre del archivo convertido
	txt_oculto = directorioPadre(txt) + "/" + $l_no_oculto + if texHay then ".tex" else ".html" end
	
	# Se usa Pandog, que a su vez usa Pandoc
	system("pc-pandog -i #{arregloRutaTerminal txt} -o #{arregloRutaTerminal txt_oculto}")
		
	# Cuenta la cantidad de notas al pie en el archivo de texto y va preparando las notas
	archivo = File.open(txt_oculto, 'r:UTF-8')
	linea_tmp = Array.new
	archivo.each do |linea|
		linea = linea.strip
		if texHay
			if linea != ""
				linea_tmp.push(linea)
			else
				txtNotas.push(linea_tmp.join(" "))
				txtConteo = txtConteo + 1
				linea_tmp = []
			end
		else
			if linea =~ /^<p/
				txtNotas.push(linea)
				txtConteo = txtConteo + 1
			end
		end
	end
	archivo.close
	
	# Si es TeX, se tiene que añadir una línea más y un conteo más, sino nunca se añadirá la última nota
	if texHay
		txtNotas.push(linea_tmp.join(" "))
		txtConteo = txtConteo + 1
	end
	
	# Modifica los elementos innecesarios
	archivo = File.open(txt_oculto, 'w:UTF-8')
	archivo.puts txtNotas
	archivo.close
end

puts $l_no_comparando

# Cuenta la cantidad de notas al pie en los archivos
archivos.each do |archivo|
    archivo = File.open(archivo, 'r:UTF-8')
    archivo.each do |linea|
        palabras = linea.split
        palabras.each do |palabra|
            if palabra =~ /#{$l_g_note[0]}.*?#{$l_g_note[1]}/
                arcConteo = arcConteo + 1
            end
        end
    end
    archivo.close
end

# Aborta si no hay coincidencia en el conteo
if txtConteo != arcConteo
	puts $l_no_error_c[0].red.bold
	puts "  #{txtConteo.to_s + $l_no_error_c[1] + File.basename(txt) + $l_no_error_c[2]}".red.bold
	puts "  #{arcConteo.to_s + $l_no_error_c[3]}".red.bold
    abort
end

puts $l_no_anadiendo

# Añade las notas a los archivos
notaNum = 1
notaReal = 0
archivos.each do |archivo|
	
	# Reinicia la numeración en cada archivo si así se deseo
	if reset
		notaNum = 1
	end
	
	# Determina la ruta según si estará en un archivo externo o no
	if inner
		href = "#c-"
	else
		href = $l_no_archivo_notas + "#"
	end
	
	# Para reconstruir el archivo
	archivo_tmp = Array.new
	if htmlHay && inner
		archivo_tmp_footer = Array.new
		archivo_tmp_footer.push("        <hr class=\"n-note-hr\" />")
    end

	# Analiza por palabra para cambiar la nota
    archivo = File.open(archivo, 'r:UTF-8')
    archivo.each_with_index do |linea, i|
		# Obtiene el espacio al inicio de la línea
		espacio = /(^\s*)/.match(linea).captures.first
		
		# Pone la referencia a la nota si es necesario
		palabras_tmp = Array.new
		palabras = linea.split
        palabras.each do |palabra|
			# Si es una nota sencilla
            if palabra =~ /#{$l_g_note[0] + $l_g_note[1]}/
				if texHay
					if reset
						nota = "\\footnote[#{notaNum}]{#{txtNotas[notaReal]}}"
					else
						nota = "\\footnote{#{txtNotas[notaReal]}}"
					end
				else					
					nota = "<sup class=\"n-note-sup\" id=\"n-#{notaReal + 1}\"><a href=\"#{href}n-#{notaReal + 1}\">[#{notaNum}]</a></sup>"
					
					if inner
						puts 
					end
				end
				
				# Hace los cambios a la palabra
				palabra = palabra.gsub(/#{$l_g_note[0] + $l_g_note[1]}/, nota)
				
				# Suma un elemento
				notaNum = notaNum + 1
				notaReal = notaReal + 1
			# Si es una nota personalizada
			elsif palabra =~ /#{$l_g_note[0]}(.*?)#{$l_g_note[1]}/
				
				# Obtiene el contenido mediante un match que obtiene capturas de las cuales solo se usa la primera, quitándole los elementos innecesarios
				contenido = /#{$l_g_note[0]}(.*?)#{$l_g_note[1]}/.match(palabra).captures.first.gsub($l_g_marca_in_1,"").gsub($l_g_marca_in_2,"")
				
				if texHay
					nota = "\\let\\svthefootnote\\thefootnote\\let\\thefootnote\\relax\\textsuperscript{#{contenido}}\\footnote{\\textsuperscript{#{contenido}} #{txtNotas[notaReal]}}\\addtocounter{footnote}{-1}\\let\\thefootnote\\svthefootnote"
				else
					nota = "<sup class=\"n-note-sup\" id=\"n-#{notaReal + 1}\"><a href=\"#{href}n-#{notaReal + 1}\">[#{contenido}]</a></sup>"
				end
				
				# Hace los cambios a la palabra
				palabra = palabra.gsub(/#{$l_g_note[0]}.*?#{$l_g_note[1]}/, nota)
				
				# Suma un elemento
				notaNum = notaNum + 1
				notaReal = notaReal + 1
			end
			
			palabras_tmp.push(palabra)
        end
        
        # Añade la información al archivo temporal
        archivo_tmp.push(espacio + palabras_tmp.join(" "))
    end
    archivo.close
    
    if htmlHay && inner
		# Imprimir para ver cómo va
    end
    
    # Modifica los elementos innecesarios
	#archivo = File.open(archivo, 'w:UTF-8')
	#archivo.puts archivo_tmp
	#archivo.close
end

# Si es sintaxis tipo HTML, se añade el contenido abajo o en un nuevo archivo
if htmlHay
	# Resetea los valores
	notaNum = 1
	notaReal = 0
end

# Elimina el archivo oculto que sirvió para las notas
File.delete(txt_oculto)

puts $l_g_fin

abort

# Variables
$divisor = '/'
$note = "--note--"
$noteRegEx = /--note(.*?)--/
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

# Un conjunto para utilizarlo al colocar las notas con la numeración correcta
$conteoFinal = Array.new

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
            archivoNotes.puts "            <p class=\"n-note-p\" id=\"n#{$conteoId}\"><a class=\"n-note-a\" href=\"#{$rutasRelativas[$conteoId - 1]}#c-n#{$conteoId}\">[#{$conteoFinal[$conteo]}]</a> #{$lineaCorregida}</p>"
        else
            arreglo linea
            archivoNotes.puts "            <p class=\"n-note-p\" id=\"n#{$conteoId}\"><a class=\"n-note-a\" href=\"#{$rutasRelativas[$conteoId - 1]}#n#{$conteoId}\">[#{$conteoFinal[$conteo]}]</a> #{$lineaCorregida}</p>"
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
	archivoNotes.puts "        <section epub:type=\"footnotes\">"

        # Añade las notas al final
        adicion archivoNotes

        # Últimos elementos necesarios para el archivo
	archivoNotes.puts "        </section>"
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
    archivoNotes.puts xhtmlTemplateHead "Notas", $rutaCSS
    archivoNotes.puts "	    <section epub:type=\"footnotes\">"
    archivoNotes.puts "            <h1>Notas</h1>"

    # Ayuda a detectar si existe un cambio de ruta
    $rutaVieja = $rutasRelativas.first

    # Añade las notas
    adicion archivoNotes

	archivoNotes.puts "	    </section>"
    archivoNotes.puts $xhtmlTemplateFoot

    archivoNotes.close
end

puts $mensajeFinal
