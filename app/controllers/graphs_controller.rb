class GraphsController < ApplicationController
  def show
    g = Graph.find(params[:id].to_i)
    @metrics = g.fetch_values(Time.now.to_i - 3600, Time.now.to_i)

    render :json => @metrics
  end
end
