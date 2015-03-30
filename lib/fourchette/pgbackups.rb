require 'heroku-api'
require 'heroku/client/heroku_postgresql'
require 'heroku/helpers/heroku_postgresql'

class Fourchette::Pgbackups
  include Fourchette::Logger

  def initialize
    @heroku = Fourchette::Heroku.new
  end

  def copy(from, to)
    from_url, from_name = pg_details_for(from)
    to_url, to_name = pg_details_for(to)

    raw_attachment = @heroku.legacy_client.get_attachments(to).body[0]
    attachment = Heroku::Helpers::HerokuPostgresql::Attachment.new raw_attachment

    pg_client =  Heroku::Client::HerokuPostgresql.new(attachment)

    wait_for_db(pg_client)

    pg_client.pg_copy(from_name, from_url, to_name, to_url)
  end

  private

  # taken from Heroku::Command::Pg
  def wait_for_db(client)
    logger.info 'Waiting for database to become available...'
    loop do
      status = client.get_wait_status
      if status[:error?]
        logger.error 'Error waiting for database:'
        logger.error status[:message]
        break
      end
      break unless status[:waiting?]
      sleep 5
    end
  end

  def existing_backups?(heroku_app_name)
    @heroku.client.addon.list(heroku_app_name).any? do |addon|
      addon['name'] == 'pgbackups'
    end
  end

  def pg_details_for(app_name)
    @heroku.config_vars(app_name).each do |key, value|
      if key =~ /^HEROKU_POSTGRESQL_(.+)_URL$/
        return [value, $1]
      end
    end
  end

end
