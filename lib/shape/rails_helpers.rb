module Shape
  module RailsHelpers
    protected

    def t(*args, &block)
      I18n.t(*args, &block)
    end

    def l(*args, &block)
      I18n.l(*args, &block)
    end

    def u
      Rails.application.routes.url_helpers
    end

    def h
      ApplicationController.helpers
    end
  end
end
