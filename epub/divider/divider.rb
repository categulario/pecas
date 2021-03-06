#!/usr/bin/env ruby
# encoding: UTF-8
# coding: UTF-8

Encoding.default_internal = Encoding::UTF_8

# Funciones y módulos comunes a todas las herramientas
require File.dirname(__FILE__) + "/../../src/common/general.rb"
require File.dirname(__FILE__) + "/../../src/common/lang.rb"
require File.dirname(__FILE__) + "/../../src/common/xhtml-template.rb"
require File.dirname(__FILE__) + "/../../src/common/xhtml-beautifier.rb"

# Argumentos
archivo = argumento "-f", archivo
carpeta = if argumento "-d", carpeta != nil then argumento "-d", carpeta else Dir.pwd end
archivoCSS = argumento "-s", archivoCSS
indice = if argumento "-i", indice != nil then argumento "-i", indice else "3" end
seccion = argumento "--section", seccion, 1
argumento "-v", $l_di_v
argumento "-h", $l_di_h

# Comprueba que existan los argumentos necesarios
comprobacion [archivo]

# Comprueba que el archivo tenga la extensión correcta
archivo = comprobacionArchivo archivo, [".html", ".xhtml", ".xml", ".htm"]

# Comprueba que el índice sea un número
if indice.is_i? == false
	puts $l_di_error_i
	abort
else
	indice = indice.to_i
end

# Define el criterio de división
if seccion
	criterio = /<(?!\/|.)*?section.*?>/i
else
	criterio = /<\s*?h1.*?>/i
end

# Comprueba el archivo CSS
archivoCSS = comprobacionArchivo archivoCSS, [".css"]

# Se va a la carpeta para crear los archivos
carpeta = comprobacionDirectorio carpeta
Dir.chdir(carpeta)

# Obtiene la ruta al archivo CSS
rutaCSS = get_relative_path(carpeta, archivoCSS)

# Inicia la división
puts $l_di_dividiendo

# Para ver el contenido
archivoTodo = File.open(archivo, 'r:UTF-8')

# Variables necesarias para obtener la información
enEncabezado = false
parteArchivo = 0
parteArchivoViejo = 1
Objecto = Struct.new(:titulo, :contenido)
objeto = Objecto.new
objeto.contenido = Array.new

# Crea los archivos
def creacion objeto, rutaCSS, indice

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
    
    # Obtiene el nombre del archivo a partir del título, eliminándose caracteres conflictivos, agregando el índice y el nombre de extensión
    begin
		nombreArchivo = transliterar objeto.titulo.to_s
	rescue
		nombreArchivo = transliterar $l_g_sin_titulo.to_s
	end
	
	# Añade un índice y la extensión
	nombreArchivo = conteoString(indice) + "-" + nombreArchivo.gsub(/_+/,"_") + ".xhtml"

	# Inicia la creación
	puts "#{$l_di_creando[0] + nombreArchivo + $l_di_creando[1]}".green
	
	# Prepara todo el contenido para el archivo
	contenidoTodo = Array.new
    
    # Añade cuerpo
    objeto.contenido.each do |linea|
		if linea.gsub(/<[^<]+?>$/, '') !~ /#{$l_g_ignore}$/ && linea.gsub(/<[^<]+?>$/, '') !~ /#{$l_g_ignore_b}$/
			contenidoTodo.push(linea.strip)
        end
    end

    # Crea el archivo
    archivo = File.new(nombreArchivo, "w:UTF-8")
    archivo.puts xhtmlTemplateHead objeto.titulo == nil ? $l_g_sin_titulo : objeto.titulo, rutaCSS
    archivo.puts contenidoTodo
    archivo.puts $xhtmlTemplateFoot
    archivo.close
    
    # Embellece el archivo
    beautifier archivo
    
    # Se limpia el conjunto con contenido
	objeto.contenido = objeto.contenido.clear

    # Para aumentar la numeración
    indice += 1
end

# Divide el archivo
tituloViejo = ""
archivoTodo.each do |linea|
	# Si se da con el criterio
	if linea =~ criterio

		# Para detectar que ya se encuentra adentro del body
		enEncabezado = true

		# Aumento del conteo de partes
		parteArchivo += 1
		
		# De esta manera se detecta una nueva parte
		if parteArchivoViejo < parteArchivo
			indice = creacion objeto, rutaCSS, indice
			parteArchivoViejo = parteArchivo
		end
		
		# Evita que se herede el título anterior si no hay h1 en el siguiente archivo cuando se divide por sección
		tituloViejo = objeto.titulo
	end
		
	if enEncabezado
		
		# Para obtener el título
		if linea =~ /<\s*?h1/i

			# Elimina etiquetas HTML y marcas PT del encabezado
			lineaLimpia = linea.strip
							.gsub(/\s*<(?!\S|\s+)*?br.*?>/, ". ")
							.gsub(/<.*?>/, "")
                            .gsub(/@\S+/, "")
							.gsub(/--.*?--/, "")
                            .strip

			# Obtención del título
			objeto.titulo = lineaLimpia
		end

        # Si es una línea que no tiene </body> o </html>
        if linea !~ /<\s*\/body>/i && linea !~ /\s*\/html>/i
            objeto.contenido.push(linea.strip)

            # Si se trata de la última línea, se crea el archivo; por si el documento no cuenta con etiquetas de body o html
            if archivoTodo.eof? == true
				objeto.titulo = seccion && objeto.titulo == tituloViejo ? $l_g_sin_titulo : objeto.titulo
                indice = creacion objeto, rutaCSS, indice
            end
        # Si se llega el fin del body o html, se crea el último archivo y se termina el loop
        else
			objeto.titulo = seccion && objeto.titulo == tituloViejo ? $l_g_sin_titulo : objeto.titulo
            indice = creacion objeto, rutaCSS, indice
            break
        end
    end
end

puts $l_g_fin
