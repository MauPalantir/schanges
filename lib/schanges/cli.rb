require 'thor'

module SoundChanges
  # Main app
  class CLI < Thor
    option :path, aliases: ['p'], default: '.', description: "Path to directory where your changes live"
    option :show_original,
            type: 'boolean',
            aliases: ['o'],
            default: false,
            description: "Show original words besides the results."
    desc 'apply NAME', 'Apply a changeset on a word list.'
    long_desc 'You will need a NAME.csv and a NAME.sc in the same directory.'
    def apply(name)
      words_file = File.join(options[:path], "#{name}.csv")
      changes_file = File.join(options[:path], "#{name}.sc")
      raise 'Word list not found' unless File.file?(words_file)
      raise 'Changes file not found' unless File.file?(changes_file)

      puts App.new(File.open(words_file), File.open(changes_file), options).apply
    rescue StandardError => e
      puts "ERROR: #{e}"
    end
  end
end
