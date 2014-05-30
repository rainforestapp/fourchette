class Fourchette::Callbacks
  include Fourchette::Logger

  def initialize params
    @params = params
  end

  def before_all
    logger.info 'Placeholder for before steps...'
  end

  def after_all
    logger.info 'Placeholder for after steps...'
  end
end