class Fourchette::Callbacks
  include Fourchette::Logger

  def initialize params
    @params = params
  end

  def before
    logger.info 'Placeholder for before steps...'
  end

  def after
    logger.info 'Placeholder for after steps...'
  end
end