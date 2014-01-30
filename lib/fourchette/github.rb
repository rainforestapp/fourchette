require 'octokit'

class Fourchette::GitHub
  def enable_hook
    puts 'Enabling the hooks for your app...'
    if fourchette_hook
      enable(fourchette_hook)
    else
      create_hook
    end
  end

  def disable_hook
    puts 'Disabling the hook for your app...'
    if fourchette_hook && fourchette_hook.active == true
      disable(fourchette_hook)
    else
      puts 'Nothing to disable, move along!'
    end
  end

  def update_hook
    puts 'Updating the hook for your app...'
    toggle_active_state_to fourchette_hook, fourchette_hook.active
  end

  def delete_hook
    puts 'Removing the hook for your app...'
    octokit.remove_hook(ENV['FOURCHETTE_GITHUB_PROJECT'], fourchette_hook.id)
  end

  private
  def octokit
    @octokit_client ||= Octokit::Client.new(login: ENV['FOURCHETTE_GITHUB_USERNAME'], password: ENV['FOURCHETTE_GITHUB_PERSONAL_TOKEN'])
  end

  def create_hook
    puts 'Creating a new hook...'
    octokit.create_hook(
      ENV['FOURCHETTE_GITHUB_PROJECT'],
      'web',
      {
        url: "#{ENV['FOURCHETTE_APP_URL']}/hooks",
        content_type: 'json',
        fourchette_env: FOURCHETTE_CONFIG[:env_name]
      },
      {
        :events => ['push', 'pull_request'],
        :active => true
      }
    )
  end

  def hooks
    octokit.hooks(ENV['FOURCHETTE_GITHUB_PROJECT'])
  end

  def fourchette_hook
    existing_hook = nil

    hooks.each do |hook|
      existing_hook = hook unless hook.config.fourchette_env.nil?
    end

    existing_hook
  end

  def enable(hook)
    if hook.active
      puts 'The hook is already active, dude!'
    else
      toggle_active_state_to hook, true
    end
  end

  def disable(hook)
    toggle_active_state_to hook, false
  end

  def toggle_active_state_to hook, active_value
    octokit.edit_hook(
      ENV['FOURCHETTE_GITHUB_PROJECT'],
      hook.id,
      'web',
      {
        url: "#{ENV['FOURCHETTE_APP_URL']}/hooks",
        content_type: 'json',
        fourchette_env: FOURCHETTE_CONFIG[:env_name]
      },
      {
        :events => ['push', 'pull_request'],
        :active => active_value
      }
    )
  end
end