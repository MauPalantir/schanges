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

    attr_reader :from, :to, :context

    def initialize(components, options = {})
      @options = options
      @values = Hash[[:from, :to, :context].zip(components)]
    end

    # Public: Apply sound change rule on a word.
    #
    def apply(word)
      regexp = prepare_rule_pattern
      p regexp if @options[:debug]
      result_word = word.clone
      # Support ephenthesis.
      m = regexp.match(result_word)
      return result_word unless m

      if @values[:to][@values[:from]]
        result_word = result_word.sub(regexp, get_result(m))
      else
        loop do
          break unless m
          result_word = result_word.sub(regexp, get_result(m))
          m = regexp.match(result_word)
        end
      end

      result_word
    end

    #
    # Prepare regular expressions.
    #
    def prepare_rule_pattern
      raise SoundChanges::Syntax::InvalidSyntaxError,
            "Missing _ in context at rule \"#{@values.values.join('/')}\"" unless @values[:context]['_']
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
