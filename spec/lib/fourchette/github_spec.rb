require "spec_helper"

describe Fourchette::GitHub do
  subject { described_class.new }

  let(:fake_hooks) { [] }

  let(:fake_hook) do
    hook = double('hook')
    hook.stub(:config).and_return(nil)
    hook.stub(:id).and_return(123)
    hook
  end

  let(:fake_fourchette_hook) do
    fake_hook.config.stub(:fourchette_env).and_return('something')
    fake_hook
  end

  let(:fake_enabled_fourchette_hook) do
    fake_fourchette_hook.stub(:active).and_return(true)
    fake_fourchette_hook
  end

  let(:fake_disabled_fourchette_hook) do
    fake_fourchette_hook.stub(:active).and_return(false)
    fake_fourchette_hook
  end

  before do
    allow_message_expectations_on_nil
    subject
      .stub(:hooks).and_return(fake_hooks)
    Octokit::Client.any_instance
      .stub(:edit_hook)
  end

  describe "#enable_hook" do
    context "when there is alerady a Fourchette hook" do

      context "when the hook was enabled" do
        let(:fake_hooks) { [ fake_enabled_fourchette_hook ] }

        it "does NOT enable the hook" do
          Octokit::Client
            .any_instance
            .should_not_receive(:edit_hook)

          subject.enable_hook
        end
      end

      context "when the hook was disabled" do
        let(:fake_hooks) { [ fake_disabled_fourchette_hook ] }

        it "enables the hook" do
          Octokit::Client
            .any_instance
            .should_receive(:edit_hook)

          subject.enable_hook
        end
      end
    end

    context "when there is no Fourchette hook yet" do
      it "adds a hook" do
        Octokit::Client
          .any_instance
          .should_receive(:create_hook)

        subject.enable_hook
      end
    end
  end

  describe "#disable_hook" do
    context "where there is an active Fourchette hook" do
      let(:fake_hooks) { [ fake_enabled_fourchette_hook ] }

      it "disables the hook" do
        Octokit::Client
          .any_instance
          .should_receive(:edit_hook)

        subject.disable_hook
      end
    end

    context "when there is a disabled Fourchette hook" do
      let(:fake_hooks) { [ fake_disabled_fourchette_hook ] }
      it "does not try to disable a hook" do
        subject.should_not_receive(:disable)
        subject.disable_hook
      end
    end

    context "when there is no Fourchette hook" do
      it "does not try to disable a hook" do
        subject.should_not_receive(:disable)
        subject.disable_hook
      end
    end
  end

  describe "#update_hook" do
    let(:fake_hooks) { [ fake_enabled_fourchette_hook ] }

    it "calls toggle_active_state_to" do
      subject
        .should_receive(:toggle_active_state_to)
      subject.update_hook
    end
  end

  describe "#delete_hook" do
    it "deletes the hook on GitHub" do
      subject.stub(:fourchette_hook).and_return(fake_hook)
      Octokit::Client
        .any_instance
        .should_receive(:remove_hook)

      subject.delete_hook
    end
  end

  describe "#comment_pr" do
    before do
      stub_const('ENV', {
          'FOURCHETTE_GITHUB_PROJECT' => 'my-project'
          })
    end

    it "adds a comment" do
      Octokit::Client
        .any_instance
        .should_receive(:add_comment)
        .with('my-project', 1, 'yo!')

      subject.comment_pr(1, 'yo!')
    end
  end
end
