module Shaper
  # = Property Decorator
  # Keeps track of property info and context
  # when shaping decorator views.
  #
  # We'll use the PropertyDecorator objects
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
  class PropertyDecorator
    include Shaper::Base::ClassMethods

    attr_accessor :name
    attr_accessor :decorator_context
    attr_accessor :options

    def initialize(decorator_context, name, options={}, &block)
      self.decorator_context = decorator_context
      self.name = name
      self.options = options

      if block
        instance_eval(&block)
      else
        from = options[:from] || name
        delegate_property(from)
      end
    end

    def from(&block)
      decorator_context.send(:define_method, name, &block)
    end
  end
end
