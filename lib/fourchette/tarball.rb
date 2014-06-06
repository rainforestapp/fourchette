require 'securerandom'
class Fourchette::Tarball
  include Fourchette::Logger

  def url(github_git_url, branch_name, github_repo)
    filepath = prepare_tarball(github_git_url, branch_name)
    tarball_to_url(filepath, github_repo)
  end

  private
  def prepare_tarball(github_git_url, branch_name)
    clone_path = "tmp/#{SecureRandom.uuid}"
    clone(github_git_url, branch_name, clone_path)
    tar(clone_path)
  end

  def clone(github_git_url,branch_name, clone_path)
    logger.info "Cloning repository..."
    repo = Git.clone(github_git_url, clone_path)
    repo.checkout(branch_name)
  end

  def tar(path)
    logger.info "Preparing tarball..."
    filepath = "#{path}/#{expiration_timestamp}.tar.gz"
    system("tar -zcvf #{filepath} #{path}")
    filepath
  end

  def expiration_timestamp
    Time.now.to_i + 300
  end

  def tarball_to_url(filepath, github_repo)
    logger.info "Tarball to URL as a service in progress..."
    cleaned_path = filepath.gsub('tmp/', '').gsub('.tar.gz', '')
    "#{ENV['FOURCHETTE_APP_URL']}/#{github_repo}/#{cleaned_path}"
  end
end