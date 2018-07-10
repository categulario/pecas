# Uso de `pc-index`

Index agrega índices índices analíticos a archivos +++HTML+++, +++HTM+++, +++XHTML+++, +++XML+++ o TeX.

## Uso para inicializar:

```
pc-index --init
```

## Uso para crear índices:

```
pc-index
```

## Parámetro necesario para la inicialización

* `\--init` = Crea el archivo +++YAML+++ para la información de los índices.

## Parámetros opcionales para la inicialización

* `-d` = [directory] Ubicación de la carpeta destino para el +++YAML+++.
* `\--index` = Nombre del archivo +++YAML+++.

## Parámetros opcionales para la autmatización

* `-d` = [directory] Ruta a los archivos +++HTML+++, +++HTM+++, +++XHTML+++, +++XML+++ o TeX.
* `-s` = [style sheet] Ruta al archivo +++CSS+++ que se desea incluir.
* `\--index` = Nombre del archivo +++YAML+++ con la información de los índices.
* `\--no-alphabet` = Evita añadir letras del alfabeto en la lista de términos, dejando un espacio en su lugar.
* `\--two-columns` = Agrega estilo para desplegar dos columnas; en sintaxis tipo +++HTML+++ se despliega a partir de los 768px de ancho.

## Parámetros únicos:

* `-v` = [version] Muestra la versión.
* `-h` = [help] Muestra esta ayuda.

## Ejemplo sencillo:

```
pc-index
```

Analiza los archivos +++HTML+++, +++HTM+++, +++XHTML+++, +++XML+++ o TeX de la carpeta actual así como el archivo `index-data.yaml` previamente generado para crear índices a una columna, con letras del alfabeto y con los estilos por defecto.

## Ejemplo complejo:

```
pc-index --no-alphabet --two-columns
```

Similar al ejemplo anterior pero sin letras del alfabeto y con estilo de dos columnas.

--- {.espacio-arriba3}

Nota: se generará un archivo `index-data.yaml` para la creación de índices analíticos. Si se desconoce cómo completarlo, consúltese la documentación de [+++YAML+++](yaml.html). {.espacio-arriba3}
