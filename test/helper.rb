require 'bundler/setup'

require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

ENV['RACK_ENV'] ||= 'test'

require 'oktobertest'
require 'oktobertest/contrib'
require 'rack'
require 'rack/test'

require 'hobbit'
require 'hobbit/contrib'

module Oktobertest
  class Test
    include Rack::Test::Methods

    def mock_app(&block)
      @app = Class.new(Hobbit::Base, &block).new
    end

    def app
      @app
    end
  end
end
