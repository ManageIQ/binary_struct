if ENV['CI']
  require 'simplecov'
  SimpleCov.start
end

RSpec.configure do |config|
end

require 'binary_struct'
