# frozen_string_literal: true

module Gamefic
  module Commodities
    module Utils
      module_function

      # @param actor [Gamefic::Actor]
      # @param verb [Symbol]
      # @param number [Integer]
      # @param result [Gamefic::Query::Result]
      def try actor, verb, number, result
        return actor.proceed if result.match.empty?

        if result.match.one?
          thing = result.match.first
          if number == thing.quantity
            actor.perform "#{verb} #{thing.object_id} #{result.remainder}"
          else
            from = thing.parent
            rest = thing.except(number)
            actor.perform "#{verb} #{thing.object_id} #{result.remainder}"
            rest.parent = from
          end
        elsif result.remainder.empty?
          actor.execute verb, result.match
        else
          actor.proceed
        end
      rescue ::CommodityError => err
        actor.tell err.message
      end
    end
  end
end
