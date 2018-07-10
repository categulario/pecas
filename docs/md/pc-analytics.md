# Uso de `pc-analytics`

Analytics analiza archivos +++EPUB+++, +++XML+++, +++XHTML+++ o +++HTML+++ para un mayor cuidado editorial y técnico.

## Dependencias opcionales:

* `hunspell`
* `linkchecker`

## Uso:

```
pc-analytics -f [archivo]
```

## Parámetro necesario:

* `-f` = [file] Archivo +++EPUB+++, +++XML+++, +++XHTML+++ o +++HTML+++ a analizar.

## Parámetros opcionales:

* `\--deep` = Realiza un análisis profundo del archivo.
* `\--json` = Crea una salida del análisis en formato +++JSON+++.
* `\--yaml` = Crea una salida del análisis en formato +++YAML+++.
* `\--rotate` = Permite rotación aleatoria de las palabras en la nube de palbras de 30° a 150°.

## Parámetros únicos:

* `-v` = [version] Muestra la versión.
* `-h` = [help] Muestra esta ayuda.

## Ejemplo sencillo:

```
pc-analytics -f directorio/al/archivo.epub
```

Analiza el `archivo.epub` y crea una salida +++HTML+++ con el análisis básico, incluyendo una nube de palabras y una gráfica de pastel.

## Ejemplo con análisis profundo:

```
pc-analytics -f directorio/al/archivo.epub --deep
```

Semejante al ejemplo anterior pero además crea un análisis profundo, solo visible en +++JSON+++ o +++YAML+++; se crea un +++JSON+++ si no se especificó `\--json` o `\--yaml`.

## Ejemplo con análisis profundo y rotación:

```
pc-analytics -f directorio/al/archivo.epub --deep --rotate
```

Semejante al ejemplo anterior pero además las palabras de la nube serán rotadas aleatoriamente, en lugar de permanecer horizontales.

--- {.espacio-arriba3}

Nota: ¿qué es un `análisis profundo`?, consúltese la documentación de [+++YAML+++](yaml.html). {.espacio-arriba3}
