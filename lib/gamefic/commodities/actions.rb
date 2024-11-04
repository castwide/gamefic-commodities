# frozen_string_literal: true

module Gamefic
  module Commodities
    module Actions
      extend Gamefic::Scriptable

      include Gamefic::What

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

      respond :take, plaintext do |actor, text|
        commodities = Utils.match_nearby_commodities(actor, text)
        next actor.proceed if commodities.empty?

        if commodities.one?
          actor.execute :take, commodities.first
        else
          places = commodities.map { |object| object.parent.definitely }
          actor.tell "Where do you want to take one from, #{places.join_or}?"
          actor.cue AskForWhat, template: "take #{commodities.first.name} from __what__"
        end
      end

      respond :collect, plaintext do |actor, text|
        commodities = Utils.match_nearby_commodities(actor, text)
        next actor.proceed if commodities.empty?

        commodities.each { |com| actor.perform "take #{com.plural_name} from #{com.parent}" }
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

      respond :take, integer, siblings(Commodity) do |actor, quantity, commodity|
        Utils.try_quantity(actor, :take, quantity, commodity)
      end

      respond :drop, integer, children(Commodity) do |actor, quantity, commodity|
        Utils.try_quantity(actor, :drop, quantity, commodity)
      end

      respond :insert, integer, children(Commodity), available do |actor, quantity, commodity, other|
        Utils.try_quantity(actor, :insert, quantity, commodity, other)
      end

      respond :place, integer, children(Commodity), available do |actor, quantity, commodity, other|
        Utils.try_quantity(actor, :place, quantity, commodity, other)
      end

      on_update do
        entities.that_are(::Commodity)
                .reject(&:parent)
                .each { |entity| destroy entity }
      end
    end
  end
end
