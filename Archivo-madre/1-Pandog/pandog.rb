#!/usr/bin/env ruby
# encoding: UTF-8
# coding: UTF-8

Encoding.default_internal = Encoding::UTF_8

# Funciones y módulos comunes a todas las herramientas
require File.dirname(__FILE__) + "/../../otros/secundarios/general.rb"
require File.dirname(__FILE__) + "/../../otros/secundarios/lang.rb"

## REQUIERE PANDOC

# Argumentos
entrada = argumento "-i", entrada
salida = argumento "-o", salida
versalita = argumento "-s", versalita
version = argumento "-v", $l_pg_v
ayuda = argumento "-h", $l_pg_h

# Comprueba que existan los argumentos necesarios
comprobacion [entrada, salida]
