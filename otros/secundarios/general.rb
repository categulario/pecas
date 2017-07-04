#!/usr/bin/env ruby
# encoding: UTF-8
# coding: UTF-8

Encoding.default_internal = Encoding::UTF_8

# Funciones y módulos comunes a todas las herramientas
require File.dirname(__FILE__) + "/../secundarios/lang.rb"

## MÓDULOS

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

## CLASES

# Para detectar que es un número entero; viene de: http://stackoverflow.com/questions/1235863/test-if-a-string-is-basically-an-integer-in-quotes-using-ruby
class String
    def is_i?
		/\A[-+]?\d+\z/ === self
    end
end

## FUNCIONES

# Obtiene los argumentos
def argumento condicion, resultado, tipo = 0
	# 0 ==> quiere texto
	# 1 ==> quiere booleano
	
	# Iteración hasta encontrar la condición buscada
	ARGF.argv.each_with_index do |p, i|
		if p == condicion
			# Si se introdujo un texto, se imprime y aborta el scrip; se usa para -v o -h, por ejemplo
			if resultado.is_a? String
				puts resultado
				abort
			# Si se trata de un parámetro nulo, se le da un valor
			else
				# Para cuando se quiere un booleano
				if tipo == 1
					resultado = true
				# Para cuando se quiere una línea de texto; toma el valor inmediato, p. ej. de -d tomará la ruta del directorio
				else
					# Si sí hay un elemento siguiente, se avanza, marca error y aborta si no
					begin
						# Si el siguiente argumento no empieza con «-» se registra el valor, marca error y aborta si no
						if ARGF.argv[i+1][0] != "-"
							resultado = ARGF.argv[i+1]
						else
							puts $l_g_error_arg2
							abort
						end
					rescue
						puts $l_g_error_arg
						abort
					end
				end
			end
		end
	end
	
	# Regresa el valor
	return resultado
end

# Comprueba que existan los argumentos necesarios
def comprobacion conjunto
	conjunto.each do |e|
		# Si al menos una de las variables es nulo, se muestra el error y aborta
		if e == nil
			puts $l_g_error_arg
			abort
		end
	end
end

# Comprueba que la carpeta sea válida
def comprobacionDirectorio carpeta
	if carpeta != nil
		c = carpeta
		carpeta = arregloRuta(File.absolute_path(carpeta))

		if !File.directory?(carpeta)
			puts "#{$l_g_error_directorio[0] + c + $l_g_error_directorio[1]}".red.bold
			abort
		else
			return carpeta
		end
	end
end

# Comprueba que el archivo sea válido
def comprobacionArchivo archivo, extension
	if archivo != nil
		a = archivo
		archivo = arregloRuta(File.absolute_path(archivo))
		valido = false
		
		# Comprueba de que exista
		if !File.exists?(archivo)
			puts "#{$l_g_error_archivo[0] + a + $l_g_error_archivo[1]}".red.bold
			abort
		end
		
		# Itera hasta dar con una extensión válida
		extension.each do |e|
			if File.extname(archivo) == e
				valido = true
				break
			end
		end
		
		#Comprueba que sea una extensión válida
		if !valido
			puts puts "#{$l_g_error_archivo2[0] + a + $l_g_error_archivo2[1]}".red.bold
			abort
		end
		
		return archivo
	end
end

# Enmienda ciertos problemas con la línea de texto
def arregloRuta elemento
	# Elimina espacios al inicio y al final
    elemento = elemento.strip

    # Elimina caracteres conficlitos
    elementoFinal = elemento.gsub("file:","").gsub("%20"," ")

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

# Enmienda ciertos problemas con la línea de texto pasa su uso directo en el sistema
def arregloRutaTerminal elemento
	ruta = elemento
	
	if OS.windows?
		ruta = '"' + ruta + '"'
	else
		ruta = ruta.gsub(/\s/, "\\ ")
	end
	
	return ruta
end

# Obtiene el directorio donde se encuentra el archivo
def directorioPadre archivo
	directorio = ((arregloRuta File.absolute_path(archivo)).split("/"))[0..-2].join("/")
end

# Obtiene el directorio donde se encuentra el archivo para uso directo en el sistema
def directorioPadreTerminal archivo
	directorio = ((arregloRuta File.absolute_path(archivo)).split("/"))[0..-2].join("/")

	if OS.windows?
		directorio = '"' + directorio + '"'
	else
		directorio = directorio.gsub(/\s/, "\\ ")
	end
	
	return directorio
end

def cambioContenido archivo_cambio, regex, contenido
	archivo_actualizado = Array.new
	
	# Analiza el archivo viejo y sustituye la línea deseada
	archivo = File.open(archivo_cambio, 'r:UTF-8')
	archivo.each do |linea|
		if linea =~ regex
			archivo_actualizado.push(contenido)
		else
			archivo_actualizado.push(linea)
		end
	end
	archivo.close
	
	# Se actualiza la información
	archivo = File.new(archivo_cambio, 'w:UTF-8')
	archivo.puts archivo_actualizado
	archivo.close
end

# Obtiene la ruta al archivo CSS
def archivoCSSBusqueda archivoCSS, carpeta
	if archivoCSS != nil
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
end

# Verifica que la codificación sea UTF-8, de lo contrario, la corrige
def codificacionValida? elemento
	if ! elemento.valid_encoding?
		elemento = elemento.encode("UTF-16be", :invalid=>:replace, :replace=>"?").encode('UTF-8')
		elemento.gsub(/dr/i,'med')
	end
	
	return elemento
end
