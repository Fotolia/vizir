require 'rrd'

class CollectdProvider < Provider

  def get_entities
    Dir.glob("#{details["rrd_path"]}/*").map {|e| e.split('/').last }.sort.uniq
  end

  def get_metrics
    list = []
    file_list.each do |filename|
      metric = filename[/#{details["rrd_path"]}\/.*?\/(.*)\.rrd/, 1].split("/")
      rrd = RRD::Base.new(filename)
      dss = rrd.info.keys.select {|v| v =~ /^ds/ }.map {|v| v[/^ds\[(\S+)\]\..*$/, 1] }.uniq
      dss.each do |ds|
        # TODO Match with definitions list
        list << metric.dup.push(ds).join(":")
      end
    end
    list
  end

  def get_data(options = {})
    entity = options["entity"]
    rrd_file = options["rrd"]
    ds = options["ds"]
    start  = options["start"]  || Time.now.to_i - 3600
    finish = options["end"] || Time.now.to_i

    flush("#{entity}/#{rrd_file}", @collectdsock) if @collectdsock
    flush("#{details["rrd_path"]}/#{entity}/#{rrd_file}", @rrdcachedsock) if @rrdcachedsock

    rrd = RRD::Base.new("#{details["rrd_path"]}/#{entity}/#{rrd_file}")

    rrd_data = rrd.fetch(:average, :start => start, :end => finish)

    # first entry describes format
    struct = rrd_data.shift
    ds_index = struct.index(ds)

    data = {
      "start"  => start,
      "end"    => finish,
      "values" => []
    }

    last_valid = 0
    rrd_data.each do |tuple|
      value = tuple[ds_index]
      if value.nan?
        value = last_valid
      else
        last_valid = value
      end
      data["values"] << { "x" => tuple[0], "y" => value }
    end

    p data
  end

  def flush(path, socket)
    socket = UNIXSocket.new(socket)
    socket.puts "FLUSH \"#{path}\""
    socket.gets
    socket.close
  end

  def file_list
    @cached_file_list ||= Dir.glob("#{details["rrd_path"]}/**/*.rrd")
  end
end
