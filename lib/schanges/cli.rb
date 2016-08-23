require 'thor'

module SoundChanges
  # Main app
  class CLI < Thor
    no_tasks do
      def apply_changes(words, changes, out_file)

      end
    end


    option :path, aliases: ['p'], default: '.', description: "Path to directory where your changes live"
    option :original,
            type: 'string',
            aliases: ['o'],
            default: false,
            description: 'Show original words besides the results.'
    option :debug,
            type: 'boolean',
            aliases: ['d'],
            default: false
    option :aliased,
            type: 'boolean',
            aliases: ['a'],
            default: true
    option :rule_count,
            type: 'boolean',
            aliases: ['rc'],
            default: false
    option :output_by_stage,
            type: 'boolean',
            default: false,
            description: 'Output wordlist between stages besides final version'
    desc 'apply NAME', 'Apply a changeset on a word list.'
    long_desc 'You will need a NAME.csv and a NAME.sc in the same directory.'
    def apply(name)
      words_files = Dir.glob(File.join(options[:path], "#{name}*.csv"))

      app = Applier.new(options)
      words_files.each do |file|
        basename = File.basename(file).sub(/\.csv/, '')
        sc = file.sub(/\.csv/, '.sc')
        app.add_stage(basename, File.open(file), File.open(sc)) if File.file?(sc)
      end

      results = app.apply
      results.each do |stage, result|
        file = File.join(options[:path], "#{stage}.out")

        lines = if options[:original]
                  # Assign original words to result words.
                  result.collect do |original, changed|
                    # Space words containing flying accents with +1 space.
                    space = changed[/[̀́̌̈̆̂]/] ? 11 : 10
                    Kernel.format("%-#{space}s%s", changed, "[#{original}]")
                  end
                else
                  result.values
                end

        File.open(file, 'wb') do |f|
          f.write(lines.join("\n"))
        end
      end
    rescue StandardError => e
      raise e if options[:debug]
      puts "ERROR: #{e}"
    end
  end
end
