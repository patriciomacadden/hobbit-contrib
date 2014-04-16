require 'minitest_helper'

describe Hobbit::Environment do
  include Hobbit::Contrib::Mock

  let :app do
    mock_app do
      include Hobbit::Environment
    end
  end

  def with_env(environment)
    env, ENV['RACK_ENV'] = ENV['RACK_ENV'], environment
    yield
    ENV['RACK_ENV'] = env
  end

  describe '::environment' do
    it 'must return the current environment' do
      with_env('development') do
        app.to_app.class.environment.must_equal :development
      end
    end
  end

  describe '#environment' do
    it 'must return the current environment' do
      with_env('development') do
        app.to_app.environment.must_equal :development
      end
    end
  end

  describe '::development?' do
    it "must return true if ENV['RACK_ENV'] = :development" do
      with_env('development') do
        app.to_app.class.development?.must_equal true
      end
    end

    it "must return false if ENV['RACK_ENV'] != :development" do
      app.to_app.class.development?.must_equal false
    end
  end

  describe '#development?' do
    it "must return true if ENV['RACK_ENV'] = :development" do
      with_env('development') do
        app.to_app.development?.must_equal true
      end
    end

    it "must return false if ENV['RACK_ENV'] != :development" do
      app.to_app.development?.must_equal false
    end
  end

  describe '::production?' do
    it "must return true if ENV['RACK_ENV'] = :production" do
      with_env('production') do
        app.to_app.class.production?.must_equal true
      end
    end

    it "must return false if ENV['RACK_ENV'] != :production" do
      app.to_app.class.production?.must_equal false
    end
  end

  describe '#production?' do
    it "must return true if ENV['RACK_ENV'] = :production" do
      with_env('production') do
        app.to_app.production?.must_equal true
      end
    end

    it "must return false if ENV['RACK_ENV'] != :production" do
      app.to_app.production?.must_equal false
    end
  end

  describe '::test?' do
    it "must return true if ENV['RACK_ENV'] = :test" do
      app.to_app.class.test?.must_equal true
    end

    it "must return false if ENV['RACK_ENV'] != :test" do
      with_env('development') do
        app.to_app.class.test?.must_equal false
      end
    end
  end

  describe '#test?' do
    it "must return true if ENV['RACK_ENV'] = :test" do
      app.to_app.test?.must_equal true
    end

    it "must return false if ENV['RACK_ENV'] != :test" do
      with_env('development') do
        app.to_app.test?.must_equal false
      end
    end
  end
end
