module SoundChanges
  class Applier
    attr_reader :options, :words, :changes_raw, :ruleset, :stages

    def initialize(options = {})
      @stages = {}
      @options = options
    end

    def add_stage(name, words, changes)
      ruleset = Parser.changes(changes, Ruleset.new([], options))
      processed_words = Parser.words(words)
      @stages[name] = {
        name: name,
        changes_raw: changes,
        ruleset: ruleset,
        words: processed_words,
        aliased_words: CharacterAlias.apply(processed_words)
      }
      self
    end

    def apply
      original = []
      result = []

      stages.each_with_object({}) do |(name, stage), aliased_result|
        words = result + stage[:aliased_words]
        original = options[:original] == 'absolute' ? original + stage[:aliased_words] : words
        result = stage[:ruleset].apply(words)
        aliased_result[name] = Hash[CharacterAlias.apply(original, :reverse).zip(CharacterAlias.apply(result, :reverse))]
      end
    end
  end
end
