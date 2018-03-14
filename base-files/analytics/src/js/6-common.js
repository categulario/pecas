timer = null

// Shows or hides the elements
function navigation () {
    elements = this.id[0] == 's' ? document.getElementsByClassName('sub-sec') : document.getElementsByTagName('section')
    nav_max = this.id[0] == 's' ? 4 : 3

    for (i = 0; i < elements.length; i++) {
        if (!elements[i].classList.contains('oculto')) {
            actual_s = elements[i]

            // Based on data-nav, it gets the next data-nav
            nav_num = this.id == 'right' || this.id == 'sub-right' ? ++i : --i
            nav_num = nav_num < 0 ? nav_max : nav_num
            nav_num = nav_num > nav_max ? 0 : nav_num

            next_s = elements[nav_num]

            // It hides the actual elements and it shows the next one
            actual_s.classList.add('oculto')
            next_s.classList.remove('oculto')

            if (this.id[0] == 's') {
                tables = document.getElementsByClassName('table-content')
                for (j = 0; j < tables.length ; j++)
                    tables[j].classList.add('oculto')
                tables[nav_num].classList.remove('oculto')
            }

            break
        }
    }
}

// Shows or hides elements in the structure's section
function accordion () {
    accordion_headers = document.getElementsByClassName('accordion')

    for (i = 0; i < accordion_headers.length; i++)
        // Adds a listener on each header
        accordion_headers[i].addEventListener('click', function () {
            accordion_contents = document.getElementsByClassName('accordion-content')

            // Shows or hides the content if both ids have the same integer
            for (j = 0; j < accordion_contents.length; j++) {
                if (this.id.replace('a','') == accordion_contents[j].id.replace('ac','')) {
                    if (accordion_contents[j].classList.contains('oculto'))
                        accordion_contents[j].classList.remove('oculto')
                    else
                        accordion_contents[j].classList.add('oculto')
                    break
                }
            }
        })
}

// Adds the general stats to the HTML
function general_stats () {
    gs = document.getElementsByClassName('general-stats')

    // Puts commas if necessary
    function format (num) {
        if (!isNaN(num) && num >= 999)
            num = num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")

        return num
    }

    // The id of the DOM element is related to the name of some global variables
    for (i = 0; i < gs.length; i++) {
        if (gs[i].id.split('-')[1] == null)
            gs[i].innerHTML = format(window[gs[i].id])
        else
            gs[i].innerHTML = format(window[gs[i].id.split('-')[0]][gs[i].id.split('-')[1]])
    }
}

// Generate the wordcloud; from:
//  https://www.jasondavies.com/wordcloud/
//  https://github.com/jasondavies/d3-cloud
//  https://stackoverflow.com/questions/27672989/dynamically-sized-word-cloud-using-d3-cloud
function wordcloud () {
    words = top50
    wordcloud_div = document.getElementById('wordcloud-div')
    canvas = document.getElementById('wordcloud-canvas')
    fillColor = d3.scale.category20b()
    w = parseInt(wordcloud_div.offsetWidth)
    h = parseInt((wordcloud_div.offsetWidth / 4) * 3) // Ratio 4:3
    scale = parseInt(wordcloud_div.offsetWidth / 100) >= 8 ? 2 : 10 - (wordcloud_div.offsetWidth / 100)
    min_rotate = rotation ? -60 : 0 // 90° to 150° (-60°)
    max_rotate = rotation ? 30 : 0  // 30° to 90°

    // Sets canvas size
    canvas.width = w
    canvas.height = h

    function draw (words) {
        d3.select(wordcloud_div).append('svg')
            .attr('width', w)
            .attr('height', h)
            .attr('id', 'wordcloud')
            .attr('viewbox', '0 0 ' + w + ' ' + h)
        .append('g')
        .attr('transform', 'translate(' + w/2 + ',' + h/2 + ')')
            .selectAll('text')
            .data(words)
            .enter().append('text')
            .style('font-size', function(d) {return d.size + 'px' })
            .style('font-family', 'Impact')
            .style('fill', function(d, i) { return fillColor(i); })
            .attr('text-anchor', 'middle')
            .attr('transform', function(d,i) {
                return 'translate(' + [d.x, d.y] + ')rotate(' + d.rotate + ')'
            }
        )
        .text(function(d) { return d.text })

        // Enables the saving of the wordcloud
        save_img('wordcloud')
    }

    d3.layout.cloud().size([w, h])
        .words(words)
        .spiral('archimedean')
        .padding(2)
        .rotate(function() { return Math.random() * (max_rotate - min_rotate) + min_rotate })     
        .font('Impact')
        .fontSize(function(d) { return d.size / scale })
        .on('end', draw)
        .start()
}

// Generate the pie chart; from:
//  http://www.chartjs.org/
//  http://www.chartjs.org/docs/latest/charts/doughnut.html
function piechart () {
    canvas = document.getElementById('piechart-canvas')
    ctx = canvas.getContext('2d')

    pie_data = {
        datasets: [
            {
                data: words_digits_unknown,
                backgroundColor: ['rgb(57, 59, 121)','rgb(99, 121, 57)','rgb(156, 158, 222)']
            },
        ],
        labels: piechart_labels
    }

    pie = new Chart(ctx ,{
        type: 'pie',
        data: pie_data,
    })

    // Enables the saving of the wordcloud
    save_img('piechart')
}

// Saves canvas or SVG in PNG format; from:
//  https://stackoverflow.com/questions/28226677/save-inline-svg-as-jpeg-png-svg
function save_img (id_prefix) {

    // Replaces the button in order to lose all the listeners
    btn_old = document.getElementById(id_prefix + '-btn')
    btn = btn_old.cloneNode(true)
    btn_old.parentNode.replaceChild(btn, btn_old)

    function triggerDownload (imgURI) {
        evt = new MouseEvent('click', {
            view: window,
            bubbles: false,
            cancelable: true
        })

        file_name = document.getElementsByTagName('title')[0].innerHTML
        .replace(/\s+/g, '_')
        .replace('.', '-')
        .toLowerCase() + '_' + id_prefix + '_' + '.png'

        a = document.createElement('a')
        a.setAttribute('download', file_name)
        a.setAttribute('href', imgURI)
        a.setAttribute('target', '_blank')
        a.dispatchEvent(evt)
    }

    btn.addEventListener('click', function () {
        id_prefix = this.id.split('-')[0]
        wordcloud_bool = id_prefix == 'wordcloud' ? true : false
        canvas = document.getElementById(id_prefix + '-canvas')
        DOMURL = window.URL || window.webkitURL || window
        img = new Image()

        // The wordcloud requieres to convert the SVG
        if (wordcloud_bool) {
            ctx = canvas.getContext('2d')
            data = (new XMLSerializer()).serializeToString(document.getElementById(id_prefix))
            blob = new Blob([data], {type: 'image/svg+xml;charset=utf-8'})
            url = DOMURL.createObjectURL(blob)
            img.src = url
        } else {
            // From: https://developer.mozilla.org/en-US/docs/Web/API/HTMLCanvasElement/toBlob
            canvas.toBlob(function(blob) { 
                url = URL.createObjectURL(blob)
                img.src = url
            })
        }

        img.onload = function () {
            ctx.drawImage(img, 0, 0)
            DOMURL.revokeObjectURL(url)
            imgURI = canvas
            .toDataURL('image/png')
            .replace('image/png', 'image/octet-stream')

            triggerDownload(imgURI)
        }
    })
}

// When the window is resized, actually it reloads
function resize () {
    window.location.reload(false)
}

// Functions works only .1 s after the end of resizement
window.onresize = function () {
    clearTimeout(timer)
    timer = setTimeout(resize, 50)
}

// Everything begins after document loads
window.onload = function () {

    // Creates the pie chart
    piechart()

    // Create the wordcloud
    wordcloud()

    // Adds the general stats
    general_stats()

    // Adds the posibility to sort tables
    sortable_table()

    // Enables the accordions
    accordion()

    // Add the navigation
    document.getElementById('left').addEventListener('click', navigation)
    document.getElementById('right').addEventListener('click', navigation)

    // Add the navigation for the first section
    document.getElementById('sub-left').addEventListener('click', navigation)
    document.getElementById('sub-right').addEventListener('click', navigation)

    
}
