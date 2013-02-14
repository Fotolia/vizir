buildGraph = (data) ->
  metrics = data.metrics

  return if $("#graph_container_#{data.id}").length > 0

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
    element: $("#graph_#{data.id}")[0]
    width: 600
    height: 150
    renderer: data["layout"]
    #stroke: true
    series: metrics
  )

  hoverDetail = new Rickshaw.Graph.HoverDetail(graph: graph)

  legend = new Rickshaw.Graph.Legend(
    graph: graph
    element: $("#legend_#{data.id}")[0]
  )

  #shelving = new Rickshaw.Graph.Behavior.Series.Toggle(
  #  graph: graph
  #  legend: legend
  #)

  x_axis = new Rickshaw.Graph.Axis.Time(graph: graph)
  y_axis = new Rickshaw.Graph.Axis.Y(
    graph: graph
    orientation: "left"
    element: $("#y_axis_#{data.id}")[0]
  )
  graph.render()

  menuItemForGraph(data.id).addClass('active')

  graph_container.find('a.remove').on 'click', (e) ->
    graph_id = $(this).data('rem-id')
    removeGraphFromPage(graph_id)
    return false


menuItemForGraph = (id) ->
  $(".graphs-list").find("li > a[data-graph-id=#{id}]").parent('li')

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
  menuItemForGraph(id).removeClass('active')
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
  # Enable links in the graphs tree
  # Entities
  $('.graphs-list > li.entity > a').on 'click', (e) ->
    link = $(this)
    entity = link.parent('li.entity')
    metrics = link.siblings('ul')
    icon = link.children('i')
    if metrics.length == 0
      # Fetch the metrics for this entity
      icon.attr('class', 'icon-refresh icon-spin')
      $.get("/entities/#{entity.data('entity-id')}/menu_metrics", (data) ->
        n = entity.append(data)
        n.find('a[data-graph-id]').each (i,e) ->
          # Show/Hide graph on click
          $(e).on('click', ->
            graph_id = $(this).data('graph-id').toString()
            if graphs.indexOf(graph_id) == -1
              addGraphToPage(graph_id)
            else
              removeGraphFromPage(graph_id)
            return false
          )

          # Mark as active if the graph is open
          if graphs.indexOf($(e).data('graph-id').toString()) != -1
            $(e).parent('li').addClass('active')

        # Call click again, to display it
        link.click()
      )
    else
      if metrics.is(':hidden')
        icon.attr('class', 'icon-chevron-down')
        metrics.show()
      else
        metrics.hide()
        icon.attr('class', 'icon-chevron-right')

  # Load the graphs from URL
  loadGraphsFromHash()
