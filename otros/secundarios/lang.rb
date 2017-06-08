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

# Obtiene el YAML
langObj = YAML.load_file(File.dirname(__FILE__) + "/lang/#{$lang}.yaml")

# Generales
$l_g_error_arg = langObj["general"]["error_arg"].red.bold
$l_g_error_arg2 = langObj["general"]["error_arg2"].red.bold
$l_g_error_directorio = langObj["general"]["error_directorio"]
$l_g_error_archivo = langObj["general"]["error_archivo"]
$l_g_error_archivo2 = langObj["general"]["error_archivo2"]
$l_g_fin = langObj["general"]["fin"].blue.bold
$l_g_sin_titulo = langObj["general"]["sin_titulo"]
$l_g_id_title = langObj["general"]["id_title"]
$l_g_id_author = langObj["general"]["id_author"]
$l_g_id_publisher = langObj["general"]["id_publisher"]
$l_g_meta_data = langObj["general"]["meta_data"]
$l_g_marca = langObj["general"]["marca"]
$l_g_marca_interior = langObj["general"]["marca_interior"]
$l_g_ignore = langObj["general"]["ignore"]
$l_g_delete = langObj["general"]["delete"]
$l_g_change = langObj["general"]["change"]
$l_g_note = langObj["general"]["note"]
$l_g_note_content = langObj["general"]["note_content"]

# Pandog
$l_pg_v = langObj["pandog"]["v"]
$l_pg_h = langObj["pandog"]["h"]
$l_pg_error_ext = langObj["pandog"]["error_ext"].red.bold
$l_pg_error_m = langObj["pandog"]["error_m"].red.bold
$l_pg_iniciando = langObj["pandog"]["iniciando"].green
$l_pg_modificando = langObj["pandog"]["modificando"].green

# Sandbox
$l_sb_v = langObj["sandbox"]["v"]
$l_sb_h = langObj["sandbox"]["h"]
$l_sb_txt_marcado = langObj["sandbox"]["txt_marcado"]
$l_sb_txt_cifras = langObj["sandbox"]["txt_cifras"]
$l_sb_txt_uniones = langObj["sandbox"]["txt_uniones"]
$l_sb_txt_versales = langObj["sandbox"]["txt_versales"]
$l_sb_txt_estadisticas = langObj["sandbox"]["txt_estadisticas"]
$l_sb_fichero = langObj["sandbox"]["fichero"]
$l_sb_fichero_interior = langObj["sandbox"]["fichero_interior"]
$l_sb_divisor = langObj["sandbox"]["divisor"]
$l_sb_e = langObj["sandbox"]["e"]
$l_sb_advertencia_archivo = langObj["sandbox"]["advertencia_archivo"]
$l_sb_analizando = langObj["sandbox"]["analizando"].green
$l_sb_realizando = langObj["sandbox"]["realizando"].green
$l_sb_eliminando = langObj["sandbox"]["eliminando"]
$l_sb_reemplazando = langObj["sandbox"]["reemplazando"]
$l_sb_error_carpeta = langObj["sandbox"]["error_carpeta"]
$l_sb_error_carpeta2 = langObj["sandbox"]["error_carpeta2"]
$l_sb_error_carpeta3 = langObj["sandbox"]["error_carpeta3"]
$l_sb_error_archivo = langObj["sandbox"]["error_archivo"]
$l_sb_error_archivo2 = langObj["sandbox"]["error_archivo2"].red.bold

# Tegs
$l_tg_v = langObj["tegs"]["v"]
$l_tg_h = langObj["tegs"]["h"]
$l_tg_comprimido = langObj["tegs"]["comprimido"]
$l_tg_procesando = langObj["tegs"]["procesando"]
$l_tg_reconociendo = langObj["tegs"]["reconociendo"]
$l_tg_extrayendo = langObj["tegs"]["extrayendo"]
$l_tg_uniendo_pdf = langObj["tegs"]["uniendo_pdf"].green
$l_tg_comprimiendo = langObj["tegs"]["comprimiendo"]
$l_tg_uniendo_txt = langObj["tegs"]["uniendo_txt"].green
$l_tg_limpiando = langObj["tegs"]["limpiando"].green
$l_tg_error_te = langObj["tegs"]["error"]["te"].red.bold
$l_tg_error_gs = langObj["tegs"]["error"]["gs"].red.bold

# Creator
$l_cr_v = langObj["creator"]["v"]
$l_cr_h = langObj["creator"]["h"]
$l_cr_epub_nombre = langObj["creator"]["epub_nombre"]
$l_cr_aviso = langObj["creator"]["aviso"]
$l_cr_yaml = langObj["creator"]["yaml"]
$l_cr_xhtml_portada = langObj["creator"]["xhtml_portada"]
$l_cr_xhtml_portadilla = langObj["creator"]["xhtml_portadilla"]
$l_cr_xhtml_legal = langObj["creator"]["xhtml_legal"]
$l_cr_creando = langObj["creator"]["creando"]
$l_cr_error_nombre = langObj["creator"]["error_nombre"].red.bold
$l_cr_error_meta = langObj["creator"]["error_meta"].red.bold

# Divider
$l_di_v = langObj["divider"]["v"]
$l_di_h = langObj["divider"]["h"]
$l_di_dividiendo = langObj["divider"]["dividiendo"].green
$l_di_creando = langObj["divider"]["creando"]
$l_di_error_f = langObj["divider"]["error_f"].red.bold
$l_di_error_i = langObj["divider"]["error_i"].red.bold

# Recreator
$l_re_v = langObj["recreator"]["v"]
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
$l_re_advertencia_fijo = langObj["recreator"]["advertencia_fijo"]
$l_re_error_y = langObj["recreator"]["error_y"]
$l_re_error_e = langObj["recreator"]["error_e"]
$l_re_error_a = langObj["recreator"]["error_a"]
$l_re_error_m = langObj["recreator"]["error_m"].red.bold
