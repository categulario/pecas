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
					# Si si hay un elemento siguiente, se avanza, marca error y aborta si no
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

# Enmienda ciertos problemas con la línea de texto
def arregloRuta (elemento)
	# Elimina espacios al inicio y al final
    elemento = elemento.strip

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
