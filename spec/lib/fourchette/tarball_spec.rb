require 'spec_helper'

describe Fourchette::Tarball do
  subject { described_class.new }

  describe '#url' do
    let(:git_repo_url) { 'git://github.com/jipiboily/fourchette.git' }
    let(:github_repo) { 'jipiboily/fourchette' }
    let(:branch_name) { 'feature/something-new' }

    before do
      subject.stub(:expiration_timestamp).and_return('123')
      subject.stub(:clone)
      subject.stub(:tar).and_return('tmp/1234567/123.tar.gz')
      subject.stub(:system)
      stub_const('ENV', {'FOURCHETTE_APP_URL' => 'http://example.com'})
      SecureRandom.stub(:uuid).and_return('1234567')
    end

    it {
        expect(
            subject.url(git_repo_url, branch_name, github_repo)
          ).to eq "http://example.com/jipiboily/fourchette/1234567/123"
        }

    it 'clones the repo and checkout the branch' do
      subject.unstub(:clone)
      git_instance = double
      Git.should_receive(:clone).with(git_repo_url, "tmp/1234567", recursive: true).and_return(git_instance)
      git_instance.should_receive(:checkout).with(branch_name)
      subject.url(git_repo_url, branch_name, github_repo)
    end

    it 'creates the tarball' do
      subject.unstub(:tar)
      subject.should_receive(:system).with 'tar -zcf tmp/1234567/123.tar.gz -C tmp/1234567 .'
      subject.url(git_repo_url, branch_name, github_repo)
    end
  end

  describe '#filepath' do
    it { expect(subject.filepath('1234567', '123')).to eq 'tmp/1234567/123.tar.gz' }
  end
end