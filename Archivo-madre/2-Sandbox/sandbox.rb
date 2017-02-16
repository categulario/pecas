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
require File.dirname(__FILE__) + "/../../otros/secundarios/xhtml-beautifier.rb"

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
archivo = comprobacionArchivo archivo, [".html", ".xhtml", ".htm"]

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
	criterio = /<.*?h1.*?>.*?<\/.*?h1.*?>/i
end

if carpeta == nil
	carpeta = Dir.pwd
end

# Se va a la carpeta para crear los archivos
carpeta = comprobacionDirectorio carpeta
Dir.chdir(carpeta)



puts $l_g_fin
