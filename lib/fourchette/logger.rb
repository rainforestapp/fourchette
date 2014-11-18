require 'logger'

module Fourchette::Logger
  def logger
    unless @logger
      @logger = Logger.new(STDOUT)
      @logger.level = Logger::INFO
    end

    @logger
  end
end
