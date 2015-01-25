require 'rule'
require 'class'
require 'alias'

module SoundChanges
  class Base
    @@classes = ClassDefinition.new
    @@aliases = AliasDefinition.new
    @@rules = []
    @@words = []

    public

    def self.run
      words = apply_aliases @@words

      @@rules.each do |rule|
        words.collect! { |w| rule.apply_sc!(w) }
      end
      apply_aliases words, true
    end

    def self.parse_rules input
      input.split.each do |line|
        ClassDefinition.regexp.match(line) { |m| @@classes[m['key']] = m['value'] }
        AliasDefinition.regexp.match(line) { |m| @@aliases[m['key']] = m['value'] }
        ChangeRule.regexp.match(line) {|m| @@rules << ChangeRule.new(m[1, 3]) }
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
