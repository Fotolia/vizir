class EntitiesController < ApplicationController
  def graphs
    if e = Entity.find(params[:id].to_i)
      @graphs = e.graphs.includes(:instances).sort_by { |g| g.title }
    end
    render :layout => false
  end

  def dashboards
    if e = Entity.find(params[:id].to_i)
      @dashboards = e.dashboards.sort_by { |d| d.title }
    end
    render :layout => false
  end
end
