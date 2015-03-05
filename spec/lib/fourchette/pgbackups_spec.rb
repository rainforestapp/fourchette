require 'spec_helper'

describe Fourchette::Pgbackups do
  describe '#copy' do
    let(:from_app_name) { 'awesome app' }
    let(:to_app_name) { 'awesomer app!' }
    let(:pg_backup) { Fourchette::Pgbackups.new }
    let(:heroku) { instance_double(Fourchette::Heroku) }

    let(:config_vars_from) do
      { 'HEROKU_POSTGRESQL_FROM_URL' => 'postgres://from...',
        'PGBACKUPS_URL' => 'postgres://frombackup...' }
    end

    let(:config_vars_to) do
      { 'HEROKU_POSTGRESQL_TO_URL' => 'postgres://to...',
        'PGBACKUPS_URL' => 'postgres://tobackup...' }
    end

    before do
      allow(Fourchette::Heroku).to receive(:new).and_return(heroku)

      allow(heroku)
        .to receive_message_chain(:client, :addon, :list)
        .and_return([{ 'name' => addon_name }])

      allow(heroku)
        .to receive(:config_vars)
        .with(from_app_name)
        .and_return(config_vars_from)

      allow(heroku)
        .to receive(:config_vars)
        .with(to_app_name)
        .and_return(config_vars_to)
    end

    context 'when Pgbackups addon is enabled' do
      let(:addon_name) { 'pgbackups' }
      let(:backup) { instance_double(Heroku::Client::Pgbackups) }

      it 'launches a PG backup from origin app to destination one' do
        expect(Heroku::Client::Pgbackups)
          .to receive(:new)
          .with(config_vars_from['PGBACKUPS_URL'] + '/api')
          .and_return(backup)

        expect(backup).to receive(:create_transfer).with(
          config_vars_from['HEROKU_POSTGRESQL_FROM_URL'],
          'HEROKU_POSTGRESQL_FROM_URL',
          config_vars_to['HEROKU_POSTGRESQL_TO_URL'],
          'HEROKU_POSTGRESQL_TO_URL'
        )

        pg_backup.copy(from_app_name, to_app_name)
      end
    end

    context 'when Pgbackups addon is not enabled' do
      let(:addon_name) { 'addon' }

      it 'enables Pgbackups addon and launches a PG backup' do
        expect(heroku)
          .to receive_message_chain(:client, :addon, :create)
          .with(to_app_name, { plan: 'pgbackups' })

        expect(heroku)
          .to receive_message_chain(:client, :addon, :create)
          .with(from_app_name, { plan: 'pgbackups' })

        expect(Heroku::Client::Pgbackups)
          .to receive_message_chain(:new, :create_transfer)

        pg_backup.copy(from_app_name, to_app_name)
      end
    end
  end
end
