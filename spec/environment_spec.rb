require 'minitest_helper'

describe Hobbit::Environment do
  def app
    TestEnvironmentApp.new
  end

  describe '#environment' do
    it 'must return the setted environment' do
      app.to_app.environment = :development
      app.to_app.environment.must_equal :development
    end

    it 'must default to RACK_ENV' do
      skip
    end
  end

  describe '#environment=()' do
    it 'must set the environment' do
      app.to_app.environment = :test
      app.to_app.environment.must_equal :test
    end
  end

  describe '#development?' do
    it 'must return true if self.class.settings[:environment] = :development' do
      app.to_app.environment = :development
      app.to_app.development?.must_equal true
    end

    it 'must return false if self.class.settings[:environment] != :development' do
      app.to_app.environment = :production
      app.to_app.development?.must_equal false
    end
  end

  describe '#production?' do
    it 'must return true if self.class.settings[:environment] = :production' do
      app.to_app.environment = :production
      app.to_app.production?.must_equal true
    end

    it 'must return false if self.class.settings[:environment] != :production' do
      app.to_app.environment = :test
      app.to_app.production?.must_equal false
    end
  end

  describe '#test?' do
    it 'must return true if self.class.settings[:environment] = :test' do
      app.to_app.environment = :test
      app.to_app.test?.must_equal true
    end

    it 'must return false if self.class.settings[:environment] != :test' do
      app.to_app.environment = :development
      app.to_app.test?.must_equal false
    end
  end
end