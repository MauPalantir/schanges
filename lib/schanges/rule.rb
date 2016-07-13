require_relative 'syntax'

module SoundChanges
  # Change rules.
  class Rule
    CONTEXT_SYNTAX = SoundChanges::Syntax::FromProcessors
                  .constants
                  .collect { |klass| SoundChanges::Syntax::FromProcessors.const_get(klass) }
                  .freeze
    RESULT_SYNTAX = SoundChanges::Syntax::ResultProcessors
                    .constants
                    .collect { |klass| SoundChanges::Syntax::ResultProcessors.const_get(klass) }
                    .freeze

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
    end

    # Public: Apply sound change rule on a word.
    #
    def apply(word)
      regexp = prepare_rule_pattern
      result_word = word.clone
      m = regexp.match(result_word)

      # Support ephenthesis.
      if @values[:from].empty?
        result_word = result_word.sub(regexp, get_result(m))
      else
        while m
          result = get_result(m)
          break unless result
          result_word = result_word.sub(regexp, result)
          m = regexp.match(result_word)
        end
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
      CONTEXT_SYNTAX.each do |syntaxelement|
        syntaxelement.new.send :process_regexp, context
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
      string[match['_']] = RESULT_SYNTAX.reduce(@values[:to].clone) do |to, syntaxelement|
        syntaxelement.new(match, to, @values[:from]).process
      end
      string
    end
  end
end
