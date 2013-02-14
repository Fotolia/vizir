prettyNumber = (n) ->
  if n > 1000
     r = Rickshaw.Fixtures.Number.formatKMBT(Math.round(n))
     c = r.slice(-1)
     if c >= 'A' or c <= 'Z'
       r = parseFloat(r.slice(0, -1)).toFixed(2) + c
     return r
  else
    return n.toFixed(2)

buildGraph = (data) ->
  metrics = data.metrics

  return if $("#graph_container_#{data.id}").length > 0

  graph_container = $("<div id=\"graph_container_#{data.id}\" class=\"graph_container\">
    <h4><a href=\"#\" class=\"remove\" data-rem-id=\"#{data.id}\"><i class=\"icon-remove-circle\"></i></a> #{data.title}</h4>
    <div id=\"y_axis_#{data.id}\" class=\"y_axis\"></div>
    <div id=\"graph_#{data.id}\" class=\"graph\"></div>
    </div>
</div>")
  $('#graphs').append graph_container

  palette = new Rickshaw.Color.Palette(scheme: "colorwheel")
  for i of metrics
    metrics[i]["color"] = palette.color()

  graph = new Rickshaw.Graph(
    element: $("#graph_#{data.id}")[0]
    width: 600
    height: 150
    renderer: data["layout"]
    #stroke: true
    series: metrics
  )

  hoverDetail = new Rickshaw.Graph.HoverDetail(graph: graph)

  x_axis = new Rickshaw.Graph.Axis.Time(graph: graph)
  y_axis = new Rickshaw.Graph.Axis.Y(
    graph: graph
    orientation: "left",
    tickFormat: Rickshaw.Fixtures.Number.formatKMBT
    element: $("#y_axis_#{data.id}")[0]
  )
  graph.render()

  # Build the legend
  legend = $('<table>').addClass('legend table table-condensed table-hover table-striped')
  header = $('<thead>')
    .append('<th class="swatch"></th>')
    .append('<th class="name">Metric</th>')
    .append('<th class="min">Minimum</th>')
    .append('<th class="max">Maximum</th>')
    .append('<th class="avg">Average</th>')
  legend.append header
  body = $('<tbody>')
  for metric in metrics.reverse()
    row = $('<tr>').addClass('line_' + metric.id).data('metric-id', metric.id)
    swatch = $('<div>')
    swatch.css('backgroundColor', metric.color)
    swatch_cell = $('<td>').addClass('swatch').append(swatch)
    name_cell = $('<td>').addClass('name').text(metric.name)

    # Calculate our values for the serie
    min = max = metric.data[0].y
    sum = 0
    for data in metric.data
      val = data.y
      max = val if val > max
      min = val if val < min
      sum += val
    avg = sum / metric.data.length

    min = prettyNumber(min)
    max = prettyNumber(max)
    avg = prettyNumber(avg)

    min_cell = $('<td>').addClass('min').text(min)
    max_cell = $('<td>').addClass('max').text(max)
    avg_cell = $('<td>').addClass('avg').text(avg)
    row
      .append(swatch_cell)
      .append(name_cell)
      .append(min_cell)
      .append(max_cell)
      .append(avg_cell)
    body.append(row)

  legend.append(body)
  graph_container.append(legend)

  for serie in graph.series
    line = legend.find('tr.line_'+serie.id)
    s = serie
    line.on('click', (e) ->
      $(this).toggleClass('disabled')
      m_id = $(this).data('metric-id')
      for s in graph.series
        if s.id == m_id
          s.disabled = ! s.disabled
          graph.render()
          break
    )

  graph_container.find('a.remove').on 'click', (e) ->
    graph_id = $(this).data('rem-id')
    removeGraphFromPage(graph_id)
    return false

@fetchAndBuildGraphById = (id) ->
  $.getJSON "/graphs/#{id}.json", (data) ->
    buildGraph data

updateLocation = (graphs) ->
  hash = if graphs.length > 0 then "#" + graphs.join(",") else ""
  history.replaceState null, document.title, document.URL.split('#')[0] + hash

addGraphToPage = (id) ->
  graphs.push(id)
  fetchAndBuildGraphById(id)
  updateLocation graphs

removeGraphFromPage = (id) ->
  i = graphs.indexOf(id)
  graphs.splice(i,1)
  $("#graph_container_#{id}").remove()
  updateLocation graphs

loadGraphsFromHash = ->
  # If we have graphs from the URL, add them
  return unless window.location.hash
  ids = window.location.hash.substr(1).split(',')
  for i, id of ids
    return unless $.isNumeric(id)
    addGraphToPage(id)

@graphs = new Array()

$ ->
  $('a[data-graph-id]').on 'click', (e) ->
    graph_id = $(this).attr('data-graph-id')
    i = graphs.indexOf(graph_id)
    if i == -1
      addGraphToPage(graph_id)
    else
      removeGraphFromPage(graph_id)
    return false

  loadGraphsFromHash()
