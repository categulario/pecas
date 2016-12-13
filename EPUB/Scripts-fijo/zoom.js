var zoom = {
    //  Lo que aumentará o disminuirá, donde tamaño normal = 1 y «fraccion» = 1 / fraccion
    fraccion: 8,

    //  Indica si restaurar el zoom por defecto
    restaurar: false,

    //  Para añadir animacion
    animacion: {
        "mostrar": true,
        "duracion": 0.2
    },

    //  Restablece el zoom indicado por el usuario
    restablecer: function () {

        // «unfade» de: http://stackoverflow.com/questions/6121203/how-to-do-fade-in-and-fade-out-with-javascript-and-css
        function fadeIn (element) {
            var op = 0.1;  // initial opacity
            element.style.display = 'block';
            var timer = setInterval(function () {
                if (op >= 1){
                    clearInterval(timer);
                }
                element.style.opacity = op;
                element.style.filter = 'alpha(opacity=' + op * 100 + ")";
                op += op * zoom.animacion.duracion;
            }, 10);
        }

        //  Elimina el zoom guardado, haciendo que la fuente se vea con el tamaño por defecto
        if (zoom.restaurar)
            localStorage.zoom = 0;

        //  Solo si el zoom está definido y no es 0
        if (typeof localStorage.zoom !== "undefined" && localStorage.zoom !== "0") {
            var z = parseInt(localStorage.zoom),
                abs = Math.abs(z);

            //  Según las veces que se aumentó o disminuyó, se manda a cambiar el zoom
            for (var i = 1; i <= abs; i++)
                if (z < 0)
                    zoom.cambiar("zoom-menor", true);
                else
                    zoom.cambiar("zoom-mayor", true);
        }

        //  Muestra el texto en fade si así se quiere
        if (zoom.animacion.mostrar)
            fadeIn(document.body);
    },

    //  Guarda el zoom para restablecerlo
    guardar: function (aumento) {
        var z;

        //  Si es la primera vez, es cero; de lo contrario, se obtiene el zoom guardado previamente
        if (typeof localStorage.zoom === "undefined")
            z = 0;
        else
            z = parseInt(localStorage.zoom);

        //  Si aumenta, se suma 1; de lo contrario, se resta uno
        if (aumento)
            z = z + 1;
        else
            z = z - 1;

        //  Se guarda
        localStorage.zoom = z;
    },

    //  Aumenta o disminuye la fuente
    cambiar: function (id, restablece) {
        var contenedor = document.getElementById("contenedor"),
            etiquetas = contenedor.getElementsByTagName("*");

        //  Por defecto es nulo
        restablece = restablece || null;

        //  Iteración de todas las etiquetas adentro del body
        for (var i = 0; i < etiquetas.length; i++) {
            var etiqueta = etiquetas[i],
                //  Se obtiene el tamaño de fuente de la etiqueta, si lo tiene, en números con decimales
                tamano = parseFloat(window.getComputedStyle(etiqueta, null).getPropertyValue('font-size')),
                //  Se obtiene la fracción del tamaño de la fuente
                cantidad = tamano / zoom.fraccion,
                relacion;

            //  Si se quiere disminur, se resta la cantidad; de lo contrario, se aumenta
            if (id == "zoom-menor") {
                relacion = tamano - cantidad;

                //  Guarda el zoom
                if (i == 0 && restablece == null)
                    this.guardar(false);
            }
            else {
                relacion = tamano + cantidad;

                //  Guarda el zoom
                if (i == 0 && restablece == null)
                    this.guardar(true);
            }

            //  Se cambia el tamaño
            etiqueta.style.fontSize = relacion + "px";
        }
    },

    //  Crea los elementos para poder aumentar o disminuir la fuente
    crear: function () {
        var contenedor = document.createElement("div"),
            fuente = document.createElement("div"),
            zoomMenor = document.createElement("p"),
            zoomMayor = document.createElement("p"),
            separador = document.createElement("p"),
            margen = 3;  // Ojo: hay dispositivos que los lados se utilizan para cambiar de página, disminuir este espacio puede ocasionar conflictos

        function estilo (dom) {
            dom.style.fontFamily = "Tahoma, Geneva, sans-serif";
            dom.style.display = "inline";
            dom.style.cursor = "pointer";
            dom.style.webkitUserSelect = "none";
            dom.style.MozUserSelect = "none";
            dom.style.msUserSelect = "none";
            dom.style.userSelect = "none";
        }

        //  Oculta el body porque la animación es para mostrarlo
        if (zoom.animacion.mostrar)
            document.body.style.opacity = 0;

        //  Se establecen id para estipular su aspecto en el CSS
        contenedor.id = "contenedor";
        fuente.id = "fuente";
        zoomMenor.id = "zoom-menor";
        zoomMayor.id = "zoom-mayor";
        separador.id = "separador";

        //  Contenido de los botones
        zoomMenor.innerHTML = "A";
        zoomMayor.innerHTML = "A";
        separador.innerHTML = "|";

        //  Se pone el contenido en el contenedor
        while (document.body.childNodes.length > 0)
            contenedor.appendChild(document.body.childNodes[0]);

        //  Se agregan los elementos al DOM
        fuente.appendChild(zoomMenor);
        fuente.appendChild(separador);
        fuente.appendChild(zoomMayor);
        document.body.appendChild(contenedor);
        document.body.appendChild(fuente);

        //  Estilos
        document.body.style.overflow = "hidden";

        contenedor.style.overflow = "auto";
        contenedor.style.width = "100%";
        contenedor.style.height = "calc(100vh - " +          // Altura = alto de la ventana
            fuente.offsetHeight + "px - " +                                         // - alto de los botones
            parseFloat(window.getComputedStyle(document.body)["margin-bottom"]) +   // - margen inferior del body
            "px)";

        fuente.style.position = "fixed";
        fuente.style.top = margen + "em";
        fuente.style.right = margen + "em";
        fuente.style.zIndex = "999";
        fuente.style.textAlign = "right";
        fuente.style.padding = ".5em";
        fuente.style.borderRadius = ".5em";
        fuente.style.color = "gray";
        fuente.style.backgroundColor = "white";

        separador.style.fontSize = "1.5em";
        separador.style.margin = "auto .25em";

        zoomMayor.style.fontSize = "1.5em";

        estilo(zoomMenor);
        estilo(zoomMayor);
        estilo(separador);

        /*  La estructura generada es (ignorando los estilos directos):
            <div id="contenedor">
                ... [Contenido del libro]
            </div>
            <div id="fuente">
                <p id="zoom-menor">A</p>
                <p id="separador">|</p>
                <p id="zoom-mayor">A</p>
            </div>
        */

        //  Cuando se presionen los botones se ejecutará la función «zoom»
        document.getElementById("zoom-menor").addEventListener("click", function (e) {
            e.preventDefault();
            zoom.cambiar(this.id);
        });
        document.getElementById("zoom-mayor").addEventListener("click", function (e) {
            e.preventDefault();
            zoom.cambiar(this.id);
        });

        //  Si hay zoom guardado, lo restablece
        zoom.restablecer();
    }
};

//  Todo empezará hasta que se cargue el DOM
window.onload = function () {
    // zoom.animacion.mostrar = false;    // Descomentar si no se desea animación
    // zoom.restaurar = true;  // Descomentar si siempre se desea empezar con el zoom por defecto
    zoom.crear();
};
