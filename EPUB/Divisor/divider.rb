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

### DIVIDER ###
