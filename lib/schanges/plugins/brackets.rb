module SoundChanges
  module RulePlugins
    class BracketsPlugin < RulePlugin
      @from_regexp = /(?!\(\?<[[:upper:]]>)\[(.+?)\](?!\))/
      @to_regexp = '[\1]'
    end
  end
end
