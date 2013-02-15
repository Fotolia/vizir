class GraphsController < ApplicationController
  def show
    now = Time.now.to_i

    # TODO add control on min/max duration

    w_start, w_end =
    if params[:d]
      if params[:e]
        [params[:e].to_i - params[:d].to_i, params[:e].to_i]
      elsif params[:s]
        [params[:s].to_i, params[:s].to_i + params[:d].to_i]
      else
        [now - params[:d].to_i, now]
      end
    else
      if params[:s] and params[:e] and params[:e] > params[:s]
        [params[:s].to_i, params[:e].to_i]
      else
        [now - 3600, now]
      end
    end

    g = Graph.find(params[:id].to_i)
    @graph = g.fetch_values(w_start, w_end)

    respond_to do |format|
      format.json { render :json => @graph }
      format.html { render "show", :layout => "minimal" }
    end
  end
end
