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

      def process_from_regexp(string)
        result = string.clone
        classes.each do |char, definition|
          if result.include? char
            result.gsub! char, "(?<#{char}>[#{Regexp.escape(definition)}])"
          end
        end
        result
      end

      def find_classes(string)
        found = []
        string.each_char do |char|
          found << char if classes.include?(char)
        end
        found
      end

      def class_letter?(letter)
        classes.keys.include? letter
      end

      def index(classname, letter)
        classes[classname].index(letter)
      end
    end
  end
end
