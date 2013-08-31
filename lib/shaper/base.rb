require 'active_support/concern'

module Shaper
  module Base

    extend ActiveSupport::Concern

    def initialize(*args)
      super(*args)
      context[:view] ||= self.class.default_view
      @data_errors = {}
    end

    def href(name = self.source_name.underscore)
        # NOTE: polymorphic_url doesn't work here for all cases
        h.send("#{name}_url", self)
      rescue ActionController::RoutingError
      # No route exists for the resource. This can happen when the resource
      # hasn't been persisted yet.
    end

    def source_name
     source.class.name
    end
    protected :source_name

    def has_data_errors?
      !@data_errors.empty?
    end

    def data_error! (name, exception)
      #Rails.logger.debug "A data error occurred setting #{name}"
      #Rails.logger.debug exception
      @data_errors[name] = exception.message
    end

    def data_errors
      @data_errors
    end

    module ClassMethods

      def decorator_context
        @decorator_context || self
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
        properties[property_name] = Shaper::PropertyDecorator.new(
          decorator_context, property_name, options, &block
        )
      end

      # Expose a link as {href: "..."}
      #
      # To expose a collection:
      #
      #   link :practices
      #
      # The decorator exposes a link to the collection as a discreet href
      # by calling `polymorphic_url(source, collection)`
      #
      #   practices: {href: 'http://host/professionals/1/practices'}
      #
      # Use :path if the path cannot be inferred by polymorphic_url, e.g.:
      #
      #   link :field_specialties, path: :professional_field_specialties
      #
      # becomes:
      #
      #   field_specialties: {href: 'http://host/professionals/1/field_specialities'}
      #
      def link(link_name, options={})
        links[link_name] = options
        delegate_property(link_name)
      end


      # Creates a view that will be used if specified
      # via the decorator's context.
      #
      # Views can contain properties and links::
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
      # Views can be composed from other views:
      #
      #   view :full do
      #     view :with_lat_long    # nests with_lat_long view
      #     view :with_facilities  # nests with_facilities view
      #   end
      #
      # Decorators expose the view that is passed
      # in to the context:
      #
      #   AddressDecorator.new(
      #     @addresses,
      #     context: {view: :full})
      #
      def view(view_name, options={}, &block)
        views[view_name] = ViewDecorator.new(decorator_context, view_name, options, &block)
        if options[:default]
          self.default_view = view_name
        end
      end

      def properties
        @properties ||= {}
      end

      def links
        @links ||= {}
      end

      def views
        @views ||= {}
      end

      def default_view
        @default_view
      end

      def default_view=(v)
        @default_view = v
      end

    private

      def delegate_property(name)
        if !decorator_context.method_defined?(name)
          decorator_context.delegate(name) if decorator_context.respond_to?(name)
          decorator_context.delegate("#{name}=") if decorator_context.respond_to?("#{name}=")
        end
      end
    end

  end
end
