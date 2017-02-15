#!/usr/bin/env ruby
# encoding: UTF-8
# coding: UTF-8

# Es para eliminar tildes y ñ en los nombres de los archivos
require 'active_support/inflector'

Encoding.default_internal = Encoding::UTF_8

# Funciones y módulos comunes a todas las herramientas
require File.dirname(__FILE__) + "/../../otros/secundarios/general.rb"
require File.dirname(__FILE__) + "/../../otros/secundarios/lang.rb"
require File.dirname(__FILE__) + "/../../otros/secundarios/xhtml-template.rb"

# Argumentos
archivo = argumento "-f", archivo
carpeta = argumento "-d", carpeta
archivoCSS = argumento "-s", archivoCSS
indice = if argumento "-i", indice != nil then argumento "-i", indice else "3" end
argumento "-v", $l_di_v
argumento "-h", $l_di_h

# Comprueba que existan los argumentos necesarios
comprobacion [archivo, carpeta]

# Comprueba que el índice sea un número
if indice.is_i? == false
	puts $l_di_error_i
	abort
else
	indice = indice.to_i
end

# Se va a la carpeta para crear los archivos
Dir.chdir(carpeta)

# Obtiene la ruta al archivo CSS
def archivoCSSBusqueda archivoCSS, carpeta
	# Comprueba el archivo CSS
	archivoCSS = comprobacionCSS archivoCSS

	# Para sacar la ruta relativa al archivo CSS
	archivoConjuntoCSS = archivoCSS.split('/')
	separacionesConjuntoCarpeta = carpeta.split('/')

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
	rutaCSS = ("..#{'/'}" * separacionesConjuntoCarpeta.length) + archivoConjuntoCSS.join('/')
end

rutaCSS = archivoCSSBusqueda archivoCSS, carpeta

# Inicia la división
puts $l_di_dividiendo

# Para ver el contenido
archivoTodo = File.open(archivo, 'r:UTF-8')

# Variables necesarias para obtener la información
enEncabezado = false
parteArchivo = 0
parteArchivoViejo = 1
Objecto = Struct.new(:titulo, :encabezado, :contenido)
objeto = Objecto.new
contenidoConjunto = Array.new

# Crea los archivos
def creacion objeto, contenidoConjunto, rutaCSS, indice

    # Uniforma la numeración basada en tres dígitos
    def conteoString numero
        if numero < 10
            numeroTexto = "00" + numero.to_s
        elsif numero < 100
            numeroTexto = "0" + numero.to_s
        else
            numeroTexto = numero.to_s
        end

        return numeroTexto
    end

    objeto.contenido = contenidoConjunto

    # Obtiene el nombre del archivo a partir del título, eliminándose caracteres conflictivos, agregando el índice y el nombre de extensión
    nombreArchivo = ActiveSupport::Inflector.transliterate(objeto.titulo).to_s
    nombreArchivo = nombreArchivo.gsub(/[^a-z0-9\s]/i, "").gsub(" ", "-").downcase
    nombreArchivo = nombreArchivo.split("-")[0..4].join("-")
    nombreArchivo = conteoString(indice) + "-" + nombreArchivo + ".xhtml"

	puts "#{$l_di_creando[0] + nombreArchivo + $l_di_creando[1]}".green

    # Crea el archivo
    archivo = File.new(nombreArchivo, "w:UTF-8")
    archivo.puts xhtmlTemplateHead objeto.titulo, rutaCSS
    archivo.puts "        " + objeto.encabezado
    objeto.contenido.each do |linea|
        archivo.puts "        " + linea
    end
    archivo.puts $xhtmlTemplateFoot
    archivo.close

    # Para aumentar la numeración
    indice += 1
end

# Divide el archivo
archivoTodo.each do |linea|
    # Si se trata de un encabezado h1
    if linea =~ /<.*?h1.*?>.*?<\/.*?h1.*?>/i

        # Para no ignorar el contenido posterior aunque no se trate de un encabezado
        enEncabezado = true

        # Aumento del conteo de partes
        parteArchivo += 1

        # De esta manera se detecta una nueva parte
        if parteArchivoViejo < parteArchivo
            indice = creacion objeto, contenidoConjunto, rutaCSS, indice
            parteArchivoViejo = parteArchivo
        end
        
        # Elimina etiquetas HTML y etiquetas PT del encabezado
        lineaLimpia = linea.strip
						.gsub(/<(?!\S|\s+)*?br.*?>/, " ")
						.gsub(/<.*?>/, "")
						.gsub(/ºº.*?ºº/, "")

        # Obtención del título y el encabezado
        if lineaLimpia == ""
			objeto.titulo = $l_di_sin_titulo
        else
			objeto.titulo = lineaLimpia
        end
        
        objeto.encabezado = linea.gsub("H1", "h1").strip

        # Se limpia el conjunto con contenido
        contenidoConjunto = contenidoConjunto.clear
    # Si se trata de contenido después del primer encabezado
    elsif enEncabezado == true
        # Si es una línea que no tiene </body> o </html>
        if linea !~ /body>/i && linea !~ /html>/i
            contenidoConjunto.push(linea.strip)

            # Si se trata de la última línea, se crea el archivo; por si el documento no cuenta con etiquetas de body o html
            if archivoTodo.eof? == true
                indice = creacion objeto, contenidoConjunto, rutaCSS, indice
            end
        # Si se llega el fin del body o html, se crea el último archivo y se termina el loop
        else
            indice = creacion objeto, contenidoConjunto, rutaCSS, indice
            break
        end
    end
end

puts $l_g_fin
