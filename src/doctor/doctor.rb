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

# Variables
$no_instalado = false
dependencias = {
    'zip' => {
        'nombre' => 'Zip',
        'paquete' => ['zip'],
        'pecas' => ['pc-automata','pc-recreator','pc-changer'],
        'version' => false
    },
    'unzip' => {
        'nombre' => 'UnZip',
        'paquete' => ['unzip'],
        'pecas' => ['pc-automata','pc-changer'],
        'version' => false
    },
    'pandoc' => {
        'nombre' => 'Pandoc', 
        'paquete' => ['pandoc'],
        'pecas' => ['pc-pandog'],
        'version' => false
    },
    'convert' => {
        'nombre' => 'ImageMagick', 
        'paquete' => ['imagemagick'],
        'pecas' => ['pc-automata','pc-images'],
        'version' => true
    },
    'hunspell' => {
        'nombre' => 'Hunspell', 
        'paquete' => ['hunspell'],
        'pecas' => ['pc-automata','pc-analytics'],
        'version' => false
    },
    'linkchecker' => {
        'nombre' => 'Linkchecker', 
        'paquete' => ['linkchecker'],
        'pecas' => ['pc-automata','pc-analytics'],
        'version' => true
    },
    'tesseract' => {
        'nombre' => 'Tesseract',
        'paquete' => ['tesseract-ocr','tesseract-ocr-spa','tesseract','tesseract-data-spa','tesseract --with-all-languages'],
        'pecas' => ['pc-tiff2pdf'],
        'version' => false
    },
    'tiffcp' => {
        'nombre' => 'Libtiff',
        'paquete' => ['libtiff'],
        'pecas' => ['pc-tiff2pdf'],
        'version' => nil
    }
}

# Obtiene las versiones de cada dependecia
def revisionDependencias install, d
    salida = []
    no_instalados = true

    # Itera el hash
    d.select do |k, v|
        # Obtiene la versión, eliminando todo posible texto y dejando solo el número
        begin
            if v['version'] == nil
                version = $l_dr_nil_instalado
            else
                output = v['version'] ? `#{k} --version` : `#{k} -v`

                version = k == 'zip' ? output.split("\n")[1] : output.split("\n")[0].gsub(/^.*?\s+/,'').strip
                version = version.gsub(/^[A-Za-z\s,\.:;]*?(\d.*?)\s.*$/, '\1')

                # Si no encuentra una fórmula con solo números, puntos o guiones, solo indica que está instalado
                if version.gsub(/[\d|\.|-|_|-]/,'') != ''
                    version = $l_dr_instalado
                end
            end
        # Si no existe, determina que falta una dependencia
        rescue
            # Cuando es «pc-doctor»
            if !install
                version = $l_dr_no_instalado
                $no_instalado = true
            # Cuando es «pc-doctor --install-dependencies»
            else
                # Elige la sintaxis según el gestor; para el caso de tesseract, se eligen los paquetes correctos
                if $gestor == 1 || $gestor == 3
                    g = $gestor == 1 ? 'sudo apt-get install' : 'sudo apt install'
                    paquete = k == 'tesseract' ? v['paquete'][0..1].join(' ') : v['paquete'].join(' ')
                elsif $gestor == 2
                    g = 'sudo pacman -S'
                    paquete = k == 'tesseract' ? v['paquete'][2..3].join(' ') : v['paquete'].join(' ')
                elsif $gestor == 4
                    g = 'brew install'
                    paquete = k == 'tesseract' ? v['paquete'][4] : v['paquete'].join(' ')
                end

                # Comando que se utilizará
                comando = "#{g} #{paquete}"
                puts "#{$l_dr_instalando[0]} #{v['nombre']} #{$l_dr_instalando[1]}\n   #{comando}"

                # Inicia la ejecución del comando
                begin
                    system(comando)
                    no_instalados = false
                rescue
                    puts $l_dr_error.red.bold
                end
            end
        end

        # Da el nombre, la versión y las herramientas que lo necesita
        if !install then salida.push('  ' + v["nombre"] + ': ' + version + " [#{v["pecas"].join(', ')}]") end
    end

    if !install
        return salida.join("\n")
    else
        return no_instalados ? "\n" + $l_g_linea + "\n" + $l_dr_instalando_nan : "\n" + $l_g_linea + "\n" + $l_dr_instalando_fin
    end
end

# Pregunta por el tipo de gestor de paquetes
def pregunta
	print $l_dr_pregunta.blue.bold
	respuesta = STDIN.gets.chomp.downcase.to_i
    if respuesta == 0
        puts $l_dr_ninguno.red.bold
        abort
    elsif respuesta > 4
        puts $l_dr_mayor.red.bold
        abort
    else
        return respuesta
    end
end

# Va a la raíz de Pecas
Dir.chdir(File.dirname(__FILE__) + '/../..')

# Si solo es información
if !update && !install && !restore
    # Revisa si Pecas está actualizado
    system ("bash #{File.dirname(__FILE__) + '/check-update.sh'}")

    # Da los datos generales y las dependencias
    puts $l_dr_generales, obtener_version(true), $l_dr_dependencias, revisionDependencias(install, dependencias)

    # Si no hay alguna dependencia instalada
    if $no_instalado
        puts $l_g_linea, $l_dr_falta
    end
# Si es restauración, actualización o instalación de terceros
else
    if restore
        puts $l_dr_restaurando, $l_g_linea
        commit = `git ls-remote -q --refs`
        commit = commit.split("\t")[0]
        system("git reset --hard #{commit}")
    end

    if update
        puts $l_dr_actualizando, $l_g_linea
        system("git pull origin master")
    end

    if install
        $gestor = pregunta
        puts $l_dr_advertencia.yellow.bold
        if OS.mac?
            puts "", $l_g_linea, $l_dr_instalando_xcode
            system("xcode-select --install")
            puts "", $l_g_linea, $l_dr_instalando_brew
            system("/usr/bin/ruby -e \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)\"")
        end
        puts revisionDependencias(install, dependencias)
    end
end
