require 'minitest_helper'

describe Hobbit::Environment do
  include Hobbit::Contrib::Mock

  let(:app) do
    mock_app do
      include Hobbit::Environment
    end
  end

  describe '#environment' do
    it 'must return the current environment' do
      env, ENV['RACK_ENV'] = ENV['RACK_ENV'], 'development'
      app.to_app.environment.must_equal :development
      ENV['RACK_ENV'] = env
    end
  end

  describe '#development?' do
    it "must return true if ENV['RACK_ENV'] = :development" do
      env, ENV['RACK_ENV'] = ENV['RACK_ENV'], 'development'
      app.to_app.development?.must_equal true
      ENV['RACK_ENV'] = env
    end

    it "must return false if ENV['RACK_ENV'] != :development" do
      app.to_app.development?.must_equal false
    end
  end

  describe '#production?' do
    it "must return true if ENV['RACK_ENV'] = :production" do
      env, ENV['RACK_ENV'] = ENV['RACK_ENV'], 'production'
      app.to_app.production?.must_equal true
      ENV['RACK_ENV'] = env
    end

    it "must return false if ENV['RACK_ENV'] != :production" do
      app.to_app.production?.must_equal false
    end
  end

  describe '#test?' do
    it "must return true if ENV['RACK_ENV'] = :test" do
      app.to_app.test?.must_equal true
    end

    it "must return false if ENV['RACK_ENV'] != :test" do
      env, ENV['RACK_ENV'] = ENV['RACK_ENV'], 'development'
      app.to_app.test?.must_equal false
      ENV['RACK_ENV'] = env
    end
  end
end
