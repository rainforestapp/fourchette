require 'rubygems'
require_relative '../lib/fourchette'

support_include_path = "#{Dir.pwd}/spec/support/**/*.rb"
Dir[support_include_path].each {|f| require f}