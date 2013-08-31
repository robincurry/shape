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
  #
  #     link :facilities
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
      shaper_context.send(:define_method, name, &block)
    end

    protected

    def define_accessor(name, source_name)
      if !shaper_context.method_defined?(name.to_sym)
        self.from do
          _source.send(source_name)
        end
      end
    end

  end
end
