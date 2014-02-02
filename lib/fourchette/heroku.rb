class Fourchette::Heroku
  def app_exists? name
    client.app.list.collect { |app| app if app['name'] == name }.reject(&:nil?).any?
  end

  def fork from, to
    create_app(to)
    copy_config(from, to)
    copy_add_ons(from, to)
    copy_pg(from, to)
  end

  def delete app_name
    puts "Deleting #{app_name}"
    client.app.delete(app_name)
  end

  def client
    # TODO: add caching... https://github.com/heroku/heroics/#client-side-caching
    unless @heroku_client
      username = CGI.escape(ENV['FOURCHETTE_HEROKU_USERNAME'])
      token = ENV['FOURCHETTE_HEROKU_API_KEY']
      url = "https://#{username}:#{token}@api.heroku.com/schema"
      options = {default_headers: {'Accept' => 'application/vnd.heroku+json; version=3'}}
      @heroku_client = Heroics.client_from_schema_url(url, options)
    end
    @heroku_client
  end

  def config_vars app_name
    client.config_var.info(app_name)
  end

  def git_url app_name
    client.app.info(app_name)['git_url']
  end

  private
  def create_app name
    puts "Creating #{name}"
    client.app.create({ name: name })
  end

  def copy_config from, to
    puts "Copying configs from #{from} to #{to}"
    from_congig_vars = config_vars(from)
    # WE SHOULD NOT MOVE THE HEROKU_POSTGRES_*_URL...
    from_congig_vars.reject! { |k, v| k.start_with?('HEROKU_POSTGRESQL_') && k.end_with?('_URL') }
    client.config_var.update(to, from_congig_vars)
  end

  def copy_add_ons from, to
    puts "Copying addons from #{from} to #{to}"
    from_addons = client.addon.list(from)
    from_addons.each do |addon|
      puts "Adding #{addon['plan']['name']} to #{to}"
      client.addon.create(to, { plan: addon['plan']['name'] })
    end
  end

  def copy_pg from, to
    puts "Copying Postgres's data from #{from} to #{to}"
    backup = Fourchette::Pgbackups.new
    backup.copy(from, to)
  end
end