module SoundChanges
  class Parser
    LINE_PATTERNS = {
      character_class: {
        regexp: /^(?<key>[[:upper:]])=(?<value>.+)$/,
        process: proc { |m| CharacterClass.add m['key'], m['value'] }
      },
      rules: {
        regexp: %r{^([\S ]+)/(.*)/(.+)$},
        process: proc { |m| @ruleset.add m[1, 3] }
      },
      character_aliases: {
        regexp: /^(?<key>.+)\|(?<value>.+)$/,
        process: proc { |m| CharacterAlias.add m['key'], m['value'] }
      }
    }.freeze

    def self.changes(input, ruleset)
      @ruleset = ruleset
      input.each do |line|
        LINE_PATTERNS.each do |_type, data|
          data[:regexp].match(line, &data[:process])
        end
      end
      ruleset
    end

    def self.words(input)
      input.collect(&:strip).reject { |w| w[0] == '#' }
    end
  end
end
