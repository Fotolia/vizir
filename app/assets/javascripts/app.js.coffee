buildGraph = (data) ->
  graph_data = data
  metrics = graph_data["metrics"]

  $('#chart_container').remove()
  chart_container = $('<div id="chart_container"><div id="y_axis"></div><div id="chart"></div><div id="legend"></div></div>')
  $('#charts').append chart_container

  palette = new Rickshaw.Color.Palette(scheme: "colorwheel")
  for i of metrics
    metrics[i]["color"] = palette.color()

  graph = new Rickshaw.Graph(
    element: document.getElementById("chart")
    width: 1000
    height: 300
    renderer: graph_data["layout"]
    #stroke: true
    series: metrics
  )

  hoverDetail = new Rickshaw.Graph.HoverDetail(graph: graph)

  legend = new Rickshaw.Graph.Legend(
    graph: graph
    element: document.getElementById("legend")
  )

  #shelving = new Rickshaw.Graph.Behavior.Series.Toggle(
  #  graph: graph
  #  legend: legend
  #)

  x_axis = new Rickshaw.Graph.Axis.Time(graph: graph)
  y_axis = new Rickshaw.Graph.Axis.Y(
    graph: graph
    orientation: "left"
    element: document.getElementById("y_axis")
  )
  graph.render()


$(document).ready ->
  $('a[data-remote="true"]').on 'ajax:complete', (e, data) ->
    jsonData = $.parseJSON data.responseText
    buildGraph jsonData
