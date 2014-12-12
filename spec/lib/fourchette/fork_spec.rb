require 'spec_helper'

describe Fourchette::Fork do
  subject { described_class.new(params) }

  let(:params) do
    {
      'pull_request' => {
        'number' => 1,
        'head' => {
          'ref' => '123456'
        }
      }
    }
  end
  let(:fork_name) { 'my-fork-pr-1' }

  before do
    stub_const(
      'ENV',
      'FOURCHETTE_HEROKU_APP_PREFIX' => 'my-fork',
      'FOURCHETTE_HEROKU_APP_TO_FORK' => 'my-heroku-app-name'
    )
  end

  describe '#create' do
    it 'calls #update and #create_unless_exists' do
      expect(subject).to receive(:create_unless_exists)
      expect(subject).to receive(:update)
      subject.create
    end
  end

  describe '#create_unless_exists' do
    after do
      subject.create_unless_exists
    end

    context 'app does NOT exists' do
      before do
        allow_any_instance_of(Fourchette::Heroku).to receive(:app_exists?).and_return(false)
      end

      it 'calls the fork creation' do
        allow(subject).to receive(:post_fork_url)
        expect_any_instance_of(Fourchette::Heroku).to receive(:fork)
          .with('my-heroku-app-name', fork_name)
      end

      it 'post the URL to the fork on the GitHub PR' do
        allow_any_instance_of(Fourchette::Heroku).to receive(:fork)
        allow_any_instance_of(Fourchette::Heroku).to receive_message_chain(:client, :app, :info)
          .and_return('web_url' => 'rainforestqa.com')
        expect_any_instance_of(Fourchette::GitHub).to receive(:comment_pr)
          .with(1, 'Test URL: rainforestqa.com')
      end
    end

    context 'app DOES exists' do
      before do
        allow_any_instance_of(Fourchette::Heroku).to receive(:app_exists?).and_return(true)
      end

      it 'does nothing' do
        expect_any_instance_of(Fourchette::GitHub).not_to receive(:comment_pr)
        expect_any_instance_of(Fourchette::Heroku).not_to receive(:fork)
      end
    end
  end

  describe '#delete' do
    it 'calls deletes the fork' do
      allow_any_instance_of(Fourchette::GitHub).to receive(:comment_pr)
      expect_any_instance_of(Fourchette::Heroku).to receive(:delete).with(fork_name)
      subject.delete
    end

    it 'comments on the GitHub PR' do
      allow_any_instance_of(Fourchette::Heroku).to receive(:delete)
      expect_any_instance_of(Fourchette::GitHub).to receive(:comment_pr)
        .with(1, 'Test app deleted!')
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
