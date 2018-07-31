#!/usr/bin/env ruby
# encoding: UTF-8
# coding: UTF-8

require 'fileutils'

Encoding.default_internal = Encoding::UTF_8

# Funciones y módulos comunes a todas las herramientas
require File.dirname(__FILE__) + "/../../src/common/general.rb"
require File.dirname(__FILE__) + "/../../src/common/lang.rb"

# Argumentos
images_dir = if argumento "-i", images_dir != nil then argumento "-i", images_dir else Dir.pwd end
resize = argumento "--resize", resize, 1
resize_h = if argumento "--resize-h", resize_h != nil then argumento "--resize-h", resize_h else nil end
resize_v = if argumento "--resize-v", resize_v != nil then argumento "--resize-v", resize_v else nil end
compress = argumento "--compress", compress, 1
argumento "-v", $l_im_v
argumento "-h", $l_im_h

# Variables
$resize_h_px = 640
$resize_v_px = 320
total_size_old = 0
total_size_new = 0
images = []
image_formats = [
    'aai','ai','bmp','bmp2','bmp3','cmyk','cmyka','epi','eps','eps2',
    'eps3','epsf','epsi','ept','ept2','ept3','hdr','icb','ico','icon',
    'ipl','jpe','jpeg','jpg','jpm','jps','jpt','picon','pjpeg','png',
    'png00','png24','png32','png48','png64','png8','pnm','ppm','ps','ps2',
    'ps3','psb','psd','ptif','tif','tiff','tiff64',
]

# Comprueba y obtiene la ruta absoluta a la carpeta
images_dir = comprobacionDirectorio images_dir

# Comprueba que al menos un parámetro se haya indicado
if resize == nil && compress == nil && resize_h == nil && resize_v == nil
    puts $l_im_error_nulo
    abort
end

# Verifica los resize particulares
def resize_validate r
    if r != nil
        r = r.to_i

        # Si la conversión a número entero es igual o menor a 0, no procede
        if r <= 0
            puts $l_im_error_unidad
            abort
        else
            return r
        end
    end
end

# Covierte de bytes a megabytes y redondea
def rounded f
    return (((f / 1024 / 1024) * 100).round / 100.0).to_f
end

# Valida unidades de medida
resize_h = resize_validate(resize_h)
resize_v = resize_validate(resize_v)

# Da los tamaños por defecto sin sobreescribir lo indicado por el usuario
if resize
    if resize_h == nil then resize_h = $resize_h_px end
    if resize_v == nil then resize_v = $resize_v_px end
end

# Va al directorio de «recursos»
Dir.chdir(images_dir)

# Obtiene, verifica y ordena alfabéticamente
Dir.glob('*.*') do |file|
    # Verifica que sea un formato aceptado
    image_formats.each do |f|
        if '.' + f ==  File.extname(file)
            images.push(file)
            break
        end
    end
end
images = images.sort.sort_by{|s| transliterar(s, false)}

# Obtiene la información y hace las modificaciones
images.each do |file|
    # Analiza el archivo
    puts "#{$l_im_analizando[0] + file + $l_im_analizando[1]}".green
    info = `magick identify -verbose '#{file}'`

    # Depura el tamaño y peso de la imagen
    geometry = info.gsub(/\n/,'').gsub(/^.*?(Geometry:\s+?\S+?)\s+.*$/, '\1').gsub(/^.*?(\d+x\d+).*$/, '\1').split('x')
    size = info.gsub(/\n/,'').gsub(/^.*?(Filesize:\s+?\S+?)\s+.*$/, '\1').gsub(/^.*?(\d+).*$/, '\1').to_f

    # Va sumando los pesos
    total_size_old += size
    
    # Obtiene tamaños actuales, si es horizontal o no, tamaños nuevos y un conjunto para procesar la información
    width = geometry.first.to_i
    height = geometry.last.to_i
    horizontal = width >= height ? true : false
    new_width = horizontal ? (resize_h == nil ? width : resize_h) : (resize_v == nil ? width : resize_v)
    new_height = width == new_width ? height : (height * new_width) / width
    img = [width.to_s + 'x' + height.to_s, new_width.to_s + 'x' + new_height.to_s]

    # Si son imágenes a reducir
    if resize || resize_h || resize_v
        if width > new_width
            puts "#{$l_im_redimensionando[0] + img[0] + $l_im_redimensionando[1] + img[1] + $l_im_redimensionando[2]}".green
            system("convert '#{file}' -resize #{new_width}x '#{file}'")
        end
    end

    # Si se quiere comprimir el archivo
    if compress
        puts $l_im_comprimiendo
        system("convert '#{file}' -strip -interlace Plane -quality 85% '#{file}'")
    end

    # Obtiene el nuevo peso de la imagen
    info = `magick identify -verbose '#{file}'`
    size = info.gsub(/\n/,'').gsub(/^.*?(Filesize:\s+?\S+?)\s+.*$/, '\1').gsub(/^.*?(\d+).*$/, '\1').to_f

    # Va sumando los pesos actuales
    total_size_new += size
end

# Convierte a MB y redondea
total_size_old = rounded(total_size_old)
total_size_new = rounded(total_size_new)

puts "#{$l_im_total[0] + total_size_old.to_s + $l_im_total[1] + total_size_new.to_s + $l_im_total[2] + (total_size_old - total_size_new).round(2).to_s + $l_im_total[3]}".green
puts $l_g_fin
