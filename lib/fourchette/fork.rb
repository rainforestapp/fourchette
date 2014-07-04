class Fourchette::Fork
  include Fourchette::Logger

  def initialize params
    @params = params
    @heroku = Fourchette::Heroku.new
    @github = Fourchette::GitHub.new
  end

  def update
    create_unless_exists
    tarball = Fourchette::Tarball.new
    tarball_url = tarball.url(github_git_url, git_branch_name, ENV['FOURCHETTE_GITHUB_PROJECT'])
    options = {
      source_blob: {
          url: tarball_url
        }
    }

    build = @heroku.client.build.create(fork_name, options)
    monitor_build(build)
  end

  def monitor_build build
    logger.info "Start of the build process on Heroku..."
    build_info = @heroku.client.build.info(fork_name, build['id'])
    # Let's just leave some time to Heroku to download the tarball and start
    # the process. This is some random timing that seems to make sense at first.
    sleep 30
    if build_info['status'] == 'failed'
      @github.comment_pr(pr_number, "The build failed on Heroku. See the activity tab on Heroku.")
      fail Fourchette::DeployException
    end
  end

  def create
    @github.comment_pr(pr_number, "Fourchette is initializing a new fork.") if Fourchette::DEBUG
    create_unless_exists
    update
  end

  def delete
    @heroku.delete(fork_name)
    @github.comment_pr(pr_number, "Test app deleted!")
  end

  def fork_name
    "#{ENV['FOURCHETTE_HEROKU_APP_PREFIX']}-PR-#{pr_number}".downcase # It needs to be lowercase only.
  end

  def branch_name
    @params['pull_request']['head']['ref']
  end

  def pr_number
    @params['pull_request']['number']
  end

  def create_unless_exists
    unless @heroku.app_exists?(fork_name)
      @heroku.fork(ENV['FOURCHETTE_HEROKU_APP_TO_FORK'] ,fork_name)
      post_fork_url
    end
  end

  private

  # Update PR with URL. This is a method so that we can override it and just not
  # have that, if we don't want. Use case: we have custom domains, so we post
  # the URLs later on.
  def post_fork_url
    @github.comment_pr(pr_number, "Test URL: #{@heroku.client.app.info(fork_name)['web_url']}")
  end

  def git_branch_name
    "remotes/origin/#{branch_name}"
  end

  def github_git_url
    @params['pull_request']['head']['repo']['clone_url'].gsub("//github.com", "//#{ENV['FOURCHETTE_GITHUB_USERNAME']}:#{ENV['FOURCHETTE_GITHUB_PERSONAL_TOKEN']}@github.com")
  end
end
