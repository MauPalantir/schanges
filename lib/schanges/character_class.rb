module SoundChanges
  class CharacterClass
    @classes = {}

    class << self
      attr_reader :classes

      def add(name, value)
        @classes[name] = value
      end

      def reset
        @classes = {}
      end

      # Replace character class wildcards with their full regexp.
      def process_regexp(string)
        result = string.clone
        classes.each do |char, definition|
          if result.include? char
            result.gsub! char, "(?<#{char}>[#{Regexp.escape(definition)}])"
          end
        end
        result
      end

      # Find character wildcards in a string.
      def find_classes(string)
        found = []
        string.each_char do |char|
          found << char if classes.include?(char)
        end
        found
      end

      # Determine if
      def class_letter?(letter)
        classes.keys.include? letter
      end

      def index(classname, letter)
        classes[classname].index(letter)
      end
    end
  end
end
