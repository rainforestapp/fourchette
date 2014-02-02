class Fourchette::Callbacks
  include Fourchette::Logger

  def initialize params
    @params = params
  end

  def before
    logger.info 'Running before steps...'
  end

  def after
    logger.info 'Running after steps...'
  end
end