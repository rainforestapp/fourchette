require 'spec_helper'

describe Fourchette::Heroku do
  let(:heroku) { Fourchette::Heroku.new }
  let(:from_app_name) { 'awesome app' }
  let(:to_app_name) { 'awesomer app!' }
  let(:app_list) do
    [
      { 'name' => 'fourchette-pr-7' },
      { 'name' => 'fourchette-pr-8' }
    ]
  end

  before do
    client = double('client')
    client_app = double('client')
    allow(client_app).to receive(:list).and_return(app_list)
    allow(client).to receive(:app).and_return(client_app)
    config_var = double('config_var')
    allow(client).to receive(:config_var).and_return(config_var)

    allow(client.app).to receive(:info).and_return(
      'git_url' => 'git@heroku.com/something.git'
    )

    allow(heroku).to receive(:client).and_return(client)
  end

  describe '#app_exists?' do
    it { expect(heroku.app_exists?('fourchette-pr-7')).to eq true }
    it { expect(heroku.app_exists?('fourchette-pr-8')).to eq true }
    it { expect(heroku.app_exists?('fourchette-pr-333')).to eq false }
  end

  describe '#fork' do
    before do
      allow(heroku).to receive(:create_app)
      allow(heroku).to receive(:copy_config)
      allow(heroku).to receive(:copy_add_ons)
      allow(heroku).to receive(:copy_pg)
      allow(heroku).to receive(:copy_rack_and_rails_env_again)
    end

    %w(
      create_app copy_config copy_add_ons copy_pg copy_rack_and_rails_env_again
    ).each do |method_name|
      it "calls `#{method_name}'" do
        expect(heroku).to receive(method_name)
        heroku.fork(from_app_name, to_app_name)
      end
    end
  end

  describe '#git_url' do
    it 'returns the correct git URL' do
      expect(heroku.git_url(to_app_name)).to eq 'git@heroku.com/something.git'
    end
  end

  describe '#delete' do
    it 'calls delete on the Heroku client' do
      expect(heroku.client.app).to receive(:delete).with(to_app_name)
      heroku.delete(to_app_name)
    end
  end

  describe '#config_vars' do
    it 'calls config_var.info on the Heroku client' do
      expect(heroku.client.config_var).to receive(:info).with(from_app_name)
      heroku.config_vars(from_app_name)
    end
  end

  describe '#create_app' do
    it 'calls app.create on the Heroku client' do
      expect(heroku.client.app).to receive(:create).with(name: to_app_name)
      heroku.create_app(to_app_name)
    end
  end

  describe '#copy_config' do
    let(:vars) do
      {
        'WHATEVER' => 'ok',
        'HEROKU_POSTGRESQL_SOMETHING_URL' => 'FAIL@POSTGRES/DB',
        'DATABASE_URL' => 'FAIL@POSTGRES/DB'
      }
    end
    let(:cleaned_vars) { { 'WHATEVER' => 'ok' } }

    it 'calls #config_vars' do
      allow(heroku.client.config_var).to receive(:update)
      expect(heroku).to receive(:config_vars).with(from_app_name).and_return(vars)
      heroku.copy_config(from_app_name, to_app_name)
    end

    it 'updates config vars without postgres URLs' do
      expect(heroku.client.config_var).to receive(:update)
        .with(to_app_name, cleaned_vars)
      allow(heroku).to receive(:config_vars).and_return(vars)
      heroku.copy_config('from', to_app_name)
    end
  end

  describe '#copy_add_ons' do
    let(:addon_list) { [{ 'plan' => { 'name' => 'redistogo' } }] }

    before do
      allow(heroku.client).to receive(:addon).and_return(double('addon'))
      allow(heroku.client.addon).to receive(:create)
      allow(heroku.client.addon).to receive(:list).and_return(addon_list)
    end

    it 'gets the addon list' do
      expect(heroku.client.addon).to receive(:list).with(from_app_name)
        .and_return(addon_list)
      heroku.copy_add_ons(from_app_name, to_app_name)
    end

    it 'creates addons' do
      expect(heroku.client.addon).to receive(:create).with(
        to_app_name,  plan: 'redistogo'
      )
      heroku.copy_add_ons(from_app_name, to_app_name)
    end
  end

  describe '#copy_pg' do

    before do
      allow(heroku.client).to receive(:addon).and_return(double('addon'))
      allow(heroku.client.addon).to receive(:list).and_return(addon_list)
    end

    context 'when a heroku-postgresql addon is enabled' do
      let(:addon_list) { [{ 'addon_service' => { 'name' => addon_name } }] }

      shared_examples 'app with pg' do
        it 'calls Fourchette::Pgbackups#copy' do
          expect_any_instance_of(Fourchette::Pgbackups).to receive(:copy).with(
            from_app_name, to_app_name
          )
          heroku.copy_pg(from_app_name, to_app_name)
        end
      end

      context "when the addon name is 'Heroku Postgres'" do
        let(:addon_name) { 'Heroku Postgres' }

        it_behaves_like 'app with pg'
      end

      context "when the addon name is 'heroku-postgresql'" do
        let(:addon_name) { 'heroku-postgresql' }

        it_behaves_like 'app with pg'
      end
    end

    context 'when a heroku-postgresql addon is not enabled' do
      let(:addon_list) { [{ 'addon_service' => { 'name' => 'redistogo' } }] }

      it 'does not call Fourchette::Pgbackups#copy' do
        # Had to work around lack of support for any_instance and
        # should_not_receive
        # See https://github.com/rspec/rspec-mocks/issues/164 for more details
        count = 0
        allow_any_instance_of(Fourchette::Pgbackups).to receive(:copy) do |_from_app_name, _to_app_name|
            count += 1
          end
        heroku.copy_pg(from_app_name, to_app_name)
        expect(count).to eq(0)
      end
    end
  end

  describe '#copy_rack_and_rails_env_again' do
    context 'with RACK_ENV or RAILS_ENV setup' do
      before do
        allow(heroku).to receive(:get_original_env).and_return('RACK_ENV' => 'qa')
      end

      it 'updates the config vars' do
        expect(heroku.client.config_var).to receive(:update).with(
          to_app_name, 'RACK_ENV' => 'qa'
        )
        heroku.copy_rack_and_rails_env_again(from_app_name, to_app_name)
      end
    end

    context 'with NO env setup' do
      before do
        allow(heroku).to receive(:get_original_env).and_return({})
      end

      it 'does not update config vars' do
        expect(heroku.client.config_var).not_to receive(:update)
        heroku.copy_rack_and_rails_env_again(from_app_name, to_app_name)
      end
    end
  end

  describe '#get_original_env' do
    before do
      stub_cong_var = {
        'RACK_ENV' => 'qa',
        'RAILS_ENV' => 'staging',
        'DATABASE_URL' => 'postgres://....'
      }
      allow(heroku).to receive_message_chain(:client, :config_var, :info).and_return(stub_cong_var)
    end

    it 'returns the set env vars' do
      return_value = heroku.get_original_env(from_app_name)
      expect(return_value).to eq('RACK_ENV' => 'qa', 'RAILS_ENV' => 'staging')
    end
  end
end
