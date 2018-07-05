#!/usr/bin/env ruby
# encoding: UTF-8
# coding: UTF-8

Encoding.default_internal = Encoding::UTF_8

require 'yaml'

$lang = "es"

# Para colorear el texto; viene de: http://stackoverflow.com/questions/1489183/colorized-ruby-output
class String
    def black;          "\e[30m#{self}\e[0m" end
    def red;            "\e[31m#{self}\e[0m" end
    def green;          "\e[32m#{self}\e[0m" end
    def brown;          "\e[33m#{self}\e[0m" end
    def blue;           "\e[34m#{self}\e[0m" end
    def magenta;        "\e[35m#{self}\e[0m" end
    def cyan;           "\e[36m#{self}\e[0m" end
    def gray;           "\e[37m#{self}\e[0m" end
    def yellow;         "\e[1;33m#{self}\e[0m" end

    def bg_black;       "\e[40m#{self}\e[0m" end
    def bg_red;         "\e[41m#{self}\e[0m" end
    def bg_green;       "\e[42m#{self}\e[0m" end
    def bg_brown;       "\e[43m#{self}\e[0m" end
    def bg_blue;        "\e[44m#{self}\e[0m" end
    def bg_magenta;     "\e[45m#{self}\e[0m" end
    def bg_cyan;        "\e[46m#{self}\e[0m" end
    def bg_gray;        "\e[47m#{self}\e[0m" end

    def bold;           "\e[1m#{self}\e[22m" end
    def italic;         "\e[3m#{self}\e[23m" end
    def underline;      "\e[4m#{self}\e[24m" end
    def blink;          "\e[5m#{self}\e[25m" end
    def reverse_color;  "\e[7m#{self}\e[27m" end
end

# Para obtener la versión de las herramientas
def obtener_version doctor = false
	# Arregla los dígitos del mes y día para que siempre sean dos
	def arreglo_digitos i
		if i < 10
			return "0" + i.to_s
		else
			return i.to_s
		end
	end

	linea = ""

	# Obtiene la información del último commit
	File.readlines(File.dirname(__FILE__) + "/../../.git/logs/HEAD").reverse_each do |l|
		linea = l
		break
	end

	commit = "-" + linea.split(/\s+/)[1][0..6]	# Abrevia el commit a 7 dígitos
	fecha = Time.at(linea.split(/\s+/)[4].to_i)	# Convierte el UNIX time
	fecha_formato = fecha.year.to_s + "." + arreglo_digitos(fecha.month) + "." + arreglo_digitos(fecha.day)

    espacio = doctor ? " " : ""

	# Regresa este formato: año.mes.día-commit => 2018.01.11-f610862
	return espacio + espacio + "Pecas: #{fecha_formato + commit}" + "\n#{espacio} Ruby: #{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}" + "\n#{espacio} Host: #{RbConfig::CONFIG['host']}" + ( doctor ? "" : "\n\nSoftware bajo licencia GPLv3+ <https://gnu.org/licenses/gpl.html>.")
end

# Obtiene el YAML
langObj = YAML.load_file(File.dirname(__FILE__) + "/lang/#{$lang}.yaml")

# Generales
$l_g_pc_pandog = langObj["general"]["pc_pandog"]
$l_g_pc_analytics = langObj["general"]["pc_analytics"]
$l_g_pc_tiff2pdf = langObj["general"]["pc_tiff2pdf"]
$l_g_pc_creator = langObj["general"]["pc_creator"]
$l_g_pc_divider = langObj["general"]["pc_divider"]
$l_g_pc_notes = langObj["general"]["pc_notes"]
$l_g_pc_cites = langObj["general"]["pc_cites"]
$l_g_pc_index = langObj["general"]["pc_index"]
$l_g_pc_recreator = langObj["general"]["pc_recreator"]
$l_g_pc_changer = langObj["general"]["pc_changer"]
$l_g_fin = langObj["general"]["fin"].blue.bold
$l_g_sin_titulo = langObj["general"]["sin_titulo"]
$l_g_id_title = langObj["general"]["id_title"]
$l_g_id_subtitle = langObj["general"]["id_subtitle"]
$l_g_id_author = langObj["general"]["id_author"]
$l_g_id_publisher = langObj["general"]["id_publisher"]
$l_g_meta_data = langObj["general"]["meta_data"]
$l_g_marca = langObj["general"]["marca"]
$l_g_marca_in_1 = langObj["general"]["marca_in_1"]
$l_g_marca_in_2 = langObj["general"]["marca_in_2"]
$l_g_marca_b = langObj["general"]["marca_b"]
$l_g_marca_in_1_b = langObj["general"]["marca_in_1_b"]
$l_g_marca_in_2_b = langObj["general"]["marca_in_2_b"]
$l_g_ignore = langObj["general"]["ignore"]
$l_g_ignore_b = langObj["general"]["ignore_b"]
$l_g_note = langObj["general"]["note"]
$l_g_note_b = langObj["general"]["note_b"]
$l_g_descomprimiendo = langObj["general"]["descomprimiendo"].green
$l_g_analizando = langObj["general"]["analizando"]
$l_g_epub_analisis = langObj["general"]["epub_analisis"]
$l_g_xhtml_analisis = langObj["general"]["xhtml_analisis"]
$l_g_linea = langObj["general"]["linea"]
$l_g_error_no_identificado = langObj["general"]["error_no_identificado"]
$l_g_error_arg = langObj["general"]["error_arg"].red.bold
$l_g_error_arg2 = langObj["general"]["error_arg2"].red.bold
$l_g_error_directorio = langObj["general"]["error_directorio"]
$l_g_error_archivo = langObj["general"]["error_archivo"]
$l_g_error_archivo2 = langObj["general"]["error_archivo2"]
$l_g_error_nombre = langObj["general"]["error_nombre"].red.bold
$l_g_error_opf = langObj["general"]["error_opf"].red.bold
$l_g_error_hash = langObj["general"]["error_hash"].red.bold

# Analytics
$l_an_v = obtener_version
$l_an_h = langObj["analytics"]["h"]
$l_an_extrayendo = langObj["analytics"]["extrayendo"]
$l_an_separando = langObj["analytics"]["separando"]
$l_an_archivo_hunspell = langObj["analytics"]["archivo_hunspell"]
$l_an_analizando_hunspell = langObj["analytics"]["analizando_hunspell"].green
$l_an_analizando_linkchecker = langObj["analytics"]["analizando_linkchecker"].green
$l_an_fin_linkchecker = langObj["analytics"]["fin_linkchecker"].green
$l_an_creando_analitica = langObj["analytics"]["creando_analitica"]
$l_an_creando_archivo = langObj["analytics"]["creando_archivo"]
$l_an_archivo_nombre = langObj["analytics"]["archivo_nombre"]
$l_an_grafica = langObj["analytics"]["grafica"]
$l_an_advertencia_md = langObj["analytics"]["advertencia_md"]
$l_an_advertencia_hunspell = langObj["analytics"]["advertencia_hunspell"]
$l_an_advertencia_linkchecker = langObj["analytics"]["advertencia_linkchecker"]
$l_an_advertencia_deep = langObj["analytics"]["advertencia_deep"]
$l_an_error_general = langObj["analytics"]["error_general"].red.bold

# Pandog
$l_pg_v = obtener_version
$l_pg_h = langObj["pandog"]["h"]
$l_pg_iniciando = langObj["pandog"]["iniciando"].green
$l_pg_iniciando_pandoc = langObj["pandog"]["iniciando_pandoc"].green
$l_pg_extrayendo = langObj["pandog"]["extrayendo"].green
$l_pg_error_ext = langObj["pandog"]["error_ext"].red.bold
$l_pg_error_m = langObj["pandog"]["error_m"].red.bold
$l_pg_error_json = langObj["pandog"]["error_json"].red.bold

# Tiff2pdf
$l_tg_v = obtener_version
$l_tg_h = langObj["tiff2pdf"]["h"]
$l_tg_uniendo = langObj["tiff2pdf"]["uniendo"]
$l_tg_extranendo = langObj["tiff2pdf"]["extranendo"].green
$l_tg_extranendo2 = langObj["tiff2pdf"]["extranendo2"].green
$l_tg_eliminando = langObj["tiff2pdf"]["eliminando"].green
$l_tg_error_ti = langObj["tiff2pdf"]["error"]["ti"].red.bold
$l_tg_error_te = langObj["tiff2pdf"]["error"]["te"].red.bold

# Automata
$l_au_v = obtener_version
$l_au_h = langObj["automata"]["h"]
$l_au_nombre = langObj["automata"]["nombre"]
$l_au_epub_nombre = langObj["automata"]["epub_nombre"]
$l_au_logs = langObj["automata"]["logs"]
$l_au_prefijo = langObj["automata"]["prefijo"]
$l_au_init_archivo = langObj["automata"]["init_archivo"]
$l_au_init_contenido = langObj["automata"]["init_contenido"]
$l_au_log = langObj["automata"]["log"]
$l_au_creando = langObj["automata"]["creando"]
$l_au_eliminando = langObj["automata"]["eliminando"].green
$l_au_verificando = langObj["automata"]["verificando"]
$l_au_convirtiendo = langObj["automata"]["convirtiendo"]
$l_au_pregunta = langObj["automata"]["pregunta"]
$l_au_epubcheck = langObj["automata"]["epubcheck"]
$l_au_ace = langObj["automata"]["ace"]
$l_au_kindlegen = langObj["automata"]["kindlegen"]
$l_au_error_a = langObj["automata"]["error_a"].red.bold
$l_au_error_e = langObj["automata"]["error_e"]
$l_au_error_r = langObj["automata"]["error_r"]

# Creator
$l_cr_v = obtener_version
$l_cr_h = langObj["creator"]["h"]
$l_cr_epub_nombre = langObj["creator"]["epub_nombre"]
$l_cr_aviso = langObj["creator"]["aviso"]
$l_cr_yaml = langObj["creator"]["yaml"]
$l_cr_alt_portada = langObj["creator"]["alt_portada"]
$l_cr_xhtml_portada = langObj["creator"]["xhtml_portada"]
$l_cr_xhtml_portadilla = langObj["creator"]["xhtml_portadilla"]
$l_cr_xhtml_legal = langObj["creator"]["xhtml_legal"]
$l_cr_creando = langObj["creator"]["creando"]
$l_cr_creando2 = langObj["creator"]["creando2"].green
$l_cr_error_meta = langObj["creator"]["error_meta"].red.bold

# Divider
$l_di_v = obtener_version
$l_di_h = langObj["divider"]["h"]
$l_di_dividiendo = langObj["divider"]["dividiendo"].green
$l_di_creando = langObj["divider"]["creando"]
$l_di_error_f = langObj["divider"]["error_f"].red.bold
$l_di_error_i = langObj["divider"]["error_i"].red.bold

# Notes
$l_no_v = obtener_version
$l_no_h = langObj["notes"]["h"]
$l_no_comparando = langObj["notes"]["comparando"].green
$l_no_anadiendo = langObj["notes"]["anadiendo"].green
$l_no_oculto = langObj["notes"]["oculto"]
$l_no_archivo_notas = langObj["notes"]["archivo_notas"]
$l_no_nota_sup = langObj["notes"]["nota_sup"]
$l_no_nota_hr = langObj["notes"]["nota_hr"]
$l_no_nota_a = langObj["notes"]["nota_a"]
$l_no_nota_p = langObj["notes"]["nota_p"]
$l_no_nota_p2 = langObj["notes"]["nota_p2"]
$l_no_archivo_notas_titulo = langObj["notes"]["archivo_notas_titulo"]
$l_no_error_f = langObj["notes"]["error_f"].red.bold
$l_no_error_c = langObj["notes"]["error_c"]

# Recreator
$l_re_v = obtener_version
$l_re_h = langObj["recreator"]["h"]
$l_re_nuevo = langObj["recreator"]["nuevo"]
$l_re_recreando_opf = langObj["recreator"]["recreando_opf"].green
$l_re_recreando_ncx = langObj["recreator"]["recreando_ncx"].green
$l_re_recreando_nav = langObj["recreator"]["recreando_nav"].green
$l_re_recreando_fijo = langObj["recreator"]["recreando_fijo"]
$l_re_recreando_autoria = langObj["recreator"]["recreando_autoria"]
$l_re_recreando_portadilla = langObj["recreator"]["recreando_portadilla"]
$l_re_recreando_legal = langObj["recreator"]["recreando_legal"]
$l_re_eliminando_viewports = langObj["recreator"]["eliminando_viewports"].green
$l_re_eliminando_epub = langObj["recreator"]["eliminando_epub"].green
$l_re_creando_epub = langObj["recreator"]["creando_epub"]
$l_re_advertencia_depth = langObj["recreator"]["advertencia_depth"].yellow.bold
$l_re_advertencia_fijo = langObj["recreator"]["advertencia_fijo"]
$l_re_error_y = langObj["recreator"]["error_y"]
$l_re_error_e = langObj["recreator"]["error_e"]
$l_re_error_a = langObj["recreator"]["error_a"]
$l_re_error_m = langObj["recreator"]["error_m"].red.bold
$l_re_error_t = langObj["recreator"]["error_t"].red.bold

# Changer
$l_ch_v = obtener_version
$l_ch_h = langObj["changer"]["h"]
$l_ch_iniciando_conversion = langObj["changer"]["iniciando_conversion"]
$l_ch_iniciando = langObj["changer"]["iniciando"].green
$l_ch_extrayendo = langObj["changer"]["extrayendo"].green
$l_ch_incluyendo = langObj["changer"]["incluyendo"]
$l_ch_anadiendo = langObj["changer"]["anadiendo"]
$l_ch_creando = langObj["changer"]["creando"]
$l_ch_advertencia_standalone = langObj["changer"]["advertencia_standalone"].yellow.bold
$l_ch_advertencia_metadata = langObj["changer"]["advertencia_metadata"].yellow.bold
$l_ch_error_version = langObj["changer"]["error_version"]
$l_ch_error_version2 = langObj["changer"]["error_version2"].red.bold
$l_ch_error_version3 = langObj["changer"]["error_version3"]
$l_ch_error_archivo = langObj["changer"]["error_archivo"]

# Index
$l_in_v = obtener_version
$l_in_h = langObj["index"]["h"]
$l_in_archivo_nombre = langObj["index"]["archivo_nombre"]
$l_in_archivo_contenido = langObj["index"]["archivo_contenido"]
$l_in_creando = langObj["index"]["creando"]
$l_in_respaldando = langObj["index"]["respaldando"].green
$l_in_limpiando = langObj["index"]["limpiando"]
$l_in_restaurando = langObj["index"]["restaurando"]
$l_in_buscando = langObj["index"]["buscando"].green
$l_in_anadiendo = langObj["index"]["anadiendo"].green
$l_in_eliminando = langObj["index"]["eliminando"].green
$l_in_index_file = langObj["index"]["index_file"]
$l_in_item_id = langObj["index"]["item_id"]
$l_in_item_span = langObj["index"]["item_span"]
$l_in_item_section = langObj["index"]["item_section"]
$l_in_item_div = langObj["index"]["item_div"]
$l_in_item_div2 = langObj["index"]["item_div2"]
$l_in_item_a = langObj["index"]["item_a"]
$l_in_advertencia = langObj["index"]["advertencia"].yellow
$l_in_error_yaml = langObj["index"]["error_yaml"].red.bold
$l_in_error_procesamiento = langObj["index"]["error_procesamiento"]
$l_in_error_data = langObj["index"]["error_data"].red.bold
$l_in_error_incorporacion = langObj["index"]["error_incorporacion"].red.bold

# Doctor
$l_dr_v = obtener_version
$l_dr_h = langObj["doctor"]["h"]
$l_dr_generales = langObj["doctor"]["generales"]
$l_dr_dependencias = langObj["doctor"]["dependencias"]
$l_dr_actualizando = langObj["doctor"]["actualizando"]
$l_dr_restaurando = langObj["doctor"]["restaurando"]
$l_dr_instalando = langObj["doctor"]["instalando"]
$l_dr_instalando_fin = langObj["doctor"]["instalando-fin"]
$l_dr_instalando_nan = langObj["doctor"]["instalando-nan"]
$l_dr_instalando_xcode = langObj["doctor"]["instalando-xcode"]
$l_dr_instalando_brew = langObj["doctor"]["instalando-brew"]
$l_dr_instalado = langObj["doctor"]["instalado"]
$l_dr_no_instalado = langObj["doctor"]["no-instalado"]
$l_dr_nil_instalado = langObj["doctor"]["nil-instalado"]
$l_dr_falta = langObj["doctor"]["falta"]
$l_dr_pregunta = langObj["doctor"]["pregunta"]
$l_dr_ninguno = langObj["doctor"]["ninguno"]
$l_dr_mayor = langObj["doctor"]["mayor"]
$l_dr_advertencia = langObj["doctor"]["advertencia"]
$l_dr_error = langObj["doctor"]["error"]
