require 'thor'

module SoundChanges
  # Main app
  class CLI < Thor
    option :path, aliases: ['p'], default: '.'
    option :show_original, aliases: ['o'], default: false
    desc 'apply NAME', 'Apply a changeset on a word list'
    def apply(name)
      words_file = File.join(options[:path], "#{name}.csv")
      changes_file = File.join(options[:path], "#{name}.sc")
      fail 'Word list not found' unless File.file?(words_file)
      fail 'Changes file not found' unless File.file?(changes_file)

      puts App.apply(File.open(words_file), File.open(changes_file), options)
    rescue StandardError => e
      puts "ERROR: #{e}"
    end
  end
end
