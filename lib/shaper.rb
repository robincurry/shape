require 'active_support/all'
require 'shaper/version'
require 'shaper/base'
require 'shaper/property_shaper'
require 'shaper/data_visitor'
require 'shaper/renderers'

module Shaper
  extend ActiveSupport::Concern
  include Shaper::Base
  include Shaper::Renderers
end
