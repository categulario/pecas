#!/usr/bin/env ruby
# encoding: UTF-8
# coding: UTF-8

require 'fileutils'

Encoding.default_internal = Encoding::UTF_8

# Funciones y módulos comunes a todas las herramientas
require File.dirname(__FILE__) + "/../../src/common/general.rb"
require File.dirname(__FILE__) + "/../../src/common/lang.rb"
require File.dirname(__FILE__) + "/../../src/common/css-template.rb"
require File.dirname(__FILE__) + "/../../src/common/css-template-legacy.rb"

# Argumentos
directory = if argumento "-d", directory != nil then argumento "-d", directory else Dir.pwd end
add = argumento "--add", add
argumento "-v", $l_ad_v
argumento "-h", $l_ad_h

# Variables
js = File.dirname(__FILE__) + "/../../epub/src/js/"

# Comprueba que existan los argumentos necesarios
comprobacion [add]

# Elimina la «/» al final del path si la tiene
if directory[-1] == '/' then directory = directory[0..-2] end

# Añade la hoja de estilo CSS actual
if add == 'css' || add == 'css-legacy'
    puts "#{$l_ad_anadiendo_css[0] + if add.split('-').last != 'css' then ' ' + add.split('-').last else '' end + $l_ad_anadiendo_css[1]}"
	archivo = File.new(directory + '/' + 'styles.css', 'w:UTF-8')
	if add == 'css' then archivo.puts $css_template else archivo.puts $css_template_legacy end
	archivo.close
# Añade algún script de JavaScript
elsif add == 'poetry' || add == 'zoom'
    puts "#{$l_ad_anadiendo_js[0] + add + $l_ad_anadiendo_js[1]}".green
    FileUtils.cp(js + add + '.js', directory)
end

puts $l_g_fin
