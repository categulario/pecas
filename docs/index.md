# Pecas: herramientas editoriales

Pecas es un conjunto de _scripts_ que agilizan varios de los procesos 
del quehacer editorial. Las herramientas están en [desarrollo continuo](https://es.wikipedia.org/wiki/Liberaci%C3%B3n_continua)
y siguen el modelo del [_single source and online publishing_](https://github.com/NikaZhenya/pecas#single-source-and-online-publishing-ssop),
cuya propuesta metodológica es la [edición ramificada](http://ed.cliteratu.re/).

## Instalación

Copia y pega en la terminal:

```bash
(cd ~ && mkdir .pecas && cd .pecas && git clone --depth 1 https://github.com/NikaZhenya/pecas.git . && bash install.sh) && source ~/.bash_profile
```

## Requisitos y verificación de estado

Pecas cuenta con una herramienta que permite ver si existe una actualización
disponible o si alguna dependencia aún no está instalada. Su ejecución desde
la terminal es:

```
pc-doctor
```

## Utilización

Todas las herramientas de Pecas cuentan con el comando `-h` que permite
leer su documentación. _Por ejemplo_:

```
pc-doctor -h
```

## Actualización

Pecas se actualiza constantemente, se arreglan errores o se implementan
nuevos elementos. ¡No te quedes fuera!, de vez en cuando ejecuta:

```
pc-doctor --update
```

## Solución de problemas y uso en Windows

¿Estás teniendo dificultades con Pecas? Visita el área de [solución de problemas](html/problemas.html).

¿Usas Windows y quieres usar Pecas? Visita [este apartado](https://nikazhenya.github.io/pecas/html/problemas.html#como-uso-pecas-en-windows)
del área de solución de problemas.
