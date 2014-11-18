get '/:github_user/:github_repo/:uuid/:expiration_timestamp' do
  if params['expiration_timestamp'].to_i < Time.now.to_i
    status 404
    'Oops...'
  else
    logger.info('Serving a tarball!')
    filepath = Fourchette::Tarball.new.filepath(
      params['uuid'],
      params['expiration_timestamp']
    )
    send_file filepath, type: 'application/x-tgz'
  end
end
