buildGraph = (data) ->
  metrics = data.metrics

  return if document.getElementById("graph_container_#{data.id}")

  graph_container = $("<div id=\"graph_container_#{data.id}\" class=\"graph_container\">
    <h4><a href=\"#\" class=\"remove\" data-rem-id=\"#{data.id}\"><i class=\"icon-remove-circle\"></i></a> #{data.title}</h4>
    <div id=\"y_axis_#{data.id}\" class=\"y_axis\"></div>
    <div id=\"graph_#{data.id}\" class=\"graph\"></div>
    <div id=\"legend_#{data.id}\" class=\"legend\"></div>
  </div>")
  $('#graphs').append graph_container

  palette = new Rickshaw.Color.Palette(scheme: "colorwheel")
  for i of metrics
    metrics[i]["color"] = palette.color()

  graph = new Rickshaw.Graph(
    element: document.getElementById("graph_#{data.id}")
    width: 600
    height: 150
    renderer: data["layout"]
    #stroke: true
    series: metrics
  )

  hoverDetail = new Rickshaw.Graph.HoverDetail(graph: graph)

  legend = new Rickshaw.Graph.Legend(
    graph: graph
    element: document.getElementById("legend_#{data.id}")
  )

  #shelving = new Rickshaw.Graph.Behavior.Series.Toggle(
  #  graph: graph
  #  legend: legend
  #)

  x_axis = new Rickshaw.Graph.Axis.Time(graph: graph)
  y_axis = new Rickshaw.Graph.Axis.Y(
    graph: graph
    orientation: "left"
    element: document.getElementById("y_axis_#{data.id}")
  )
  graph.render()

  $('a.remove').on 'click', (e) ->
    e.preventDefault()
    graph_id = $(this).attr('data-rem-id')
    i = graphs.indexOf(graph_id)
    graphs.splice(i,1)
    $("#graph_container_#{graph_id}").remove()
    updateLocation graphs

@fetchAndBuildGraphById = (id) ->
  $.getJSON "/?g=#{id}", (data) ->
    buildGraph data

fetchAndBuildGraphByUrl = (href) ->
  $.getJSON href, (data) ->
    buildGraph data

updateLocation = ->
  query = if graphs.length > 0 then "?g=#{graphs.join(",")}" else ""
  history.pushState null, document.title, "#{document.URL.split("?")[0]}#{query}"

@graphs = new Array()

$(document).ready ->
  $('a[data-graph-id]').on 'click', (e) ->
    graph_id = $(this).attr('data-graph-id')
    e.preventDefault()
    i = graphs.indexOf(graph_id)
    if i == -1
      graphs.push graph_id
      fetchAndBuildGraphById graph_id
    else
      graphs.splice(i,1)
      $("#graph_container_#{graph_id}").remove()
    updateLocation graphs

  $(window).bind "popstate", ->
    fetchAndBuildGraphByUrl location.href
