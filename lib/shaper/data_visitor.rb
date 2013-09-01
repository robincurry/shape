module Shaper
  module DataVisitor

    def visit(visitor = lambda {|x| x})
      data_visitor(properties_to_visit, visitor).merge!(
        assocation_visitor(self.class.associations, visitor)
      )
    end

  protected

    def properties_to_visit
      self.class.properties
    end

    def data_visitor(properties = self.properties_to_visit, visitor = lambda {|x| x})
      properties.each_with_object({}) do |(name, property), obj|
        obj[name] = visitor.call(self.send(name))
      end
    end

    def assocation_visitor(associations = self.class.associations, visitor = lambda {|x| x})
      associations.each_with_object({}) do |(name, property), obj|
        assocation = self.send(name)
        obj[name] = if assocation.respond_to?(:visit)
          assocation.visit(visitor)
        elsif assocation.respond_to?(:map)
          assocation.each_with_object([]) do |item, results|
            if item.respond_to?(:visit) and visited = item.visit(visitor) and !visited.blank?
              results << visited
            end
          end
        end
      end
    end

  end
end
