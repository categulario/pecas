var zoom = {
    //  Lo que aumentará o disminuirá, donde tamaño normal = 1 y «fraccion» = 1 / fraccion
    fraccion: 8,

    //  Indica si restaurar el zoom por defecto
    restaurar: false,

    //  Indica si también se hay zoom en versiones de escritorio
    computadora: false,

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
            margen = 3, // Ojo: hay dispositivos que los lados se utilizan para cambiar de página, disminuir este espacio puede ocasionar conflictos
            m = movil();

        //  De: https://stackoverflow.com/questions/11381673/detecting-a-mobile-browser#11381730
        function movil () {
            var check = false;
            (function(a){if(/(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows ce|xda|xiino|android|ipad|playbook|silk/i.test(a)||/1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(a.substr(0,4))) check = true;})(navigator.userAgent||navigator.vendor||window.opera);
            return check;
        };

        //  Aborta la creación si no es un dispositivo móvil y no se especificó que fuera en cualquier dispositivo
        if (!m && !zoom.computadora)
            return;

        function estilo (dom) {
            dom.style.fontFamily = "Tahoma, Geneva, sans-serif";
            dom.style.display = "inline";
            dom.style.cursor = "pointer";
            dom.style.color = "gray";
            dom.style.webkitUserSelect = "none";
            dom.style.MozUserSelect = "none";
            dom.style.msUserSelect = "none";
            dom.style.userSelect = "none";

            //  Para evitar que la hoja de estilo modifique el aspecto
            dom.style.margin = "0";
            dom.style.padding = "0";
            dom.style.border = "0";
            dom.style.lineHeight = "1.25";
            dom.style.fontSize = "1em";
            dom.style.verticalAlign = "baseline";
            dom.style.textAlign = "justify";
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
        estilo(zoomMenor);
        estilo(zoomMayor);
        estilo(separador);

        zoomMayor.style.fontSize = "1.5em";

        separador.style.fontSize = "1.5em";
        separador.style.margin = "auto .25em";

        fuente.style.position = "fixed";
        fuente.style.top = margen + "em";
        fuente.style.right = margen + "em";
        fuente.style.zIndex = "999";
        fuente.style.textAlign = "right";
        fuente.style.padding = ".5em";
        fuente.style.borderRadius = ".5em";
        fuente.style.backgroundColor = "white";

        contenedor.style.overflow = "auto";
        contenedor.style.width = "100%";
        contenedor.style.height = "calc(100vh - " +                                 // Altura = alto de la ventana
            fuente.getBoundingClientRect().bottom + "px - " +                       // - posición y inferior de los botones
            parseFloat(window.getComputedStyle(document.body)["margin-bottom"]) +   // - margen inferior del body
            "px)";
        contenedor.style.marginTop = fuente.getBoundingClientRect().bottom + "px";  // Margen superior = posición y inferior de los botones

        document.body.style.overflow = "hidden";

        /*  La estructura generada es (ignorando los estilos directos):
            <div id="contenedor">
                … [Contenido del libro]
            </div>
            <div id="fuente">
                <p id="zoom-menor">A</p>
                <p id="separador">|</p>
                <p id="zoom-mayor">A</p>
            </div>
            <style>…</style>
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
    // zoom.computadora = true;    // Descomentar si también se quiere aplicar a computadoras
    // zoom.animacion.mostrar = false;    // Descomentar si no se desea animación
    // zoom.restaurar = true;  // Descomentar si siempre se desea empezar con el zoom por defecto
    zoom.crear();
};
