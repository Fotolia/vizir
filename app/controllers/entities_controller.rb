class EntitiesController < ApplicationController
  def menu_metrics
    e = Entity.find(params[:id].to_i)
    if e
      @graphs = e.graphs.includes(:instances)
    end
    render :layout => false
  end
end
