module Shaper
  module DataVisitor

    def visit(visitor = lambda {|x| x})
      data_visitor(properties_to_visit, visitor).merge!(
        association_visitor(self.class.associations, visitor)
      )
    end

  protected

    def properties_to_visit
      self.class.properties.merge(self.properties)
    end

    def data_visitor(properties = self.properties_to_visit, visitor = lambda {|x| x})
      properties.each_with_object({}) do |(name, property), obj|
        obj[name] = visitor.call(self.send(name))
      end
    end

    def association_visitor(associations = self.class.associations, visitor = lambda {|x| x})
      associations.each_with_object({}) do |(name, property), obj|
        association = self.send(name)
        obj[name] = if association.respond_to?(:visit)
          association.visit(visitor)
        elsif association.respond_to?(:map)
          association.each_with_object([]) do |item, results|
            if item.respond_to?(:visit) and visited = item.visit(visitor) and !visited.blank?
              results << visited
            end
          end
        end
      end
    end

  end
end
