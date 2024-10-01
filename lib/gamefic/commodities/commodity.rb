# frozen_string_literal: true

module Gamefic
  module Commodities
    # A groupable Gamefic entity.
    #
    # Commodities are grouped by default. When a commodity gets added to a parent
    # that already contains a commodity with the same class and name, they get
    # combined, i.e., the existing commodity's quantity is increased by the new
    # commodity's quantity, and the other commodity is destroyed.
    #
    class Commodity < Item
      class CommodityError < ArgumentError; end

      # @return [Integer]
      attr_writer :quantity

      # @return [String]
      attr_writer :plural_name

      def quantity
        @quantity ||= 1
      end

      def name
        plural? ? plural_name : super
      end

      def indefinite_article
        plural? ? quantity : super
      end

      def plural?
        quantity > 1
      end

      def plural_name
        @plural_name ||= "#{@name}s"
      end

      def except(amount)
        validate_split(amount)
        split(quantity - amount)
      end

      def split(amount)
        validate_split(amount)
        return self if amount == quantity

        dup.tap do |other|
          self.quantity -= amount
          other.quantity = amount
          other.parent = nil
        end
      end

      def parent=(other)
        extant = other&.children&.that_are&.find { |ent| same?(ent) }
        if extant
          extant.quantity += quantity
          super(nil)
        else
          super
        end
      end

      def same?(other)
        other.class == self.class && other.plural_name == plural_name
      end

      def keywords
        super + plural_name.keywords
      end

      def validate_split(amount)
        raise CommodityError, "There #{maybe_plural('is', 'are')} only #{quantity} #{name}." unless amount <= quantity

        raise CommodityError, "You need to specify 1 or more #{plural_name}." unless amount.positive?
      end
    end
  end
end

Commodity = Gamefic::Commodities::Commodity
