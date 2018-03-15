#!/usr/bin/env ruby
# encoding: UTF-8
# coding: UTF-8

require 'fileutils'
require 'json'
require 'yaml'

Encoding.default_internal = Encoding::UTF_8

# Funciones y módulos comunes a todas las herramientas
require File.dirname(__FILE__) + "/../../src/common/general.rb"
require File.dirname(__FILE__) + "/../../src/common/lang.rb"
require File.dirname(__FILE__) + "/../../src/common/css-template.rb"
require File.dirname(__FILE__) + "/../../src/common/xhtml-template.rb"
require File.dirname(__FILE__) + "/../../src/common/xhtml-beautifier.rb"

# Argumentos
archivo = if argumento "-f", archivo != nil then argumento "-f", archivo end
$deep_analysis = argumento "--deep", $deep_analysis, 1
json = argumento "--json", json, 1
yaml = argumento "--yaml", yaml, 1
$rotacion_grafica = argumento "--rotate", yaml, 1
argumento "-v", $l_an_v
argumento "-h", $l_an_h

# Extrae la lista de palabras o de etiquetas
def extraccion hash, marcado = false

    puts "#{$l_an_extrayendo[0] + (!marcado ? $l_an_extrayendo[1] : $l_an_extrayendo[2]) + $l_an_extrayendo[3]}".green

    $resultado_extraccion = []

    # La función propia de extracción
    def extraccion_archivo h, m

        # Si se van a poner palabras en $resultado_extraccion
        def guardado_palabra elemento
            elemento.split(/[\u00A0|\s]+/).each do |p|
                # Si la palabra tiene entrecruzada entidades HTML, las separa para volver a ejecutar esta función
                if p =~ /\&\w+;/ || p =~ /\&\#\d+;/
                    p = p.split(/\&.*?;/).join(' ')
                    guardado_palabra(p)
                else
                    # Elimina todo lo que no son letras (^\p{L}), marcas que se unen con letras (^\p{M}) o números (^\p{N}) al inicio o al final de la palabra
                    p = p.gsub(/--note.*?--/,'').gsub(/^[^\p{L}|^\p{M}|^\p{N}]+/,'').gsub(/[^\p{L}|^\p{M}|^\p{N}]+$/, '')
                    # Si quedarán caracteres hipotéticamente eliminando todo lo que no es dígito o letra, se manda al resultado
                    if p.gsub(/[^\p{L}|^\p{M}|^\p{N}]/,'').length > 0 then $resultado_extraccion.push(p) end
                end
            end
        end

        # Si se van a poner etiquetas en $resultado_extraccion
        def guardado_etiqueta elemento

            # Extrae los atributos en la sintaxis correcta
            def extraccion_atributos h
                atributos = []
                h.each do |k, v|
                    atributos.push(k[1..-1] + '="' + v + '"')
                end

                atributos.join(' ')
            end

            # Iteración de cada etiqueta
            elemento.each do |k, v|

                # Se le añaden los elementos iniciales
                etiqueta = '<' + k[1..-1]

                if v != nil
                    # Se añaden atributos si los hay
                    if v['attributes'] != nil
                        etiqueta += ' ' + extraccion_atributos(v['attributes'])
                    end

                    # Se añade su cierre según si es etiqueta única o doble
                    if v['content'] != nil
                        etiqueta += '>'
                    else
                        etiqueta += ' />'
                    end
                # Cuando no tiene ningún valor, se considera etiqueta única como el caso de <br />
                else
                    etiqueta += ' />'
                end

                # Se entrega el resultado
                $resultado_extraccion.push(etiqueta)
            end
        end

        # Itera cada uno de los contenidos
        def iteracion conjunto, m
            conjunto.each do |e|
                # Si es un Hash, se buscan las etiquetas e ir más adentro
                if e.kind_of?(Hash)
                    e.each do |k, v|
                        # La variable «k» son las etiquetas
                        if m then guardado_etiqueta(e) end

                        # Si el valor no es nulo, ni es nulo que tenga contenido, se va más adentro
                        # Se ignoran las etiquetas <style>, <script> y <title>; SE PUEDEN AGREGAR MÁS
                        if v != nil && v['content'] != nil && 
                           k != '$style' && k != '$script' && k != '$title'
                            iteracion(v['content'], m)
                        end
                    end
                # De lo contrario es contenido
                else
                    # La variable «e» es el texto
                    if !m then guardado_palabra(e) end
                end
            end
        end

        iteracion(h['content'], m)
    end

    # Si es un archivo con sintaxis HTML
    if hash['opf'] == nil
        extraccion_archivo(hash, marcado)
    # Si es un epub
    else
        # Iteración de cada archivo HTML que compone el libro
        hash['htmls'].each do |html|
            extraccion_archivo(html, marcado)
        end
    end

    # El primer sort es para agrupar las palabras según si están en bajas o en altas, pero no acomoda correctamente las palabras con tilde
    # El segundo sort acomoda de manera correcta las palabras con tildes
    $resultado_extraccion = $resultado_extraccion.sort.sort_by{|s| transliterar(s, false)}
end

# Separa las palabras y las cifras
def separacion conjunto, cifras = false

    puts "#{$l_an_separando[0] + (!cifras ? $l_an_separando[1] : $l_an_separando[2]) + $l_an_separando[3]}".green

    # La condición es según si se quieren palabras o cifras
    condicion = cifras ? /^\p{N}+$/ : /^[\p{L}|\p{M}]+$/
    conjunto_final = []
    $conjunto_no_identificados = []
    $conjunto_versales = []

    conjunto.each do |e|
        if e =~ condicion
            conjunto_final.push(e)
        # Hay elementos que tienen mezcla de cifras y palabras, por lo que no pueden identificarse
        elsif e !~ /^\p{N}+$/ && e !~ /^[\p{L}|\p{M}]+$/
            $conjunto_no_identificados.push(e)
        # Obtiene las palabras con versal inicial
        elsif e[0].downcase != e[0]
            $conjunto_versales.push(e)
        end
    end

    conjunto_final
end

# Genera un conjunto donde cada elemento = [palabra, núm. de apariciones]
def contabilizar c
    e_guardado = c[0]
    c_final = []
    cantidad = 0

    # Iteración del conjunto dado
    c.each_with_index do |e, i|
        # Si el elemento guardado es igual al elemento actual, solo se suma uno
        if e_guardado === e
            cantidad += 1
        # Si ya no son iguales, se guarda en el conjunto final y se reseta la cantidad y el elemento guardado
        else
            c_final.push([e_guardado, cantidad])
            cantidad = 1
            e_guardado = e
        end

        if i + 1 === c.length then c_final.push([e_guardado, cantidad]) end
    end

    return c_final
end

# Genera un conjunto donde cada elemento = {'tag' => etiqueta, 'length' => cantidad total, 'types' => [etiqueta, núm. de apariciones]}
def contabilizar_etiquetas c

    puts "#{$l_an_creando_analitica[0] + $l_an_creando_analitica[8] + $l_an_creando_analitica.last}".green

    c = contabilizar(c)
    e_guardado = c[0]
    e_conjuntos = []
    c_final = []
    cantidad = 0

    # Iteración del conjunto dado
    c.each_with_index do |e, i|
        # Si el elemento guardado es igual al elemento actual, solo se suma uno
        if e_guardado[0].gsub('<', '').gsub(' />', '').gsub('>', '').gsub(/\s+?.*$/, '') == e[0].gsub('<', '').gsub(' />', '').gsub('>', '').gsub(/\s+?.*$/, '')
            cantidad += e[1]
        # Si ya no son iguales, se guarda en el conjunto final y se reseta la cantidad, el elemento guardado y los conjuntos
        else
            c_final.push({'tag' => e_guardado[0].gsub('<', '').gsub(' />', '').gsub('>', '').gsub(/\s+?.*$/, ''), 'length' => cantidad, 'types' => e_conjuntos})
            cantidad = e[1]
            e_guardado = e
            e_conjuntos = []
        end

        # Guarda cada uno de los conjuntos
        e_conjuntos.push(e)

        if i + 1 === c.length then c_final.push({'tag' => e_guardado[0].gsub('<', '').gsub(' />', '').gsub('>', '').gsub(/\s+?.*$/, ''), 'length' => cantidad, 'types' => e_conjuntos}) end
    end

    return c_final
end

# Cada elemento de un conjunto pasa de ser texto a un conjunto donde está la palabra/cifra y su número de apariciones
def incrustar_analitica hash, conjunto, texto, indice

    puts "#{$l_an_creando_analitica[0] + $l_an_creando_analitica[indice] + $l_an_creando_analitica.last}".green

    list_uniq_case_on = conjunto.uniq
    if $deep_analysis then list_uniq_case_off = conjunto.map(&:downcase).uniq{|e| e.downcase} end

    # Se le agrega la llave al hash que a su vez tiene las siguientes llaves
    if $deep_analysis
        hash[texto] = {
            'all' => conjunto.length,                                       # Extensión de todo el conjunto
            'uniq_case_on' => list_uniq_case_on.length,                     # Extensión de elementos únicos del conjunto sin ignorar las versales
            'uniq_case_off' => list_uniq_case_off.length,                   # Extensión de elementos únicos del conjunto ingnorando las versales
            'list_all_case_on' => contabilizar(conjunto),                   # Lista de todo el conjunto sin ignorar las versales donde cada elemento = [palabra, núm. de apariciones]
            'list_all_case_off' => contabilizar(conjunto.map(&:downcase)),  # Lista de todo el conjunto ignorando las versales donde cada elemento = [palabra, núm. de apariciones]
            'list_uniq_case_on' => list_uniq_case_on,                       # Lista de elementos únicos del conjunto sin ignorar las versales
            'list_uniq_case_off' => list_uniq_case_off                      # Lista de elementos únicos del conjunto ignorando las versales
        }
    else
        hash[texto] = {
            'all' => conjunto.length,                                       # Extensión de todo el conjunto
            'uniq_case_on' => list_uniq_case_on.length,                     # Extensión de elementos únicos del conjunto sin ignorar las versales
            'list_all_case_on' => contabilizar(conjunto),                   # Lista de todo el conjunto sin ignorar las versales donde cada elemento = [palabra, núm. de apariciones]
            'list_uniq_case_on' => list_uniq_case_on,                       # Lista de elementos únicos del conjunto sin ignorar las versales
        }
    end

    return hash
end

# Semejante a la definición anterior pero acomodados según el núm. de aparición, así como saca porcentajes y depura
def incrustar_analitica_top hash, c

    puts "#{$l_an_creando_analitica[0] + $l_an_creando_analitica[6] + $l_an_creando_analitica.last}".green

    # Ambos conjuntos se contabilizan, orden según el núm. de apariciones y se invierten (la palabra con mayor núm. de apariciones va primero)
    # La diferencia es que el segundo primero se reordena para ser puras minúsculas
    c_sucio = contabilizar(c).sort_by(&:last).reverse
    c_cuasilimpio = contabilizar(c.map(&:downcase)).sort_by(&:last).reverse

    # A partir del número de apariciones y el total de palabras se obtiene el porcentaje de aparición
    def obtener_porcentaje c, total
        c_final = []

        c.each do |e|
            c_final.push([e[0], e[1], ((e[1] * 100) / total.to_f)])
        end

        return c_final
    end

    # Saca las palabras vacías (stopwords)
    def depurar c
        ruta = File.dirname(__FILE__) + "/../../src/common/stopwords/stopwords-#{$lang}.txt"
        contenido = []
        c_final = []

        # Extrae la lista de palabras vacías
        archivo_abierto = File.open(ruta, 'r:UTF-8')
        archivo_abierto.each do |linea|
            contenido.push(linea.strip)
        end
        archivo_abierto.close

        # Itera el conjunto para identificar palabras vacías
        c.each do |e|
            incorporar = true

            # Si en la transliteración la palabra coincide con una palabra vacía, se omite del nuevo conjunto
            contenido.each do |ee|
                if transliterar(e[0], false) =~ /^#{ee}$/
                    incorporar = false
                    break
                end
            end

            if incorporar == true then c_final.push(e) end
        end

        return c_final
    end

    # Obtiene las listas
    list_all_clean = obtener_porcentaje(depurar(c_cuasilimpio), hash['words']['all'])
    if $deep_analysis then list_all_dirty = obtener_porcentaje(c_sucio, hash['words']['all']) end

    # Se le agrega la llave al hash que a su vez tiene las siguientes llaves
    if $deep_analysis
        hash['top'] = {
            'all_clean' => list_all_clean.length,   # Top sin palabras vacías y en bajas
            'all_dirty' => list_all_dirty.length,   # Top con palabras vacías e insensible a mayúsculas
            'list_all_clean' => list_all_clean,     # Lista del top sin palabras vacías y en bajas
            'list_all_dirty' => list_all_dirty      # Lista del top con palabras vacías e insensible a mayúsculas
        }
    else
        hash['top'] = {
            'all_clean' => list_all_clean.length,   # Top sin palabras vacías y en bajas
            'list_all_clean' => list_all_clean      # Lista del top sin palabras vacías y en bajas
        }
    end

    return hash
end

# Añade el contenido de las estadísticas al contenido JavaScript
def cambios_js a, conjunto
    conjunto_final = []

    # Formatea el objeto necesario para la nube de palabras
    def formatear_top aa
        top = []

        if aa['top']['list_all_clean'].length < 50
            top_crudo = aa['top']['list_all_clean']
        else
            top_crudo = aa['top']['list_all_clean'][0..49]
        end

        top_crudo.each do |e|
            top.push("{\"text\": \"#{e[0]}\", \"size\": #{e[1]}},")
        end

        return '[' + top.join('')[0..-2] + ']'
    end

    localizado = false
    resuelto = false
    conjunto_final.push("            // Start of dependencies")
    conjunto.each do |linea|
        if linea =~ /Pecas -->/ then localizado = true end

        # Si se encuentras las variables a modificar
        if localizado
            # Si aún no han sido modificadas
            if !resuelto
                contenido = []
                espacio = '            '

                # Creación y adición de las variables
                contenido.push(espacio + "total_words = #{a['words_digits']['all']}")
                contenido.push(espacio + "words_digits_unknown = [#{a['words']['all']},#{a['digits']['all']},#{a['unknown']['all']}]")
                contenido.push(espacio + "uppercase_downcase = [#{a['uppercase']['all']},#{a['words_digits']['all'] - a['uppercase']['all']}]")
                contenido.push(espacio + "diversity = #{a['diversity']}")
                contenido.push(espacio + "total_tags = #{a['tags']['all']}")
                contenido.push(espacio + "total_tags_types = #{a['tags']['types']}")

                if a['hunspell'] != nil
                    contenido.push(espacio + "total_typos = #{a['hunspell']['all']}")
                else
                    contenido.push(espacio + "total_typos = \"0. <mark>#{$l_an_advertencia_hunspell}</mark>\"")
                end

                if a['linkchecker'] != nil
                    contenido.push(espacio + "total_urls = #{a['linkchecker']['all']}")
                else
                    contenido.push(espacio + "total_urls = \"0. <mark>#{$l_an_advertencia_linkchecker}</mark>\"")
                end

                contenido.push(espacio + "top50 = #{formatear_top(a)}")
                contenido.push(espacio + "piechart_labels = #{$l_an_grafica.to_s}")
                contenido.push(espacio + "rotation = #{$rotacion_grafica ? true : false}")
                
                conjunto_final.push(contenido)
                resuelto = true
            end
        # De lo contrario se añaden sin contratiempos
        elsif linea =~ /DO NOT ALTER THE ORDER/
            conjunto_final.push("            // End of dependencies\n\n            // Variables")
        else
            conjunto_final.push(linea)
        end

        if linea =~ /<-- Pecas/ then localizado = false end
    end

    return conjunto_final
end

# Añade el contenido de las estadísticas al HTML
def cambios_html html_crudo, a, js, css
    html_final = []

    # Llena las filas (<tr>) de cada tabla
    def filas contenido, columnas, espacios, ocultable = false
        filas_contenido = []

        # Obtiene lo necesario para acceder a cada elemento de la columna
        if columnas < 4
            columna_e = *(0..(columnas - 1))
        else 
            columna_e = ['url', 'parentname', 'valid', 'result'] 
        end

        # Llena cada <td>
        def fila c, o, e
            fila_contenido = []

            c.each_with_index do |j, i|
                if o && i.odd?
                    fila_contenido.push('<td class="ocultable"><p>' + e[j].to_s.gsub('<', '&lt;').gsub('>', '&gt;') + '</p></td>')
                else
                    fila_contenido.push('<td><p>' + e[j].to_s.gsub('<', '&lt;').gsub('>', '&gt;') + '</p></td>')
                end
            end

            return fila_contenido.join('')
        end

        # Iteración de cada elemento del contenido
        contenido.each do |e|
            filas_contenido.push(espacios + '<tr>' + fila(columna_e, ocultable, e) + '</tr>')
        end

        return filas_contenido
    end

    # Crea el acordeón
    def tablas conjunto
        acordeon = []

        conjunto.each_with_index do |e, i|
            acordeon.push("            <h3 class=\"accordion\" id=\"a#{i}\">&lt;#{e['tag']}&gt; : #{e['length']}</h2>")
            acordeon.push("            <table class=\"sortable accordion-content oculto\" id=\"ac#{i}\">")
            acordeon.push("                <tr><th><p>Elemento</p></th><th><p>Ocurrencias</p></th></tr>")
            acordeon.push(filas(e['types'], 2, '                '))
            acordeon.push("            </table>")
        end

        return acordeon
    end

    html_crudo.each do |l|
        # Se añade el contenido de las analíticas
        if l =~ /^<!--/
            if l =~ /--\w+--/ && l !~ /--nan--/
                if l =~ /--title--/
                    html_final.push(l.gsub('<!---->', '       ').gsub('--title--', a['title']))
                elsif l =~ /--tags--/
                    html_final.push(tablas(a['tags']['list']))
                else
                    if l =~ /--top--/
                        html_final.push(filas(a['top']['list_all_clean'], 3, '                        ', true))
                    elsif l =~ /--words--/
                        html_final.push(filas(a['words']['list_all_case_on'], 2, '                        '))
                    elsif l =~ /--digits--/
                        html_final.push(filas(a['digits']['list_all_case_on'], 2, '                        '))
                    elsif l =~ /--unknown--/
                        html_final.push(filas(a['unknown']['list_all_case_on'], 2, '                        '))
                    elsif l =~ /--uppercase--/
                        html_final.push(filas(a['uppercase']['list_all_case_on'], 2, '                        '))
                    elsif l =~ /--typos--/
                        if a['hunspell'] != nil
                            html_final.push(filas(a['hunspell']['list'], 2, '                '))
                        end
                    elsif l =~ /--urls--/
                        if a['linkchecker'] != nil
                            html_final.push(filas(a['linkchecker']['list'], 4, '                ', true))
                        end
                    end
                end
            end
        # Añade el js y el css
        elsif l =~ /^\s+<script/ || l =~ /^\s+<link/
            # Buscando un archivo en específico se evita que añada varias veces
            if l =~ /6-common.js/
                html_final.push('        <script>')
                html_final.push(js)
                html_final.push('        </script>')
            elsif l =~ /styles.css/
                html_final.push('        <style>')
                html_final.push(css)
                html_final.push('        </style>')
            end
        # El resto de añade sin contratiempo
        else
            html_final.push(l)
        end
    end

    return html_final
end

begin
    # Comprueba que existan los argumentos necesarios
    comprobacion [archivo]

    # Comprueba los argumentos necesarios
    if archivo == nil
        puts $l_g_error_arg
        abort
    end

    # Comprueba que el archivo tenga la extensión correcta
    archivo = comprobacionArchivo archivo, [".html", ".xhtml", ".htm", ".xml", ".epub", ".md"]
    archivo = arregloRuta archivo

    # Se va a la carpeta para crear los archivos
    Dir.chdir(directorioPadre archivo)

    # Analiza el archivo según su extensión
    if File.extname(archivo) == ".epub"
        analisis_crudo = epub_analisis archivo
        borrar = $l_g_epub_analisis
    else
        # Para el MD se convierte a XHTML con pc-pandog
        if File.extname(archivo) == ".md"
            puts "#{$l_an_advertencia_md[0] + $l_g_xhtml_analisis + $l_an_advertencia_md[1]}".yellow.bold
            system("ruby #{File.dirname(__FILE__)+ "/../pandog/pandog.rb"} -i #{File.basename(archivo)} -o #{$l_g_xhtml_analisis}")
            archivo_md = File.basename(archivo)
            archivo = $l_g_xhtml_analisis
            borrar = archivo
        else
            borrar = nil
        end

        analisis_crudo = file_to_hash archivo
    end

    # Extrae las palabras y etiquetas
    conjunto_palabras_cifras = extraccion(analisis_crudo)
    conjunto_etiquetas = extraccion(analisis_crudo, true)

    # Separa las palabras y las cifras
    conjunto_palabras = separacion(conjunto_palabras_cifras)
    conjunto_cifras = separacion(conjunto_palabras_cifras, true)

    # Se usa hunspell para encontrar posibles erratas

    # Se crea el archivo para que hunspell lo analice
    archivo_hunspell = File.new($l_an_archivo_hunspell, 'w:UTF-8')
    archivo_hunspell.puts conjunto_palabras_cifras.uniq
    archivo_hunspell.close

    # Se inicia hunspell
    begin
        puts $l_an_analizando_hunspell
        hunspell = `hunspell -d es_MX,en_US,pt_BR,it_IT,de_DE -l #{arregloRutaTerminal($l_an_archivo_hunspell)} | sort`
        hunspell = hunspell.split("\n")
    rescue
        puts $l_an_advertencia_hunspell.yellow.bold
        hunspell = []
    end

    # Se borra el archivo que usó hunspell
    File.delete($l_an_archivo_hunspell)

    # Se usa linkchecker para verificar los enlaces

    # Si es un archivo EPUB
    if File.extname(archivo) == ".epub"
        archivo_linkchecker = []

        # Se obtienen todos los archivos HTML
        analisis_crudo['htmls'].each do |html|
            archivo_linkchecker.push(html['path'])
        end

        # Se unen para formar una sola línea separados con un espacio
        archivo_linkchecker = archivo_linkchecker.join(' ')

        # Servirá para acortar las rutas en el conjunto final
        criterio_division = $l_g_epub_analisis
    # Si no es EPUB, el archivo a analizar es el mismo del input
    else
        archivo_linkchecker = archivo
        criterio_division = File.basename(archivo)
    end

    # Se inicia linkchecker
    begin
        puts $l_an_analizando_linkchecker, $l_g_linea
        linkchecker_crudo = `linkchecker #{arregloRutaTerminal(archivo_linkchecker)} --check-extern --verbose -o csv`
        linkchecker_crudo = linkchecker_crudo.split("\n")
        puts $l_an_fin_linkchecker, $l_g_linea
    rescue
        puts $l_an_advertencia_linkchecker.yellow.bold
        puts $l_g_linea
        linkchecker_crudo = []
    end

    # Se convierte la salida CSV a un conjunto de hashes
    linkchecker = []

    # Solo se llena el conjunto si el análisis de linkchecker arrojó alguna salida
    if linkchecker_crudo.length != 0

        # Servirá para obtejer cada una de las llaves
        linkchecker_llaves = []

        # Iteración de cada resultado
        linkchecker_crudo.each do |e|

            # Solo si cumple con la sintaxis esperada del resultado
            if e =~ /.*?;.*?;.*?;.*?;.*?;.*?;.*?;.*?;.*?;.*?;.*?;.*?;.*?;.*?;.*?;.*?;.*?/
                # Convierte la línea en un conjuto porque cada elemento será una llave o un valor
                elementos = e.split(";")

                # Crea las llaves
                if e =~ /^urlname;/
                    elementos.each do |ee| linkchecker_llaves.push(ee) end
                # Obtiene los valores
                else
                    obj = {}

                    # Se llena de valor a la llave correcta
                    elementos.each_with_index do |ee, i|
                        obj["#{linkchecker_llaves[i]}"] = if ee =~ /^file:/ then (ee.split(criterio_division)[1] != nil ? '.' +  ee.split(criterio_division)[1] : (archivo_md == nil ? criterio_division : archivo_md)) else ee end
                    end

                    # Se manda el objeto al conjunto
                    linkchecker.push(obj)
                end
            end
        end
    end

    # Se empieza la creación del hash final
    analitica = {}

    # Agrega el nombre del archivo o del libro
    if archivo_md != nil
        analitica['title'] = archivo_md
    else
        if analisis_crudo['opf'] != nil
            analisis_crudo['opf']['content'][0]['$package']['content'][0]['$metadata']['content'].each do |m|
                if m['$dc:title']
                    analitica['title'] = m['$dc:title']['content'][0]
                end
            end

            if analitica['title'] == nil
                analitica['title'] = File.basename(archivo)
            end
        else
            analitica['title'] = File.basename(archivo)
        end
    end

    # Incrusta todos los conjuntos de palabras
    analitica = incrustar_analitica(analitica, conjunto_palabras_cifras, 'words_digits', 1)
    analitica = incrustar_analitica(analitica, conjunto_palabras, 'words', 2)
    analitica = incrustar_analitica(analitica, conjunto_cifras, 'digits', 3)
    analitica = incrustar_analitica(analitica, $conjunto_no_identificados, 'unknown', 4)
    analitica = incrustar_analitica(analitica, $conjunto_versales, 'uppercase', 5)

    # Incrusta los elementos para poder obtener frecuencias de uso
    analitica = incrustar_analitica_top(analitica, conjunto_palabras)

    # Incrusta la diversidad
    puts "#{$l_an_creando_analitica[0] + $l_an_creando_analitica[7] + $l_an_creando_analitica.last}".green
    analitica['diversity'] = analitica['words']['all'] / analitica['words']['uniq_case_on'].to_f

    # Incrusta las etiquetas
    tags = contabilizar_etiquetas(conjunto_etiquetas)
    analitica['tags'] = {'all' => conjunto_etiquetas.length, 'types' => tags.length, 'list' => tags}

    # Incrusta los datos de hunspell
    if hunspell.length != 0
        puts "#{$l_an_creando_analitica[0] + $l_an_creando_analitica[9] + $l_an_creando_analitica.last}".green
        analitica['hunspell'] = {'all' => hunspell.length, 'list' => contabilizar(hunspell)}
    end

    # Incrusta los datos de linkchecker
    if linkchecker.length != 0
        puts "#{$l_an_creando_analitica[0] + $l_an_creando_analitica[10] + $l_an_creando_analitica.last}".green
        analitica['linkchecker'] = {'all' => linkchecker.length, 'list' => linkchecker}
    end

    # El análisis profundo requiere de un archivo
    if $deep_analysis
        if (!json && !yaml)
            puts $l_an_advertencia_deep.yellow.bold
            json = true
        else
            puts $l_an_advertencia_deep.green
        end
    end

    # Crea el archivo HTML con las analíticas sencillas
    puts "#{$l_an_creando_archivo[0] + $l_an_creando_archivo[5] + $l_an_creando_archivo[1] + $l_an_archivo_nombre + 'html' + $l_an_creando_archivo[2]}".green

    # Obtiene los archivos necesarios para crear el HTML
    archivos_rutas_css = obtener_rutas_archivos(archivos_rutas_css, File.dirname(__FILE__) + '/src/css', '.css')
    archivos_rutas_js = obtener_rutas_archivos(archivos_rutas_js, File.dirname(__FILE__) + '/src/js', '.js')
    archivos_rutas_html = obtener_rutas_archivos(archivos_rutas_html, File.dirname(__FILE__) + '/src/', '.html')

    # Primero se añade los estilos por defecto del CSS
    css = []
    css.push('            ' + $css_template_min)

    # Obtiene el contenido de los archivos
    css = obtener_contenido_archivo(archivos_rutas_css, css, '            ', 'styles.css')
    archivos_contenido_js = obtener_contenido_archivo(archivos_rutas_js, archivos_contenido_js, '            ')
    archivos_contenido_html = obtener_contenido_archivo(archivos_rutas_html, archivos_contenido_html, '', "index-#{$lang}.html")

    # Se hacen las sustituciones necesarias para tener el JavaScript final
    js = []
    js = cambios_js(analitica, archivos_contenido_js)

    # Se hacen las sustituciones necesarias para tener el HTML final
    html = []
    html = cambios_html(archivos_contenido_html, analitica, js, css)

    # Por fin crea el HTML
    archivo_html = File.new($l_an_archivo_nombre + 'html', 'w:UTF-8')
    archivo_html.puts html
    archivo_html.close

    # Crea el archivo JSON si así se pidió
    if json
        puts "#{$l_an_creando_archivo[0] + $l_an_creando_archivo[3] + $l_an_creando_archivo[1] + $l_an_archivo_nombre + 'json' + $l_an_creando_archivo[2]}".green
        archivo_json = File.new($l_an_archivo_nombre + 'json', 'w:UTF-8')
        archivo_json.puts JSON.pretty_generate(analitica)
        archivo_json.close
    end

    # Crea el archivo YAML si así se pidió
    if yaml
        puts "#{$l_an_creando_archivo[0] + $l_an_creando_archivo[4] + $l_an_creando_archivo[1] + $l_an_archivo_nombre + 'yaml' + $l_an_creando_archivo[2]}".green
        archivo_json = File.new($l_an_archivo_nombre + 'yaml', 'w:UTF-8')
        archivo_json.puts analitica.to_yaml
        archivo_json.close
    end

    # Se borran los archivos que ya no son necesarios
    if borrar != nil
        FileUtils.rm_rf(borrar)
    end

    puts $l_g_fin

rescue
    puts $l_an_error_general
end
