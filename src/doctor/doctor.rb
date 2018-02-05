#!/usr/bin/env ruby
# encoding: UTF-8
# coding: UTF-8

require 'fileutils'

Encoding.default_internal = Encoding::UTF_8

# Funciones y módulos comunes a todas las herramientas
require File.dirname(__FILE__) + "/../../src/common/general.rb"
require File.dirname(__FILE__) + "/../../src/common/lang.rb"

# Argumentos
argumento "-v", $l_dr_v
argumento "-h", $l_dr_h
update = argumento "--update", update, 1
install = argumento "--install-dependencies", install, 1
restore = argumento "--restore", restore, 1

# Obtiene las versiones de cada dependecia
def revisionDependencias d
    salida = []

    # Itera el hash
    d.select do |k, v|
        # Obtiene la versión, eliminando todo posible texto y dejando solo el número
        begin
            output = `#{k} --version`
            version = output.split("\n")[0].gsub(/^.*?\s+/,'')
        # Si no existe, determina que falta una dependencia
        rescue
            version = $l_dr_no_instalado
            $no_instalado = true
        end

        # Da el nombre, la versión y las herramientas que lo necesita
        salida.push('  ' + v["nombre"] + ': ' + version + " [#{v["pecas"].join(', ')}]")
    end

    return salida.join("\n")
end

# Variables
$no_instalado = false
dependencias = {
    "pandoc" => {
        "nombre" => "Pandoc", 
        "pecas" => ["pc-pandog","pc-notes"]
    }, 
    "tesseract" => {
        "nombre" => "Tesseract",
        "pecas" => ["pc-tegs"]
    },
    "gs" => {
        "nombre" => "Ghostscript",
        "pecas" => ["pc-tegs"]
    }
}

# Va a la raíz de Pecas
Dir.chdir(File.dirname(__FILE__) + '/../..')

# Si solo es información
if !update && !install && !restore
    # Revisa si Pecas está actualizado
    system ("bash #{File.dirname(__FILE__) + '/check-update.sh'}")

    # Da los datos generales y las dependencias
    puts $l_dr_generales, $l_dr_v, $l_dr_dependencias, revisionDependencias(dependencias)

    # Si no hay alguna dependencia instalada
    if $no_instalado
        puts $l_dr_linea, $l_dr_falta
    end
# Si es restauración, actualización o instalación de terceros
else
    if restore
        puts $l_dr_restaurando, $l_dr_linea
        system("git reset --hard")
    end

    if update
        puts $l_dr_actualizando, $l_dr_linea
        system("git pull origin master")
    end

    if install
       puts "install"
    end
end
