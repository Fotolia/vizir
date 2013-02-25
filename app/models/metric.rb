class Metric < ActiveRecord::Base
  extend StiHelpers

  attr_accessible :name, :type
  attr_accessor :title, :unit, :instance_details, :defined, :details

  validates :name,
    :uniqueness => true,
    :presence => true

  # TODO: use descendants/subclasses
  validates :type,
    :inclusion => {:in => ["CollectdMetric"]}

  has_many :instances, :inverse_of => :metric, :dependent => :destroy
  has_many :entities, :through => :instances

  after_initialize do |metric|
    metric.dsl_override
  end

  def data_type
    case unit
    when :value, :percent
      unit
    else
      :si
    end
  end

  protected

  def dsl_override
    self.defined = false
    if metric_defs = Vizir::DSL.metrics.select {|metric| metric[:type] == self.class.to_s}
      select_proc = nil
      matches = {}

      if self.new_record?
        unless self.class.attr_customs.nil?
          select_proc = lambda do |dsl|
            self.class.attr_customs.each do |field|
              if dsl[field].is_a? Regexp
                return false unless (dsl_match = dsl[field].match(self.send(field)))
                matches.merge!(dsl_match.to_hash(field.to_s)) if dsl_match
              else
                return false unless (dsl[field] == self.send(field))
                matches[field.to_s] = self.send(field)
              end
            end
            true
          end
        end
      else
        select_proc = lambda {|dsl| dsl[:name] == self.name}
      end

      metric_def = metric_defs.select {|m| select_proc.call(m)}
      unless metric_def.empty?
        self.assign_attributes(metric_def.first, :without_protection => true)
        self.defined = true
      end
      self.instance_details = matches
    end
  end
end
