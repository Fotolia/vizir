class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :init_sidebar

  def init_sidebar
    if !request.xhr?
      @entities = Entity.order(:name)
    end
  end
end
