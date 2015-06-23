module SoundChanges
  class App
    def self.apply(words, changes, options = {})
      Parser.changes(changes)
      aliased = CharacterAlias.apply Parser.words(words)
      result = CharacterAlias.apply Rule.apply(aliased), :reverse
      if options[:show_original]
        # Assign original words to result words.
        Hash[@words.zip(result)].collect do |original, changed|
          Kernel.format('%s%10s', changed, "[#{original}]")
        end
      else
        result
      end
    end
  end
end
