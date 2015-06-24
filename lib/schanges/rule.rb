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
      @values = Hash[[:from, :to, :context].zip(components)]
      @to_from_map = []
      CharacterClass
        .find_classes(@values[:to])
        .each_with_index do |to_class, i|
        @to_from_map << [to_class,
                         CharacterClass.find_classes(@values[:from])[i]]
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
      from = CharacterClass.process_regexp @values[:from]
      context = CharacterClass.process_regexp @values[:context]

      # Process various special characters in the context.
      SoundChanges::RulePlugins.constants.each do |plugin|
        SoundChanges::RulePlugins
          .const_get(plugin).send :process_regexp, context
      end
      Regexp.new assemble_regexp(from, context)
    end

    private

    # Replace underscore with the from expression in the context string.
    def assemble_regexp(from, context)
      context.gsub!('_', "(?<_>#{from})")
    end

    # Replace "from" with the contents of "to".
    def get_result(match)
      string = match[0]
      string[match['_']] = replace_classes_in @values[:to], match
      string
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
    def replace_classes_in(to, from_match)
      return to if @to_from_map.empty?
      # Avoid manipulating to.
      result = to.clone
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
