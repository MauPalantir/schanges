module SoundChanges::Syntax::ResultProcessors
  # Plugin to define nonce character class (ie. a class defined one the fly).
  class DoubleBackslashProcessor < SoundChanges::ResultProcessor
    def process
      return @to unless @to.include?('\\\\')
      @from_match['_'].reverse
    end
  end
end
