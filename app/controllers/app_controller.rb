class AppController < ApplicationController
  def home
    @gs = Graph.w_entity

    @metrics = []

    if params[:g]
      g = Graph.find(params[:g])
      @metrics = g.fetch_values(Time.now.to_i - 3600, Time.now.to_i)
    end

    respond_to do |format|
      format.html
      format.js { render :json => @metrics.to_json }
      format.json { render :json => @metrics.to_json }
    end
  end
end
