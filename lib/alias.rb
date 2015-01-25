module SoundChanges
  class AliasDefinition < Hash
    @regexp = /^(?<key>.+)\|(?<value>.+)$/

    def self.regexp
      @regexp
    end
  end
end
