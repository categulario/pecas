# Uso de `pc-doctor`

Doctor analiza el estado de Pecas y sus dependencias.

## Uso:

```
pc-doctor
```
  
## Parámetros únicos:

* `-v` = [version] Muestra la versión.
* `-h` = [help] Muestra esta ayuda.
* `\--update` = Actualiza Pecas.
* `\--restore` = Restaura Pecas.
* `\--install-dependencies` = Instala dependencias de Pecas.

## Ejemplo sencillo:

```
pc-doctor
```

Da un análisis del estado de Pecas y sus dependencias.
 
## Ejemplo para actualizar:

```
pc-doctor --update
```

Actualiza Pecas.

## Ejemplo para restaurar, actualizar e instalar dependencias:

```
pc-doctor --restore --update --install-dependencies
```

Restaura y actualiza Pecas, para después instalar sus dependencias.
