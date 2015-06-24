module SoundChanges
  module RulePlugins
    class ParenthesesPlugin < RulePlugin
      @from_regexp = /\(((?:\(\?<[[:upper:]]>.+\))|[^?<>]+)\)/
      @to_regexp = '(?:\1)?'
    end
  end
end
