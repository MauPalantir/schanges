module SoundChanges
  class App
    attr_reader :options, :words, :changes_raw

    def initialize(words, changes, options = {})
      @options = options
      Parser.changes(changes)
      @words = Parser.words(words)
      @changes_raw = changes
      @aliased = CharacterAlias.apply self.words
    end

    def apply
      result = CharacterAlias.apply Rule.apply(@aliased), :reverse
      if options[:show_original]
        # Assign original words to result words.
        Hash[words.zip(result)].collect do |original, changed|
          Kernel.format('%-10s%s', changed, "[#{original}]")
        end
      else
        result
      end
    end
  end
end
