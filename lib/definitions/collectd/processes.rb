process_states = %w(zombies wait blocked stopped running sleeping idle)

process_states.each do |type|
  metric "processes_#{type}" do
    rrd %r{processes/ps_state-#{type}.rrd}
    ds "value"
    title "#{type.capitalize} processes"
  end
end

graph "processes" do
  metrics process_states.map {|m| "processes_#{m}"}
  layout :area
  title "Processes"
  scope :entity
end
