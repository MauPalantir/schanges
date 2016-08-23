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

    attr_reader :from, :to, :context, :regexp

    def from; @values[:from]; end
    def to; @values[:to]; end
    def context; @values[:context]; end

    def initialize(components, options = {})
      @options = options
      @values = Hash[[:from, :to, :context].zip(components)]
      @regexp = prepare_rule_pattern
    end

    # Public: Apply sound change rule on a word.
    #
    def apply(word_entry)
      word = word_entry[:word]
      STDOUT.puts word if @options[:debug]
      original_word = word
      result_word = word.dup

      # Support ephenthesis.
      m = regexp.match(result_word)
      return word_entry.merge(word: result_word) unless m
      return word_entry.merge(word: result_word.sub(regexp, get_result(m))) if to[from]
      loop do
        break unless m
        result_word.sub!(regexp, get_result(m))
        break if result_word == original_word
        original_word = result_word
        m = regexp.match(result_word)
      end

      word_entry.merge(word: result_word)
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
    #
    # I think this could be simplified with using sub regexp.
    def get_result(match)
      string = match[0]

      replaced = RESULT_SYNTAX.reduce(@values[:to].clone) do |to, syntaxelement|
        syntaxelement.new(match, to, @values[:from]).process
      end
      string[match_position(string, match), match['_'].length] = replaced
      string
    end

    # this is a temporary fix to make at least the word-finals work.
    # needs a proper sub implementation.
    def match_position(string, match)
      r = regexp.to_s
      multiple_matched = string.scan(match['_']).length > 1
      match_towards_end = r.end_with?('(?:\b|\Z))') &&
                          r.index('(?<_>') >= (r.length / 2)
      method = multiple_matched && match_towards_end ? :rindex : :index
      string.send(method, match['_'])
    end
  end
end
