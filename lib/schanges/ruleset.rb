module SoundChanges
  class Ruleset
    def rules
      @rules || []
    end

    def initialize(rules)
      rules.each do |rule|
        add(rule)
      end
    end

    def add(components)
      @rules << Rule.new(components)
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
