require 'spec_helper'

require 'heroku/helpers/heroku_postgresql'

describe Fourchette::Pgbackups do
  describe '#copy' do
    let(:from_app_name) { 'awesome app' }
    let(:to_app_name) { 'awesomer app!' }
    let(:pg_backup) { Fourchette::Pgbackups.new }
    let(:heroku) { instance_double(Fourchette::Heroku) }
    let(:pg_client) { instance_double(Heroku::Client::HerokuPostgresql) }

    let(:config_vars_from) do
      { 'HEROKU_POSTGRESQL_FROM_URL' => 'postgres://from...',
        'PGBACKUPS_URL' => 'postgres://frombackup...' }
    end

    let(:config_vars_to) do
      { 'HEROKU_POSTGRESQL_TO_URL' => 'postgres://to...',
        'PGBACKUPS_URL' => 'postgres://tobackup...' }
    end

    before do
      response = double('response')
      allow(Fourchette::Heroku).to receive(:new).and_return(heroku)

      allow(heroku)
        .to receive_message_chain(:legacy_client, :get_attachments)
        .and_return(response)

      allow(response)
        .to receive(:body)
        .and_return(['raw_attachment'])

      allow(heroku)
        .to receive(:config_vars)
        .with(from_app_name)
        .and_return(config_vars_from)

      allow(heroku)
        .to receive(:config_vars)
        .with(to_app_name)
        .and_return(config_vars_to)

      allow(pg_client)
        .to receive(:get_wait_status)
        .and_return({ :waiting? => false })
    end

    it 'copies the pg database from origin app to destination one' do
      expect(Heroku::Helpers::HerokuPostgresql::Attachment)
        .to receive(:new)
        .with('raw_attachment')
        .and_return('attachment')

      expect(Heroku::Client::HerokuPostgresql)
        .to receive(:new)
        .with('attachment')
        .and_return(pg_client)

      expect(pg_client).to receive(:pg_copy).with(
        'FROM',
        config_vars_from['HEROKU_POSTGRESQL_FROM_URL'],
        'TO',
        config_vars_to['HEROKU_POSTGRESQL_TO_URL']
      )

      pg_backup.copy(from_app_name, to_app_name)
    end
  end
end
