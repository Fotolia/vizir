module Vizir
  class DSL
    attr_accessor :objects, :type
    attr_reader :parent

    @@members = [:metric, :graph, :dashboard]
    @@collections = [:metrics, :graphs]

    def initialize(parent = nil)
      @objects = Hash.new
      @parent = parent
      @root = root
    end

    @@members.each do |method|
      define_method method do |*args, &block|
        if block
          # create a "sub-"context to evaluate nested directives
          context = DSL.new(self)
          context.instance_eval &block
          # create object definition in the root hash
          object = Hash.new
          object[:name] = args.first
          object[:type] = @root.type if method == :metric
          @root.objects[method] ||= Array.new
          @root.objects[method] << object.merge(context.objects)
          # create a reference on the former in the local hash
          send(method, args.first) unless root?
        else
          send("#{method}s", *args)
        end
      end
    end

    @@collections.each do |method|
      define_method method do |*args, &block|
        @objects[method] ||= Hash.new
        if args.count == 1
          args.flatten.each{|a| @objects[method][a] = nil}
        else
          @objects[method][args.shift] = args.shift
        end
      end
    end

    def method_missing(method, *args, &block)
      @objects[method] = args.count > 1 ? args : args.first
    end

    def semantic_check
      @@members.each do |member|
        # Check for duplicate names
        objects[member].group_by {|obj| obj[:name]}.each do |name,occurences|
          if occurences.count > 1
            puts "#{name} #{member} has multiple definitions, Attempting deep merge"
            new = occurences.first
            occurences.each {|o| new.deep_merge!(o); objects[member].delete(o)}
            objects[member] << new
          end
        end
        # Check for missing or unwanted keys
      end
    end

    def root
      _parent = self
      loop do
        break if _parent.parent.nil?
        _parent = _parent.parent
      end
      _parent
    end

    def root?
      @root == self
    end

    class << self
      def parse(defs_path)
        dsl = new
        Dir.glob(File.join(File.expand_path(defs_path), "**/*.rb")) do |file|
          folder = File.basename(File.dirname(file))
          dsl.type = "#{folder}_metric".camelcase
          dsl.instance_eval(File.read(file))
        end
        dsl.semantic_check
        dsl
      end

      def load_dsl
        Vizir::Application.config.dsl = parse(Vizir::Application.config.definitions_path).objects
      end

      def data
        begin
          Vizir::Application.config.dsl
        rescue
          load_dsl
        end
      end

      @@members.each do |method|
        define_method "#{method}s" do |*args|
          data[method] if data
        end
      end
    end
  end
end
