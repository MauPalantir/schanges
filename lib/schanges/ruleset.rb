module SoundChanges
  class Ruleset
    attr_reader :rules

    def initialize(rules = [])
      @rules = []
      rules.each do |rule|
        add(rule)
      end
    end

    def add(components, options)
      rules << Rule.new(components, options)
    end

    def apply(words)
      return words unless @rules
      result = words.clone
      @rules.each do |r|
        result = result.collect { |w| r.apply(w) }
      end
      result
    end
  end
end
