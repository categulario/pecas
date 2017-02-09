#!/usr/bin/env ruby
# encoding: UTF-8
# coding: UTF-8

Encoding.default_internal = Encoding::UTF_8

require "json"

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

# Obtiene el JSON
json = File.read(File.dirname(__FILE__) + "/lang/#{$lang}.json")
langObj = JSON.parse(json)

# Generales

$l_g_error_arg = langObj["general"]["error_arg"].red.bold
$l_g_error_arg2 = langObj["general"]["error_arg2"].red.bold
$l_g_fin = langObj["general"]["fin"].blue.bold

# Pandog

$l_pg_v = langObj["pandog"]["v"]
$l_pg_h = langObj["pandog"]["h"]
$l_pg_error_ext = langObj["pandog"]["error_ext"].red.bold
$l_pg_error_m = langObj["pandog"]["error_m"].red.bold
$l_pg_iniciando = langObj["pandog"]["iniciando"].green
$l_pg_modificando = langObj["pandog"]["modificando"].green

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
