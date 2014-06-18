require 'spec_helper'

describe Fourchette::Heroku do
  let(:heroku) { Fourchette::Heroku.new }
  let(:from_app_name) { 'awesome app' }
  let(:to_app_name) { 'awesomer app!' }

  before do
    client = double('client')
    client_app = double('client')
    app_list = [ { 'name' => 'fourchette-pr-7' }, { 'name' => 'fourchette-pr-8' } ]
    client_app.stub(:list).and_return(app_list)
    client.stub(:app).and_return(client_app)

    config_var = double('config_var')
    client.stub(:config_var).and_return(config_var)

    client.app.stub(:info).and_return( { 'git_url' => 'git@heroku.com/something.git' } )

    heroku.stub(:client).and_return(client)
  end

  describe '#app_exists?' do
    it { expect(heroku.app_exists?('fourchette-pr-7')).to eq true }
    it { expect(heroku.app_exists?('fourchette-pr-8')).to eq true }
    it { expect(heroku.app_exists?('fourchette-pr-333')).to eq false }
  end

  describe '#fork' do
    before do
      heroku.stub(:create_app)
      heroku.stub(:copy_config)
      heroku.stub(:copy_add_ons)
      heroku.stub(:copy_pg)
      heroku.stub(:copy_RACK_AND_RAILS_ENV_again)
    end

    ['create_app', 'copy_config', 'copy_add_ons', 'copy_pg', 'copy_RACK_AND_RAILS_ENV_again'].each do |method_name|
      it "calls `#{method_name}'" do
        heroku.should_receive(method_name)
        heroku.fork(from_app_name, to_app_name)
      end
    end
  end

  describe '#git_url' do
    it { expect(heroku.git_url(to_app_name)).to eq 'git@heroku.com/something.git' }
  end

  describe '#delete' do
    it 'calls delete on the Heroku client' do
      heroku.client.app.should_receive(:delete).with(to_app_name)
      heroku.delete(to_app_name)
    end
  end

  describe '#config_vars' do
    it 'calls config_var.info on the Heroku client' do
      heroku.client.config_var.should_receive(:info).with(from_app_name)
      heroku.config_vars(from_app_name)
    end
  end

  describe '#create_app' do
    it 'calls app.create on the Heroku client' do
      heroku.client.app.should_receive(:create).with({ name: to_app_name })
      heroku.create_app(to_app_name)
    end
  end

  describe '#copy_config' do
    let(:vars) { { 'WHATEVER' => 'ok', 'HEROKU_POSTGRESQL_SOMETHING_URL' => 'FAIL@POSTGRES/DB' } }
    let(:cleaned_vars) { { 'WHATEVER' => 'ok'} }

    it 'calls #config_vars' do
      heroku.client.config_var.stub(:update)
      heroku.should_receive(:config_vars).with(from_app_name).and_return(vars)
      heroku.copy_config(from_app_name, to_app_name)
    end

    it 'updates config vars without postgres URLs' do
      heroku.client.config_var.should_receive(:update).with(to_app_name, cleaned_vars )
      heroku.stub(:config_vars).and_return(vars)
      heroku.copy_config('from', to_app_name)
    end
  end

  describe '#copy_add_ons' do
    let(:addon_list) { [ { 'plan' => { 'name' => 'redistogo' } } ] }

    before do
      heroku.client.stub(:addon).and_return( double('addon') )
      heroku.client.addon.stub(:create)
      heroku.client.addon.stub(:list).and_return(addon_list)
    end

    it 'gets the addon list' do
      heroku.client.addon.should_receive(:list).with(from_app_name).and_return(addon_list)
      heroku.copy_add_ons(from_app_name, to_app_name)
    end

    it 'creates addons' do
      heroku.client.addon.should_receive(:create).with(to_app_name, { plan: 'redistogo' })
      heroku.copy_add_ons(from_app_name, to_app_name)
    end
  end

  describe '#copy_pg' do
    it 'calls Fourchette::Pgbackups#copy' do
      Fourchette::Pgbackups.any_instance.should_receive(:copy).with(from_app_name, to_app_name)
      heroku.copy_pg(from_app_name, to_app_name)
    end
  end

  describe '#copy_RACK_AND_RAILS_ENV_again' do
    context 'with RACK_ENV or RAILS_ENV setup' do
      before do
        heroku.stub(:get_original_env).and_return({ 'RACK_ENV' => 'qa' })
      end

      it 'updates the config vars' do
        heroku.client.config_var.should_receive(:update).with(to_app_name,  { 'RACK_ENV' => 'qa' })
        heroku.copy_RACK_AND_RAILS_ENV_again(from_app_name, to_app_name)
      end
    end

    context 'with NO env setup' do
      before do
        heroku.stub(:get_original_env).and_return({})
      end

      it 'does not update config vars' do
        heroku.client.config_var.should_not_receive(:update)
        heroku.copy_RACK_AND_RAILS_ENV_again(from_app_name, to_app_name)
      end
    end
  end

  describe '#get_original_env' do
    before do
      stub_cong_var = { 'RACK_ENV' => 'qa', 'RAILS_ENV' => 'staging', 'DATABASE_URL' => 'postgres://....' }
      heroku.stub_chain(:client, :config_var, :info).and_return(stub_cong_var)
    end

    it 'returns the set env vars' do
      return_value = heroku.get_original_env(from_app_name)
      expect(return_value).to eq({'RACK_ENV' => 'qa', 'RAILS_ENV' => 'staging'})
    end
  end
end