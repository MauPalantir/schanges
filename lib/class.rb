module SoundChanges
  class ClassDefinition < Hash
    @regexp = /^(?<key>[[:upper:]])=(?<value>.+)$/

    def self.regexp
      @regexp
    end
  end
end
