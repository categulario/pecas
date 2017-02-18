#!/usr/bin/env ruby
# encoding: UTF-8
# coding: UTF-8

Encoding.default_internal = Encoding::UTF_8

# OJO: depende de la estructura que crea Pandoc, úsese con precaución
def beautifier archivo
	b = ".beautifier"
	elementos = Array.new
	$beautifier_nivel = 0
	$beautifier_auto = false
	$beautifier_espacio = "    "
	$beautifier_e_final = Array.new
	
	# Añade los espacios necesarios
	def espaciar elemento
		# </html> es nivel 0
		if elemento =~ /<\/(\s+)?html/
			$beautifier_nivel = 0
		# <head>, <body>, </head> y </body> son nivel 1
		elsif elemento =~ /<(\s+)?head/ || elemento =~ /<(\s+)?body/ || elemento =~ /<\/(\s+)?head/ || elemento =~ /<\/(\s+)?body/
			$beautifier_nivel = 1
		# </section>, </div>, </blockquote>, </ol>, </ul>, </table>, </tr>, </thead>, </tbody>, </tfoot> y </colgroup> restan un nivel
		elsif elemento =~ /<\/(\s+)?section/ || elemento =~ /<\/(\s+)?div/ || elemento =~ /<\/(\s+)?blockquote/ || elemento =~ /<\/(\s+)?ol/ || elemento =~ /<\/(\s+)?ul/ || elemento =~ /<\/(\s+)?table/ || elemento =~ /<\/(\s+)?tr/ || elemento =~ /<\/(\s+)?thead/ || elemento =~ /<\/(\s+)?tbody/ || elemento =~ /<\/(\s+)?tfoot/ || elemento =~ /<\/(\s+)?colgroup/
			$beautifier_nivel = $beautifier_nivel - 1
		end
		
		# Evita niveles negativos
		if $beautifier_nivel < 0
			$beautifier_nivel = 0
		end
		
		# El espacio en este elemento es igual al espacio por defecto por el nivel
		e = $beautifier_espacio * $beautifier_nivel
		
		# Agrega el elemento
		$beautifier_e_final.push(e + elemento)
		
		# Lo que sigue a <head> y <body> empieza con nivel 2
		if elemento =~ /<(\s+)?head/ || elemento =~ /<(\s+)?body/
			$beautifier_nivel = 2
		# Lo que sigue a <section>, <div>, <blockquote>, <ol>, <ul>, <table>, <tr>, <thead>, <tbody>, <tfoot> y <colgroup> sube un nivel
		elsif elemento =~ /<(\s+)?section/ || elemento =~ /<(\s+)?div/ || elemento =~ /<(\s+)?blockquote/ || elemento =~ /<(\s+)?ol/ || elemento =~ /<(\s+)?ul/ || elemento =~ /<(\s+)?table/ || elemento =~ /<(\s+)?tr/ || elemento =~ /<(\s+)?thead/ || elemento =~ /<(\s+)?tbody/ || elemento =~ /<(\s+)?tfoot/ || elemento =~ /<(\s+)?colgroup/
			$beautifier_nivel = $beautifier_nivel + 1
		end
	end
	
	# Extrae el texto del archivo original
	archivo_abierto = File.open(archivo, "r")
	archivo_abierto.each do |l|
		# Se eliminan los espacios al inicio y los saltos de línea
		elementos.push(l.gsub(/^\s+/, "").gsub(/\n/, ""))
	end
	archivo_abierto.close
	
	# Se espacia cada línea
	elementos.each do |l|; espaciar l; end
	
	# Se añaden las líneas espaciadas al nuevo archivo
	archivo_final = File.open(b, "w") 
	archivo_final.puts $beautifier_e_final
	archivo_final.close
	
	# Renombra el nuevo archivo para sustituir el original
	File.rename(b, File.basename(archivo))
end
