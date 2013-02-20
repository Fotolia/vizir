@renderGraphs = (container) ->
  container.find('div[data-graph-id]').each (i) ->
    displayGraph($(this), $(this).data('graph-id'))

prettyNumber = (n) ->
  if n > 1000
     r = Rickshaw.Fixtures.Number.formatKMBT(Math.round(n))
     c = r.slice(-1)
     if c >= 'A' or c <= 'Z'
       r = parseFloat(r.slice(0, -1)).toFixed(2) + c
     return r
  else
    return n.toFixed(2)

displayGraph = (container, id) ->
  $.getJSON "/graphs/#{id}.json", (data) ->
    generateGraph(container, data)

generateGraph = (container, data) ->
  metrics = data.metrics

  #return if $("#graph_container_#{data.id}").length > 0

  container.append($('<h4>').append(" #{data.title}"))
    .append($('<div>').attr('id', "y_axis_#{data.id}").addClass('y_axis'))
    .append($('<div>').attr('id', "graph_#{data.id}").addClass('graph'))

  palette = new Rickshaw.Color.Palette(scheme: "colorwheel")
  for i of metrics
    metrics[i]["color"] = palette.color()

  graph = new Rickshaw.Graph(
    element: $("#graph_#{data.id}")[0]
    width: 700
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

  legendContainer = $('<div class="legend-container">')

  # The line to show the legend
  miniLegend = $('<div class="mini-legend"></div>')
  miniLegendIcon = $('<i class="icon-chevron-right pull-left">')
  miniLegend.prepend(miniLegendIcon)
  legendContainer.append(miniLegend)
  miniLegend.on 'click', ->
    $(this).hide()
    $(this).parent().children('table').show()

  # Build the legend
  legend = $('<table>').addClass('table table-condensed table-hover table-striped').hide()
  header = $('<thead>')
    .append('<th class="swatch"><i class="icon-chevron-down"></th>')
    .append('<th class="name">Metric</th>')
    .append('<th class="min">Minimum</th>')
    .append('<th class="max">Maximum</th>')
    .append('<th class="avg">Average</th>')
    .on 'click', ->
      t = $(this).parent('table')
      t.hide()
      t.siblings('.mini-legend').show()

  legend.append header
  body = $('<tbody>')
  for metric in metrics.slice().reverse()
    # Build the mini legend
    mini = $('<div>').addClass('item')
    miniSwatch = $('<span>').addClass('swatch').css('backgroundColor', metric.color)
    mini.append(miniSwatch)
    mini.append($('<span>').addClass('text').text(metric.name))
    miniLegend.append(mini)
    # Build the regular legend
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
  legendContainer.append(legend)
  container.append(legendContainer)

  for serie in graph.series
    line = legend.find('tr.line_'+serie.id)
    line.on('click', (e) ->
      # Dont allow to disable all series
      return if !$(this).hasClass('disabled') && graph.series.active().length == 1

      $(this).toggleClass('disabled')
      m_id = $(this).data('metric-id')
      for s in graph.series
        if s.id == m_id
          s.disabled = ! s.disabled
          unless s.disabled
            # Reorder the series
            newSeries = []
            series = body.children('tr').each (i,tr) ->
              newSeries.unshift $.grep(graph.series.active(), (s) -> s.id == $(tr).data('metric-id'))[0]

            for i,s in newSeries
              graph.series[i] = s

          graph.render()
          break
    )

  container.find('a.remove').on 'click', (e) ->
    graph_id = $(this).data('rem-id')
    removeGraphFromPage(graph_id)
    return false
