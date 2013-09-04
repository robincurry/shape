require 'active_support/all'
require 'shape/version'
require 'shape/base'
require 'shape/property_shaper'
require 'shape/data_visitor'
require 'shape/renderers'

module Shape
  extend ActiveSupport::Concern
  include Shape::Base
  include Shape::Renderers
end
