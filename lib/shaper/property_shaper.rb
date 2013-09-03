module Shaper
  # = Property Shaper
  # Keeps track of property info and context
  # when shaping shaper views.
  #
  # We'll use the PropertyShaper objects
  # later to recursively build the data.
  #
  # Allows anything inside a property block
  # to call methods in the context of the
  # Shaper dsl allowing for nested properties.
  #
  # Example:
  #
  #   property :address do
  #     property :street_address do
  #       property :addr_line1
  #       property :addr_line2
  #     end
  #     property :city
  #     # ...
  #   end
  class PropertyShaper
    include Shaper::Base::ClassMethods

    attr_accessor :name
    attr_accessor :shaper_context
    attr_accessor :options

    def initialize(shaper_context, name, options={}, &block)
      self.shaper_context = shaper_context
      self.name = name
      self.options = options

      if block
        instance_eval(&block)
      else
        from = options[:from] || name
        define_accessor(name, from)
        delegate_property(from)
      end
    end

    def from(&block)
      unless shaper_context.method_defined?(name.to_sym)
        shaper_context.send(:define_method, name, &block)
      end
    end

    protected

    def define_accessor(name, source_name)
      if !shaper_context.method_defined?(name.to_sym)
        _options = self.options
        self.from do
          return nil unless _source
          result = begin
            _source.send(source_name)
            rescue NoMethodError
              # If source doesn't have a corresponding method, try accessing it
              # via element accessor.
              if _source.respond_to?(:[])
                _source.send(:[], source_name)
              else
                raise
              end
          end
          if with = _options[:with]
            if result.respond_to?(:join)
              with.shape_collection(result, parent: self)
            else
              with.shape(result, parent: self)
            end
          else
            result
          end
        end
      end
    end

  end
end
