# Pecas Markdown

Pecas Markdown se compone de dos tipos de elementos:

1. [**Elementos en bloque**](#elementos-en-bloque) que se crean dejando una línea en blanco entre cada bloque.
2. [**Elementos en línea**](#elementos-en-linea) que se insertan adentro de un bloque.

## Elementos en bloque {.espacio-arriba3}

### Párrafo

<div class="example"><div><div>

```markdown
Párrafo. Lorem ipsum dolor sit amet, consectetur adipiscing elit. 
Maecenas ac lacus viverra, scelerisque nisl non, pretium turpis.

Otro párrafo. Lorem ipsum dolor sit amet, consectetur adipiscing elit. 
Maecenas ac lacus viverra, scelerisque nisl non, pretium turpis.
```

</div><div>

```html
<p>Párrafo. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas ac lacus viverra, scelerisque nisl non, pretium turpis.</p>
<p>Otro párrafo. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas ac lacus viverra, scelerisque nisl non, pretium turpis.</p>
```

</div></div><div>

Párrafo. Lorem ipsum dolor sit amet, consectetur adipiscing elit. 
Maecenas ac lacus viverra, scelerisque nisl non, pretium turpis.

Otro párrafo. Lorem ipsum dolor sit amet, consectetur adipiscing elit. 
Maecenas ac lacus viverra, scelerisque nisl non, pretium turpis.

</div></div>

### Encabezados

<div class="example"><div><div>

```markdown
# Encabezado 1

## Encabezado 2

### Encabezado 3

#### Encabezado 4

##### Encabezado 5

###### Encabezado 6
```

</div><div>

```html
<h1>Encabezado 1</h1>
<h2>Encabezado 2</h2>
<h3>Encabezado 3</h3>
<h4>Encabezado 4</h4>
<h5>Encabezado 5</h5>
<h6>Encabezado 6</h6>
```

</div></div><div>

# Encabezado 1

## Encabezado 2

### Encabezado 3

#### Encabezado 4

##### Encabezado 5

###### Encabezado 6

</div></div>

### Bloque de cita

<div class="example"><div><div>

```markdown
Párrafo. Lorem ipsum dolor sit amet, consectetur adipiscing elit.

> Bloque de cita. Lorem ipsum dolor sit amet, consectetur adipiscing elit. 
Maecenas ac lacus viverra, scelerisque nisl non, pretium turpis.

> Otro bloque de cita. Lorem ipsum dolor sit amet, consectetur adipiscing elit. 
> Maecenas ac lacus viverra, scelerisque nisl non, pretium turpis.
```

</div><div>

```html
<p>Párrafo. Lorem ipsum dolor sit amet, consectetur adipiscing elit.</p>
<blockquote>
    <p>Bloque de cita. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas ac lacus viverra, scelerisque nisl non, pretium turpis.</p>
</blockquote>
<blockquote>
    <p>Otro bloque de cita. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas ac lacus viverra, scelerisque nisl non, pretium turpis.</p>
</blockquote>
```

</div></div><div>

Párrafo. Lorem ipsum dolor sit amet, consectetur adipiscing elit.

> Bloque de cita. Lorem ipsum dolor sit amet, consectetur adipiscing elit. 
Maecenas ac lacus viverra, scelerisque nisl non, pretium turpis.

> Otro bloque de cita. Lorem ipsum dolor sit amet, consectetur adipiscing elit. 
> Maecenas ac lacus viverra, scelerisque nisl non, pretium turpis.

</div></div>

### Imagen

<div class="example"><div><div>

```markdown
![Imagen con pie de foto.](../img/gnu.svg)

![](../img/tux.svg)
```

</div><div>

```html
<figure>
    <img src="../img/gnu.svg" alt="Imagen con pie de foto.">
    <figcaption>Imagen con pie de foto.</figcaption>
</figure>
<img src="../img/tux.svg">
```

</div></div><div>

![Imagen con pie de foto.](../img/gnu.svg)

![](../img/tux.svg)

</div></div>

### Lista no numerada

<div class="example"><div><div>

```markdown
* Lista no numerada.
  + Puede ser con «*», «+» o «-».
  - Y puede anidarse.
    @type[em-dash]
    * Incluso cambiar el tipo de viñeta a
      [estos](https://www.w3schools.com/cssref/pr_list-style-type.asp).
    * O por estos: `dash`, `en-dash` o `em-dash`.
```

</div><div>

```html
<ul>
    <li><p>Lista no numerada.</p></li>
    <li class="no-count">
        <ul>
            <li><p>Puede ser con «*», «+» o «-».</p></li>
            <li><p>Y puede anidarse.</p></li>
            <li class="no-count">
                <ul class="em-dash">
                    <li><p>Incluso cambiar el tipo de viñeta a <a href="https://www.w3schools.com/cssref/pr_list-style-type.asp">estos</a>.</p></li>
                    <li><p>O por estos: <code>dash</code>, <code>en-dash</code> o <code>em-dash</code>.</p></li>
                </ul>
            </li>
        </ul>
    </li>
</ul>
```

</div></div><div>

* Lista no numerada.
  + Puede ser con «*», «+» o «-».
  - Y puede anidarse.
    @type[em-dash]
    * Incluso cambiar el tipo de viñeta a
      [estos](https://www.w3schools.com/cssref/pr_list-style-type.asp).
    * O por estos: `dash`, `en-dash` o `em-dash`.

</div></div>

### Lista numerada

<div class="example"><div><div>

```markdown
1. Lista numerada.
  2. No es necesaria una numeración correcta.
  20. Y puede anidarse.
    @type[lower-alpha]
    1. Incluso cambiar el tipo de viñeta a
      [estos](https://www.w3schools.com/cssref/pr_list-style-type.asp).
```

</div><div>

```html
<ol>
    <li><p>Lista numerada.</p></li>
    <li class="no-count">
        <ol>
            <li><p>No es necesaria una numeración correcta.</p></li>
            <li><p>Y puede anidarse.</p></li>
            <li class="no-count">
                <ol style="list-style-type: lower-alpha !important">
                    <li><p>Incluso cambiar el tipo de viñeta a <a href="https://www.w3schools.com/cssref/pr_list-style-type.asp">estos</a>.</p></li>
                </ol>
            </li>
        </ol>
    </li>
</ol>
```

</div></div><div>

1. Lista numerada.
  2. No es necesaria una numeración correcta.
  20. Y puede anidarse.
    @type[lower-alpha]
    1. Incluso cambiar el tipo de viñeta a
      [estos](https://www.w3schools.com/cssref/pr_list-style-type.asp).

</div></div>

### Bloque de código

<div class="example"><div><div>

```markdown
&#96;&#96;&#96;
Bloque de código genérico.

Soporta varias líneas.
&#96;&#96;&#96;

&#96;&#96;&#96;ruby
# Bloque de código con clase según el tipo de sintaxis.

# Soporta varias líneas, este ejemplo es con la clase «ruby».
&#96;&#96;&#96;
```

</div><div>

```html
<pre class="">
    <code class="code-line-1">Bloque de código genérico.</code>
    <code class="code-line-2"></code>
    <code class="code-line-3">Soporta varias líneas.</code>
</pre>
<pre class="ruby">
    <code class="code-line-1"># Bloque de código con clase según el tipo de sintaxis.</code>
    <code class="code-line-2"></code>
    <code class="code-line-3"># Soporta varias líneas, este ejemplo es con la clase «ruby».</code>
</pre>
```

</div></div><div>

```
Bloque de código genérico.

Soporta varias líneas.
```

```ruby
# Bloque de código con clase según el tipo de sintaxis.

# Soporta varias líneas, este ejemplo es con la clase «ruby».
```

</div></div>

### Línea horizontal

<div class="example"><div><div>

```markdown
Línea horizontal:

---
```

</div><div>

```html
<p>Línea horizontal:</p>
<hr/>
```

</div></div><div>

Línea horizontal:

---

</div></div>

### Opción de clases e identificador

<div class="example"><div><div>

```markdown
## En cualquier bloque es posible poner 
   clases o identificador {.clase1 .centrado #id-encabezado}

Lorem ipsum dolor sit amet, consectetur adipiscing elit. 
Maecenas ac lacus viverra, scelerisque nisl non, pretium turpis. {.derecha}

> Lorem ipsum dolor sit amet, consectetur adipiscing elit.
> Maecenas ac lacus viverra, scelerisque nisl non, pretium turpis. {.versalita}
```

</div><div>

```html
<h2 id="id-encabezado" class="clase1 centrado">En cualquier bloque es posible poner    clases o identificador</h2>
<p class="derecha">Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas ac lacus viverra, scelerisque nisl non, pretium turpis.</p>
<blockquote class="versalita">
    <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas ac lacus viverra, scelerisque nisl non, pretium turpis.</p>
</blockquote>
```

</div></div><div>

## En cualquier bloque es posible poner 
   clases o identificador {.clase1 .centrado #id-encabezado}

Lorem ipsum dolor sit amet, consectetur adipiscing elit. 
Maecenas ac lacus viverra, scelerisque nisl non, pretium turpis. {.derecha}

> Lorem ipsum dolor sit amet, consectetur adipiscing elit.
> Maecenas ac lacus viverra, scelerisque nisl non, pretium turpis. {.versalita}

</div></div>

## Elementos en línea {.espacio-arriba3}

### Itálica

<div class="example"><div><div>

```markdown
_Itálica_
```

</div><div>

```html
<i>Itálica</i>
```

</div></div><div>

_Itálica_

</div></div>

### Negrita

<div class="example"><div><div>

```markdown
__Negrita__
```

</div><div>

```html
<b>Negrita</b>
```

</div></div><div>

__Negrita__

</div></div>

### Negrita e itálica

<div class="example"><div><div>

```markdown
___Negrita e itálica___
```

</div><div>

```html
<i><b>Negrita e itálica</b></i>
```

</div></div><div>

___Negrita e itálica___

</div></div>

### Itálica semántica

<div class="example"><div><div>

```markdown
*Itálica semántica*
```

</div><div>

```html
<em>Itálica semántica</em>
```

</div></div><div>

*Itálica semántica*

</div></div>

### Negrita semántica

<div class="example"><div><div>

```markdown
**Negrita semántica**
```

</div><div>

```html
<strong>Negrita semántica</strong>
```

</div></div><div>

**Negrita semántica**

</div></div>

### Negrita e itálica semántica

<div class="example"><div><div>

```markdown
***Negrita e itálica semántica***
```

</div><div>

```html
<em><strong>Negrita e itálica semántica</strong></em>
```

</div></div><div>

***Negrita e itálica semántica***

</div></div>

### Superíndice

<div class="example"><div><div>

```markdown
Un^superíndice^
```

</div><div>

```html
Un<sup>superíndice</sup>
```

</div></div><div>

Un^superíndice^

</div></div>

### Subíndice

<div class="example"><div><div>

```markdown
Un~subíndice~
```

</div><div>

```html
Un<sub>subíndice</sub>
```

</div></div><div>

Un~subíndice~

</div></div>

### Tachado

<div class="example"><div><div>

```markdown
~~Tachado~~
```

</div><div>

```html
<s>Tachado</s>
```

</div></div><div>

~~Tachado~~

</div></div>

### Versalita

<div class="example"><div><div>

```markdown
++Versalita solo las minúsculas++
```

</div><div>

```html
<span class="smallcap-light">Versalita solo las minúsculas</span>
```

</div></div><div>

++Versalita solo las minúsculas++

</div></div>

### Versalita forzada

<div class="example"><div><div>

```markdown
+++Versalita todo el texto+++
```

</div><div>

```html
<span class="smallcap">Versalita todo el texto</span>
```

</div></div><div>

+++Versalita todo el texto+++

</div></div>

### Código

<div class="example"><div><div>

```markdown
`Código en línea`
```

</div><div>

```html
<code>Código en línea</code>
```

</div></div><div>

`Código en línea`

</div></div>

### Imagen

<div class="example"><div><div>

```markdown
Imagen en línea: ![Como una fórmula](../img/img_inline.png), 
![Como una fórmula con clases o identificador](../img/img_inline.png){.clase1 .clase2 #id-imagen}.
```

</div><div>

```html
Imagen en línea: <img src="../img/img_inline.png" alt="Como una fórmula">, <img id="id-imagen" class="clase1 clase2" src="../img/img_inline.png" alt="Como una fórmula con clases o identificador">.
```

</div></div><div>

Imagen en línea: ![Como una fórmula](../img/img_inline.png), 
![Como una fórmula con clases o identificador](../img/img_inline.png){.clase1 .clase2 #id-imagen}.

</div></div>

### Enlace

<div class="example"><div><div>

```markdown
Enlace en línea: [un enlace](https://duckduckgo.com/), 
[otro enlace](https://duckduckgo.com/){.clase1 .clase2 #id-enlace} con clases o identificador.
```

</div><div>

```html
Enlace en línea: <a href="https://duckduckgo.com/">un enlace</a>, <a id="id-enlace" class="clase1 clase2" href="https://duckduckgo.com/">otro enlace</a> con clases o identificador.
```

</div></div><div>

Enlace en línea: [un enlace](https://duckduckgo.com/), 
[otro enlace](https://duckduckgo.com/){.clase1 .clase2 #id-enlace} con clases o identificador.

</div></div>

### Elemento &lt;span&gt;

> OJO: solo para +++HTML+++.

<div class="example"><div><div>

```markdown
[Contenido en span]{.clase1 .clase2 #id-span} con clases o identificador.
```

</div><div>

```html
<span id="id-span" class="clase1 clase2">Contenido en span</span> con clases o identificador.
```

</div></div><div>

[Contenido en span]{.clase1 .clase2 #id-span} con clases o identificador.

</div></div>

### Salto de línea

<div class="example"><div><div>

```markdown
Salto de \
línea
```

</div><div>

```html
Salto de <br> línea
```

</div></div><div>

Salto de \
línea

</div></div>

### Barra

<div class="example"><div><div>

```markdown
----Barra----
```

</div><div>

```html
―Barra―
```

</div></div><div>

----Barra----

</div></div>

### Raya

<div class="example"><div><div>

```markdown
---Raya---
```

</div><div>

```html
—Raya—
```

</div></div><div>

---Raya---

</div></div>

### Signo de menos

<div class="example"><div><div>

```markdown
--Signo de menos--
```

</div><div>

```html
–Signo de menos–
```

</div></div><div>

--Signo de menos--

</div></div>

### Espacio fino

<div class="example"><div><div>

```markdown
Espacio/,fino
```

</div><div>

```html
Espacio&amp;#8201;fino
```

</div></div><div>

Espacio/,fino

</div></div>

### Espacio de no separación

<div class="example"><div><div>

```markdown
Espacio de no/+separación
```

</div><div>

```html
Espacio de no&amp;#160;separación
```

</div></div><div>

Espacio de no/+separación

</div></div>

### Escape

<div class="example"><div><div>

```markdown
\*Si se escapa, evita interpretación de cualquier estilo en línea*.
```

</div><div>

```html
*Si se escapa, evita interpretación de cualquier estilo en línea*.
```

</div></div><div>

\*Si se escapa, evita interpretación de cualquier estilo en línea*.

</div></div>
