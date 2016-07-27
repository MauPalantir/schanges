module SoundChanges::Syntax::ResultProcessors
  class CharacterClassProcessor < SoundChanges::ResultProcessor
    def process
      replace_classes
    end

    # Private: Find class definitions in the To definition and replace them with
    # the letter which has the same index in the target class as the original letter.
    #
    # Example:
    #   Given we have a class "S=ptk"
    #   And we have a class "Z=bdg"
    #   And the rule is "S/Z/_a"
    #   And the word is "pita"
    #   Then the value for +to+ is "Z"
    #   And the matched part +from_match+ is "<MatchData "ta" S="t">"
    #   And the output should be "da"
    #   Beacuse "t" is the second letter of the origin class, and "d" is the
    #   second letter of the original class.
    #
    # Returns the +to+ fragment with class wildcards replaced with target.
    def replace_classes
      return to if to_from_map.empty?
      result = to.clone
      result.each_char.with_index do |letter, index|
        next unless ::SoundChanges::CharacterClass.class_letter?(letter)
        to_class, from_class = to_from_map.assoc(letter)
        result[index] = replace_class(from_class, to_class)
      end
      result
    end

    private

    # Replace the character in @from_match that belongs to a class
    # with the corresponding sound in the result class.
    #
    # Example:
    # Given instance @from_match has an entry "S" => "t"
    # character classes are S=ptk, Z=bdg
    # then replace_class("S", "Z") will return "d"
    #
    # @param from_class eg. "S"
    # @param to_class eg. "Z"
    #
    # @return the replaced character.
    def replace_class(from_class, to_class)
      return to_class.downcase unless from_class
      from_char = from_match[from_class]
      # Get the actual letter that matches the original class in the word.
      # Eg "t".
      # Find the index of the letter in the original class eg. 1.
      from_class_index = ::SoundChanges::CharacterClass.index(from_class, from_char)
      # Get the target class equivalent of the letter eg. "d".
      ::SoundChanges::CharacterClass.classes[to_class][from_class_index] || from_char
    end

    # Finds character classes and maps them to their equivalent in the origin.
    #
    # @return Array
    # [
    #   ["Z", "S"]
    # ]
    def to_from_map
      return @to_from_map if @to_from_map
      @to_from_map = []

      ::SoundChanges::CharacterClass
        .find_classes(to)
        .each_with_index do |to_class, i|
        @to_from_map << [to_class,
                         ::SoundChanges::CharacterClass.find_classes(@from)[i]]
      end
      @to_from_map
    end
  end
end
