# _Scripts_ de JavaScript para EPUB

Estos _scripts_ implementan algunas funcionalidades
adicionales a los EPUB.

## Implementación {.espacio-arriba3}

Solo vincula el archivo `.js` adentro de la etiqueta
`head` de los XHTML del EPUB, por ejemplo:

```
<script type="text/javascript" src="script.js"></script>
```

## Documentación {.espacio-arriba3}

Para saber cómo emplear cada uno de los _scripts_
solo es necesario leer las líneas comentadas al
inicio de estos archivos.

## *Scripts* {.espacio-arriba3}

* [`poetry.js`](https://github.com/NikaZhenya/pecas/blob/master/epub/others/javascript/poetry.js). 
  Posibilita un control ortotipográfico cuando el verso excede el tamaño de la caja.

> **CUIDADO**. Este _script_ tiene errores que aún no han sido
> arreglados.

* [`zoom.js`](https://github.com/NikaZhenya/pecas/blob/master/epub/others/javascript/zoom.js). 
  Posibilita el aumento o disminución del tamaño de la tipografía en EPUB de diseño fijo.

