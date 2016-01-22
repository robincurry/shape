require 'active_support/concern'

module Shape
  module Base

    extend ActiveSupport::Concern

    attr_accessor :_source
    attr_accessor :_parent

    protected :_parent

    def initialize(source = nil, options = {})
      self._source = source
      self._parent = options.delete(:parent)
      self.delegate_properties_from
    end

    #def source_name
      #_source.class.name
    #end
    #protected :source_name
    #

    protected

    def delegate_properties_from
      self.class._properties_from.each do |from, except|
        Array(_source.send(from)).each do |name|
          unless except.include?(name.to_sym)
            property(name) do
              from do
                _source.send(:[], name)
              end
            end
          end
        end
      end
    end


    module ClassMethods

      def shape(source, options={})
        self.new(source, options)
      end

      def shaper_context
        @shaper_context || self
      end

      # Expose a property as {<property_name>: "..."}
      # To expose a property using a different attribute on the resource:
      #
      #   property :display, from: :display_name
      #
      # To expose a property with inline definition:
      #
      #   property :display do
      #     from do
      #       #{last_name}, #{first_name}
      #     end
      #   end
      #
      # To expose a decorated collection:
      #
      #   property :practices, with: PracticeDecorator
      #
      #
      # To expose a decorated collection with view context
      #
      #   property :practices, with: PracticeDecorator, context: {view: :summary}
      #
      def property(property_name, options={}, &block)
        properties[property_name.to_sym] = Shape::PropertyShaper.new(
          shaper_context, property_name, options, &block
        )
      end
      alias_method :association, :property

      def properties_from(name, options={})
        except = Array(options[:except])
        _properties_from << [name, except]
      end

      def associations
        @associations ||= {}
      end

      def properties
        @properties ||= {}
      end

      def _properties_from
        @properties_from ||= []
      end

      # @overload delegate(*methods, options = {})
      #   Overrides {http://api.rubyonrails.org/classes/Module.html#method-i-delegate Module.delegate}
      #   to make `:_source` the default delegation target.
      #
      #   @return [void]
      def delegate(*methods)
        options = methods.extract_options!
        super *methods, options.reverse_merge(to: :_source)
      end

      def shape_collection(collection, sort_by: nil, **options)
        raw_shaped_collection(collection, options).tap do |c|
          c.sort_by! { |i| i.send(sort_by) } if sort_by
        end
      end

    protected
      def raw_shaped_collection(collection, options)
        Array(collection).map do |item|
          self.shape(item, options.clone)
        end
      end

      def delegate_property(name)
        if !shaper_context.method_defined?(name)
          shaper_context.delegate(name)
          shaper_context.send(:protected, name)
        end
      end


    end
    # Allows properties to be added in an instance..
    include ClassMethods
    def shaper_context
      @shaper_context || self.class
    end
  end
end
