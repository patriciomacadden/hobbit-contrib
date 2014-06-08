require 'helper'

scope Hobbit::Environment do
  setup do
    mock_app do
      include Hobbit::Environment
    end
  end

  def with_env(environment)
    env, ENV['RACK_ENV'] = ENV['RACK_ENV'], environment
    yield
    ENV['RACK_ENV'] = env
  end

  scope '::environment' do
    test 'returns the current environment' do
      with_env('development') do
        assert app.to_app.class.environment == :development
      end
    end
  end

  scope '#environment' do
    test 'returns the current environment' do
      with_env('development') do
        assert app.to_app.environment == :development
      end
    end
  end

  scope '::development?' do
    test "returns true if ENV['RACK_ENV'] = :development" do
      with_env('development') do
        assert app.to_app.class.development? == true
      end
    end

    test "returns false if ENV['RACK_ENV'] != :development" do
      assert app.to_app.class.development? == false
    end
  end

  scope '#development?' do
    test "returns true if ENV['RACK_ENV'] = :development" do
      with_env('development') do
        assert app.to_app.development? == true
      end
    end

    test "returns false if ENV['RACK_ENV'] != :development" do
      assert app.to_app.development? == false
    end
  end

  scope '::production?' do
    test "returns true if ENV['RACK_ENV'] = :production" do
      with_env('production') do
        assert app.to_app.class.production? == true
      end
    end

    test "returns false if ENV['RACK_ENV'] != :production" do
      assert app.to_app.class.production? == false
    end
  end

  scope '#production?' do
    test "returns true if ENV['RACK_ENV'] = :production" do
      with_env('production') do
        assert app.to_app.production? == true
      end
    end

    test "returns false if ENV['RACK_ENV'] != :production" do
      assert app.to_app.production? == false
    end
  end

  scope '::test?' do
    test "returns true if ENV['RACK_ENV'] = :test" do
      assert app.to_app.class.test? == true
    end

    test "returns false if ENV['RACK_ENV'] != :test" do
      with_env('development') do
        assert app.to_app.class.test? == false
      end
    end
  end

  scope '#test?' do
    test "returns true if ENV['RACK_ENV'] = :test" do
      assert app.to_app.test? == true
    end

    test "returns false if ENV['RACK_ENV'] != :test" do
      with_env('development') do
        assert app.to_app.test? == false
      end
    end
  end
end
