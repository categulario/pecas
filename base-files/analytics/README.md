# Analytics

Analytics analiza archivos EPUB, XML, XHTML o HTML para un mayor cuidado editorial y técnico.

## Uso:

```
pc-analytics -f [archivo]
```

## Descripción de los parámetros

### Parámetro necesario:

* `-f` = [file] Archivo EPUB, XML, XHTML o HTML a analizar.

### Parámetros opcionales:

* `--deep` = Realiza un análisis profundo del archivo.
* `--json` = Crea una salida del análisis en formato JSON.
* `--yaml` = Crea una salida del análisis en formato YAML.
* `--rotate` = Permite rotación aleatoria de las palabras en la nube de palabras de 30° a 150°.

### Parámetros únicos:

* `-v` = [version] Muestra la versión.
* `-h` = [help] Muestra la ayuda, la cual es este contenido.

## Ejemplos

### Ejemplo sencillo:

```
pc-analytics -f directorio/al/archivo.epub
```

Analiza el `archivo.epub` y crea una salida HTML con el análisis básico, incluyendo una nube de palabras y una gráfica de pastel.

### Ejemplo con análisis profundo:

```
pc-analytics -f directorio/al/archivo.epub --deep
```

Semejante al ejemplo anterior pero además crea un análisis profundo, solo visible en JSON o YAML; se crea un JSON si no se especificó `--json` o `--yaml`.

### Ejemplo con análisis profundo y rotación:

```
pc-analytics -f directorio/al/archivo.epub --deep --rotate
```

Semejante al ejemplo anterior pero además las palabras de la nube serán rotadas aleatoriamente, en lugar de permanecer horizontales.

---

# Notas 

## Lista de palabras vacías

Las palabras vacías (*stopwords* en inglés) son términos ignorados al 
momento de realizar un análisis, ya que se catalogan como «ruido» o 
como «poco significativas». Ejemplos de palabras vacías son «de», 
«para», «donde», etcétera.

> [Enlace a la entrada de la Wikipedia](https://es.wikipedia.org/wiki/Palabra_vac%C3%ADa).

Las listas de palabras vacías de Pecas se localizan en [`src/common/stopwords/`](https://github.com/NikaZhenya/pecas/tree/master/src/common/stopwords).

## Estructura del análisis

> El archivo HTML contempla solo algunos de los siguientes elementos.
> Solo si se especifica una salida JSON o YAML se obtiene el objeto completo listo para procesar.

El análisis ordinario (sin la opción `--deep`) genera este objeto:

```
{
  "title": String,
  "words_digits": {
    "all": Integer,
    "uniq_case_on": Integer,
    "list_all_case_on" : Array,
    "list_uniq_case_on" : Array
  },
  "words": {
    "all": Integer,
    "uniq_case_on": Integer,
    "list_all_case_on" : Array,
    "list_uniq_case_on" : Array
  },
  "digits": {
    "all": Integer,
    "uniq_case_on": Integer,
    "list_all_case_on" : Array,
    "list_uniq_case_on" : Array
  },
  "unknown": {
    "all": Integer,
    "uniq_case_on": Integer,
    "list_all_case_on" : Array,
    "list_uniq_case_on" : Array
  },
  "uppercase": {
    "all": Integer,
    "uniq_case_on": Integer,
    "list_all_case_on" : Array,
    "list_uniq_case_on" : Array
  },
  "top": {
    "all_clean": Integer,
    "list_all_clean" : Array
  },
  "diversity": 7.51481909160893,
  "tags": {
    "all": Integer,
    "types": Integer,
    "list" : Array
  },
  "hunspell": {
    "all": Integer,
    "list" : Array
  },
  "linkchecker": {
    "all": Integer,
    "list" : Array
  }
}
```

Los campos son muy semejantes, donde cada uno significa lo siguiente:

* `title`: título de la obra (EPUB) o del archivo.
* `words_digits`: objeto para las palabras y dígitos.
* `words`: objeto para las palabras.
* `digits`: objeto para los dígitos.
* `unknown`: objeto para las líneas de texto que no pudieron ser catalogadas como palabras o dígitos.
* `uppercase`: objeto para las palabras con versal inicial.
* `top`: objeto de palabras más comunes excluyendo palabras vacías.
* `diversity`: índice de diversidad (división del total de palabras entre el total de palabras únicas).
* `tags`: objeto para las etiquetas.
* `hunspell`: objeto para las posibles erratas encontradas por Hunspell.
* `linkchecker`: objeto para la verificación de enlaces realizada por Linkchecker.
* `all`: total de los casos encontrados.
* `all_clean`: total de casos encontrados excluyendo palabras vacías.
* `uniq_case_on`: total de los casos encontrados sin repeticiones y sensible a versales.
* `list_all_case_on`: conjunto de todos los casos encontrados sensible a versales.
* `list_all_clean`: conjunto de todos los casos encontrados excluyendo palabras vacías.
* `list_uniq_case_on`: conjunto de todos los casos encontrados sin repeticiones y sensible a versales.
* `types`: total de tipos de etiquetas encontradas.

### El caso de las listas

Todas las listas son conjuntos, pero según el caso tienen una estructura específica.

#### 1. `list_uniq_case_on`

```
[
  String
]
```

Cada línea de texto es una palabra o dígito.

#### 2. `list_all_case_on` y la `list` de `hunspell`

```
[
  [
    String,
    Integer
  ]
]
```

Cada elemento está a su vez compuesto por un conjunto de dos elementos:

* `String`: palabra encontrada.
* `Integer`: número de coincidencias de la palabra.

#### 3. `list_all_clean`

```
[
  [
    String,
    Integer,
    Float
  ]
]
```

Similar a `list_all_case_on` pero con un elemento adicional:

* `Float`: expresión en porcentaje del número de coincidencias en relación al total de palabras.

#### 4. `list` de `tags`

```
[
  {
    "tag": String,
    "length": Integer,
    "types": [
      [
        String,
        Integer
      ]
    ]
  }
]
```

Cada elemento es un objeto compuesto por las siguientes llaves:

* `tag`: tipo de etiqueta; p. ej. `h1`.
* `length`: número de coincidencias de la etiqueta.
* `types`: Cada uno de los tipos encontrados de esa etiqueta y su número de coincidencias; p. ej. `["<h1 class=\"centrado\">",1]`.

#### 5. `list` de `linkchecker`

```
[
  {
    "urlname": String,
    "parentname": String,
    "baseref": String,
    "result": String,
    "warningstring": String,
    "infostring": String,
    "valid": String,
    "url": String,
    "line": String,
    "column": String,
    "name": String,
    "dltime": String,
    "size": String,
    "checktime": String,
    "cached": String,
    "level": String,
    "modified": String
  }
]
```

Para la descripción de cada una de las llaves, véase `linkchecker -h`.

## Estructura del «análisis profundo»

La diferencia entre el análisis ordinario y el análisis profundo es 
que el último también contempla casos donde los análisis son 
insensibles a versales:

* En los totales o listas con `case_on`: `palabra ≠ Palabra`.
* En los totales o listas con `case_off`: `palabra = Palabra` y en
  la lista todas se mostrarán en bajas (`palabra` y no `Palabra`, p. ej.).

La descripción de los campos son las mismas al análisis ordinario,
pero sumándose los `case_off`, por lo que se tiene la siguiente estructura:

```
{
  "title": String,
  "words_digits": {
    "all": Integer,
    "uniq_case_on": Integer,
    "uniq_case_off": Integer,
    "list_all_case_on" : Array,
    "list_all_case_off" : Array,
    "list_uniq_case_on" : Array,
    "list_uniq_case_off" : Array
  },
  "words": {
    "all": Integer,
    "uniq_case_on": Integer,
    "uniq_case_off": Integer,
    "list_all_case_on" : Array,
    "list_all_case_off" : Array,
    "list_uniq_case_on" : Array,
    "list_uniq_case_off" : Array
  },
  "digits": {
    "all": Integer,
    "uniq_case_on": Integer,
    "uniq_case_off": Integer,
    "list_all_case_on" : Array,
    "list_all_case_off" : Array,
    "list_uniq_case_on" : Array,
    "list_uniq_case_off" : Array
  },
  "unknown": {
    "all": Integer,
    "uniq_case_on": Integer,
    "uniq_case_off": Integer,
    "list_all_case_on" : Array,
    "list_all_case_off" : Array,
    "list_uniq_case_on" : Array,
    "list_uniq_case_off" : Array
  },
  "uppercase": {
    "all": Integer,
    "uniq_case_on": Integer,
    "uniq_case_off": Integer,
    "list_all_case_on" : Array,
    "list_all_case_off" : Array,
    "list_uniq_case_on" : Array,
    "list_uniq_case_off" : Array
  },
  "top": {
    "all_clean": Integer,
    "all_dirty": Integer,
    "list_all_clean" : Array,
    "list_all_dirty" : Array
  },
  "diversity": 7.51481909160893,
  "tags": {
    "all": Integer,
    "types": Integer,
    "list" : Array
  },
  "hunspell": {
    "all": Integer,
    "list" : Array
  },
  "linkchecker": {
    "all": Integer,
    "list" : Array
  }
}
```
