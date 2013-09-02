require 'active_support/concern'

module Shaper
  module Base

    extend ActiveSupport::Concern

    attr_accessor :_source
    attr_accessor :_parent

    protected :_parent

    def initialize(source = nil, options = {})
      self._source = source
      self._parent = options.delete(:parent)
    end

    def self.included(base)
      base.class_eval do
        class << self
          alias_method :shape, :new
        end
      end
    end

    #def source_name
      #_source.class.name
    #end
    #protected :source_name

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
        properties[property_name] = Shaper::PropertyShaper.new(
          shaper_context, property_name, options, &block
        )
      end

      def association(association_name, options = {}, &block)
        associations[association_name] = Shaper::AssocationShaper.new(
          shaper_context, association_name, options, &block
        )
      end

      def associations
        @associations ||= {}
      end

      def properties
        @properties ||= {}
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

      def shape_collection(collection, options = {})
        Array(collection).map do |item|
          self.shape(item, options.clone)
        end
      end

    protected
      def delegate_property(name)
        if !shaper_context.method_defined?(name)
          shaper_context.delegate(name)
          shaper_context.send(:protected, name)
        end
      end

    end
  end
end
