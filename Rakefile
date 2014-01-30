require './lib/fourchette'

desc 'This enables Fourchette hooks for the app it is configured'
task :enable do
  Fourchette::GitHub.new.enable_hook
end

desc 'This disables Fourchette hooks for the app it is configured'
task :disable do
  Fourchette::GitHub.new.disable_hook
end