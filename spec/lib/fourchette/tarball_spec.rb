require 'spec_helper'

describe Fourchette::Tarball do
  subject { described_class.new }

  describe '#url' do
    let(:git_repo_url) { 'git://github.com/jipiboily/fourchette.git' }
    let(:github_repo) { 'jipiboily/fourchette' }
    let(:branch_name) { 'feature/something-new' }

    before do
      allow(subject).to receive(:expiration_timestamp).and_return('123')
      allow(subject).to receive(:clone)
      allow(subject).to receive(:tar).and_return('tmp/1234567/123.tar.gz')
      allow(subject).to receive(:system)
      stub_const('ENV', 'FOURCHETTE_APP_URL' => 'http://example.com')
      allow(SecureRandom).to receive(:uuid).and_return('1234567')
    end

    it do
      expect(
          subject.url(git_repo_url, branch_name, github_repo)
        ).to eq 'http://example.com/jipiboily/fourchette/1234567/123'
    end

    it 'clones the repo and checkout the branch' do
      allow(subject).to receive(:clone).and_call_original
      git_instance = double
      expect(Git).to receive(:clone).with(
        git_repo_url, 'tmp/1234567', recursive: true
      ).and_return(git_instance)
      expect(git_instance).to receive(:checkout).with(branch_name)
      subject.url(git_repo_url, branch_name, github_repo)
    end

    it 'creates the tarball' do
      allow(subject).to receive(:tar).and_call_original
      expect(subject).to receive(:system).with(
        'tar --ignore-failed-read -zcf tmp/1234567/123.tar.gz -C tmp/1234567 .'
      )
      subject.url(git_repo_url, branch_name, github_repo)
    end
  end

  describe '#filepath' do
    it 'should return the correct filepath' do
      expect(subject.filepath('1234567', '123')).to eq 'tmp/1234567/123.tar.gz'
    end
  end
end
