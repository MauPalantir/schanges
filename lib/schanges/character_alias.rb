module SoundChanges
  class CharacterAlias
    @aliases = {}

    class << self
      def apply(words, reverse = false)
        words.collect { |w| apply_alias(w, reverse) }
      end

      def apply!(words, reverse = false)
        words.collect! { |w| apply_alias(w, reverse) }
      end

      def add(key, value)
        @aliases[key] = value
      end

      protected

      def apply_alias(word_entry, reverse = false)
        w = word_entry[:word].clone
        @aliases.each do |char, al|
          if reverse
            w.gsub!(al, char)
          else
            w.gsub!(char, al)
          end
        end
        word_entry.merge(:word => w)
      end
    end
  end
end
