module Shape
  # = View Decorator
  # Allows for creating different, composable
  # decorator views
  #
  # Example:
  #
  #   property :href
  #   property :addr_line1
  #   property :addr_line2
  #   property :city
  #   # ...
  #
  #   view :with_lat_long do
  #     property :latitude
  #     property :longitude
  #   end
  #
  #   view :with_facilities do
  #     link :facilities
  #   end
  #
  #   view :full do
  #     view :with_lat_long    # nests with_lat_long view
  #     view :with_facilities  # nests with_facilities view
  #   end
  #
  #
  # To use a decorator view, pass the view in to
  # the decorator context. For example:
  #
  #   @address = AddressDecorator.new(
  #     Address.find(params[:id]),
  #     context: {view: :full})
  #
  #
  class ViewDecorator
    include Shape::Base::ClassMethods
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
        views[name] = decorator_context.views[name]
      end
    end
  end
end
