module SoundChanges::Syntax::FromProcessors
  # Parentheses make the character or group optional.
  class Parentheses < SoundChanges::FromProcessor
    FROM_REGEXP = /\(((?:\(\?<[[:upper:]]>.+\))|[^?<>]+)\)/
    TO_REGEXP = '(?:\1)?'.freeze
  end
end
