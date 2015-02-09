require "pry"
require "./db/setup"
Dir["./lib/**/*.rb"].each { |path| require path }

binding.pry
