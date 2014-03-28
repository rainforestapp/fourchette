require './lib/fourchette'

begin
  require 'rspec/core/rake_task'
  # Set default Rake task to spec
  RSpec::Core::RakeTask.new(:spec)
  task :default => :spec
rescue LoadError => ex
  # That's ok, it just means we don't have RSpec loaded
end


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

  desc 'Brings up a REPL with the code loaded'
  task :console do
    require './lib/fourchette'
    Pry.start
  end
end
