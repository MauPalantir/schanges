module SoundChanges
  class Parser
    LINE_PATTERNS = {
      character_class: {
        regexp: /^(?<key>[[:upper:]])=(?<value>.+)$/,
        process: proc { |m| CharacterClass.add m['key'], m['value'] }
      },
      rules: {
        regexp: %r{^(\S*)/(.*)/(.+)$},
        process: proc { |m| @ruleset.add m[1, 3], @options }
      },
      character_aliases: {
        regexp: /^(?<key>.+)\|(?<value>.+)$/,
        process: proc { |m| CharacterAlias.add m['key'], m['value'] }
      }
    }.freeze

    def self.changes(input, ruleset, options)
      @ruleset = ruleset
      @options = options
      input.each do |line|
        LINE_PATTERNS.each do |_type, data|
          data[:regexp].match(line, &data[:process])
        end
      end
    end

    def self.words(input)
      input.collect(&:strip)
    end
  end
end
