dashboard "system" do
  graph "cpu" do
    %w(system interrupt softirq wait steal user nice idle).each do |type|
      metric "cpu_#{type}" do
        rrd %r{cpu-(?<cpu_id>\d+)/cpu-#{type}.rrd}
        ds "value"
        title "CPU $cpu_id #{type.capitalize}"
      end
    end

    layout :area
    title "CPU $cpu_id"
    scope "cpu_id"
  end
end
