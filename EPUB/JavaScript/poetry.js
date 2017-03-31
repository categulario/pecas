/*
	Posibilita un control ortotipográfico cuando el verso 
	                        [excede el tamaño de la caja.

    Hasta el final existen las siquientes opciones:
    
    1. poetry.clase
        Indica los elementos HTML que empleará el script. 
        Por defecto no tiene clase y toma los elementos <p>.
    2. poetry.claseVerso
		Indica la clase que se ha de agregar a cada verso
		de manera automática. Por defecto es "py-v".
    3. poetry.clasePalabra
        Indica la clase que se ha de agregar a cada palabra
		de manera automática. Por defecto es "py-w".
	4. poetry.claseCorte
		Indica la clase que se ha de agregar a cada verso
		cortado de manera automática. Por defecto es "py-b".
	5. poetry.claseContenido
		Indica la clase que se ha de agregar a cada contenido
		inicial de manera automática. Por defecto es "py-c".
	6. poetry.contenidoInicial
		Indica el contenido que se ha de agregar antes del
		corte de cada verso. Por defecto es "[".
	7. poetry.estilo
		Indica el estilo que se ha de agegar a cada verso
		cortado. Por defecto es alineado a la derecha.
	
	En la estructura HTML un párrafo equivale a una estrofa
	y cada verso se divide con un salto. Por ejemplo:
	
	Este es un primer verso.
	Este es un segundo verso de la primera estrofa.
	Este es un tercer verso.
	
	Se estructura así:
	
	<p>Este es un primer verso.<br />
	Este es un segundo verso de la primera estrofa.<br />
	Este es un tercer verso.</p>
	
	Se pueden colocar clases e identificadores y otros
	elementos HTML, incluso que abarquen toda la 
	etiqueta <p>, por ejemplo:
	
	<p class="poema"><em>Este es un <b>primer</b> verso.<br />
	Este es un <u>segundo</u> verso de la primera estrofa.<br />
	Este es un <s>tercer</s> verso.</em></p>

	Con esto el resultado obtenido por defecto es:
	
	Este es un primer verso.
	Este es un segundo verso
	 [de la primera estrofa.
	Este es un tercer verso.
	
	E incluso puede generar varias líneas cortadas:
	
	Este es un primer
	          [verso.
	Este es un 
	[segundo verso de
	      [la primera
	         [estrofa.
	Este es un tercer
	           [verso.

    OJO: Los espacios y sangrías en los versos tienen
    que ser manuales, el uso de CSS causa conflicto.
*/

//	Todo lo relativo al control ortotipográfico de los cortes de verso
var poetry = {
    //  Determina si se busca una clase o todos los párrafos
    clase: false,

    //  Determina el nombre de la clase para los versos
    claseVerso: "py-v",

    //  Determina el nombre de la clase para las palabras
    clasePalabra: "py-w",

    //  Determina el nombre de la clase para los versos cortados
    claseCorte: "py-b",

	//	Determina el nombre de la clase para lo que se incluye en cada corte
    claseContenido: "py-c",

    //  Determina el estilo a agregar cuando se detecta un verso cortado
    estilo: "text-align: right;",

    //  Determina el contenido inicial del verso cortado
    contenidoInicial: "<span style='font-style:normal; font-weight: normal;'>[</span>",
    
    //	Determina el identificador para el iframe
    iframe: "py-i",

	//	Inicialización
	init: function () {
		//	Crea un iframe que ayudará a detectar los cambios de fuente
		iframe = document.createElement("iframe");
		iframe.id = poetry.iframe;
		iframe.style.top = "0";
		iframe.style.left = "0";
		iframe.style.width = "100%";
		iframe.style.height = "5em";
		iframe.style.zIndex = "-1";
		iframe.style.visibility = "hidden";
		
		document.body.insertBefore(iframe, document.body.childNodes[0]);
		
		//	Determina si hay cortes para aplicar la corrección ortotipográfica
		poetry.aplicar();
		
		//  Al modificarse el tamaño de pantalla se reinicia para aplicar los cambios
		window.addEventListener("resize", function () {
			poetry.reiniciar();
		});
		
		//  Al modificarse el tamaño de fuente se reinicia para aplicar los cambios
		window.frames[poetry.iframe].addEventListener("resize", function () {
			poetry.reiniciar();
		});
	},
	
    // Obtiene las estrofas
    obtener: function (e) {
        if (!poetry.clase)
            e = document.getElementsByTagName("p");
        else
            e = document.getElementsByClassName(poetry.clase);

        return e;
    },

    //  Aplica estilos cada corte de línea
    aplicar: function () {
        var etiquetas;
        
        // Agrega spans en versos y palabras
        function agregarSpan () {
			//  Elimina espacios al inicio y al final
			poetry.claseVerso = poetry.claseVerso.trim();
			poetry.clasePalabra = poetry.clasePalabra.trim();
			poetry.claseCorte = poetry.claseCorte.trim();

			//  Se aborta si los nombres de las clases son idénticos
			if (poetry.claseVerso == poetry.clasePalabra || poetry.claseVerso == poetry.claseCorte || poetry.clasePalabra == poetry.claseCorte) {
				console.log("Nos nombres de las opciones «claseVerso», «clasePalabra» o «claseCorte» no pueden ser idénticos.");
				return;
			}

			//  Obtiene las estrofas
			etiquetas = poetry.obtener();
			
			//  Agrega un span a cada verso
			for (var i = 0; i < etiquetas.length; i++) {
				var etiqueta = etiquetas[i],
					elementos2 = [],
					etiquetaInterior = null,
					elementos;

				//  Si la estrofa está adentro de una etiqueta, se toma en consideración lo que está contiene
				if (etiqueta.children.length == 1 && etiqueta.children.localName != "br") {
					elementos = etiqueta.children[0].innerHTML.split(/<\s*?br.*?>/);
					etiquetaInterior = etiqueta.children[0].localName;
				//  Si la estrofa está limpia, esta se toma en consideración
				} else
					elementos = etiqueta.innerHTML.split(/<\s*?br.*?>/);

				//  Se separó por verso y se itera
				for (var j = 0; j < elementos.length; j++)
					elementos2.push('<span class="' + poetry.claseVerso + '">' + elementos[j] + '</span>');

				//  Se agregan los cambios
				if (etiquetaInterior == null)
					etiqueta.innerHTML = elementos2.join("<br />");
				//  Se vuelve a agregar la etiqueta interior si es que la estrofa la tenía
				else
					etiqueta.innerHTML = "<" + etiquetaInterior + ">" + elementos2.join("<br />") + "</" + etiquetaInterior + ">";

				// Vuelve a obtener las etiquetas ya que se agregaron los span para los versos
				etiquetas = poetry.obtener();
			}

			//  Agrega un span a cada palabra
			for (var i = 0; i < etiquetas.length; i++) {
				var etiqueta = etiquetas[i];

				// Hace los reemplazos correspondientes
				etiqueta.outerHTML = etiqueta.outerHTML.replace(/>(.*?\n*?.*?)</g, function reemplazo (x) {
					var c = x.replace(">", "").replace("<", "");

					// Si hay contenido
					if (c.length > 0) {
						var ps = c.trim().split(" "),
							ps2 = [];

						//  Se separó por palabras y se itera
						for (var j = 0; j < ps.length; j++) {
							p = ps[j];

							//  A cada palabra se le agrega el span
							if (p != "") {
								ps2.push('<span class="' + poetry.clasePalabra + '">' + p + " </span>");
							}
							//  Si no tiene contenido, quiere decir que originalmente era un espacio
							else
								ps2.push('<span class="' + poetry.clasePalabra + '">&#8194;</span>');
						}

						//  Se reemplaza con los span agregados
						return ">" + ps2.join("") + "<";
					// Si no hay contenido no se hace ningún cambio
					} else
						return x;

					//  Ojo: se hace con outerHTML y no innerHTML para también agarrar los elementos si en la estrofa no hay ninguna etiqueta interior
				});

				// Vuelve a obtener las etiquetas ya que se agregaron los span para las palabras
				etiquetas = poetry.obtener();
			}
		}
		
        //  Saca medidas para determinar si hay corte de línea
        function identificarCorte (otraVez) {
			
			otraVez = otraVez || false;
			
			for (var i = 0; i < etiquetas.length; i++) {
				var estrofa = etiquetas[i],
					versos = estrofa.getElementsByClassName(poetry.claseVerso),
					estrofaAltura = estrofa.offsetHeight;

				//  Evita la separación silábica
				estrofa.style.webkitHyphens = "none";
				estrofa.style.MozHyphens = "none";
				estrofa.style.msHyphens = "none";
				estrofa.style.hyphens = "none";

				//  Se itera cada verso para sacar la medida
				for (var j = 0; j < versos.length; j++) {
					var conjunto = [];

					//	Saca medidas de cada verso para identificar quiebres
					function medicion () {
						var palabras = versos[j].getElementsByClassName(poetry.clasePalabra),
							inicio = false,
							palabraViejaAltura;

						//  Se itera cada palabra para sacar la medida
						for (var k = 0; k < palabras.length; k++) {
							var p = palabras[k];

							//  Se ignora la primera palabra para evitar un falso positivo
							if (k != 0) {
								//  Si la altura no es la misma, implica que hay un quiebre de línea
								if (palabraViejaAltura != p.getBoundingClientRect().top) {
									//  Incrusta un span de quiebre en los casos de quiebres múltiples, si lo hay
									incrustar(p);

									//  Se guarda el elemento en el conjunto
									conjunto.push(p);

									//  Se indica que se inicia el quiebre
									inicio = true;
								//  Si la altura es la misma y sigue el quibre, se guarda el elemento en el conjunto
								} else
									if (inicio)
										conjunto.push(p);
							}

							//  Al final de la iteración se restaura el valor inicial
							if (k == palabras.length - 1)
								inicio = false;

							//  Se guarda la altura para compararla con la siguiente palabra
							palabraViejaAltura = p.getBoundingClientRect().top;
						}
					}

					//  Agrega un span a cada quiebre de línea
					function incrustar (h) {
						if (conjunto.length > 0) {
							var padre,
								hijo,
								quiebre;

							//  Obtiene el padre, el hijo y el hermano mayor
							padre = h.parentNode;
							hijo = h;
							hermano = hijo.previousElementSibling;

							//	Si hay contenido que incrustar y el hermano no es un contenido inicial previamente incrustado, para así evitar duplicados
							if (poetry.contenidoInicial != "" && hermano.innerHTML.replace(/<.*?>/g,"") != poetry.contenidoInicial.replace(/<.*?>/g,"")) {
								//	Crea el span del contenido y lo añade
								contenido = document.createElement("span");
								contenido.className = poetry.claseContenido;
								contenido.innerHTML = poetry.contenidoInicial;
								padre.insertBefore(contenido, hijo);
								
								//	Solo si es la primera vez se agregan las palabras al span de quiebre
								if (!otraVez) {
									//  Crea el span para el quiebre y lo añade
									quiebre = document.createElement("span");
									quiebre.className = poetry.claseCorte;
									padre.insertBefore(quiebre, hijo);

									//  Se itera para incrustar las palabras adentro del span de quiebre
									quiebre.appendChild(contenido);
									for (var i = 0; i < conjunto.length; i++) {
										//  Localiza el elemento deseado
										function localizar (e, p) {
											//  Si el elemento padre corresponde al span del verso
											if (e.parentNode.className == poetry.claseVerso) {
												//  Si se está buscando el padre
												if (p)
													return e.parentNode;
												//  Si se está buscando el hijo
												else
													return e;
											//  De lo contrario, vuelve a llamar la función pero con un elemento más arriba
											} else {
												return localizar(e.parentNode, p);
											}
										}
										
										quiebre.appendChild(localizar(conjunto[i], false));
									}

									//  Oculta el br para evitar una línea vacía debido al despliegue como bloque
									if (quiebre.parentNode.nextSibling != null && quiebre.parentNode.nextSibling.localName == "br")
										quiebre.parentNode.nextSibling.style.display = "none";
								}
							}

							//  Se vacía para evitar conflictos en versos con múltiples cortes de línea
							conjunto = [];
						}
					}

					//  Mide las palabras
					medicion();

					//  Incrusta un span para el quiebre de línea, si lo hay
					incrustar(conjunto[0]);
				}
				
				// Sirve para identificar si después de añadidos los contenidos, hubo nuevos cortes
				etiquetas = poetry.obtener();
				estrofa = etiquetas[i];
				
				//	Si la altura anterior difiere a la actual, quiere decir que hubo nuevos quiebres debido al contenido inicial agregado
				if (estrofaAltura != estrofa.offsetHeight)
					identificarCorte(true);
			}
		}
		
		agregarSpan();
		identificarCorte();
		
		// Añade estilos CSS extras necesarios, en lugar de insertarlos directamente porque no los detecta ebook-viewer
		if (document.getElementById("estilos") == null) {
			estilo = document.createElement("style");
			estilo.type = 'text/css';
			estilo.id = "estilos";
			estilo.innerHTML = "." + poetry.claseCorte + "{display: block; " + poetry.estilo + "}";
			document.getElementsByTagName('head')[0].appendChild(estilo);
		}
    },

    //  Elimina las etiquetas incrustadas por este script
    eliminar: function () {
        etiquetas = poetry.obtener();

        //  Se itera cada estrofa para obtener cada verso, palabra y corte
        for (var i = 0; i < etiquetas.length; i++) {
            //  Elimina cada etiqueta
            function el (e) {
                while (e.length != 0) {
                    if (e[0].className != poetry.claseContenido)
                        e[0].outerHTML = e[0].innerHTML;
                    //  En el caso del contenido elimina todo
                    else
                        e[0].parentNode.removeChild(e[0]);
                }
            }

            //  Llama a la eliminación de cada etiqueta
            el(etiquetas[i].getElementsByClassName(poetry.claseVerso));
            el(etiquetas[i].getElementsByClassName(poetry.clasePalabra));
            el(etiquetas[i].getElementsByClassName(poetry.claseCorte));
            el(etiquetas[i].getElementsByClassName(poetry.claseContenido));
        }
    },

    //  Reinicia los cambios para refrescar los estilos
    reiniciar: function () {
        //  Se eliminan los cambios aplicados
        poetry.eliminar();

        //  Se vuelven a aplicar los cambios
        poetry.aplicar();
    }
}


//  Todo empezará hasta que se cargue el DOM
window.addEventListener("load", function () {
    // poetry.clase = "CLASE_CSS";
    // poetry.claseVerso = "CLASE_CSS";
    // poetry.clasePalabra = "CLASE_CSS";
    // poetry.claseCorte = "CLASE_CSS";
    // poetry.claseContenido = _"CLASE_CSS";
    // poetry.contenidoInicial = "CONTENIDO";
    // poetry.estilo = "CODIGO_CSS";
    poetry.init();	// Aplica el script
});
