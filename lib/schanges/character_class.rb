module SoundChanges
  class CharacterClass
    @classes = {}

    class << self
      def add(name, value)
        @classes[name] = value
      end

      def all
        @classes
      end
    end
  end
end
