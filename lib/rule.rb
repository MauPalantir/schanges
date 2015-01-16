module SoundChanges
  class Rule
    def initialize components
      @from, @to = components
    end

    def from
      @from
    end

    def to
      @to
    end

    def self.regexp
      @regexp
    end

    def self.short_name
      self.name.match(/::(.+)Rule$/)[1].downcase.to_sym
    end

    def to_a
      [@from, @to]
    end

    def to_h
      {@from => @to}
    end
  end

  class ClassRule < Rule
    @regexp = /^([[:upper:]])=(.+)$/
  end

  class AliasRule < Rule
    @regexp = /^(.+)\|(.+)$/
  end

  class ChangeRule < Rule
    # Regular expression to reckognize chage rules.
    @regexp = %r{^(.+)/(.+)/(.+)$}
    # Class
    @@classes

    def initialize components
      @from, @to, @context = components
    end

    # Public: Apply sound change rule on a word.
    #
    def apply_sc! word
      raise "Rule not preapred with class definitions." unless @from_regexp

      @from_regexp.match(word) do |m|
        result = get_result m
        word.gsub!(@from_regexp, result)
      end
      word
    end

    #
    # Prepare regular expressions.
    #
    def prepare classes = []
      @@classes = {}
      @from_classes = []
      from, from_context = ''

      classes.each do |klass|
        # Store classes in a class variable.
        @@classes[klass.from] = klass

        # Replace class reference with named regexp capture and
        # store classes appearing in the “from” part.
        from, from_context = [@from, @context].collect do |str|
          if str.include? klass.from
            @from_classes << { klass.from => klass.to }
            str.gsub! klass.from, "(?<#{klass.from}>[#{Regexp::escape(klass.to)}])"
          end
          str
        end
      end

      # Process various special characters in the context.
      [:braces, :hashmark, :ellipsis].each do |sym|
        method("from_#{sym}_to_regexp!").call from_context
      end
      from_underscore_to_regexp! from, from_context

      @from_regexp = Regexp.new from_context
    end

    private

    # Replace braces with escaped braces.
    def from_braces_to_regexp! str
      str.gsub!(/\(([^?:<>]+)\)/, '(?:\1)?')
    end

    # Replace hashmark with word boundary markers.
    def from_hashmark_to_regexp! str
      str.gsub!(/\#$/, '(?:\b|\Z)')
      str.gsub!(/^\#/, '(?:\b|\A)')
    end

    # Replace ellipsis with any characters wildcard.
    def from_ellipsis_to_regexp! str
      str.gsub!(/…/, '.+')
    end

    # Replace underscore with the from expression in the context string.
    def from_underscore_to_regexp! from, context
      context.gsub!('_', "(?<_>#{from})")
    end

    # Private: Make replacement string for the word part affected by the rule.
    #
    # +match+ - MatchData for the original string matched with +@from_regexp+.
    #
    # Return the replacement String.
    def get_result match
      result = match[0]
      to = to_replace_classes @to, match
      # Replace the „from” part marked as underscore with the prepared „to” value.
      result[match['_']] = to
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
    #
    # Returns the +to+ fragment with the class wildcards replaced with target letter.
    def to_replace_classes to, from_match
      if !@from_classes
        return to
      end

      to.each_char.with_index do |letter, index|
        # If the letter is a character class eg. Z.
        if @@classes.keys.include? letter
          # Pair target class with origin class by their order eg. Z > S
          from_class = @from_classes[index].keys.first

          # Get the actual letter that matches the original class in the word eg "t".
          match_letter = from_match[from_class]

          # Find the index of the letter in the original class eg. 1.
          from_class_index = @from_classes[index][from_class].index(match_letter)

          # Get the target class equivalent of the letter eg. "d".
          result_char = @@classes[letter].to[from_class_index] || match_letter

          # Replace the class letter with the actual resulting letter.
          to[letter] = result_char
        end
      end
      to
    end
  end
end