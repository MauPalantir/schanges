module SoundChanges
  module RulePlugins
    class EllipsisPlugin < RulePlugin
      @from_regexp = /…/
      @to_regexp = '\S+?'
    end
  end
end
