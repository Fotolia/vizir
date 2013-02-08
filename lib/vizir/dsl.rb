module Vizir
  class DSL

    @@objects = {}
    @@types = {}

    [:metric, :graph].each do |what|
      Kernel.send :define_method, what do |name, &block|
        @@objects[name] = block
        @@types[name] = what
      end
    end

    Kernel.send :define_method, :each_object do |&block|
      @@objects.each do |name, object|
        block.call name, object
        @@objects.delete(name)
      end
    end

    class << self
      def parse_dsl
        definitions = {}
        Dir.glob("#{Vizir::Application.config.definitions_path}/**/*.rb").each do |file|
          type = "#{file.split("/")[-2]}_metric".camelcase
          load file
          each_object do |name, object|
            env = Vizir::HashBuilder.new
            env.instance_eval &object
            obj = env.build.merge({ :name => name })
            if @@types[name] == :metric
              definitions[@@types[name]] ||= {}
              definitions[@@types[name]][type] ||= []
              definitions[@@types[name]][type] << obj
            else
              definitions[@@types[name]] ||= []
              definitions[@@types[name]] << obj
            end
          end
        end
        definitions
      end

      def load_dsl
        Vizir::Application.config.dsl = parse_dsl
      end

      def data
        Vizir::Application.config.dsl
      end
    end
  end
end
