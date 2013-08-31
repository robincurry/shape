module Shaper
  module Renderers
    include Shaper::DataVisitor

    def as_json(*args)
      Rack::MiniProfiler.step("Shaper::Renderers#as_json") do
        visit(lambda {|x| x.as_json})
      end
    end

    def to_hash(*args)
      visit
    end
  end
end
