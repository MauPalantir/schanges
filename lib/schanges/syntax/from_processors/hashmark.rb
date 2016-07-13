module SoundChanges::Syntax::FromProcessors
  class Hashmark < SoundChanges::FromProcessor
    # Replace brackets with escaped brackets.
    def process_regexp(str)
      str.gsub!(/\#$/, '(?:\b|\Z)')
      str.gsub!(/^\#/, '(?:\b|\A)')
    end
  end
end
