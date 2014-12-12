require 'spec_helper'
require 'support/sinatra_helper'
require 'sucker_punch/testing/inline'

describe 'GitHub web hooks receiver' do
  it 'kicks an async job doing all the work' do
    expected_param = { 'something' => 'ok' }
    expect_any_instance_of(Fourchette::PullRequest)
      .to receive(:perform)
      .with(expected_param)

    post '/hooks',
         expected_param.to_json,
         'CONTENT_TYPE' => 'application/json'
  end
end
