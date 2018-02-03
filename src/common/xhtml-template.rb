#!/usr/bin/env ruby
# encoding: UTF-8
# coding: UTF-8

Encoding.default_internal = Encoding::UTF_8

# Funciones y módulos comunes a todas las herramientas
require File.dirname(__FILE__) + "/../common/lang.rb"

def xhtmlTemplateHead title = "Título", css = "", epubType = ""

# Para el caso del css y el epub:type se sigue esta condición:
#   la variable no está vacía ? output si sí : output si no
# Se pone pegada a la línea anterior para evitar la creación de una línea vacía en caso de ser nil, y si no es el caso, se crea un salto de línea al inicia con \n

template = "<?xml version=\"1.0\" encoding=\"utf-8\"?>
<!DOCTYPE html>
<html xmlns=\"http://www.w3.org/1999/xhtml\" xmlns:epub=\"http://www.idpf.org/2007/ops\" xml:lang=\"#{$lang}\" lang=\"#{$lang}\">
    <head>
        <meta charset=\"UTF-8\" />
        <title>#{title}</title>#{css != "" ? "\n        <link href=\"#{css}\" rel=\"stylesheet\" type=\"text/css\" />" : ""}
    </head>#{epubType != "" ? "\n    <body epub:type=\"#{epubType}\">" : "\n    <body>"}
"

end

def htmlTemplateHead title = "Título", css = ""

# Para el caso del css y el epub:type se sigue esta condición:
#   la variable no está vacía ? output si sí : output si no
# Se pone pegada a la línea anterior para evitar la creación de una línea vacía en caso de ser nil, y si no es el caso, se crea un salto de línea al inicia con \n

template = "<!DOCTYPE html>
<html lang=\"#{$lang}\">
    <head>
        <meta charset=\"UTF-8\" />
        <title>#{title}</title>#{css != "" ? "\n        <link href=\"#{css}\" rel=\"stylesheet\" type=\"text/css\" />" : ""}
    </head>
    <body>
"

end

def xhtmlTemplateHeadCover title = "Título"

# Para el caso del css y el epub:type se sigue esta condición:
#   la variable no está vacía ? output si sí : output si no
# Se pone pegada a la línea anterior para evitar la creación de una línea vacía en caso de ser nil, y si no es el caso, se crea un salto de línea al inicia con \n

template = "<?xml version=\"1.0\" encoding=\"utf-8\"?>
<!DOCTYPE html>
<html xmlns=\"http://www.w3.org/1999/xhtml\" xmlns:epub=\"http://www.idpf.org/2007/ops\" xml:lang=\"#{$lang}\" lang=\"#{$lang}\">
    <head>
        <meta charset=\"UTF-8\" />
        <title>#{title}</title>
        <style>.sin-margen{margin:0;padding:0;}.forro{display:block;margin:auto;padding:0;height:100vh;width:auto;}</style>
    </head>
    <body class=\"sin-margen\">
"

end

$xmlTemplateHead = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<body>
"

$xhtmlTemplateFoot = "    </body>
</html>
"
