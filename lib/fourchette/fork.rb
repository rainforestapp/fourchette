class Fourchette::Fork
  include Fourchette::Logger

  def initialize params
    @params = params
    @heroku = Fourchette::Heroku.new
  end

  def update
    create_unless_exists

    heroku_git_url = @heroku.git_url(fork_name)

    FileUtils.rm_rf('tmp/')

    # Add key to current
    logger.info "Creating an SSH key"
    key_path = "~/.ssh/id_rsa-fourchette"
    public_key_path = "#{key_path}.pub"
    `ssh-keygen -t rsa -C "temporary@fourchetteapp" -N "" -f #{key_path} -q`
    public_key_content = `cat #{public_key_path}`

    # Create SSH config file, so that it uses the right SSH key
    ssh_config_path = "~/.ssh/config"
    if `cat #{ssh_config_path}`.length == 0
      # Set the SSH key used, and disable strict host key checking
      `echo "Host heroku.com\n IdentityFile #{key_path}\n StrictHostKeyChecking no" >> ~/.ssh/config`
    end

    # Add SSH key to the Heroku account
    logger.info "Adding the SSH key to your Heroku account"
    heroku_public_key = @heroku.client.key.create(public_key: public_key_content)

    # Clone & push
    logger.info "Cloning repository..."
    repo = Git.clone(github_git_url, 'tmp')
    repo.checkout(branch_name)

    # TODO - HACK ALERT - Next couple lines are really hacky, and used
    # instead of calling `git push heroku my_branch_name:master`
    repo.branch('master').delete
    begin
      repo.branch('master').merge(branch_name)
    rescue Git::GitExecuteError
      # TODO - HACK ALERT! There is certainly a cleaner way to do this...
    end
    repo.add_remote('heroku', heroku_git_url)

    logger.info "Pushing to Heroku..."
    repo.push(repo.remote('heroku'))
    logger.info "Done pushing to Heroku, apparently!"

    # REMOVE key to the Heroku account
    logger.info "Removing SSH key from your Heroku account"
    @heroku.client.key.delete(heroku_public_key['id'])

    # Remove ssh key
    logger.info "Removing SSH key for file system"
    FileUtils.rm_rf("~./ssh/id_rsa-fourchette*")
  end

  def create
    github.comment_pr(pr_number, "Fourchette is initializing a new fork.")
    create_unless_exists
    update
  end

  def delete
    @heroku.delete(fork_name)

    # Update PR with URL
    github.comment_pr(pr_number, "Test app deleted!")
  end

  private
  def github
    Fourchette::GitHub.new
  end

  def create_unless_exists
    unless @heroku.app_exists?(fork_name)
      @heroku.fork(ENV['FOURCHETTE_HEROKU_APP_TO_FORK'] ,fork_name)
      # Update PR with URL
      github.comment_pr(pr_number, "Test URL: #{@heroku.client.app.info(fork_name)['web_url']}")
    end
  end

  def fork_name
    "#{ENV['FOURCHETTE_HEROKU_APP_PREFIX']}-PR-#{pr_number}".downcase # It needs to be lowercase only.
  end

  def github_git_url
    @params['pull_request']['head']['repo']['clone_url'].gsub("//github.com", "//#{ENV['FOURCHETTE_GITHUB_USERNAME']}:#{ENV['FOURCHETTE_GITHUB_PERSONAL_TOKEN']}@github.com")
  end

  def branch_name
    @branch_name ||= "remotes/origin/#{@params['pull_request']['head']['ref']}"
  end

  def pr_number
    @pr_number ||= @params['pull_request']['number']
  end
end
