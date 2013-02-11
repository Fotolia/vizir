class AppController < ApplicationController
  def home
    # TODO right query to avoid duplicates
    @entities = Entity.includes(:graphs => :instances).order("entities.name")
  end

  def reload_dsl
    Vizir::DSL.load_dsl

    respond_to do |format|
      format.js { render :text => "OK" }
    end
  end

  def dsl
    respond_to do |format|
      format.html { render :text => JSON.pretty_generate(Vizir::DSL.data), :content_type => "text/plain" }
    end
  end
end
