# frozen_string_literal: true

module Gamefic
  module Commodities
    module Utils
      module_function

      # @param actor [Gamefic::Actor]
      # @param number [Integer]
      # @param command [String]
      def try_quantity actor, number, command
        expressions = Syntax.tokenize(command, actor.epic.syntaxes)
        command = Gamefic::Command.compose(actor, expressions)
        if command.arguments.first.is_a?(Commodity)
          if command.arguments.first.quantity == number
            actor.execute command.verb, *command.arguments
          else
            rest = command.arguments.first.except(number)
            from = command.arguments.first.parent
            actor.execute command.verb, *command.arguments
            rest.parent = from
          end
        else
          actor.proceed
        end
      rescue Commodity::CommodityError => e
        actor.tell e.message
      end
    end
  end
end
