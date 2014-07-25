require 'spec_helper'
require 'support/sinatra_helper'
require 'sucker_punch/testing/inline'

describe 'GitHub web hooks receiver' do
  it 'kicks an async job doing all the work' do
    expected_param = { 'something' => 'ok' }
    Fourchette::PullRequest.any_instance
      .should_receive(:perform)
      .with(expected_param)

    post '/hooks', expected_param.to_json, { "CONTENT_TYPE" => "application/json" }
  end
end
