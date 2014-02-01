require 'sinatra'
require 'octokit'
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

require_relative 'fourchette/web'

module Fourchette
end

require_relative 'fourchette/github'