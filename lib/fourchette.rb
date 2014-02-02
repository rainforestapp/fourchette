require 'sinatra'
require 'json'
require 'cgi' # Required for Heroics
require 'heroics'
require 'octokit'
require 'git'
require 'sucker_punch'

# TODO: Extract this to development.rb and production.rb
if development?
  require "sinatra/reloader"
  require "pry"
  FOURCHETTE_CONFIG = {
    env_name: 'fourchette-dev'
  }
else
  FOURCHETTE_CONFIG = {
    env_name: 'fourchette'
  }
end


module Fourchette
end

require_relative 'fourchette/logger'
require_relative 'fourchette/web'
require_relative 'fourchette/github'
require_relative 'fourchette/pull_request'
require_relative 'fourchette/fork'
require_relative 'fourchette/heroku'
require_relative 'fourchette/pgbackups'