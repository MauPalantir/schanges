module SoundChanges
  module Syntax;
    InvalidSyntaxError = Class.new StandardError
  end

  class FromProcessor
    FROM_REGEXP = Regexp.new('')
    TO_REGEXP = ''.freeze

    def process_regexp(str)
      str.gsub!(self.class::FROM_REGEXP, self.class::TO_REGEXP)
    end
  end

  class ResultProcessor
    attr_reader :to, :from, :from_match

    def initialize(match, to, from)
      @to = to
      @from = from
      @from_match = match
    end

    def process
      raise 'this method is to be overridden'
    end
  end
end

Dir.glob("#{File.dirname(__FILE__)}/syntax/from_processors/*.rb").each { |f| require_relative f }
Dir.glob("#{File.dirname(__FILE__)}/syntax/result_processors/*.rb").each { |f| require_relative f }
