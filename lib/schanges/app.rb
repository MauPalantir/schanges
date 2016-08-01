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
    end

    def apply
      previous = {}
      stages.reduce({}) do |aliased_result, (name, stage)|
        words = stage[:aliased_words]
        original = stage[:aliased_words]
        unless previous.empty?
          words = previous[:result] + words
          original = previous[:original] + original
        end
        result = stage[:ruleset].apply(words)
        aliased_result[name] = Hash[CharacterAlias.apply(original, :reverse).zip(CharacterAlias.apply(result, :reverse))]
        previous[:original] = words
        previous[:result] = result
        aliased_result
      end
    end
  end
end
