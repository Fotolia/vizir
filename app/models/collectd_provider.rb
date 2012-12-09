require 'rrd'

class CollectdProvider < Provider
  attr_custom :rrd_path, :collectd_sock, :rrdcached_sock

  def get_entities
    Dir.glob("#{rrd_path}/*").map {|e| e.split('/').last }.sort.uniq
  end

  def get_metrics
    list = []
    file_list.each do |filename|
      rrd = filename[/#{rrd_path}\/.*?\/(.*)/, 1]
      dss = get_ds_list(filename)
      dss.each do |ds|
        # TODO Match with definitions list
        list << { "rrd" => rrd, "ds" => ds }
      end
    end
    list
  end

  def get_values(options = {})
    rrd_rel_path = "#{options["entity"]}/#{options["rrd"]}"
    rrd_abs_path = "#{rrd_path}/#{rrd_rel_path}"
    start  = options["start"]
    finish = options["end"]

    flush(rrd_rel_path, collectd_sock) if collectd_sock
    flush(rrd_abs_path, rrdcached_sock) if rrdcached_sock

    rrd = RRD::Base.new(rrd_abs_path)
    rrd_data = rrd.fetch(:average, :start => start, :end => finish)

    # first entry describes format
    ds_index = rrd_data.shift.index(options["ds"])

    data = []

    last_valid = 0
    rrd_data.each do |tuple|
      value = tuple[ds_index]
      if value.nan?
        value = last_valid
      else
        last_valid = value
      end
      data << { "x" => tuple[0], "y" => value }
    end

    data
  end

  private

  def get_ds_list(rrd_file)
    rrd = RRD::Base.new(rrd_file)
    rrd.info.keys.select {|v| v =~ /^ds/ }.map {|v| v[/^ds\[(\S+)\]\..*$/, 1] }.uniq
  end

  def flush(path, socket)
    socket = UNIXSocket.new(socket)
    socket.puts "FLUSH \"#{path}\""
    socket.gets
    socket.close
  end

  def file_list
    @cached_file_list ||= Dir.glob("#{rrd_path}/**/*.rrd")
  end
end
