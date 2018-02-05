# Doctor

Doctor analiza el estado de Pecas y sus dependencias.

## Uso:

  ```
  pc-doctor
  ```

## Descripción de los parámetros

### Parámetros únicos:

* `-v` = [version] Muestra la versión.
* `-h` = [help] Muestra la ayuda, la cual es este contenido.
* `--update` = Actualiza Pecas.
* `--restore` = Restaura Pecas.
* `--install-dependencies` = Instala dependencias de Pecas.

## Ejemplos

### Ejemplo sencillo:

```
  pc-doctor
```

Da un análisis del estado de Pecas y sus dependencias.

### Ejemplo con un proyecto EPUB específico:

```
  pc-doctor --update
```

Actualiza Pecas.

### Ejemplo con un proyecto EPUB y metadatos específicos:

```
  pc-doctor --restore --update --install-dependencies
```

Restaura y actualiza Pecas, para después instalar sus dependencias.
