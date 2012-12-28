class AppController < ApplicationController
  def home
    #@entities = Entity.includes(:entity_metrics)
    #graphs = {}
    #@entities.each do |e|
    #  graphs[e.id] = e.entity_metrics.map {|em| em.id}
    #end
    #enti = 1
    #if params[:e]
    #  enti = params[:e].to_i
    #end

    @is = Instance.w_assocs

    @metrics = []

    if params[:i]
      i = Instance.w_assocs.find(params[:i])
      @metrics << i.fetch_values(Time.now.to_i - 3600, Time.now.to_i)
    end

    respond_to do |format|
      format.html
      format.js { render :json => @metrics  }
      format.json { render :json => @metrics  }
    end
  end
end
