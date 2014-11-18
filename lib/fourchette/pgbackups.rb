require 'heroku/client/pgbackups'
class Fourchette::Pgbackups
  include Fourchette::Logger

  def initialize
    @heroku = Fourchette::Heroku.new
  end

  def copy(from, to)
    ensure_pgbackups_is_present(from)
    ensure_pgbackups_is_present(to)

    from_url, from_name = pg_details_for(from)
    to_url, to_name = pg_details_for(to)

    @client =  Heroku::Client::Pgbackups.new pgbackup_url(from) + '/api'
    @client.create_transfer(from_url, from_name, to_url, to_name)
  end

  private

  def ensure_pgbackups_is_present(heroku_app_name)
    unless @heroku.client.addon.list(heroku_app_name).select do |addon|
      addon['name'] == 'pgbackups'
    end.any?
      logger.info "Adding pgbackups to #{heroku_app_name}"
      @heroku.client.addon.create(heroku_app_name,  plan: 'pgbackups')
    end
  end

  def pg_details_for(app_name)
    @heroku.config_vars(app_name).each do |key, value|
      if key.start_with?('HEROKU_POSTGRESQL_') && key.end_with?('_URL')
        return [value, key]
      end
    end
  end

  def pgbackup_url(app_name)
    @heroku.config_vars(app_name).each do |k, v|
      return v if k == 'PGBACKUPS_URL'
    end
  end
end
