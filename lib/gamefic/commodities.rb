# frozen_string_literal: true

require 'gamefic'
require 'gamefic-standard'

module Gamefic
  module Commodities
    require 'gamefic/commodities/version'
    require 'gamefic/commodities/commodity'
    require 'gamefic/commodities/utils'
    require 'gamefic/commodities/actions'
  end
end

Gamefic::Standard.include Gamefic::Commodities::Actions
