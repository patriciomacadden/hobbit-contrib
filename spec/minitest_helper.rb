ENV['RACK_ENV'] ||= 'test'

require 'bundler'
Bundler.require :default, ENV['RACK_ENV'].to_sym

require 'minitest/autorun'
require 'rack'
require 'rack/test'

require 'hobbit'
require 'hobbit/contrib'

# hobbit test apps
require 'fixtures/test_asset_tag_app/test_asset_tag_app'
require 'fixtures/test_enhanced_render_app/test_enhanced_render_app'
require 'fixtures/test_environment_app/test_environment_app'