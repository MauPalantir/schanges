module SoundChanges::Syntax::FromProcessors
  class Hashmark < SoundChanges::FromProcessor
    # Replace brackets with escaped brackets.
    def process_regexp(str)
      str.gsub!(/\#\Z/, '(?:\b|\Z)')
      str.gsub!(/\A\#/, '(?:\b|\A)')
    end
  end
end
