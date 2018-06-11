#!/usr/bin/env ruby
# encoding: UTF-8
# coding: UTF-8

require 'fileutils'

Encoding.default_internal = Encoding::UTF_8

# Funciones y módulos comunes a todas las herramientas
require File.dirname(__FILE__) + "/../../src/common/general.rb"
require File.dirname(__FILE__) + "/../../src/common/lang.rb"
require File.dirname(__FILE__) + "/../../src/common/css-template.rb"
require File.dirname(__FILE__) + "/../../src/common/xhtml-template.rb"

# Argumentos
epub_nombre = if argumento "-e", epub_nombre != nil then argumento "-e", epub_nombre else nil end
epub_version = if argumento "--version", epub_version != nil then argumento "--version", epub_version else nil end
standalone = argumento "--standalone", standalone, 1
argumento "-v", $l_ch_v
argumento "-h", $l_ch_h
version_disponible = ['2.0.0','2.0.1','3.0.0','3.0.1']
version_actual = ''

# Comprueba que existan los argumentos necesarios
comprobacion [epub_nombre]

# Comprueba que los argumentos necesarios existan
if epub_nombre == nil || epub_version == nil
    puts $l_g_error_arg
    abort
end

# Nombre final que tendrá el EPUB
epub_nombre_final = File.basename(epub_nombre, '.*') + '_' + epub_version.gsub('.','-') + '.epub'

# Borra el proyecto si no es necesario o compatible
def borrar_proyecto
    FileUtils.rm_rf($l_g_epub_analisis)
    abort
end

# Obtiene la versión actual del EPUB
def version obj, epub_version
    v = obj["opf"]["content"][0]["$package"]["attributes"]["_version"].to_i

    # Compara para ver si es posible la conversión
    def comparacion v, epub_version
        # Si se quiere cambiar entre versiones 2, o bajar la versión 3 a 2
        if (epub_version.to_i == 2 && v.to_i == 2) || (epub_version.to_i == 2 && v.to_i == 3)
            puts $l_ch_error_version2
            borrar_proyecto
        # Si son la misma versión 3
        elsif v == epub_version
            puts "#{$l_ch_error_version3[0] + v + $l_ch_error_version3[1]}".red.bold
            borrar_proyecto
        else
            return v
        end
    end

    if v == 2
        comparacion(v.to_s, epub_version)
    else
        if obj["opf"]["content"][0]["$package"]["attributes"]["_prefix"] =~ /rendition/
            comparacion('3.0.0', epub_version)
        else
            comparacion('3.0.1', epub_version)
        end
    end
end

# Ambos argumentos son necesarios
if epub_nombre == nil || epub_version == nil
    puts $l_g_error_arg
    abort
end

# Comprueba si es un EPUB, obtiene su ruta y su directorio padre
epub_nombre = comprobacionArchivo epub_nombre, [".epub"]

# Comprueba que la versión sea una soportada
version_existente = false
version_disponible.each do |v|
    if v == epub_version
       version_existente = true
        break
    end
end
if !version_existente then puts "#{$l_ch_error_version[0] + epub_version + $l_ch_error_version[1]}".red.bold; abort end

# Va al directorio padre del EPUB
Dir.chdir(directorioPadre epub_nombre)

# Analiza el EPUB para obtener un hash con el OPF y todos los HTML
puts "#{$l_ch_iniciando_conversion[0] + File.basename(epub_nombre) + $l_ch_iniciando_conversion[1] + epub_version + $l_ch_iniciando_conversion[2]}".green
epub_objeto = epub_analisis(epub_nombre)

# Obtiene la versión y analiza si la conversión es pertinente
version_actual = version(epub_objeto, epub_version)

# Si la versión del EPUB es >= 3
puts $l_ch_iniciando
if version_actual.to_i == 3
    if version_actual == '3.0.0'
        epub_objeto["opf"]["content"][0]["$package"]["attributes"]["_prefix"] = epub_objeto["opf"]["content"][0]["$package"]["attributes"]["_prefix"].gsub(/rendition:\s+.*?\s+/,'').gsub(/schema:\s+.*?\s+/,'')
    elsif version_actual == '3.0.1'
        epub_objeto["opf"]["content"][0]["$package"]["attributes"]["_prefix"] = 'rendition: http://www.idpf.org/vocab/rendition/# schema: http://schema.org/ ' + epub_objeto["opf"]["content"][0]["$package"]["attributes"]["_prefix"]
    end

	archivo = File.new(epub_objeto["opf"]["path"], 'w:UTF-8')
	archivo.puts hash_to_html(epub_objeto["opf"])
	archivo.close

    # Empieza la compresión del EPUB
    puts "#{$l_ch_creando[0] + epub_version + $l_ch_creando[1] + epub_nombre_final + $l_ch_creando[2] + directorioPadre(epub_nombre) + $l_ch_creando[3]}".green
    Dir.chdir($l_g_epub_analisis)

    # Obtiene el nombre de la carpeta donde están los contenidos del EPUB
    ops = epub_objeto["opf"]["path"].gsub($l_g_epub_analisis, '').split('/')[1]

    # Crea el EPUB
    system ("zip #{arregloRutaTerminal('../' + epub_nombre_final)} -X mimetype -q")
    system ("zip #{arregloRutaTerminal('../' + epub_nombre_final)} -r #{ops} META-INF -x \*.DS_Store \*._* -q")

    # Elimina el proyecto EPUB si así se indicó
    Dir.chdir('..')
    if standalone != true then FileUtils.rm_rf($l_g_epub_analisis) end

    # Fin
    puts $l_g_fin
# Si la versión del EPUB es 2
else
    if standalone != true then puts $l_ch_advertencia_standalone end

    # Para localizar la imagen de portada
    puts $l_ch_extrayendo
    portada_archivo = nested_hash_value(epub_objeto["opf"], '_type', /cover/)
    portada = nil

    # Si hay un archivo considerado HTML como portada
    if portada_archivo != nil
        epub_objeto["htmls"].each do |h|
            # Si el archivo HTML es asignado para la portada
            if h["file"] == File.basename(portada_archivo["_href"])
                # Extrae el nombre de la imagen de portada si lo hay
                if nested_hash_value(h["content"][0], '_src', /^.*$/) != nil then portada = File.basename(nested_hash_value(h["content"][0], '_src', /^.*$/)["_src"]) end
            end
        end
    end

    # Para localizar los metadatos
    $metadata_para_epub = {}

    begin
        # Incluye los metadatos al objeto
        def incluir_metadata llave, valor
            $metadata_para_epub["#{llave}"] = valor
        end

        # Iteración de los contenidos del paquete OPF
        epub_objeto["opf"]["content"][0]["$package"]["content"].each do |e|
            if e["$metadata"]
                # Si hay metadatos, se iteran
                e["$metadata"]["content"].each do |h|
                    h.each do |k, v|
                        if k =~ /\$dc:/
                            # Si es el título
                            if k =~ /title/
                                incluir_metadata('title', v["content"])
                            # Si es el autor
                            elsif k =~ /creator/
                                incluir_metadata('author', v["content"])
                            # Si es el editor
                            elsif k =~ /publisher/
                                incluir_metadata('publisher', v["content"])
                            # Si es la sinopsis
                            elsif k =~ /description/
                                incluir_metadata('synopsis', v["content"])
                            # Si es la categoría
                            elsif k =~ /subject/
                                incluir_metadata('category', v["content"])
                            end
                        end
                    end
                end
            end
        end
    # Si existe algún error, se menciona que no fue posible obtener los metadatos
    rescue
        $metadata_para_epub = nil
        puts $l_ch_advertencia_metadata
    end

    # Crea el proyecto EPUB con el nombre del EPUB
    system("ruby #{File.dirname(__FILE__)+ "/../creator/creator.rb"} -o #{File.basename(epub_nombre, '.*')} --no-pre")

    # Remueve todas las carpetas de contenido del proyecto
    Dir.glob(File.basename(epub_nombre, '.*') + '/OPS/*') do |fichero|
        if File.directory?(fichero)
            FileUtils.rm_rf(fichero)
        end
    end

	# Se empieza a analizar el YAML
    puts "#{$l_ch_incluyendo[0] + $l_g_meta_data + $l_ch_incluyendo[1]}".green
    yaml_nuevo = []
    no_push = false
	archivo_abierto = File.open($l_g_meta_data, 'r:UTF-8')
	archivo_abierto.each do |linea|
        if no_push
            yaml_nuevo.push('author: ' + $metadata_para_epub['author'].to_s)
            no_push = false
        else
            if linea =~ /^title:/
                if $metadata_para_epub['title'] != nil
                    yaml_nuevo.push('title: "' + $metadata_para_epub['title'][0].gsub('"', '\"') + '"')
                end
            elsif linea =~ /^author:/
                no_push = true
            elsif linea =~ /^publisher:/
                if $metadata_para_epub['publisher'] != nil
                    yaml_nuevo.push('publisher: ' + $metadata_para_epub['publisher'].to_s)
                end
            elsif linea =~ /^synopsis:/
                if $metadata_para_epub['synopsis'] != nil
                    yaml_nuevo.push('synopsis: "' + $metadata_para_epub['synopsis'][0].gsub('"', '\"') + '"')
                end
            elsif linea =~ /^category:/
                if $metadata_para_epub['category'] != nil
                    yaml_nuevo.push('category: ' + $metadata_para_epub['category'].to_s)
                end
            elsif linea =~ /^cover:/
                yaml_nuevo.push('cover: ' + portada)
            else
                yaml_nuevo.push(linea)
            end
        end
	end
	archivo_abierto.close
	
	# Abre el archivo para meter los cambios
	archivo_abierto = File.open($l_g_meta_data, 'w:UTF-8')
	archivo_abierto.puts yaml_nuevo
	archivo_abierto.close

    # Añade los archivos
    puts "#{$l_ch_anadiendo[0] + File.basename(epub_nombre) + $l_ch_anadiendo[1]}".green
    Dir.glob(directorioPadre(epub_objeto["opf"]["path"]) + '/*') do |fichero|
        if File.extname(fichero) != '.ncx' && File.extname(fichero) != '.opf'
            FileUtils.cp_r(fichero, Dir.pwd + '/' + File.basename(epub_nombre, '.*') + '/OPS')
        end
    end

    # Elimina el proyecto viejo porque ya no es necesario
    FileUtils.rm_rf($l_g_epub_analisis)

    # Crea el EPUB en su versión más reciente
    system("ruby #{File.dirname(__FILE__)+ "/../recreator/recreator.rb"} -d #{File.basename(epub_nombre, '.*')}")

    # Si se pide una versión 3.0.0 en lugar de la más reciente
    if epub_version == '3.0.0'
        Dir.glob(Dir.pwd + '/*') do |archivo|
            if File.basename(archivo) =~ /#{File.basename(epub_nombre, '.*')}-.*?\.epub/
                system("ruby #{File.dirname(__FILE__)+ "/../changer/changer.rb"} -e #{archivo} --version 3.0.0")
                File.delete(archivo)
            end
        end
    end

    # Elimina el proyecto EPUB si así se indicó
    if standalone != true
        FileUtils.rm_rf(File.basename(epub_nombre, '.*'))
        File.delete($l_g_meta_data)
    end
end
