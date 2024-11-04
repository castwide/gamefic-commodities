# frozen_string_literal: true

module Gamefic
  module Commodities
    module Utils
      module_function

      # @param actor [Gamefic::Actor]
      # @param verb [Symbol]
      # @param quantity [Integer]
      # @param commodity [Commodity]
      def try_quantity(actor, verb, quantity, commodity, *args)
        commodity.count(quantity) { actor.execute verb, commodity, *args }
      rescue Commodity::CommodityError => e
        actor.tell e.message
      end

      def match_nearby_commodities(actor, text)
        available = Gamefic::Query::Family.span(actor)
        result = Gamefic::Scanner.scan(available, text)
        if result.remainder.empty? && result.matched.all? do |ent|
             ent.is_a?(Commodity)
           end && result.matched.uniq(&:name).one?
          result.matched.reject { |com| actor.flatten.include?(com) }
        else
          []
        end
      end
    end
  end
end
