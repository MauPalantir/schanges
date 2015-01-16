require './rule.rb'

module SoundChanges
  class App
    require 'optparse'

    @rules
    @words

    def initialize
      files = parse_params
      parse files
    end

    def apply_changes
      apply_aliases @words

      @rules[:change].each do |rule|
        rule.prepare @rules[:class]
        @words.collect! { |w| rule.apply_sc!(w) }
      end
      apply_aliases @words, true
      @words
    end

    protected

    def apply_aliases(words, reverse = false)
      @rules[:alias].each do |al|
        arr = al.to_a
        if reverse; arr.reverse! end
        @words.collect! { |w| w.gsub(arr[0], arr[1]) }
      end
    end

    def parse files
      raise "You need to specify a sound change file." unless rules_file = files.find { |f| /.+\.sc/.match(f) }
      files.delete rules_file

      @rules = {:class => [], :alias => [], :change => []}
      @words = []

      # Collect all lines from the sc file that match a rule format.
      IO.foreach rules_file do |line|
        SoundChanges.constants.find_all {|klass| /.+Rule$/.match(klass) }.collect do |klass|
          rule_type = Object.const_get "SoundChanges::#{klass}"

          if m = rule_type.regexp.match(line)
            @rules[rule_type.short_name] << rule_type.new(m.to_a[1..-1])
          end
        end
      end

      files.each do |file|
        @words += File.read(file).split("\n")
      end
    end # def parse

    def parse_params
      parser = OptionParser.new
      @params = {}

      # Output everything with new line.
      parser.on('-n') { @params[:newline] = true }
      files = parser.parse!

      raise "You need to specify exactly two files." unless files.count == 2

      files
    end
  end
end

puts SoundChanges::App.new.apply_changes
