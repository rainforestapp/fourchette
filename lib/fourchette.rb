require 'fourchette/version'
require 'sinatra'
require 'json'
require 'platform-api'
require 'octokit'
require 'git'
require 'sucker_punch'
require 'rest-client'

def attempt_pry
  require 'pry'
rescue LoadError => ex
  puts "Oops: #{ex}"
end

# TODO: Extract this to development.rb and production.rb
if development?
  require 'sinatra/reloader'
  attempt_pry

  FOURCHETTE_CONFIG = {
    env_name: 'fourchette-dev'
  }
else
  FOURCHETTE_CONFIG = {
    env_name: 'fourchette'
  }
end

module Fourchette
  DEBUG = ENV['DEBUG'] ? true : false

  class DeployException < StandardError; end
end

require_relative 'fourchette/logger'
require_relative 'fourchette/web'
require_relative 'fourchette/github'
require_relative 'fourchette/pull_request'
require_relative 'fourchette/fork'
require_relative 'fourchette/heroku'
require_relative 'fourchette/pgbackups'
require_relative 'fourchette/callbacks'
require_relative 'fourchette/tarball'
