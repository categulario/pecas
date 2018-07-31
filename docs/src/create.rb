#!/usr/bin/env ruby
# encoding: UTF-8
# coding: UTF-8

require 'fileutils'
require 'yaml'

Encoding.default_internal = Encoding::UTF_8

# Funciones y módulos comunes a todas las herramientas
require File.expand_path("../../..", File.absolute_path(__FILE__)) + '/src/common/xhtml-beautifier.rb'
require File.expand_path("../../..", File.absolute_path(__FILE__)) + "/src/common/lang.rb"

$tools_md = {}
tools = [
    ["pc-tiff2pdf", $l_tg_h],
    ["pc-analytics", $l_an_h],
    ["pc-images", $l_im_h],
    ["pc-pandog", $l_pg_h],
    ["pc-automata", $l_au_h],
    ["pc-creator", $l_cr_h],
    ["pc-divider", $l_di_h],
    ["pc-notes", $l_no_h],
    ["pc-cites", $l_ci_h],
    ["pc-index", $l_in_h],
    ["pc-recreator", $l_re_h],
    ["pc-changer", $l_ch_h],
    ["pc-doctor", $l_dr_h],
]

# Va a la carpeta «docs»
Dir.chdir(File.dirname(__FILE__) + '/..')

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

# Crea los MD a partir de las ayudas de las herramientas
def create_md tool
    
    original = tool[1].split("\n")
    new = []
    note = false

    # Cambia las rutas y < y > por código HTML
    def diple l
        return l.gsub('de +++YAML+++ en <http://pecas.cliteratu.re>', 'de [+++YAML+++](yaml.html)')
                .gsub('Lista de acrónimos: <https://github.com/tesseract-ocr/tesseract/blob/master/doc/tesseract.1.asc#languages>', '[Lista de acrónimos](https://github.com/tesseract-ocr/tesseract/blob/master/doc/tesseract.1.asc#languages)')
                .gsub('<','&lt;').gsub('>','&gt;')
    end

    # Agrega versalitas
    def smallcaps l
        return l.gsub(/([A-Z]{3,})/, '+++\1+++')
    end

    # Cambia comillas por sintaxis para línea de código
    def to_code l
        return l.gsub(/«(.+?)»/, '`\1`')
    end

    # Añade líneas de código en las opciones
    def to_code_option l
        return l.gsub(/^(\S+)/, '`\1`')
    end

    def avoid_endash l
        return l.gsub('--','\\--')
    end

    new.push('# ' + $l_g_pc_docs_creation + '`' + tool[0] + '`')

    original.each_with_index do |l, i|

        l = to_code(diple(smallcaps(l)))

        if l =~ /^\S/
            # Encabezados 2
            if l !~ /^Nota/ && i != 1
                new.push('## ' + l + "\n\n")
            # Párrafos
            else
                # Notas
                if l =~ /^Nota/
                    if !note
                        new.push("--- {.espacio-arriba3}\n\n")
                        note = true
                        new.push(avoid_endash(l) + ' {.espacio-arriba3}')
                    else
                        new.push(avoid_endash(l) + ' {.espacio-arriba1 .sin-sangria}')
                    end                    
                # Descripción
                else
                    # Esto servirá para crear «herramientas.md»
                    $tools_md["#{tool[0]}"] = [tool[0], l.gsub(/^\S+\s+/, '')]
                    new.push(l)
                end
            end
        else
            if l.strip != ''
                l = l.strip

                # Opciones de Pecas
                if l =~ /^-/
                    new.push('* ' + to_code_option(avoid_endash(l)))
                # Comandos de Pecas
                elsif l =~ /^pc-/
                    new.push('```')
                    new.push(l)
                    new.push('```')
                # Explicaciones
                elsif l =~ /^[A-Z]/
                    new.push("\n" + avoid_endash(l))
                # Dependencias
                else
                    new.push('* `' + avoid_endash(l) + '`')
                end
            # Líneas en blanco
            else
                new.push(l)
            end
        end
    end

	archivo = File.new(Dir.pwd + '/md/' + tool[0] + '.md', 'w:UTF-8')
	archivo.puts new
	archivo.close
end

# Crea el «heramientas.md»
def create_md_tools
	archivo = File.new(Dir.pwd + '/md/herramientas.md', 'w:UTF-8')
	archivo.puts "# Herramientas\n\n"
	archivo.puts "## Digitalización\n\n"
    archivo.puts "* [`#{$tools_md["pc-tiff2pdf"][0]}`](#{$tools_md["pc-tiff2pdf"][0]}.html): #{$tools_md["pc-tiff2pdf"][1]}"
	archivo.puts "\n## Archivos madre\n\n"
    archivo.puts "* [`#{$tools_md["pc-analytics"][0]}`](#{$tools_md["pc-analytics"][0]}.html): #{$tools_md["pc-analytics"][1]}"
    archivo.puts "* [`#{$tools_md["pc-images"][0]}`](#{$tools_md["pc-images"][0]}.html): #{$tools_md["pc-images"][1]}"
    archivo.puts "* [`#{$tools_md["pc-pandog"][0]}`](#{$tools_md["pc-pandog"][0]}.html): #{$tools_md["pc-pandog"][1]}"
	archivo.puts "\n## +++EPUB+++\n\n"
    archivo.puts "* [`#{$tools_md["pc-automata"][0]}`](#{$tools_md["pc-automata"][0]}.html): #{$tools_md["pc-automata"][1]}"
    archivo.puts "* [`#{$tools_md["pc-creator"][0]}`](#{$tools_md["pc-creator"][0]}.html): #{$tools_md["pc-creator"][1]}"
    archivo.puts "* [`#{$tools_md["pc-divider"][0]}`](#{$tools_md["pc-divider"][0]}.html): #{$tools_md["pc-divider"][1]}"
    archivo.puts "* [`#{$tools_md["pc-notes"][0]}`](#{$tools_md["pc-notes"][0]}.html): #{$tools_md["pc-notes"][1]}"
    archivo.puts "* [`#{$tools_md["pc-cites"][0]}`](#{$tools_md["pc-cites"][0]}.html): #{$tools_md["pc-cites"][1]}"
    archivo.puts "* [`#{$tools_md["pc-index"][0]}`](#{$tools_md["pc-index"][0]}.html): #{$tools_md["pc-index"][1]}"
    archivo.puts "* [`#{$tools_md["pc-recreator"][0]}`](#{$tools_md["pc-recreator"][0]}.html): #{$tools_md["pc-recreator"][1]}"
    archivo.puts "* [`#{$tools_md["pc-changer"][0]}`](#{$tools_md["pc-changer"][0]}.html): #{$tools_md["pc-changer"][1]}"
	archivo.puts "\n## Estado de Pecas y sus dependencias\n\n"
    archivo.puts "* [`#{$tools_md["pc-doctor"][0]}`](#{$tools_md["pc-doctor"][0]}.html): #{$tools_md["pc-doctor"][1]}"
	archivo.close
end

# Crea los HTML a partir de los MD
def create_html path
    html_name = "#{File.basename(path, '.md')}.html"

    if html_name !~ /^index/
        html_name = 'md/' + html_name
    end

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
            if html_name !~ /^index/
                new_html.push($header.join("\n"))
            else
                new_html.push($header.join("\n").gsub('../index.html', '').gsub(/"(\S+?\.html)"/, 'html/' + '\1'))  
            end
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
    if html_name !~ /^index/
        FileUtils.mv(html_name, 'html')
    end
end

# Obtiene HTML necesario
$head = get_html('src/head.html')
$header = get_html('src/header.html')
$footer = get_html('src/footer.html')

# Crea los MD de la ayuda de cada herramienta
tools.each do |tool|
    create_md(tool)
end
create_md_tools

# Crea las páginas HTML
create_html('index.md')
Dir.glob('./md/*').each do |f|
    if File.extname(f) == '.md'
        create_html(f.gsub(/^\.\//,''))
    end
end
