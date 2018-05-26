#!/usr/bin/env ruby
# encoding: UTF-8
# coding: UTF-8

require 'fileutils'

Encoding.default_internal = Encoding::UTF_8

# Va a la carpeta «docs»
Dir.chdir(File.dirname(__FILE__) + '/..')

# Funciones y módulos comunes a todas las herramientas
require Dir.pwd + '/../src/common/xhtml-beautifier.rb'

# Obtiene los elementos HTML
def get_html path
    array = []

    archivo = File.open(path, 'r:UTF-8')
    archivo.each do |l|
        array.push(l.strip)
	end
    archivo.close

    return array
end

# Crea los HTML a partir de los MD
def create_html path
    html_name = "#{File.basename(path, '.md')}.html"

    puts "Ejecutando «pc-pandog -i #{path} -o #{html_name}»…"
    system("pc-pandog -i #{path} -o #{html_name}")

    html = get_html(html_name)
    new_html = []

    write = true
    html.each do |l|
        if l =~ /<head>/
            write = false
            new_html.push($head.join("\n"))
        elsif l =~ /<\/head>/
            write = true
        elsif l =~ /<style>/
            new_html.push(l)
            new_html.push($header.join("\n"))
        elsif l =~ /<\/body>/
            new_html.push($footer.join("\n"))
            new_html.push(l)
        else
            if write == true
                new_html.push(l)
            end
        end
    end

    new_html = beautifier_html(new_html)

	# Se actualiza la información
	archivo = File.new(html_name, 'w:UTF-8')
	archivo.puts new_html
	archivo.close

    # Si no es el index, lo mueve a la carpeta «html»
    if html_name !~ /index/
        FileUtils.mv(html_name, 'html')
    end
end

# Obtiene HTML necesario
$head = get_html('src/head.html')
$header = get_html('src/header.html')
$footer = get_html('src/footer.html')

# Crea las páginas HTML
create_html('index.md')
Dir.glob('./md/*').each do |f|
    if File.extname(f) == '.md'
        create_html(f.gsub(/^\.\//,''))
    end
end


