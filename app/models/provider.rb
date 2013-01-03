class Provider < ActiveRecord::Base
  extend StiHelpers

  attr_accessible :name, :type, :details

  serialize :details, JSON

  validates :name,
    :uniqueness => true,
    :presence => true
  validates :type,
    :presence => true

  has_many :instances

  def load_entities
    unless @entities.nil?
      existing_entities = Entity.all.map {|e| e.name}
      @entities.each do |e|
        unless existing_entities.include?(e)
          Entity.new(:name => e).save
        end
        existing_entities.delete(e)
      end
      unless existing_entities.empty?
        existing_entities.each {|e| Entity.find_by_name(e).destroy}
      end
    end
  end

  def load_metrics
    raise "Method not implemented"
  end

  def get_values(options = {})
    raise "Method not implemented"
  end
end
