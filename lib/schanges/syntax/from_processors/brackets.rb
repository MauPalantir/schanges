module SoundChanges::Syntax::FromProcessors
  # Plugin to define nonce character class (ie. a class defined one the fly).
  class Brackets < SoundChanges::FromProcessor
    FROM_REGEXP = /(?!\(\?<[[:upper:]]>)\[(.+?)\](?!\))/
    TO_REGEXP = '[\1]'.freeze
  end
end
