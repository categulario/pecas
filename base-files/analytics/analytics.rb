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
json = argumento "--json", json, 1
yaml = argumento "--yaml", yaml, 1
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
            elemento.split(/\s+/).each do |p|
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

    $resultado_extraccion = $resultado_extraccion.sort
end

# Separa las palabras y las cifras
def separacion conjunto, cifras = false

    puts "#{$l_an_separando[0] + (!cifras ? $l_an_separando[1] : $l_an_separando[2]) + $l_an_separando[3]}".green

    # La condición es según si se quieren palabras o cifras
    condicion = cifras ? /^\p{N}+$/ : /^[\p{L}|\p{M}]+$/
    conjunto_final = []
    $conjunto_no_identificados = []

    conjunto.each do |e|
        if e =~ condicion
            conjunto_final.push(e)
        # Hay elementos que tienen mezcla de cifras y palabras, por lo que no pueden identificarse
        elsif e !~ /^\p{N}+$/ && e !~ /^[\p{L}|\p{M}]+$/
            $conjunto_no_identificados.push(e)
        end
    end

    conjunto_final
end

#begin
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
        hunspell = `hunspell -d es_MX,en_US,pt_BR,it_IT,de_DE -l #{$l_an_archivo_hunspell} | sort | uniq`
        hunspell = hunspell.split("\n")
    rescue
        puts $l_an_advertencia_hunspell
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
        linkchecker_crudo = `linkchecker #{archivo_linkchecker} --check-extern --verbose -o csv`
        linkchecker_crudo = linkchecker_crudo.split("\n")
        puts $l_g_linea
    rescue
        puts $l_an_advertencia_linkchecker
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

    # Todos son conjuntos:
    #   * conjunto_palabras_cifras
    #   * conjunto_palabras
    #   * conjunto_cifras
    #   * conjunto_etiquetas
    #   * $conjunto_no_identificados
    #   * hunspell
    #   * linkchecker
    #       * Cada uno de sus elementos es un hash, las llaves de interés son urlname, parentname, result y valid

    # Estadísticas
    #   * Cantidad de palabras y cifras
    #   * Cantidad de palabras
    #   * Cantidad de palabras únicas
    #   * Índice de diversidad => CP / CPU
    #   * Cantidad de cifras
    #   * Cantidad de cifras únicas
    #   * Cantidad de etiquetas
    #   * Cantidad de etiquetas únicas
    #   * NUBE de palabras: https://github.com/jasondavies/d3-cloud
    #   * Lista de palabras, cada una indicando su frecuencia y porcentaje
    # Marcado
    #   * Lista de etiquetas, cada una indicando cantidades totales y únicas
    #   * Lista por etiqueta y sus distintas aparaciones
    # Comprobación de enlaces => linkchecker
    #   * Lista de enlaces y su estatus
    # Posibles erratas => hunspell
    #   * Lista de palabras únicas por orden alfabético en ES, EN, FR, PT y IT, DE
    # Cifras
    #   * Lista de cifras únicas
    # Versales
    #   * Lista de versales únicas
    # No identificadas
    #   * Lista de uniones únicas: OJO no son literales

    # Se borran los archivos que ya no son necesarios
    if borrar != nil
        FileUtils.rm_rf(borrar)
    end

    puts $l_g_fin
# DESCOMENTAR
#rescue
#    puts $l_an_error_general
#end
