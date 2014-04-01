require 'fourchette'

namespace :fourchette do
  desc 'This enables Fourchette hook'
  task :enable do
    Fourchette::GitHub.new.enable_hook
  end

  desc 'This disables Fourchette hook'
  task :disable do
    Fourchette::GitHub.new.disable_hook
  end

  desc 'This updates the Fourchette hook with the current URL of the app'
  task :update do
    Fourchette::GitHub.new.update_hook
  end

  desc 'This deletes the Fourchette hook'
  task :delete do
    Fourchette::GitHub.new.delete_hook
  end
end
