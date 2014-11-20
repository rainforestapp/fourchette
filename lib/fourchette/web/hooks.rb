post '/hooks' do
  params = JSON.parse(request.env['rack.input'].read)
  Fourchette::PullRequest.new.async.perform(params)
  'Got it, thanks!'
end
