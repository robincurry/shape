module Shaper
  module DataVisitor

    def visit(visitor = lambda {|x| x})
      s1 = Rack::MiniProfiler.start_step("#visit")
      data_visitor(self.class.properties, visitor).tap do |obj|
        s2 = Rack::MiniProfiler.start_step("#links_visitor")
        obj.merge! links_visitor(self.class.links, visitor)
        Rack::MiniProfiler.finish_step s2

        if context[:view] && view = self.class.views[context[:view]]
          s3 = Rack::MiniProfiler.start_step("#view_visitor")
          view_visitor(view, obj, visitor)
          Rack::MiniProfiler.finish_step s3
        end
        Rack::MiniProfiler.finish_step s1
      end
    end

    def keys
      map_keys = lambda {|hash| hash.map {|k,v| v.is_a?(Enumerable) ? {}.tap {|h| h[k] = map_keys.(v)} : k}}
      map_keys.(self.visit(lambda {|x| nil}))
    end

    def properties
      {}.tap do |props|
        props.merge! self.class.properties
        if context[:view] && view = self.class.views[context[:view]]
          props.merge! view.properties
        end
      end
    end

  protected

    def data_visitor(properties = self.class.properties, visitor = lambda {|x| x})
      properties.each_with_object({}) do |(name, property), obj|
        from = property.options[:from] || name
        begin
          if property.properties.present? || property.links.present?
            obj[name] = self.data_visitor(property.properties, visitor)
            .merge!(links_visitor(property.links, visitor))
          elsif property.options.present? && property.options[:with]
            v1 = Rack::MiniProfiler.start_step("#data_visitor association")
            association = Draper::DecoratedAssociation.new(
              self,
              from,
              property.options.except(:from)
            )
            if association.call.nil?
              obj[name] = nil
            else
              obj[name] = visitor.call(association.call)
            end
            Rack::MiniProfiler.finish_step v1
          else
            v2 = Rack::MiniProfiler.start_step("#data_visitor send(#{from})")
            obj[name] = visitor.call(self.send(from))
            Rack::MiniProfiler.finish_step v2
          end
        # An error can occur here when we have an id for a related object
        # which doesn't happen to be in the database. This is kind of
        # a catch-all that I don't actually like but want to discuss.
        rescue Exception => error
          obj[name] = nil
          self.data_error! name, error
        end
      end
    end

    def links_visitor(links = self.class.links, visitor = lambda {|x| x})
      links.each_with_object({}) do |(name, options), obj|
        l1 = Rack::MiniProfiler.start_step("#links_visitor each")
        obj[:links] ||= {}
        if path = options[:path]
          obj[:links][name] = h.polymorphic_url(link_args_for(path))
        elsif resource = self.send(name)
          if resource.respond_to?(:map) # array of resources
            obj[:links][name] = h.polymorphic_url(link_args_for(name))
          else # single resource
            obj[:links][name] = resource.href
          end
        else
          obj[:links][name] = nil
        end
        Rack::MiniProfiler.finish_step l1
      end
    end

    def view_visitor(view, obj, visitor = lambda {|x| x})
      if view.views.present?
        view.views.each do |k, v|
          view_visitor(v, obj, visitor)
        end
      else
        v1 = Rack::MiniProfiler.start_step("#merge data_visitor")
        obj.merge! data_visitor(view.properties, visitor)
        Rack::MiniProfiler.finish_step v1

        v2 = Rack::MiniProfiler.start_step("#deep_merge links")
        obj.deep_merge! links_visitor(view.links, visitor)
        Rack::MiniProfiler.finish_step v2
        obj
      end
    end

    def link_args_for(param)
      [].tap do |args|
        args << self.source
        args << param if !param.nil?
      end
    end

  end
end
