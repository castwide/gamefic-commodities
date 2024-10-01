# frozen_string_literal: true

module Gamefic
  module Commodities
    module Actions
      extend Gamefic::Scriptable

      respond :look, ::Commodity do |actor, thing|
        actor.proceed
        next unless thing.plural?

        if thing.parent == actor
          actor.tell "You have #{thing.quantity} of them."
        else
          actor.tell "There are #{thing.quantity} of them in #{the thing.parent}."
        end
      end

      respond :take, available(::Commodity, ambiguous: true) do |actor, comms|
        if comms.one?
          actor.proceed
        else
          filtered = comms.reject { |ent| actor.flatten.include?(ent) }
          if filtered.one?
            actor.execute :take, filtered.first
          else
            actor.tell "I don't know if you mean #{filtered.map(&:definitely).join_or}"
          end
        end
      end

      respond :drop, available(::Commodity, ambiguous: true) do |actor, comms|
        if comms.one?
          actor.proceed
        else
          filtered = comms.select { |ent| actor.flatten.include?(ent) }
          if filtered.one?
            actor.execute :drop, filtered.first
          else
            actor.tell "I don't know if you mean #{filtered.map(&:definitely).join_or}"
          end
        end
      end

      meta nil, plaintext do |actor, text|
        words = text.keywords
        verb = words.shift
        next actor.proceed if words.empty? || words.first =~ /[^\d]+/

        number = words.shift.to_i
        result = available(::Commodity, ambiguous: true).query(actor, words.join(' '))
        Utils.try(actor, verb.to_sym, number, result)
      end
    end
  end
end
