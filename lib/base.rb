require 'rule'
require 'class'
require 'alias'

module SoundChanges
  class Base
    @@classes = ClassDefinition.new
    @@aliases = AliasDefinition.new
    @@rules = []
    @@words = []
    @@params = []

    public

    def self.run params
      words = apply_aliases @@words
      result = words

      @@rules.each do |rule|
        result = result.collect { |w| rule.apply_sc(w) }
      end

      if params.has_key? :show_original and params[:show_original]
        # Assign original words.
        return Hash[words.zip(apply_aliases result, true)].collect do |original, changed|
          Kernel.format("%s%10s", changed, "[#{original}]")
        end
      else
        return result
      end
    end

    def self.parse_rules input
      input.split("\n").each do |line|
        ClassDefinition.regexp.match(line) { |m| @@classes[m['key']] = Regexp::escape m['value'] }
        AliasDefinition.regexp.match(line) do |m|
          @@aliases[Regexp::escape(m['key'])] = Regexp::escape m['value']
        end
        ChangeRule.regexp.match(line) do |m|
          @@rules << ChangeRule.new(m[1, 3])
        end
      end

      ChangeRule::set_classes @@classes
    end

    def self.parse_words input
      @@words = input.split("\n")
    end

    private

    def self.apply_aliases(words, reverse = false)
      result = words
      @@aliases.each do |char, al|
        if reverse
          result.collect! { |w| w.gsub(al, char) }
        else
          result.collect! { |w| w.gsub(char, al) }
        end
      end
      return result
    end

  end
end
