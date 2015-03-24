module Shape
  module DataVisitor

    def visit(visitor = lambda {|x| x})
      data_visitor(properties_to_visit, visitor)
    end

  protected

    def properties_to_visit
      all_properties.select { |_, property| visitable?(property) }
    end

    def all_properties
      self.class.properties.merge(self.properties)
    end

    def data_visitor(properties = self.properties_to_visit, visitor = lambda {|x| x})
      properties.each_with_object({}) do |(name, property), obj|
        if property.properties.present?
          obj[name] = self.data_visitor(property.properties, visitor)
        elsif property.options.present? && (property.options[:with] || property.options[:each_with])
          result = self.send(name)
          if result.respond_to?(:visit)
            obj[name] = result.visit(visitor)
          elsif result.is_a?(Array)
            obj[name] = result.each_with_object([]) do |item, results|
              results << item.visit(visitor)
            end
          else
            obj[name] = property.options[:with] ? nil : []
          end
        else
          obj[name] = visitor.call(self.send(name))
        end
      end
    end

    def visitable?(property)
      conditional = property.options.fetch(:if, true)
      conditional.is_a?(Proc) ? instance_exec(&conditional) : conditional
    end

  end
end
