# This is a sample file to see how the really, really basic callback system works.
# See the README for me or just dive in.
class Fourchette::Callbacks
  include Fourchette::Logger

  def initialize(params)
    @params = params
  end

  def before_all
    logger.info 'Placeholder for before steps... (see callbacks.rb to override)'
  end

  def after_all
    logger.info 'Placeholder for after steps... (see callbacks.rb to override)'
  end
end
