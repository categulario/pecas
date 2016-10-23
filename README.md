# Herramientas

A través de eventos o talleres este perro ha tenido que escribir algo de
código para ahorrarse mucho trabajo repetitivo. Con el fin de hacer más
accesibles estas herramientas, se ha creado este repositorio para irlas
recolectando.

# Requisitos

Las herramientas requieren [Ruby](https://www.ruby-lang.org/es/) 1.9.3 o posterior.

# Utilización

Las herramientas pueden utilizarse de tres maneras:

1. Escribiendo `ruby` en la terminal y arrastrando el *script* correspondiente.
2. Arrastrando el *script* deseado a la terminal.
3. Instalando los binarios para utilizar los *script* directamente.

# Instalación de los binarios

###### 1. Ingresa a esta carpeta (`Herramientas`) en la terminal.
###### 2. Llama al instalador con `./instalar.sh`
###### 3. ¡Listo!

## Utilización de los binarios

Solo es necesario escribir el nombre del binario para llamar al script:

* `pt-creator` llama a `creator.rb`, cuya documentación se encuentra en [`1-Creador`](https://github.com/ColectivoPerroTriste/Herramientas/tree/master/EPUB/1-Creador).
* `pt-divider` llama a `divider.rb`, cuya documentación se encuentra en [`2-Divisor`](https://github.com/ColectivoPerroTriste/Herramientas/tree/master/EPUB/2-Divisor).
* `pt-notes` llama a `notes.rb`, cuya documentación se encuentra en [`3-Notas`](https://github.com/ColectivoPerroTriste/Herramientas/tree/master/EPUB/3-Notas).
* `pt-cites` llama a `cites.rb`, cuya documentación se encuentra en [`4-Bibliografia`](https://github.com/ColectivoPerroTriste/Herramientas/tree/master/EPUB/4-Bibliografia).
* `pt-recreator` llama a `recreator.rb`, cuya documentación se encuentra en [`5-Recreador`](https://github.com/ColectivoPerroTriste/Herramientas/tree/master/EPUB/5-Recreador).
* `pt-changer` llama a `changer.rb`, cuya documentación se encuentra en [`6-Cambiador`](https://github.com/ColectivoPerroTriste/Herramientas/tree/master/EPUB/6-Cambiador).

    Si ningún binario se encuentra, es necesario refrescar el archivo de
    inicialización de usuario que `./instalar.sh` nos menciona. Para hacer esto
    solo tiene que cerrar y volver a abrir la terminal. Si no se desea cerrarla,
    se ha de escribir `source <archivo de inicialización de usuario>`. Este
    procedimiento solo se hace una vez, cuando se termina la instalación.

    Para usuarios de Windows, una vez instalado Ruby han de buscar el programa
    «Start Command Prompt with Ruby» para no tener conflicto con la ejecución de
    los binarios.

# Pendientes

* `cites.rb`.
  * Terminar el desarrollo.
* `recreator.rb`.
  * Tabla de contenidos jerarquizado.
* `changer.rb`.
  * Terminar el desarrollo.
* `index.rb`.
  * Añadir este séptimo `script` para la creación de índices analíticos.

# Licencia

Las herramientas están bajo licencia GPL v3.
