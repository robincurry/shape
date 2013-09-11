module Shape
  module DataVisitor

    def visit(visitor = lambda {|x| x})
      data_visitor(properties_to_visit, visitor)
    end

  protected

    def properties_to_visit
      self.class.properties.merge(self.properties)
    end

    def data_visitor(properties = self.properties_to_visit, visitor = lambda {|x| x})
      properties.each_with_object({}) do |(name, property), obj|
        if property.options.present? && (property.options[:with] || property.options[:each_with])
          result = self.send(name)
          if result.respond_to?(:visit)
            obj[name] = result.visit(visitor)
          elsif result.is_a?(Enumerable)
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

  end
end
