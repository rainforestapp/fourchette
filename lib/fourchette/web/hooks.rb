post '/hooks' do
  params = JSON.parse(request.env["rack.input"].read)
  pr = Fourchette::PullRequest.new(params)
  pr.perform
  "Got it, thanks!"
end