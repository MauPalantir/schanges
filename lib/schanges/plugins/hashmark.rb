module SoundChanges
  module RulePlugins
    class HashmarkPlugin < RulePlugin
      class << self
        # Replace brackets with escaped brackets.
        def process_regexp(str)
          str.gsub!(/\#$/, '(?:\b|\Z)')
          str.gsub!(/^\#/, '(?:\b|\A)')
        end
      end
    end
  end
end
