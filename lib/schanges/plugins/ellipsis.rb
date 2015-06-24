module SoundChanges
  module RulePlugins
    class EllipsisPlugin < RulePlugin
      @from_regexp = /…/
      @to_regexp = '.+?'
    end
  end
end
