buildGraph = (data) ->
  seriesdata = data

  $('#chart_container').remove()
  chart_container = $('<div id="chart_container"><div id="y_axis"></div><div id="chart"></div><div id="legend"></div></div>')
  $('#charts').append chart_container

  palette = new Rickshaw.Color.Palette(scheme: "colorwheel")
  for i of seriesdata
    seriesdata[i]["color"] = palette.color()

  graph = new Rickshaw.Graph(
    element: document.getElementById("chart")
    width: 1000
    height: 300
    renderer: "line"
    #stroke: true
    series: seriesdata
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

  $('a[data-remote="true"]').live 'ajax:success',
    (e, data, textStatus, jqXHR) ->
      jsonData = $.parseJSON data
      buildGraph jsonData

  #$.getJSON "http://localhost:3000/", (data) ->
  #  buildGraph data
