module Shaper
  module Persistence
    extend ActiveSupport::Concern

    # Allows attributes on the decorated source to
    # be updated based on the properties hierarchy
    # exposed by the shaper view context.
    #
    # Only properties exposed by the view context
    # will be updated. Any others are ignored.
    #
    # Also handles the translation back to source
    # attributes from aliases. For instance, given
    # a decorated property:
    #
    #   property :first, from: :first_name
    #
    # Updating attributes from the decorator will
    # translate the "first" attribute to "first_name"
    # and update appropriately:
    #
    #   decorated_model.update_attributes(first: 'Alfred')
    #
    def update_attributes(params = {})
      updatable_attributes = self.keys
      updatable_attributes.delete(:id)

      params = ActionController::Parameters.new(params) unless params.respond_to?(:permit)
      permitted_params = params.permit(*updatable_attributes)

      recursively_update = lambda { |params_to_update, properties|
        params_to_update.each do |k, v|
          attr = (properties[k.to_sym].try(:options).try(:[], :from) || k).to_s
          if self.respond_to?("#{attr}=")
            self.send("#{attr}=", v)
          elsif v.is_a?(Hash)
            recursively_update.(v, properties[k.to_sym].properties)
          end
        end
      }
      recursively_update.(permitted_params, self.properties)

      self.source.save!
    end


    module ClassMethods

      # Allows a resource to be created
      # based on the properties hierarchy
      # exposed by the shaper view context.
      #
      # Only properties exposed by the view context
      # will be updated on the newly created resource.
      # Any others are ignored.
      #
      # By default it will infer the resource to
      # be created from the decorator name. For example
      #
      #   ProfessionalAwardDecorator.create(params)
      #
      # This will create and save a new ProfessionalAward instance.
      #
      # A specific resource may be passed in via block
      # if needed. This is particularly useful for creating
      # association resources on a parent object. For example:
      #
      #   ProfessionalAwardDecorator.create(params) { professional.awards.new }
      #
      # This will create a new ProfessionalAward for the given professional.
      #
      def create(attributes = nil, options = {}, &block)
        if attributes.is_a?(Array)
          attributes.collect { |attr| create(attr, options, &block) }
        else
          object = block_given? ? block.call : self.inferred_source_class.new
          self.new(object, options).tap do |obj|
            obj.update_attributes(attributes)
          end
        end
      end
    end
  end
end
