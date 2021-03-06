module Shape
  module Renderers
    include Shape::DataVisitor

    def as_json(*args)
      visit(lambda {|x| x.as_json})
    end

    def to_hash(*args)
      visit
    end
    alias_method :to_h, :to_hash
  end
end
