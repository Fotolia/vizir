class DashboardsController < ApplicationController
  def index
  end

  def create
    d = Dashboard.find_or_initialize_by_name(:name => params[:name])
    render :json => "OK"
  end

  def show
    @dashboard = Dashboard.includes(:graphs).find(params[:id].to_i)

    if request.xhr?
      render :layout => false
    end
  end
end
