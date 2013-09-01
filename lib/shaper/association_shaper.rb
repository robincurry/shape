module Shaper
  class AssocationShaper < PropertyShaper

    def define_accessor(name, source_name)
      with = options.fetch(:with)
      self.from do
        _source_object = (name == source_name ? _source : self)
        if assocation = begin
          _source_object.send(source_name)
          rescue NoMethodError
            if _source_object.respond_to?(:[])
              _source_object.send(:[], source_name)
            else
              raise
            end
          end
          if assocation.respond_to?(:join)
            with.shape_collection(assocation, parent: self)
          else
            with.shape(assocation, parent: self)
          end
        end
      end
    end

  end
end
