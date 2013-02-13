graph "processes" do
  %w(zombies wait blocked stopped running sleeping idle).each do |type|
    metric "processes_#{type}" do
      rrd %r{processes/ps_state-#{type}.rrd}
      ds "value"
      title "#{type.capitalize} processes"
    end
  end

  layout :area
  title "Processes"
  scope :entity
end
