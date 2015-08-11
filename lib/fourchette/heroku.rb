class Fourchette::Heroku
  include Fourchette::Logger

  EXCEPTIONS = [
    Excon::Errors::UnprocessableEntity,
    Excon::Errors::ServiceUnavailable
  ]

  def app_exists?(name)
    client.app.list.collect do |app|
      app if app['name'] == name
    end.reject(&:nil?).any?
  end

  def fork(from, to)
    create_app(to)
    copy_config(from, to)
    copy_add_ons(from, to)
    copy_pg(from, to)
    copy_rack_and_rails_env_again(from, to)
  end

  def delete(app_name)
    logger.info "Deleting #{app_name}"
    client.app.delete(app_name)
  end

  def client
    api_key = ENV['FOURCHETTE_HEROKU_API_KEY']
    @heroku_client ||= PlatformAPI.connect(api_key)
  end

  def legacy_client
    api_key = ENV['FOURCHETTE_HEROKU_API_KEY']
    ENV['HEROKU_API_KEY'] = api_key # necessary for Heroku::Auth.password to work
    @non_platform_client ||= Heroku::API.new(api_key: api_key)
  end

  def config_vars(app_name)
    client.config_var.info(app_name)
  end

  def git_url(app_name)
    client.app.info(app_name)['git_url']
  end

  def create_app(name)
    logger.info "Creating #{name}"
    client.app.create(name: name)
  end

  def copy_config(from, to)
    logger.info "Copying configs from #{from} to #{to}"
    from_congig_vars = config_vars(from)
    # WE SHOULD NOT MOVE THE HEROKU_POSTGRES_*_URL or DATABASE_URL...
    from_congig_vars.reject! do |k, _v|
      k.start_with?('HEROKU_POSTGRESQL_') && k.end_with?('_URL')
    end
    from_congig_vars.reject! { |k, _v| k == ('DATABASE_URL') }
    client.config_var.update(to, from_congig_vars)
  end

  def copy_add_ons(from, to)
    logger.info "Copying addons from #{from} to #{to}"
    from_addons = client.addon.list(from)
    from_addons.each do |addon|
      name = addon['plan']['name']
      begin
        logger.info "Adding #{name} to #{to}"
        client.addon.create(to, plan: name)
      rescue *EXCEPTIONS => e
        logger.error "Failed to copy addon #{name}"
        logger.error e
      end
    end
  end

  def copy_pg(from, to)
    if pg_enabled?(from)
      logger.info "Copying Postgres's data from #{from} to #{to}"
      backup = Fourchette::Pgbackups.new
      backup.copy(from, to)
    else
      logger.info "Postgres not enabled on #{from}. Skipping data copy."
    end
  end

  def copy_rack_and_rails_env_again(from, to)
    env_to_update = get_original_env(from)
    client.config_var.update(to, env_to_update) unless env_to_update.empty?
  end

  def get_original_env(from)
    environments = {}
    %w(RACK_ENV RAILS_ENV).each do |var|
      if client.config_var.info(from)[var]
        environments[var] = client.config_var.info(from)[var]
      end
    end
    environments
  end

  def pg_enabled?(app)
    client.addon.list(app).any? do |addon|
      addon['addon_service']['name'] =~ /heroku.postgres/i
    end
  end
end
