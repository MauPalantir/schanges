module SoundChanges
  class Ruleset
    attr_reader :rules, :options

    def initialize(rules = [], options = {})
      @rules = []
      @options = options
      rules.each do |rule|
        add(rule)
      end
    end

    def add(components)
      rules << Rule.new(components, options)
    end

    def apply(words)
      return words unless @rules
      STDERR.puts @rules.size if options[:debug]
      result = words.clone
      @rules.each do |r|
        result = result.collect { |w| r.apply(w) }
      end
      result
    end
  end
end
