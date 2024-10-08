# frozen_string_literal: true

module Gamefic
  module Commodities
    module Utils
      module_function

      # @param actor [Gamefic::Actor]
      # @param number [Integer]
      # @param input [String]
      def try_quantity(actor, number, input)
        command = Gamefic::Command.compose(actor, input)
        return actor.proceed unless command.arguments.first.is_a?(Commodity)

        command.arguments.first.count(number) do
          actor.execute command.verb, *command.arguments
        end
      rescue Commodity::CommodityError => e
        actor.tell e.message
      end
    end
  end
end
