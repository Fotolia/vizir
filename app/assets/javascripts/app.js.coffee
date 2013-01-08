buildGraph = (data) ->
  graph_data = data
  metrics = graph_data["metrics"]

  $('#graph_container').remove()
  graph_container = $('<div id="graph_container"><div id="y_axis"></div><div id="graph"></div><div id="legend"></div></div>')
  $('#graphs').append graph_container

  palette = new Rickshaw.Color.Palette(scheme: "colorwheel")
  for i of metrics
    metrics[i]["color"] = palette.color()

  graph = new Rickshaw.Graph(
    element: document.getElementById("graph")
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

  $('a[data-graph-id]').on 'ajax:complete', (e, data) ->
    jsonData = $.parseJSON data.responseText
    buildGraph jsonData

#  if history and history.pushState
#    $ ->
#      $('a:[data-remote]:not([class~="no_history"]), .pagination a').live "click", (e) ->
#        $.getScript @href
#        history.pushState null, document.title, @href
#        e.preventDefault()
#      $(window).bind "popstate", ->
#        $.getScript location.href
