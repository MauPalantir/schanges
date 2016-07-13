module SoundChanges::Syntax::FromProcessors
  class Ellipsis < SoundChanges::FromProcessor
    FROM_REGEXP = /…/
    TO_REGEXP = '.+?'.freeze
  end
end
