require 'spec_helper'

describe Fourchette::Fork do
  subject { described_class.new(params) }

  let(:params) {
    {
      'pull_request' => {
        'number' => 1,
        'head' => {
          'ref' => '123456'
        }
      }
    }
  }
  let(:fork_name) { 'my-fork-pr-1' }

  before do
    stub_const('ENV', {
        'FOURCHETTE_HEROKU_APP_PREFIX' => 'my-fork',
        'FOURCHETTE_HEROKU_APP_TO_FORK' => 'my-heroku-app-name'
        })
  end

  describe '#create' do
    it 'calls #update and #create_unless_exists' do
      subject.should_receive(:create_unless_exists)
      subject.should_receive(:update)
      subject.create
    end
  end

  describe '#create_unless_exists' do
    after do
      subject.create_unless_exists
    end

    context 'app does NOT exists' do
      before do
        Fourchette::Heroku.any_instance.stub(:app_exists?).and_return(false)
      end

      it 'calls the fork creation' do
        subject.stub(:post_fork_url)
        Fourchette::Heroku.any_instance.should_receive(:fork).with('my-heroku-app-name', fork_name)
      end

      it 'post the URL to the fork on the GitHub PR' do
        Fourchette::Heroku.any_instance.stub(:fork)
        Fourchette::Heroku.any_instance.stub_chain(:client, :app, :info).and_return({'web_url' => 'rainforestqa.com'})
        Fourchette::GitHub.any_instance.should_receive(:comment_pr).with(1, 'Test URL: rainforestqa.com')
      end
    end

    context 'app DOES exists' do
      before do
        Fourchette::Heroku.any_instance.stub(:app_exists?).and_return(true)
      end

      it 'does nothing' do
        Fourchette::GitHub.any_instance.should_not_receive(:comment_pr)
        Fourchette::Heroku.any_instance.should_not_receive(:fork)
      end
    end
  end

  describe '#delete' do
    it 'calls deletes the fork' do
      Fourchette::GitHub.any_instance.stub(:comment_pr)
      Fourchette::Heroku.any_instance.should_receive(:delete).with(fork_name)
      subject.delete
    end

    it 'comments on the GitHub PR' do
      Fourchette::Heroku.any_instance.stub(:delete)
      Fourchette::GitHub.any_instance.should_receive(:comment_pr).with(1, 'Test app deleted!')
      subject.delete
    end
  end

  describe '#fork_name' do
    it { expect(subject.fork_name).to eq fork_name }
  end

  describe '#branch_name' do
    it { expect(subject.branch_name).to eq '123456' }
  end

  describe '#pr_number' do
    it { expect(subject.pr_number).to eq 1 }
  end
end