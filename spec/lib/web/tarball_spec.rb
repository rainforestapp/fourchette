require 'spec_helper'
require 'support/sinatra_helper'

describe 'web tarball serving' do
  context 'valid and not expired URL' do
    it 'returns the file' do
      expire_in_2_secs = Time.now.to_i + 2
      Fourchette::Tarball.any_instance
        .should_receive(:filepath)
        .with('1234567', expire_in_2_secs.to_s)
        .and_return { "#{Dir.pwd}/spec/factories/fake_file" }

      get "/jipiboily/fourchette/1234567/#{expire_in_2_secs}"
      expect(last_response.headers['Content-Type']).to eq 'application/x-tgz'
      expect(last_response.body).to eq 'some content...'
    end
  end

  context 'expired URL' do
    it 'does NOT returns the file if it is expired' do
      expired_one_sec_ago = Time.now.to_i - 1
      get "/jipiboily/fourchette/1234567/#{expired_one_sec_ago}"
      expect(last_response).not_to be_ok
      expect(last_response.body).not_to eq('Hello World')
      expect(last_response.status).to eq(404)
      subject.should_not_receive(:send_file)
    end
  end
end
