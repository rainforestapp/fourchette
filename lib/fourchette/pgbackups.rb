class Fourchette::Pgbackups
  include Fourchette::Logger

  def initialize
    @heroku = Fourchette::Heroku.new
  end

  def copy from, to
    ensure_pgbackups_is_present(from)
    ensure_pgbackups_is_present(to)

    create_transfer(from, to)
  end

  def create_transfer(from, to)

    pg_addons = @heroku.client.addon.list(from).select { |a| a['addon_service']['name'] == 'Heroku Postgres' }
    if pg_addons.size == 1
      pg_addon = pg_addons.first
      from_url, from_name = pg_details_for(from)
      to_url, to_name = pg_details_for(to)
      resource_name = pg_addon['provider_id']

      api_path = "/client/v11/databases/#{resource_name}/transfers"
      api_parameters = parameters = {
        'from_name' => from_name,
        'from_url' => from_url,
        'to_name' => to_name,
        'to_url' => to_url
      }.to_json

      db_api_client = RestClient::Resource.new(
        "https://postgres-api.heroku.com",
        :user => ENV['FOURCHETTE_HEROKU_USERNAME'],
        :password => ENV['FOURCHETTE_HEROKU_API_KEY']
      )

      res = db_api_client[api_path].post(parameters)
      logger.info "Transfer initiated. API response => #{res}"
    else
      logger.info "There is no Postgres database to copy"
    end

  end

  private
  def ensure_pgbackups_is_present heroku_app_name
    unless @heroku.client.addon.list(heroku_app_name).select { |addon| addon['name'] == 'pgbackups' }.any?
      logger.info "Adding pgbackups to #{heroku_app_name}"
      @heroku.client.addon.create(heroku_app_name, { plan: 'pgbackups' })
    end
  end

  def pg_details_for app_name
    @heroku.config_vars(app_name).each do |key, value|
      return [value, key] if key.start_with?('HEROKU_POSTGRESQL_') && key.end_with?('_URL')
    end
  end
end
