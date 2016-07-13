module SoundChanges
  class App
    attr_reader :options, :words, :changes_raw, :ruleset

    def initialize(words, changes, options = {})
      @options = options
      @ruleset = Ruleset.new
      Parser.changes(changes, @ruleset, options)
      @words = Parser.words(words)
      @changes_raw = changes
      @aliased = CharacterAlias.apply self.words
    end

    def apply
      result = CharacterAlias.apply ruleset.apply(@aliased), :reverse
      if options[:show_original]
        # Assign original words to result words.
        Hash[words.zip(result)].collect do |original, changed|
          # Space words containing flying accents with +1 space.
          space = changed[/[̀́̌̈̆̂]/] ? 11 : 10
          Kernel.format("%-#{space}s%s", changed, "[#{original}]")
        end
      else
        result
      end
    end
  end
end
