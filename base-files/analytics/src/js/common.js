timer = null

// Show or hide the sections
function navigation () {
    sections = document.getElementsByTagName('section')

    for (i = 0; i < sections.length; i++) {
        if (!sections[i].classList.contains('oculto')) {
            actual_s = document.getElementById(sections[i].id)

            // Based on data-nav, it gets the next data-nav
            nav_num = parseInt(actual_s.dataset.nav)
            nav_num = this.id == 'right' ? ++nav_num : --nav_num
            nav_num = nav_num < 0 ? 3 : nav_num
            nav_num = nav_num > 3 ? 0 : nav_num

            next_s = document.getElementById(sections[nav_num].id)

            // It hides the actual section and it shows the next one
            actual_s.classList.add('oculto')
            next_s.classList.remove('oculto')

            break
        }
    }
}

// Generate the wordcloud; from:
//   https://stackoverflow.com/questions/27672989/dynamically-sized-word-cloud-using-d3-cloud
//   https://www.jasondavies.com/wordcloud/
function wordcloud () {

    // Top 50 words
    words = [{"text": "edición", "size": 240},{"text": "epub", "size": 219},{"text": "obra", "size": 122},{"text": "libro", "size": 114},{"text": "formato", "size": 110},{"text": "publicación", "size": 108},{"text": "software", "size": 105},{"text": "archivo", "size": 105},{"text": "digital", "size": 101},{"text": "autor", "size": 99},{"text": "editorial", "size": 97},{"text": "archivos", "size": 97},{"text": "adobe", "size": 84},{"text": "formatos", "size": 83},{"text": "tiempo", "size": 81},{"text": "trabajo", "size": 77},{"text": "indesign", "size": 75},{"text": "desarrollo", "size": 73},{"text": "producción", "size": 68},{"text": "creación", "size": 67},{"text": "libre", "size": 66},{"text": "texto", "size": 59},{"text": "estilos", "size": 58},{"text": "proyecto", "size": 57},{"text": "posible", "size": 56},{"text": "estructura", "size": 56},{"text": "control", "size": 54},{"text": "contenidos", "size": 54},{"text": "contenido", "size": 54},{"text": "libros", "size": 52},{"text": "crear", "size": 50},{"text": "ejemplo", "size": 49},{"text": "xml", "size": 48},{"text": "sigil", "size": 47},{"text": "otros", "size": 45},{"text": "obras", "size": 45},{"text": "necesario", "size": 44},{"text": "mariana", "size": 44},{"text": "derecho", "size": 44},{"text": "caso", "size": 44},{"text": "calidad", "size": 44},{"text": "pdf", "size": 43},{"text": "todo", "size": 42},{"text": "tener", "size": 42},{"text": "original", "size": 42},{"text": "necesidad", "size": 42},{"text": "método", "size": 42},{"text": "párrafo", "size": 41},{"text": "existe", "size": 41},{"text": "momento", "size": 40}]
    wordcloud_div = document.getElementById('wordcloud-div')
    fillColor = d3.scale.category20b();
    w = wordcloud_div.offsetWidth
    h = (wordcloud_div.offsetWidth / 4) * 3 // Ratio 4:3
    scale = parseInt(wordcloud_div.offsetWidth / 100) >= 8 ? 1.5 : 9 - (wordcloud_div.offsetWidth / 100)
    min_rotate = -60
    max_rotate = 60

    function draw (words) {
        d3.select(wordcloud_div).append('svg')
            .attr('width', w)
            .attr('height', h)
            .attr('id', 'wordcloud')
        .append('g')
        .attr('transform', 'translate(' + w/2 + ',' + h/2 + ')')
            .selectAll('text')
            .data(words)
            .enter().append('text')
            .style('font-size', function(d) { return (d.size) + 'px'; })
            .style('font-family', 'Impact')
            .style('fill', function(d, i) { return fillColor(i); })
            .attr('text-anchor', 'middle')
            .attr('transform', function(d,i) {
                return 'translate(' + [d.x, d.y] + ')rotate(' + d.rotate + ')';
            }
        )
        .text(function(d) { return d.text; });

        // Enables the saving of the wordcloud
        save_img(document.getElementById('wordcloud'))
    }

    d3.layout.cloud().size([w, h])
        .words(words)
        .spiral('archimedean')
        .padding(2)
        .rotate(function() { return Math.random() * (max_rotate - min_rotate) + min_rotate; })     
        .font('Impact')
        .fontSize(function(d) { return d.size / scale; })
        .on('end', draw)
        .start();
}

// Saves SVG in PNG format; from:
//   https://stackoverflow.com/questions/28226677/save-inline-svg-as-jpeg-png-svg
function save_img (svg) {
    wordcloud_div = document.getElementById('wordcloud-div')
    canvas = document.getElementById('wordcloud-canvas')

    // Replaces the button in order to lose all the listeners
    btn_old = document.getElementById('wordcloud-btn')
    btn = btn_old.cloneNode(true)
    btn_old.parentNode.replaceChild(btn, btn_old)

    // Sets canvas size
    w = wordcloud_div.offsetWidth
    h = (wordcloud_div.offsetWidth / 4) * 3 // Ratio 4:3
    canvas.width = w
    canvas.height = h

    function triggerDownload (imgURI) {
        evt = new MouseEvent('click', {
            view: window,
            bubbles: false,
            cancelable: true
        })

        file_name = document.getElementsByTagName('title')[0].innerHTML
        .replace(/\s+/, '_')
        .replace('.', '-')
        .toLowerCase() + '.png'

        a = document.createElement('a')
        a.setAttribute('download', file_name)
        a.setAttribute('href', imgURI)
        a.setAttribute('target', '_blank')
        a.dispatchEvent(evt)
    }

    btn.addEventListener('click', function () {
        ctx = canvas.getContext('2d')
        data = (new XMLSerializer()).serializeToString(svg)
        DOMURL = window.URL || window.webkitURL || window
        img = new Image()
        svgBlob = new Blob([data], {type: 'image/svg+xml;charset=utf-8'})
        url = DOMURL.createObjectURL(svgBlob)

        img.onload = function () {
            ctx.drawImage(img, 0, 0);
            DOMURL.revokeObjectURL(url);
            imgURI = canvas
            .toDataURL('image/png')
            .replace('image/png', 'image/octet-stream');

            triggerDownload(imgURI);
        };

        img.src = url;
    })
}

// When the window is resized
function resize () {
    // Delete the worcloud's SVG ana create it again
    document.getElementById('wordcloud').parentElement.removeChild(document.getElementById('wordcloud'))
    wordcloud()
}

window.onresize = function () {
    clearTimeout(timer)
    timer = setTimeout(resize, 100)
}

// Everything begins after document loads
window.onload = function () {

    // Create the wordcloud
    wordcloud()

    // Add the navigation
    document.getElementById('left').addEventListener('click', navigation)
    document.getElementById('right').addEventListener('click', navigation)

};
