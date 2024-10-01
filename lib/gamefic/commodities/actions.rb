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

      respond :take, siblings(::Commodity) do |actor, _|
        actor.proceed
      end

      respond :place, siblings(::Commodity), available do |actor, _|
        actor.proceed
      end

      respond :place, children(::Commodity), available do |actor, _|
        actor.proceed
      end

      respond :insert, siblings(::Commodity), available do |actor, _|
        actor.proceed
      end

      respond :insert, children(::Commodity), available do |actor, _|
        actor.proceed
      end

      respond :take, available(::Commodity, ambiguous: true) do |actor, comms|
        comms = comms.reject { |com| com.parent == actor }
        if comms.one?
          actor.execute :take, comms.first
        else
          filtered = comms.reject { |ent| actor.flatten.include?(ent) }
          if filtered.one?
            actor.execute :take, filtered.first
          else
            places = filtered.map { |object| object.parent.definitely }
            actor.tell "Where do you want to take one from, #{places.join_or}?"
            actor.ask_for_what "take #{filtered.first.name} from __what__"
          end
        end
      end

      respond :collect, available(::Commodity, ambiguous: true) do |actor, comms|
        comms.reject { |com| com.parent == actor }
             .each { |com| actor.perform "take #{com.plural_name} from #{com.parent}" }
      end
      interpret 'collect all', 'take all'
      interpret 'collect :thing', 'take :thing'
      interpret 'collect all :commodity', 'collect :commodity'
      interpret 'collect all of :commodity', 'collect :commodity'
      interpret 'collect every :commodity', 'collect :commodity'
      interpret 'collect each :commodity', 'collect :commodity'
      interpret 'take all :commodity', 'collect :commodity'
      interpret 'take all of :commodity', 'collect :commodity'
      interpret 'take every :commodity', 'collect :commodity'
      interpret 'take each :commodity', 'collect :commodity'

      meta nil, plaintext do |actor, text|
        words = text.keywords
        verb = words.shift
        next actor.proceed if words.empty? || words.first =~ /[^\d]+/

        number = words.shift.to_i
        Utils.try_quantity(actor, number, "#{verb} #{words.join(' ')}")
      end

      on_update do
        entities.that_are(::Commodity)
                .reject(&:parent)
                .each { |entity| destroy entity }
      end
    end
  end
end
