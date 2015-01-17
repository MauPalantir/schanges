module SoundChanges
  class App
    require 'optparse'
    require_relative '../lib/base'

    def initialize(args)
      parse_params args
    end

    def run
      parse @files
      Base::run
    end

    protected

    def parse files
      raise "You need to specify a sound change file." unless rules_file = files.find { |f| /.+\.sc/.match(f) }
      files.delete rules_file

      # Collect all lines from the sc file that match a rule format.
      Base::parse_rules File.read(rules_file)
      Base::parse_words File.read(files.first)
    end # def parse

    def parse_params args
      parser = OptionParser.new
      @params = {}

      # Output everything with new line.
      parser.on('-n') { @params[:newline] = true }
      files = parser.parse! args

      raise "You need to specify exactly two files." unless files.count == 2
      files.each { |file| raise "File \"#{file}\" not found." unless File.file? file }

      @files = files
    end
  end
end
