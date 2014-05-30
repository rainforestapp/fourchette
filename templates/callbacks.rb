# This is a sample
class Fourchette::Callbacks
  include Fourchette::Logger

  def initialize params
    @params = params
  end

  def before
    logger.info 'Placeholder for before steps... (see callbacks.rb to override)'
  end

  def after
    logger.info 'Placeholder for after steps... (see callbacks.rb to override)'
  end
end