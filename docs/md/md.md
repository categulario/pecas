# Pecas Markdown

Pecas Markdown se compone de dos tipos de elementos:

1. **Elementos en línea** que se insertan adentro de un bloque.
2. **Elementos en bloque** que se crean dejando una línea en blanco entre cada bloque.

## Elementos en línea

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

<div class="example"><div><div>

```markdown
Imagen en línea: ![Como una fórmula](../img/img_inline.png)
```

</div><div>

```html
Imagen en línea: <img src="../img/img_inline.png" alt="Como una fórmula"/>
```

</div></div><div>

Imagen en línea: ![Como una fórmula](../img/img_inline.png)

</div></div>

<div class="example"><div><div>

```markdown
Enlace en línea: [un enlace](https://duckduckgo.com/)
```

</div><div>

```html
Enlace en línea: <a href="https://duckduckgo.com/">un enlace</a>
```

</div></div><div>

Enlace en línea: [un enlace](https://duckduckgo.com/)

</div></div>

<div class="example"><div><div>

```markdown
[Algo en span]{.clase1 .clase2}
```

</div><div>

```html
<span class="clase1 clase2">Algo en span</span>
```

</div></div><div>

[Algo en span]{.clase1 .clase2}

</div></div>

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

## Elementos en bloque
