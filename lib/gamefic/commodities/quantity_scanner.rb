module Gamefic
  module Commodities
    class QuantityScanner < Gamefic::Scanner::Base
      def scan
        words = token.keywords
        first = words.shift
        return unmatched_result unless first&.match(/\d+/)

        result = subprocess(words.join(' '))
        # @todo So we know the token might reference a quantity of a commodity. Now what?
        Gamefic::Scanner::Result.new(result.scanned, result.token. result.matched, result.remainder, self)
      end

      private

      def subprocess token_wo_number
        Gamefic::Scanner::DEFAULT_PROCESSORS.each do |scanner|
          result = scanner.scan(selection, token_wo_number)
          return result unless result.matched.empty?

          next result
        end
      end
    end
  end
end
