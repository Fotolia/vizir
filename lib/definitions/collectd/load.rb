dashboard "system" do
  graph "load" do
    { :shortterm => 1, :midterm => 5, :longterm => 15 }.each do |term,time|
      metric "load_#{time.to_s}" do
        rrd "load/load.rrd"
        ds term.to_s
        title "Load average #{time.to_s}min"
      end
    end

    layout :line
    title "Load average"
    scope :entity
  end
end
