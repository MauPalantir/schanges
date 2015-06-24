module SoundChanges
  class RulePlugin
    class << self
      attr_reader :from_regexp, :to_regexp

      def process_regexp(str)
        str.gsub!(from_regexp, to_regexp)
      end
    end
  end

  # Change rules.
  class Rule
    Dir.glob("#{File.dirname(__FILE__)}/plugins/*.rb")
      .each { |f| require_relative f }

    @rules = []
    attr_reader :from, :to, :context

    class << self
      def add(components)
        @rules << new(components)
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

    def initialize(components)
      @original = components
      @from, @to, @context = components
      @to_from_map = []

      CharacterClass.find_classes(@to).each_with_index do |to_class, i|
        @to_from_map << [to_class, CharacterClass.find_classes(@from)[i]]
      end
    end

    # Public: Apply sound change rule on a word.
    #
    def apply(word)
      regexp = prepare_rule_pattern
      result_word = word.clone
      m = regexp.match(result_word)
      while m
        result = get_result(m)
        break unless result
        result_word = result_word.sub(regexp, result)
        m = regexp.match(result_word)
      end
      result_word
    end

    #
    # Prepare regular expressions.
    #
    def prepare_rule_pattern
      @from, @context = [@from, @context].collect do |string|
        CharacterClass.process_from_regexp string
      end

      # Process various special characters in the context.
      SoundChanges::RulePlugins.constants.each do |plugin|
        SoundChanges::RulePlugins
          .const_get(plugin).send :process_regexp, @context
      end
      assemble_regexp!
      Regexp.new @context
    end

    private

    # Replace underscore with the from expression in the context string.
    def assemble_regexp!
      @context.gsub!('_', "(?<_>#{@from})")
    end

    # Private: Make replacement string for the word part affected by the rule.
    #
    # +match+ - MatchData for the original string matched with +@from_regexp+.
    #
    # Return the replacement String.
    def get_result(match)
      result = match[0]
      result_to = to_replace_classes match
      return unless result_to
      # Replace the "from" part marked as underscore with the prepared
      # "to" value.
      result[match['_']] = result_to
      result
    end

    # Private: Find class definitions in the To definition and replace them with
    # the letter which has the same index in the target class as the original letter.
    #
    # - +to+ - The to pattern of the rule.
    # - +from_match+ - The MatchData of the full substring that the rule matched (from+context).
    #
    # Example:
    #   Given we have a class "S=ptk"
    #   And we have a class "Z=bdg"
    #   And the rule is "S/Z/_a"
    #   And the word is "pita"
    #   Then the value for +to+ is "Z"
    #   And the matched part +from_match+ is "<MatchData "ta" S="t">"
    #   And the output should be "da"
    #   Beacuse "t" is the second letter of the origin class, and "d" is the
    #   second letter of the original class.
    #
    # Returns the +to+ fragment with class wildcards replaced with target.
    def to_replace_classes(from_match)
      return @to if @to_from_map.empty?
      # Avoid manipulating to.
      result = @to.clone
      result.each_char.with_index do |letter, index|
        next unless CharacterClass.class_letter?(letter)
        to_class, from_class = @to_from_map.assoc(letter)
        result[index] = replace_class(from_class, to_class, from_match)
      end
      result
    end

    def replace_class(from_class, to_class, from_match)
      return to_class.downcase unless from_class
      from_char = from_match[from_class]
      # Get the actual letter that matches the original class in the word.
      # Eg "t".
      # Find the index of the letter in the original class eg. 1.
      from_class_index = CharacterClass.index(from_class, from_char)
      # Get the target class equivalent of the letter eg. "d".
      CharacterClass.classes[to_class][from_class_index] || from_char
    end
  end
end
