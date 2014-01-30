require './lib/fourchette'

desc 'This enables Fourchette hook for the app it is configured'
task :enable do
  Fourchette::GitHub.new.enable_hook
end

desc 'This disables Fourchette hook for the app it is configured'
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