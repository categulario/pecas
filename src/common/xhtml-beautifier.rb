#!/usr/bin/env ruby
# encoding: UTF-8
# coding: UTF-8

Encoding.default_internal = Encoding::UTF_8

# Pone lindo un conjunto o línea de texto de HTML; OJO: estaría bien ya no depender de un conjutno dado de elementos HTML
def beautifier_html elemento
    $nivel_actual = 0
    block_elements = [
        'address', 'article', 'aside', 'blockquote', 'canvas', 'dd', 
        'div', 'dl', 'dt', 'fieldset', 'figcaption', 'figure', 
        'footer', 'form', 'header', 'hgroup', 'hr', 'li', 'main', 
        'nav', 'noscript', 'ol', 'output', 'pre', 'section', 'table', 
        'tfoot', 'ul', 'video', 'html', 'head', 'body', 'package', 
        'metadata', 'manifest', 'spine'
    ] # Estos elementos quedan:  \n<e>\n…\n</e>\n
    other_elements = [
        'meta', 'title', 'link', 'p', 'item', /dc:/, /h\d/
    ] # Estos elementos quedan:  \n<e>…</e>\n

    # Coloca los espacios correctos
    def movimiento_espacio elemento, bloques, conjunto
        espacio = '    '

        # Define si es una línea de texto donde puede sumarse o restarse un nivel
        def si_bloque elemento, bloques
            bloques.each do |b|
                if elemento =~ /^<[^>|^\w]*?#{b}[^\w]/ then return true end
            end
            return false
        end

        # Si es de cierre
        if elemento =~ /^<\//
            # Si sí aplica una reducción
            if si_bloque(elemento, bloques) == true
                $nivel_actual = $nivel_actual - 1
                conjunto.push((espacio * $nivel_actual) + elemento)
            else
                conjunto.push((espacio * $nivel_actual) + elemento)
            end
        # Si es de apertura o puro texto
        else
            # Si sí aplica una adición
            if si_bloque(elemento, bloques) == true
                conjunto.push((espacio * $nivel_actual) + elemento)
                $nivel_actual = $nivel_actual + 1
            else
                conjunto.push((espacio * $nivel_actual) + elemento)
            end
        end
    end

    # Para forzar iniciar con una sola línea de texto
    if elemento.kind_of?(Array)
        elemento = elemento.join('')
    end

    # Añade saltos de línea en los elementos que son bloques
    block_elements.each do |e|
        elemento = elemento.gsub(/<\s*?(#{e}.*?)>/,"\n<" + '\1' + ">\n").gsub(/<\s*?\/\s*?(#{e}.*?)>/,"\n</" + '\1' + ">\n")
    end

    # Añade saltos de línea a otros elementos
    other_elements.each do |e|
        elemento = elemento.gsub(/<\s*?(#{e}.*?)>/,"\n<" + '\1' + ">").gsub(/<\s*?\/\s*?(#{e}.*?)>/,"</" + '\1' + ">\n")
    end

    # Crea un conjunto sin elementos vacíos fruto de saltos excesivos
    elemento = elemento.split("\n").reject{|l| l.empty?}

    # Crea el nuevo elemento con los espacios correctos
    elemento_final = []
    elemento.each do |e|
        movimiento_espacio(e, block_elements, elemento_final)
    end

    return elemento_final
end

# Pone lido un archivo tipo HTML
def beautifier archivo
	b = ".beautifier"
	elementos = []
	
	# Extrae el texto del archivo original
	archivo_abierto = File.open(archivo, "r")
	archivo_abierto.each do |l|
		elementos.push(l.strip.gsub("\n", ""))
	end
	archivo_abierto.close
	
	# Se añaden las líneas espaciadas al nuevo archivo
	archivo_final = File.open(b, "w") 
	archivo_final.puts beautifier_html(elementos)
	archivo_final.close
	
	# Renombra el nuevo archivo para sustituir el original
	File.rename(b, File.basename(archivo))
end
