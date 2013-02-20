$ ->
  renderGraphs($('div#content'))
  $('.graphs-list > li.entity > a').on 'click', (e) ->
    link = $(this)
    entity = link.parent('li.entity')
    icon = link.children('i')

    # Loading entity dashboards
    dashboards = link.siblings('ul.dashboards')
    if dashboards.length == 0
      # Fetch the metrics for this entity
      icon.attr('class', 'icon-refresh icon-spin')
      $.get("/entities/#{entity.data('entity-id')}/dashboards", (data) ->
        n = entity.append(data)
        n.find('a[data-dashboard-id]').each (i,e) ->
          # Show/Hide graph on click
          $(e).on('click', ->
            dashboard_id = $(this).data('dashboard-id').toString()
            $.get("/dashboards/#{dashboard_id}", (data) ->
              n = $('#content').html(data)
              history.replaceState null, document.title, "/dashboards/#{dashboard_id}"
              renderGraphs(n)
              $('li.dashboard').removeClass('active')
              $(e).parent('li').addClass('active')
            )
            return false
          )

        # Call click again, to display it
        link.click()
      )
    else
      if dashboards.is(':hidden')
        icon.attr('class', 'icon-chevron-down')
        dashboards.show()
      else
        dashboards.hide()
        icon.attr('class', 'icon-chevron-right')

## to be factorized and used later
#    metrics = link.siblings('ul')
#    if metrics.length == 0
#      # Fetch the metrics for this entity
#      icon.attr('class', 'icon-refresh icon-spin')
#      $.get("/entities/#{entity.data('entity-id')}/graphs", (data) ->
#        n = entity.append(data)
#        n.find('a[data-graph-id]').each (i,e) ->
#          # Show/Hide graph on click
#          $(e).on('click', ->
#            graph_id = $(this).data('graph-id').toString()
#            $.get("/graphs/#{graph_id}", (data) ->
#              n = $('#content').html(data)
#              history.replaceState null, document.title, "/graphs/#{graph_id}"
#              renderGraphs(n)
#            )
#            return false
#          )
#        # Call click again, to display it
#        link.click()
#      )
#    else
#      if metrics.is(':hidden')
#        icon.attr('class', 'icon-chevron-down')
#        metrics.show()
#      else
#        metrics.hide()
#        icon.attr('class', 'icon-chevron-right')
