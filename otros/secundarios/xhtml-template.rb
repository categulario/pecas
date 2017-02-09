#!/usr/bin/env ruby
# encoding: UTF-8
# coding: UTF-8

Encoding.default_internal = Encoding::UTF_8

# Funciones y módulos comunes a todas las herramientas
require File.dirname(__FILE__) + "/../secundarios/lang.rb"

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

$xhtmlTemplateFoot = "    </body>
</html>
"
